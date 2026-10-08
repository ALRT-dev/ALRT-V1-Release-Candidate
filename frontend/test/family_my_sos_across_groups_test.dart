import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/providers/states/family_provider_state.dart';
import 'package:hazard_app/features/family/services/family_location_service.dart';
import 'package:hazard_app/features/family/services/family_service.dart';
import 'package:hazard_app/features/family/services/location_fix.dart';
import 'package:hazard_app/features/shared/models/app_user_model.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

// Live SOS location used to stop silently: the loop asked whether the SOS
// was sent by "my member id in the group in scope", and member ids differ
// per group, so switching group (or an app restart, which never started
// the loop at all) ended it. My SOS is found by my user id now, and the
// loop is (re)started from what the server holds. The same for journeys:
// mine are loaded across every group so their points keep going.

/// Group A: where I sent the SOS from (my member id there: m-a).
/// Group B: the group in scope (my member id there: m-b).
const _a = FamilyCircleSummary(circleId: 'a', name: 'A', myMemberId: 'm-a');
const _b = FamilyCircleSummary(circleId: 'b', name: 'B', myMemberId: 'm-b');

FamilySosEvent _sos({
  final String id = 'sos-a',
  final String memberId = 'm-a',
  final String userId = 'me',
  final String? locationMode = 'live',
}) => FamilySosEvent(
  id: id,
  circleId: 'a',
  memberId: memberId,
  locationMode: locationMode,
  isLive: locationMode == 'live',
  member: FamilyMemberSnippet(
    id: memberId,
    user: FamilyMemberUserSnippet(id: userId),
  ),
);

class _FakeService extends FamilyService {
  _FakeService(super.ref);

  List<FamilySosEvent> active = const [];
  Map<String, FamilyJourney?> journeysByCircle = const {};

  @override
  Future<Either<List<FamilySosEvent>, AppError>>
  getAllActiveFamilySosEvents() async => Success(active);

  @override
  Future<Either<List<FamilyCircleSummary>, AppError>>
  getFamilyCircles() async => const Success([_a, _b]);

  @override
  Future<Either<FamilyCircle?, AppError>> getFamilyCircle() async =>
      const Success(
        FamilyCircle(id: 'b', name: 'B', myMemberId: 'm-b', members: []),
      );

  @override
  Future<Either<FamilyCircle?, AppError>> getFamilyCircleById(
    final String circleId,
  ) async => Success(
    FamilyCircle(id: circleId, name: circleId, myMemberId: 'm-$circleId'),
  );

  @override
  Future<Either<FamilyJourney?, AppError>> getMyFamilyJourneyIn(
    final String circleId,
  ) async => Success(journeysByCircle[circleId]);

  @override
  Future<Either<FamilyJourney?, AppError>> getMyFamilyJourney() async =>
      Success(journeysByCircle['b']);

  @override
  Future<Either<List<FamilyCheckIn>, AppError>> getFamilyCheckIns({
    final int? limit,
  }) async => const Success([]);

  @override
  Future<Either<List<FamilySosEvent>, AppError>> getFamilySosHistory() async =>
      const Success([]);

  @override
  Future<Either<List<FamilyLocationRequest>, AppError>>
  getPendingFamilyLocationRequests() async => const Success([]);

  @override
  Future<Either<List<FamilyJourney>, AppError>>
  getFamilyJourneysSharedWithMe() async => const Success([]);
}

/// No fix ever: nothing is posted, so nothing reaches the network.
class _NoLocation implements DeviceLocationSource {
  @override
  Future<bool> isServiceEnabled() async => false;
  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.denied;
  @override
  Future<LocationPermission> requestPermission() async =>
      LocationPermission.denied;
  @override
  Future<Position?> lastKnown() async => null;
  @override
  Future<Position> current({required final Duration timeout}) =>
      throw StateError('no fix');
}

({ProviderContainer container, _FakeService service}) _setUp() {
  late _FakeService service;
  final container = ProviderContainer(
    overrides: [
      providerOfFamilyService.overrideWith((ref) {
        service = _FakeService(ref);
        return service;
      }),
      providerOfDeviceLocationSource.overrideWithValue(_NoLocation()),
      providerOfLoggedInUser.overrideWith(
        (ref) => const AppUser(id: 'me', name: 'Me'),
      ),
      providerOfFamily.overrideWith(
        (ref) => FamilyProvider(
          ref: ref,
          bootstrap: false,
          state: const FamilyProviderState(
            hasLoadedOnce: true,
            circles: [_a, _b],
            // Group B is in scope; the SOS was sent from group A.
            circle: FamilyCircle(id: 'b', name: 'B', myMemberId: 'm-b'),
          ),
        ),
      ),
    ],
  );
  container.read(providerOfFamilyService);
  container.read(providerOfFamily);
  return (container: container, service: service);
}

void main() {
  test('my live SOS from another group starts its loop on refresh '
      '(app restart, group switch)', () async {
    final setup = _setUp();
    addTearDown(setup.container.dispose);
    setup.service.active = [_sos()];

    final notifier = setup.container.read(providerOfFamily.notifier);
    expect(notifier.sosLiveShareEventId, isNull);
    await notifier.refreshActiveSos();
    expect(
      notifier.sosLiveShareEventId,
      'sos-a',
      reason: 'member id m-a is not my id in group B, but the SOS is mine',
    );
  });

  test('someone else\'s live SOS never starts my loop', () async {
    final setup = _setUp();
    addTearDown(setup.container.dispose);
    setup.service.active = [_sos(memberId: 'm-tom', userId: 'tom')];

    final notifier = setup.container.read(providerOfFamily.notifier);
    await notifier.refreshActiveSos();
    expect(notifier.sosLiveShareEventId, isNull);
  });

  test('my SOS sent with no location or once starts no loop', () async {
    final setup = _setUp();
    addTearDown(setup.container.dispose);
    final notifier = setup.container.read(providerOfFamily.notifier);

    setup.service.active = [_sos(locationMode: 'none')];
    await notifier.refreshActiveSos();
    expect(notifier.sosLiveShareEventId, isNull);

    setup.service.active = [_sos(id: 'sos-b', locationMode: 'once')];
    await notifier.refreshActiveSos();
    expect(notifier.sosLiveShareEventId, isNull);
  });

  test('load restarts the loop and keeps my journey in another group '
      'posting', () async {
    final setup = _setUp();
    addTearDown(setup.container.dispose);
    setup.service.active = [_sos()];
    setup.service.journeysByCircle = {
      'a': FamilyJourney(
        id: 'j-a',
        circleId: 'a',
        memberId: 'm-a',
        endsAt: DateTime.now().add(const Duration(minutes: 30)),
      ),
      'b': null,
    };

    final notifier = setup.container.read(providerOfFamily.notifier);
    await notifier.load(silent: true);

    expect(notifier.sosLiveShareEventId, 'sos-a');
    expect(notifier.runningJourneyIds, {'j-a'});
    // The journey screen of group B has nothing running.
    expect(setup.container.read(providerOfFamily).activeJourney, isNull);
  });
}
