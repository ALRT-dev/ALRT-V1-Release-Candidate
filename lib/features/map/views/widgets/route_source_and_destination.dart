import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/map/providers/location_provider.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/providers/map_search_text_editing_controller_provider.dart';
import 'package:hazard_app/features/map/views/screens/select_location_screen.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

class RouteSourceAndDestination extends ConsumerStatefulWidget {
  const RouteSourceAndDestination({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RouteSourceAndDestinationState();
}

class _RouteSourceAndDestinationState
    extends ConsumerState<RouteSourceAndDestination> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.spMin),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10.0,
            offset: Offset(0.0, 0.0),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 20.spMin,
        vertical: 15.spMin,
      ),
      child: Row(
        spacing: 15.spMin,
        children: [
          _iconsBuilder(),
          Expanded(
            child: _locationsBuilder(),
          ),
        ],
      ),
    );
  }

  Widget _iconsBuilder() {
    return Column(
      spacing: 2.spMin,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.blue.withValues(alpha: 0.2),
          ),
          padding: EdgeInsets.all(4.spMin),
          child: Icon(
            Icons.circle,
            size: 12.spMin,
            color: AppColors.blue,
          ),
        ),
        Container(
          width: 2.spMin,
          height: 15.spMin,
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(10.r),
          ),
        ).pY(5.0),
        Icon(
          Icons.location_on,
          size: 16.spMin,
          color: AppColors.red,
        ).pB(4.0),
      ],
    );
  }

  Widget _locationsBuilder() {
    final origin = ref.watch(
      providerOfMap.select(
        (value) => value.currentRoutePlan?.origin,
      ),
    );
    final destination = ref.watch(
      providerOfMap.select(
        (value) => value.currentRoutePlan?.destination,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (origin != null)
          _locationItemBuilder(origin)
              .pB(14.0)
              .onPressed(
                () => _handleLocationSelection(
                  location: origin,
                  isSelectingOrigin: true,
                ),
              ),
        Divider(
          height: 0.0,
          color: AppColors.lightGrey,
        ),
        if (destination != null)
          _locationItemBuilder(destination)
              .pT(14.0)
              .onPressed(
                () => _handleLocationSelection(
                  location: destination,
                  isSelectingOrigin: false,
                ),
              ),
      ],
    );
  }

  Widget _locationItemBuilder(final AlrtLocation location) {
    return Consumer(
      builder: (context, ref, child) {
        final currentUserLocation = ref.read(
          providerOfLocation.select(
            (value) => value.location,
          ),
        );

        return SizedBox(
          width: double.infinity,
          child: Text(
            location == currentUserLocation
                ? 'Your Location'
                : location.displayName,
            style: TextStyle(
              fontSize: 14.spMin,
              color: AppColors.black,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }

  /// Navigate to select location screen with the given [location].
  void _handleLocationSelection({
    required final AlrtLocation location,
    final bool isSelectingOrigin = false,
  }) async {
    final selectedLocation = await context.push(
      SelectLocationScreen.route,
      extra: SelectLocationScreenArgs(
        initialLocation: location,
      ),
    );
    if (!mounted) return;
    if (selectedLocation != null && selectedLocation is AlrtLocation) {
      final origin = isSelectingOrigin
          ? selectedLocation
          : ref.read(
              providerOfMap.select(
                (value) => value.currentRoutePlan?.origin,
              ),
            );
      final destination = !isSelectingOrigin
          ? selectedLocation
          : ref.read(
              providerOfMap.select(
                (value) => value.currentRoutePlan?.destination,
              ),
            );
      if (origin == null || destination == null) return;

      ref.read(providerOfMap.notifier)
        ..getRoutePlan(origin: origin, destination: destination)
        ..updateSelectedLocation(destination)
        ..addSelectedLocationMarker(destination.latLng);
      ref.read(providerOfMapSearchTextEditingController).text =
          destination.name ?? destination.address ?? '';
    }
  }
}
