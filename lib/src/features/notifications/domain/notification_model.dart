enum NotificationType {
  asistenciaConfirmada,
  recordatorio,
  planCambiado,
  planCancelado,
  listaEspera,
}

class NotificationModel {
  final String id;
  final String userId;
  final NotificationType tipo;
  final String titulo;
  final String cuerpo;
  final String? planId;
  final String? planTitulo;
  final DateTime fechaCreacion;
  final bool leida;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.tipo,
    required this.titulo,
    required this.cuerpo,
    this.planId,
    this.planTitulo,
    required this.fechaCreacion,
    required this.leida,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      tipo: _tipoFromString(json['tipo'] as String? ?? ''),
      titulo: json['titulo'] as String? ?? '',
      cuerpo: json['cuerpo'] as String? ?? '',
      planId: json['planId'] as String?,
      planTitulo: json['planTitulo'] as String?,
      fechaCreacion: DateTime.parse(
          json['fechaCreacion'] as String? ?? DateTime.now().toIso8601String()),
      leida: json['leida'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'tipo': tipo.name,
        'titulo': titulo,
        'cuerpo': cuerpo,
        if (planId != null) 'planId': planId,
        if (planTitulo != null) 'planTitulo': planTitulo,
        'fechaCreacion': fechaCreacion.toIso8601String(),
        'leida': leida,
      };

  NotificationModel copyWith({bool? leida}) {
    return NotificationModel(
      id: id,
      userId: userId,
      tipo: tipo,
      titulo: titulo,
      cuerpo: cuerpo,
      planId: planId,
      planTitulo: planTitulo,
      fechaCreacion: fechaCreacion,
      leida: leida ?? this.leida,
    );
  }

  static NotificationType _tipoFromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationType.asistenciaConfirmada,
    );
  }
}
