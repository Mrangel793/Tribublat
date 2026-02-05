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

/// Niveles de planes destacados/patrocinados (solo para negocios)
enum SponsorTier {
  none, // No destacado
  basico, // Destacado basico - aparece con badge
  premium, // Premium - aparece primero en feeds
  exclusivo, // Exclusivo - banner en la parte superior
}

/// Extension para obtener informacion del tier de sponsor
extension SponsorTierInfo on SponsorTier {
  String get nombre {
    switch (this) {
      case SponsorTier.none:
        return 'Sin destacar';
      case SponsorTier.basico:
        return 'Destacado';
      case SponsorTier.premium:
        return 'Premium';
      case SponsorTier.exclusivo:
        return 'Exclusivo';
    }
  }

  String get descripcion {
    switch (this) {
      case SponsorTier.none:
        return 'Plan normal sin destacar';
      case SponsorTier.basico:
        return 'Badge de destacado visible';
      case SponsorTier.premium:
        return 'Aparece primero en el feed';
      case SponsorTier.exclusivo:
        return 'Banner promocional + primero en feed';
    }
  }

  Color get color {
    switch (this) {
      case SponsorTier.none:
        return const Color(0xFF636E72);
      case SponsorTier.basico:
        return const Color(0xFF4ECDC4);
      case SponsorTier.premium:
        return const Color(0xFFFFB347);
      case SponsorTier.exclusivo:
        return const Color(0xFFFF6B9D);
    }
  }

  IconData get icon {
    switch (this) {
      case SponsorTier.none:
        return Icons.remove_circle_outline;
      case SponsorTier.basico:
        return Icons.star_outline;
      case SponsorTier.premium:
        return Icons.star;
      case SponsorTier.exclusivo:
        return Icons.auto_awesome;
    }
  }
}

/// Rangos de edad para filtros
enum AgeRange {
  todos,
  jovenes,  // 18-25
  adultos,  // 26-40
  seniors,  // 40+
}

/// Extension para obtener informacion del rango de edad
extension AgeRangeInfo on AgeRange {
  String get nombre {
    switch (this) {
      case AgeRange.todos:
        return 'Todas las edades';
      case AgeRange.jovenes:
        return '18-25 anos';
      case AgeRange.adultos:
        return '26-40 anos';
      case AgeRange.seniors:
        return '40+ anos';
    }
  }

  String get nombreCorto {
    switch (this) {
      case AgeRange.todos:
        return 'Todos';
      case AgeRange.jovenes:
        return '18-25';
      case AgeRange.adultos:
        return '26-40';
      case AgeRange.seniors:
        return '40+';
    }
  }

  int? get minAge {
    switch (this) {
      case AgeRange.todos:
        return null;
      case AgeRange.jovenes:
        return 18;
      case AgeRange.adultos:
        return 26;
      case AgeRange.seniors:
        return 40;
    }
  }

  int? get maxAge {
    switch (this) {
      case AgeRange.todos:
        return null;
      case AgeRange.jovenes:
        return 25;
      case AgeRange.adultos:
        return 40;
      case AgeRange.seniors:
        return null;
    }
  }

  IconData get icon {
    switch (this) {
      case AgeRange.todos:
        return Icons.people;
      case AgeRange.jovenes:
        return Icons.person;
      case AgeRange.adultos:
        return Icons.person_outline;
      case AgeRange.seniors:
        return Icons.elderly;
    }
  }

  Color get color {
    switch (this) {
      case AgeRange.todos:
        return const Color(0xFF9B59B6);
      case AgeRange.jovenes:
        return const Color(0xFF4ECDC4);
      case AgeRange.adultos:
        return const Color(0xFFFFB347);
      case AgeRange.seniors:
        return const Color(0xFF95E1D3);
    }
  }
}
