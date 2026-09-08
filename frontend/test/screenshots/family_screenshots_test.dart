// Renders the real Family screens with the app's fonts and writes PNGs, so
// the implemented UI can be reviewed without a device.
//
// Opt-in only: `ALRT_SCREENSHOTS=1 flutter test --update-goldens
// test/screenshots` writes test/screenshots/goldens/*.png (git-ignored).
// Without the variable the file is skipped, so CI's flutter test gate never
// depends on pixel-exact fonts.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/providers/states/family_provider_state.dart';
import 'package:hazard_app/features/family/views/screens/family_group_settings_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_hub_screen.dart';
import 'package:hazard_app/features/family/views/widgets/family_check_in_consent_sheet.dart';
import 'package:hazard_app/features/family/views/widgets/family_check_in_requests_sheet.dart';
import 'package:hazard_app/features/family/views/widgets/family_choose_circle_sheet.dart';
import 'package:hazard_app/features/family/views/widgets/family_member_details_sheet.dart';
import 'package:hazard_app/features/shared/providers/live_connection_provider.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_expired_screen.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_paywall_screen.dart';
import 'package:hazard_app/features/subscription/views/widgets/alrt_plus_upsell_sheet.dart';
import 'package:hazard_app/others/app_theme.dart';

final _enabled = Platform.environment['ALRT_SCREENSHOTS'] == '1';

class _LiveOn extends LiveConnectionNotifier {
  @override
  bool build() => true;
}

Future<void> _loadFonts() async {
  // FLUTTER_ROOT is set by `flutter test`; the Dart VM path is inside
  // bin/cache/dart-sdk, so walk up to the SDK root as a fallback.
  final sdk = Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.path;
  final materialFonts = '$sdk/bin/cache/artifacts/material_fonts';
  // ignore: avoid_print
  print('fonts from $materialFonts exists=${Directory(materialFonts).existsSync()}');
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      final file = File(f);
      if (!file.existsSync()) continue;
      loader.addFont(
        file.readAsBytes().then((b) => ByteData.view(b.buffer)),
      );
    }
    await loader.load();
  }
  // The theme asks for Arial; on a phone that resolves to the system sans.
  await load('Arial', [
    '$materialFonts/Roboto-Regular.ttf',
    '$materialFonts/Roboto-Medium.ttf',
    '$materialFonts/Roboto-Bold.ttf',
    '$materialFonts/Roboto-Black.ttf',
  ]);
  await load('Roboto', [
    '$materialFonts/Roboto-Regular.ttf',
    '$materialFonts/Roboto-Medium.ttf',
    '$materialFonts/Roboto-Bold.ttf',
  ]);
  await load('MaterialIcons', ['$materialFonts/MaterialIcons-Regular.otf']);
  final pub = Platform.environment['PUB_CACHE'] ??
      '${Platform.environment['HOME']}/.pub-cache';
  final lucideDir = Directory('$pub/hosted/pub.dev')
      .listSync()
      .whereType<Directory>()
      .where((d) => d.path.contains('/lucide_icons_flutter-'))
      .map((d) => d.path)
      .toList()
    ..sort();
  if (lucideDir.isNotEmpty) {
    await load('packages/lucide_icons_flutter/Lucide', [
      '${lucideDir.last}/assets/build_font/LucideVariable-w500.ttf',
    ]);
  }
}

final _now = DateTime.now();

FamilyMember _member({
  required String id,
  required String name,
  FamilyRole role = FamilyRole.adult,
  FamilySharingLevel level = FamilySharingLevel.precise,
  DateTime? lastCheckInAt,
  String? label,
  String? colorHex,
}) =>
    FamilyMember(
      id: id,
      userId: 'u-$id',
      name: name,
      role: role,
      sharingLevel: level,
      lastCheckInAt: lastCheckInAt,
      locationLabel: label,
      locationUpdatedAt: label == null ? null : _now.subtract(const Duration(minutes: 12)),
      locationExpiresAt: label == null ? null : _now.add(const Duration(minutes: 48)),
      colorHex: colorHex,
    );

FamilyCircle _circle({bool askPending = true, bool multiAsk = false}) => FamilyCircle(
      id: 'c1',
      name: 'The Nixons',
      myMemberId: 'me',
      themeColor: '#7B3FA0',
      members: [
        _member(
          id: 'me',
          name: 'Sarah',
          role: FamilyRole.owner,
          lastCheckInAt: _now.subtract(const Duration(hours: 3)),
          colorHex: '#8E44AD',
        ),
        _member(
          id: 'amy',
          name: 'Amy',
          lastCheckInAt: _now.subtract(const Duration(minutes: 8)),
          level: FamilySharingLevel.approximate,
          label: 'Newcastle',
          colorHex: '#5238DE',
        ),
        _member(
          id: 'tom',
          name: 'Tom',
          lastCheckInAt: _now.subtract(const Duration(days: 1, hours: 2)),
          level: FamilySharingLevel.off,
          colorHex: '#6C7A94',
        ),
        _member(
          id: 'ben',
          name: 'Ben',
          role: FamilyRole.guest,
          colorHex: '#4A5568',
        ),
      ],
      latestCheckInRequest: askPending ? _asks(multiAsk).first : null,
      checkInRequests: askPending ? _asks(multiAsk) : const [],
    );

/// Amy's ask alone, or Amy, Tom and Ben all asking within minutes.
List<FamilyCheckInRequest> _asks(bool multi) => [
      if (multi)
        FamilyCheckInRequest(
          id: 'r3',
          circleId: 'c1',
          requestedById: 'ben',
          requestedBy: const FamilyMemberSnippet(id: 'ben', nickname: 'Ben'),
          createdAt: _now.subtract(const Duration(minutes: 1)),
        ),
      if (multi)
        FamilyCheckInRequest(
          id: 'r2',
          circleId: 'c1',
          requestedById: 'tom',
          requestedBy: const FamilyMemberSnippet(id: 'tom', nickname: 'Tom'),
          createdAt: _now.subtract(const Duration(minutes: 3)),
          message: 'Big storm here, all okay?',
        ),
      FamilyCheckInRequest(
        id: 'r1',
        circleId: 'c1',
        requestedById: 'amy',
        requestedBy: const FamilyMemberSnippet(id: 'amy', nickname: 'Amy'),
        createdAt: _now.subtract(const Duration(minutes: 5)),
        targetMemberIds: const ['me'],
      ),
    ];

FamilyProviderState _state({bool multiAsk = false}) => FamilyProviderState(
      circle: _circle(multiAsk: multiAsk),
      hasLoadedOnce: true,
      circles: const [
        FamilyCircleSummary(
          circleId: 'c1',
          name: 'The Nixons',
          myMemberId: 'me',
          role: FamilyRole.owner,
          isOwned: true,
          seatCount: 2,
          memberCount: 4,
          themeColor: '#7B3FA0',
          checkedInCount: 2,
          waitingOn: ['Tom', 'Ben'],
        ),
        FamilyCircleSummary(
          circleId: 'c2',
          name: 'Netball Mums',
          pendingCheckInRequests: 1,
          myMemberId: 'me2',
          isOwned: false,
          memberCount: 6,
          themeColor: '#16A46B',
          checkedInCount: 6,
        ),
      ],
    );

Widget _app(Widget home, {bool dark = false, double textScale = 1.0, bool multiAsk = false}) {
  return ProviderScope(
    overrides: [
      providerOfFamily.overrideWith(
        (ref) => FamilyProvider(ref: ref, state: _state(multiAsk: multiAsk), bootstrap: false),
      ),
      providerOfLiveConnection.overrideWith(_LiveOn.new),
      providerOfAlrtPlusBillingIssue.overrideWith((ref) async => false),
      providerOfAlrtPlus.overrideWith((ref) async => false),
      providerOfExpiredAlrtPlus.overrideWith((ref) async => null),
    ],
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightPalette,
        darkTheme: AppTheme.darkPalette,
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
            padding: const EdgeInsets.only(top: 44, bottom: 24),
            viewPadding: const EdgeInsets.only(top: 44, bottom: 24),
          ),
          child: child!,
        ),
        home: home,
      ),
    ),
  );
}

Future<void> _shoot(WidgetTester tester, String name, {Size size = const Size(390, 844)}) async {
  await tester.binding.setSurfaceSize(size);
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  await tester.pump(const Duration(milliseconds: 300));
  await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/$name.png'));
}

void main() {
  setUpAll(() async {
    dotenv.loadFromString(envString: 'ALRT_PLUS_TEST_UNLOCK=false\nREVENUECAT_API_KEY_GOOGLE=\n');
    if (_enabled) await _loadFonts();
  });

  testWidgets('family hub, light, ask pending', (tester) async {
    await tester.pumpWidget(_app(const FamilyHubScreen()));
    await _shoot(tester, '01_family_hub_light');
    await _shoot(tester, '02_family_hub_light_full', size: const Size(390, 1500));
  }, skip: !_enabled);

  testWidgets('family hub, dark', (tester) async {
    await tester.pumpWidget(_app(const FamilyHubScreen(), dark: true));
    await _shoot(tester, '03_family_hub_dark');
  }, skip: !_enabled);

  testWidgets('family hub, large text', (tester) async {
    await tester.pumpWidget(_app(const FamilyHubScreen(), textScale: 1.3));
    await _shoot(tester, '04_family_hub_large_text');
  }, skip: !_enabled);

  testWidgets('member details sheet (host viewing a member)', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(_app(Scaffold(body: Builder(builder: (c) { ctx = c; return const SizedBox.shrink(); }))));
    showFamilyMemberDetailsSheet(
      ctx,
      member: _circle().members[2],
      isMe: false,
      isNearAlert: false,
      hasAnswered: false,
      askedAt: _now.subtract(const Duration(minutes: 5)),
      onAskToCheckIn: () {},
      onRequestLocation: () {},
      onRemove: () {},
    );
    await tester.pumpAndSettle();
    await _shoot(tester, '05_member_details_sheet');
  }, skip: !_enabled);

  testWidgets('check-in consent sheet, approximate, answering an ask', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(_app(Scaffold(body: Builder(builder: (c) { ctx = c; return const SizedBox.shrink(); }))));
    showCheckInConsentSheet(ctx, requesterName: 'Amy', sharingLevel: FamilySharingLevel.approximate);
    await tester.pumpAndSettle();
    await _shoot(tester, '06_consent_sheet_approximate');
  }, skip: !_enabled);

  testWidgets('choose a circle sheet', (tester) async {
    late WidgetRef sheetRef;
    late BuildContext ctx;
    await tester.pumpWidget(_app(Scaffold(body: Consumer(builder: (c, r, _) { ctx = c; sheetRef = r; return const SizedBox.shrink(); }))));
    showChooseCircleSheet(ctx, sheetRef);
    await tester.pumpAndSettle();
    await _shoot(tester, '12_choose_circle_sheet');
  }, skip: !_enabled);

  testWidgets('family hub, several people asked', (tester) async {
    await tester.pumpWidget(_app(const FamilyHubScreen(), multiAsk: true));
    await _shoot(tester, '13_family_hub_multi_ask');
  }, skip: !_enabled);

  testWidgets('check-in requests sheet', (tester) async {
    await tester.pumpWidget(_app(
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => showCheckInRequestsSheet(context, onCheckIn: () async {}),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      multiAsk: true,
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await _shoot(tester, '14_check_in_requests_sheet');
  }, skip: !_enabled);

  testWidgets('circle settings (host)', (tester) async {
    await tester.pumpWidget(_app(const FamilyGroupSettingsScreen()));
    await _shoot(tester, '07_circle_settings', size: const Size(390, 1100));
  }, skip: !_enabled);

  testWidgets('upsell sheet: hosting needs ALRT+', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(_app(Scaffold(body: Builder(builder: (c) { ctx = c; return const SizedBox.shrink(); }))));
    showAlrtPlusUpsellSheet(
      context: ctx,
      icon: AlrtPlusUpsellIcons.hostCircle,
      iconGradient: familyUpsellGradient,
      title: 'Hosting needs ALRT+',
      message: 'Joining a Family circle is always free. Hosting your own — invites, seats, circle settings — needs ALRT+.',
      primaryLabel: 'See ALRT+',
      onPrimary: (_) async => false,
    );
    await tester.pumpAndSettle();
    await _shoot(tester, '08_upsell_host_circle');
  }, skip: !_enabled);

  testWidgets('upsell sheet: one free saved location', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(_app(Scaffold(body: Builder(builder: (c) { ctx = c; return const SizedBox.shrink(); }))));
    showAlrtPlusUpsellSheet(
      context: ctx,
      icon: AlrtPlusUpsellIcons.savedLocation,
      title: 'One free saved location',
      message: 'Free accounts can save 1 location. ALRT+ removes the limit, so you can save as many as you like.',
      primaryLabel: 'See ALRT+',
      onPrimary: (_) async => false,
    );
    await tester.pumpAndSettle();
    await _shoot(tester, '09_upsell_saved_location');
  }, skip: !_enabled);

  testWidgets('paywall (no store key: unavailable state)', (tester) async {
    await tester.pumpWidget(_app(const AlrtPlusPaywallScreen()));
    await tester.pump(const Duration(seconds: 1));
    await _shoot(tester, '10_paywall_unavailable');
  }, skip: !_enabled);

  testWidgets('back on the free plan (expired)', (tester) async {
    await tester.pumpWidget(_app(const AlrtPlusExpiredScreen()));
    await _shoot(tester, '11_expired_free_plan');
  }, skip: !_enabled);
}
