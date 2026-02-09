import 'package:flutter/material.dart';

/// Paleta de colores Dark Mode para el feed
class DarkFeedColors {
  DarkFeedColors._();

  // Fondos
  static const Color background = Color(0xFF0A0A0A);
  static const Color cardBackground = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFF16213E);
  static const Color borderSubtle = Color(0xFF2A2A3E);

  // Gradiente primario
  static const Color gradientOrange = Color(0xFFFF6B35);
  static const Color gradientViolet = Color(0xFF9B59B6);
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientOrange, gradientViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Acentos
  static const Color greenEmerald = Color(0xFF2ECC71);

  // Texto
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8899AA);

  // Funcionales
  static const Color errorRed = Color(0xFFFF4757);
  static const Color warningOrange = Color(0xFFFF6B35);
}
