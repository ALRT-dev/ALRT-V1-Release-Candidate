import 'dart:async';

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/notification/providers/accessible_alerts_provider.dart';
import 'package:hazard_app/features/notification/views/screens/accessible_alerts_screen.dart';
import 'package:hazard_app/features/notification/views/screens/manage_notifications_screen.dart';
import 'package:hazard_app/features/profile/providers/my_location_subscriptions_provider.dart';
import 'package:hazard_app/features/profile/providers/safety_profile_provider.dart';
import 'package:hazard_app/features/profile/providers/widget_step_provider.dart';
import 'package:hazard_app/features/profile/views/screens/add_widget_screen.dart';
import 'package:hazard_app/features/profile/views/screens/safety_profile_screen.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// "Finish setting up" on the Map (product owner, 12 Oct 2026): the same
/// four steps as the Me tab's card, as a row of small cards just above the
/// footer. Each step is done by exactly the rule profile_screen.dart uses:
/// a saved place other than where you are, a safety profile with at least
/// one cohort, sound and vibration turned up, and the home screen widget
/// (done once the user has opened that step; Android only, because the iOS
/// widget target is not in the Xcode project yet).
///
/// The strip waits until the Safety Profile and the widget flag have been
/// read from the device, so it never flashes a step that is already done.
/// It disappears once every step is done, and while a route is being
/// planned or navigated so the route cards keep the floor.
class MapFinishSetupStrip extends ConsumerWidget {
  const MapFinishSetupStrip({super.key});

  static const _label = Color(0xFF3A3A42);
  static const _doneTile = Color(0xFFE6F7EC);
  static const _done = AppColors.green;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRouting = ref.watch(
      providerOfMap.select((value) => value.currentRoutePlan != null),
    );
    if (isRouting) return const SizedBox.shrink();
    // A picked place has its own card at the bottom; keep the floor clear.
    final hasPickedPlace = ref.watch(
      providerOfMap.select((value) => value.selectedLocation != null),
    );
    if (hasPickedPlace) return const SizedBox.shrink();

    final savedPlace = ref.watch(
      providerOfMyLocationSubscriptions.select(
        (s) => s.locationSubscriptions.any((l) => !l.isOwnLocation),
      ),
    );
    final safetyProfile = ref.watch(
      providerOfSafetyProfile.select((cohorts) => cohorts.isNotEmpty),
    );
    final accessibleAlerts = ref.watch(
      providerOfAccessibleAlerts.select(
        (s) => s.strongVibration || s.readAloud,
      ),
    );
    final profileLoaded = ref.watch(providerOfSafetyProfileLoaded);
    final widgetStep = ref.watch(providerOfWidgetStep);
    // Safety Profile and the widget flag read asynchronously from the
    // device; until both are in, every step would look open.
    if (!profileLoaded || !widgetStep.loaded) return const SizedBox.shrink();

    final showWidgetStep = widgetStepAvailableOn(defaultTargetPlatform);
    final widgetAdded = !showWidgetStep || widgetStep.done;
    final total = showWidgetStep ? 4 : 3;

    final done = (savedPlace ? 1 : 0) +
        (safetyProfile ? 1 : 0) +
        (accessibleAlerts ? 1 : 0) +
        (showWidgetStep && widgetStep.done ? 1 : 0);
    if (savedPlace && safetyProfile && accessibleAlerts && widgetAdded) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 10.spMin),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.spMin),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'FINISH SETTING UP',
                  style: TextStyle(
                    fontSize: 12.spMin,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: _label,
                  ),
                ),
              ),
              Text(
                '$done of $total done',
                style: TextStyle(
                  fontSize: 12.spMin,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: _label,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.spMin),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 20.spMin),
          child: Row(
            children: [
              // Finished steps drop out; only the open ones are shown.
              if (!savedPlace) ...[
                _cardBuilder(
                  icon: LucideIcons.mapPin,
                  label: 'Save a place',
                  done: false,
                  onTap: () => context.push(
                    ManageNotificationsScreen.route,
                    extra: const ManageNotificationsScreenArgs(initialTab: 1),
                  ),
                ),
                SizedBox(width: 10.spMin),
              ],
              if (!safetyProfile) ...[
                _cardBuilder(
                  icon: LucideIcons.shield,
                  label: 'Safety profile',
                  done: false,
                  onTap: () => context.push(SafetyProfileScreen.route),
                ),
                SizedBox(width: 10.spMin),
              ],
              if (!accessibleAlerts) ...[
                _cardBuilder(
                  icon: LucideIcons.volume2,
                  label: 'Sound and vibration',
                  done: false,
                  onTap: () => context.push(AccessibleAlertsScreen.route),
                ),
                SizedBox(width: 10.spMin),
              ],
              if (!widgetAdded)
                _cardBuilder(
                  icon: LucideIcons.layoutGrid,
                  label: 'Add a widget',
                  done: false,
                  onTap: () {
                    // Opening the step finishes it for good.
                    unawaited(ref.read(providerOfWidgetStep.notifier).markDone());
                    context.push(AddWidgetScreen.route);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// One 120 x 70 card: the orange outline icon top-left, the label
  /// bottom-left. Done cards go pale green with a green check.
  Widget _cardBuilder({
    required final IconData icon,
    required final String label,
    required final bool done,
    required final VoidCallback onTap,
  }) {
    return Container(
      width: 120.spMin,
      height: 70.spMin,
      padding: EdgeInsets.all(10.spMin),
      decoration: BoxDecoration(
        color: done ? _doneTile : AppColors.white,
        borderRadius: BorderRadius.circular(14.spMin),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            done ? LucideIcons.check : icon,
            size: 20.spMin,
            color: done ? _done : AppColors.orange,
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.spMin,
              fontWeight: FontWeight.w700,
              height: 1.1,
              color: done ? _done : AppColors.black,
            ),
          ),
        ],
      ),
    ).onPressed(onTap);
  }
}
