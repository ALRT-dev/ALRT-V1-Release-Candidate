import 'package:flutter/material.dart';
import 'package:hazard_app/features/shared/models/hazard_category_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The one picture of a category: a filled disc in the locked category
/// colour with a white glyph on it (product owner, 12 Oct 2026).
///
/// It is drawn the same everywhere a category is shown: the Report chips,
/// the Filters and Notifications chips, the Map key, community cards, the
/// community pin on the map and the community report header. The glyph is
/// matched on the category's name so it survives a renamed id; anything
/// outside the seven locked categories falls back to the Other mark.
class CategoryGlyph extends StatelessWidget {
  const CategoryGlyph({
    super.key,
    required this.category,
    this.size = 22,
    this.borderColor,
    this.borderWidth = 0,
  });

  /// The category to draw.
  final HazardCategory category;

  /// Disc diameter in logical pixels (chips 22, pins 30, headers 40).
  final double size;

  /// An optional ring around the disc (white on map pins).
  final Color? borderColor;
  final double borderWidth;

  /// The glyph for a category name, by the same matching rule as the
  /// locked colour so colour and glyph can never disagree.
  static IconData? iconFor(final String? categoryName) {
    final name = categoryName?.toLowerCase() ?? '';
    if (name.contains('weather') || name.contains('environment')) {
      return LucideIcons.cloud;
    }
    if (name.contains('health') || name.contains('air')) {
      return LucideIcons.heartPulse;
    }
    if (name.contains('security') || name.contains('crime')) {
      return LucideIcons.lock;
    }
    if (name.contains('traffic') || name.contains('transport')) {
      return LucideIcons.car;
    }
    if (name.contains('utilit')) return LucideIcons.zap;
    if (name.contains('community') || name.contains('info')) {
      return LucideIcons.users;
    }
    // Other, and anything new the server sends: the exclamation mark,
    // drawn as text below because Lucide has no bare "!" glyph.
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final icon = iconFor(category.name);
    final color = category.resolvedColor;
    final glyphSize = size * 0.58;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: borderColor == null || borderWidth <= 0
            ? null
            : Border.all(color: borderColor!, width: borderWidth),
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, size: glyphSize, color: Colors.white)
          : Text(
              '!',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.62,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
    );
  }
}
