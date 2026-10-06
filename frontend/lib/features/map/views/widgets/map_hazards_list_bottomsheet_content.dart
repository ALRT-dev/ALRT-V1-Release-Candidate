import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/views/screens/map_screen.dart';
import 'package:hazard_app/features/map/views/widgets/map_hazards_list.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/providers/hazard_filters_provider.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/features/shared/views/widgets/button.dart';
import 'package:hazard_app/others/app_colors.dart';

class MapHazardsListBottomsheetContent extends ConsumerStatefulWidget {
  const MapHazardsListBottomsheetContent({
    super.key,
    this.showOnlyRouteHazards = false,
  });

  /// Whether to show only the hazards on the current route.
  final bool showOnlyRouteHazards;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MapHazardsListBottomsheetContentState();
}

class _MapHazardsListBottomsheetContentState
    extends ConsumerState<MapHazardsListBottomsheetContent> {
  var _safeAreaTopPadding = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _safeAreaTopPadding = MediaQuery.of(context).padding.top;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                _safeAreaTopPadding.hSizedBox,
                if (!widget.showOnlyRouteHazards)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _listFiltersButtonBuilder().pX(20.0),
                    ],
                  ),
                10.hSizedBox,
                Expanded(
                  child: MapHazardsList(
                    showOnlyRouteHazards: widget.showOnlyRouteHazards,
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0.0,
              left: 0.0,
              bottom: 80.spMin,
              child: _viewMapButtonBuilder(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _viewMapButtonBuilder() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 50.spMin,
          width: 140.spMin,
          child: Button.filled(
            onPressed: Navigator.of(context).pop,
            borderRadius: 50.0,
            color: const Color(0xFF3A3A3A),
            icon: Icon(
              Icons.map_rounded,
              size: 22.0,
              color: AppColors.white,
            ),
            value: 'View Map',
            valueStyle: TextStyle(
              color: AppColors.white,
            ),
            elevation: 3.0,
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _listFiltersButtonBuilder() {
    return Stack(
      children: [
        Button.filled(
          width: 120.spMin,
          onPressed: () {
            showHazardFiltersBottomSheet(
              context: context,
              filtersKey: MapScreen.filtersKey,
              onFiltersUpdated: () => _getMapHazards(),
            );
          },
          borderRadius: 50.0,
          color: AppColors.white,
          icon: Icon(
            Icons.filter_list,
            size: 22.0,
            color: AppColors.black,
          ),
          value: 'Filters',
          valueStyle: TextStyle(
            color: AppColors.black,
          ),
          elevation: 3.0,
          padding: EdgeInsets.zero,
        ),
        Positioned(
          right: 0,
          child: _countBuilder(),
        ),
      ],
    );
  }

  Widget _countBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final count = ref.watch(
          providerOfHazardFiltersForMap.select(
            (value) => value.unselectedFiltersCount,
          ),
        );
        if (count == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          width: 20.spMin,
          height: 20.spMin,
          decoration: BoxDecoration(
            color: AppColors.red,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12.spMin,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        );
      },
    );
  }

  /// Fetches the hazards for the current map view.
  void _getMapHazards() {
    ref.read(providerOfMap.notifier).getMapHazards();

    // also update the hazards to avoid for the route if route planning is active
    ref.read(providerOfMap.notifier).getRoutePlanHazardsToAvoid();
  }
}
