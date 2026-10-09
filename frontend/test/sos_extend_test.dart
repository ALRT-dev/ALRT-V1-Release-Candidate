import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/providers/states/family_provider_state.dart';
import 'package:hazard_app/features/family/services/family_service.dart';
import 'package:hazard_app/features/family/services/sos_api.dart';
import 'package:hazard_app/features/family/utils/sos_preview.dart';
import 'package:hazard_app/features/family/utils/sos_timing.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_receiver_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_resolved_screen.dart';
import 'package:hazard_app/features/notification/enums/push_notification_types.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

/// SOS lasts 1 hour (3 Oct 2026): the sender sees "Live until [time]" and
/// can extend by an hour; an SOS that ran out its hour reads "This SOS
/// expired at [time]." Widget and unit tests only.

final _start = DateTime(2026, 10, 6, 14, 45);
final _end = DateTime(2026, 10, 6, 15, 45);
final _extended = DateTime(2026, 10, 6, 16, 50);

FamilySosEvent _sos({
  final DateTime? liveUntil,
  final FamilySosStatus status = FamilySosStatus.active,
  final DateTime? resolvedAt,
  final String? endedByMemberId,
}) => FamilySosEvent(
  id: 'sos-1',
  circleId: 'c1',
  memberId: 'me-member',
  isLive: false,
  locationMode: 'none',
  status: status,
  createdAt: _start,
  liveUntil: liveUntil,
  resolvedAt: resolvedAt,
  endedByMemberId: endedByMemberId,
);

class _FakeService extends FamilyService {
  _FakeService(super.ref);

  @override
  Future<Either<List<FamilySosEvent>, AppError>>
  getAllActiveFamilySosEvents() async => Success(List.of(_server));

  @override
  Future<Either<FamilySosTrail, AppError>> getFamilySosTrail({
    required final String sosEventId,
  }) async => Success(FamilySosTrail(sosEventId: sosEventId));
}

/// What the server lists as live; an accepted extend moves its end time.
final _server = <FamilySosEvent>[];

class _FakeSosApi extends SosApi {
  _FakeSosApi({this.error}) : super(dio: Dio(), circleId: () => 'c1');

  final AppError? error;
  final extended = <String>[];

  @override
  Future<Either<DateTime?, AppError>> extend({
    required final String sosEventId,
  }) async {
    extended.add(sosEventId);
    final e = error;
    if (e != null) return Failure(e);
    for (var i = 0; i < _server.length; i++) {
      if (_server[i].id == sosEventId) {
        _server[i] = _server[i].copyWith(liveUntil: _extended);
      }
    }
    return Success(_extended);
  }
}

Widget _host(
  final Widget child, {
  required final SosApi sosApi,
  required final List<FamilySosEvent> active,
  final List<FamilySosEvent> serverActive = const [],
  final List<FamilySosEvent> history = const [],
}) {
  _server
    ..clear()
    ..addAll(serverActive);
  return ProviderScope(
    overrides: [
      providerOfFamilyService.overrideWith(_FakeService.new),
      providerOfSosApi.overrideWithValue(sosApi),
      providerOfFamily.overrideWith(
        (ref) => FamilyProvider(
          ref: ref,
          bootstrap: false,
          state: FamilyProviderState(
            hasLoadedOnce: true,
            activeSosEvents: active,
            sosHistory: history,
            circle: const FamilyCircle(
              id: 'c1',
              name: 'Nixons',
              myMemberId: 'me-member',
              members: [
                FamilyMember(id: 'me-member', userId: 'me', name: 'Me'),
                FamilyMember(id: 'a1', userId: 'ua1', name: 'Alex'),
              ],
            ),
          ),
        ),
      ),
    ],
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => MaterialApp(home: child),
    ),
  );
}

void main() {
  group('SOS timing', () {
    test('an SOS never extended runs 1 hour from the start', () {
      final sos = _sos();
      expect(sosLiveUntil(sos), _end);
      expect(sosLiveUntilLine(sos), 'Live until 3:45 pm');
    });

    test('liveUntil from the backend wins once extended', () {
      expect(sosLiveUntilLine(_sos(liveUntil: _extended)), 'Live until 4:50 pm');
    });

    test('expired: no one ended it and it stopped at its end time', () {
      final sos = _sos(
        status: FamilySosStatus.resolved,
        resolvedAt: _end.add(const Duration(seconds: 40)),
      );
      expect(sosExpired(sos), isTrue);
      expect(sosExpiredLine(sos), 'This SOS expired at 3:45 pm.');
      final extendedThenExpired = _sos(
        status: FamilySosStatus.resolved,
        liveUntil: _extended,
        resolvedAt: _extended.add(const Duration(seconds: 50)),
      );
      expect(sosExpiredLine(extendedThenExpired), 'This SOS expired at 4:50 pm.');
    });

    test('ended by the sender, or early: never called expired', () {
      expect(
        sosExpired(
          _sos(
            status: FamilySosStatus.resolved,
            resolvedAt: _end.add(const Duration(minutes: 5)),
            endedByMemberId: 'me-member',
          ),
        ),
        isFalse,
      );
      expect(
        sosExpired(
          _sos(
            status: FamilySosStatus.resolved,
            resolvedAt: _start.add(const Duration(minutes: 10)),
          ),
        ),
        isFalse,
      );
      expect(sosExpired(_sos()), isFalse, reason: 'still active');
      expect(sosExpiredLine(_sos()), isNull);
    });

    test('a refused extend gets a friendly reason', () {
      expect(
        extendSosErrorMessage(const AppError(message: 'x', code: '409')),
        'This SOS has already ended, so it can\'t be extended.',
      );
      expect(
        extendSosErrorMessage(const AppError(message: 'x', code: '404')),
        contains('already ended'),
      );
      expect(
        extendSosErrorMessage(const AppError(message: 'x')),
        'We couldn\'t extend your SOS. Check your connection and try again.',
      );
    });

    test('SOS copy says 1 hour, never 4 hours', () {
      final p = LocalSosPreview(names: const ['Alex'], live: true);
      expect(p.locationLine, contains(kSosDurationLine));
      expect(p.locationLine, isNot(contains('4 hours')));
      expect(kSosDurationLine, 'SOS lasts 1 hour. You can extend it or end it.');
    });

    test('the ending-soon push is a known type', () {
      expect(
        PushNotificationType.values.byName('familySosEndingSoon'),
        PushNotificationType.familySosEndingSoon,
      );
    });
  });

  group('the sender\'s running SOS', () {
    setUp(() {
      final view =
          TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
      view.physicalSize = const Size(1080, 2340);
      view.devicePixelRatio = 3.0;
    });
    tearDown(() {
      final view =
          TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    Future<void> close(WidgetTester tester) async {
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    }

    testWidgets('shows Live until, and Extend 1 hour moves it on', (
      tester,
    ) async {
      final api = _FakeSosApi();
      final sos = _sos();
      await tester.pumpWidget(
        _host(
          FamilySosReceiverScreen(
            args: FamilySosReceiverScreenArgs(sosEvent: sos),
          ),
          sosApi: api,
          active: [sos],
          serverActive: [sos],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Live until 3:45 pm'), findsOneWidget);
      expect(find.text(kSosDurationLine), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('sos-extend')));
      await tester.tap(find.byKey(const Key('sos-extend')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(api.extended, ['sos-1']);
      expect(find.text('Live until 4:50 pm'), findsOneWidget);
      await close(tester);
    });

    testWidgets('a refused extend says so and keeps the SOS screen', (
      tester,
    ) async {
      final api = _FakeSosApi(
        error: const AppError(message: 'This SOS has ended', code: '409'),
      );
      final sos = _sos();
      await tester.pumpWidget(
        _host(
          FamilySosReceiverScreen(
            args: FamilySosReceiverScreenArgs(sosEvent: sos),
          ),
          sosApi: api,
          active: [sos],
          serverActive: [sos],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.ensureVisible(find.byKey(const Key('sos-extend')));
      await tester.tap(find.byKey(const Key('sos-extend')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 600));

      expect(api.extended, ['sos-1']);
      expect(
        find.text('This SOS has already ended, so it can\'t be extended.'),
        findsOneWidget,
      );
      expect(find.text('Live until 3:45 pm'), findsOneWidget);
      await close(tester);
    });

    testWidgets('an expired SOS reads "This SOS expired at [time]."', (
      tester,
    ) async {
      final expired = _sos(
        status: FamilySosStatus.resolved,
        resolvedAt: _end,
      );
      await tester.pumpWidget(
        _host(
          FamilySosReceiverScreen(
            args: FamilySosReceiverScreenArgs(sosEvent: expired),
          ),
          sosApi: _FakeSosApi(),
          active: const [],
          history: [expired],
        ),
      );
      await tester.pump();
      expect(find.text('This SOS expired at 3:45 pm.'), findsOneWidget);
      expect(find.byKey(const Key('sos-extend')), findsNothing);
      expect(find.textContaining('ended their SOS'), findsNothing);
      await close(tester);
    });

    testWidgets('the after-event record says it expired, not who stopped it', (
      tester,
    ) async {
      final expired = _sos(
        status: FamilySosStatus.resolved,
        resolvedAt: _end,
      ).copyWith(
        member: const FamilyMemberSnippet(id: 'me-member', nickname: 'Sam'),
      );
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, __) => ProviderScope(
            child: MaterialApp(
              home: FamilySosResolvedScreen(
                args: FamilySosResolvedScreenArgs(event: expired),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('This SOS expired at 3:45 pm.'), findsOneWidget);
      expect(find.textContaining('stopped sharing'), findsNothing);
    });
  });
}
