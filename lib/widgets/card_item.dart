import 'package:flutter/material.dart';

class CardItem extends StatelessWidget {
  final String name;
  final String series;
  final String rarity;
  final int price;
  final String? imageUrl;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onTap;

  const CardItem({
    super.key,
    required this.name,
    required this.series,
    required this.rarity,
    required this.price,
    this.imageUrl,
    required this.onDelete,
    required this.onEdit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFFFDE00),
          width: 2,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl!,
                  width: 50,
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(Icons.image),

        title: Text(name),

        subtitle: Text(
          "$series • $rarity\nRp $price",
        ),

        isThreeLine: true,

        trailing: Column(
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}