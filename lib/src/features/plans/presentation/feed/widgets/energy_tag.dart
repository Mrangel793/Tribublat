import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/src/features/user/domain/user_model.dart';

/// Tag que muestra el nivel de energía requerido
class EnergyTag extends StatelessWidget {
  final EnergyLevel level;

  const EnergyTag({super.key, required this.level});

  Color get _color {
    switch (level) {
      case EnergyLevel.baja:
        return const Color(0xFF74B9FF);
      case EnergyLevel.media:
        return const Color(0xFF4ECDC4);
      case EnergyLevel.alta:
        return const Color(0xFFFF6B9D);
    }
  }

  String get _label {
    switch (level) {
      case EnergyLevel.baja:
        return 'Energia Baja';
      case EnergyLevel.media:
        return 'Energia Media';
      case EnergyLevel.alta:
        return 'Energia Alta';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withAlpha(38),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color, width: 1),
      ),
      child: Text(
        _label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}
