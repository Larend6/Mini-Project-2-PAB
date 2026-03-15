import 'package:flutter/material.dart';

class AppNavbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppNavbar({super.key, this.title = 'Pokémon TCG Collection'});

  @override
  Widget build(BuildContext context) {

    final color = Theme.of(context).colorScheme;

    return AppBar(

      backgroundColor: color.surface,
      foregroundColor: color.onSurface,

      elevation: 1,

      titleSpacing: 16,

      title: Row(
        children: [

          Icon(
            Icons.catching_pokemon,
            color: color.primary,
          ),

          const SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,

            children: [

              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color.onSurface,
                ),
              ),

              Text(
                'Pokémon TCG',
                style: TextStyle(
                  fontSize: 11,
                  color: color.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}