enum ReportType {
  spam,
  conductaInapropiada,
  perfilFalso,
  acoso,
  contenidoInapropiado,
  otro,
}

enum ReportStatus { nuevo, revisando, resuelto }

enum ReportAction { sinAccion, advertencia, bloqueoTemporal, expulsion }

class ReportModel {
  final String id;
  final String reporterId;
  final String reporterName;
  final String reportedUserId;
  final String reportedUserName;
  final ReportType tipo;
  final String descripcion;
  final ReportStatus estado;
  final DateTime fechaCreacion;
  final DateTime? fechaResolucion;
  final ReportAction? accionTomada;
  final String? notaAdmin;

  const ReportModel({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.reportedUserId,
    required this.reportedUserName,
    required this.tipo,
    required this.descripcion,
    required this.estado,
    required this.fechaCreacion,
    this.fechaResolucion,
    this.accionTomada,
    this.notaAdmin,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String? ?? '',
      reporterId: json['reporterId'] as String? ?? '',
      reporterName: json['reporterName'] as String? ?? '',
      reportedUserId: json['reportedUserId'] as String? ?? '',
      reportedUserName: json['reportedUserName'] as String? ?? '',
      tipo: ReportType.values.firstWhere(
        (e) => e.name == json['tipo'],
        orElse: () => ReportType.otro,
      ),
      descripcion: json['descripcion'] as String? ?? '',
      estado: ReportStatus.values.firstWhere(
        (e) => e.name == json['estado'],
        orElse: () => ReportStatus.nuevo,
      ),
      fechaCreacion: DateTime.parse(
          json['fechaCreacion'] as String? ?? DateTime.now().toIso8601String()),
      fechaResolucion: json['fechaResolucion'] != null
          ? DateTime.parse(json['fechaResolucion'] as String)
          : null,
      accionTomada: json['accionTomada'] != null
          ? ReportAction.values.firstWhere(
              (e) => e.name == json['accionTomada'],
              orElse: () => ReportAction.sinAccion,
            )
          : null,
      notaAdmin: json['notaAdmin'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reporterId': reporterId,
        'reporterName': reporterName,
        'reportedUserId': reportedUserId,
        'reportedUserName': reportedUserName,
        'tipo': tipo.name,
        'descripcion': descripcion,
        'estado': estado.name,
        'fechaCreacion': fechaCreacion.toIso8601String(),
        if (fechaResolucion != null)
          'fechaResolucion': fechaResolucion!.toIso8601String(),
        if (accionTomada != null) 'accionTomada': accionTomada!.name,
        if (notaAdmin != null) 'notaAdmin': notaAdmin,
      };

  static String labelForType(ReportType tipo) {
    switch (tipo) {
      case ReportType.spam:
        return 'Spam';
      case ReportType.conductaInapropiada:
        return 'Conducta inapropiada';
      case ReportType.perfilFalso:
        return 'Perfil falso';
      case ReportType.acoso:
        return 'Acoso';
      case ReportType.contenidoInapropiado:
        return 'Contenido inapropiado';
      case ReportType.otro:
        return 'Otro';
    }
  }

  static String labelForAction(ReportAction action) {
    switch (action) {
      case ReportAction.sinAccion:
        return 'Sin acción';
      case ReportAction.advertencia:
        return 'Advertencia enviada';
      case ReportAction.bloqueoTemporal:
        return 'Bloqueo temporal (7 días)';
      case ReportAction.expulsion:
        return 'Usuario expulsado';
    }
  }
}
