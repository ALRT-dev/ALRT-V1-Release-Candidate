import 'package:flutter_polyline_points/flutter_polyline_points.dart'
    show TravelMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/map/models/route_step_model.dart';

/// Parsing wrong here means a rider is shown the wrong line, vehicle, or
/// transfer count — pin the exact Google Routes API v2 JSON shape.
void main() {
  group('TransitVehicleType.fromApi', () {
    test('maps known vehicle type strings', () {
      expect(TransitVehicleType.fromApi('BUS'), TransitVehicleType.bus);
      expect(TransitVehicleType.fromApi('SUBWAY'), TransitVehicleType.subway);
      expect(TransitVehicleType.fromApi('TRAM'), TransitVehicleType.tram);
      expect(TransitVehicleType.fromApi('FERRY'), TransitVehicleType.ferry);
      expect(
        TransitVehicleType.fromApi('HEAVY_RAIL'),
        TransitVehicleType.heavyRail,
      );
    });

    test('falls back to unspecified for null/unknown', () {
      expect(TransitVehicleType.fromApi(null), TransitVehicleType.unspecified);
      expect(
        TransitVehicleType.fromApi('SOMETHING_NEW'),
        TransitVehicleType.unspecified,
      );
    });
  });

  group('RouteStep.fromJson — transit step', () {
    // Shape verified against google/maps/routing/v2/route.proto and
    // transit.proto (RouteLegStepTransitDetails, TransitLine, TransitVehicle,
    // TransitStop) — not guessed.
    final transitStepJson = {
      'startLocation': {
        'latLng': {'latitude': -27.4698, 'longitude': 153.0251},
      },
      'endLocation': {
        'latLng': {'latitude': -27.4705, 'longitude': 153.026},
      },
      'polyline': {'encodedPolyline': ''},
      'distanceMeters': 3200,
      'staticDuration': '540s',
      'travelMode': 'TRANSIT',
      'transitDetails': {
        'stopDetails': {
          'departureStop': {
            'name': 'Central Station',
            'location': {
              'latLng': {'latitude': -27.4655, 'longitude': 153.0251},
            },
          },
          'departureTime': '2026-08-22T01:15:00Z',
          'arrivalStop': {
            'name': 'Roma Street',
            'location': {
              'latLng': {'latitude': -27.4664, 'longitude': 153.0179},
            },
          },
          'arrivalTime': '2026-08-22T01:24:00Z',
        },
        'headsign': 'Ipswich',
        'stopCount': 3,
        'transitLine': {
          'name': 'Ipswich Line',
          'nameShort': 'IP',
          'color': '#00558E',
          'textColor': '#FFFFFF',
          'vehicle': {
            'name': {'text': 'Train', 'languageCode': 'en'},
            'type': 'COMMUTER_TRAIN',
          },
        },
      },
    };

    test('parses transit line, vehicle, stops, and headsign', () {
      final step = RouteStep.fromJson(transitStepJson);
      expect(step, isNotNull);
      expect(step!.travelMode, TravelMode.transit);

      final transit = step.transitDetails;
      expect(transit, isNotNull);
      expect(transit!.headsign, 'Ipswich');
      expect(transit.stopCount, 3);
      expect(transit.departureStop?.name, 'Central Station');
      expect(transit.arrivalStop?.name, 'Roma Street');
      expect(
        transit.departureTime,
        DateTime.parse('2026-08-22T01:15:00Z'),
      );

      final line = transit.line;
      expect(line, isNotNull);
      expect(line!.name, 'Ipswich Line');
      expect(line.nameShort, 'IP');
      expect(line.displayLabel, 'IP');
      expect(line.color, isNotNull);
      expect(line.vehicle.type, TransitVehicleType.commuterTrain);
      expect(line.vehicle.name, 'Train');
    });

    test('derives an instruction from the line when Google omits one', () {
      final step = RouteStep.fromJson(transitStepJson);
      expect(step!.instruction, 'Take IP towards Ipswich');
    });
  });

  group('RouteStep.fromJson — non-transit step', () {
    test('transitDetails is null and behavior is unchanged', () {
      final drivingStepJson = {
        'startLocation': {
          'latLng': {'latitude': -27.4698, 'longitude': 153.0251},
        },
        'endLocation': {
          'latLng': {'latitude': -27.4705, 'longitude': 153.026},
        },
        'polyline': {'encodedPolyline': ''},
        'distanceMeters': 500,
        'staticDuration': '60s',
        'travelMode': 'DRIVE',
        'navigationInstruction': {
          'maneuver': 'TURN_LEFT',
          'instructions': 'Turn left onto Pacific Highway',
        },
      };

      final step = RouteStep.fromJson(drivingStepJson);
      expect(step, isNotNull);
      expect(step!.travelMode, TravelMode.driving);
      expect(step.transitDetails, isNull);
      expect(step.instruction, 'Turn left onto Pacific Highway');
    });

    test('a malformed transitDetails does not throw and yields null', () {
      final json = {
        'startLocation': {
          'latLng': {'latitude': 0.0, 'longitude': 0.0},
        },
        'endLocation': {
          'latLng': {'latitude': 0.0, 'longitude': 0.0},
        },
        'travelMode': 'TRANSIT',
        'transitDetails': 'not-an-object',
      };

      final step = RouteStep.fromJson(json);
      expect(step, isNotNull);
      expect(step!.transitDetails, isNull);
      // No line/headsign to derive from — instruction falls back to empty.
      expect(step.instruction, '');
    });
  });
}
