import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/extensions/color_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/models/hazard_category_model.dart';
import 'package:hazard_app/features/shared/views/widgets/category_glyph.dart';
import 'package:hazard_app/others/app_colors.dart';

/// The ink a category chip draws in: the locked category colour, darkened
/// enough to stay readable as text and as a border.
Color categoryChipColor(final HazardCategory category) {
  // Utilities amber needs the extra step to hold contrast on white.
  // Product owner 2026-08-06: the chips read too dark, utilities nearly
  // invisible. Keep just enough darkening to hold contrast on white.
  return category.id == 'utilitiesAndInfrastructure'
      ? category.resolvedColor.darken(0.16)
      : category.resolvedColor.darken(0.06);
}

/// The one category pill in the app.
///
/// The ALRT feed filters, the map keys sheet and notification settings all
/// render this, so a category is the same shape and the same colour
/// wherever it is offered.
class CategoryFilterChip extends StatelessWidget {
  const CategoryFilterChip({
    super.key,
    required this.category,
    required this.isSelected,
    this.onToggle,
    this.isCompact = false,
    this.iconOnly = false,
  });

  /// The category the chip stands for.
  final HazardCategory category;

  /// Whether the category is currently on.
  final bool isSelected;

  /// Called with the new value when tapped. A null callback renders the
  /// chip as a legend entry that does not respond to touch.
  final ValueChanged<bool>? onToggle;

  /// Tightens the padding and type one step, for screens that must fit the
  /// whole set in a few rows (Report an ALRT). Colours, the dot and the
  /// outline are untouched: it is the same chip, not a second design.
  final bool isCompact;

  /// Draws only the category's glyph in a rounded square (filters), with
  /// the name kept for screen readers and long-press.
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    final color = categoryChipColor(category);

    if (iconOnly) {
      final tile = Tooltip(
        message: category.name ?? 'Category',
        child: Semantics(
          label: category.name ?? 'Category',
          selected: isSelected,
          button: onToggle != null,
          child: Container(
            width: 52.spMin,
            height: 52.spMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isSelected ? 0.14 : 0.05),
              borderRadius: BorderRadius.circular(16.spMin),
              border: Border.all(
                color: isSelected ? color : color.withValues(alpha: 0.45),
                width: (isSelected ? 2 : 1.2).spMin,
              ),
            ),
            child: CategoryGlyph(category: category, size: 28.spMin),
          ),
        ),
      );
      final faded = onToggle != null && !isSelected
          ? Opacity(opacity: 0.45, child: tile)
          : tile;
      if (onToggle == null) return faded;
      return faded.onPressed(() => onToggle!(!isSelected));
    }

    final chip = Container(
      padding: EdgeInsets.symmetric(
        horizontal: (isCompact ? 9 : 12).spMin,
        vertical: (isCompact ? 5 : 6).spMin,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? color.withValues(alpha: 0.12)
            : color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular((isCompact ? 16 : 20).spMin),
        // The outline always carries the category's own colour, softened
        // when unselected. A grey outline made every category look the
        // same until you tapped one, which is the opposite of the point:
        // colour is how a category is recognised.
        border: Border.all(
          color: isSelected ? color : color.withValues(alpha: 0.45),
          width: (isSelected ? 1.6 : 1.2).spMin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The category's own glyph on its disc (product owner, 12 Oct
          // 2026): a category is recognised by shape and colour, not by
          // reading the label.
          Padding(
            padding: EdgeInsets.only(right: (isCompact ? 6 : 8).spMin),
            child: CategoryGlyph(
              category: category,
              size: (isCompact ? 20 : 22).spMin,
            ),
          ),
          Text(
            category.name ?? 'Unknown Category',
            style: TextStyle(
              fontSize: (isCompact ? 12.5 : 14).spMin,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? color : AppColors.black,
            ),
          ),
        ],
      ),
    );

    final faded = onToggle != null && !isSelected
        ? Opacity(opacity: 0.45, child: chip)
        : chip;
    if (onToggle == null) return faded;
    return faded.onPressed(() => onToggle!(!isSelected));
  }
}
