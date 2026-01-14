import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Indicador de capacidad del plan
class CapacityIndicator extends StatelessWidget {
  final int current;
  final int max;

  const CapacityIndicator({
    super.key,
    required this.current,
    required this.max,
  });

  bool get _isFull => current >= max;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.people,
          size: 16,
          color: _isFull ? Colors.red : const Color(0xFF636E72),
        ),
        const SizedBox(width: 4),
        Text(
          '$current/$max plazas',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _isFull ? Colors.red : const Color(0xFF636E72),
          ),
        ),
      ],
    );
  }
}
