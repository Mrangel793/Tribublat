import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Botón de acción para unirse a un plan
class PlanActionButton extends StatelessWidget {
  final bool isJoined;
  final bool isInWaitingList;
  final bool isFull;
  final VoidCallback onPressed;
  final bool isLoading;

  const PlanActionButton({
    super.key,
    required this.isJoined,
    required this.isInWaitingList,
    required this.isFull,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9B59B6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    if (isJoined) {
      return _buildOutlinedButton(
        label: 'Ya estas unido',
        icon: Icons.check_circle,
        enabled: false,
        color: const Color(0xFF4ECDC4),
      );
    }

    if (isInWaitingList) {
      return _buildOutlinedButton(
        label: 'En lista de espera',
        icon: Icons.hourglass_empty,
        enabled: false,
        color: const Color(0xFFFAB1A0),
      );
    }

    if (isFull) {
      return _buildOutlinedButton(
        label: 'Lista de Espera',
        icon: null,
        enabled: true,
        onPressed: onPressed,
        color: const Color(0xFF9B59B6),
      );
    }

    return _buildFilledButton();
  }

  Widget _buildFilledButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9B59B6),
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: const Color(0xFF9B59B6).withAlpha(100),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Unirme',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton({
    required String label,
    IconData? icon,
    required bool enabled,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: enabled ? (onPressed ?? this.onPressed) : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(
            color: enabled ? color : const Color(0xFFE0E0E0),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
