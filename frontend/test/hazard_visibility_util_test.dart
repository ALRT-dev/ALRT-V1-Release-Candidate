import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/map/utils/hazard_visibility_util.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';
import 'package:hazard_app/features/shared/models/hazard_category_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/models/hazard_source_model.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_types.dart';
import 'package:hazard_app/features/shared/providers/states/hazard_filters_provider_state.dart';

// Locks in the exact Map tab visibility rules a TEST-alert investigation
// traced this turn: a hazard filed under a CHILD category (e.g. the
// "Create Test Alert" picker's "bushfire", parent "weatherAndEnvironment")
// must match a filter selection containing EITHER the child id or the
// parent id - never only one direction - and a hazard within the current
// map viewport must be shown regardless of which of the two ids is
// selected. Written after confirming this was NOT the bug behind a TEST
// alert not appearing (that turned out to be an unrelated, correctly-coded
// LocationSubscription scoping on the Notifications feed, not this).

// Scarborough, WA - the fixed coordinates every "Create Test Alert" preset
// uses.
const _scarboroughLat = -31.89441;
const _scarboroughLng = 115.75999;

LatLngBounds _boundsAround(double lat, double lng, {double delta = 0.5}) =>
    LatLngBounds(
      southwest: LatLng(lat - delta, lng - delta),
      northeast: LatLng(lat + delta, lng + delta),
    );

Hazard _bushfireHazard({double? lat = _scarboroughLat, double? lng = _scarboroughLng}) =>
    Hazard(
      categoryId: 'bushfire',
      category: const HazardCategory(id: 'bushfire', parentId: 'weatherAndEnvironment'),
      latitude: lat,
      longitude: lng,
      isAwsCompliant: false,
    );

void main() {
  group('hazardIsInMapBounds', () {
    test('a hazard inside the viewport is in bounds', () {
      final hazard = _bushfireHazard();
      final bounds = _boundsAround(_scarboroughLat, _scarboroughLng);
      expect(hazardIsInMapBounds(hazard, bounds), isTrue);
    });

    test('a hazard outside the viewport is not in bounds', () {
      final hazard = _bushfireHazard();
      // Brisbane - nowhere near Scarborough, WA.
      final bounds = _boundsAround(-27.4698, 153.0251);
      expect(hazardIsInMapBounds(hazard, bounds), isFalse);
    });

    test('a hazard with no coordinates is never in bounds', () {
      final hazard = _bushfireHazard(lat: null, lng: null);
      final bounds = _boundsAround(_scarboroughLat, _scarboroughLng);
      expect(hazardIsInMapBounds(hazard, bounds), isFalse);
    });
  });

  group('hazardMatchesMapFilters - parent/child category matching', () {
    test('matches when only the CHILD category id is selected', () {
      final hazard = _bushfireHazard();
      final filters = const HazardFiltersProviderState(
        selectedCategoryIds: {'bushfire'},
      );
      expect(hazardMatchesMapFilters(hazard, filters), isTrue);
    });

    test('matches when only the PARENT category id is selected', () {
      final hazard = _bushfireHazard();
      final filters = const HazardFiltersProviderState(
        selectedCategoryIds: {'weatherAndEnvironment'},
      );
      expect(hazardMatchesMapFilters(hazard, filters), isTrue);
    });

    test('does not match an unrelated category selection', () {
      final hazard = _bushfireHazard();
      final filters = const HazardFiltersProviderState(
        selectedCategoryIds: {'securityAndCrime'},
      );
      expect(hazardMatchesMapFilters(hazard, filters), isFalse);
    });

    test('matches any category when the selection is empty (no filter applied)', () {
      final hazard = _bushfireHazard();
      const filters = HazardFiltersProviderState(selectedCategoryIds: {});
      expect(hazardMatchesMapFilters(hazard, filters), isTrue);
    });
  });

  group('hazardMatchesMapFilters - source-type filters', () {
    test('a non-AWS official hazard requires officialNonAws to be on', () {
      final hazard = _bushfireHazard();
      const allowed = HazardFiltersProviderState(officialNonAws: true);
      const blocked = HazardFiltersProviderState(officialNonAws: false);
      expect(hazardMatchesMapFilters(hazard, allowed), isTrue);
      expect(hazardMatchesMapFilters(hazard, blocked), isFalse);
    });

    test('an AWS-compliant critical hazard requires awsEmergency to be on', () {
      final hazard = Hazard(
        categoryId: 'bushfire',
        category: const HazardCategory(id: 'bushfire', parentId: 'weatherAndEnvironment'),
        latitude: _scarboroughLat,
        longitude: _scarboroughLng,
        isAwsCompliant: true,
        severityBand: HazardSeverityBand.critical,
      );
      const allowed = HazardFiltersProviderState(awsEmergency: true);
      const blocked = HazardFiltersProviderState(awsEmergency: false);
      expect(hazardMatchesMapFilters(hazard, allowed), isTrue);
      expect(hazardMatchesMapFilters(hazard, blocked), isFalse);
    });
  });

  group('hazardMatchesMapFilters - the same source switches as the feed', () {
    Hazard official({final String? sourceId, final HazardSourceShape? shape}) => Hazard(
      categoryId: 'bushfire',
      category: const HazardCategory(id: 'bushfire', parentId: 'weatherAndEnvironment'),
      latitude: _scarboroughLat,
      longitude: _scarboroughLng,
      isAwsCompliant: false,
      source: HazardSource(id: sourceId ?? 'qldFire', name: 'src', shape: shape),
    );

    test('Global humanitarian off hides a GDACS alert on the map too', () {
      final gdacs = official(sourceId: 'gdacsGlobal');
      expect(hazardMatchesMapFilters(gdacs, const HazardFiltersProviderState()), isTrue);
      expect(
        hazardMatchesMapFilters(gdacs, const HazardFiltersProviderState(globalHumanitarian: false)),
        isFalse,
      );
      // A state agency alert is untouched by that switch.
      expect(
        hazardMatchesMapFilters(official(), const HazardFiltersProviderState(globalHumanitarian: false)),
        isTrue,
      );
    });

    test('ALRT Intel off hides a shield alert on the map too', () {
      final intel = official(shape: HazardSourceShape.shield);
      expect(hazardMatchesMapFilters(intel, const HazardFiltersProviderState()), isTrue);
      expect(hazardMatchesMapFilters(intel, const HazardFiltersProviderState(alrtIntel: false)), isFalse);
    });

    test('Official off hides state, humanitarian and Intel alerts alike (as the server does)', () {
      const off = HazardFiltersProviderState(officialNonAws: false);
      expect(hazardMatchesMapFilters(official(), off), isFalse);
      expect(hazardMatchesMapFilters(official(sourceId: 'gdacsGlobal'), off), isFalse);
      expect(hazardMatchesMapFilters(official(shape: HazardSourceShape.shield), off), isFalse);
    });

    test('AWS levels follow the official severity, not the derived band', () {
      final adviceWithActionBand = Hazard(
        categoryId: 'bushfire',
        latitude: _scarboroughLat,
        longitude: _scarboroughLng,
        isAwsCompliant: true,
        severity: HazardSeverity.advice,
        severityBand: HazardSeverityBand.action,
      );
      expect(
        hazardMatchesMapFilters(adviceWithActionBand, const HazardFiltersProviderState(awsAdvice: false)),
        isFalse,
      );
      expect(
        hazardMatchesMapFilters(adviceWithActionBand, const HazardFiltersProviderState(awsWatchAndAct: false)),
        isTrue,
      );
    });
  });

  test('a correctly-created Scarborough TEST alert is visible end-to-end when panned there', () {
    // The exact scenario a "Create Test Alert" preset produces: accepted,
    // Scarborough coordinates, a child category id, official (non-AWS,
    // non-user-reported) source. If this ever fails, the Map tab's
    // visibility rules - not category hierarchy or viewport bounds - are
    // the place to look first.
    final hazard = _bushfireHazard();
    final scarboroughViewport = _boundsAround(_scarboroughLat, _scarboroughLng);
    const filters = HazardFiltersProviderState();

    expect(hazardIsInMapBounds(hazard, scarboroughViewport), isTrue);
    expect(hazardMatchesMapFilters(hazard, filters), isTrue);
  });
}
