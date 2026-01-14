import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget para mostrar calificación con estrellas
class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;
  final bool showValue;
  final int? totalReviews;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 16,
    this.color = const Color(0xFFFFD700),
    this.showValue = true,
    this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, size: size, color: color),
        const SizedBox(width: 2),
        if (showValue)
          Text(
            rating.toStringAsFixed(1),
            style: GoogleFonts.inter(
              fontSize: size * 0.75,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2D3436),
            ),
          ),
        if (totalReviews != null) ...[
          Text(
            ' ($totalReviews)',
            style: GoogleFonts.inter(
              fontSize: size * 0.65,
              color: const Color(0xFF636E72),
            ),
          ),
        ],
      ],
    );
  }
}

/// Widget completo con 5 estrellas
class StarRatingFull extends StatelessWidget {
  final double rating;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  const StarRatingFull({
    super.key,
    required this.rating,
    this.size = 16,
    this.activeColor = const Color(0xFFFFD700),
    this.inactiveColor = const Color(0xFFE0E0E0),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, size: size, color: activeColor);
        } else if (index < rating) {
          return Icon(Icons.star_half, size: size, color: activeColor);
        }
        return Icon(Icons.star_border, size: size, color: inactiveColor);
      }),
    );
  }
}
