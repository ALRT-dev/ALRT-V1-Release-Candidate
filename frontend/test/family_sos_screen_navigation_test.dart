import 'package:hazard_app/features/family/views/screens/family_sos_list_edit_screen.dart';
import 'package:hazard_app/features/family/services/location_fix.dart';
import 'package:hazard_app/features/family/services/sos_api.dart';
import 'package:dio/dio.dart';
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
  double? lastLatitude;
  String? lastMode;
  String? lastPrecision;
  DateTime? lastCapturedAt;
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
    final String? locationMode,
    final String? locationPrecision,
    final DateTime? locationCapturedAt,
    final double? locationAccuracyM,
  }) async {
    triggers += 1;
    lastLatitude = latitude;
    lastMode = locationMode;
    lastPrecision = locationPrecision;
    lastCapturedAt = locationCapturedAt;
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

  List<FamilySosList> lists = const [];

  @override
  Future<Either<List<FamilySosList>, AppError>> getFamilySosLists() async =>
      Success(lists);
}

/// The backend's SOS preview, answered from fixed values.
class _FakeSosApi extends SosApi {
  _FakeSosApi(this.answer) : super(dio: Dio(), circleId: () => 'c1');
  final SosPreview? answer;
  final asked = <String?>[];

  @override
  Future<Either<SosPreview, AppError>> preview({final String? sosListId}) async {
    asked.add(sosListId);
    final a = answer;
    return a == null
        ? const Failure(AppError(message: 'offline'))
        : Success(a);
  }
}

/// A phone location source with nothing to report (tests that don't care).
class _NoFixSource implements DeviceLocationSource {
  @override
  Future<bool> isServiceEnabled() async => true;
  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.whileInUse;
  @override
  Future<LocationPermission> requestPermission() async =>
      LocationPermission.whileInUse;
  @override
  Future<Position?> lastKnown() async => null;
  @override
  Future<Position> current({required Duration timeout}) async =>
      throw Exception('no fix');
}

class _Source extends _NoFixSource {
  _Source({
    this.cachedAge,
    this.freshNow = false,
    this.denied = false,
    this.now = DateTime.now,
    this.cachedAt,
  });
  final Duration? cachedAge;
  bool freshNow;
  final bool denied;
  final DateTime Function() now;

  /// A fixed moment for the cached point (so it ages as the clock moves).
  final DateTime? cachedAt;
  Position _p(DateTime at) => Position(
    latitude: -27.47,
    longitude: 153.02,
    timestamp: at,
    accuracy: 15,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
  @override
  Future<LocationPermission> checkPermission() async =>
      denied ? LocationPermission.deniedForever : LocationPermission.whileInUse;
  @override
  Future<Position?> lastKnown() async => cachedAt != null
      ? _p(cachedAt!)
      : cachedAge == null
      ? null
      : _p(now().subtract(cachedAge!));
  @override
  Future<Position> current({required Duration timeout}) async =>
      freshNow ? _p(now()) : throw Exception('no fix');
}

const _okPreview = SosPreview(
  state: SosPreviewState.ok,
  recipients: [SosPreviewPerson(memberId: 'm2', name: 'Alex')],
  excluded: [],
);

class _NoLocation extends FamilyLocationService {
  _NoLocation(super.ref);
  @override
  Future<Position?> getCurrentPositionOrNull() async => null;
}

({
  Widget app,
  GoRouter router,
  _FakeFamilyService Function() service,
  ProviderContainer Function() container,
})
_build({
  bool withOthers = true,
  SosPreview? preview = _okPreview,
  DeviceLocationSource? source,
  List<FamilySosList> lists = const [],
  DateTime Function()? clock,
  FamilySharingLevel myLevel = FamilySharingLevel.precise,
}) {
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
      GoRoute(
        path: FamilySosListEditScreen.route,
        builder: (_, state) => Scaffold(
          body: Text(
            'editing ${(state.extra as FamilySosListEditScreenArgs?)?.list?.id ?? 'a new list'}',
          ),
        ),
      ),
    ],
  );
  final app = ProviderScope(
    overrides: [
      providerOfFamilyService.overrideWith(
        (ref) => service = _FakeFamilyService(ref)..lists = lists,
      ),
      providerOfSosApi.overrideWithValue(_FakeSosApi(preview)),
      providerOfDeviceLocationSource.overrideWithValue(
        source ?? _NoFixSource(),
      ),
      if (clock != null) providerOfLocationClock.overrideWithValue(clock),
      providerOfFamilyLocationService.overrideWith((ref) => _NoLocation(ref)),
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
              // Someone to reach: with nobody, the screen asks to invite
              // someone instead of offering the hold (sos_preview.dart).
              members: [
                FamilyMember(
                  id: 'me-member',
                  userId: 'me',
                  name: 'Me',
                  sharingLevel: myLevel,
                ),
                if (withOthers)
                  const FamilyMember(id: 'm2', userId: 'u2', name: 'Alex'),
              ],
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

/// The harness of the test running now (for tests that open it in a
/// shared helper).
({
  Widget app,
  GoRouter router,
  _FakeFamilyService Function() service,
  ProviderContainer Function() container,
})? _lastBuild;

Future<void> _holdToSend(WidgetTester tester) async {
  final button = find.byKey(const Key('sos-hold-button'));
  expect(button, findsOneWidget);
  // The screen scrolls: bring the button into view as a person would.
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
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

  Future<void> openSos(WidgetTester tester, Widget app) async {
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    await tester.tap(find.text('open sos'));
    await tester.pumpAndSettle();
  }

  Finder rich(String text) => find.textContaining(text, findRichText: true);

  testWidgets('before sending: the backend\'s recipients, who is left out and '
      'why, delivery not promised, and the three location choices', (
    tester,
  ) async {
    final t = _build(
      source: _Source(freshNow: true),
      preview: const SosPreview(
        state: SosPreviewState.ok,
        recipients: [
          SosPreviewPerson(memberId: 'm2', name: 'Alex', deliveryLimited: true),
        ],
        excluded: [
          SosPreviewPerson(
            memberId: 'm3',
            name: 'Taylor',
            reason: 'needs_individual',
          ),
        ],
      ),
    );
    await openSos(tester, t.app);
    expect(rich('Goes to: Alex'), findsOneWidget);
    expect(rich('Taylor (needs ALRT + here)'), findsOneWidget);
    expect(rich('May not be notified: Alex'), findsOneWidget);
    expect(rich('can\'t promise delivery'), findsOneWidget);
    expect(find.textContaining('Your location now'), findsOneWidget);
    // Default with a current fix: live, visibly.
    expect(rich('live location, updating'), findsOneWidget);
    await tester.tap(find.byKey(const Key('sos-loc-once')));
    await tester.pumpAndSettle();
    expect(rich('Where you are now, once'), findsOneWidget);
    await tester.tap(find.byKey(const Key('sos-loc-none')));
    await tester.pumpAndSettle();
    expect(rich('Location: None.'), findsOneWidget);
    expect(find.byKey(const Key('sos-hold-button')), findsOneWidget);
    await _teardown(tester);
  });

  testWidgets('nobody in the group: no hold button, an invite instead', (
    tester,
  ) async {
    final t = _build(
      withOthers: false,
      preview: const SosPreview(
        state: SosPreviewState.noPeople,
        recipients: [],
        excluded: [],
      ),
    );
    await openSos(tester, t.app);
    expect(find.byKey(const Key('sos-hold-button')), findsNothing);
    expect(find.byKey(const Key('sos-nobody')), findsOneWidget);
    expect(find.text('Invite someone'), findsOneWidget);
    expect(t.service().triggers, 0);
    await _teardown(tester);
  });

  testWidgets('people exist but none can receive it: says so, never "invite '
      'someone"', (tester) async {
    final t = _build(
      preview: const SosPreview(
        state: SosPreviewState.noneEligible,
        recipients: [],
        excluded: [
          SosPreviewPerson(
            memberId: 'm2',
            name: 'Alex',
            reason: 'sponsorship_paused',
          ),
        ],
      ),
    );
    await openSos(tester, t.app);
    expect(find.byKey(const Key('sos-none-eligible')), findsOneWidget);
    expect(rich("Alex (this group's plan has ended)"), findsOneWidget);
    expect(find.text('Invite someone'), findsNothing);
    expect(find.byKey(const Key('sos-hold-button')), findsNothing);
    await _teardown(tester);
  });

  testWidgets('a list that needs repair opens THAT list, not a blank one', (
    tester,
  ) async {
    const list = FamilySosList(
      id: 'l1',
      ownerUserId: 'me',
      name: 'Close',
      isDefault: true,
      memberIds: ['elsewhere'],
    );
    final t = _build(
      lists: const [list],
      preview: const SosPreview(
        state: SosPreviewState.presetInvalid,
        recipients: [],
        excluded: [],
        preset: SosPresetStatus(
          id: 'l1',
          name: 'Close',
          state: 'otherGroup',
          removedCount: 0,
          otherGroupCount: 1,
        ),
      ),
    );
    await openSos(tester, t.app);
    expect(find.byKey(const Key('sos-preset-invalid')), findsOneWidget);
    expect(find.textContaining('people from another group'), findsOneWidget);
    expect(find.byKey(const Key('sos-hold-button')), findsNothing);
    await tester.ensureVisible(find.text('Edit "Close"'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit "Close"'));
    await tester.pumpAndSettle();
    expect(find.text('editing l1'), findsOneWidget);
    await _teardown(tester);
  });

  testWidgets('last known location: its age is shown, nothing is shared '
      'until chosen, and "once" says how old it is', (tester) async {
    final t = _build(source: _Source(cachedAge: const Duration(minutes: 12)));
    await openSos(tester, t.app);
    expect(
      find.textContaining('Last known location: 12 min ago'),
      findsOneWidget,
    );
    expect(find.textContaining('now (about'), findsNothing);
    expect(rich('without your location'), findsOneWidget, reason: 'default');
    await tester.tap(find.byKey(const Key('sos-loc-once')));
    await tester.pumpAndSettle();
    expect(
      rich('Your last known location (12 min ago), once.'),
      findsOneWidget,
    );
    await _teardown(tester);
  });

  testWidgets('permission denied: sharing options are off, the SOS can still '
      'be sent', (tester) async {
    final t = _build(source: _Source(denied: true));
    await openSos(tester, t.app);
    expect(find.textContaining('isn\'t allowed to use your location'), findsWidgets);
    await tester.tap(find.byKey(const Key('sos-loc-once')));
    await tester.pumpAndSettle();
    expect(rich('Location: None.'), findsOneWidget, reason: 'choice unchanged');
    expect(find.text('You can still send your SOS without location.'), findsOneWidget);
    expect(find.byKey(const Key('sos-hold-button')), findsOneWidget);
    await _teardown(tester);
  });

  testWidgets('preview unreachable: the phone\'s guess is shown as unchecked, '
      'the send still re-checks', (tester) async {
    final t = _build(preview: null);
    await openSos(tester, t.app);
    expect(rich('Not checked:'), findsOneWidget);
    expect(find.byKey(const Key('sos-hold-button')), findsOneWidget);
    await _teardown(tester);
  });

  // ---- Review of cb26a8d, finding 3: freshness is judged at send ----

  group('a fix that was fresh at open and has aged by send', () {
    final t0 = DateTime(2026, 9, 29, 10);
    late DateTime clockNow;
    DateTime clock() => clockNow;

    Future<_Source> openFresh(
      WidgetTester tester, {
      bool refreshAtSend = false,
    }) async {
      clockNow = t0;
      final source = _Source(
        cachedAt: t0.subtract(const Duration(seconds: 10)),
        now: clock,
      );
      final t = _build(source: source, clock: clock);
      await openSos(tester, t.app);
      expect(find.textContaining('Your location now'), findsOneWidget);
      // Time moves on past the two-minute window while the screen is open.
      clockNow = t0.add(const Duration(minutes: 3));
      await tester.pump(const Duration(seconds: 16));
      source.freshNow = refreshAtSend;
      _lastBuild = t;
      return source;
    }

    testWidgets('the screen relabels it as last known with its age', (
      tester,
    ) async {
      await openFresh(tester);
      expect(
        find.textContaining('Last known location: 3 min ago'),
        findsOneWidget,
      );
      expect(find.textContaining('Your location now'), findsNothing);
      await _teardown(tester);
    });

    testWidgets('Once: the old point is sent only because it was shown as '
        'last known, with its real capture time', (tester) async {
      await openFresh(tester);
      await tester.tap(find.byKey(const Key('sos-loc-once')));
      await tester.pumpAndSettle();
      expect(
        rich('Your last known location (3 min ago), once.'),
        findsOneWidget,
      );
      await _holdToSend(tester);
      await tester.pump(const Duration(milliseconds: 100));
      final s = _lastBuild!.service();
      expect(s.lastMode, 'once');
      expect(s.lastLatitude, isNotNull);
      expect(
        s.lastCapturedAt,
        t0.subtract(const Duration(seconds: 10)),
        reason: 'its real time, never "now"',
      );
      await _teardown(tester);
    });

    testWidgets('Live: the stale point is never the starting point', (
      tester,
    ) async {
      await openFresh(tester);
      await tester.tap(find.byKey(const Key('sos-loc-live')));
      await tester.pumpAndSettle();
      expect(rich('last known location is NOT used'), findsOneWidget);
      await _holdToSend(tester);
      await tester.pump(const Duration(milliseconds: 100));
      final s = _lastBuild!.service();
      expect(s.triggers, 1, reason: 'the SOS still goes');
      expect(s.lastMode, 'live');
      expect(s.lastLatitude, isNull);
      expect(s.lastCapturedAt, isNull);
      await _teardown(tester);
    });

    testWidgets('Live: when the phone can refresh at send, the fresh point '
        'is the starting point', (tester) async {
      await openFresh(tester, refreshAtSend: true);
      await tester.tap(find.byKey(const Key('sos-loc-live')));
      await tester.pumpAndSettle();
      await _holdToSend(tester);
      await tester.pump(const Duration(milliseconds: 100));
      final s = _lastBuild!.service();
      expect(s.lastMode, 'live');
      expect(s.lastLatitude, isNotNull);
      expect(s.lastCapturedAt, clockNow, reason: 'the refreshed fix');
      await _teardown(tester);
    });

    testWidgets('Once chosen as "where you are now", aged during the hold, '
        'no refresh: sent WITHOUT location and the sender is told', (
      tester,
    ) async {
      clockNow = t0;
      final source = _Source(
        cachedAt: t0.subtract(const Duration(seconds: 10)),
        now: clock,
      );
      final t = _build(source: source, clock: clock);
      await openSos(tester, t.app);
      await tester.tap(find.byKey(const Key('sos-loc-once')));
      await tester.pumpAndSettle();
      expect(rich('Where you are now, once.'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('sos-hold-button')));
      await tester.pumpAndSettle();
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('sos-hold-button'))),
      );
      await tester.pump(const Duration(milliseconds: 200));
      clockNow = t0.add(const Duration(minutes: 3));
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(t.service().lastMode, 'once');
      expect(t.service().lastLatitude, isNull);
      expect(find.textContaining('too old to send'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets('No location stays available and sends nothing', (
      tester,
    ) async {
      await openFresh(tester);
      await tester.tap(find.byKey(const Key('sos-loc-none')));
      await tester.pumpAndSettle();
      await _holdToSend(tester);
      await tester.pump(const Duration(milliseconds: 100));
      expect(_lastBuild!.service().lastMode, 'none');
      expect(_lastBuild!.service().lastLatitude, isNull);
      await _teardown(tester);
    });
  });

  // ---- Finding 1: the SOS's own precision, separate from group sharing ----

  testWidgets('precision defaults to the group setting and the sender can '
      'choose suburb only for this SOS', (tester) async {
    final t = _build(source: _Source(freshNow: true));
    await openSos(tester, t.app);
    await tester.tap(find.byKey(const Key('sos-loc-once')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sos-precision-suburb')));
    await tester.pumpAndSettle();
    expect(rich('Suburb only, never an exact pin.'), findsOneWidget);
    await _holdToSend(tester);
    await tester.pump(const Duration(milliseconds: 100));
    expect(t.service().lastPrecision, 'approximate');
    await _teardown(tester);
  });

  testWidgets('an approximate sharer starts at suburb only', (tester) async {
    final t = _build(
      source: _Source(freshNow: true),
      myLevel: FamilySharingLevel.approximate,
    );
    await openSos(tester, t.app);
    await tester.tap(find.byKey(const Key('sos-loc-once')));
    await tester.pumpAndSettle();
    await _holdToSend(tester);
    await tester.pump(const Duration(milliseconds: 100));
    expect(t.service().lastPrecision, 'approximate');
    await _teardown(tester);
  });

  // ---- Finding 4: this group's lists only ----

  testWidgets('only this group\'s lists are offered (plus ones needing '
      'repair); another group\'s default is never preselected', (
    tester,
  ) async {
    final t = _build(
      lists: const [
        FamilySosList(
          id: 'other',
          ownerUserId: 'me',
          name: 'Work people',
          isDefault: true,
          memberIds: ['x1'],
          circleId: 'c2',
        ),
        FamilySosList(
          id: 'mine',
          ownerUserId: 'me',
          name: 'Close family',
          memberIds: ['m2'],
          circleId: 'c1',
        ),
        FamilySosList(
          id: 'mixed',
          ownerUserId: 'me',
          name: 'Old mixed',
          memberIds: ['m2', 'x1'],
          needsRepair: 'multipleGroups',
        ),
      ],
    );
    await openSos(tester, t.app);
    expect(find.text('Work people'), findsNothing);
    expect(find.text('Close family'), findsOneWidget);
    expect(find.text('Old mixed'), findsOneWidget);
    await _holdToSend(tester);
    await tester.pump(const Duration(milliseconds: 100));
    expect(t.service().triggers, 1);
    await _teardown(tester);
  });
}
