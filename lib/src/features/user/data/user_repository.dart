import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/src/features/auth/data/database_repository.dart';
import 'package:myapp/src/features/user/data/storage_service.dart';
import 'package:myapp/src/features/user/domain/user_model.dart';

/// Repositorio que orquesta las operaciones relacionadas con el perfil de usuario
/// Combina DatabaseRepository (Firestore) y StorageService (Firebase Storage)
class UserRepository {
  final DatabaseRepository _databaseRepository;
  final StorageService _storageService;

  UserRepository(this._databaseRepository, this._storageService);

  /// Actualiza la información básica del perfil (Paso 1)
  /// - Sube la foto a Storage si se proporciona
  /// - Actualiza ciudad, edad y foto en Firestore
  Future<void> updateBasicInfo({
    required String userId,
    required String ciudad,
    required int edad,
    File? profilePhoto,
  }) async {
    try {
      String? photoUrl;

      // Subir foto si se proporcionó
      if (profilePhoto != null) {
        // Obtener foto anterior para eliminarla
        final currentUser = await _databaseRepository.getUserProfile(userId);
        final oldPhotoUrl = currentUser?.foto;

        // Subir nueva foto
        photoUrl = await _storageService.uploadProfilePhoto(
          profilePhoto,
          userId,
        );

        // Eliminar foto anterior si existe
        if (oldPhotoUrl != null && oldPhotoUrl.isNotEmpty) {
          await _storageService.deleteProfilePhoto(oldPhotoUrl);
        }
      }

      // Actualizar campos en Firestore
      final fields = <String, dynamic>{
        'ciudad': ciudad,
        'edad': edad,
        if (photoUrl != null) 'foto': photoUrl,
        'ultimaConexion': DateTime.now().toIso8601String(),
      };

      await _databaseRepository.updateUserFields(userId, fields);
    } catch (e) {
      throw UserRepositoryException(
        'Error al actualizar información básica: ${e.toString()}',
      );
    }
  }

  /// Actualiza los intereses del usuario (Paso 2)
  Future<void> updateInterests(String userId, List<String> interests) async {
    try {
      await _databaseRepository.updateUserField(userId, 'intereses', interests);
      await _databaseRepository.updateUserField(
        userId,
        'ultimaConexion',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw UserRepositoryException(
        'Error al actualizar intereses: ${e.toString()}',
      );
    }
  }

  /// Actualiza el nivel de energía del usuario (Paso 3)
  Future<void> updateEnergyLevel(
    String userId,
    EnergyLevel level,
  ) async {
    try {
      // Convertir enum a string
      final levelString = level.toString().split('.').last;

      await _databaseRepository.updateUserField(
        userId,
        'nivelEnergia',
        levelString,
      );
      await _databaseRepository.updateUserField(
        userId,
        'ultimaConexion',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw UserRepositoryException(
        'Error al actualizar nivel de energía: ${e.toString()}',
      );
    }
  }

  /// Obtiene el perfil completo del usuario
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      return await _databaseRepository.getUserProfile(userId);
    } catch (e) {
      throw UserRepositoryException(
        'Error al obtener perfil de usuario: ${e.toString()}',
      );
    }
  }

  /// Crea el perfil completo del usuario
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _databaseRepository.updateUserProfile(user);
    } catch (e) {
      throw UserRepositoryException(
        'Error al crear perfil de usuario: ${e.toString()}',
      );
    }
  }

  /// Stream del perfil completo del usuario
  Stream<UserModel?> userProfileStream(String userId) {
    return _databaseRepository.userModelStream(userId);
  }

  /// Verifica el estado de completitud del perfil
  Future<ProfileCompleteness> getProfileCompleteness(String userId) async {
    try {
      final user = await _databaseRepository.getUserProfile(userId);

      if (user == null) {
        return ProfileCompleteness.incomplete;
      }

      // Verificar paso 1 (obligatorio): ciudad, edad, foto
      final hasBasicInfo = user.ciudad.isNotEmpty &&
          user.edad >= 18 &&
          user.foto.isNotEmpty;

      if (!hasBasicInfo) {
        return ProfileCompleteness.incomplete;
      }

      // Verificar paso 2 (opcional): intereses
      final hasInterests = user.intereses.length >= 3;

      // Verificar paso 3 (opcional): nivel de energía
      // Asumimos que "media" es el default, así que si es diferente significa que fue seleccionado
      final hasEnergyLevel = true; // Siempre tiene un valor

      if (hasBasicInfo && hasInterests && hasEnergyLevel) {
        return ProfileCompleteness.complete;
      } else if (hasBasicInfo && hasInterests) {
        return ProfileCompleteness.withInterests;
      } else if (hasBasicInfo) {
        return ProfileCompleteness.basicOnly;
      }

      return ProfileCompleteness.incomplete;
    } catch (e) {
      print('Error al obtener completitud del perfil: $e');
      return ProfileCompleteness.incomplete;
    }
  }

  /// Verifica si el perfil está completo (al menos paso 1)
  Future<bool> isProfileComplete(String userId) async {
    return await _databaseRepository.isProfileComplete(userId);
  }

  /// Sube fotos adicionales al perfil
  Future<List<String>> uploadAdditionalPhotos(
    String userId,
    List<File> photos,
  ) async {
    try {
      final urls = await _storageService.uploadAdditionalPhotos(photos, userId);

      // Obtener fotos actuales
      final user = await _databaseRepository.getUserProfile(userId);
      final currentPhotos = user?.fotosAdicionales ?? [];

      // Agregar nuevas URLs
      final updatedPhotos = [...currentPhotos, ...urls];

      // Actualizar en Firestore
      await _databaseRepository.updateUserField(
        userId,
        'fotosAdicionales',
        updatedPhotos,
      );

      return urls;
    } catch (e) {
      throw UserRepositoryException(
        'Error al subir fotos adicionales: ${e.toString()}',
      );
    }
  }
}

/// Enum que representa el estado de completitud del perfil
enum ProfileCompleteness {
  /// Paso 1 no completado
  incomplete,

  /// Solo paso 1 completado
  basicOnly,

  /// Pasos 1 y 2 completados
  withInterests,

  /// Todos los pasos completados
  complete,
}

/// Excepción personalizada para errores del UserRepository
class UserRepositoryException implements Exception {
  final String message;

  UserRepositoryException(this.message);

  @override
  String toString() => message;
}

/// Provider del UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(
    ref.watch(databaseRepositoryProvider),
    ref.watch(storageServiceProvider),
  );
});
