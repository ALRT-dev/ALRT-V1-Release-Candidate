import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hazard_app/features/home/widgets/home_tabbar.dart';
import 'package:hazard_app/features/shared/providers/states/hazard_filters_provider_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/providers/map_display_settings_provider.dart';
import 'package:hazard_app/features/map/views/widgets/map_finish_setup_strip.dart';
import 'package:hazard_app/features/map/views/widgets/map_hazard_info_window.dart';
import 'package:hazard_app/features/map/views/widgets/map_rail.dart';
import 'package:hazard_app/features/map/views/widgets/map_searchbar.dart';
import 'package:hazard_app/features/map/views/widgets/map_warnings_banner.dart';
import 'package:hazard_app/features/map/views/widgets/navigation/navigation_mode_overlay.dart';
import 'package:hazard_app/features/map/views/widgets/navigation/navigation_route_info_cards_list.dart';
import 'package:hazard_app/features/map/views/widgets/navigation/navigation_simulation_controls.dart';
import 'package:hazard_app/features/map/views/widgets/navigation/navigation_travel_modes_list.dart';
import 'package:hazard_app/features/map/views/widgets/route_source_and_destination.dart';
import 'package:hazard_app/features/map/views/widgets/selected_location_preview.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/map/utils/maps_availability.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  static const filtersKey = kSharedAlertFiltersKey;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  @override
  void initState() {
    super.initState();
    // With a map, the first camera move loads the alerts. Without one
    // nothing moves, so load the alerts around the person once here.
    if (!MapsAvailability.available) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(providerOfMap.notifier).getMapHazards();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // The map fills the page under the floating footer; the cards, the
    // Google logo and the finish-setup strip sit above it.
    final footerClearance = MediaQuery.of(context).padding.bottom +
        HomeTabbar.height -
        20.0;
    return Scaffold(
      body: Stack(
        children: [
          MapsAvailability.available
              ? GoogleMap(
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
                  padding: EdgeInsets.only(
                    bottom: footerClearance + 22.spMin,
                    left: 8.spMin,
                  ),
                  buildingsEnabled: ref.watch(
                    providerOfMap.select(
                      (value) =>
                          !(value.currentRoutePlan?.isNavigating ?? false),
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
                )
              : const MapUnavailable(),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(bottom: footerClearance),
              child: _overlayedContentsBuilder(),
            ),
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

        return Stack(
          children: [
            _safeAreaContentsBuilder(),
            _railBuilder(),
          ],
        );
      },
    );
  }

  /// The search bar, warnings banner and the bottom cards.
  Widget _safeAreaContentsBuilder() {
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
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: MapSearchbar()),
                        ],
                      ).pX(20.0).pT(34.0),
                      SizedBox(height: 8.spMin),
                      const MapWarningsBanner().pX(20.0),
                    ],
                  );
                },
              ),
            ],
          ),
          Expanded(
            child: Column(
              children: [
                // The rail is positioned against the screen in
                // _railBuilder; this spacer keeps the cards below
                // pinned to the bottom.
                const Expanded(child: SizedBox.shrink()),
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
                      return SelectedLocationPreview().pT(10.0).pX(20.0);
                    }

                    return const SizedBox();
                  },
                ),
                // "Finish setting up" sits under the bottom cards, just
                // above the footer. It hides itself when all four steps
                // are done and while a route is planned or navigated.
                const MapFinishSetupStrip(),
              ],
            ),
          ),
        ],
      ).pB(30.0),
    );
  }

  /// The white rail on the right edge, 280 logical px from the top of the
  /// screen (prototype board "Main", 9 Oct 2026). Hidden while a route is
  /// being planned; navigation mode has its own overlay.
  Widget _railBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final isRoutePresent = ref.watch(
          providerOfMap.select(
            (value) => value.currentRoutePlan != null,
          ),
        );
        if (isRoutePresent) {
          return const SizedBox.shrink();
        }

        return Positioned(
          right: 16.spMin,
          top: 280.spMin,
          child: const MapRail(),
        );
      },
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
