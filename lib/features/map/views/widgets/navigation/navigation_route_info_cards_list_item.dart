import 'package:flutter/material.dart' hide Route;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/utils/hazard_avoidance_helper.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:hazard_app/others/app_theme.dart';

class NavigationRouteInfoCardsListItem extends ConsumerStatefulWidget {
  const NavigationRouteInfoCardsListItem({
    super.key,
    required this.route,
  });

  /// The route to display information for.
  final Route route;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NavigationRouteInfoCardsListItemState();
}

class _NavigationRouteInfoCardsListItemState
    extends ConsumerState<NavigationRouteInfoCardsListItem> {
  @override
  Widget build(BuildContext context) {
    final isSelected = ref.watch(
      providerOfMap.select(
        (value) =>
            value.currentRoutePlan?.currentRoute?.selectedRoute == widget.route,
      ),
    );
    return Container(
      constraints: BoxConstraints(
        minWidth: 152.spMin,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.spMin),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8.0,
            offset: Offset(0, 0.0),
          ),
        ],
        border: Border.all(
          color: isSelected ? AppColors.blue : AppColors.transparent,
          width: 1.5,
        ),
      ),
      padding: EdgeInsets.all(8.spMin),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeaderHazardCount(),
                6.wSizedBox,
                _buildRouteMetadata(),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRouteDuration(),
                _buildRouteDistance(),
              ],
            ),
            _buildActionButton(),
          ],
        ),
      ),
    ).onPressed(_handleRouteTap);
  }

  Widget _buildHeaderHazardCount() {
    return Consumer(
      builder: (context, ref, child) {
        final hazardCount = _getRouteHazardSummary(ref).totalHazards;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: hazardCount == 0
                    ? AppColors.green.withValues(alpha: 0.1)
                    : AppColors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4.spMin),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 6.spMin,
                vertical: 2.spMin,
              ),
              child: Row(
                children: [
                  Icon(
                    hazardCount == 0
                        ? Icons.check_rounded
                        : Icons.warning_rounded,
                    size: 10.spMin,
                    color: hazardCount == 0 ? AppColors.green : AppColors.red,
                  ),
                  3.wSizedBox,
                  Text(
                    hazardCount == 0
                        ? 'AVOIDS HAZARDS'
                        : '$hazardCount HAZARD${hazardCount == 1 ? '' : 'S'}',
                    style: TextStyle(
                      fontSize: 9.spMin,
                      fontWeight: FontWeight.w700,
                      color: hazardCount == 0 ? AppColors.green : AppColors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRouteDuration() {
    final totalMinutes = (widget.route.durationMinutes ?? 0).round();
    final suffixStyle = TextStyle(
      fontSize: 10.spMin,
      color: AppColors.grey.withValues(alpha: 0.7),
      letterSpacing: -0.5,
      fontFamily: AppTheme.defaultFontFamily,
    );

    final List<TextSpan> children;
    if (totalMinutes < 60) {
      children = [
        TextSpan(text: '$totalMinutes'),
        TextSpan(text: ' min', style: suffixStyle),
      ];
    } else {
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      if (minutes == 0) {
        children = [
          TextSpan(text: '$hours'),
          TextSpan(text: ' hr', style: suffixStyle),
        ];
      } else {
        children = [
          TextSpan(text: '$hours'),
          TextSpan(text: ' hr  ', style: suffixStyle),
          TextSpan(text: '$minutes'),
          TextSpan(text: ' min', style: suffixStyle),
        ];
      }
    }

    return Text.rich(
      TextSpan(children: children),
      style: TextStyle(
        fontSize: 20.spMin,
        fontWeight: FontWeight.w700,
        fontFamily: AppTheme.defaultFontFamily,
        height: 1.2,
      ),
    );
  }

  Widget _buildRouteDistance() {
    final distanceInKm = widget.route.distanceKm;
    final distanceInMeters = widget.route.distanceMeters;

    return Row(
      children: [
        Text(
          distanceInKm != null && distanceInKm >= 1
              ? '${distanceInKm.toStringAsFixed(2)} km'
              : distanceInMeters != null
              ? '$distanceInMeters m'
              : '',

          style: TextStyle(
            fontSize: 10.spMin,
            color: AppColors.grey.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteMetadata() {
    return Consumer(
      builder: (context, ref, child) {
        final fastestRoute = ref.watch(
          providerOfMap.select(
            (value) => value.currentRoutePlan?.currentRoute?.fastestRoute,
          ),
        );
        final additionalDuration =
            (widget.route.durationMinutes ?? 0).round() -
            (fastestRoute?.durationMinutes ?? 0).round();
        final isFastest =
            fastestRoute == widget.route || additionalDuration == 0;

        return Container(
          decoration: BoxDecoration(
            color: isFastest
                ? AppColors.green.withValues(alpha: 0.1)
                : AppColors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(50.spMin),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 6.spMin,
            vertical: 2.spMin,
          ),
          child: Text(
            isFastest ? 'Fastest' : '+$additionalDuration min',
            style: TextStyle(
              fontSize: 9.spMin,
              color: isFastest ? AppColors.green : AppColors.red,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton() {
    return Consumer(
      builder: (context, ref, child) {
        final hazardCount = _getRouteHazardSummary(ref).totalHazards;

        return Container(
          decoration: BoxDecoration(
            color: hazardCount == 0
                ? AppColors.green.withValues(alpha: 0.1)
                : AppColors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6.spMin),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 6.spMin,
            vertical: 3.spMin,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hazardCount == 0) ...[
                Icon(
                  Icons.check_rounded,
                  size: 10.spMin,
                  color: AppColors.green,
                ),
                3.wSizedBox,
              ],
              Text(
                hazardCount == 0 ? 'No hazards on route' : 'View Hazards',
                style: TextStyle(
                  fontSize: 10.spMin,
                  color: hazardCount == 0 ? AppColors.green : AppColors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hazardCount > 0) ...[
                3.wSizedBox,
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 10.spMin,
                  color: hazardCount == 0 ? AppColors.green : AppColors.red,
                ),
              ],
            ],
          ),
        ).onPressed(_viewHazards);
      },
    );
  }

  void _handleRouteTap() {
    ref.read(providerOfMap.notifier).handleRouteTap(widget.route);
  }

  void _viewHazards() {
    final hazards = _getRouteHazardSummary(ref).hazards;
    if (hazards.isEmpty) return;

    showHazardsBottomsheet(
      context: context,
      hazards: hazards,
    );
  }

  /// Returns the route hazard summary from the provider.
  RouteHazardSummary _getRouteHazardSummary(final WidgetRef ref) {
    final hazards = ref.watch(
      providerOfMap.select(
        (value) => value.currentRoutePlan?.hazardsToAvoid ?? [],
      ),
    );
    final routePoints =
        widget.route.polylinePoints
            ?.map((e) => LatLng(e.latitude, e.longitude))
            .toList() ??
        [];
    final sum = HazardAvoidanceHelper.analyzeRouteHazards(
      hazards: hazards,
      routePoints: routePoints,
      otherHazardsBufferKm: 0.5,
    );
    return sum;
  }
}
