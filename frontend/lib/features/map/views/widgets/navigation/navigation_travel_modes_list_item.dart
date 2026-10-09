import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/map/extensions/travel_mode_extension.dart';
import 'package:hazard_app/features/map/models/safest_fastest_routes_model.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

class NavigationTravelModesListItem extends ConsumerStatefulWidget {
  const NavigationTravelModesListItem({
    super.key,
    required this.travelMode,
    required this.route,
  });

  /// The travel mode for the route.
  final TravelMode travelMode;

  /// The route for the travel mode.
  final SafestFastestRoutes route;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NavigationTravelModesListItemState();
}

class _NavigationTravelModesListItemState
    extends ConsumerState<NavigationTravelModesListItem> {
  @override
  Widget build(BuildContext context) {
    final isSelected = ref.watch(
      providerOfMap.select(
        (value) =>
            value.currentRoutePlan?.selectedTravelMode == widget.travelMode,
      ),
    );

    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.spMin),
          gradient: !isSelected
              ? null
              : LinearGradient(
                  colors: [
                    AppColors.orange300,
                    AppColors.red200,
                  ],
                ),
          color: isSelected ? null : AppColors.white,
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.orange300.withValues(alpha: 0.3)
                  : AppColors.shadowColor,
              blurRadius: 10,
              offset: Offset(0.0, 0.0),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 12.spMin,
          vertical: 7.spMin,
        ),
        child: Row(
          spacing: 5.spMin,
          children: [
            Icon(
              widget.travelMode.iconData,
              size: 18.spMin,
              color: isSelected ? AppColors.white : AppColors.grey,
            ),
            Text(
              widget.travelMode.displayText,
              style: TextStyle(
                fontSize: 12.spMin,
                color: isSelected ? AppColors.white : AppColors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _formatDuration(widget.route.currentRoute.durationMinutes),
              style: TextStyle(
                fontSize: 12.spMin,
                color: isSelected
                    ? AppColors.white.withValues(alpha: 0.8)
                    : AppColors.black.withValues(alpha: 0.4),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ).onPressed(_handleTravelModeChange);
  }

  /// Formats the duration in minutes to a string.
  String _formatDuration(double? durationMinutes) {
    final totalMinutes = (durationMinutes ?? 0).round();
    if (totalMinutes < 60) {
      return '${totalMinutes}m';
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  /// Handles travel mode change.
  void _handleTravelModeChange() {
    ref
        .read(providerOfMap.notifier)
        .updateSelectedTravelMode(widget.travelMode);
  }
}
