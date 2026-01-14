import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

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
    try {
      // Decodificar Base64 a bytes
      final Uint8List bytes = base64Decode(base64String);

      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              Container(
                width: width,
                height: height,
                color: Colors.grey[300],
                child: const Icon(
                  Icons.broken_image,
                  color: Colors.grey,
                ),
              );
        },
      );
    } catch (e) {
      // Si falla la decodificación, mostrar error
      return errorWidget ??
          Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Icon(
              Icons.error_outline,
              color: Colors.red,
            ),
          );
    }
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
