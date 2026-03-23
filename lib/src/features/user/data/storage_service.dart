import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/src/features/user/data/cloudinary_service.dart';

/// Servicio de imágenes:
/// - Si Cloudinary está configurado → sube a CDN y retorna URL
/// - Si no → comprime a Base64 (comportamiento anterior)
class StorageService {
  final CloudinaryService _cloudinary;

  StorageService(this._cloudinary);

  /// Sube foto de perfil. Retorna URL de Cloudinary o Base64 (fallback).
  Future<String> uploadProfilePhoto(File imageFile, String userId) async {
    try {
      if (CloudinaryService.isConfigured) {
        // ── Cloudinary CDN ──
        final compressedBytes = await _compressToBytes(imageFile, quality: 80);
        return await _cloudinary.uploadBytes(
          compressedBytes,
          folder: 'tribulat/profiles',
        );
      } else {
        // ── Base64 fallback ──
        return await _toBase64(imageFile);
      }
    } catch (e) {
      throw StorageException('Error al subir foto de perfil: $e');
    }
  }

  Future<void> deleteProfilePhoto(String imageRef) async {
    // Cloudinary: la eliminación se hace desde el dashboard o via API admin
    // Base64: se elimina actualizando el campo en Firestore
  }

  /// Sube fotos adicionales. Retorna lista de URLs o Base64.
  Future<List<String>> uploadAdditionalPhotos(
    List<File> images,
    String userId,
  ) async {
    final results = <String>[];

    for (final image in images) {
      try {
        if (CloudinaryService.isConfigured) {
          final bytes = await _compressToBytes(image, quality: 75);
          final url = await _cloudinary.uploadBytes(
            bytes,
            folder: 'tribulat/profiles/gallery',
          );
          results.add(url);
        } else {
          final base64 = await _toBase64(image);
          results.add(base64);
        }
      } catch (e) {
        debugPrint('Error al subir foto: $e');
      }
    }

    return results;
  }

  /// Comprime imagen a bytes
  Future<Uint8List> _compressToBytes(File file,
      {int quality = 75, int maxSize = 1024}) async {
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: quality,
      minWidth: maxSize,
      minHeight: maxSize,
      format: CompressFormat.jpeg,
    );
    if (result == null || result.isEmpty) {
      throw StorageException('No se pudo comprimir la imagen');
    }
    return result;
  }

  /// Fallback Base64 (cuando Cloudinary no está configurado)
  Future<String> _toBase64(File imageFile) async {
    final compressedBytes =
        await _compressToBytes(imageFile, quality: 65, maxSize: 512);
    final estimatedSize = (compressedBytes.length * 1.37).toInt();
    if (estimatedSize > 300000) {
      throw StorageException(
          'La imagen es demasiado grande. Tamaño: ${(estimatedSize / 1024).toStringAsFixed(1)}KB');
    }
    return base64Encode(compressedBytes);
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
  return StorageService(ref.watch(cloudinaryServiceProvider));
});
