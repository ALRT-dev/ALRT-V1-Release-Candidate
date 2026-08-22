import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';

/// The source systems an alert can come from (V3 "Map details" sheet).
///
/// AWS = Australian Warning System compliant official alerts,
/// official = state agencies and services (non-AWS),
/// globalHumanitarian = GDACS-style events rated for international
/// humanitarian response (this system may be retired later),
/// community = user reports from people nearby,
/// alrtIntel = ALRT's own assessment, the shield.
enum AlertSourceSystem {
  aws,
  official,
  globalHumanitarian,
  community,
  alrtIntel;

  /// Resolves the source system of the given [hazard].
  ///
  /// ALRT Intel is tested first: it is ALRT's own assessment and outranks
  /// every other system. Global humanitarian is tested before AWS and
  /// official: those feeds carry a source like any agency alert, so
  /// without this they would fall through to the diamond.
  static AlertSourceSystem of(final Hazard hazard) {
    if (hazard.isAlrtIntel) return AlertSourceSystem.alrtIntel;
    if (hazard.isUserReported) return AlertSourceSystem.community;
    if (hazard.isGlobalHumanitarian) {
      return AlertSourceSystem.globalHumanitarian;
    }
    if (hazard.isAwsCompliant == true) return AlertSourceSystem.aws;
    return AlertSourceSystem.official;
  }
}

/// The [MapType] selected in the "Map details" sheet.
final providerOfMapType = NotifierProvider<MapTypeNotifier, MapType>(
  MapTypeNotifier.new,
);

class MapTypeNotifier extends Notifier<MapType> {
  @override
  MapType build() => MapType.normal;

  /// Updates the selected map type.
  void update(final MapType mapType) {
    state = mapType;
  }
}

/// The source systems whose alerts are currently visible on the map and in
/// the "Around You" list. Defaults to all systems on.
final providerOfVisibleAlertSystems =
    NotifierProvider<VisibleAlertSystemsNotifier, Set<AlertSourceSystem>>(
      VisibleAlertSystemsNotifier.new,
    );

class VisibleAlertSystemsNotifier extends Notifier<Set<AlertSourceSystem>> {
  @override
  Set<AlertSourceSystem> build() => AlertSourceSystem.values.toSet();

  /// Toggles the visibility of the given [system].
  void toggle(final AlertSourceSystem system) {
    final next = {...state};
    if (!next.remove(system)) next.add(system);
    state = next;
  }
}
