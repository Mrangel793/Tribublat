import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/features/auth/domain/app_user.dart';
import 'package:myapp/src/features/user/domain/user_model.dart';

class DatabaseRepository {
  final FirebaseFirestore _firestore;

  DatabaseRepository(this._firestore);

  Future<void> createUser(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  /// Crea el documento base del usuario inmediatamente despues del registro
  /// Esto asegura que el usuario siempre tenga un documento en Firestore
  Future<void> createBaseUserProfile({
    required String uid,
    required String email,
    required String nombre,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'id': uid,
      'email': email,
      'nombre': nombre,
      'edad': 0,
      'ciudad': '',
      'foto': '',
      'intereses': <String>[],
      'nivelEnergia': 'media',
      'rol': 'usuario',
      'fechaCreacion': DateTime.now().toIso8601String(),
      'ultimaConexion': DateTime.now().toIso8601String(),
      'verificado': false,
      'reputacion': 5.0,
      'fotosAdicionales': <String>[],
    }, SetOptions(merge: true));
  }

  Stream<AppUser?> userStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return AppUser.fromDocument(snapshot);
      }
      return null;
    });
  }

  // ========== Métodos para UserModel (perfil completo) ==========

  /// Actualiza el perfil completo del usuario
  /// Usa merge: true para no sobrescribir los datos de AppUser
  Future<void> updateUserProfile(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.id)
        .set(user.toJson(), SetOptions(merge: true));
  }

  /// Obtiene el perfil completo del usuario
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      return null;
    }

    try {
      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      // Si falla la deserialización, puede ser porque el perfil no está completo
      print('Error al deserializar UserModel: $e');
      return null;
    }
  }

  /// Stream del perfil completo del usuario
  Stream<UserModel?> userModelStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      try {
        return UserModel.fromJson(snapshot.data()!);
      } catch (e) {
        print('Error al deserializar UserModel en stream: $e');
        return null;
      }
    });
  }

  /// Verifica si el perfil del usuario está completo
  /// Un perfil está completo si tiene ciudad, edad >= 18 y foto
  Future<bool> isProfileComplete(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        return false;
      }

      final data = doc.data();
      if (data == null) {
        return false;
      }

      // Verificar campos obligatorios del paso 1
      final ciudad = data['ciudad'] as String?;
      final edad = data['edad'] as int?;
      final foto = data['foto'] as String?;

      if (ciudad == null || ciudad.isEmpty) {
        return false;
      }

      if (edad == null || edad < 18) {
        return false;
      }

      if (foto == null || foto.isEmpty) {
        return false;
      }

      return true;
    } catch (e) {
      print('Error al verificar completitud del perfil: $e');
      return false;
    }
  }

  /// Actualiza campos específicos del perfil
  Future<void> updateUserField(String uid, String field, dynamic value) async {
    await _firestore.collection('users').doc(uid).update({field: value});
  }

  /// Actualiza múltiples campos del perfil
  Future<void> updateUserFields(String uid, Map<String, dynamic> fields) async {
    await _firestore.collection('users').doc(uid).update(fields);
  }
}

final databaseRepositoryProvider = Provider<DatabaseRepository>((ref) {
  return DatabaseRepository(FirebaseFirestore.instance);
});

final userProvider = StreamProvider.autoDispose.family<AppUser?, String>((ref, uid) {
  final databaseRepository = ref.watch(databaseRepositoryProvider);
  return databaseRepository.userStream(uid);
});
