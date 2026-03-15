import 'package:flutter/material.dart';

import '../services/card_service.dart';
import '../widgets/app_navbar.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

import 'add_edit_page.dart';

class CardDetailPage extends StatefulWidget {
  final Map<String, dynamic> card;

  const CardDetailPage({super.key, required this.card});

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {

  final cardService = CardService();

  bool isDeleting = false;

  Future<void> _deleteCard() async {

    final userCardId = widget.card['id']?.toString();

    if (userCardId == null || userCardId.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID kartu tidak valid')),
      );

      return;
    }

    final confirmed = await showDialog<bool>(

      context: context,

      builder: (context) => AlertDialog(

        title: const Text('Hapus kartu'),

        content: const Text(
          'Apakah Anda yakin ingin menghapus kartu ini?',
        ),

        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),

          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),

        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      isDeleting = true;
    });

    try {

      await cardService.deleteCard(userCardId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kartu berhasil dihapus')),
      );

      Navigator.pop(context);

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus kartu: $e')),
      );

    } finally {

      if (mounted) {
        setState(() {
          isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final data = widget.card['cards'] ?? <String, dynamic>{};

    final name = data['name'] as String? ?? 'Tidak diketahui';
    final series = data['series'] as String? ?? '-';
    final rarity = data['rarity'] as String? ?? '-';
    final imageUrl = data['image_url'] as String?;

    final price = widget.card['price']?.toString() ?? '0';
    final quantity = widget.card['quantity']?.toString() ?? '1';

    return Scaffold(

      appBar: const AppNavbar(title: 'Detail Kartu'),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(AppSpacing.lg),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [

            Container(

              height: 240,

              decoration: BoxDecoration(

                borderRadius:
                    BorderRadius.circular(AppRadius.large),

                color: Theme.of(context).cardColor,

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],

                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),

              child: imageUrl == null
                  ? const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 60,
                        color: Colors.grey,
                      ),
                    )
                  : null,
            ),

            const SizedBox(height: AppSpacing.lg),

            Text(
              name,
              style: AppTextStyles.heading,
            ),

            const SizedBox(height: AppSpacing.sm),

            _rarityBadge(rarity),

            const SizedBox(height: AppSpacing.lg),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [

                    _infoRow("Series", series),
                    _infoRow("Harga", "Rp $price"),
                    _infoRow("Jumlah", quantity),

                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      "Informasi Tambahan",
                      style: AppTextStyles.subheading,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    Text(
                      "User card ID: ${widget.card['id'] ?? '-'}",
                      style: AppTextStyles.body,
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    Text(
                      "Card ID: ${data['id'] ?? '-'}",
                      style: AppTextStyles.body,
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(

                icon: const Icon(Icons.edit),

                label: const Text('Update Kartu'),

                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddEditPage(card: widget.card),
                    ),
                  ).then((value) {

                    if (value == true) {
                      Navigator.pop(context);
                    }

                  });
                },
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            SizedBox(
              height: 50,
              child: OutlinedButton.icon(

                icon: isDeleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.delete_outline),

                label: const Text('Hapus Kartu'),

                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.medium),
                  ),
                ),

                onPressed: isDeleting ? null : _deleteCard,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Text(
            label,
            style: AppTextStyles.body
                .copyWith(color: Colors.grey),
          ),

          Text(
            value,
            style: AppTextStyles.body
                .copyWith(fontWeight: FontWeight.bold),
          ),

        ],
      ),
    );
  }

  Widget _rarityBadge(String rarity) {

    return Container(

      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),

      decoration: BoxDecoration(

        color: AppColors.primary.withValues(alpha: 0.1),

        borderRadius:
            BorderRadius.circular(AppRadius.medium),
      ),

      child: Text(
        rarity,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}