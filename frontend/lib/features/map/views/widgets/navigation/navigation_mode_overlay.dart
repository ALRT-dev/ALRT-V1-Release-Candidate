import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/views/screens/family_journey_screen.dart';
import 'package:hazard_app/features/map/models/route_step_model.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/utils/transit_icons.dart';
import 'package:hazard_app/features/map/views/screens/check_route_screen.dart';
import 'package:hazard_app/features/map/views/widgets/custom_compass_button.dart';
import 'package:hazard_app/features/map/views/widgets/navigation/navigation_simulation_controls.dart';
import 'package:hazard_app/features/map/views/widgets/navigation/route_hazard_shape.dart';
import 'package:hazard_app/features/map/views/widgets/navigation/route_option_format.dart';
import 'package:hazard_app/features/map/views/widgets/navigation/take_alternate_route.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/views/screens/view_hazard_screen.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:hazard_app/features/map/utils/test_build.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Travelling (prototype board "Travelling", Sarah 9 Oct 2026): the trip in
/// progress over the live map. Title with time, distance and road, End;
/// the next instruction; how many alerts are on the way and which; Share
/// journey. An alert ahead pops up as the en route sheet
/// ([TakeAlternateRoute], board "EnRouteAlert").
class NavigationModeOverlay extends ConsumerStatefulWidget {
  const NavigationModeOverlay({super.key});

  @override
  ConsumerState<NavigationModeOverlay> createState() =>
      _NavigationModeOverlayState();
}

class _NavigationModeOverlayState extends ConsumerState<NavigationModeOverlay> {
  static const _ink = Color(0xFF1C1C1E);
  static const _muted = Color(0xFF5C5C66);
  static const _routeBlue = Color(0xFF2563EB);
  static const _field = Color(0xFFE3E6EA);

  static List<BoxShadow> get _shadow => [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.08),
          blurRadius: 12.0,
          offset: const Offset(0, 4),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final showEnRoute = ref.watch(
      providerOfMap.select((s) => s.showTakeAlternateRouteButton),
    );

    return Stack(
      children: [
        SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.spMin, 8.spMin, 16.spMin, 30.spMin),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              if (isTestBuild)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.spMin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const NavigationSimulationControls(),
                        SizedBox(height: 8.spMin),
                        const CustomCompassButton(),
                      ],
                    ),
                  ),
                ),
              const Spacer(),
              _buildInstructionCard(),
              SizedBox(height: 10.spMin),
              _buildRoutePanel(),
            ],
            ),
          ),
        ),
        if (showEnRoute) ...[
          Positioned.fill(
            child: ColoredBox(
              color: AppColors.black.withValues(alpha: 0.35),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: TakeAlternateRoute(),
          ),
        ],
      ],
    );
  }

  // ------------------------------------------------------------- header

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.spMin),
        boxShadow: _shadow,
      ),
      padding: EdgeInsets.fromLTRB(4.spMin, 6.spMin, 12.spMin, 12.spMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => CheckRouteScreen.open(context),
                tooltip: 'Check a route',
                icon: Icon(LucideIcons.chevronLeft, size: 26.spMin, color: _ink),
              ),
              Expanded(
                child: Text(
                  'Travelling',
                  style: TextStyle(
                    fontSize: 24.spMin,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: _ink,
                  ),
                ),
              ),
              SizedBox(
                height: 36.spMin,
                child: OutlinedButton(
                  onPressed: _handleEndNavigation,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _ink,
                    side: const BorderSide(color: _field),
                    padding: EdgeInsets.symmetric(horizontal: 14.spMin),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.spMin),
                    ),
                  ),
                  child: Text(
                    'End',
                    style: TextStyle(
                      fontSize: 13.spMin,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 12.spMin),
            child: Consumer(
              builder: (context, ref, child) {
                final line = ref.watch(
                  providerOfMap.select((s) {
                    final options = s.currentRoutePlan?.currentRoute;
                    if (options == null) return '';
                    final route = options.currentRoute;
                    final seconds = s.remainingDurationSeconds;
                    final minutes = seconds != null
                        ? seconds / 60
                        : route.durationMinutes;
                    final metres = s.remainingDistanceMeters ??
                        RouteOptionFormat.routeMetres(route);
                    final via = RouteOptionFormat.viaRoad(
                      options.stepsForRoute(route),
                    );
                    return [
                      RouteOptionFormat.minutes(minutes),
                      if (metres != null) RouteOptionFormat.distance(metres),
                      if (via != null) 'via $via',
                    ].join(' · ');
                  }),
                );
                return Text(
                  line,
                  style: TextStyle(fontSize: 14.spMin, color: _muted),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------- next instruction

  Widget _buildInstructionCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.spMin),
        boxShadow: _shadow,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.spMin, vertical: 10.spMin),
      child: Row(
        children: [
          Consumer(
            builder: (context, ref, child) {
              final step = ref.watch(
                providerOfMap.select((s) => s.nextStep ?? s.currentStep),
              );
              return Icon(_iconForStep(step), size: 24.spMin, color: _ink);
            },
          ),
          SizedBox(width: 10.spMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    final instruction = ref.watch(
                      providerOfMap.select(
                        (s) =>
                            s.nextStep?.instruction ??
                            s.currentStep?.instruction ??
                            '',
                      ),
                    );
                    return AutoSizeText(
                      instruction.isEmpty
                          ? 'Follow the route'
                          : instruction.split('\n').first,
                      maxLines: 2,
                      minFontSize: 11,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.spMin,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    );
                  },
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final detail = ref.watch(
                      providerOfMap.select((s) {
                        final step = s.nextStep;
                        final transit = step?.transitDetails;
                        final destination =
                            s.currentRoutePlan?.destination.displayName;
                        final parts = <String>[];
                        if (step?.travelMode == TravelMode.transit &&
                            transit?.stopCount != null) {
                          final stops = transit!.stopCount!;
                          final headsign = transit.headsign;
                          parts.add(
                            '$stops stop${stops == 1 ? '' : 's'}'
                            '${headsign != null && headsign.isNotEmpty ? ' to $headsign' : ''}',
                          );
                        } else if (s.distanceToNextManeuverMeters != null) {
                          parts.add(
                            'In ${RouteOptionFormat.distance(s.distanceToNextManeuverMeters)}',
                          );
                        }
                        if (destination != null) parts.add('Then $destination');
                        return parts.join(' · ');
                      }),
                    );
                    if (detail.isEmpty) return const SizedBox.shrink();
                    return Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.spMin, color: _muted),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(width: 10.spMin),
          Consumer(
            builder: (context, ref, child) {
              final seconds = ref.watch(
                providerOfMap.select((s) => s.remainingDurationSeconds),
              );
              if (seconds == null) return const SizedBox.shrink();
              return Text(
                RouteOptionFormat.minutes(seconds / 60),
                style: TextStyle(
                  fontSize: 13.spMin,
                  fontWeight: FontWeight.w700,
                  color: _routeBlue,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------- alerts on the way

  Widget _buildRoutePanel() {
    final plan = ref.watch(providerOfMap.select((s) => s.currentRoutePlan));
    final options = plan?.currentRoute;
    final hazards = plan == null || options == null
        ? const <Hazard>[]
        : RouteOptionFormat.hazardsOnRoute(
            hazards: plan.hazardsToAvoid,
            route: options.currentRoute,
          );
    final count = hazards.length;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.34;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.spMin),
        boxShadow: _shadow,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.spMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 10.spMin,
                  height: 10.spMin,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: count > 0
                        ? _bandColor(hazards.first)
                        : const Color(0xFF16A34A),
                  ),
                ),
                SizedBox(width: 10.spMin),
                Expanded(
                  child: Text(
                    count > 0
                        ? '$count alert${count == 1 ? '' : 's'} ahead on this route'
                        : 'Nothing on your route right now',
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.spMin),
            Text(
              'ALRT watches the road ahead. If an alert touches your route it '
              'pops up here, and on your lock screen if the app is in the '
              'background.',
              style: TextStyle(fontSize: 13.spMin, color: _muted, height: 1.45),
            ),
            if (count > 0) ...[
              SizedBox(height: 14.spMin),
              Text(
                'ON THIS ROUTE',
                style: TextStyle(
                  fontSize: 12.spMin,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppColors.sectionLabel,
                ),
              ),
              for (final hazard in hazards) _hazardRow(hazard),
            ],
            SizedBox(height: 10.spMin),
            SizedBox(
              height: 48.spMin,
              child: OutlinedButton(
                onPressed: () => context.push(FamilyJourneyScreen.route),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _ink,
                  side: const BorderSide(color: Color(0xFFD9D6D0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.spMin),
                  ),
                ),
                child: Text(
                  'Share journey',
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.spMin),
            Text(
              'Not an emergency service. Keep your eyes on the road; a '
              'passenger should handle the phone.',
              style: TextStyle(fontSize: 12.spMin, color: _muted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hazardRow(final Hazard hazard) {
    final level = routeHazardLevelOf(hazard);
    return InkWell(
      onTap: () => context.push(
        ViewHazardScreen.route,
        extra: ViewHazardScreenArgs(hazard: hazard),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.spMin),
        child: Row(
          children: [
            RouteHazardShape(hazard: hazard, size: 22.spMin),
            SizedBox(width: 10.spMin),
            Expanded(
              child: Text(
                hazard.title ?? hazard.category?.name ?? 'Alert',
                style: TextStyle(fontSize: 14.spMin, color: _ink),
              ),
            ),
            if (level.isNotEmpty) ...[
              SizedBox(width: 8.spMin),
              Text(
                level,
                style: TextStyle(fontSize: 12.spMin, color: _muted),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Color _bandColor(final Hazard hazard) =>
      hazard.color == Colors.transparent
          ? const Color(0xFF8A93A0)
          : hazard.color;

  /// End: the trip stops and the routes leave the map, back to the plain
  /// map (prototype tripend: back to Main).
  void _handleEndNavigation() {
    ref.read(providerOfMap.notifier)
      ..stopNavigation()
      ..updateCurrentRoutePlan(null);
  }
}

// ---------------------------------------------------------------------------
// Instruction icons
// ---------------------------------------------------------------------------

/// Maps each [ManeuverType] to a Material icon. The Material set already
/// covers every navigation maneuver Google Routes API returns.
IconData _iconForManeuver(ManeuverType? maneuver) {
  switch (maneuver) {
    case ManeuverType.depart:
    case ManeuverType.straight:
    case ManeuverType.unspecified:
    case null:
      return Icons.straight_rounded;
    case ManeuverType.arrive:
      return Icons.flag_rounded;
    case ManeuverType.turnLeft:
      return Icons.turn_left_rounded;
    case ManeuverType.turnRight:
      return Icons.turn_right_rounded;
    case ManeuverType.turnSlightLeft:
      return Icons.turn_slight_left_rounded;
    case ManeuverType.turnSlightRight:
      return Icons.turn_slight_right_rounded;
    case ManeuverType.turnSharpLeft:
      return Icons.turn_sharp_left_rounded;
    case ManeuverType.turnSharpRight:
      return Icons.turn_sharp_right_rounded;
    case ManeuverType.uTurnLeft:
      return Icons.u_turn_left_rounded;
    case ManeuverType.uTurnRight:
      return Icons.u_turn_right_rounded;
    case ManeuverType.keepLeft:
    case ManeuverType.forkLeft:
      return Icons.fork_left_rounded;
    case ManeuverType.keepRight:
    case ManeuverType.forkRight:
      return Icons.fork_right_rounded;
    case ManeuverType.merge:
      return Icons.merge_rounded;
    case ManeuverType.roundaboutLeft:
      return Icons.roundabout_left_rounded;
    case ManeuverType.roundaboutRight:
      return Icons.roundabout_right_rounded;
    case ManeuverType.ferry:
      return Icons.directions_boat_rounded;
    case ManeuverType.ferryTrain:
      return Icons.directions_train_rounded;
  }
}

/// The icon for a navigation step: a vehicle icon for a transit step (which
/// carries no maneuver data), otherwise the usual turn-by-turn maneuver icon.
IconData _iconForStep(RouteStep? step) {
  if (step?.travelMode == TravelMode.transit) {
    return iconForTransitVehicleType(step?.transitDetails?.line?.vehicle.type);
  }
  return _iconForManeuver(step?.maneuver);
}
