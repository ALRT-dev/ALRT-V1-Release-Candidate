import 'dart:async';

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

/// Asks for routes from where the person is to [destination] and explains
/// any failure. The route options sheet opens from the map state on success.
Future<void> startDirectionsTo({
  required final BuildContext context,
  required final WidgetRef ref,
  required final AlrtLocation destination,
}) async {
  final origin = ref.read(providerOfLocation).location;
  await ref
      .read(providerOfMap.notifier)
      .getRoutePlan(origin: origin, destination: destination);
  if (!context.mounted) return;
  final failure = ref.read(providerOfMap).getRouteState.maybeWhen(
        error: (error) => error.message,
        orElse: () => null,
      );
  if (failure == null) return;
  debugPrint('[directions] $failure');
  final noRoad = failure.startsWith('No routes found between these locations');
  final plain = noRoad
      ? "We couldn't find a route to this place."
      : "Directions aren't available right now. Please try again later.";
  context.showErrorToast(
    message: showRawDirectionsErrors && !noRoad
        ? '$plain\n(Test build) $failure'
        : plain,
  );
}
