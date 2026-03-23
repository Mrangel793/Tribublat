import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Servicio de almacenamiento de imágenes con Cloudinary CDN.
///
/// CONFIGURACIÓN:
/// 1. Crea cuenta gratis en https://cloudinary.com
/// 2. En el dashboard copia tu "Cloud name"
/// 3. Ve a Settings → Upload → Add upload preset
///    - Mode: Unsigned
///    - Folder: tribulat (opcional)
///    - Copia el "Preset name"
/// 4. Reemplaza los valores abajo
class CloudinaryService {
  // ⚠️ REEMPLAZAR con tus valores de Cloudinary
  static const String _cloudName = 'REEMPLAZAR_CON_TU_CLOUD_NAME';
  static const String _uploadPreset = 'REEMPLAZAR_CON_TU_UPLOAD_PRESET';

  static const String _uploadUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  static bool get isConfigured =>
      _cloudName != 'REEMPLAZAR_CON_TU_CLOUD_NAME' &&
      _uploadPreset != 'REEMPLAZAR_CON_TU_UPLOAD_PRESET';

  /// Sube una imagen desde File y retorna la URL de Cloudinary
  Future<String> uploadFile(File file, {String? folder}) async {
    if (!isConfigured) {
      throw Exception(
          'Cloudinary no configurado. Agrega Cloud Name y Upload Preset.');
    }

    final bytes = await file.readAsBytes();
    return _upload(bytes, folder: folder);
  }

  /// Sube una imagen desde bytes y retorna la URL de Cloudinary
  Future<String> uploadBytes(Uint8List bytes, {String? folder}) async {
    if (!isConfigured) {
      throw Exception('Cloudinary no configurado.');
    }
    return _upload(bytes, folder: folder);
  }

  Future<String> _upload(Uint8List bytes, {String? folder}) async {
    final request =
        http.MultipartRequest('POST', Uri.parse(_uploadUrl));

    request.fields['upload_preset'] = _uploadPreset;
    if (folder != null) request.fields['folder'] = folder;

    // Transformaciones automáticas de Cloudinary
    // q_auto: calidad automática | f_auto: formato automático (webp si el browser soporta)
    request.fields['transformation'] = 'q_auto,f_auto';

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
    ));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      debugPrint('Cloudinary error: $responseBody');
      throw Exception('Error subiendo imagen a Cloudinary');
    }

    final json = jsonDecode(responseBody) as Map<String, dynamic>;

    // Retornar URL con transformaciones para optimización automática
    // secure_url ya incluye https y la ruta del CDN
    return json['secure_url'] as String;
  }

  /// Genera una URL con transformaciones específicas
  /// Útil para thumbnails vs imagen completa
  static String getThumbnailUrl(String originalUrl,
      {int width = 400, int height = 300}) {
    if (!originalUrl.contains('cloudinary.com')) return originalUrl;

    // Insertar transformación en la URL de Cloudinary
    return originalUrl.replaceFirst(
      '/upload/',
      '/upload/c_fill,w_$width,h_$height,q_auto,f_auto/',
    );
  }

  /// Genera URL de avatar (cuadrada)
  static String getAvatarUrl(String originalUrl, {int size = 200}) {
    if (!originalUrl.contains('cloudinary.com')) return originalUrl;

    return originalUrl.replaceFirst(
      '/upload/',
      '/upload/c_fill,w_$size,h_$size,g_face,q_auto,f_auto/',
    );
  }
}

final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  return CloudinaryService();
});
