import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/utils/hazard_avoidance_helper.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/views/widgets/common_hazards_list_item.dart';

class MapHazardsList extends ConsumerStatefulWidget {
  const MapHazardsList({
    super.key,
    this.showOnlyRouteHazards = false,
  });

  /// Whether to show only the hazards on the current route.
  final bool showOnlyRouteHazards;

  @override
  ConsumerState<MapHazardsList> createState() => _MapHazardsListState();
}

class _MapHazardsListState extends ConsumerState<MapHazardsList> {
  @override
  Widget build(BuildContext context) {
    return _dataBuilder();
  }

  Widget _emptyBuilder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Nothing to show!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.spMin,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          widget.showOnlyRouteHazards
              ? 'There are no alerts on your current route.'
              : 'There are no alerts to display for the selected filters.',
          textAlign: TextAlign.center,
        ),
      ],
    ).pad(40.0);
  }

  Widget _dataBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final mapHazards = ref.watch(
          providerOfMap.select(
            (value) => widget.showOnlyRouteHazards
                ? HazardAvoidanceHelper.getRelevantHazardsForPolyline(
                    value.currentRoutePlan?.hazardsToAvoid ?? [],
                    value
                            .currentRoutePlan
                            ?.currentRoute
                            ?.currentRoute
                            .polylinePoints
                            ?.map((e) => LatLng(e.latitude, e.longitude))
                            .toList() ??
                        [],
                  )
                : value.hazards,
          ),
        );
        if (mapHazards.isEmpty) {
          return _emptyBuilder();
        }

        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView.separated(
            itemCount: mapHazards.length,
            itemBuilder: (context, index) {
              final hazard = mapHazards[index];
              return CommonHazardsListItem(
                key: ValueKey(hazard.id),
                hazard: hazard,
              ).pB(index == mapHazards.length - 1 ? 120.0 : 0.0);
            },
            separatorBuilder: (context, index) => 15.hSizedBox,
          ),
        );
      },
    );
  }
}
