import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/map/utils/hazard_cluster_util.dart';
import 'package:hazard_app/features/notification/views/widgets/map_area_alerts_list.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';
import 'package:hazard_app/features/shared/models/app_user_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/views/widgets/alert_card_style.dart';

/// Product owner, 14 Oct 2026: markers and grouping match the live app,
/// the Alerts tab is the list of what the map shows (most serious first),
/// and "In plain terms" never promises advice that is not there.
void main() {
  group('plain terms', () {
    test('names the place from the agency title, not the region code', () {
      final line = AlertCardStyle.plainTermsOf(
        isOfficial: true,
        isAws: false,
        categoryName: 'Vehicle Fire',
        sourceName: 'Department of Fire and Emergency Services WA',
        locationName: 'METRO SOUTH EAST',
        title: 'Vehicle Fire at Salter Point',
        hasAdvice: false,
      );
      expect(
        line,
        'Department of Fire and Emergency Services WA has reported a '
        'vehicle fire at Salter Point. They have not published advice yet.',
      );
    });

    test('keeps the advice line when the agency gave advice', () {
      final line = AlertCardStyle.plainTermsOf(
        isOfficial: true,
        isAws: false,
        categoryName: 'Bushfire',
        sourceName: 'DFES',
        locationName: 'Gingin',
        hasAdvice: true,
      );
      expect(line, 'DFES has reported a bushfire near Gingin. '
          'Their advice is in this alert.');
    });

    test('keeps the title preposition and names bucket categories', () {
      final line = AlertCardStyle.plainTermsOf(
        isOfficial: true,
        isAws: false,
        categoryName: 'Security & Crime',
        sourceName: 'WA Police',
        title: 'Police operation in Northbridge',
        hasAdvice: true,
      );
      expect(
        line,
        'WA Police has reported a security and crime alert in Northbridge. '
        'Their advice is in this alert.',
      );
    });

    test('takes the last place phrase in a title', () {
      expect(
        AlertCardStyle.placeFromTitle('Burn-off in progress at Gingin'),
        'Gingin',
      );
      expect(AlertCardStyle.placeFromTitle('Road closed'), isNull);
      expect(
        AlertCardStyle.placeFromTitle('FIRE AT SALTER POINT'),
        'Salter Point',
      );
    });
  });

  group('Alerts tab order', () {
    test('most serious first, community after official, newest first', () {
      final old = DateTime(2026, 10, 14, 8);
      final recent = DateTime(2026, 10, 14, 9);
      final sorted = MapAreaAlertsList.sortBySeverity([
        Hazard(id: 'info', severityBand: HazardSeverityBand.info),
        Hazard(id: 'community', reportedBy: const AppUser(id: 'u1')),
        Hazard(
          id: 'action-old',
          severityBand: HazardSeverityBand.action,
          createdAt: old,
        ),
        Hazard(id: 'critical', severityBand: HazardSeverityBand.critical),
        Hazard(
          id: 'action-new',
          severityBand: HazardSeverityBand.action,
          createdAt: recent,
        ),
      ]);
      expect(sorted.map((h) => h.id), [
        'critical',
        'action-new',
        'action-old',
        'info',
        'community',
      ]);
    });
  });

  group('grouping', () {
    test('AWS Watch and Act and Emergency are never grouped', () {
      final hazards = [
        for (var i = 0; i < 4; i++)
          Hazard(
            id: 'h$i',
            latitude: -31.95,
            longitude: 115.86,
            severityBand: HazardSeverityBand.info,
          ),
        Hazard(
          id: 'ew',
          latitude: -31.95,
          longitude: 115.86,
          isAwsCompliant: true,
          severityBand: HazardSeverityBand.critical,
        ),
      ];
      final clusters = clusterHazards(hazards: hazards, zoom: 10);
      expect(clusters.where((c) => c.isSingle).single.single.id, 'ew');
      expect(clusters.where((c) => !c.isSingle).single.count, 4);
    });

    test('a group turns orange only for an official Action alert', () {
      final quiet = HazardCluster(
        hazards: [
          Hazard(id: 'a', severityBand: HazardSeverityBand.monitor),
          Hazard(id: 'b', reportedBy: const AppUser(id: 'u1')),
        ],
        latitude: 0,
        longitude: 0,
      );
      expect(quiet.dominantBand, HazardSeverityBand.monitor);
      final loud = HazardCluster(
        hazards: [
          Hazard(id: 'a', severityBand: HazardSeverityBand.action),
          Hazard(id: 'b', severityBand: HazardSeverityBand.info),
        ],
        latitude: 0,
        longitude: 0,
      );
      expect(loud.dominantBand, HazardSeverityBand.action);
    });

    test('pins on the same spot fan out at street zoom', () {
      final offsets = fanOutOffsets(
        hazards: [
          Hazard(id: 'a', latitude: -31.95, longitude: 115.86),
          Hazard(id: 'b', latitude: -31.95, longitude: 115.86),
          Hazard(id: 'c', latitude: -31.90, longitude: 115.80),
        ],
        zoom: 18,
      );
      expect(offsets.keys, containsAll(['a', 'b']));
      expect(offsets.containsKey('c'), isFalse);
      expect(offsets['a'], isNot(equals(offsets['b'])));
    });
  });

  group('markers', () {
    test('official alerts wear the category artwork, not a bare shape', () {
      final artwork = BitmapDescriptor.defaultMarkerWithHue(10);
      final bare = BitmapDescriptor.defaultMarkerWithHue(200);
      final hazard = Hazard(
        id: 'vf',
        categoryId: 'vehicleFire',
        isAwsCompliant: false,
        severityBand: HazardSeverityBand.info,
      );
      final picked = hazard.getMarkerBitmapDescriptor({
        'vehicleFire_info_non_aws': artwork,
        'shape_${hazard.effectiveMapShape.name}_info': bare,
      });
      expect(identical(picked, artwork), isTrue);
    });
  });
}
