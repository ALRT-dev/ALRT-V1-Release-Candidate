import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/ask_alrt/utils/coarse_place.dart';

void main() {
  group('Ask ALRT coarse place (D1)', () {
    test('finds the state for major cities', () {
      expect(CoarsePlace.auState(-31.95, 115.86), 'WA'); // Perth
      expect(CoarsePlace.auState(-20.31, 118.6), 'WA'); // Port Hedland
      expect(CoarsePlace.auState(-33.87, 151.21), 'NSW'); // Sydney
      expect(CoarsePlace.auState(-37.81, 144.96), 'VIC'); // Melbourne
      expect(CoarsePlace.auState(-27.47, 153.03), 'QLD'); // Brisbane
      expect(CoarsePlace.auState(-34.93, 138.6), 'SA'); // Adelaide
      expect(CoarsePlace.auState(-42.88, 147.33), 'TAS'); // Hobart
      expect(CoarsePlace.auState(-12.46, 130.84), 'NT'); // Darwin
      expect(CoarsePlace.auState(-35.28, 149.13), 'ACT'); // Canberra
      expect(CoarsePlace.auState(-16.92, 145.77), 'QLD'); // Cairns
    });

    test('is null outside Australia', () {
      expect(CoarsePlace.auState(-8.65, 115.22), isNull); // Bali
      expect(CoarsePlace.auState(-36.85, 174.76), isNull); // Auckland
    });

    test('sends codes only, never coordinates', () {
      final fields = CoarsePlace.fields(deviceCountry: 'au', lat: -31.95, lng: 115.86, usingDeviceLocation: true);
      expect(fields, {'country': 'AU', 'state': 'WA'});
      expect(fields.values.join(), isNot(contains('.')));
    });

    test('uses the SIM or region country when no device location', () {
      expect(CoarsePlace.fields(deviceCountry: 'ID', lat: -31.95, lng: 115.86), {'country': 'ID'});
      expect(CoarsePlace.fields(deviceCountry: null), isEmpty);
    });
  });
}
