import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show appFlavor;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/map/providers/location_provider.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/providers/states/map_provider_state.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';

/// Test builds (flavour "dev") show the real reason directions failed, so a
/// tester can see "API key not authorised for Routes API" and fix the Google
/// Cloud setting. Live builds keep the plain message.
bool get showRawDirectionsErrors => appFlavor == 'dev' || kDebugMode;

/// Puts [destination] on the map as the selected place (marker + camera),
/// the same as choosing it from search.
void selectPlaceOnMap(final WidgetRef ref, final AlrtLocation destination) {
  final map = ref.read(providerOfMap.notifier)
    ..updateSelectedLocation(destination)
    ..updateSelectedHazard(null);
  unawaited(map.animateTo(position: destination.latLng, zoom: 14.0));
  map.addSelectedLocationMarker(destination.latLng);
}

/// The plain words for a failed directions request ([failure] is the raw
/// error the Routes API call returned). Test builds add the raw reason.
String directionsFailureText(final String failure) {
  final noRoad = failure.startsWith('No routes found between these locations');
  final plain = noRoad
      ? "We couldn't find a route to this place."
      : "Directions aren't available right now. Please try again later.";
  return showRawDirectionsErrors && !noRoad
      ? '$plain\n(Test build) $failure'
      : plain;
}

/// Asks for routes from [origin] to [destination] (Routes API through
/// map_repository.getRoute) and starts the search for the alerts that touch
/// them. Returns null on success, else the words to show.
Future<String?> planRouteBetween({
  required final WidgetRef ref,
  required final AlrtLocation origin,
  required final AlrtLocation destination,
}) async {
  final notifier = ref.read(providerOfMap.notifier);
  await notifier.getRoutePlan(origin: origin, destination: destination);
  final failure = ref.read(providerOfMap).getRouteState.maybeWhen(
        error: (error) => error.message,
        orElse: () => null,
      );
  if (failure != null) {
    debugPrint('[directions] $failure');
    return directionsFailureText(failure);
  }
  // The hazards on each route are otherwise only fetched when the map
  // camera moves, which may not happen while Check a route covers the map.
  unawaited(notifier.getRoutePlanHazardsToAvoid());
  return null;
}

/// Asks for routes from where the person is to [destination] and explains
/// any failure. The route options sheet opens from the map state on success.
Future<void> startDirectionsTo({
  required final BuildContext context,
  required final WidgetRef ref,
  required final AlrtLocation destination,
}) async {
  final origin = ref.read(providerOfLocation).location;
  final failure = await planRouteBetween(
    ref: ref,
    origin: origin,
    destination: destination,
  );
  if (!context.mounted || failure == null) return;
  context.showErrorToast(message: failure);
}
