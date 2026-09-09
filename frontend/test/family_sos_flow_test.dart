import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/providers/states/family_provider_state.dart';
import 'package:hazard_app/features/family/services/family_service.dart';
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
  }) async {
    triggers += 1;
    active.add(_mine);
    if (triggerAnswerLost) return const Failure(AppError(message: 'timeout'));
    return const Success(_mine);
  }

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

({ProviderContainer container, _FakeFamilyService service}) _setUp() {
  late _FakeFamilyService service;
  final container = ProviderContainer(
    overrides: [
      providerOfFamilyService.overrideWith((ref) => service = _FakeFamilyService(ref)),
      providerOfFamily.overrideWith(
        (ref) => FamilyProvider(
          ref: ref,
          bootstrap: false,
          state: const FamilyProviderState(
            hasLoadedOnce: true,
            circle: FamilyCircle(id: 'c1', name: 'Nixons', myMemberId: 'me-member'),
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
    final direct = await notifier.triggerSos(isLive: false);
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
    await notifier.triggerSos(isLive: false);
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
    await notifier.triggerSos(isLive: false);
    service.resolveFails = true;
    final ok = await notifier.resolveSos(sosEventId: 'sos-1');
    expect(ok, isFalse);
    expect(container.read(providerOfFamily).activeSosEvents.map((e) => e.id), ['sos-1']);
  });
}
