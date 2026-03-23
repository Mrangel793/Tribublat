import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:myapp/src/features/user/data/cloudinary_service.dart';

/// Retorna un ImageProvider que soporta URL (Cloudinary/http) y Base64.
/// Útil donde se necesita un ImageProvider en lugar de un Widget.
ImageProvider smartImageProvider(String source) {
  if (source.isEmpty) return const AssetImage('assets/images/placeholder.png');
  if (source.startsWith('http://') || source.startsWith('https://')) {
    return CachedNetworkImageProvider(source);
  }
  try {
    final bytes = _getCachedBytes(source);
    if (bytes != null) return MemoryImage(bytes);
  } catch (_) {}
  return const AssetImage('assets/images/placeholder.png');
}

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

/// Widget inteligente para imágenes:
/// - Si es URL (Cloudinary/http) → CachedNetworkImage con CDN
/// - Si es Base64 → decodifica con caché en memoria (legado)
class Base64ImageWidget extends StatelessWidget {
  final String base64String;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  /// Si true, aplica transformación de thumbnail de Cloudinary
  final bool useThumbnail;

  const Base64ImageWidget({
    super.key,
    required this.base64String,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.useThumbnail = true,
  });

  bool get _isUrl =>
      base64String.startsWith('http://') ||
      base64String.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    if (base64String.isEmpty) return _buildPlaceholder();

    // ── Imagen desde Cloudinary CDN ──
    if (_isUrl) {
      final url = useThumbnail && width != null && height != null
          ? CloudinaryService.getThumbnailUrl(
              base64String,
              width: width!.toInt(),
              height: height!.toInt(),
            )
          : base64String;

      return CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => _buildPlaceholder(),
        errorWidget: (_, __, ___) => _buildError(),
        fadeInDuration: const Duration(milliseconds: 200),
        memCacheWidth: width?.toInt(),
        memCacheHeight: height?.toInt(),
      );
    }

    // ── Imagen Base64 (legado) ──
    final bytes = _getCachedBytes(base64String);
    if (bytes == null) return _buildError();

    return Image.memory(
      bytes,
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => _buildError(),
    );
  }

  Widget _buildPlaceholder() => placeholder ??
      Container(
        width: width,
        height: height,
        color: const Color(0xFF1A1A2E),
        child: const Center(
          child: Icon(Icons.image_outlined, color: Color(0xFF2A2A3E), size: 32),
        ),
      );

  Widget _buildError() => errorWidget ??
      Container(
        width: width,
        height: height,
        color: const Color(0xFF1A1A2E),
        child: const Center(
          child: Icon(Icons.broken_image_outlined,
              color: Color(0xFF2A2A3E), size: 32),
        ),
      );
}

/// Avatar circular — soporta URL de Cloudinary y Base64 (legado)
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

  bool get _isUrl =>
      base64String.startsWith('http://') ||
      base64String.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? const Color(0xFF2A2A3E);
    final size = (radius * 2).toInt();

    if (base64String.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bg,
        child: Icon(Icons.person, size: radius, color: Colors.white),
      );
    }

    if (_isUrl) {
      final avatarUrl = CloudinaryService.getAvatarUrl(
        base64String,
        size: size,
      );
      return CircleAvatar(
        radius: radius,
        backgroundColor: bg,
        backgroundImage: CachedNetworkImageProvider(avatarUrl),
      );
    }

    // Base64 legado
    try {
      final bytes = base64Decode(base64String);
      return CircleAvatar(
        radius: radius,
        backgroundColor: bg,
        backgroundImage: MemoryImage(bytes),
      );
    } catch (_) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bg,
        child: Icon(Icons.person, size: radius, color: Colors.white),
      );
    }
  }
}
