import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart'
    show TravelMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/map/models/route_step_model.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/utils/transit_icons.dart';
import 'package:hazard_app/features/map/views/widgets/custom_compass_button.dart';
import 'package:hazard_app/features/map/views/widgets/navigation/navigation_simulation_controls.dart';
import 'package:hazard_app/features/map/views/widgets/navigation/take_alternate_route.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class NavigationModeOverlay extends ConsumerStatefulWidget {
  const NavigationModeOverlay({super.key});

  @override
  ConsumerState<NavigationModeOverlay> createState() =>
      _NavigationModeOverlayState();
}

class _NavigationModeOverlayState extends ConsumerState<NavigationModeOverlay> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        spacing: 8.spMin,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildTurnInfo(),
              Consumer(
                builder: (context, ref, child) {
                  final showNavigationSimulationPanel =
                      kDebugMode &&
                      ref.watch(
                        providerOfMap.select(
                          (value) =>
                              value.currentRoutePlan?.isNavigating ?? false,
                        ),
                      );
                  if (!showNavigationSimulationPanel) {
                    return const SizedBox.shrink();
                  }
                  return const NavigationSimulationControls().pT(8.0);
                },
              ),
            ],
          ),
          Column(
            spacing: 8.spMin,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildCompassButton(),
              _buildTakeAlternateRouteButton(),
              _buildRemainingInfo(),
              _buildFooter(),
            ],
          ),
        ],
      ).pX(16.0).pB(30.0),
    );
  }

  Widget _buildTurnInfo() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(14.spMin),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8.0,
            offset: Offset(0.0, 0.0),
          ),
        ],
      ),
      padding: EdgeInsets.all(12.spMin),
      child: Row(
        spacing: 12.spMin,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    final step = ref.watch(
                      providerOfMap.select(
                        (s) => s.nextStep ?? s.currentStep,
                      ),
                    );

                    return Container(
                      width: 56.spMin,
                      height: 56.spMin,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.spMin),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.orange300,
                            AppColors.red200,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.red200,
                            blurRadius: 8.0,
                            offset: Offset(0.0, 0.0),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _iconForStep(step),
                          size: 32.spMin,
                          color: AppColors.white,
                        ),
                      ),
                    );
                  },
                ),
                12.wSizedBox,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // "In 400 m" — distance to the next maneuver. Watches just
                      // distanceToNextManeuverMeters so this Text is the only
                      // widget that rebuilds on each GPS tick.
                      Consumer(
                        builder: (context, ref, child) {
                          final meters = ref.watch(
                            providerOfMap.select(
                              (s) => s.distanceToNextManeuverMeters,
                            ),
                          );
                          return Text(
                            _formatDistancePrefix(meters),
                            style: TextStyle(
                              fontSize: 11.spMin,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF888888),
                            ),
                          );
                        },
                      ),
                      4.hSizedBox,
                      // Primary instruction — the action you're approaching.
                      // Falls back to currentStep on the final (ARRIVE) step
                      // where nextStep is null.
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
                            instruction.isEmpty ? '--' : instruction,
                            maxLines: 3,
                            minFontSize: 7.spMin,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.spMin,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          );
                        },
                      ),
                      4.hSizedBox,
                      // "Continue for X km" for a driving/walking/cycling
                      // step, or "5 stops to Downtown" for a transit step —
                      // stop count matters more than distance while riding.
                      // Hidden when there's no next step or nothing to show.
                      Consumer(
                        builder: (context, ref, child) {
                          final step = ref.watch(
                            providerOfMap.select((s) => s.nextStep),
                          );
                          final transit = step?.transitDetails;
                          if (step?.travelMode == TravelMode.transit &&
                              transit?.stopCount != null) {
                            final stops = transit!.stopCount!;
                            final headsign = transit.headsign;
                            return Text(
                              '$stops stop${stops == 1 ? '' : 's'}'
                              '${headsign != null && headsign.isNotEmpty ? ' to $headsign' : ''}',
                              style: TextStyle(
                                fontSize: 10.spMin,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey,
                              ),
                            );
                          }
                          final meters = step?.distanceMeters;
                          if (meters == null || meters <= 0) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            'Continue for ${_formatDistance(meters)}',
                            style: TextStyle(
                              fontSize: 10.spMin,
                              fontWeight: FontWeight.w500,
                              color: AppColors.grey,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // THEN section — the maneuver after the upcoming one. The whole
          // block is hidden when there's no step-after-next, so the
          // primary column expands to fill the card.
          Consumer(
            builder: (context, ref, child) {
              final hasStepAfterNext = ref.watch(
                providerOfMap.select((s) => s.stepAfterNext != null),
              );
              if (!hasStepAfterNext) return const SizedBox.shrink();

              return IntrinsicHeight(
                child: Row(
                  children: [
                    _buildDivider(),
                    12.wSizedBox,
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'THEN',
                          style: TextStyle(
                            fontSize: 9.spMin,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey,
                          ),
                        ),
                        4.hSizedBox,
                        Consumer(
                          builder: (context, ref, child) {
                            final step = ref.watch(
                              providerOfMap.select(
                                (s) => s.stepAfterNext,
                              ),
                            );
                            return Icon(
                              _iconForStep(step),
                              size: 16.spMin,
                              color: const Color(0xFF888888),
                            );
                          },
                        ),
                        4.hSizedBox,
                        Consumer(
                          builder: (context, ref, child) {
                            final meters = ref.watch(
                              providerOfMap.select(
                                (s) => s.stepAfterNext?.distanceMeters,
                              ),
                            );
                            return Text(
                              _formatDistance(meters),
                              style: TextStyle(
                                fontSize: 10.spMin,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF888888),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompassButton() {
    return Consumer(
      builder: (context, ref, child) {
        final showNavigationSimulationPanel =
            kDebugMode &&
            ref.watch(
              providerOfMap.select(
                (value) => value.currentRoutePlan?.isNavigating ?? false,
              ),
            );
        if (!showNavigationSimulationPanel) {
          return const SizedBox.shrink();
        }
        return CustomCompassButton();
      },
    );
  }

  Widget _buildTakeAlternateRouteButton() {
    return Consumer(
      builder: (context, ref, child) {
        final shouldShow = ref.watch(
          providerOfMap.select(
            (s) => s.showTakeAlternateRouteButton,
          ),
        );

        // Only show button when showTakeAlternateRouteButton is true
        // (auto-hides after 10 seconds, reappears for new hazards)
        if (!shouldShow) return const SizedBox.shrink();

        return TakeAlternateRoute();
      },
    );
  }

  Widget _buildRemainingInfo() {
    return IntrinsicHeight(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(14.spMin),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 8.0,
              offset: Offset(0.0, 0.0),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 14.spMin,
          vertical: 12.spMin,
        ),
        child: Row(
          spacing: 5.spMin,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Remaining duration in minutes (or "Hh Mm" past 60).
            Consumer(
              builder: (context, ref, child) {
                final seconds = ref.watch(
                  providerOfMap.select(
                    (s) => s.remainingDurationSeconds,
                  ),
                );
                final formatted = _formatDuration(seconds);
                return _buildRemainingInfoItem(
                  value: formatted.value,
                  unit: formatted.unit,
                  label: 'REMAINING',
                );
              },
            ),
            _buildDivider(),
            // ETA (current clock time + remaining duration).
            Consumer(
              builder: (context, ref, child) {
                final seconds = ref.watch(
                  providerOfMap.select(
                    (s) => s.remainingDurationSeconds,
                  ),
                );
                final formatted = _formatEta(seconds);
                return _buildRemainingInfoItem(
                  value: formatted.time,
                  unit: formatted.meridiem,
                  label: 'ARRIVE',
                );
              },
            ),
            _buildDivider(),
            // Total remaining distance.
            Consumer(
              builder: (context, ref, child) {
                final meters = ref.watch(
                  providerOfMap.select(
                    (s) => s.remainingDistanceMeters,
                  ),
                );
                final formatted = _formatDistanceParts(meters);
                return _buildRemainingInfoItem(
                  value: formatted.value,
                  unit: formatted.unit,
                  label: 'LEFT',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemainingInfoItem({
    required final String value,
    required final String unit,
    required final String label,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15.spMin,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 10.spMin,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF888888),
          ),
        ),
        3.hSizedBox,
        Text(
          label,
          style: TextStyle(
            fontSize: 9.spMin,
            fontWeight: FontWeight.w600,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return IntrinsicHeight(
      child: Row(
        spacing: 8.spMin,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Current speed in km/h (state stores m/s).
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10.spMin,
              vertical: 8.spMin,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.spMin),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColorDark,
                  blurRadius: 8.0,
                  offset: Offset(0.0, 0.0),
                ),
              ],
            ),
            child: Center(
              child: Consumer(
                builder: (context, ref, child) {
                  final speedMps = ref.watch(
                    providerOfMap.select((s) => s.currentSpeed),
                  );
                  final kmh = (speedMps * 3.6).round();
                  return Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$kmh',
                          style: TextStyle(
                            fontSize: 13.spMin,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                        TextSpan(
                          text: ' km/h',
                          style: TextStyle(
                            fontSize: 10.spMin,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          // Speed limit indicator. Routes API doesn't return speed limits;
          // adding them would require Roads API or a tile-based source.
          // Left as a static placeholder for now.
          // Container(
          //   padding: EdgeInsets.all(8.spMin),
          //   decoration: BoxDecoration(
          //     color: AppColors.white,
          //     shape: BoxShape.circle,
          //     border: Border.all(
          //       color: AppColors.red,
          //       width: 3.0,
          //     ),
          //   ),
          //   child: Center(
          //     child: Text(
          //       '60',
          //       style: TextStyle(
          //         fontSize: 12.spMin,
          //         fontWeight: FontWeight.w700,
          //         color: AppColors.red,
          //       ),
          //     ),
          //   ),
          // ),
          // End Navigation button.
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.spMin,
                    vertical: 8.spMin,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12.spMin),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColorDark,
                        blurRadius: 8.0,
                        offset: Offset(0.0, 0.0),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.x400,
                          size: 16.spMin,
                          color: AppColors.red,
                        ),
                        5.wSizedBox,
                        Text(
                          'End Navigation',
                          style: TextStyle(
                            fontSize: 12.spMin,
                            fontWeight: FontWeight.w600,
                            color: AppColors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).onPressed(_handleEndNavigation);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1.spMin,
      decoration: BoxDecoration(
        color: AppColors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }

  void _handleEndNavigation() {
    ref.read(providerOfMap.notifier).stopNavigation();
  }
}

// ---------------------------------------------------------------------------
// Formatting helpers
// ---------------------------------------------------------------------------

/// Returns "In 400 m" / "In 1.2 km", or "In --" when no distance is known.
String _formatDistancePrefix(num? meters) {
  if (meters == null) return 'In --';
  if (meters >= 1000) return 'In ${(meters / 1000).toStringAsFixed(1)} km';
  return 'In ${meters.round()} m';
}

/// Returns "400 m" / "1.2 km", or "--" when no distance is known.
String _formatDistance(num? meters) {
  if (meters == null) return '--';
  if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
  return '${meters.round()} m';
}

/// Splits a distance into a number and a unit so it can be rendered with the
/// existing two-line value/unit layout in the remaining-info card.
({String value, String unit}) _formatDistanceParts(num? meters) {
  if (meters == null) return (value: '--', unit: '');
  if (meters >= 1000) {
    return (
      value: (meters / 1000).toStringAsFixed(1),
      unit: 'km',
    );
  }
  return (value: meters.round().toString(), unit: 'm');
}

/// Formats a remaining duration as a value/unit pair. Trips longer than an
/// hour use the *"1h 23m"* shorthand and a "time" unit instead of "min" so
/// the value stays readable inside the existing layout.
({String value, String unit}) _formatDuration(int? seconds) {
  if (seconds == null) return (value: '--', unit: '');
  final minutes = (seconds / 60).round();
  if (minutes < 60) return (value: '$minutes', unit: 'min');
  final hours = minutes ~/ 60;
  final remainingMin = minutes % 60;
  return (value: '${hours}h ${remainingMin}m', unit: 'time');
}

/// Computes the wall-clock arrival time as `now + remainingDurationSeconds`
/// and returns it split into the time portion and the meridiem so the
/// existing two-line value/unit layout can render it unchanged.
({String time, String meridiem}) _formatEta(int? seconds) {
  if (seconds == null) return (time: '--', meridiem: '');
  final eta = DateTime.now().add(Duration(seconds: seconds));
  return (
    time: DateFormat('h:mm').format(eta),
    meridiem: DateFormat('a').format(eta).toLowerCase(),
  );
}

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
