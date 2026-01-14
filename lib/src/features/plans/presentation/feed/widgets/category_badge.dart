import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Badge que muestra la categoría del plan con emoji
class CategoryBadge extends StatelessWidget {
  final String name;
  final String emoji;

  const CategoryBadge({
    super.key,
    required this.name,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(240),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2D3436),
            ),
          ),
          const SizedBox(width: 4),
          Text(emoji, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
