class ReviewModel {
  final String id;
  final String planId;
  final String userId;
  final String userName;
  final String userPhoto;
  final int rating; // 1–5
  final String comentario;
  final DateTime fechaCreacion;

  const ReviewModel({
    required this.id,
    required this.planId,
    required this.userId,
    required this.userName,
    required this.userPhoto,
    required this.rating,
    required this.comentario,
    required this.fechaCreacion,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String? ?? '',
      planId: json['planId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? 'Usuario',
      userPhoto: json['userPhoto'] as String? ?? '',
      rating: json['rating'] as int? ?? 5,
      comentario: json['comentario'] as String? ?? '',
      fechaCreacion: DateTime.parse(
          json['fechaCreacion'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'planId': planId,
        'userId': userId,
        'userName': userName,
        'userPhoto': userPhoto,
        'rating': rating,
        'comentario': comentario,
        'fechaCreacion': fechaCreacion.toIso8601String(),
      };
}
