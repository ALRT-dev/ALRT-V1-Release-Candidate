import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/providers/map_display_settings_provider.dart';
import 'package:hazard_app/features/map/views/widgets/custom_compass_button.dart';
import 'package:hazard_app/features/map/views/widgets/map_hazard_info_window.dart';
import 'package:hazard_app/features/map/views/widgets/map_rail.dart';
import 'package:hazard_app/features/map/views/widgets/map_searchbar.dart';
import 'package:hazard_app/features/map/views/widgets/navigation/navigation_mode_overlay.dart';
import 'package:hazard_app/features/map/views/widgets/navigation/navigation_route_info_cards_list.dart';
import 'package:hazard_app/features/map/views/widgets/navigation/navigation_simulation_controls.dart';
import 'package:hazard_app/features/map/views/widgets/navigation/navigation_travel_modes_list.dart';
import 'package:hazard_app/features/map/views/widgets/route_source_and_destination.dart';
import 'package:hazard_app/features/map/views/widgets/selected_location_preview.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  static const filtersKey = 'MapScreenFiltersKey';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
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
            polylines: ref.watch(
              providerOfMap.select(
                (value) => value.polylines,
              ),
            ),
            mapType: ref.watch(providerOfMapType),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: false,
            zoomControlsEnabled: false,
            padding: EdgeInsets.only(bottom: 22.spMin, left: 8.spMin),
            buildingsEnabled: ref.watch(
              providerOfMap.select(
                (value) => !(value.currentRoutePlan?.isNavigating ?? false),
              ),
            ),
            onMapCreated: (controller) {
              ref
                  .read(providerOfMap.notifier)
                  .init(googleMapController: controller);
            },
            onCameraMove: _handleMapMoved,
            onTap: (_) {
              context.unfocusInputs();
              ref.read(providerOfMap.notifier).updateSelectedHazard(null);
            },
            onLongPress: kDebugMode
                ? (final LatLng position) =>
                      NavigationSimulationControls.handleMapLongPress(
                        ref,
                        position,
                      )
                : null,
          ),
          Positioned.fill(
            child: _overlayedContentsBuilder(),
          ),
          const MapHazardInfoWindow(),
        ],
      ),
    );
  }

  Widget _overlayedContentsBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final isNavigating = ref.watch(
          providerOfMap.select(
            (value) => value.currentRoutePlan?.isNavigating ?? false,
          ),
        );
        if (isNavigating) {
          return const NavigationModeOverlay();
        }

        return SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Consumer(
                    builder: (context, ref, child) {
                      final isRoutePresent = ref.watch(
                        providerOfMap.select(
                          (value) => value.currentRoutePlan != null,
                        ),
                      );

                      if (isRoutePresent) {
                        return Column(
                          spacing: 5.spMin,
                          children: [
                            RouteSourceAndDestination().pX(20.0),
                            NavigationTravelModesList(),
                          ],
                        );
                      }
                      // A real gap below the status bar. At 18 the capsule
                      // still sat under the clock on tall screens and read
                      // as part of the system bar rather than as something
                      // floating over the map.
                      return Row(
                        children: [
                          Expanded(child: MapSearchbar()),
                        ],
                      ).pX(20.0).pT(34.0);
                    },
                  ),
                ],
              ),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final isRoutePresent = ref.watch(
                      providerOfMap.select(
                        (value) => value.currentRoutePlan != null,
                      ),
                    );

                    return Column(
                      children: [
                        // Don't show the map action buttons and view list button if a route is present
                        isRoutePresent
                            ? Expanded(
                                child: const SizedBox.shrink(),
                              )
                            : Expanded(
                                child: Stack(
                                  children: [
                                    Positioned(
                                      right: 15.spMin,
                                      bottom: 0.0,
                                      child: _mapActionButtons(),
                                    ),
                                    Positioned(
                                      right: 12.spMin,
                                      top: 0.0,
                                      bottom: 0.0,
                                      child: const Center(
                                        child: MapRail(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                        Consumer(
                          builder: (context, ref, child) {
                            final isRoutePresent = ref.watch(
                              providerOfMap.select(
                                (value) => value.currentRoutePlan != null,
                              ),
                            );
                            if (isRoutePresent) {
                              return NavigationRouteInfoCardsList().pT(10.0);
                            }

                            final isSelectedLocationPresent = ref.watch(
                              providerOfMap.select(
                                (value) => value.selectedLocation != null,
                              ),
                            );
                            if (isSelectedLocationPresent) {
                              return SelectedLocationPreview()
                                  .pT(10.0)
                                  .pX(20.0);
                            }

                            return const SizedBox();
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ).pB(30.0),
        );
      },
    );
  }

  // The V3 map rail owns layers/keys and filtering; only the compass
  // remains as a floating action.
  Widget _mapActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 10.spMin,
      children: [
        CustomCompassButton(),
      ],
    );
  }


  /// Handles the map movement by updating the camera position in the provider.
  void _handleMapMoved(CameraPosition position) {
    ref
        .read(providerOfMap.notifier)
        .updateCameraPosition(cameraPosition: position);

    EasyDebounce.debounce(
      'map-debouncer',
      const Duration(milliseconds: 300),
      () {
        if (!mounted) return;

        // Get the hazards for the new map position
        ref.read(providerOfMap.notifier).getMapHazards();

        // If route planning is active, update the hazards to avoid for the route
        ref.read(providerOfMap.notifier).getRoutePlanHazardsToAvoid();
      },
    );
  }

}
