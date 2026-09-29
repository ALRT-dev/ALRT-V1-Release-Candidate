import 'package:geolocator/geolocator.dart';

/// Where the phone is, said truthfully (review follow-up, 29 Sep 2026).
///
/// - [LocationFixKind.current]: a fix taken just now (at most
///   [LocationFix.maxCurrentAge] old). Only this is ever "where you are".
/// - [LocationFixKind.lastKnown]: an older fix the phone kept. It is only
///   used when the person explicitly chooses it, and its age is shown.
/// - [LocationFixKind.unavailable]: no usable fix, with the reason. An SOS
///   can still be sent without location.
enum LocationFixKind { current, lastKnown, unavailable }

enum LocationUnavailableReason { servicesOff, permissionDenied, noFix }

class LocationFix {
  const LocationFix._(this.kind, this.position, this.reason, this.age);

  const LocationFix.current(Position position, Duration age)
    : this._(LocationFixKind.current, position, null, age);

  const LocationFix.lastKnown(Position position, Duration age)
    : this._(LocationFixKind.lastKnown, position, null, age);

  const LocationFix.unavailable(LocationUnavailableReason reason)
    : this._(LocationFixKind.unavailable, null, reason, null);

  /// A fix older than this is never presented as current.
  static const maxCurrentAge = Duration(minutes: 2);

  /// A cached fix less accurate than this is not treated as current.
  static const maxCurrentAccuracyM = 150.0;

  /// Older than this, a last-known fix isn't offered at all.
  static const maxLastKnownAge = Duration(hours: 24);

  final LocationFixKind kind;
  final Position? position;
  final LocationUnavailableReason? reason;
  final Duration? age;

  bool get isCurrent => kind == LocationFixKind.current;
  bool get hasPoint => position != null;

  /// When the phone actually fixed the point.
  DateTime? get capturedAt => position?.timestamp;

  /// How old the point is at [now] (a fix ages while a screen stays open).
  Duration? ageAt(final DateTime now) {
    final at = capturedAt;
    if (at == null) return null;
    final age = now.difference(at);
    return age.isNegative ? Duration.zero : age;
  }

  /// Still "where you are now" at [now]: it was current when resolved AND
  /// has not aged past [maxCurrentAge] since. A point that was current when
  /// the SOS screen opened is last known a few minutes later.
  bool isCurrentAt(final DateTime now) =>
      isCurrent && (ageAt(now) ?? maxCurrentAge * 2) <= maxCurrentAge;

  /// The same fix, said truthfully at [now]: a current fix that has aged
  /// past the window becomes last known, with its real age.
  LocationFix at(final DateTime now) {
    if (!hasPoint) return this;
    final age = ageAt(now)!;
    if (isCurrent && age <= maxCurrentAge) return LocationFix.current(position!, age);
    return LocationFix.lastKnown(position!, age);
  }

  /// "12 min ago", "3 h ago", "just now".
  String get ageLabel => describeAge(age ?? Duration.zero);

  /// One line for the sender, never claiming "now" for an old point.
  String get statusLine => switch (kind) {
    LocationFixKind.current =>
      'Your location now (about ${accuracyLabel(position!.accuracy)}).',
    LocationFixKind.lastKnown =>
      'Your phone can\'t find you right now. Last known location: $ageLabel.',
    LocationFixKind.unavailable => switch (reason!) {
      LocationUnavailableReason.servicesOff =>
        'Location is switched off on this phone.',
      LocationUnavailableReason.permissionDenied =>
        'ALRT isn\'t allowed to use your location.',
      LocationUnavailableReason.noFix =>
        'Your phone can\'t find your location right now.',
    },
  };
}

String describeAge(final Duration age) {
  if (age.inMinutes < 1) return 'just now';
  if (age.inMinutes < 60) return '${age.inMinutes} min ago';
  if (age.inHours < 24) return '${age.inHours} h ago';
  return '${age.inDays} d ago';
}

String accuracyLabel(final double metres) =>
    metres < 1000 ? '±${metres.round()} m' : '±${(metres / 1000).toStringAsFixed(1)} km';

/// The clock the location screens use, so tests can move time on while a
/// screen is open.
typedef Clock = DateTime Function();

/// The phone's location API, behind a seam so every case (stale cache,
/// denied permission, GPS off, a failed request) can be tested.
abstract class DeviceLocationSource {
  Future<bool> isServiceEnabled();
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
  Future<Position?> lastKnown();

  /// Throws on failure or timeout.
  Future<Position> current({required Duration timeout});
}

class GeolocatorLocationSource implements DeviceLocationSource {
  const GeolocatorLocationSource();

  @override
  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  @override
  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  @override
  Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();

  @override
  Future<Position?> lastKnown() => Geolocator.getLastKnownPosition();

  @override
  Future<Position> current({required Duration timeout}) =>
      Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeout,
        ),
      );
}

/// Resolves the phone's location truthfully: a recent, accurate cached fix
/// counts as current; otherwise a fresh fix is requested; if that fails an
/// older cached fix is offered only as "last known", with its age.
Future<LocationFix> resolveLocationFix(
  final DeviceLocationSource source, {
  final DateTime Function() now = DateTime.now,
  final Duration timeout = const Duration(seconds: 10),
}) async {
  try {
    if (!await source.isServiceEnabled()) {
      return const LocationFix.unavailable(LocationUnavailableReason.servicesOff);
    }
    var permission = await source.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await source.requestPermission();
    }
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      return const LocationFix.unavailable(
        LocationUnavailableReason.permissionDenied,
      );
    }
  } catch (_) {
    return const LocationFix.unavailable(LocationUnavailableReason.noFix);
  }

  Position? cached;
  try {
    cached = await source.lastKnown();
  } catch (_) {
    cached = null;
  }
  Duration ageOf(final Position p) {
    final age = now().difference(p.timestamp);
    return age.isNegative ? Duration.zero : age;
  }

  if (cached != null &&
      ageOf(cached) <= LocationFix.maxCurrentAge &&
      cached.accuracy <= LocationFix.maxCurrentAccuracyM) {
    return LocationFix.current(cached, ageOf(cached));
  }
  try {
    final fresh = await source.current(timeout: timeout);
    // A platform can hand back a cached point from getCurrentPosition too:
    // check its own timestamp before calling it current.
    if (ageOf(fresh) <= LocationFix.maxCurrentAge) {
      return LocationFix.current(fresh, ageOf(fresh));
    }
    cached = cached == null || fresh.timestamp.isAfter(cached.timestamp)
        ? fresh
        : cached;
  } catch (_) {
    // Fall through to the last known point, if any.
  }
  if (cached != null && ageOf(cached) <= LocationFix.maxLastKnownAge) {
    return LocationFix.lastKnown(cached, ageOf(cached));
  }
  return const LocationFix.unavailable(LocationUnavailableReason.noFix);
}
