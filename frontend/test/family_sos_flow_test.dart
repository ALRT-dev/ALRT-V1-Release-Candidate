import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/providers/states/family_provider_state.dart';
import 'package:hazard_app/features/family/services/family_service.dart';
import 'package:hazard_app/features/family/services/location_fix.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

/// The SOS send/stand-down contract behind the screens (2026-09-09):
/// a send whose answer was lost is recognised from the server instead of
/// being retried into a duplicate; standing down reports success only
/// when the server confirmed it and moves the event into history.
class _FakeFamilyService extends FamilyService {
  _FakeFamilyService(super.ref);

  bool triggerAnswerLost = false;
  bool resolveFails = false;
  final active = <FamilySosEvent>[];
  int triggers = 0;
  ({
    double? lat,
    String? mode,
    String? precision,
    DateTime? capturedAt,
    bool isLive,
  })?
  last;

  static const _mine = FamilySosEvent(
    id: 'sos-1',
    circleId: 'c1',
    memberId: 'me-member',
    status: FamilySosStatus.active,
  );

  @override
  Future<Either<FamilySosEvent, AppError>> triggerFamilySos({
    final double? latitude,
    final double? longitude,
    final String? sosListId,
    required final bool isLive,
    final String? locationMode,
    final String? locationPrecision,
    final DateTime? locationCapturedAt,
    final double? locationAccuracyM,
  }) async {
    triggers += 1;
    last = (
      lat: latitude,
      mode: locationMode,
      precision: locationPrecision,
      capturedAt: locationCapturedAt,
      isLive: isLive,
    );
    active.add(_mine);
    if (triggerAnswerLost) return const Failure(AppError(message: 'timeout'));
    return const Success(_mine);
  }

  @override
  Future<Either<List<FamilySosEvent>, AppError>> getAllActiveFamilySosEvents() async =>
      getActiveFamilySosEvents();

  @override
  Future<Either<List<FamilySosEvent>, AppError>> getActiveFamilySosEvents() async =>
      Success(List.of(active));

  @override
  Future<Either<FamilySosEvent, AppError>> resolveFamilySos({
    required final String sosEventId,
  }) async {
    if (resolveFails) return const Failure(AppError(message: 'offline'));
    active.removeWhere((e) => e.id == sosEventId);
    return Success(_mine.copyWith(status: FamilySosStatus.resolved, resolvedAt: DateTime(2026, 9, 9)));
  }

  @override
  Future<Either<List<FamilySosEvent>, AppError>> getFamilySosHistory() async =>
      const Success([]);
}

({ProviderContainer container, _FakeFamilyService service}) _setUp({
  FamilySharingLevel level = FamilySharingLevel.precise,
}) {
  late _FakeFamilyService service;
  final container = ProviderContainer(
    overrides: [
      providerOfFamilyService.overrideWith((ref) => service = _FakeFamilyService(ref)),
      providerOfFamily.overrideWith(
        (ref) => FamilyProvider(
          ref: ref,
          bootstrap: false,
          state: FamilyProviderState(
            hasLoadedOnce: true,
            circle: FamilyCircle(
              id: 'c1',
              name: 'Nixons',
              myMemberId: 'me-member',
              members: [
                FamilyMember(
                  id: 'me-member',
                  userId: 'me',
                  name: 'Me',
                  sharingLevel: level,
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
  container.read(providerOfFamilyService);
  return (container: container, service: service);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('a send whose answer was lost is found on the server, not sent twice', () async {
    final (:container, :service) = _setUp();
    service.triggerAnswerLost = true;
    final notifier = container.read(providerOfFamily.notifier);
    final direct = await notifier.triggerSos(location: SosLocationChoice.none);
    expect(direct, isNull, reason: 'the answer was lost');
    final found = await notifier.findMyActiveSos();
    expect(found?.id, 'sos-1', reason: 'the server has my active SOS');
    expect(service.triggers, 1, reason: 'no second SOS was raised');
    expect(container.read(providerOfFamily).activeSosEvents.map((e) => e.id), ['sos-1']);
  });

  test('findMyActiveSos ignores other people\'s SOS', () async {
    final (:container, :service) = _setUp();
    service.active.add(const FamilySosEvent(
      id: 'sos-other', circleId: 'c1', memberId: 'amy', status: FamilySosStatus.active,
    ));
    final found = await container.read(providerOfFamily.notifier).findMyActiveSos();
    expect(found, isNull);
  });

  test('standing down reports success and moves the SOS into history', () async {
    final (:container, :service) = _setUp();
    final notifier = container.read(providerOfFamily.notifier);
    await notifier.triggerSos(location: SosLocationChoice.none);
    final ok = await notifier.resolveSos(sosEventId: 'sos-1');
    expect(ok, isTrue);
    final s = container.read(providerOfFamily);
    expect(s.activeSosEvents, isEmpty);
    expect(s.sosHistory.map((e) => e.id), contains('sos-1'));
    expect(s.sosHistory.first.latitude, isNull, reason: 'history keeps who/when, never where');
  });

  test('a failed stand-down reports false and keeps the SOS active', () async {
    final (:container, :service) = _setUp();
    final notifier = container.read(providerOfFamily.notifier);
    await notifier.triggerSos(location: SosLocationChoice.none);
    service.resolveFails = true;
    final ok = await notifier.resolveSos(sosEventId: 'sos-1');
    expect(ok, isFalse);
    expect(container.read(providerOfFamily).activeSosEvents.map((e) => e.id), ['sos-1']);
  });

  group('SOS location choice is sent exactly as chosen (review 29 Sep)', () {
    final now = DateTime.now();
    Position pos(DateTime at) => Position(
      latitude: -27.47,
      longitude: 153.02,
      timestamp: at,
      accuracy: 20,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
    final current = LocationFix.current(pos(now), Duration.zero);
    final old = now.subtract(const Duration(minutes: 12));
    final lastKnown = LocationFix.lastKnown(
      pos(old),
      const Duration(minutes: 12),
    );

    test('No location sends no coordinates even with a fix', () async {
      final (:container, :service) = _setUp();
      await container
          .read(providerOfFamily.notifier)
          .triggerSos(location: SosLocationChoice.none, fix: current);
      expect(service.last!.lat, isNull);
      expect(service.last!.mode, 'none');
      expect(service.last!.isLive, isFalse);
    });

    test('Share location once with a last-known fix sends its real, older '
        'time', () async {
      final (:container, :service) = _setUp();
      await container
          .read(providerOfFamily.notifier)
          .triggerSos(location: SosLocationChoice.once, fix: lastKnown);
      expect(service.last!.lat, -27.47);
      expect(service.last!.mode, 'once');
      expect(service.last!.capturedAt, old);
      expect(service.last!.isLive, isFalse);
    });

    test('Share live location never starts from a last-known point', () async {
      final (:container, :service) = _setUp();
      await container
          .read(providerOfFamily.notifier)
          .triggerSos(location: SosLocationChoice.live, fix: lastKnown);
      expect(service.last!.lat, isNull);
      expect(service.last!.mode, 'live');
      expect(service.last!.isLive, isTrue);
      container.dispose();
    });

    test('precision follows the sharing setting', () async {
      var (:container, :service) = _setUp();
      await container
          .read(providerOfFamily.notifier)
          .triggerSos(location: SosLocationChoice.once, fix: current);
      expect(service.last!.precision, 'precise');
      (:container, :service) = _setUp(level: FamilySharingLevel.approximate);
      await container
          .read(providerOfFamily.notifier)
          .triggerSos(location: SosLocationChoice.once, fix: current);
      expect(service.last!.precision, 'approximate');
    });
  });

  group('stale and duplicate SOS events (phone QA 2026-09-09)', () {
    const other = FamilySosEvent(
      id: 'sos-9',
      circleId: 'c1',
      memberId: 'amy-member',
      status: FamilySosStatus.active,
    );

    test('a replayed familySos for an ended SOS does not bring it back', () async {
      final (:container, :service) = _setUp();
      final n = container.read(providerOfFamily.notifier);
      n.debugReceiveSos(other);
      expect(container.read(providerOfFamily).activeSosEvents.map((e) => e.id), ['sos-9']);
      n.debugReceiveSosResolved(other.copyWith(status: FamilySosStatus.resolved));
      expect(container.read(providerOfFamily).activeSosEvents, isEmpty);
      // The duplicate/late delivery.
      n.debugReceiveSos(other);
      expect(container.read(providerOfFamily).activeSosEvents, isEmpty,
          reason: 'an ended SOS never reopens from a replayed event');
      expect(container.read(providerOfFamily).sosHistory.map((e) => e.id), ['sos-9']);
      container.dispose();
    });

    test('an SOS for a circle I am no longer in is ignored', () async {
      final (:container, :service) = _setUp();
      final n = container.read(providerOfFamily.notifier);
      n.debugReceiveSos(other.copyWith(circleId: 'departed-circle'));
      expect(container.read(providerOfFamily).activeSosEvents, isEmpty);
      container.dispose();
    });

    test('a check-in for a departed circle does not touch state', () async {
      final (:container, :service) = _setUp();
      final n = container.read(providerOfFamily.notifier);
      n.debugReceiveCheckIn(const FamilyCheckIn(
        id: 'ci-1',
        circleId: 'departed-circle',
        memberId: 'amy-member',
      ));
      expect(container.read(providerOfFamily).recentCheckIns, isEmpty);
      container.dispose();
    });

    test('a server refresh that no longer lists an SOS ends it locally', () async {
      final (:container, :service) = _setUp();
      final n = container.read(providerOfFamily.notifier);
      n.debugReceiveSos(other);
      // The server (all circles) has nothing live any more.
      await n.refreshActiveSos();
      expect(container.read(providerOfFamily).activeSosEvents, isEmpty);
      n.debugReceiveSos(other);
      expect(container.read(providerOfFamily).activeSosEvents, isEmpty,
          reason: 'the server said it ended; a late socket copy is stale');
      container.dispose();
    });

    test('a resolved payload without memberId still parses', () {
      final event = FamilySosEvent.fromJson({
        'memberId': '',
        'status': 'resolved',
        'id': 'sos-lapsed',
        'circleId': 'c1',
      });
      expect(event.id, 'sos-lapsed');
      expect(event.status, FamilySosStatus.resolved);
    });
  });
}
