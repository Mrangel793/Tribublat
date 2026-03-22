class ChatMessageModel {
  final String id;
  final String planId;
  final String userId;
  final String userName;
  final String userPhoto;
  final String texto;
  final DateTime fechaCreacion;
  final bool fijado;
  final bool reportado;

  const ChatMessageModel({
    required this.id,
    required this.planId,
    required this.userId,
    required this.userName,
    required this.userPhoto,
    required this.texto,
    required this.fechaCreacion,
    this.fijado = false,
    this.reportado = false,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String? ?? '',
      planId: json['planId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? 'Usuario',
      userPhoto: json['userPhoto'] as String? ?? '',
      texto: json['texto'] as String? ?? '',
      fechaCreacion: DateTime.parse(
          json['fechaCreacion'] as String? ?? DateTime.now().toIso8601String()),
      fijado: json['fijado'] as bool? ?? false,
      reportado: json['reportado'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'planId': planId,
        'userId': userId,
        'userName': userName,
        'userPhoto': userPhoto,
        'texto': texto,
        'fechaCreacion': fechaCreacion.toIso8601String(),
        'fijado': fijado,
        'reportado': reportado,
      };

  ChatMessageModel copyWith({bool? fijado, bool? reportado}) {
    return ChatMessageModel(
      id: id,
      planId: planId,
      userId: userId,
      userName: userName,
      userPhoto: userPhoto,
      texto: texto,
      fechaCreacion: fechaCreacion,
      fijado: fijado ?? this.fijado,
      reportado: reportado ?? this.reportado,
    );
  }
}
