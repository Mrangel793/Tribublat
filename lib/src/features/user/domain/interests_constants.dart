import 'package:flutter/material.dart';

/// Clase que representa un interés o categoría
class Interest {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String emoji;

  const Interest({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.emoji = '',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Interest && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Constantes con todos los intereses disponibles
class InterestsConstants {
  /// Lista completa de intereses predefinidos
  static const List<Interest> allInterests = [
    Interest(
      id: 'deportes',
      name: 'Deportes',
      description: 'Actividades físicas, fitness y deportes',
      icon: Icons.sports_soccer,
      color: Color(0xFF4ECDC4),
      emoji: '⚽',
    ),
    Interest(
      id: 'cultura',
      name: 'Cultura',
      description: 'Museos, exposiciones y eventos culturales',
      icon: Icons.museum,
      color: Color(0xFF95E1D3),
      emoji: '🏛️',
    ),
    Interest(
      id: 'gastronomia',
      name: 'Gastronomía',
      description: 'Restaurantes, cocina y experiencias culinarias',
      icon: Icons.restaurant,
      color: Color(0xFFFF6B9D),
      emoji: '🍽️',
    ),
    Interest(
      id: 'vida_nocturna',
      name: 'Vida Nocturna',
      description: 'Bares, discotecas y eventos nocturnos',
      icon: Icons.nightlife,
      color: Color(0xFFC06BFF),
      emoji: '🌙',
    ),
    Interest(
      id: 'naturaleza',
      name: 'Naturaleza',
      description: 'Senderismo, camping y actividades al aire libre',
      icon: Icons.nature,
      color: Color(0xFF55E1D5),
      emoji: '🌿',
    ),
    Interest(
      id: 'tecnologia',
      name: 'Tecnología',
      description: 'Gadgets, innovación y eventos tech',
      icon: Icons.computer,
      color: Color(0xFF6C5CE7),
      emoji: '💻',
    ),
    Interest(
      id: 'arte',
      name: 'Arte',
      description: 'Galerías, pintura, escultura y arte visual',
      icon: Icons.palette,
      color: Color(0xFFFD79A8),
      emoji: '🎨',
    ),
    Interest(
      id: 'musica',
      name: 'Música',
      description: 'Conciertos, festivales y eventos musicales',
      icon: Icons.music_note,
      color: Color(0xFFFAB1A0),
      emoji: '🎵',
    ),
    Interest(
      id: 'cine',
      name: 'Cine',
      description: 'Películas, series y eventos cinematográficos',
      icon: Icons.movie,
      color: Color(0xFF74B9FF),
      emoji: '🎬',
    ),
    Interest(
      id: 'viajes',
      name: 'Viajes',
      description: 'Explorar nuevos lugares y culturas',
      icon: Icons.flight,
      color: Color(0xFFA29BFE),
      emoji: '✈️',
    ),
    Interest(
      id: 'gaming',
      name: 'Gaming',
      description: 'Videojuegos y comunidad gamer',
      icon: Icons.sports_esports,
      color: Color(0xFF00B894),
      emoji: '🎮',
    ),
    Interest(
      id: 'lectura',
      name: 'Lectura',
      description: 'Libros, clubes de lectura y literatura',
      icon: Icons.menu_book,
      color: Color(0xFF636E72),
      emoji: '📚',
    ),
    Interest(
      id: 'fitness',
      name: 'Fitness',
      description: 'Gimnasio, crossfit y entrenamiento',
      icon: Icons.fitness_center,
      color: Color(0xFFE17055),
      emoji: '💪',
    ),
    Interest(
      id: 'fotografia',
      name: 'Fotografía',
      description: 'Fotografía artística y profesional',
      icon: Icons.camera_alt,
      color: Color(0xFF00CEC9),
      emoji: '📷',
    ),
    Interest(
      id: 'cocina',
      name: 'Cocina',
      description: 'Cocinar, recetas y gastronomía casera',
      icon: Icons.kitchen,
      color: Color(0xFFFF7675),
      emoji: '👨‍🍳',
    ),
    Interest(
      id: 'mascotas',
      name: 'Mascotas',
      description: 'Amantes de los animales y mascotas',
      icon: Icons.pets,
      color: Color(0xFFFDCB6E),
      emoji: '🐕',
    ),
    Interest(
      id: 'yoga',
      name: 'Yoga',
      description: 'Yoga, meditación y bienestar',
      icon: Icons.self_improvement,
      color: Color(0xFF81ECEC),
      emoji: '🧘',
    ),
    Interest(
      id: 'baile',
      name: 'Baile',
      description: 'Baile, danza y ritmos latinos',
      icon: Icons.nightlife,
      color: Color(0xFFE84393),
      emoji: '💃',
    ),
    Interest(
      id: 'senderismo',
      name: 'Senderismo',
      description: 'Caminatas, montañismo y naturaleza',
      icon: Icons.hiking,
      color: Color(0xFF55A3FF),
      emoji: '🥾',
    ),
    Interest(
      id: 'cafe',
      name: 'Café',
      description: 'Cultura del café y cafeterías',
      icon: Icons.coffee,
      color: Color(0xFFA0522D),
      emoji: '☕',
    ),
  ];

  /// Obtiene un interés por su ID
  static Interest? getInterestById(String id) {
    try {
      return allInterests.firstWhere((interest) => interest.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene múltiples intereses por sus IDs
  static List<Interest> getInterestsByIds(List<String> ids) {
    return ids
        .map((id) => getInterestById(id))
        .where((interest) => interest != null)
        .cast<Interest>()
        .toList();
  }

  /// Filtra intereses por búsqueda de texto
  static List<Interest> searchInterests(String query) {
    if (query.isEmpty) {
      return allInterests;
    }

    final lowerQuery = query.toLowerCase();
    return allInterests.where((interest) {
      return interest.name.toLowerCase().contains(lowerQuery) ||
          interest.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Obtiene los IDs de una lista de intereses
  static List<String> getInterestIds(List<Interest> interests) {
    return interests.map((interest) => interest.id).toList();
  }

  /// Valida si una lista de IDs de intereses es válida
  /// Retorna true si todos los IDs existen y la cantidad está entre min y max
  static bool validateInterestIds(
    List<String> ids, {
    int min = 3,
    int max = 10,
  }) {
    if (ids.length < min || ids.length > max) {
      return false;
    }

    // Verificar que todos los IDs existan
    for (final id in ids) {
      if (getInterestById(id) == null) {
        return false;
      }
    }

    return true;
  }
}
