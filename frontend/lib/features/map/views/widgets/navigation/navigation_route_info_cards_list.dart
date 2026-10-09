import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/views/widgets/navigation/navigation_route_info_cards_list_item.dart';
import 'package:hazard_app/features/map/views/widgets/navigation/start_navigation_button.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';

class NavigationRouteInfoCardsList extends ConsumerStatefulWidget {
  const NavigationRouteInfoCardsList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NavigationRouteInfoCardsListState();
}

class _NavigationRouteInfoCardsListState
    extends ConsumerState<NavigationRouteInfoCardsList> {
  @override
  Widget build(BuildContext context) {
    final allRoutes = ref.watch(
      providerOfMap.select(
        (value) => value.currentRoutePlan?.currentRoute?.allRoutes ?? [],
      ),
    );

    return Column(
      children: [
        SizedBox(
          height: 130.spMin,
          child: ListView.separated(
            itemCount: allRoutes.length,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: 16.spMin,
              vertical: 8.spMin,
            ),
            itemBuilder: (context, index) => NavigationRouteInfoCardsListItem(
              route: allRoutes[index],
            ),
            separatorBuilder: (context, index) => 8.wSizedBox,
          ),
        ),
        StartNavigationButton().pX(20.0),
      ],
    );
  }
}
