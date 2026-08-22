import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/views/widgets/navigation/navigation_travel_modes_list_item.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';

class NavigationTravelModesList extends ConsumerStatefulWidget {
  const NavigationTravelModesList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NavigationTravelModesListState();
}

class _NavigationTravelModesListState
    extends ConsumerState<NavigationTravelModesList> {
  @override
  Widget build(BuildContext context) {
    final travelModeRoutes = ref.watch(
      providerOfMap.select(
        (value) => value.currentRoutePlan?.travelModeRoutes ?? {},
      ),
    );

    return SizedBox(
      height: 40.spMin,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.spMin),
        itemCount: travelModeRoutes.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final travelMode = travelModeRoutes.keys.toList()[index];
          final route = travelModeRoutes[travelMode]!;

          return NavigationTravelModesListItem(
            travelMode: travelMode,
            route: route,
          );
        },
        separatorBuilder: (context, index) => 10.wSizedBox,
      ),
    );
  }
}
