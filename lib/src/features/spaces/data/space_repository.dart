import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/src/features/spaces/domain/business_space_model.dart';

class SpaceRepository {
  final FirebaseFirestore _firestore;

  SpaceRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _spacesRef =>
      _firestore.collection('spaces');

  /// Crea un nuevo espacio (estado: pendiente hasta aprobación del admin)
  Future<String> createSpace(BusinessSpaceModel space) async {
    final docRef = _spacesRef.doc();
    await docRef.set({...space.toJson(), 'id': docRef.id});
    return docRef.id;
  }

  /// Actualiza datos de un espacio
  Future<void> updateSpace(String spaceId, Map<String, dynamic> fields) async {
    await _spacesRef.doc(spaceId).update(fields);
  }

  /// Stream del directorio público (solo aprobados), premium primero.
  /// Usa un solo orderBy para no requerir índice compuesto en Firestore.
  /// El ordenamiento premium-first se hace en el cliente.
  Stream<List<BusinessSpaceModel>> watchDirectory({
    String? ciudad,
    SpaceCategory? categoria,
  }) {
    Query<Map<String, dynamic>> query = _spacesRef
        .where('estado', isEqualTo: SpaceStatus.aprobado.name)
        .orderBy('fechaRegistro', descending: false)
        .limit(50);

    if (ciudad != null && ciudad.isNotEmpty) {
      query = query.where('ciudad', isEqualTo: ciudad);
    }
    if (categoria != null) {
      query = query.where('categoria', isEqualTo: categoria.name);
    }

    return query.snapshots().map((snap) {
      final spaces = snap.docs
          .map((doc) =>
              BusinessSpaceModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      // Ordenar: premium primero, luego por fecha de registro
      spaces.sort((a, b) {
        if (a.esPremium && !b.esPremium) return -1;
        if (!a.esPremium && b.esPremium) return 1;
        return a.fechaRegistro.compareTo(b.fechaRegistro);
      });
      return spaces;
    });
  }

  /// Stream de los espacios del negocio actual
  Stream<List<BusinessSpaceModel>> watchMySpaces(String negocioId) {
    return _spacesRef
        .where('negocioId', isEqualTo: negocioId)
        .orderBy('fechaRegistro', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                BusinessSpaceModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  /// Stream de un espacio individual
  Stream<BusinessSpaceModel?> watchSpace(String spaceId) {
    return _spacesRef.doc(spaceId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return BusinessSpaceModel.fromJson({...doc.data()!, 'id': doc.id});
    });
  }

  /// Obtiene un espacio por ID (una sola vez)
  Future<BusinessSpaceModel?> getSpace(String spaceId) async {
    final doc = await _spacesRef.doc(spaceId).get();
    if (!doc.exists) return null;
    return BusinessSpaceModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  // ─── Admin ───────────────────────────────────────────────────────

  /// Stream de todos los espacios para el admin
  Stream<List<BusinessSpaceModel>> watchAllSpaces({SpaceStatus? filtro}) {
    Query<Map<String, dynamic>> query =
        _spacesRef.orderBy('fechaRegistro', descending: true);
    if (filtro != null) {
      query = query.where('estado', isEqualTo: filtro.name);
    }
    return query.snapshots().map((snap) => snap.docs
        .map((doc) =>
            BusinessSpaceModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList());
  }

  /// Aprueba un espacio
  Future<void> approveSpace(String spaceId) async {
    await _spacesRef
        .doc(spaceId)
        .update({'estado': SpaceStatus.aprobado.name});
  }

  /// Rechaza un espacio
  Future<void> rejectSpace(String spaceId) async {
    await _spacesRef
        .doc(spaceId)
        .update({'estado': SpaceStatus.rechazado.name});
  }

  /// Suspende un espacio
  Future<void> suspendSpace(String spaceId) async {
    await _spacesRef
        .doc(spaceId)
        .update({'estado': SpaceStatus.suspendido.name});
  }

  /// Activa o desactiva plan premium (admin)
  Future<void> setPremium(String spaceId, bool premium) async {
    await _spacesRef.doc(spaceId).update({'esPremium': premium});
  }

  /// Incrementa contadores al crear un plan vinculado
  Future<void> incrementEventStats(
      String spaceId, int asistentesConfirmados) async {
    await _spacesRef.doc(spaceId).update({
      'totalEventos': FieldValue.increment(1),
      'totalAsistentes': FieldValue.increment(asistentesConfirmados),
    });
  }
}

final spaceRepositoryProvider = Provider<SpaceRepository>((ref) {
  return SpaceRepository(FirebaseFirestore.instance);
});

final spaceDirectoryProvider =
    StreamProvider.family<List<BusinessSpaceModel>, Map<String, dynamic>>(
        (ref, filters) {
  return ref.watch(spaceRepositoryProvider).watchDirectory(
        ciudad: filters['ciudad'] as String?,
        categoria: filters['categoria'] as SpaceCategory?,
      );
});

final mySpacesProvider =
    StreamProvider.family<List<BusinessSpaceModel>, String>((ref, negocioId) {
  return ref.watch(spaceRepositoryProvider).watchMySpaces(negocioId);
});

final spaceStreamProvider =
    StreamProvider.family<BusinessSpaceModel?, String>((ref, spaceId) {
  return ref.watch(spaceRepositoryProvider).watchSpace(spaceId);
});

final allSpacesAdminProvider =
    StreamProvider.family<List<BusinessSpaceModel>, SpaceStatus?>(
        (ref, filtro) {
  return ref.watch(spaceRepositoryProvider).watchAllSpaces(filtro: filtro);
});
