import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hazard_app/features/family/services/family_location_service.dart';
import 'package:hazard_app/features/family/services/location_fix.dart';

/// Location freshness (review follow-up, 29 Sep 2026): an old cached
/// position is never presented as current; each failure says why.
class FakeLocationSource implements DeviceLocationSource {
  FakeLocationSource({
    this.services = true,
    this.permission = LocationPermission.whileInUse,
    this.afterRequest,
    this.cached,
    this.fresh,
    this.currentFails = false,
  });

  bool services;
  LocationPermission permission;
  LocationPermission? afterRequest;
  Position? cached;
  Position? fresh;
  bool currentFails;
  int currentCalls = 0;

  @override
  Future<bool> isServiceEnabled() async => services;
  @override
  Future<LocationPermission> checkPermission() async => permission;
  @override
  Future<LocationPermission> requestPermission() async =>
      afterRequest ?? permission;
  @override
  Future<Position?> lastKnown() async => cached;
  @override
  Future<Position> current({required Duration timeout}) async {
    currentCalls += 1;
    if (currentFails || fresh == null) throw Exception('timeout');
    return fresh!;
  }
}

final now = DateTime(2026, 9, 29, 12);

Position pos(Duration age, {double accuracy = 20}) => Position(
  latitude: -27.47,
  longitude: 153.02,
  timestamp: now.subtract(age),
  accuracy: accuracy,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

Future<LocationFix> resolve(FakeLocationSource s) =>
    resolveLocationFix(s, now: () => now);

void main() {
  test('a fresh, accurate cached fix is current (no wait)', () async {
    final s = FakeLocationSource(cached: pos(const Duration(seconds: 30)));
    final fix = await resolve(s);
    expect(fix.kind, LocationFixKind.current);
    expect(s.currentCalls, 0);
    expect(fix.statusLine, contains('Your location now'));
  });

  test('a stale cached fix is NOT current: a fresh fix is requested', () async {
    final s = FakeLocationSource(
      cached: pos(const Duration(minutes: 30)),
      fresh: pos(const Duration(seconds: 2)),
    );
    final fix = await resolve(s);
    expect(fix.kind, LocationFixKind.current);
    expect(fix.age, const Duration(seconds: 2));
    expect(s.currentCalls, 1);
  });

  test('stale cache and a failed current request: last known, with its age', () async {
    final s = FakeLocationSource(
      cached: pos(const Duration(minutes: 30)),
      currentFails: true,
    );
    final fix = await resolve(s);
    expect(fix.kind, LocationFixKind.lastKnown);
    expect(fix.ageLabel, '30 min ago');
    expect(fix.statusLine, contains('Last known location: 30 min ago'));
    expect(fix.statusLine, isNot(contains('now (')));
  });

  test('an inaccurate recent cache is not current either', () async {
    final s = FakeLocationSource(
      cached: pos(const Duration(seconds: 20), accuracy: 2000),
      currentFails: true,
    );
    expect((await resolve(s)).kind, LocationFixKind.lastKnown);
  });

  test('a "current" answer carrying an old timestamp is not current', () async {
    final s = FakeLocationSource(fresh: pos(const Duration(minutes: 10)));
    final fix = await resolve(s);
    expect(fix.kind, LocationFixKind.lastKnown);
    expect(fix.ageLabel, '10 min ago');
  });

  test('denied permission: unavailable, says why', () async {
    final s = FakeLocationSource(
      permission: LocationPermission.denied,
      afterRequest: LocationPermission.deniedForever,
      cached: pos(Duration.zero),
    );
    final fix = await resolve(s);
    expect(fix.kind, LocationFixKind.unavailable);
    expect(fix.reason, LocationUnavailableReason.permissionDenied);
    expect(fix.hasPoint, isFalse);
  });

  test('location services off: unavailable', () async {
    final fix = await resolve(FakeLocationSource(services: false));
    expect(fix.reason, LocationUnavailableReason.servicesOff);
  });

  test('GPS unavailable: no cache and the current request fails', () async {
    final fix = await resolve(FakeLocationSource(currentFails: true));
    expect(fix.kind, LocationFixKind.unavailable);
    expect(fix.reason, LocationUnavailableReason.noFix);
  });

  test('a cache older than a day is not offered at all', () async {
    final fix = await resolve(
      FakeLocationSource(cached: pos(const Duration(days: 2)), currentFails: true),
    );
    expect(fix.kind, LocationFixKind.unavailable);
  });

  test('check-ins and journeys get a position only when it is current', () async {
    Position realPos(Duration age) => Position(
      latitude: -27.47,
      longitude: 153.02,
      timestamp: DateTime.now().subtract(age),
      accuracy: 10,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
    final source = FakeLocationSource(
      cached: realPos(const Duration(minutes: 30)),
      currentFails: true,
    );
    final container = ProviderContainer(
      overrides: [providerOfDeviceLocationSource.overrideWithValue(source)],
    );
    addTearDown(container.dispose);
    final service = container.read(providerOfFamilyLocationService);
    expect(await service.getCurrentPositionOrNull(), isNull,
        reason: 'a 30-minute-old point is not "where you are now"');
    source.fresh = realPos(Duration.zero);
    source.currentFails = false;
    expect(await service.getCurrentPositionOrNull(), isNotNull);
  });
}
