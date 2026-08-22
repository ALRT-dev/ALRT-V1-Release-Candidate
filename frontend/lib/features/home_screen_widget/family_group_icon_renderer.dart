import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:home_widget/home_widget.dart';

/// Renders a family group's icon to a PNG the home-screen widget can draw.
///
/// The widget process cannot fetch a URL, so the app renders each group's
/// icon to a file in the shared container and passes the path. With a
/// picture set it is the picture, cropped to a circle; without one it is
/// the group's initial on its beacon colour, the same fallback the app
/// uses. A failed download quietly falls back to the initial rather than
/// leaving a hole where a group should be.
abstract final class FamilyGroupIconRenderer {
  /// The size the icons are drawn at. Small on purpose: these sit in a
  /// row on a widget card, and the files are rewritten on every change.
  static const _logicalSize = Size(48, 48);
  static const _pixelRatio = 3.0;

  /// Renders one group icon and returns the file path, or null when the
  /// render fails. A null path means the native side skips that slot.
  static Future<String?> render({
    required final String key,
    required final String name,
    final String? photoUrl,
    final String? themeColorHex,
  }) async {
    try {
      final image = await _decodePhoto(photoUrl);
      final path = await HomeWidget.renderFlutterWidget(
        CustomPaint(
          size: _logicalSize,
          painter: _GroupIconPainter(
            initial: _initialOf(name),
            beacon: _colorOfHex(themeColorHex) ?? const Color(0xFF3D3DDF),
            photo: image,
          ),
        ),
        key: key,
        logicalSize: _logicalSize,
        pixelRatio: _pixelRatio,
      );
      return path is String ? path : null;
    } catch (e, s) {
      // A widget icon is never worth breaking the app over.
      debugPrint('FamilyGroupIconRenderer.render failed: $e\n$s');
      return null;
    }
  }

  /// Fetches and decodes the group picture. Returns null on any failure,
  /// which the painter reads as "draw the initial".
  static Future<ui.Image?> _decodePhoto(final String? url) async {
    final trimmed = url?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;

    try {
      final file = await DefaultCacheManager().getSingleFile(trimmed);
      final Uint8List bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: (_logicalSize.width * _pixelRatio).round(),
      );
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (e) {
      debugPrint('FamilyGroupIconRenderer could not load $trimmed: $e');
      return null;
    }
  }

  static String _initialOf(final String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.substring(0, 1).toUpperCase();
  }

  static Color? _colorOfHex(final String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return null;
    return Color(cleaned.length <= 6 ? value | 0xFF000000 : value);
  }
}

/// Paints the circular group icon: the picture cover-cropped to the circle,
/// or the initial on the beacon colour.
class _GroupIconPainter extends CustomPainter {
  const _GroupIconPainter({
    required this.initial,
    required this.beacon,
    this.photo,
  });

  final String initial;
  final Color beacon;
  final ui.Image? photo;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final circle = Path()..addOval(rect);

    // The beacon fills the disc either way, so a picture with transparency
    // still reads as this group's colour rather than as a hole.
    canvas.drawPath(circle, Paint()..color = beacon);

    final image = photo;
    if (image != null) {
      canvas.save();
      canvas.clipPath(circle);
      // Cover fit: the shorter side fills, the longer one is cropped, so a
      // portrait or landscape photo is never squashed.
      final src = _coverSourceRect(image, size);
      canvas.drawImageRect(image, src, rect, Paint());
      canvas.restore();
    } else {
      _paintInitial(canvas, size);
    }

    // A hairline so the icon still separates from a dark widget card.
    canvas.drawPath(
      circle,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  Rect _coverSourceRect(final ui.Image image, final Size target) {
    final imageWidth = image.width.toDouble();
    final imageHeight = image.height.toDouble();
    final scale = (target.width / imageWidth) > (target.height / imageHeight)
        ? target.width / imageWidth
        : target.height / imageHeight;
    final visibleWidth = target.width / scale;
    final visibleHeight = target.height / scale;
    return Rect.fromLTWH(
      (imageWidth - visibleWidth) / 2,
      (imageHeight - visibleHeight) / 2,
      visibleWidth,
      visibleHeight,
    );
  }

  void _paintInitial(final Canvas canvas, final Size size) {
    final painter = TextPainter(
      text: TextSpan(
        text: initial,
        style: TextStyle(
          fontSize: size.width * 0.44,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(
        (size.width - painter.width) / 2,
        (size.height - painter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _GroupIconPainter oldDelegate) =>
      initial != oldDelegate.initial ||
      beacon != oldDelegate.beacon ||
      photo != oldDelegate.photo;
}
