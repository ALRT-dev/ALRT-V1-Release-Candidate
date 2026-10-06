import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:hazard_app/features/home_screen_widget/home_widget_mapper.dart';
import 'package:hazard_app/features/home_screen_widget/models/home_widget_alert.dart';
import 'package:hazard_app/features/home_screen_widget/home_widget_service.dart';
import 'package:hazard_app/features/map/providers/location_provider.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';

/// Pushes the current nearby-hazard picture to the home-screen widget.
///
/// Call [push] whenever the hazard set the user cares about changes (wired into
/// the map provider's hazard-fetch success). Ordering is highest-severity
/// first, then nearest — the widget only ever shows the single most important
/// hazard, so this ordering decides what that is.
class HomeWidgetSync {
  const HomeWidgetSync._();

  /// Hazards further than this from the user are treated as not "nearby".
  static const _nearbyRadiusMeters = 50000.0; // 50 km

  static int _bandRank(final HazardSeverityBand? band) => switch (band) {
        HazardSeverityBand.critical => 3,
        HazardSeverityBand.action => 2,
        HazardSeverityBand.monitor => 1,
        HazardSeverityBand.info => 0,
        null => -1,
      };

  static String _distanceLabel(final double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  /// Builds the payload from [hazards] relative to the user's current location
  /// and hands it to the widget. Never throws.
  static Future<void> push(final Ref ref, final List<Hazard> hazards) async {
    final userLocation = ref.read(providerOfLocation).location;
    final userLat = userLocation.latitude;
    final userLng = userLocation.longitude;

    final candidates = <_RankedHazard>[];
    for (final hazard in hazards) {
      if (hazard.isExpired) continue;
      if (hazard.latitude == null || hazard.longitude == null) continue;

      final meters = Geolocator.distanceBetween(
        userLat,
        userLng,
        hazard.latitude!,
        hazard.longitude!,
      );
      if (meters > _nearbyRadiusMeters) continue;

      candidates.add(_RankedHazard(hazard: hazard, meters: meters));
    }

    candidates.sort((a, b) {
      final byBand = _bandRank(b.hazard.severityBand)
          .compareTo(_bandRank(a.hazard.severityBand));
      if (byBand != 0) return byBand;
      return a.meters.compareTo(b.meters);
    });

    final alerts = candidates.map((c) {
      final created = c.hazard.createdAt;
      return HomeWidgetMapper.fromHazard(
        c.hazard,
        distance: _distanceLabel(c.meters),
        time: created != null ? timeago.format(created) : null,
      );
    }).toList();

    await _update(alerts);
  }

  /// Explicitly render the "All clear" state (e.g. after a fetch that returned
  /// nothing nearby).
  static Future<void> pushAllClear() => _update(const <HomeWidgetAlert>[]);

  static Future<void> _update(final List<HomeWidgetAlert> alerts) {
    final updatedLabel = 'Updated ${DateFormat.jm().format(DateTime.now())}';
    return HomeWidgetService.update(
      HomeWidgetMapper.payload(nearby: alerts, updatedLabel: updatedLabel),
    );
  }
}

class _RankedHazard {
  const _RankedHazard({required this.hazard, required this.meters});
  final Hazard hazard;
  final double meters;
}
