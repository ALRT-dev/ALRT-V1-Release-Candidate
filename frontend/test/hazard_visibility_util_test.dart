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

Hazard _bushfireHazard({
  double? lat = _scarboroughLat,
  double? lng = _scarboroughLng,
}) => Hazard(
  categoryId: 'bushfire',
  category: const HazardCategory(
    id: 'bushfire',
    parentId: 'weatherAndEnvironment',
  ),
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

    // Zooming out from Perth pushes the east edge past 180, so it comes
    // back as a negative longitude and south-west > north-east. The map and
    // the Alerts list used to go blank at that zoom.
    test('a wrapped viewport still contains a hazard east of the seam', () {
      final hazard = _bushfireHazard();
      final wrapped = LatLngBounds(
        southwest: const LatLng(-60.0, 15.0),
        northeast: const LatLng(20.0, -144.0),
      );
      expect(hazardIsInMapBounds(hazard, wrapped), isTrue);
    });

    test('a wrapped viewport contains a hazard west of the seam', () {
      // Honolulu, on the far side of the antimeridian from Perth.
      final hazard = _bushfireHazard(lat: 21.3069, lng: -157.8583);
      final wrapped = LatLngBounds(
        southwest: const LatLng(-60.0, 15.0),
        northeast: const LatLng(40.0, -144.0),
      );
      expect(hazardIsInMapBounds(hazard, wrapped), isTrue);
    });

    test('a wrapped viewport excludes a hazard in the gap it does not cover', () {
      // Sao Paulo sits in the untouched wedge between -144 and 15.
      final hazard = _bushfireHazard(lat: -23.5505, lng: -46.6333);
      final wrapped = LatLngBounds(
        southwest: const LatLng(-60.0, 15.0),
        northeast: const LatLng(20.0, -144.0),
      );
      expect(hazardIsInMapBounds(hazard, wrapped), isFalse);
    });

    test('a wrapped viewport still respects latitude', () {
      // Right longitude, far too far north.
      final hazard = _bushfireHazard(lat: 64.0, lng: 115.0);
      final wrapped = LatLngBounds(
        southwest: const LatLng(-60.0, 15.0),
        northeast: const LatLng(20.0, -144.0),
      );
      expect(hazardIsInMapBounds(hazard, wrapped), isFalse);
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

    test(
      'matches any category when the selection is empty (no filter applied)',
      () {
        final hazard = _bushfireHazard();
        const filters = HazardFiltersProviderState(selectedCategoryIds: {});
        expect(hazardMatchesMapFilters(hazard, filters), isTrue);
      },
    );
  });

  group('hazardMatchesMapFilters - source-type filters', () {
    test('a non-AWS official hazard requires officialNonAws to be on', () {
      final hazard = _bushfireHazard();
      const allowed = HazardFiltersProviderState(officialNonAws: true);
      const blocked = HazardFiltersProviderState(officialNonAws: false);
      expect(hazardMatchesMapFilters(hazard, allowed), isTrue);
      expect(hazardMatchesMapFilters(hazard, blocked), isFalse);
    });

    test(
      'an AWS-compliant critical hazard is always visible, even with awsEmergency off',
      () {
        final hazard = Hazard(
          categoryId: 'bushfire',
          category: const HazardCategory(
            id: 'bushfire',
            parentId: 'weatherAndEnvironment',
          ),
          latitude: _scarboroughLat,
          longitude: _scarboroughLng,
          isAwsCompliant: true,
          severityBand: HazardSeverityBand.critical,
        );
        const allowed = HazardFiltersProviderState(awsEmergency: true);
        const blocked = HazardFiltersProviderState(awsEmergency: false);
        expect(hazardMatchesMapFilters(hazard, allowed), isTrue);
        expect(hazardMatchesMapFilters(hazard, blocked), isTrue);
      },
    );
  });

  group('hazardMatchesMapFilters - official warnings are always visible', () {
    Hazard aws({
      HazardSeverity? severity,
      HazardSeverityBand? band,
      String category = 'bushfire',
    }) => Hazard(
      categoryId: category,
      latitude: _scarboroughLat,
      longitude: _scarboroughLng,
      isAwsCompliant: true,
      severity: severity,
      severityBand: band,
    );

    test('an AWS Emergency Warning ignores the category selection', () {
      final hazard = aws(severity: HazardSeverity.emergency);
      const filters = HazardFiltersProviderState(
        selectedCategoryIds: {'securityAndCrime'},
        awsEmergency: false,
      );
      expect(hazardMatchesMapFilters(hazard, filters), isTrue);
    });

    test(
      'an official critical alert survives Official off and a category mismatch',
      () {
        final hazard = Hazard(
          categoryId: 'bushfire',
          latitude: _scarboroughLat,
          longitude: _scarboroughLng,
          isAwsCompliant: false,
          severityBand: HazardSeverityBand.critical,
        );
        const filters = HazardFiltersProviderState(
          selectedCategoryIds: {'securityAndCrime'},
          officialNonAws: false,
        );
        expect(hazardMatchesMapFilters(hazard, filters), isTrue);
      },
    );

    test('a non-critical official alert is still hidden by Official off', () {
      final hazard = Hazard(
        categoryId: 'bushfire',
        latitude: _scarboroughLat,
        longitude: _scarboroughLng,
        isAwsCompliant: false,
        severityBand: HazardSeverityBand.action,
      );
      expect(
        hazardMatchesMapFilters(
          hazard,
          const HazardFiltersProviderState(officialNonAws: false),
        ),
        isFalse,
      );
    });

    test('an AWS Watch and Act bypasses its switch and the category', () {
      final hazard = aws(severity: HazardSeverity.watchAndAct);
      expect(
        hazardMatchesMapFilters(
          hazard,
          const HazardFiltersProviderState(awsWatchAndAct: false),
        ),
        isTrue,
      );
      expect(
        hazardMatchesMapFilters(
          hazard,
          const HazardFiltersProviderState(
            selectedCategoryIds: {'securityAndCrime'},
          ),
        ),
        isTrue,
      );
    });
    test('an AWS Info lifecycle update does not bypass disabled filters', () {
      final hazard = aws(
        severity: HazardSeverity.emergency,
        band: HazardSeverityBand.info,
      );
      expect(
        hazardMatchesMapFilters(
          hazard,
          const HazardFiltersProviderState(
            awsEmergency: false,
            selectedCategoryIds: {'securityAndCrime'},
          ),
        ),
        isFalse,
      );
    });
  });

  group('hazardMatchesMapFilters - the same source switches as the feed', () {
    Hazard official({final String? sourceId, final HazardSourceShape? shape}) =>
        Hazard(
          categoryId: 'bushfire',
          category: const HazardCategory(
            id: 'bushfire',
            parentId: 'weatherAndEnvironment',
          ),
          latitude: _scarboroughLat,
          longitude: _scarboroughLng,
          isAwsCompliant: false,
          source: HazardSource(
            id: sourceId ?? 'qldFire',
            name: 'src',
            shape: shape,
          ),
        );

    test(
      'Global humanitarian folded into Official: the old switch no longer hides GDACS',
      () {
        final gdacs = official(sourceId: 'gdacsGlobal');
        expect(
          hazardMatchesMapFilters(
            gdacs,
            const HazardFiltersProviderState(globalHumanitarian: false),
          ),
          isTrue,
        );
      },
    );

    test('ALRT Intel off hides a shield alert on the map too', () {
      final intel = official(shape: HazardSourceShape.shield);
      expect(
        hazardMatchesMapFilters(intel, const HazardFiltersProviderState()),
        isTrue,
      );
      expect(
        hazardMatchesMapFilters(
          intel,
          const HazardFiltersProviderState(alrtIntel: false),
        ),
        isFalse,
      );
    });

    test(
      'Official off hides state, humanitarian and Intel alerts alike (as the server does)',
      () {
        const off = HazardFiltersProviderState(officialNonAws: false);
        expect(hazardMatchesMapFilters(official(), off), isFalse);
        expect(
          hazardMatchesMapFilters(official(sourceId: 'gdacsGlobal'), off),
          isFalse,
        );
        expect(
          hazardMatchesMapFilters(
            official(shape: HazardSourceShape.shield),
            off,
          ),
          isFalse,
        );
      },
    );

    test('active AWS Advice remains visible despite optional switches', () {
      final adviceWithActionBand = Hazard(
        categoryId: 'bushfire',
        latitude: _scarboroughLat,
        longitude: _scarboroughLng,
        isAwsCompliant: true,
        severity: HazardSeverity.advice,
        severityBand: HazardSeverityBand.action,
      );
      expect(
        hazardMatchesMapFilters(
          adviceWithActionBand,
          const HazardFiltersProviderState(awsAdvice: false),
        ),
        isTrue,
      );
      expect(
        hazardMatchesMapFilters(
          adviceWithActionBand,
          const HazardFiltersProviderState(awsWatchAndAct: false),
        ),
        isTrue,
      );
    });
  });

  test(
    'a correctly-created Scarborough TEST alert is visible end-to-end when panned there',
    () {
      // The exact scenario a "Create Test Alert" preset produces: accepted,
      // Scarborough coordinates, a child category id, official (non-AWS,
      // non-user-reported) source. If this ever fails, the Map tab's
      // visibility rules - not category hierarchy or viewport bounds - are
      // the place to look first.
      final hazard = _bushfireHazard();
      final scarboroughViewport = _boundsAround(
        _scarboroughLat,
        _scarboroughLng,
      );
      const filters = HazardFiltersProviderState();

      expect(hazardIsInMapBounds(hazard, scarboroughViewport), isTrue);
      expect(hazardMatchesMapFilters(hazard, filters), isTrue);
    },
  );
}
