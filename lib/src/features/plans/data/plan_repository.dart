import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/src/features/plans/domain/models/plan_model.dart';
import 'package:myapp/src/features/plans/domain/plan_constants.dart';
import 'package:myapp/src/features/user/domain/user_model.dart';

/// Excepción para errores del repositorio de planes
class PlanRepositoryException implements Exception {
  final String message;
  PlanRepositoryException(this.message);

  @override
  String toString() => message;
}

/// Repositorio para operaciones CRUD de planes en Firestore
class PlanRepository {
  final FirebaseFirestore _firestore;

  PlanRepository(this._firestore);

  /// Referencia a la colección de planes
  CollectionReference<Map<String, dynamic>> get _plansRef =>
      _firestore.collection('plans');

  // ============ OPERACIONES DE LECTURA ============

  /// Stream de planes activos para el feed
  Stream<List<PlanModel>> watchActivePlans({
    String? ciudad,
    int limit = 20,
  }) {
    Query<Map<String, dynamic>> query = _plansRef
        .where('estado', isEqualTo: PlanStatus.activo.name)
        .where('fechaHora', isGreaterThanOrEqualTo: DateTime.now().toIso8601String())
        .orderBy('fechaHora')
        .limit(limit);

    if (ciudad != null && ciudad.isNotEmpty) {
      query = query.where('ciudad', isEqualTo: ciudad);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => PlanModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  /// Stream de planes de hoy
  Stream<List<PlanModel>> watchTodayPlans({String? ciudad}) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    Query<Map<String, dynamic>> query = _plansRef
        .where('estado', isEqualTo: PlanStatus.activo.name)
        .where('fechaHora', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('fechaHora', isLessThan: endOfDay.toIso8601String())
        .orderBy('fechaHora');

    if (ciudad != null && ciudad.isNotEmpty) {
      query = query.where('ciudad', isEqualTo: ciudad);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => PlanModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  /// Stream de planes instantáneos (inician en menos de 2 horas)
  Stream<List<PlanModel>> watchInstantPlans({String? ciudad}) {
    final now = DateTime.now();
    final twoHoursLater = now.add(const Duration(hours: 2));

    Query<Map<String, dynamic>> query = _plansRef
        .where('estado', isEqualTo: PlanStatus.activo.name)
        .where('fechaHora', isGreaterThanOrEqualTo: now.toIso8601String())
        .where('fechaHora', isLessThanOrEqualTo: twoHoursLater.toIso8601String())
        .orderBy('fechaHora');

    if (ciudad != null && ciudad.isNotEmpty) {
      query = query.where('ciudad', isEqualTo: ciudad);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => PlanModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  /// Stream de planes del usuario (donde participa)
  Stream<List<PlanModel>> watchUserPlans(String userId) {
    return _plansRef
        .where('participantesIds', arrayContains: userId)
        .orderBy('fechaHora')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PlanModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  /// Obtener planes personalizados basados en intereses del usuario
  Future<List<PlanModel>> getPersonalizedPlans({
    required List<String> userInterests,
    required EnergyLevel userEnergyLevel,
    String? ciudad,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> query = _plansRef
        .where('estado', isEqualTo: PlanStatus.activo.name)
        .where('fechaHora', isGreaterThanOrEqualTo: DateTime.now().toIso8601String())
        .orderBy('fechaHora')
        .limit(limit * 2); // Obtener más para filtrar

    if (ciudad != null && ciudad.isNotEmpty) {
      query = query.where('ciudad', isEqualTo: ciudad);
    }

    final snapshot = await query.get();
    final plans = snapshot.docs
        .map((doc) => PlanModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();

    // Calcular puntuaciones de match y ordenar
    final scoredPlans = plans.map((plan) {
      final score = calculateMatchScore(plan, userInterests, userEnergyLevel);
      return MapEntry(plan, score);
    }).toList();

    scoredPlans.sort((a, b) => b.value.compareTo(a.value));

    return scoredPlans.take(limit).map((e) => e.key).toList();
  }

  /// Calcular porcentaje de match entre usuario y plan
  double calculateMatchScore(
    PlanModel plan,
    List<String> userInterests,
    EnergyLevel userEnergyLevel,
  ) {
    double score = 0.0;

    // Coincidencia de intereses (60% peso)
    final matchingInterests = plan.interesesRelacionados
        .where((i) => userInterests.contains(i))
        .length;
    if (plan.interesesRelacionados.isNotEmpty) {
      score += (matchingInterests / plan.interesesRelacionados.length) * 60;
    } else if (userInterests.contains(plan.categoria.name)) {
      score += 40; // Si la categoría coincide con un interés
    }

    // Coincidencia de nivel de energía (30% peso)
    if (plan.nivelEnergia == userEnergyLevel) {
      score += 30;
    } else if ((plan.nivelEnergia.index - userEnergyLevel.index).abs() == 1) {
      score += 15; // Nivel adyacente obtiene puntaje parcial
    }

    // Bonus por disponibilidad (10% peso)
    if (plan.tieneDisponibilidad) {
      score += 10;
    }

    return score;
  }

  /// Obtener un plan por ID
  Future<PlanModel?> getPlanById(String planId) async {
    final doc = await _plansRef.doc(planId).get();
    if (!doc.exists) return null;
    return PlanModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  /// Stream de un plan específico
  Stream<PlanModel?> watchPlan(String planId) {
    return _plansRef.doc(planId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return PlanModel.fromJson({...doc.data()!, 'id': doc.id});
    });
  }

  // ============ OPERACIONES DE ESCRITURA ============

  /// Unirse a un plan
  Future<void> joinPlan(String planId, String userId) async {
    await _firestore.runTransaction((transaction) async {
      final planDoc = await transaction.get(_plansRef.doc(planId));

      if (!planDoc.exists) {
        throw PlanRepositoryException('El plan no existe');
      }

      final planData = planDoc.data()!;
      final participantes = List<String>.from(planData['participantesIds'] ?? []);
      final listaEspera = List<String>.from(planData['listaEsperaIds'] ?? []);
      final capacidadActual = planData['capacidadActual'] as int? ?? 0;
      final capacidadMaxima = planData['capacidadMaxima'] as int? ?? 0;

      if (participantes.contains(userId)) {
        throw PlanRepositoryException('Ya estas en este plan');
      }

      if (listaEspera.contains(userId)) {
        throw PlanRepositoryException('Ya estas en la lista de espera');
      }

      if (capacidadActual >= capacidadMaxima) {
        // Agregar a lista de espera
        transaction.update(_plansRef.doc(planId), {
          'listaEsperaIds': FieldValue.arrayUnion([userId]),
        });
        throw PlanRepositoryException('Plan lleno. Te agregamos a la lista de espera.');
      }

      // Agregar como participante
      transaction.update(_plansRef.doc(planId), {
        'participantesIds': FieldValue.arrayUnion([userId]),
        'capacidadActual': FieldValue.increment(1),
      });
    });
  }

  /// Salir de un plan
  Future<void> leavePlan(String planId, String userId) async {
    await _firestore.runTransaction((transaction) async {
      final planDoc = await transaction.get(_plansRef.doc(planId));

      if (!planDoc.exists) {
        throw PlanRepositoryException('El plan no existe');
      }

      final planData = planDoc.data()!;
      final participantes = List<String>.from(planData['participantesIds'] ?? []);
      final listaEspera = List<String>.from(planData['listaEsperaIds'] ?? []);

      if (!participantes.contains(userId)) {
        // Verificar si está en lista de espera
        if (listaEspera.contains(userId)) {
          transaction.update(_plansRef.doc(planId), {
            'listaEsperaIds': FieldValue.arrayRemove([userId]),
          });
          return;
        }
        throw PlanRepositoryException('No estas en este plan');
      }

      // Remover participante
      transaction.update(_plansRef.doc(planId), {
        'participantesIds': FieldValue.arrayRemove([userId]),
        'capacidadActual': FieldValue.increment(-1),
      });

      // Promover al primero de la lista de espera si existe
      if (listaEspera.isNotEmpty) {
        final nextUser = listaEspera.first;
        transaction.update(_plansRef.doc(planId), {
          'listaEsperaIds': FieldValue.arrayRemove([nextUser]),
          'participantesIds': FieldValue.arrayUnion([nextUser]),
          'capacidadActual': FieldValue.increment(1),
        });
      }
    });
  }

  /// Crear un nuevo plan
  Future<String> createPlan(PlanModel plan) async {
    final docRef = _plansRef.doc();
    final planWithId = plan.copyWith(id: docRef.id);
    await docRef.set(planWithId.toJson());
    return docRef.id;
  }

  /// Actualizar un plan
  Future<void> updatePlan(String planId, Map<String, dynamic> updates) async {
    await _plansRef.doc(planId).update(updates);
  }

  /// Eliminar un plan
  Future<void> deletePlan(String planId) async {
    await _plansRef.doc(planId).delete();
  }

  /// Buscar planes por título
  Future<List<PlanModel>> searchPlans(String query, {int limit = 20}) async {
    // Nota: Firestore no soporta búsqueda full-text nativamente
    // Para producción, considerar Algolia o similar
    final queryLower = query.toLowerCase();

    final snapshot = await _plansRef
        .where('estado', isEqualTo: PlanStatus.activo.name)
        .orderBy('titulo')
        .limit(limit * 3)
        .get();

    final plans = snapshot.docs
        .map((doc) => PlanModel.fromJson({...doc.data(), 'id': doc.id}))
        .where((plan) => plan.titulo.toLowerCase().contains(queryLower))
        .take(limit)
        .toList();

    return plans;
  }
}

/// Provider del repositorio de planes
final planRepositoryProvider = Provider<PlanRepository>((ref) {
  return PlanRepository(FirebaseFirestore.instance);
});
