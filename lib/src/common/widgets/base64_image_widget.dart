import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Caché global en memoria para evitar decodificar la misma imagen repetidamente.
/// Se limpia automáticamente cuando supera 50 entradas para no agotar RAM.
final _imageCache = <String, Uint8List>{};

Uint8List? _getCachedBytes(String base64String) {
  // Usar los primeros 64 chars como key (suficiente para identificar la imagen)
  final key = base64String.length > 64
      ? base64String.substring(0, 64)
      : base64String;

  if (_imageCache.containsKey(key)) return _imageCache[key];

  try {
    final bytes = base64Decode(base64String);
    if (_imageCache.length >= 50) _imageCache.clear(); // Limpiar si crece mucho
    _imageCache[key] = bytes;
    return bytes;
  } catch (_) {
    return null;
  }
}

/// Widget para mostrar imágenes guardadas como Base64 en Firestore
class Base64ImageWidget extends StatelessWidget {
  final String base64String;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const Base64ImageWidget({
    super.key,
    required this.base64String,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final bytes = _getCachedBytes(base64String);

    if (bytes == null) {
      return errorWidget ??
          Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Icon(Icons.error_outline, color: Colors.grey),
          );
    }

    return Image.memory(
      bytes,
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true, // Evita parpadeo al reconstruir
      errorBuilder: (_, __, ___) =>
          errorWidget ??
          Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
    );
  }
}

/// Widget circular para avatares con imágenes Base64
class Base64CircleAvatar extends StatelessWidget {
  final String base64String;
  final double radius;
  final Color? backgroundColor;

  const Base64CircleAvatar({
    super.key,
    required this.base64String,
    this.radius = 20,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final Uint8List bytes = base64Decode(base64String);

      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey[300],
        backgroundImage: MemoryImage(bytes),
        onBackgroundImageError: (exception, stackTrace) {
          // Error manejado por el child
        },
        child: null,
      );
    } catch (e) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey[300],
        child: Icon(
          Icons.person,
          size: radius,
          color: Colors.white,
        ),
      );
    }
  }
}
