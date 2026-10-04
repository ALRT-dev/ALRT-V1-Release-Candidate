import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/api/rest_client.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/providers/states/family_provider_state.dart';
import 'package:hazard_app/features/family/repositories/family_repository.dart';
import 'package:hazard_app/features/family/services/family_service.dart';
import 'package:hazard_app/features/family/services/sos_api.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_list_edit_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_receiver_screen.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

/// Review of cb26a8d (29 Sep 2026), app side of findings 1, 2 and 4:
/// the sender's controls for a running SOS, the "manual" label on ordinary
/// shares, and the one-group SOS list editor. Widget and unit tests only:
/// not a device, a store sandbox or deployed TEST.

const _mySos = FamilySosEvent(
  id: 'sos-1',
  circleId: 'c1',
  memberId: 'me-member',
  isLive: true,
  locationMode: 'live',
  locationPrecision: 'precise',
);

class _FakeService extends FamilyService {
  _FakeService(super.ref);

  List<FamilySosRecipientGroup> groups = const [];
  List<String>? savedMemberIds;
  String? savedListId;

  @override
  Future<Either<List<FamilySosRecipientGroup>, AppError>>
  getFamilySosRecipients() async => Success(groups);

  @override
  Future<Either<List<FamilySosList>, AppError>> getFamilySosLists() async =>
      const Success([]);

  @override
  Future<Either<FamilySosList, AppError>> createFamilySosList({
    required final String name,
    required final List<String> memberIds,
    final bool? isDefault,
  }) async {
    savedMemberIds = memberIds;
    return Success(
      FamilySosList(id: 'new', ownerUserId: 'me', name: name, memberIds: memberIds),
    );
  }

  @override
  Future<Either<FamilySosList, AppError>> updateFamilySosList({
    required final String sosListId,
    final String? name,
    final List<String>? memberIds,
    final bool? isDefault,
  }) async {
    savedListId = sosListId;
    savedMemberIds = memberIds;
    return Success(
      FamilySosList(
        id: sosListId,
        ownerUserId: 'me',
        name: name ?? '',
        memberIds: memberIds ?? const [],
      ),
    );
  }

  @override
  Future<Either<List<FamilySosEvent>, AppError>>
  getAllActiveFamilySosEvents() async => const Success([_mySos]);

  @override
  Future<Either<FamilySosTrail, AppError>> getFamilySosTrail({
    required final String sosEventId,
  }) async => Success(FamilySosTrail(sosEventId: sosEventId));
}

class _FakeSosApi extends SosApi {
  _FakeSosApi() : super(dio: Dio(), circleId: () => 'c1');
  final consentCalls = <({String? mode, String? precision})>[];

  @override
  Future<Either<Map<String, dynamic>, AppError>> setLocationConsent({
    required final String sosEventId,
    final String? mode,
    final String? precision,
  }) async {
    consentCalls.add((mode: mode, precision: precision));
    return Success({
      'id': sosEventId,
      'circleId': 'c1',
      'memberId': 'me-member',
      'status': 'active',
      'isLive': mode == null ? true : mode == 'live',
      'locationMode': mode ?? 'live',
      'locationPrecision': precision ?? 'precise',
    });
  }
}

Widget _host(
  final Widget child, {
  required final void Function(_FakeService) onService,
  final SosApi? sosApi,
  final List<FamilySosEvent> active = const [],
}) {
  return ProviderScope(
    overrides: [
      providerOfFamilyService.overrideWith((ref) {
        final s = _FakeService(ref);
        onService(s);
        return s;
      }),
      if (sosApi != null) providerOfSosApi.overrideWithValue(sosApi),
      providerOfFamily.overrideWith(
        (ref) => FamilyProvider(
          ref: ref,
          bootstrap: false,
          state: FamilyProviderState(
            hasLoadedOnce: true,
            activeSosEvents: active,
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

const _groups = [
  FamilySosRecipientGroup(
    circleId: 'c1',
    name: 'Nixons',
    members: [
      FamilySosRecipient(memberId: 'a1', name: 'Alex'),
      FamilySosRecipient(memberId: 'a2', name: 'Bea'),
    ],
  ),
  FamilySosRecipientGroup(
    circleId: 'c2',
    name: 'Work',
    members: [FamilySosRecipient(memberId: 'b1', name: 'Casey')],
  ),
];

void main() {
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

  group('finding 4: an SOS list is for one group', () {
    testWidgets('an old mixed list opens with a repair notice, keeps only '
        'one group, and saving sends only that group', (tester) async {
      late _FakeService service;
      await tester.pumpWidget(
        _host(
          const FamilySosListEditScreen(
            args: FamilySosListEditScreenArgs(
              list: FamilySosList(
                id: 'mixed',
                ownerUserId: 'me',
                name: 'Old mixed',
                memberIds: ['a1', 'a2', 'b1'],
                needsRepair: 'multipleGroups',
              ),
            ),
          ),
          onService: (s) => service = s..groups = _groups,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sos-list-repair-notice')), findsOneWidget);
      expect(find.textContaining('1 person from other groups was taken off'),
          findsOneWidget);
      expect(find.text('Casey'), findsNothing, reason: 'other group hidden');
      expect(find.text('Save list · 2 people'), findsOneWidget);
      await tester.tap(find.text('Save list · 2 people'));
      await tester.pumpAndSettle();
      expect(service.savedListId, 'mixed');
      expect(service.savedMemberIds, unorderedEquals(['a1', 'a2']));
    });

    testWidgets('switching group clears every pick; nothing hidden is kept', (
      tester,
    ) async {
      late _FakeService service;
      await tester.pumpWidget(
        _host(
          const FamilySosListEditScreen(),
          onService: (s) => service = s..groups = _groups,
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Mine');
      await tester.tap(find.text('Alex'));
      await tester.pump();
      expect(find.text('Save list · 1 person'), findsOneWidget);
      await tester.tap(find.byKey(const Key('sos-list-group-c2')));
      await tester.pumpAndSettle();
      expect(find.text('Alex'), findsNothing);
      expect(find.text('Save list · 0 people'), findsOneWidget);
      await tester.tap(find.text('Casey'));
      await tester.pump();
      await tester.tap(find.text('Save list · 1 person'));
      await tester.pumpAndSettle();
      expect(service.savedMemberIds, ['b1'], reason: 'Alex was not kept');
    });
  });

  group('finding 1: the sender controls what a running SOS shares', () {
    Future<_FakeSosApi> open(WidgetTester tester) async {
      final api = _FakeSosApi();
      await tester.pumpWidget(
        _host(
          const FamilySosReceiverScreen(
            args: FamilySosReceiverScreenArgs(sosEvent: _mySos),
          ),
          onService: (_) {},
          sosApi: api,
          active: const [_mySos],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      return api;
    }

    Future<void> tapKey(WidgetTester tester, String key) async {
      await tester.ensureVisible(find.byKey(Key(key)));
      await tester.pump();
      await tester.tap(find.byKey(Key(key)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    Future<void> close(WidgetTester tester) async {
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    }

    testWidgets('suburb only, then stop sharing, each as an explicit SOS '
        'change; the SOS stays active', (tester) async {
      final api = await open(tester);
      expect(find.text('Sharing your exact live location with this SOS.'),
          findsOneWidget);
      await tapKey(tester, 'sos-consent-suburb');
      expect(api.consentCalls.single, (mode: null, precision: 'approximate'));
      expect(find.text('Sharing your live location with this SOS: suburb only.'),
          findsOneWidget);
      await tapKey(tester, 'sos-consent-stop');
      expect(api.consentCalls.last, (mode: 'none', precision: null));
      expect(find.text('This SOS is not sharing your location.'), findsOneWidget);
      expect(find.byKey(const Key('sos-send-now')), findsNothing);
      expect(find.byKey(const Key('sos-consent-live')), findsOneWidget,
          reason: 'sharing can be turned back on explicitly');
      expect(find.text('Cancel SOS'), findsOneWidget);
      await close(tester);
    });

    testWidgets('the running SOS never offers an ordinary group share', (
      tester,
    ) async {
      await open(tester);
      expect(find.text('Share updated location'), findsNothing);
      expect(find.byKey(const Key('sos-send-now')), findsOneWidget);
      await close(tester);
    });
  });

  group('finding 2: ordinary shares say they are ordinary', () {
    test('the location post carries purpose "manual"', () async {
      Map<String, dynamic>? sent;
      final dio = Dio(BaseOptions(baseUrl: 'http://local.invalid'))
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              sent = Map<String, dynamic>.from(options.data as Map);
              handler.resolve(Response(requestOptions: options, statusCode: 200));
            },
          ),
        );
      final repo = FamilyRepositoryImpl(restClient: RestClient(dio));
      final result = await repo.sendFamilyLocationPing(
        latitude: -27.47,
        longitude: 153.02,
      );
      expect(result.isSuccess, isTrue);
      expect(sent?['purpose'], 'manual');
    });
  });
}
