import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/providers/selected_circle_provider.dart';
import 'package:hazard_app/features/family/providers/states/family_provider_state.dart';
import 'package:hazard_app/features/family/services/family_service.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

/// Leaving a circle used to wipe the state to "no circles" and stop; the
/// next background list refresh then repopulated the list while no
/// circle was in scope, and the Family tab sat on a spinner for ever.
/// These tests pin the corrected behaviour: after leaving, the provider
/// loads the next circle (or truthfully has none), a failed request
/// reports an error the screen can act on, and a request whose answer
/// was lost is recognised by asking the server which circles remain.
class _FakeFamilyService extends FamilyService {
  _FakeFamilyService(super.ref);

  /// Circles the server says I am in, by id -> summary.
  final circles = <String, FamilyCircleSummary>{};
  bool leaveFails = false;
  bool leaveSucceedsServerSideButAnswerLost = false;
  int leaveCalls = 0;
  int circleFetches = 0;

  FamilyCircle _detail(final FamilyCircleSummary s) => FamilyCircle(
        id: s.circleId,
        name: s.name,
        myMemberId: s.myMemberId,
        members: [
          FamilyMember(id: s.myMemberId, userId: 'me', name: 'Me'),
        ],
      );

  /// What the server reports the leave did.
  FamilyLeaveOutcome leaveOutcome = FamilyLeaveOutcome.left;

  @override
  Future<Either<FamilyLeaveOutcome, AppError>> leaveFamilyCircle() async {
    leaveCalls += 1;
    if (leaveSucceedsServerSideButAnswerLost) {
      circles.remove('a');
      return const Failure(AppError(message: 'connection lost'));
    }
    if (leaveFails) return const Failure(AppError(message: 'server said no'));
    circles.remove('a');
    return Success(leaveOutcome);
  }

  @override
  Future<Either<List<FamilySosEvent>, AppError>> getAllActiveFamilySosEvents() async =>
      const Success([]);

  @override
  Future<Either<List<FamilySosList>, AppError>> getFamilySosLists() async =>
      const Success([]);

  @override
  Future<Either<List<FamilyCircleSummary>, AppError>> getFamilyCircles() async =>
      Success(circles.values.toList());

  @override
  Future<Either<FamilyCircle?, AppError>> getFamilyCircle() async {
    circleFetches += 1;
    final first = circles.values.firstOrNull;
    return Success(first == null ? null : _detail(first));
  }

  @override
  Future<Either<List<FamilyCheckIn>, AppError>> getFamilyCheckIns({
    final int? limit,
  }) async =>
      const Success([]);

  @override
  Future<Either<List<FamilySosEvent>, AppError>> getActiveFamilySosEvents() async =>
      const Success([]);

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

const _a = FamilyCircleSummary(circleId: 'a', name: 'A', myMemberId: 'm-a');
const _b = FamilyCircleSummary(circleId: 'b', name: 'B', myMemberId: 'm-b');

({ProviderContainer container, _FakeFamilyService service}) _setUp({
  required final List<FamilyCircleSummary> memberships,
}) {
  late _FakeFamilyService service;
  final container = ProviderContainer(
    overrides: [
      providerOfFamilyService.overrideWith((ref) {
        service = _FakeFamilyService(ref);
        for (final c in memberships) {
          service.circles[c.circleId] = c;
        }
        return service;
      }),
      providerOfFamily.overrideWith(
        (ref) => FamilyProvider(
          ref: ref,
          bootstrap: false,
          state: FamilyProviderState(
            hasLoadedOnce: true,
            circles: memberships,
            circle: FamilyCircle(
              id: memberships.first.circleId,
              name: memberships.first.name,
              myMemberId: memberships.first.myMemberId,
            ),
            activeSosEvents: const [
              FamilySosEvent(id: 'sos-a', circleId: 'a', memberId: 'x'),
            ],
          ),
        ),
      ),
    ],
  );
  container.read(providerOfFamilyService); // builds the fake
  container.read(providerOfSelectedCircleId.notifier).select('a');
  return (container: container, service: service);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('leaving one of two circles lands on the other, with a fresh scope', () async {
    final (:container, :service) = _setUp(memberships: [_a, _b]);
    await container.read(providerOfFamily.notifier).leave();
    final s = container.read(providerOfFamily);
    expect(service.leaveCalls, 1);
    expect(s.leaveDeleteState.isSuccess, isTrue);
    expect(s.circles.map((c) => c.circleId), ['b']);
    expect(s.circle?.id, 'b', reason: 'the next circle is loaded, not a spinner');
    expect(s.activeSosEvents, isEmpty, reason: 'the departed circle\'s SOS is gone');
    expect(container.read(providerOfSelectedCircleId), isNull);
  });

  test('leaving the last circle leaves a truthful no-circle state', () async {
    final (:container, :service) = _setUp(memberships: [_a]);
    await container.read(providerOfFamily.notifier).leave();
    final s = container.read(providerOfFamily);
    expect(s.leaveDeleteState.isSuccess, isTrue);
    expect(s.circles, isEmpty);
    expect(s.circle, isNull);
    expect(s.hasLoadedOnce, isTrue);
    expect(s.loadState.isSuccess, isTrue, reason: 'the tab shows onboarding, not an error');
    expect(service.circleFetches, greaterThan(0));
  });

  test('a refused leave keeps the circle and reports the error', () async {
    final (:container, :service) = _setUp(memberships: [_a, _b]);
    service.leaveFails = true;
    await container.read(providerOfFamily.notifier).leave();
    final s = container.read(providerOfFamily);
    expect(s.leaveDeleteState.isError, isTrue);
    expect(s.leaveDeleteState.error?.message, 'server said no');
    expect(s.circle?.id, 'a', reason: 'still a member, still in scope');
    expect(s.circles.length, 2);
  });

  test('a leave whose answer was lost is recognised from the server, never retried blindly', () async {
    final (:container, :service) = _setUp(memberships: [_a, _b]);
    service.leaveSucceedsServerSideButAnswerLost = true;
    await container.read(providerOfFamily.notifier).leave();
    final s = container.read(providerOfFamily);
    expect(service.leaveCalls, 1);
    expect(s.leaveDeleteState.isSuccess, isTrue, reason: 'the server no longer lists circle a');
    expect(s.circle?.id, 'b');
  });
}
