import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/map/providers/location_provider.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/providers/map_search_text_editing_controller_provider.dart';
import 'package:hazard_app/features/map/providers/places_provider.dart';
import 'package:hazard_app/features/map/providers/states/map_provider_state.dart';
import 'package:hazard_app/features/shared/views/widgets/button.dart';
import 'package:hazard_app/features/shared/views/widgets/round_button.dart';
import 'package:hazard_app/others/app_colors.dart';

class SelectedLocationPreview extends ConsumerStatefulWidget {
  const SelectedLocationPreview({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectedLocationPreviewState();
}

class _SelectedLocationPreviewState
    extends ConsumerState<SelectedLocationPreview> {
  @override
  Widget build(BuildContext context) {
    final selectedLocation = ref.watch(
      providerOfMap.select(
        (value) => value.selectedLocation,
      ),
    );
    if (selectedLocation == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.spMin),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10.0,
            offset: Offset(0, 4.0),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.spMin),
      child: Column(
        spacing: 8.spMin,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10.spMin,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedLocation.name ?? 'Unnamed Location',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      selectedLocation.address ?? 'Unknown Address',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              RoundButton(
                icon: Icon(
                  Icons.close_rounded,
                  size: 20.spMin,
                ),
                size: 30.0,
                onPressed: _clearSelectedLocation,
              ),
            ],
          ),
          _actionButtonsBuilder(),
        ],
      ),
    );
  }

  Widget _actionButtonsBuilder() {
    return Row(
      spacing: 5.spMin,
      children: [
        Consumer(
          builder: (context, ref, child) {
            final isLoading = ref.watch(
              providerOfMap.select(
                (value) => value.getRouteState.maybeWhen(
                  orElse: () => false,
                  loading: () => true,
                ),
              ),
            );

            return _buttonBuilder(
              value: 'Get Directions',
              isLoading: isLoading,
              icon: Icon(
                Icons.directions_rounded,
                size: 20.spMin,
                color: AppColors.white,
              ),
              onPressed: _getDirections,
            );
          },
        ),
      ],
    );
  }

  Widget _buttonBuilder({
    required final String value,
    final Widget? icon,
    final void Function()? onPressed,
    final bool isLoading = false,
  }) {
    return SizedBox(
      height: 34.spMin,
      child: Button.filled(
        value: value,
        isLoading: isLoading,
        padding: EdgeInsets.symmetric(
          vertical: 0.0,
          horizontal: 20.spMin,
        ),
        valueStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        icon: icon,
        onPressed: onPressed,
      ),
    );
  }

  /// Clears the selected location in the map provider.
  void _clearSelectedLocation() {
    ref.read(providerOfPlacesForMap.notifier).updateSearchString('');
    ref.read(providerOfMap.notifier)
      ..updateSelectedLocation(null)
      ..removeSelectedLocationMarker();
    ref.read(providerOfMapSearchTextEditingController).clear();
  }

  /// Gets the directions to the selected location.
  void _getDirections() {
    final selectedLocation = ref.read(providerOfMap).selectedLocation;
    if (selectedLocation == null) return;

    final currentUserLocation = ref.read(providerOfLocation).location;

    ref
        .read(providerOfMap.notifier)
        .getRoutePlan(
          origin: currentUserLocation,
          destination: selectedLocation,
        );
  }
}
