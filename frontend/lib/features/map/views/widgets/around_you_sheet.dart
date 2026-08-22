import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/map/providers/location_provider.dart';
import 'package:hazard_app/features/map/providers/map_display_settings_provider.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/utils/location_helper.dart';
import 'package:hazard_app/features/shared/views/widgets/common_hazards_list_item.dart';
import 'package:hazard_app/others/app_colors.dart';

/// Shows the light "Around You" bottom sheet (V3 map UI): the map's current
/// alerts sorted by distance from the user's location.
Future<void> showAroundYouSheet({
  required final BuildContext context,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (context) => const AroundYouSheet(),
  );
}

class AroundYouSheet extends ConsumerStatefulWidget {
  const AroundYouSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AroundYouSheetState();
}

class _AroundYouSheetState extends ConsumerState<AroundYouSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F8),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.spMin),
          topRight: Radius.circular(24.spMin),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _dragHandleBuilder()).pT(10.0),
          12.hSizedBox,
          Text(
            'AROUND YOU',
            style: TextStyle(
              fontSize: 10.5.spMin,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: AppColors.grey,
            ),
          ).pX(16.0),
          10.hSizedBox,
          Expanded(
            child: _hazardsListBuilder(),
          ),
        ],
      ),
    );
  }

  Widget _dragHandleBuilder() {
    return Container(
      width: 40.spMin,
      height: 4.spMin,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  Widget _hazardsListBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final hazards = ref.watch(
          providerOfMap.select(
            (value) => value.hazards,
          ),
        );
        final visibleSystems = ref.watch(providerOfVisibleAlertSystems);
        final userLocation = ref.watch(
          providerOfLocation.select(
            (value) => value.location,
          ),
        );

        final entries =
            hazards
                .where(
                  (hazard) =>
                      hazard.latitude != null &&
                      hazard.longitude != null &&
                      visibleSystems.contains(AlertSourceSystem.of(hazard)),
                )
                .map(
                  (hazard) => (
                    hazard: hazard,
                    distanceKm: calculateDistanceInKm(
                      userLocation.latitude,
                      userLocation.longitude,
                      hazard.latitude!,
                      hazard.longitude!,
                    ),
                  ),
                )
                .toList()
              ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

        if (entries.isEmpty) {
          return Center(
            child: Text(
              'No alerts around you right now.',
              style: TextStyle(
                fontSize: 13.spMin,
                fontWeight: FontWeight.w500,
                color: AppColors.grey,
              ),
            ),
          );
        }

        // Distance sorting stays; the rows themselves are the standard
        // alert cards used everywhere else in the app.
        return ListView.separated(
          padding: EdgeInsets.fromLTRB(0, 4.spMin, 0, 30.spMin),
          itemCount: entries.length,
          separatorBuilder: (context, index) => 15.hSizedBox,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return CommonHazardsListItem(
              key: ValueKey(entry.hazard.id),
              hazard: entry.hazard,
              horizontalPadding: 16.0,
            );
          },
        );
      },
    );
  }
}
