import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/providers/hazard_filters_provider.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HazardFiltersButton extends ConsumerStatefulWidget {
  const HazardFiltersButton({
    super.key,
    required this.filtersKey,
    this.buttonShadow = const [
      BoxShadow(
        color: AppColors.shadowColor,
        blurRadius: 10.0,
        offset: Offset(0, 0.0),
      ),
    ],
    this.onFiltersUpdated,
    this.useTransparentStyle = false,
  });

  /// The key to identify the specific hazard filters instance.
  final String filtersKey;

  /// The box shadow to apply to the dropdown button.
  final List<BoxShadow> buttonShadow;

  /// Whether to use a transparent style for the button.
  final bool useTransparentStyle;

  /// Callback when the filters are updated.
  final void Function()? onFiltersUpdated;

  @override
  ConsumerState<HazardFiltersButton> createState() =>
      _HazardFiltersButtonState();
}

class _HazardFiltersButtonState extends ConsumerState<HazardFiltersButton> {
  @override
  Widget build(BuildContext context) {
    return _filtersButtonBuilder().onPressed(_showFiltersBottomSheet);
  }

  Widget _filtersButtonBuilder() {
    return Stack(
      children: [
        Container(
          width: 48.spMin,
          height: 48.spMin,
          decoration: BoxDecoration(
            color: widget.useTransparentStyle
                ? AppColors.white.withValues(alpha: 0.2)
                : null,
            borderRadius: widget.useTransparentStyle
                ? BorderRadius.circular(14.spMin)
                : null,
            border: widget.useTransparentStyle
                ? Border.all(
                    color: AppColors.white.withValues(alpha: 0.3),
                    width: 1.0,
                  )
                : null,
            gradient: widget.useTransparentStyle
                ? null
                : LinearGradient(
                    colors: [
                      AppColors.orange300,
                      AppColors.red200,
                    ],
                  ),
          ),
          child: Icon(
            LucideIcons.slidersHorizontal,
            size: 20.spMin,
            color: AppColors.white,
          ),
        ),
        Positioned(
          right: 0,
          child: _countBuilder(),
        ),
      ],
    );
  }

  Widget _countBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final count = ref.watch(
          providerOfHazardFilters(widget.filtersKey).select(
            (value) => value.unselectedFiltersCount,
          ),
        );
        if (count == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          width: 20.spMin,
          height: 20.spMin,
          decoration: BoxDecoration(
            color: AppColors.red,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12.spMin,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        );
      },
    );
  }

  /// Shows the hazard filters bottom sheet.
  void _showFiltersBottomSheet() {
    showHazardFiltersBottomSheet(
      context: context,
      filtersKey: widget.filtersKey,
      onFiltersUpdated: widget.onFiltersUpdated,
    );
  }
}
