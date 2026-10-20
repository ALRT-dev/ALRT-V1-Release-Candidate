import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/notification/providers/notifications_feed_provider.dart';
import 'package:hazard_app/features/notification/providers/states/notifications_feed_provider_state.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/views/widgets/common_hazards_list_item.dart';
import 'package:hazard_app/features/shared/views/widgets/spinner.dart';

/// The main Alerts feed list — shows all hazards currently visible on the
/// map, sorted by severity (critical first) then most recent.
///
/// This replaces the old subscription-only feed so the user always sees
/// what is actually on the map without needing a saved location first.
/// Saved-location alerts are reachable via the 'My saved location alerts'
/// pill in the app bar, which opens [SavedLocationHazardsList].
class HazardNotificationsList extends ConsumerWidget {
  const HazardNotificationsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read the hazards already loaded by the map provider — no extra API call.
    final mapHazards = ref.watch(
      providerOfMap.select((s) => s.hazards),
    );

    final sorted = [...mapHazards]
      ..sort((a, b) {
        // Higher severity band index = more serious = show first.
        final aIdx = a.severityBand?.index ?? 0;
        final bIdx = b.severityBand?.index ?? 0;
        if (bIdx != aIdx) return bIdx.compareTo(aIdx);
        // Same severity: most recently updated first.
        final aTime = a.updatedAt ?? a.createdAt ?? DateTime(2000);
        final bTime = b.updatedAt ?? b.createdAt ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });

    if (sorted.isEmpty) {
      return _emptyBuilder();
    }

    return SliverList.separated(
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final hazard = sorted[index];
        return CommonHazardsListItem(
          key: ValueKey(hazard.id),
          hazard: hazard,
        );
      },
      separatorBuilder: (context, index) => 20.hSizedBox,
    );
  }

  Widget _emptyBuilder() {
    return SliverFillRemaining(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children: [
          SvgPicture.asset(
            'assets/icons/notifications_tab_unselected.svg',
            width: 40,
          ),
          Column(
            spacing: 5,
            children: [
              Text(
                'No alerts in this area',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Move the map to an area with alerts, or zoom out to see more.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ).pad(20.0),
    );
  }
}

/// The subscription-based (saved locations) alerts list, shown in the
/// 'My saved location alerts' bottom sheet.
class SavedLocationHazardsList extends ConsumerStatefulWidget {
  const SavedLocationHazardsList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SavedLocationHazardsListState();
}

class _SavedLocationHazardsListState
    extends ConsumerState<SavedLocationHazardsList> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      providerOfNotificationsFeed.select(
        (value) => value.getNotificationsFeedHazardsState,
      ),
    );

    return state.maybeWhen(
      loading: () => SliverFillRemaining(child: Spinner()),
      success: (_) => _dataBuilder(),
      error: (_) => SliverFillRemaining(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Something went wrong.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              'Unable to load your saved location alerts. Please try again.',
              textAlign: TextAlign.center,
            ),
          ],
        ).pad(20.0),
      ),
      orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }

  Widget _dataBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final hazards = ref.watch(
          providerOfNotificationsFeed.select((value) => value.hazards),
        );

        if (hazards.isEmpty) {
          return SliverFillRemaining(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                SvgPicture.asset(
                  'assets/icons/notifications_tab_unselected.svg',
                  width: 40,
                ),
                Column(
                  spacing: 5,
                  children: [
                    Text(
                      'No alerts for your saved locations',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Add a saved location in Notifications to get alerts for that area.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ).pad(20.0),
          );
        }

        return SliverList.separated(
          itemCount: hazards.length,
          itemBuilder: (context, index) {
            final hazard = hazards[index];
            return CommonHazardsListItem(
              key: ValueKey(hazard.id),
              hazard: hazard,
            );
          },
          separatorBuilder: (context, index) => 20.hSizedBox,
        );
      },
    );
  }
}
