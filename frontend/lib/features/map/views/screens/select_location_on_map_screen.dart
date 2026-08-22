import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/map/providers/location_provider.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/providers/states/map_provider_state.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/utils/location_helper.dart';
import 'package:hazard_app/features/shared/views/widgets/round_button.dart';
import 'package:hazard_app/features/shared/views/widgets/spinner.dart';
import 'package:hazard_app/others/app_colors.dart';

class SelectLocationOnMapScreenArgs {
  SelectLocationOnMapScreenArgs({
    this.initialLocation,
    this.getSubUrbOnly = false,
    this.centerLocation,
    this.radiusInMeters,
  });

  /// The initial location to center the map on.
  final AlrtLocation? initialLocation;

  /// Whether to get only the suburb part of the address.
  final bool getSubUrbOnly;

  /// The center location for radius constraint.
  /// If provided with [radiusInMeters], only locations within the radius can be selected.
  final AlrtLocation? centerLocation;

  /// The radius in meters for location selection constraint.
  /// If provided with [centerLocation], only locations within this radius can be selected.
  final double? radiusInMeters;

  /// Whether radius constraint is enabled.
  bool get hasRadiusConstraint =>
      centerLocation != null && radiusInMeters != null;
}

class SelectLocationOnMapScreen extends ConsumerStatefulWidget {
  const SelectLocationOnMapScreen({
    super.key,
    this.args,
  });

  final SelectLocationOnMapScreenArgs? args;

  static const route = '/select-location-on-map';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectLocationOnMapScreenState();
}

class _SelectLocationOnMapScreenState
    extends ConsumerState<SelectLocationOnMapScreen> {
  @override
  Widget build(BuildContext context) {
    _listenToGetAddressFromCoordinatesState();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          _doneButtonBuilder(),
          15.wSizedBox,
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: ref.read(
          providerOfMap.select(
            (value) => value.cameraPosition,
          ),
        ),
        markers: ref.watch(
          providerOfMap.select(
            (value) => value.markers,
          ),
        ),
        circles: widget.args?.hasRadiusConstraint ?? false
            ? {
                Circle(
                  circleId: const CircleId('radius-constraint'),
                  center: LatLng(
                    widget.args!.centerLocation!.latitude,
                    widget.args!.centerLocation!.longitude,
                  ),
                  radius: widget.args!.radiusInMeters!,
                  fillColor: AppColors.blue.withValues(alpha: 0.1),
                  strokeColor: AppColors.blue.withValues(alpha: 0.5),
                  strokeWidth: 2,
                ),
              }
            : {},
        myLocationEnabled: true,
        onMapCreated: (controller) {
          ref
              .read(providerOfMap.notifier)
              .init(googleMapController: controller);
          _onInit();
        },
        onTap: _handleMapTapped,
      ),
    );
  }

  Widget _doneButtonBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final isLoading = ref.watch(
          providerOfMap.select(
            (value) => value.getAddressFromCoordinatesState.maybeWhen(
              loading: () => true,
              orElse: () => false,
            ),
          ),
        );
        return RoundButton(
          icon: isLoading ? Spinner(size: 15.0) : Icon(Icons.check_rounded),
          onPressed: () {
            final marker = ref
                .read(providerOfMap)
                .markers
                .firstWhere(
                  (marker) => marker.markerId.value == 'selected-location',
                );
            final position = marker.position;

            // Validate radius constraint
            if (widget.args?.hasRadiusConstraint ?? false) {
              final distance = calculateDistanceInMeters(
                widget.args!.centerLocation!.latitude,
                widget.args!.centerLocation!.longitude,
                position.latitude,
                position.longitude,
              );

              if (distance > widget.args!.radiusInMeters!) {
                final radiusInKm = (widget.args!.radiusInMeters! / 1000)
                    .toStringAsFixed(1);
                final distanceText = distance < 1000
                    ? '${distance.toStringAsFixed(0)} m'
                    : '${(distance / 1000).toStringAsFixed(1)} km';
                context.showErrorToast(
                  message:
                      'Selected location is $distanceText away. Please select within $radiusInKm km.',
                );
                return;
              }
            }

            ref
                .read(providerOfMap.notifier)
                .getAddressFromCoordinates(
                  coordinates: position,
                  getSubUrbOnly: widget.args?.getSubUrbOnly ?? false,
                );
          },
        );
      },
    );
  }

  void _onInit() {
    final currentLocation = ref.read(providerOfLocation).location;
    final initialLocation =
        widget.args?.initialLocation ??
        AlrtLocation(
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude,
        );

    ref
        .read(providerOfMap.notifier)
        .animateTo(
          position: LatLng(
            initialLocation.latitude,
            initialLocation.longitude,
          ),
        );
    ref.read(providerOfMap.notifier).updateMarkers({
      Marker(
        markerId: const MarkerId('selected-location'),
        position: LatLng(
          initialLocation.latitude,
          initialLocation.longitude,
        ),
      ),
    });
  }

  /// Listens to changes in the getAddressFromCoordinatesState and shows a
  void _listenToGetAddressFromCoordinatesState() {
    ref.listen(
      providerOfMap.select(
        (value) => value.getAddressFromCoordinatesState,
      ),
      (previous, next) {
        next.maybeWhen(
          success: context.pop,
          error: _handleErrors,
          orElse: () {},
        );
      },
    );
  }

  /// Handles errors by showing a toast message.
  void _handleErrors(final AppError error) {
    context.showErrorToast(message: error.message);
  }

  /// Handles the map tap by updating the marker position in the provider.
  void _handleMapTapped(final LatLng position) {
    final isLoading = ref.read(
      providerOfMap.select(
        (value) => value.getAddressFromCoordinatesState.maybeWhen(
          loading: () => true,
          orElse: () => false,
        ),
      ),
    );
    if (isLoading) return;

    // Validate radius constraint
    if (widget.args?.hasRadiusConstraint ?? false) {
      final distance = calculateDistanceInMeters(
        widget.args!.centerLocation!.latitude,
        widget.args!.centerLocation!.longitude,
        position.latitude,
        position.longitude,
      );

      if (distance > widget.args!.radiusInMeters!) {
        final radiusInKm = (widget.args!.radiusInMeters! / 1000)
            .toStringAsFixed(1);
        final distanceText = distance < 1000
            ? '${distance.toStringAsFixed(0)} m'
            : '${(distance / 1000).toStringAsFixed(1)} km';
        context.showErrorToast(
          message:
              'You can only select locations within $radiusInKm km. Selected location is $distanceText away.',
          autoCloseDuration: Duration(seconds: 6),
        );
        return;
      }
    }

    ref.read(providerOfMap.notifier).updateMarkers({
      Marker(
        markerId: const MarkerId('selected-location'),
        position: position,
      ),
    });
  }
}
