import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/providers/states/family_provider_state.dart';
import 'package:hazard_app/features/family/services/family_service.dart';
import 'package:hazard_app/features/family/services/sos_api.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_receiver_screen.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

/// SOS received (12 Oct 2026 mockups): a recipient's one response is
/// "I've seen this"; the group's host additionally gets "End this SOS as
/// host", which goes through the same resolve call as the sender's End
/// SOS. Nobody else can end someone's SOS, and nothing says "safe".

final _start = DateTime(2026, 10, 12, 9, 0);

const _alexSos = FamilySosEvent(
  id: 'sos-1',
  circleId: 'c1',
  memberId: 'a1',
  isLive: false,
  locationMode: 'none',
  member: FamilyMemberSnippet(id: 'a1', nickname: 'Alex'),
);

class _FakeService extends FamilyService {
  _FakeService(super.ref);

  final resolved = <String>[];

  @override
  Future<Either<List<FamilySosEvent>, AppError>>
  getAllActiveFamilySosEvents() async => Success(
    resolved.isEmpty ? [_alexSos.copyWith(createdAt: _start)] : const [],
  );

  @override
  Future<Either<FamilySosTrail, AppError>> getFamilySosTrail({
    required final String sosEventId,
  }) async => Success(FamilySosTrail(sosEventId: sosEventId));

  @override
  Future<Either<FamilySosEvent, AppError>> resolveFamilySos({
    required final String sosEventId,
  }) async {
    resolved.add(sosEventId);
    return Success(
      _alexSos.copyWith(
        status: FamilySosStatus.resolved,
        resolvedAt: _start.add(const Duration(minutes: 20)),
        endedByMemberId: 'me-member',
      ),
    );
  }
}

class _FakeSosApi extends SosApi {
  _FakeSosApi() : super(dio: Dio(), circleId: () => 'c1');
}

({Widget app, _FakeService Function() service}) _build({
  required final bool iAmHost,
}) {
  late _FakeService service;
  final sos = _alexSos.copyWith(createdAt: _start);
  final router = GoRouter(
    initialLocation: FamilySosReceiverScreen.route,
    routes: [
      GoRoute(
        path: FamilySosReceiverScreen.route,
        builder: (_, __) => FamilySosReceiverScreen(
          args: FamilySosReceiverScreenArgs(sosEvent: sos),
        ),
      ),
    ],
  );
  final app = ProviderScope(
    overrides: [
      providerOfFamilyService.overrideWith(
        (ref) => service = _FakeService(ref),
      ),
      providerOfSosApi.overrideWithValue(_FakeSosApi()),
      providerOfFamily.overrideWith(
        (ref) => FamilyProvider(
          ref: ref,
          bootstrap: false,
          state: FamilyProviderState(
            hasLoadedOnce: true,
            activeSosEvents: [sos],
            circle: FamilyCircle(
              id: 'c1',
              name: 'Nixons',
              myMemberId: 'me-member',
              members: [
                FamilyMember(
                  id: 'me-member',
                  userId: 'me',
                  name: 'Me',
                  role: iAmHost ? FamilyRole.owner : FamilyRole.adult,
                ),
                const FamilyMember(
                  id: 'a1',
                  userId: 'ua1',
                  name: 'Alex',
                  role: FamilyRole.owner,
                ),
              ],
            ),
          ),
        ),
      ),
    ],
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => MaterialApp.router(routerConfig: router),
    ),
  );
  return (app: app, service: () => service);
}

Future<void> _close(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 10));
  await tester.pumpWidget(const SizedBox());
  await tester.pump();
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
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

  testWidgets('a recipient who is not the host: "I\'ve seen this" only, '
      'never an end control, never "On my way"', (tester) async {
    final t = _build(iAmHost: false);
    await tester.pumpWidget(t.app);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('SOS FROM'), findsOneWidget);
    expect(find.text('Alex'), findsOneWidget);
    expect(find.byKey(const Key('sos-seen')), findsOneWidget);
    expect(find.text("I've seen this"), findsOneWidget);
    expect(find.byKey(const Key('sos-host-end')), findsNothing);
    expect(find.textContaining('On my way'), findsNothing);
    expect(find.byKey(const Key('sos-extend')), findsNothing);
    await _close(tester);
  });

  testWidgets('the host sees "End this SOS as host"; confirming ends it '
      'through the resolve call and the record reads factually', (
    tester,
  ) async {
    final t = _build(iAmHost: true);
    await tester.pumpWidget(t.app);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('sos-seen')), findsOneWidget);
    final end = find.byKey(const Key('sos-host-end'));
    await tester.ensureVisible(end);
    await tester.pump();
    await tester.tap(end);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text("End Alex's SOS as host?"), findsOneWidget);
    await tester.tap(find.text('End SOS'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(t.service().resolved, ['sos-1']);
    expect(find.text('Alex ended their SOS.'), findsOneWidget);
    expect(find.byKey(const Key('sos-seen')), findsNothing);
    expect(find.byKey(const Key('sos-host-end')), findsNothing);
    expect(find.textContaining('safe'), findsNothing);
    expect(find.textContaining('resolved'), findsNothing);
    await _close(tester);
  });
}
