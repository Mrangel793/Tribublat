enum BusinessRequestStatus { pendiente, aprobada, rechazada }

enum BusinessType {
  bar,
  cafe,
  restaurante,
  espacioCultural,
  coworking,
  tienda,
  otro,
}

class BusinessRequestModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String nombreEmpresa;
  final String nit;
  final BusinessType tipoNegocio;
  final String telefono;
  final String descripcion;
  final BusinessRequestStatus estado;
  final DateTime fechaSolicitud;
  final DateTime? fechaResolucion;
  final String? notaAdmin;

  const BusinessRequestModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.nombreEmpresa,
    required this.nit,
    required this.tipoNegocio,
    required this.telefono,
    required this.descripcion,
    required this.estado,
    required this.fechaSolicitud,
    this.fechaResolucion,
    this.notaAdmin,
  });

  factory BusinessRequestModel.fromJson(Map<String, dynamic> json) {
    return BusinessRequestModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      userEmail: json['userEmail'] as String? ?? '',
      nombreEmpresa: json['nombreEmpresa'] as String? ?? '',
      nit: json['nit'] as String? ?? '',
      tipoNegocio: BusinessType.values.firstWhere(
        (e) => e.name == json['tipoNegocio'],
        orElse: () => BusinessType.otro,
      ),
      telefono: json['telefono'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      estado: BusinessRequestStatus.values.firstWhere(
        (e) => e.name == json['estado'],
        orElse: () => BusinessRequestStatus.pendiente,
      ),
      fechaSolicitud: DateTime.parse(
          json['fechaSolicitud'] as String? ??
              DateTime.now().toIso8601String()),
      fechaResolucion: json['fechaResolucion'] != null
          ? DateTime.parse(json['fechaResolucion'] as String)
          : null,
      notaAdmin: json['notaAdmin'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'nombreEmpresa': nombreEmpresa,
        'nit': nit,
        'tipoNegocio': tipoNegocio.name,
        'telefono': telefono,
        'descripcion': descripcion,
        'estado': estado.name,
        'fechaSolicitud': fechaSolicitud.toIso8601String(),
        if (fechaResolucion != null)
          'fechaResolucion': fechaResolucion!.toIso8601String(),
        if (notaAdmin != null) 'notaAdmin': notaAdmin,
      };

  static String labelForType(BusinessType tipo) {
    switch (tipo) {
      case BusinessType.bar:             return 'Bar / Discoteca';
      case BusinessType.cafe:            return 'Café / Panadería';
      case BusinessType.restaurante:     return 'Restaurante';
      case BusinessType.espacioCultural: return 'Espacio Cultural';
      case BusinessType.coworking:       return 'Coworking';
      case BusinessType.tienda:          return 'Tienda / Comercio';
      case BusinessType.otro:            return 'Otro';
    }
  }
}
