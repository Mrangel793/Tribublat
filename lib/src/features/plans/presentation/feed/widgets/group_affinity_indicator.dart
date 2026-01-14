import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Indicador circular de afinidad grupal
class GroupAffinityIndicator extends StatelessWidget {
  final double affinity; // 0.0 a 1.0

  const GroupAffinityIndicator({super.key, required this.affinity});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  value: affinity,
                  strokeWidth: 3,
                  backgroundColor: const Color(0xFFE0E0E0),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF9B59B6),
                  ),
                ),
              ),
              Text(
                '${(affinity * 100).toInt()}',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9B59B6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Afinidad grupal',
          style: GoogleFonts.inter(
            fontSize: 8,
            color: const Color(0xFF636E72),
          ),
        ),
      ],
    );
  }
}
