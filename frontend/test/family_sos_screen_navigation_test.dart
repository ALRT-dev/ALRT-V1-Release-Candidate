import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/providers/states/family_provider_state.dart';
import 'package:hazard_app/features/family/services/family_location_service.dart';
import 'package:hazard_app/features/family/services/family_service.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_screen.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';
import 'package:hazard_app/features/home/providers/home_tab_provider.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

/// Issue 1, reproduced through real navigation: the SOS send screen is
/// pushed on a router, the hold completes, and the screen must leave by
/// itself for the Family tab once the server confirms. Provider tests
/// had not caught the phone's behaviour; this pumps the actual screen.
class _FakeFamilyService extends FamilyService {
  _FakeFamilyService(super.ref);
  bool fail = false;
  bool answerLost = false;
  int triggers = 0;
  static const _mine = FamilySosEvent(
    id: 'sos-1',
    circleId: 'c1',
    memberId: 'me-member',
  );

  @override
  Future<Either<FamilySosEvent, AppError>> triggerFamilySos({
    final double? latitude,
    final double? longitude,
    final String? sosListId,
    required final bool isLive,
  }) async {
    triggers += 1;
    if (fail) return const Failure(AppError(message: 'server said no'));
    if (answerLost) return const Failure(AppError(message: 'timeout'));
    return const Success(_mine);
  }

  @override
  Future<Either<List<FamilySosEvent>, AppError>>
  getAllActiveFamilySosEvents() async =>
      Success(answerLost ? const [_mine] : const []);

  @override
  Future<Either<List<FamilySosEvent>, AppError>>
  getActiveFamilySosEvents() async => getAllActiveFamilySosEvents();

  @override
  Future<Either<List<FamilySosList>, AppError>> getFamilySosLists() async =>
      const Success([]);
}

class _NoLocation extends FamilyLocationService {
  _NoLocation(super.ref);
  @override
  Future<Position?> getLastKnownOrCurrentPosition() async => null;
}

({
  Widget app,
  GoRouter router,
  _FakeFamilyService Function() service,
  ProviderContainer Function() container,
})
_build() {
  late _FakeFamilyService service;
  late ProviderContainer container;
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () => context.push(FamilySosScreen.route),
                child: const Text('open sos'),
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: FamilySosScreen.route,
        builder: (_, __) => const FamilySosScreen(),
      ),
    ],
  );
  final app = ProviderScope(
    overrides: [
      providerOfFamilyService.overrideWith(
        (ref) => service = _FakeFamilyService(ref),
      ),
      providerOfFamilyLocationService.overrideWith((ref) => _NoLocation(ref)),
      providerOfFamily.overrideWith(
        (ref) => FamilyProvider(
          ref: ref,
          bootstrap: false,
          state: const FamilyProviderState(
            hasLoadedOnce: true,
            circle: FamilyCircle(
              id: 'c1',
              name: 'Nixons',
              myMemberId: 'me-member',
            ),
          ),
        ),
      ),
    ],
    child: Builder(
      builder: (context) {
        container = ProviderScope.containerOf(context);
        return ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, __) => MaterialApp.router(routerConfig: router),
        );
      },
    ),
  );
  return (
    app: app,
    router: router,
    service: () => service,
    container: () => container,
  );
}

Future<void> _holdToSend(WidgetTester tester) async {
  final button = find.byKey(const Key('sos-hold-button'));
  expect(button, findsOneWidget);
  final gesture = await tester.startGesture(tester.getCenter(button));
  // The body scrolls on short phones, so the tap recognizer only claims
  // the pointer after its deadline; then the hold animation needs a
  // first frame to start its clock before three seconds can elapse.
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pump(const Duration(milliseconds: 1500));
  await tester.pump(const Duration(milliseconds: 1500));
  await tester.pump(const Duration(milliseconds: 100));
  await gesture.up();
  await tester.pump();
}

/// Tears the tree down so the container (and the provider's periodic
/// timers) are disposed before the test ends.
Future<void> _teardown(WidgetTester tester) async {
  // Let any toast run its course, then drop the tree.
  await tester.pump(const Duration(seconds: 10));
  await tester.pumpWidget(const SizedBox());
  await tester.pump();
}

void main() {
  // A phone-sized surface: the send screen is laid out for one.
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

  testWidgets(
    'after the server confirms, the screen leaves for Family by itself',
    (tester) async {
      final t = _build();
      await tester.pumpWidget(t.app);
      await tester.pumpAndSettle();
      await tester.tap(find.text('open sos'));
      await tester.pumpAndSettle();
      expect(find.byType(FamilySosScreen), findsOneWidget);

      await _holdToSend(tester);
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        find.text('SOS sent'),
        findsOneWidget,
        reason: 'the tick shows for a moment',
      );
      expect(t.service().triggers, 1);

      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();
      expect(
        find.byType(FamilySosScreen),
        findsNothing,
        reason: 'no extra tap was needed',
      );
      expect(
        find.text('open sos'),
        findsOneWidget,
        reason: 'back on the screen below',
      );
      expect(t.container().read(providerOfHomeTab), HomeTab.family);
      expect(
        t.container().read(providerOfFamily).activeSosEvents.map((e) => e.id),
        ['sos-1'],
      );
      await _teardown(tester);
    },
  );

  testWidgets(
    'Done before the timer leaves once, and the timer never navigates again',
    (tester) async {
      final t = _build();
      await tester.pumpWidget(t.app);
      await tester.pumpAndSettle();
      await tester.tap(find.text('open sos'));
      await tester.pumpAndSettle();
      await _holdToSend(tester);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('open sos'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();
      expect(
        find.text('open sos'),
        findsOneWidget,
        reason: 'still on the screen below, not on a fresh home',
      );
      expect(t.container().read(providerOfHomeTab), HomeTab.family);
      await _teardown(tester);
    },
  );

  testWidgets('a failed send shows an error and stays, never a success', (
    tester,
  ) async {
    final t = _build();
    await tester.pumpWidget(t.app);
    await tester.pumpAndSettle();
    await tester.tap(find.text('open sos'));
    await tester.pumpAndSettle();
    t.service().fail = true;
    await _holdToSend(tester);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('SOS sent'), findsNothing);
    expect(find.byType(FamilySosScreen), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.byType(FamilySosScreen), findsOneWidget);
    expect(t.container().read(providerOfFamily).activeSosEvents, isEmpty);
    await _teardown(tester);
  });

  testWidgets('a lost answer is found on the server and sent once', (
    tester,
  ) async {
    final t = _build();
    await tester.pumpWidget(t.app);
    await tester.pumpAndSettle();
    await tester.tap(find.text('open sos'));
    await tester.pumpAndSettle();
    t.service().answerLost = true;
    await _holdToSend(tester);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('SOS sent'), findsOneWidget);
    expect(t.service().triggers, 1);
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    expect(find.byType(FamilySosScreen), findsNothing);
    await _teardown(tester);
  });

  testWidgets(
    'a second hold while the first is in flight sends nothing extra',
    (tester) async {
      final t = _build();
      await tester.pumpWidget(t.app);
      await tester.pumpAndSettle();
      await tester.tap(find.text('open sos'));
      await tester.pumpAndSettle();
      await _holdToSend(tester);
      await _holdToSend(tester).catchError((_) {});
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();
      expect(t.service().triggers, 1);
      await _teardown(tester);
    },
  );
}
