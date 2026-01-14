import 'dart:io';
import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Servicio para manejar la conversión de imágenes a Base64 para Firestore
/// NOTA: Las imágenes se comprimen agresivamente para no exceder el límite de Firestore (1MB)
class StorageService {
  StorageService();

  /// Convierte una foto de perfil a Base64 para guardar en Firestore
  /// Comprime agresivamente la imagen (max ~200KB, 512x512px)
  /// Returns: String Base64 de la imagen
  Future<String> uploadProfilePhoto(File imageFile, String userId) async {
    try {
      // Comprimir imagen agresivamente
      final compressedBytes = await _compressImageToBytes(imageFile);

      // Validar tamaño (máximo ~300KB en Base64)
      final estimatedSize = (compressedBytes.length * 1.37).toInt(); // Base64 aumenta ~37%
      if (estimatedSize > 300000) {
        throw StorageException(
          'La imagen es demasiado grande después de comprimir. Tamaño: ${(estimatedSize / 1024).toStringAsFixed(1)}KB',
        );
      }

      // Convertir a Base64
      final base64String = base64Encode(compressedBytes);

      return base64String;
    } catch (e) {
      throw StorageException(
        'Error al procesar la foto de perfil: ${e.toString()}',
      );
    }
  }

  /// Elimina una foto de perfil (Base64 se elimina actualizando Firestore)
  /// Este método ya no hace nada porque las imágenes Base64 se eliminan
  /// directamente actualizando el documento en Firestore
  Future<void> deleteProfilePhoto(String base64Image) async {
    // No se requiere ninguna acción aquí
    // La eliminación se maneja actualizando el campo en Firestore
  }

  /// Convierte múltiples fotos adicionales a Base64
  /// Returns: Lista de strings Base64
  Future<List<String>> uploadAdditionalPhotos(
    List<File> images,
    String userId,
  ) async {
    final base64Images = <String>[];

    for (final image in images) {
      try {
        // Comprimir imagen
        final compressedBytes = await _compressImageToBytes(image);

        // Validar tamaño
        final estimatedSize = (compressedBytes.length * 1.37).toInt();
        if (estimatedSize > 300000) {
          print('Warning: Imagen adicional demasiado grande, omitiendo...');
          continue;
        }

        // Convertir a Base64
        final base64String = base64Encode(compressedBytes);
        base64Images.add(base64String);
      } catch (e) {
        print('Error al procesar foto adicional: ${e.toString()}');
        // Continuar con las demás fotos
      }
    }

    return base64Images;
  }

  /// Comprime una imagen agresivamente a bytes
  /// Target: ~150-200KB, dimensiones 512x512px, quality 65
  /// Para que en Base64 no exceda ~300KB
  Future<List<int>> _compressImageToBytes(File imageFile) async {
    try {
      final result = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        quality: 65,
        minWidth: 512,
        minHeight: 512,
        format: CompressFormat.jpeg,
      );

      if (result == null || result.isEmpty) {
        throw StorageException('No se pudo comprimir la imagen');
      }

      // Si aún es muy grande, comprimir más
      if (result.length > 220000) {
        final secondPass = await FlutterImageCompress.compressWithFile(
          imageFile.absolute.path,
          quality: 50,
          minWidth: 512,
          minHeight: 512,
          format: CompressFormat.jpeg,
        );

        if (secondPass != null && secondPass.isNotEmpty) {
          return secondPass;
        }
      }

      return result;
    } catch (e) {
      throw StorageException('Error al comprimir la imagen: ${e.toString()}');
    }
  }
}

/// Excepción personalizada para errores de Storage
class StorageException implements Exception {
  final String message;

  StorageException(this.message);

  @override
  String toString() => message;
}

/// Provider del StorageService
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});
