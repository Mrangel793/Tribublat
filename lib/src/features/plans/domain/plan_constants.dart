import 'package:flutter/material.dart';

/// Información de categoría para mostrar en UI
class PlanCategoryInfo {
  final String id;
  final String nombre;
  final String emoji;
  final IconData icon;
  final Color color;

  const PlanCategoryInfo({
    required this.id,
    required this.nombre,
    required this.emoji,
    required this.icon,
    required this.color,
  });
}

/// Constantes de categorías de planes
class PlanConstants {
  static const List<PlanCategoryInfo> categories = [
    PlanCategoryInfo(
      id: 'gastronomia',
      nombre: 'Gastronomia',
      emoji: '🍽',
      icon: Icons.restaurant,
      color: Color(0xFFFF6B9D),
    ),
    PlanCategoryInfo(
      id: 'deportes',
      nombre: 'Deportes',
      emoji: '⚽',
      icon: Icons.sports_soccer,
      color: Color(0xFF4ECDC4),
    ),
    PlanCategoryInfo(
      id: 'cultura',
      nombre: 'Cultura',
      emoji: '🏛',
      icon: Icons.museum,
      color: Color(0xFF95E1D3),
    ),
    PlanCategoryInfo(
      id: 'vidaNocturna',
      nombre: 'Vida Nocturna',
      emoji: '🌙',
      icon: Icons.nightlife,
      color: Color(0xFFC06BFF),
    ),
    PlanCategoryInfo(
      id: 'naturaleza',
      nombre: 'Naturaleza',
      emoji: '🌿',
      icon: Icons.nature,
      color: Color(0xFF55E1D5),
    ),
    PlanCategoryInfo(
      id: 'tecnologia',
      nombre: 'Tecnologia',
      emoji: '💻',
      icon: Icons.computer,
      color: Color(0xFF6C5CE7),
    ),
    PlanCategoryInfo(
      id: 'arte',
      nombre: 'Arte',
      emoji: '🎨',
      icon: Icons.palette,
      color: Color(0xFFFD79A8),
    ),
    PlanCategoryInfo(
      id: 'musica',
      nombre: 'Musica',
      emoji: '🎵',
      icon: Icons.music_note,
      color: Color(0xFFFAB1A0),
    ),
    PlanCategoryInfo(
      id: 'cine',
      nombre: 'Cine',
      emoji: '🎬',
      icon: Icons.movie,
      color: Color(0xFF74B9FF),
    ),
    PlanCategoryInfo(
      id: 'viajes',
      nombre: 'Viajes',
      emoji: '✈️',
      icon: Icons.flight,
      color: Color(0xFFA29BFE),
    ),
  ];

  /// Obtener categoría por ID
  static PlanCategoryInfo? getCategoryById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Obtener categoría por enum
  static PlanCategoryInfo? getCategoryByEnum(PlanCategory category) {
    return getCategoryById(category.name);
  }
}

/// Categorías de planes
enum PlanCategory {
  gastronomia,
  deportes,
  cultura,
  vidaNocturna,
  naturaleza,
  tecnologia,
  arte,
  musica,
  cine,
  viajes,
  otros,
}

/// Estado del plan
enum PlanStatus {
  activo,
  lleno,
  enProgreso,
  finalizado,
  cancelado,
}

/// Tipo de precio
enum PlanPriceType {
  gratis,
  fijo,
  variable,
}

/// Filtros del feed
enum FeedFilter {
  todos,
  hoy,
  cerca,
  miEnergia,
}

/// Tabs del feed
enum FeedTab {
  paraTi,
  cerca,
  instantaneos,
  misPlanes,
}
