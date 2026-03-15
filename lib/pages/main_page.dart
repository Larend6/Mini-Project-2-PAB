import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/card_service.dart';
import '../widgets/app_navbar.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

import 'add_edit_page.dart';
import 'card_detail_page.dart';
import 'login_page.dart';
import 'profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  int _selectedIndex = 1;

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const AddCardPage();
      case 2:
        return const ProfilePage();
      default:
        return const HomeSection();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    final color = Theme.of(context).colorScheme;

    return Scaffold(

      body: _buildPage(_selectedIndex),

      bottomNavigationBar: BottomNavigationBar(

        backgroundColor: color.surface,

        selectedItemColor: AppColors.primary,

        unselectedItemColor: color.onSurface.withOpacity(0.6),

        currentIndex: _selectedIndex,

        showUnselectedLabels: true,

        onTap: _onItemTapped,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Tambah',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Utama',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),

        ],
      ),
    );
  }
}

enum CardViewMode {
  list,
  grid,
  large,
}

class HomeSection extends StatefulWidget {
  const HomeSection({super.key});

  @override
  State<HomeSection> createState() => _HomeSectionState();
}

class _HomeSectionState extends State<HomeSection> {

  final cardService = CardService();

  String searchText = '';
  String rarityFilter = 'All';

  CardViewMode viewMode = CardViewMode.list;

  static const rarityOptions = [
    'All',
    'Common',
    'Uncommon',
    'Rare',
    'Double Rare',
    'Ace Spec Rare',
    'Illustration Rare',
    'Ultra Rare',
    'Special Illustration Rare',
    'Hyper Rare',
    'Shiny Rare',
    'Shiny Ultra Rare',
    'Black Star Promo',
  ];

  Future<void> _refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    final color = Theme.of(context).colorScheme;

    return FutureBuilder<List<Map<String, dynamic>>>(

      future: cardService.getUserCards(),

      builder: (context, snapshot) {

        final cards = snapshot.data ?? [];

        final filtered = cards.where((card) {

          final cardData = card['cards'] ?? {};

          final name =
              (cardData['name'] ?? '').toString().toLowerCase();

          final rarity =
              (cardData['rarity'] ?? 'Unknown').toString();

          final matchSearch =
              name.contains(searchText.toLowerCase());

          final matchRarity =
              rarityFilter == 'All' || rarity == rarityFilter;

          return matchSearch && matchRarity;

        }).toList();

        final total = filtered.fold<int>(0, (sum, card) {

          final p = card['price'];

          return sum + (p is num ? p.toInt() : 0);

        });

        return Scaffold(

          appBar: const AppNavbar(title: 'Beranda'),

          body: RefreshIndicator(

            onRefresh: _refresh,

            child: ListView(

              padding: EdgeInsets.zero,

              children: [

                Container(
                  margin: const EdgeInsets.all(AppSpacing.lg),

                  padding: const EdgeInsets.all(AppSpacing.lg),

                  decoration: BoxDecoration(

                    borderRadius:
                        BorderRadius.circular(AppRadius.large),

                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primary,
                        Color(0xFF5A6CE0),
                      ],
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        'My Card Vault',
                        style: AppTextStyles.heading
                            .copyWith(color: Colors.white),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      const Text(
                        'Organize your TCG collection with ease',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),

                  child: Column(
                    children: [

                      TextField(

                        decoration: InputDecoration(

                          hintText: 'Search cards...',
                          prefixIcon: const Icon(Icons.search),

                          filled: true,
                          fillColor: color.surface,

                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.medium),
                            borderSide: BorderSide.none,
                          ),
                        ),

                        onChanged: (value) =>
                            setState(() => searchText = value.trim()),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      DropdownButtonFormField<String>(

                        value: rarityFilter,

                        decoration: InputDecoration(

                          filled: true,
                          fillColor: color.surface,

                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.medium),
                            borderSide: BorderSide.none,
                          ),
                        ),

                        items: rarityOptions
                            .map(
                              (option) => DropdownMenuItem(
                                value: option,
                                child: Text(option),
                              ),
                            )
                            .toList(),

                        onChanged: (value) {
                          if (value != null) {
                            setState(() => rarityFilter = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),

                  child: Row(

                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [

                      Text(
                        'Collection',
                        style: AppTextStyles.subheading,
                      ),

                      Text(
                        '${filtered.length} cards',
                        style: TextStyle(
                          color: color.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),

                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [

                      _statCard(context,'Total Cards', '${filtered.length}'),

                      _statCard(context,'Total Value', 'Rp $total'),

                      _statCard(context,'Rarity', rarityFilter),

                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),

                  child: Row(

                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [

                      Text(
                        'Your cards',
                        style: AppTextStyles.subheading,
                      ),

                      Row(
                        children: [

                          IconButton(
                            icon: const Icon(Icons.view_list),
                            color: viewMode == CardViewMode.list
                                ? AppColors.primary
                                : Colors.grey,
                            onPressed: () {
                              setState(() {
                                viewMode = CardViewMode.list;
                              });
                            },
                          ),

                          IconButton(
                            icon: const Icon(Icons.grid_view),
                            color: viewMode == CardViewMode.grid
                                ? AppColors.primary
                                : Colors.grey,
                            onPressed: () {
                              setState(() {
                                viewMode = CardViewMode.grid;
                              });
                            },
                          ),

                          IconButton(
                            icon: const Icon(Icons.view_agenda),
                            color: viewMode == CardViewMode.large
                                ? AppColors.primary
                                : Colors.grey,
                            onPressed: () {
                              setState(() {
                                viewMode = CardViewMode.large;
                              });
                            },
                          ),

                          IconButton(
                            icon: const Icon(Icons.add_circle),
                            color: AppColors.primary,
                            onPressed: () {

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddEditPage(),
                                ),
                              ).then((_) => setState(() {}));
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                _buildCardView(filtered),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardView(List<Map<String, dynamic>> cards) {

    if (viewMode == CardViewMode.grid) {

      return GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cards.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.7,
        ),
        itemBuilder: (context, index) {

          final card = cards[index];
          final data = card['cards'] ?? {};

          return GestureDetector(

            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CardDetailPage(card: card),
                ),
              ).then((_) => setState(() {}));
            },

            child: Card(

              child: Column(

                children: [

                  Expanded(
                    child: data['image_url'] != null
                        ? Image.network(
                            data['image_url'],
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Text(
                      data['name'] ?? '',
                      style: AppTextStyles.body,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    if (viewMode == CardViewMode.large) {

      return Column(
        children: cards.map((card) {

          final data = card['cards'] ?? {};

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),

            child: Card(

              child: Column(

                children: [

                  if (data['image_url'] != null)
                    Image.network(
                      data['image_url'],
                      height: 260,
                      fit: BoxFit.cover,
                    ),

                  ListTile(
                    title: Text(data['name'] ?? ''),
                    subtitle: Text(
                      '${data['series'] ?? '-'} • ${data['rarity'] ?? '-'}',
                    ),
                    trailing: Text(
                      'Rp ${card['price'] ?? 0}',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CardDetailPage(card: card),
                        ),
                      ).then((_) => setState(() {}));
                    },
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }

    return Column(
      children: cards.map((card) {

        final data = card['cards'] ?? {};

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),

          child: Card(

            child: ListTile(

              leading: data['image_url'] != null
                  ? ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppRadius.small),
                      child: Image.network(
                        data['image_url'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.image),

              title: Text(data['name'] ?? ''),

              subtitle: Text(
                '${data['series'] ?? '-'} • ${data['rarity'] ?? '-'}',
              ),

              trailing: Text(
                'Rp ${card['price'] ?? 0}',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),

              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CardDetailPage(card: card),
                  ),
                ).then((_) => setState(() {}));
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _statCard(BuildContext context, String title, String value) {

  final color = Theme.of(context).colorScheme;

  return Container(

    width: 110,

    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),

    decoration: BoxDecoration(
      color: color.surface,
      borderRadius: BorderRadius.circular(AppRadius.medium),
    ),

    child: Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(
          title,
          style: AppTextStyles.caption.copyWith(
            color: color.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

      ],
    ),
  );
}
}

class AddCardPage extends StatelessWidget {

  const AddCardPage({super.key});

  @override
  Widget build(BuildContext context) {

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {

      return Center(

        child: Padding(

          padding: const EdgeInsets.all(AppSpacing.lg),

          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              const Text(
                'Silakan login dulu untuk menambah kartu.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.md),

              ElevatedButton(

                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ),
                  );
                },

                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    return const AddEditPage();
  }
}