import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';

/// Debug-only desk-testing controls: toggle simulated GPS, nudge position,
/// advance along the route, and long-press teleport (wired from [MapScreen]).
///
/// Renders nothing in release/profile builds.
///
/// Only mount this widget while navigation is active ([MapScreen] adds it to
/// the stack conditionally) so the stack never holds a zero-sized [Positioned]
/// hit target.
class NavigationSimulationControls extends ConsumerWidget {
  const NavigationSimulationControls({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    if (!kDebugMode) return const SizedBox.shrink();

    final simEnabled = ref.watch(
      providerOfMap.select((final s) => s.navigationSimulationEnabled),
    );
    final notifier = ref.read(providerOfMap.notifier);

    return SizedBox(
      width: 147.spMin,
      child: Material(
        color: const Color(0xE6252525),
        borderRadius: BorderRadius.circular(12.spMin),
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(8.spMin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: notifier.toggleNavigationSimulation,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.spMin,
                          vertical: 6.spMin,
                        ),
                        decoration: BoxDecoration(
                          color: simEnabled
                              ? Colors.orange.withValues(alpha: 0.35)
                              : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8.spMin),
                        ),
                        child: Center(
                          child: Text(
                            simEnabled
                                ? 'Sim ON (GPS paused)'
                                : 'Sim OFF — tap to enable',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.spMin,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (simEnabled) ...[
                6.hSizedBox,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 36.spMin,
                      height: 36.spMin,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          size: 22.spMin,
                          color: Colors.white,
                        ),
                        onPressed: notifier.simulateNavigationNudgeWest,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 36.spMin,
                          height: 36.spMin,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.arrow_upward_rounded,
                              size: 22.spMin,
                              color: Colors.white,
                            ),
                            onPressed: notifier.simulateNavigationNudgeNorth,
                          ),
                        ),
                        SizedBox(
                          width: 36.spMin,
                          height: 36.spMin,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.arrow_downward_rounded,
                              size: 22.spMin,
                              color: Colors.white,
                            ),
                            onPressed: notifier.simulateNavigationNudgeSouth,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 36.spMin,
                      height: 36.spMin,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.arrow_forward_rounded,
                          size: 22.spMin,
                          color: Colors.white,
                        ),
                        onPressed: notifier.simulateNavigationNudgeEast,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orangeAccent,
                    padding: EdgeInsets.symmetric(vertical: 4.spMin),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => notifier.simulateAdvanceAlongRoute(5),
                  child: Text(
                    '+${5.round()} m along route',
                    style: TextStyle(fontSize: 11.spMin),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orangeAccent,
                    padding: EdgeInsets.symmetric(vertical: 4.spMin),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => notifier.simulateAdvanceAlongRoute(10),
                  child: Text(
                    '+${10.round()} m along route',
                    style: TextStyle(fontSize: 11.spMin),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orangeAccent,
                    padding: EdgeInsets.symmetric(vertical: 4.spMin),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => notifier.simulateAdvanceAlongRoute(100),
                  child: Text(
                    '+${100.round()} m along route',
                    style: TextStyle(fontSize: 11.spMin),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Long-press handler for [GoogleMap]; pass from map screen when debug + navigating + sim on.
  static void handleMapLongPress(final WidgetRef ref, final LatLng position) {
    if (!kDebugMode) return;
    final navigating = ref.read(
      providerOfMap.select(
        (final s) => s.currentRoutePlan?.isNavigating ?? false,
      ),
    );
    final sim = ref.read(
      providerOfMap.select((final s) => s.navigationSimulationEnabled),
    );
    if (!navigating || !sim) return;
    ref
        .read(providerOfMap.notifier)
        .simulateTeleportToNavigationLocation(position);
  }
}
