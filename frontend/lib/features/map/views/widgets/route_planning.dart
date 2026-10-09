import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/map/extensions/travel_mode_extension.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/utils/dialogs.dart';
import 'package:hazard_app/features/map/utils/hazard_avoidance_helper.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_types.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/views/widgets/round_button.dart';
import 'package:hazard_app/others/app_colors.dart';

class RoutePlanning extends ConsumerStatefulWidget {
  const RoutePlanning({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RoutePlanningState();
}

class _RoutePlanningState extends ConsumerState<RoutePlanning> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.spMin),
        border: Border.all(
          color: AppColors.lightGrey,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10.0,
            offset: Offset(0, 0.0),
          ),
        ],
      ),
      padding: EdgeInsets.all(10.spMin),
      child: Column(
        spacing: 8.h,
        children: [
          _headerBuilder(),
          _analysisBuilder(),
          Row(
            spacing: 5.spMin,
            children: [
              Expanded(
                child: _travelModesBuilder(),
              ),
              _toggleNavigationButtonBuilder(),
            ],
          ).pT(3.0),
        ],
      ),
    );
  }

  Widget _headerBuilder() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          spacing: 8.w,
          children: [
            Icon(
              Icons.route,
              color: AppColors.primary,
            ),
            Text(
              'Route Planning',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Consumer(
              builder: (context, ref, child) {
                final distanceInKm = ref.watch(
                  providerOfMap.select(
                    (value) => value
                        .currentRoutePlan
                        ?.currentRoute
                        ?.currentRoute
                        .distanceKm,
                  ),
                );
                final distanceInMeters = ref.watch(
                  providerOfMap.select(
                    (value) => value
                        .currentRoutePlan
                        ?.currentRoute
                        ?.currentRoute
                        .distanceMeters,
                  ),
                );

                return Text(
                  distanceInKm != null && distanceInKm >= 1
                      ? '${distanceInKm.toStringAsFixed(2)} km'
                      : distanceInMeters != null
                      ? '$distanceInMeters m'
                      : '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.grey,
                  ),
                );
              },
            ),
          ],
        ),
        _closeButtonBuilder(),
      ],
    );
  }

  Widget _analysisBuilder() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.spMin),
      decoration: BoxDecoration(
        color: _getMainColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.spMin),
        border: Border.all(
          color: _getMainColor().withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        spacing: 2.h,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 5.w,
            children: [
              Icon(
                _routeHazardSummary.riskLevel == RouteRiskLevel.safe
                    ? Icons.check_circle_outline_rounded
                    : Icons.warning_amber_rounded,
                color: _getMainColor(),
                size: 16.sp,
              ),
              Text(
                'Route Safety Analysis',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: _getMainColor(),
                ),
              ),
            ],
          ),
          Text(
            _routeHazardSummary.summaryMessage,
            style: TextStyle(
              fontSize: 10.sp,
              color: _getMainColor(),
            ),
          ),
          if (_routeHazardSummary.riskLevel != RouteRiskLevel.safe)
            _chipsBuilder().pT(5.0),
        ],
      ),
    ).onPressed(_handleRouteSafetyAnalysisTap);
  }

  Widget _chipsBuilder() {
    return Wrap(
      spacing: 8.spMin,
      runSpacing: 4.spMin,
      children: [
        if (_routeHazardSummary.emergencyHazards > 0)
          _chipItemBuilder(
            label: '${_routeHazardSummary.emergencyHazards} emergency',
            severity: HazardSeverity.emergency,
          ),
        if (_routeHazardSummary.highRiskHazards > 0)
          _chipItemBuilder(
            label: '${_routeHazardSummary.highRiskHazards} high',
            severity: HazardSeverity.watchAndAct,
          ),
        if (_routeHazardSummary.mediumRiskHazards > 0)
          _chipItemBuilder(
            label: '${_routeHazardSummary.mediumRiskHazards} medium',
            severity: HazardSeverity.advice,
            textColor: AppColors.darkYellow,
          ),
        if (_routeHazardSummary.lowRiskHazards > 0)
          _chipItemBuilder(
            label: '${_routeHazardSummary.lowRiskHazards} low',
            severity: HazardSeverity.info,
          ),
      ],
    );
  }

  Widget _chipItemBuilder({
    required final String label,
    required final HazardSeverity severity,
    final Color? textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.spMin,
        vertical: 4.spMin,
      ),
      decoration: BoxDecoration(
        color: severity.colorAws.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8.spMin),
        border: Border.all(
          color: (textColor ?? severity.colorAws).withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: textColor ?? severity.colorAws,
        ),
      ),
    );
  }

  Widget _closeButtonBuilder() {
    return RoundButton(
      icon: Icon(
        Icons.close_rounded,
        size: 20.spMin,
      ),
      size: 30.0,
      onPressed: _handleClose,
    );
  }

  Widget _travelModesBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final selectedTravelMode = ref.watch(
          providerOfMap.select(
            (value) => value.currentRoutePlan?.selectedTravelMode,
          ),
        );

        final travelModeRoutes = ref.watch(
          providerOfMap.select(
            (value) => value.currentRoutePlan?.travelModeRoutes ?? {},
          ),
        );
        final unavailableModes = ref.watch(
          providerOfMap.select(
            (value) => value.currentRoutePlan?.unavailableModes ?? {},
          ),
        );

        // Every mode keeps its place in the row. A mode with no route is
        // shown greyed and says why when tapped, instead of vanishing and
        // leaving you wondering where public transport went.
        const modeOrder = [
          TravelMode.driving,
          TravelMode.transit,
          TravelMode.walking,
          TravelMode.bicycling,
        ];

        return Row(
          spacing: 5.spMin,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final mode in modeOrder)
              if (travelModeRoutes.containsKey(mode) ||
                  unavailableModes.containsKey(mode))
                Expanded(
                  child: travelModeRoutes.containsKey(mode)
                      ? _travelModeItemBuilder(
                          icon: mode.iconData,
                          duration:
                              travelModeRoutes[mode]!
                                      .currentRoute
                                      .durationMinutes !=
                                  null
                              ? '${travelModeRoutes[mode]!.currentRoute.durationMinutes?.toStringAsFixed(0)}m'
                              : null,
                          isSelected: selectedTravelMode == mode,
                          onTap: () => _handleTravelModeChange(mode),
                        )
                      : _travelModeItemBuilder(
                          icon: mode.iconData,
                          duration: '--',
                          isSelected: false,
                          isUnavailable: true,
                          onTap: () => _showModeUnavailableSheet(
                            mode: mode,
                            reason: unavailableModes[mode]!,
                          ),
                        ),
                ),
          ],
        );
      },
    );
  }

  /// Why a mode has no route, in a sheet rather than a toast.
  ///
  /// A toast takes the answer away after three seconds, which is no use for
  /// the one question this screen actually gets asked: why is public
  /// transport greyed out? The reason stays on screen until dismissed, and
  /// the exact text Google returned is kept underneath — a trip with no
  /// service and a misconfigured API key look identical up top, and only
  /// that line tells them apart.
  void _showModeUnavailableSheet({
    required final TravelMode mode,
    required final String reason,
  }) {
    final isTransit = mode == TravelMode.transit;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22.spMin)),
        ),
        padding: EdgeInsets.fromLTRB(
          20.spMin,
          18.spMin,
          20.spMin,
          16.spMin,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(mode.iconData, size: 20.spMin, color: AppColors.grey),
                  SizedBox(width: 10.spMin),
                  Expanded(
                    child: Text(
                      '${mode.displayText} is not available for this trip',
                      style: TextStyle(
                        fontSize: 16.spMin,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.spMin),
              Text(
                isTransit
                    ? 'ALRT asks Google for a public transport route every '
                          'time you plan a trip. Google returns one only '
                          'where it has timetable data and a service that '
                          'runs at the time you are travelling.'
                    : 'ALRT asked Google for this mode and it returned no '
                          'route between these two points.',
                style: TextStyle(
                  fontSize: 13.spMin,
                  height: 1.5,
                  color: AppColors.mediumGrey,
                ),
              ),
              SizedBox(height: 14.spMin),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.spMin),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12.spMin),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WHAT GOOGLE SAID',
                      style: TextStyle(
                        fontSize: 10.spMin,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: AppColors.grey,
                      ),
                    ),
                    SizedBox(height: 6.spMin),
                    SelectableText(
                      reason,
                      style: TextStyle(
                        fontSize: 12.spMin,
                        height: 1.45,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.spMin),
              SizedBox(
                height: 44.spMin,
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.lightGrey.withValues(
                      alpha: 0.5,
                    ),
                    foregroundColor: AppColors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.spMin),
                    ),
                  ),
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 14.spMin,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _travelModeItemBuilder({
    required final IconData icon,
    final String? duration,
    required final bool isSelected,
    required final VoidCallback onTap,
    final bool isUnavailable = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 5.spMin,
          vertical: 6.spMin,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.white,
          borderRadius: BorderRadius.circular(8.spMin),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightGrey,
          ),
        ),
        child: Row(
          spacing: 5.w,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16.spMin,
              color: isUnavailable
                  ? AppColors.grey.withValues(alpha: 0.5)
                  : isSelected
                  ? AppColors.primary
                  : AppColors.black,
            ),
            if (duration != null)
              Text(
                duration,
                style: TextStyle(
                  fontSize: 12.spMin,
                  color: isUnavailable
                      ? AppColors.grey.withValues(alpha: 0.5)
                      : isSelected
                      ? AppColors.primary
                      : AppColors.black,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _toggleNavigationButtonBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final isNavigating = ref.watch(
          providerOfMap.select(
            (value) => value.currentRoutePlan?.isNavigating ?? false,
          ),
        );

        return RoundButton(
          icon: Icon(
            isNavigating ? Icons.close_rounded : Icons.navigation_rounded,
            size: 16.spMin,
            color: isNavigating ? AppColors.white : AppColors.black,
          ),
          size: 30.0,
          backgroundColor: isNavigating ? AppColors.red : null,
          onPressed: () => _handleToggleNavigation(),
        );
      },
    );
  }

  /// Returns the route hazard summary from the provider.
  RouteHazardSummary get _routeHazardSummary {
    final hazards = ref.watch(
      providerOfMap.select(
        (value) => value.currentRoutePlan?.hazardsToAvoid ?? [],
      ),
    );
    final routePoints = ref.watch(
      providerOfMap.select(
        (value) =>
            value.currentRoutePlan?.currentRoute?.currentRoute.polylinePoints
                ?.map((e) => LatLng(e.latitude, e.longitude))
                .toList() ??
            [],
      ),
    );
    final sum = HazardAvoidanceHelper.analyzeRouteHazards(
      hazards: hazards,
      routePoints: routePoints,
    );
    return sum;
  }

  /// Returns the main color based on the route risk level.
  Color _getMainColor() {
    switch (_routeHazardSummary.riskLevel) {
      case RouteRiskLevel.emergency:
        return AppColors.emergency;
      case RouteRiskLevel.high:
        return AppColors.watchAndAct;
      case RouteRiskLevel.medium:
        return AppColors.darkYellow;
      case RouteRiskLevel.low:
        return AppColors.info;
      case RouteRiskLevel.safe:
        return Colors.green.shade700;
    }
  }

  /// Handles the close button press to clear the current route.
  void _handleClose() {
    final isNavigating = ref.read(
      providerOfMap.select(
        (value) => value.currentRoutePlan?.isNavigating ?? false,
      ),
    );
    if (isNavigating) {
      ref.read(providerOfMap.notifier).stopNavigation();
    } else {
      ref.read(providerOfMap.notifier).updateCurrentRoutePlan(null);
    }
  }

  /// Handles travel mode change.
  void _handleTravelModeChange(final TravelMode mode) {
    ref.read(providerOfMap.notifier).updateSelectedTravelMode(mode);
  }

  /// Handles start navigation button press.
  void _handleToggleNavigation() {
    ref.read(providerOfMap.notifier).toggleNavigation();
  }

  /// Handles tap on the route safety analysis section.
  void _handleRouteSafetyAnalysisTap() {
    final hasHazards = _routeHazardSummary.totalHazards > 0;
    if (!hasHazards) return;

    showMapHazardsListBottomSheet(
      context: context,
      showOnlyRouteHazards: true,
    );
  }
}
