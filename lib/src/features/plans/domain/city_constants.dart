/// Constantes de ciudades para filtros de ubicacion
class CityConstants {
  CityConstants._();

  /// Ciudades principales de Colombia
  static const List<String> colombianCities = [
    'Bogota',
    'Medellin',
    'Cali',
    'Barranquilla',
    'Cartagena',
    'Bucaramanga',
    'Pereira',
    'Manizales',
    'Santa Marta',
    'Cucuta',
    'Ibague',
    'Villavicencio',
    'Pasto',
    'Armenia',
    'Neiva',
    'Monteria',
    'Valledupar',
    'Popayan',
    'Sincelejo',
    'Tunja',
    'Florencia',
    'Quibdo',
    'Riohacha',
    'Yopal',
    'Leticia',
  ];

  /// Obtener ciudad por indice
  static String? getCityAt(int index) {
    if (index < 0 || index >= colombianCities.length) return null;
    return colombianCities[index];
  }

  /// Buscar ciudades que coincidan con el texto
  static List<String> searchCities(String query) {
    if (query.isEmpty) return colombianCities;
    final queryLower = query.toLowerCase();
    return colombianCities
        .where((city) => city.toLowerCase().contains(queryLower))
        .toList();
  }

  /// Verificar si una ciudad existe
  static bool isValidCity(String city) {
    return colombianCities.any(
      (c) => c.toLowerCase() == city.toLowerCase(),
    );
  }
}
