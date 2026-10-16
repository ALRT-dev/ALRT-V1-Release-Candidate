import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/models/hazard_category_model.dart';
import 'package:hazard_app/features/shared/views/widgets/category_filter_chip.dart';
import 'package:hazard_app/features/shared/views/widgets/category_glyph.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The category picker shared by the Filters sheet and the Notifications
/// screen: an "All categories" tile first, then every category as an equal
/// tile with its disc AND its name (product owner, 15 and 16 Oct 2026).
///
/// "All categories" is on by default and shows ticked while every
/// category is selected; the category tiles then sit dull, because all of
/// them are included. Tapping one category while All is on narrows the
/// selection to that category alone, which lights up. Tapping All again
/// selects everything; tapping it while on clears the selection only
/// where [allowNone] permits (Notifications: unsubscribed from every
/// category is a real choice; Filters: an empty selection means
/// everything, so All stays on).
class CategoryGridPicker extends StatelessWidget {
  const CategoryGridPicker({
    super.key,
    required this.categories,
    required this.selectedIds,
    required this.onToggle,
    required this.onSelectAll,
    this.onSelectOnly,
    this.onClearAll,
    this.allowNone = false,
  });

  final List<HazardCategory> categories;
  final Set<String> selectedIds;

  /// Switch one category on or off (used while All is off).
  final void Function(HazardCategory category) onToggle;

  /// Select every category.
  final VoidCallback onSelectAll;

  /// Narrow to one category (used when a tile is tapped while All is on).
  /// Falls back to [onToggle] when null.
  final void Function(HazardCategory category)? onSelectOnly;

  /// Clear the selection (All tapped while on). Only used if [allowNone].
  final VoidCallback? onClearAll;
  final bool allowNone;

  @override
  Widget build(BuildContext context) {
    final allOn = categories.isNotEmpty &&
        categories.every((c) => selectedIds.contains(c.id));
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 8.spMin;
        final tileWidth = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            SizedBox(
              width: constraints.maxWidth,
              child: _allTile(allOn: allOn),
            ),
            for (final category in categories)
              SizedBox(
                width: tileWidth,
                child: _categoryTile(
                  category: category,
                  // While All is on every tile is included but sits dull;
                  // a tile lights only when picked on its own.
                  isSelected: !allOn && selectedIds.contains(category.id),
                  onTap: allOn
                      ? () => (onSelectOnly ?? onToggle)(category)
                      : () => _toggle(category),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Switch one tile while All is off. Where an empty selection is not a
  /// choice (Filters: empty means everything), switching the last lit
  /// tile off goes back to All, so the tiles never show nothing selected
  /// while everything is in fact shown.
  void _toggle(final HazardCategory category) {
    final wouldEmpty = !allowNone &&
        selectedIds.length == 1 &&
        selectedIds.contains(category.id);
    if (wouldEmpty) {
      onSelectAll();
      return;
    }
    onToggle(category);
  }

  Widget _allTile({required final bool allOn}) {
    return Semantics(
      button: true,
      selected: allOn,
      label: 'All categories',
      child: Container(
        height: 52.spMin,
        padding: EdgeInsets.symmetric(horizontal: 12.spMin),
        decoration: BoxDecoration(
          color: allOn
              ? AppColors.green.withValues(alpha: 0.10)
              : AppColors.extraLightGrey,
          borderRadius: BorderRadius.circular(14.spMin),
          border: Border.all(
            color: allOn ? AppColors.green : AppColors.lightGrey,
            width: allOn ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.layoutGrid, size: 22.spMin, color: AppColors.ink),
            10.wSizedBox,
            Expanded(
              child: Text(
                'All categories',
                style: TextStyle(
                  fontSize: 14.spMin,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
            Icon(
              allOn
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: allOn ? AppColors.green : AppColors.lightGrey,
            ),
          ],
        ),
      ).onPressed(() {
        if (allOn) {
          if (allowNone) onClearAll?.call();
          return;
        }
        onSelectAll();
      }),
    );
  }

  Widget _categoryTile({
    required final HazardCategory category,
    required final bool isSelected,
    required final VoidCallback onTap,
  }) {
    final color = categoryChipColor(category);
    final name = category.name ?? 'Category';
    return Semantics(
      button: true,
      selected: isSelected,
      label: name,
      child: Opacity(
        opacity: isSelected ? 1.0 : 0.5,
        child: Container(
          height: 52.spMin,
          padding: EdgeInsets.symmetric(horizontal: 10.spMin),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.10)
                : AppColors.extraLightGrey,
            borderRadius: BorderRadius.circular(14.spMin),
            border: Border.all(
              color: isSelected ? color : AppColors.lightGrey,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              CategoryGlyph(category: category, size: 28.spMin),
              8.wSizedBox,
              Expanded(
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5.spMin,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ).onPressed(onTap),
    );
  }
}
