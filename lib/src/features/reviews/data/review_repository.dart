import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/src/features/reviews/domain/review_model.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore;

  ReviewRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> _reviewsRef(String planId) =>
      _firestore.collection('plans').doc(planId).collection('reviews');

  /// Crea una reseña y actualiza el promedio del plan y la reputación del organizador
  Future<void> createReview(ReviewModel review) async {
    // Verificar que el usuario no haya reseñado ya este plan
    final existing = await _reviewsRef(review.planId)
        .where('userId', isEqualTo: review.userId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw ReviewException('Ya reseñaste este plan anteriormente');
    }

    await _firestore.runTransaction((transaction) async {
      // Guardar la reseña
      final docRef = _reviewsRef(review.planId).doc();
      transaction.set(docRef, {...review.toJson(), 'id': docRef.id});

      // Actualizar puntuaciónPromedio en el plan
      final planRef = _firestore.collection('plans').doc(review.planId);
      final planSnap = await transaction.get(planRef);
      if (planSnap.exists) {
        final data = planSnap.data()!;
        final currentAvg = (data['puntuacionPromedio'] as num?)?.toDouble() ?? 0.0;
        final currentCount = (data['totalResenas'] as int?) ?? 0;
        final newCount = currentCount + 1;
        final newAvg = ((currentAvg * currentCount) + review.rating) / newCount;

        transaction.update(planRef, {
          'puntuacionPromedio': double.parse(newAvg.toStringAsFixed(1)),
          'totalResenas': newCount,
        });

        // Actualizar reputación del organizador
        final organizadorId = data['organizadorId'] as String?;
        if (organizadorId != null) {
          final userRef = _firestore.collection('users').doc(organizadorId);
          final userSnap = await transaction.get(userRef);
          if (userSnap.exists) {
            final userData = userSnap.data()!;
            final userCurrentRep =
                (userData['reputacion'] as num?)?.toDouble() ?? 0.0;
            final userCurrentCount =
                (userData['totalResenas'] as int?) ?? 0;
            final userNewCount = userCurrentCount + 1;
            final userNewRep =
                ((userCurrentRep * userCurrentCount) + review.rating) /
                    userNewCount;

            transaction.update(userRef, {
              'reputacion': double.parse(userNewRep.toStringAsFixed(1)),
              'totalResenas': userNewCount,
            });
          }
        }
      }
    });
  }

  /// Stream de reseñas del plan, más recientes primero
  Stream<List<ReviewModel>> watchReviews(String planId) {
    return _reviewsRef(planId)
        .orderBy('fechaCreacion', descending: true)
        .limit(20)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ReviewModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  /// Verifica si el usuario ya reseñó este plan
  Future<bool> hasUserReviewed(String planId, String userId) async {
    final snap = await _reviewsRef(planId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }
}

class ReviewException implements Exception {
  final String message;
  ReviewException(this.message);

  @override
  String toString() => message;
}

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(FirebaseFirestore.instance);
});

final planReviewsProvider =
    StreamProvider.family<List<ReviewModel>, String>((ref, planId) {
  return ref.watch(reviewRepositoryProvider).watchReviews(planId);
});
