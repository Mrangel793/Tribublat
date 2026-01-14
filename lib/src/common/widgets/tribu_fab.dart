import 'package:flutter/material.dart';

/// FAB personalizado de TribuLat con sombra púrpura
class TribuFab extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const TribuFab({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9B59B6).withAlpha(100),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: const Color(0xFF9B59B6),
        elevation: 0,
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}
