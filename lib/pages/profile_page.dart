import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/theme_provider.dart';
import '../services/card_service.dart';
import '../services/storage_service.dart';

import '../widgets/app_navbar.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

import 'login_page.dart';
import 'change_password_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final nameController = TextEditingController();
  final imagePicker = ImagePicker();
  final cardService = CardService();

  String? profileUrl;
  bool loading = false;

  int totalCards = 0;
  int totalValue = 0;
  String rarestCard = "-";

  @override
  void initState() {
    super.initState();

    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      nameController.text = user.userMetadata?['name'] ?? '';
      profileUrl = user.userMetadata?['profile_photo'];
    }

    loadCollectionStats();
  }

  Future<void> loadCollectionStats() async {

    final cards = await cardService.getUserCards();

    int value = 0;
    String rare = "-";

    if (cards.isNotEmpty) {
      rare = cards.first['cards']?['name'] ?? "-";
    }

    for (var card in cards) {
      final price = card['price'];
      if (price is num) value += price.toInt();
    }

    setState(() {
      totalCards = cards.length;
      totalValue = value;
      rarestCard = rare;
    });
  }

  String getCollectorBadge() {

    if (totalCards < 10) return "Beginner Collector";
    if (totalCards < 30) return "Intermediate Collector";

    return "Master Collector";
  }

  Future<void> _updateName() async {

    final newName = nameController.text.trim();

    if (newName.isEmpty) return;

    await Supabase.instance.client.auth.updateUser(
      UserAttributes(data: {'name': newName}),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Nama diperbarui")),
    );
  }

  Future<void> _pickAndUploadProfilePhoto() async {

    final picked = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (picked == null) return;

    setState(() => loading = true);

    try {

      final file = File(picked.path);
      final storage = StorageService();

      final uploadedUrl = await storage.uploadImage(file);

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {
          'profile_photo': uploadedUrl,
          'name': nameController.text.trim(),
        }),
      );

      setState(() => profileUrl = uploadedUrl);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload foto gagal: $e")),
      );
    } finally {

      setState(() => loading = false);

    }
  }

  @override
  Widget build(BuildContext context) {

    final user = Supabase.instance.client.auth.currentUser;
    final color = Theme.of(context).colorScheme;

    if (user == null) {
      return Scaffold(
        appBar: const AppNavbar(title: "Profil"),
        body: Center(
          child: ElevatedButton(
            child: const Text("Login"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ),
      );
    }

    final displayName = user.userMetadata?['name'] ?? "User";
    final email = user.email ?? "";

    return Scaffold(

      appBar: const AppNavbar(title: "Profil"),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(AppSpacing.lg),

        child: Column(

          children: [

            Column(

              children: [

                Stack(
                  children: [

                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          profileUrl != null ? NetworkImage(profileUrl!) : null,
                      child: profileUrl == null
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),

                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: loading ? null : _pickAndUploadProfilePhoto,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: color.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                Text(displayName, style: AppTextStyles.heading),

                const SizedBox(height: 4),

                Text(email, style: AppTextStyles.caption),

                const SizedBox(height: AppSpacing.sm),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    getCollectorBadge(),
                    style: TextStyle(
                      color: color.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            Row(
              children: [

                _statCard("Cards", totalCards.toString()),
                const SizedBox(width: AppSpacing.md),

                _statCard("Value", "Rp $totalValue"),
                const SizedBox(width: AppSpacing.md),

                _statCard("Rarest", rarestCard),

              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.large),
              ),

              child: Column(

                children: [

                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("Edit Name"),
                    subtitle: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: "Nama lengkap",
                        border: InputBorder.none,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: _updateName,
                    ),
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text("Change Password"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordPage(),
                        ),
                      );

                    },
                  ),

                  const Divider(height: 1),

                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {

                      return SwitchListTile(
                        secondary: const Icon(Icons.dark_mode),
                        title: const Text("Dark Mode"),
                        value: themeProvider.themeMode == ThemeMode.dark,
                        onChanged: (v) {
                          themeProvider.toggleTheme();
                        },
                      );
                    },
                  ),

                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: color.error,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),

                onPressed: () async {

                  await Supabase.instance.client.auth.signOut();

                  if (!mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );

                },

                child: const Text("Logout"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value) {

    final theme = Theme.of(context);

    return Expanded(
      child: Container(

        padding: const EdgeInsets.all(AppSpacing.md),

        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),

        child: Column(

          children: [

            Text(title, style: AppTextStyles.caption),

            const SizedBox(height: 6),

            Text(value, style: AppTextStyles.subheading),

          ],
        ),
      ),
    );
  }
}
