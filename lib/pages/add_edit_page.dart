import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../services/card_service.dart';
import '../services/storage_service.dart';
import '../widgets/app_navbar.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

import 'main_page.dart';

class AddEditPage extends StatefulWidget {
  final Map<String, dynamic>? card;

  const AddEditPage({super.key, this.card});

  @override
  State<AddEditPage> createState() => _AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final seriesController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController(text: "1");

  String? rarity;

  File? imageFile;
  String? existingImageUrl;

  bool isLoading = false;

  final picker = ImagePicker();
  final storageService = StorageService();
  final cardService = CardService();

  final rupiahFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  final rarityOptions = const [
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

  @override
  void initState() {
    super.initState();

    if (widget.card != null) {
      final cardData = widget.card!['cards'] ?? {};

      nameController.text = cardData['name'] ?? "";
      seriesController.text = cardData['series'] ?? "";
      rarity = cardData['rarity'];
      existingImageUrl = cardData['image_url'];

      priceController.text = widget.card!['price']?.toString() ?? "";
      quantityController.text =
          widget.card!['quantity']?.toString() ?? "1";
    }

    priceController.addListener(formatPrice);
  }

  void formatPrice() {
    if (priceController.text.isEmpty) return;

    String clean = priceController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (clean.isEmpty) {
      priceController.clear();
      return;
    }

    int value = int.parse(clean);

    String formatted = rupiahFormat.format(value);

    priceController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  int parsePrice() {
    String clean = priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return 0;
    return int.parse(clean);
  }

  void increaseQty() {
    int value = int.tryParse(quantityController.text) ?? 0;
    value++;
    quantityController.text = value.toString();
  }

  void decreaseQty() {
    int value = int.tryParse(quantityController.text) ?? 0;
    if (value > 0) value--;
    quantityController.text = value.toString();
  }

  Future<void> saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      String? imageUrl = existingImageUrl;

      if (imageFile != null) {
        imageUrl = await storageService.uploadImage(imageFile!);
      }

      final userCardId = widget.card?['id']?.toString();
      final cardId = widget.card?['cards']?['id']?.toString();

      if (userCardId != null && cardId != null) {
        await cardService.updateCardAndUserCard(
          userCardId: userCardId,
          cardId: cardId,
          name: nameController.text.trim(),
          series: seriesController.text.trim(),
          rarity: rarity!,
          imageUrl: imageUrl,
          price: parsePrice(),
          quantity: int.parse(quantityController.text),
        );
      } else {
        await cardService.addCard(
          cardId: cardId,
          name: nameController.text.trim(),
          series: seriesController.text.trim(),
          rarity: rarity!,
          imageUrl: imageUrl,
          price: parsePrice(),
          quantity: int.parse(quantityController.text),
        );
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan kartu: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget fieldTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppNavbar(title: "Tambah Kartu"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.large),
                    color: Theme.of(context).cardColor,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: imageFile != null
                      ? ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppRadius.large),
                          child: Image.file(imageFile!, fit: BoxFit.cover),
                        )
                      : existingImageUrl != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.large),
                              child: Image.network(existingImageUrl!,
                                  fit: BoxFit.cover),
                            )
                          : Center(
                              child: Text(
                                "Tap untuk memilih gambar",
                                style: AppTextStyles.body
                                    .copyWith(color: Colors.grey),
                              ),
                            ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              fieldTitle("Name"),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: "Contoh: Pikachu",
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Nama kartu wajib diisi";
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              fieldTitle("Series"),
              TextFormField(
                controller: seriesController,
                decoration: const InputDecoration(
                  hintText: "Contoh: Scarlet & Violet",
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Series wajib diisi";
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              fieldTitle("Rarity"),
              DropdownButtonFormField<String>(
                value: rarity,
                hint: const Text("Pilih rarity kartu"),
                items: rarityOptions
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(r),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => rarity = value),
                validator: (value) {
                  if (value == null) {
                    return "Pilih rarity";
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              fieldTitle("Price"),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Contoh: Rp 25.000",
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              fieldTitle("Quantity"),
              Row(
                children: [

                  Expanded(
                    child: TextFormField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "Jumlah kartu",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Quantity wajib diisi";
                        }

                        int? val = int.tryParse(value);

                        if (val == null) {
                          return "Harus angka";
                        }

                        if (val < 0) {
                          return "Tidak boleh minus";
                        }

                        return null;
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: decreaseQty,
                  ),

                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: increaseQty,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : saveCard,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Simpan"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
