import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/shared/enums/category_image_type.dart';
import 'package:hazard_app/features/shared/models/category_image_model.dart';

part 'hazard_category_model.freezed.dart';
part 'hazard_category_model.g.dart';

@freezed
abstract class HazardCategory with _$HazardCategory {
  const HazardCategory._();

  const factory HazardCategory({
    /// The unique identifier for the hazard category.
    required final String id,

    /// The name of the hazard category.
    final String? name,

    /// The description of the hazard category.
    final String? description,

    /// The color associated with the hazard category.
    @ColorConverter() final Color? color,

    /// The ID of the parent category, if any.
    final String? parentId,

    /// The parent category of this hazard category, if any.
    final HazardCategory? parent,

    /// The number of hazards associated with this category.
    @Default(0) final int hazardsCount,

    /// Whether the hazard category is fire-related.
    @Default(false) final bool isFireRelated,

    /// The images associated with the hazard category.
    final List<CategoryImage>? images,
  }) = _HazardCategory;

  /// Checks if the hazard category is bushfire.
  bool get isBushfire => id == 'bushfire';

  /// Gets the effective color of the hazard category, falling back to the parent's color if not set.
  Color? get effectiveColor => color ?? parent?.color;

  /// The single colour this category shows everywhere in the app.
  ///
  /// The locked design-system hex wins for the seven known categories, so a
  /// category looks identical on the map, the feed, the filters and the
  /// report form. Anything the palette does not name keeps whatever colour
  /// the server gave it, and falls back to Other last.
  Color get resolvedColor =>
      lockedCategoryColorFor(name) ??
      lockedCategoryColorFor(parent?.name) ??
      effectiveColor ??
      categoryOtherColor;

  /// Gets the category image by type from the category or its parent.
  CategoryImage? categoryImageByType(CategoryImageType type) {
    final img = images?.firstWhereOrNull((image) => image.imageType == type);
    if (img != null) {
      return img;
    }

    final parentImg = parent?.categoryImageByType(type);
    if (parentImg != null) {
      return parentImg;
    }

    return null;
  }

  factory HazardCategory.fromJson(Map<String, dynamic> json) =>
      _$HazardCategoryFromJson(json);
}

class ColorConverter implements JsonConverter<Color?, String?> {
  const ColorConverter();

  @override
  Color? fromJson(String? json) {
    if (json == null) return null;
    final hexColor = json.replaceFirst('#', '');
    if (hexColor.length == 6) {
      return Color(int.parse('FF$hexColor', radix: 16));
    } else if (hexColor.length == 8) {
      return Color(int.parse(hexColor, radix: 16));
    }
    return null;
  }

  @override
  String? toJson(Color? object) {
    if (object == null) return null;
    // ignore: deprecated_member_use
    return '#${object.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}

/// The locked "Other" category colour, and the last resort for any category
/// the palette does not name.
const categoryOtherColor = Color(0xFFA67C52);

/// The locked category colours from the design system, matched on name.
///
/// Returns null when the name is not one of the seven locked categories, so
/// callers can fall back to a server-supplied colour for anything new.
Color? lockedCategoryColorFor(final String? categoryName) {
  final name = categoryName?.toLowerCase() ?? '';
  if (name.isEmpty) return null;
  if (name.contains('weather') || name.contains('environment')) {
    return const Color(0xFF2FA6FF);
  }
  if (name.contains('health') || name.contains('air')) {
    return const Color(0xFFFF7E29);
  }
  if (name.contains('security') || name.contains('crime')) {
    // Magenta, deliberately NOT red: red is reserved for highest-danger
    // severity semantics (product-owner ruling 2026-08-20, FINAL_HANDOFF).
    return const Color(0xFFD946EF);
  }
  if (name.contains('traffic') || name.contains('transport')) {
    return const Color(0xFF00CC96);
  }
  if (name.contains('utilit')) return const Color(0xFFFFB300);
  if (name.contains('community') || name.contains('info')) {
    return const Color(0xFFC233DB);
  }
  if (name.contains('other')) return categoryOtherColor;
  return null;
}
