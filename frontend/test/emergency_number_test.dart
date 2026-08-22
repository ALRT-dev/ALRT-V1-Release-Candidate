import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/shared/services/sim_country.dart';
import 'package:hazard_app/features/shared/services/emergency_number.dart';

/// A wrong number here sends someone to the wrong place in an emergency, so
/// the resolution order and the fallback are pinned.
void main() {
  group('countryFromLocale', () {
    test('reads the region subtag', () {
      expect(EmergencyNumber.countryFromLocale('en-AU'), 'AU');
      expect(EmergencyNumber.countryFromLocale('en_US'), 'US');
      expect(EmergencyNumber.countryFromLocale('fr-CA'), 'CA');
    });

    test('returns null when there is no region', () {
      expect(EmergencyNumber.countryFromLocale('en'), isNull);
      expect(EmergencyNumber.countryFromLocale(''), isNull);
      expect(EmergencyNumber.countryFromLocale(null), isNull);
    });
  });

  group('resolve', () {
    test('SIM country wins over device region and locale', () {
      expect(
        EmergencyNumber.resolve(
          simCountry: 'US',
          deviceRegion: 'AU',
          locale: 'en-GB',
        ),
        '911',
      );
    });

    test('device region wins over locale when there is no SIM', () {
      expect(
        EmergencyNumber.resolve(deviceRegion: 'GB', locale: 'en-AU'),
        '999',
      );
    });

    test('falls through to the locale when that is all there is', () {
      expect(EmergencyNumber.resolve(locale: 'en-NZ'), '111');
    });

    test('an Australian still gets 000', () {
      expect(EmergencyNumber.resolve(deviceRegion: 'AU'), '000');
    });

    test('Europe gets 112', () {
      for (final iso in ['FR', 'DE', 'ES', 'IT', 'PL', 'SE']) {
        expect(EmergencyNumber.resolve(deviceRegion: iso), '112');
      }
    });

    test('unknown or missing country falls back to the GSM global 112', () {
      expect(EmergencyNumber.resolve(deviceRegion: 'ZZ'), '112');
      expect(EmergencyNumber.resolve(), '112');
      expect(
        EmergencyNumber.resolve(simCountry: '', deviceRegion: '', locale: ''),
        '112',
      );
    });

    test('country codes are matched case-insensitively', () {
      expect(EmergencyNumber.resolve(deviceRegion: 'au'), '000');
    });

    test('every seeded number is dialable digits', () {
      for (final entry in EmergencyNumber.numbers.entries) {
        expect(
          RegExp(r'^\d{3,4}$').hasMatch(entry.value),
          isTrue,
          reason: '${entry.key} has a non-dialable number "${entry.value}"',
        );
      }
    });
  });

  group('SimCountry', () {
    tearDown(() => SimCountry.debugSet(null, hasLoaded: false));

    test('the channel result feeds the top tier of the chain', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.safetyalrt.alrt/sim'),
        (call) async => call.method == 'getSimCountryIso' ? 'es' : null,
      );

      expect(await SimCountry.load(), 'ES');
      // An Australian phone in Spain is offered the Spanish number, which
      // is the whole reason the SIM tier outranks device region.
      expect(
        EmergencyNumber.resolve(
          simCountry: SimCountry.value,
          deviceRegion: 'AU',
          locale: 'en-AU',
        ),
        '112',
      );
    });

    test('no SIM leaves the value null and falls through to region', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.safetyalrt.alrt/sim'),
        (call) async => null,
      );

      expect(await SimCountry.load(), isNull);
      expect(
        EmergencyNumber.resolve(
          simCountry: SimCountry.value,
          deviceRegion: 'AU',
        ),
        '000',
      );
    });

    test('a platform failure never costs the fallback', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.safetyalrt.alrt/sim'),
        (call) async => throw PlatformException(code: 'nope'),
      );

      expect(await SimCountry.load(), isNull);
      expect(
        EmergencyNumber.resolve(simCountry: SimCountry.value),
        EmergencyNumber.gsmGlobalFallback,
      );
    });
  });
}
