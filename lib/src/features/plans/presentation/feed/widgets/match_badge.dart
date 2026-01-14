import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Badge que muestra el porcentaje de match
class MatchBadge extends StatelessWidget {
  final int percentage;

  const MatchBadge({super.key, required this.percentage});

  Color get _backgroundColor {
    if (percentage >= 80) return const Color(0xFF4ECDC4);
    if (percentage >= 60) return const Color(0xFFFAB1A0);
    return const Color(0xFF636E72);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            '$percentage% Match',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
