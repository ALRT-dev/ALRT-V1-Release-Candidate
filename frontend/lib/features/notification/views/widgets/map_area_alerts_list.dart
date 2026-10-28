import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';
import 'package:hazard_app/features/home/providers/home_tab_provider.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/providers/states/map_provider_state.dart';
import 'package:hazard_app/features/notification/providers/alerts_display_provider.dart';
import 'package:hazard_app/features/notification/views/widgets/offline_banner.dart';
import 'package:hazard_app/features/profile/providers/my_location_subscriptions_provider.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/map/views/widgets/places_sheet.dart';
import 'package:hazard_app/features/shared/models/location_subscription_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/providers/community_safety_provider.dart';
import 'package:hazard_app/features/shared/views/widgets/common_hazards_list_item.dart';
import 'package:hazard_app/features/shared/views/widgets/spinner.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The Alerts tab: the alerts in the map's current view, as a list
/// (product owner, 14 Oct 2026). One list, not two: the map rail's list
/// button opens this tab, and it reads the same alerts, through the same
/// ALRT Filters, that the map is drawing. Zoom or pan the map and the list
/// follows.
///
/// Order is most serious first: the band the source stated, or the band
/// ALRT's keyword scan inferred where the agency gives none. Within a band,
/// official alerts come before community reports (which never carry a
/// severity of their own), then the newest first.
class MapAreaAlertsList extends ConsumerWidget {
  const MapAreaAlertsList({super.key});

  /// Sorted copy of [hazards], most serious first. Kept static and pure so
  /// it can be tested without a map.
  static List<Hazard> sortBySeverity(final Iterable<Hazard> hazards) {
    int bandRank(final Hazard h) =>
        h.isUserReported ? -1 : (h.severityBand?.index ?? 0);
    final sorted = hazards.toList()
      ..sort((a, b) {
        final byBand = bandRank(b).compareTo(bandRank(a));
        if (byBand != 0) return byBand;
        final aTime = a.updatedAt ?? a.createdAt;
        final bTime = b.updatedAt ?? b.createdAt;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });
    return sorted;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocked = ref.watch(providerOfBlockedUserIds);
    final hazards = ref.watch(providerOfMap.select((value) => value.hazards));
    final showSaved = ref.watch(providerOfShowSavedLocationsOnly);
    final subs = showSaved
        ? ref.watch(
            providerOfMyLocationSubscriptions
                .select((s) => s.locationSubscriptions),
          )
        : null;

    final visible = sortBySeverity(
      hazards.where((h) {
        if (h.isExpired || blocked.contains(h.reportedBy?.id)) return false;
        if (!showSaved || subs == null || subs.isEmpty) return !showSaved;
        final lat = h.latitude;
        final lng = h.longitude;
        if (lat == null || lng == null) return false;
        return subs.any(
          (sub) =>
              lat >= sub.southwestLat &&
              lat <= sub.northeastLat &&
              lng >= sub.southwestLng &&
              lng <= sub.northeastLng,
        );
      }),
    );
    // Freezed equality: the loading case has no fields, so this is a type
    // check. (This state class generates no when/maybeWhen helpers.)
    final isFirstLoad = ref.watch(
      providerOfMap.select(
        (value) =>
            value.getMapHazardsState == const GetMapHazardsState.loading(),
      ),
    );

    if (visible.isEmpty) {
      if (isFirstLoad) {
        return const SliverFillRemaining(child: Spinner());
      }
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _EmptyMapArea(
          onZoomOut: () => _zoomOut(ref),
          onOpenMap: () =>
              ref.read(providerOfHomeTab.notifier).state = HomeTab.map,
        ),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        // Offline board: "Can't update right now" with Retry on top.
        const SliverToBoxAdapter(child: OfflineAlertsCard()),
        SliverToBoxAdapter(
          child: Text(
            showSaved
                ? (visible.length == 1
                    ? '1 alert across your saved locations, grouped by place'
                    : '${visible.length} alerts across your saved locations, grouped by place')
                : (visible.length == 1
                    ? '1 alert in this map area, most serious first'
                    : '${visible.length} alerts in this map area, most serious first'),
            style: TextStyle(
              fontSize: 13.spMin,
              fontWeight: FontWeight.w500,
              color: AppColors.mediumGrey,
            ),
          ).pX(20.0).pB(12.0),
        ),
        if (showSaved && subs != null && subs.isNotEmpty)
          ..._groupedSavedLocationSlivers(visible, subs.where((s) => !s.isOwnLocation).toList())
        else
          SliverList.separated(
            itemCount: visible.length,
            itemBuilder: (context, index) {
              final hazard = visible[index];
              return CommonHazardsListItem(
                key: ValueKey(hazard.id),
                hazard: hazard,
              );
            },
            separatorBuilder: (context, index) => 20.hSizedBox,
          ),
        const SliverToBoxAdapter(child: OfflineAlertsFootnote()),
      ],
    );
  }



  List<Widget> _groupedSavedLocationSlivers(
    List<Hazard> visible,
    List<LocationSubscription> savedSubs,
  ) {
    final slivers = <Widget>[];
    var firstGroup = true;
    for (final sub in savedSubs) {
      final groupHazards = visible.where((h) {
        final lat = h.latitude;
        final lng = h.longitude;
        if (lat == null || lng == null) return false;
        return lat >= sub.southwestLat &&
            lat <= sub.northeastLat &&
            lng >= sub.southwestLng &&
            lng <= sub.northeastLng;
      }).toList();
      if (groupHazards.isEmpty) continue;
      if (!firstGroup) {
        slivers.add(SliverToBoxAdapter(child: 16.hSizedBox));
      }
      firstGroup = false;
      final title = (sub.name?.trim().isNotEmpty ?? false) ? sub.name! : 'Saved place';
      final subtitle = [
        if (sub.address?.trim().isNotEmpty ?? false) sub.address!,
        '${alertsInsideSubscription(sub, visible)} alert${alertsInsideSubscription(sub, visible) == 1 ? '' : 's'} now',
      ].join(' · ');
      slivers.add(
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 17.spMin,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              4.hSizedBox,
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13.spMin,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mediumGrey,
                ),
              ),
            ],
          ).pX(20.0).pB(12.0),
        ),
      );
      slivers.add(
        SliverList.separated(
          itemCount: groupHazards.length,
          itemBuilder: (context, index) {
            final hazard = groupHazards[index];
            return CommonHazardsListItem(
              key: ValueKey('${sub.id}-${hazard.id}'),
              hazard: hazard,
            );
          },
          separatorBuilder: (context, index) => 20.hSizedBox,
        ),
      );
    }
    return slivers;
  }

  /// Widens the map view by two zoom levels and reloads, so the list fills
  /// from a bigger area without leaving the Alerts tab.
  Future<void> _zoomOut(final WidgetRef ref) async {
    final notifier = ref.read(providerOfMap.notifier);
    final camera = ref.read(providerOfMap).cameraPosition;
    await notifier.animateTo(
      position: camera.target,
      zoom: (camera.zoom - 2).clamp(3.0, 21.0),
    );
    await notifier.getMapHazards();
  }
}

class _EmptyMapArea extends StatelessWidget {
  const _EmptyMapArea({required this.onZoomOut, required this.onOpenMap});

  final VoidCallback onZoomOut;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 12.spMin,
      children: [
        Icon(LucideIcons.mapPinned, size: 36.spMin, color: AppColors.ink),
        Text(
          'No alerts in this map area',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17.spMin, fontWeight: FontWeight.w700),
        ),
        Text(
          'This list shows what the map is showing. Zoom out to see a wider '
          'area, or check your filters.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.spMin, color: AppColors.mediumGrey),
        ),
        4.hSizedBox,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10.spMin,
          children: [
            _pill(label: 'Zoom out', filled: true, onTap: onZoomOut),
            _pill(label: 'Open the map', filled: false, onTap: onOpenMap),
          ],
        ),
      ],
    ).pX(32.0);
  }

  Widget _pill({
    required final String label,
    required final bool filled,
    required final VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: Container(
        constraints: BoxConstraints(minHeight: 44.spMin),
        padding: EdgeInsets.symmetric(horizontal: 18.spMin),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? AppColors.ink : AppColors.white,
          borderRadius: BorderRadius.circular(22.spMin),
          border: Border.all(
            color: filled ? AppColors.ink : AppColors.lightGrey,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.spMin,
            fontWeight: FontWeight.w600,
            color: filled ? AppColors.white : AppColors.ink,
          ),
        ),
      ).onPressed(onTap),
    );
  }
}
