enum SpaceCategory {
  bar,
  cafe,
  restaurante,
  espacioCultural,
  coworking,
  parque,
  otro,
}

enum SpaceStatus { pendiente, aprobado, rechazado, suspendido }

class DisponibilidadFranja {
  final int diaSemana; // 0=Dom, 1=Lun, ..., 6=Sab
  final String horaInicio; // "HH:mm"
  final String horaFin;

  const DisponibilidadFranja({
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
  });

  factory DisponibilidadFranja.fromJson(Map<String, dynamic> json) =>
      DisponibilidadFranja(
        diaSemana: json['diaSemana'] as int? ?? 0,
        horaInicio: json['horaInicio'] as String? ?? '08:00',
        horaFin: json['horaFin'] as String? ?? '22:00',
      );

  Map<String, dynamic> toJson() => {
        'diaSemana': diaSemana,
        'horaInicio': horaInicio,
        'horaFin': horaFin,
      };

  static const diasNombres = [
    'Domingo', 'Lunes', 'Martes', 'Miércoles',
    'Jueves', 'Viernes', 'Sábado'
  ];

  String get diaLabel => diasNombres[diaSemana];
}

class BusinessSpaceModel {
  final String id;
  final String negocioId;
  final String negocioNombre;
  final String nombre;
  final String descripcion;
  final SpaceCategory categoria;
  final String direccion;
  final String ciudad;
  final double latitud;
  final double longitud;
  final List<String> fotos; // base64, hasta 10
  final String telefono;
  final String web;
  final List<DisponibilidadFranja> disponibilidad;
  final bool esPremium;
  final SpaceStatus estado;
  final DateTime fechaRegistro;
  final int totalEventos;
  final int totalAsistentes;
  final double puntuacionPromedio;
  final int totalResenas;

  const BusinessSpaceModel({
    required this.id,
    required this.negocioId,
    required this.negocioNombre,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.direccion,
    required this.ciudad,
    this.latitud = 0.0,
    this.longitud = 0.0,
    this.fotos = const [],
    this.telefono = '',
    this.web = '',
    this.disponibilidad = const [],
    this.esPremium = false,
    this.estado = SpaceStatus.pendiente,
    required this.fechaRegistro,
    this.totalEventos = 0,
    this.totalAsistentes = 0,
    this.puntuacionPromedio = 0.0,
    this.totalResenas = 0,
  });

  factory BusinessSpaceModel.fromJson(Map<String, dynamic> json) {
    return BusinessSpaceModel(
      id: json['id'] as String? ?? '',
      negocioId: json['negocioId'] as String? ?? '',
      negocioNombre: json['negocioNombre'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      categoria: SpaceCategory.values.firstWhere(
        (e) => e.name == json['categoria'],
        orElse: () => SpaceCategory.otro,
      ),
      direccion: json['direccion'] as String? ?? '',
      ciudad: json['ciudad'] as String? ?? '',
      latitud: (json['latitud'] as num?)?.toDouble() ?? 0.0,
      longitud: (json['longitud'] as num?)?.toDouble() ?? 0.0,
      fotos: List<String>.from(json['fotos'] ?? []),
      telefono: json['telefono'] as String? ?? '',
      web: json['web'] as String? ?? '',
      disponibilidad: (json['disponibilidad'] as List<dynamic>? ?? [])
          .map((e) => DisponibilidadFranja.fromJson(e as Map<String, dynamic>))
          .toList(),
      esPremium: json['esPremium'] as bool? ?? false,
      estado: SpaceStatus.values.firstWhere(
        (e) => e.name == json['estado'],
        orElse: () => SpaceStatus.pendiente,
      ),
      fechaRegistro: DateTime.parse(
          json['fechaRegistro'] as String? ?? DateTime.now().toIso8601String()),
      totalEventos: json['totalEventos'] as int? ?? 0,
      totalAsistentes: json['totalAsistentes'] as int? ?? 0,
      puntuacionPromedio:
          (json['puntuacionPromedio'] as num?)?.toDouble() ?? 0.0,
      totalResenas: json['totalResenas'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'negocioId': negocioId,
        'negocioNombre': negocioNombre,
        'nombre': nombre,
        'descripcion': descripcion,
        'categoria': categoria.name,
        'direccion': direccion,
        'ciudad': ciudad,
        'latitud': latitud,
        'longitud': longitud,
        'fotos': fotos,
        'telefono': telefono,
        'web': web,
        'disponibilidad': disponibilidad.map((d) => d.toJson()).toList(),
        'esPremium': esPremium,
        'estado': estado.name,
        'fechaRegistro': fechaRegistro.toIso8601String(),
        'totalEventos': totalEventos,
        'totalAsistentes': totalAsistentes,
        'puntuacionPromedio': puntuacionPromedio,
        'totalResenas': totalResenas,
      };

  static String labelForCategory(SpaceCategory cat) {
    switch (cat) {
      case SpaceCategory.bar:         return 'Bar';
      case SpaceCategory.cafe:        return 'Café';
      case SpaceCategory.restaurante: return 'Restaurante';
      case SpaceCategory.espacioCultural: return 'Espacio Cultural';
      case SpaceCategory.coworking:   return 'Coworking';
      case SpaceCategory.parque:      return 'Parque / Aire libre';
      case SpaceCategory.otro:        return 'Otro';
    }
  }

  bool get estaAprobado => estado == SpaceStatus.aprobado;
  bool get tieneDisponibilidad => disponibilidad.isNotEmpty;
  String get fotoPortada => fotos.isNotEmpty ? fotos.first : '';
}
