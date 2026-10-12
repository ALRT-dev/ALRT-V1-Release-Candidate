import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/views/widgets/family_check_in_consent_sheet.dart';

// The saved sharing level is a ceiling (approved policy, Option A): the
// consent sheet must never offer more than that level allows, and must say
// why. The backend enforces the same ceiling; this locks the explanation.
void main() {
  group('checkInLocationOfferFor', () {
    test('precise may offer a snapshot', () {
      expect(
        checkInLocationOfferFor(FamilySharingLevel.precise),
        CheckInLocationOffer.preciseSnapshot,
      );
    });

    test('approximate may offer a suburb only', () {
      expect(
        checkInLocationOfferFor(FamilySharingLevel.approximate),
        CheckInLocationOffer.suburbOnly,
      );
    });

    test('alertsOnly and off offer no location', () {
      expect(
        checkInLocationOfferFor(FamilySharingLevel.alertsOnly),
        CheckInLocationOffer.none,
      );
      expect(
        checkInLocationOfferFor(FamilySharingLevel.off),
        CheckInLocationOffer.none,
      );
    });
  });

  /// Pumps a host screen, opens the consent sheet for [level] and returns
  /// the sheet's own result future, so a test can tap and then await it.
  Future<Future<CheckInConsentChoice?>> pumpSheet(
    WidgetTester tester,
    FamilySharingLevel? level, {
    bool offerNeedHelp = false,
  }) async {
    late BuildContext hostContext;
    await tester.binding.setSurfaceSize(const Size(375, 812));
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                hostContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
    final result = showCheckInConsentSheet(
      hostContext,
      sharingLevel: level,
      offerNeedHelp: offerNeedHelp,
    );
    await tester.pumpAndSettle();
    return result;
  }

  /// Whether the sharing button carrying [label] can be pressed. Both
  /// sharing buttons are always rendered; the saved level decides which
  /// one is live, so enablement (not presence) is the rule under test.
  bool shareButtonEnabled(WidgetTester tester, String label) {
    // OutlinedButton.icon builds a private subclass, so match by `is`
    // rather than by exact runtime type.
    final button = tester.widget<OutlinedButton>(
      find.ancestor(
        of: find.text(label),
        matching: find.byWidgetPredicate((w) => w is OutlinedButton),
      ),
    );
    return button.enabled;
  }

  testWidgets('precise offers the location button', (tester) async {
    final result = await pumpSheet(tester, FamilySharingLevel.precise);
    expect(find.text('Check in'), findsOneWidget);
    expect(
      find.text(
        'Tells your group you are okay. Location is only sent if you '
        'choose it.',
      ),
      findsOneWidget,
    );
    expect(find.text('Check in and share my location'), findsOneWidget);
    expect(find.text('Just check in'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    // Callers that cannot carry the needsHelp status never see the button.
    expect(find.text('I need help'), findsNothing);
    expect(
      shareButtonEnabled(tester, 'Check in and share my location'),
      isTrue,
    );
    // Precise already allows the pin, so the suburb-only path is not the
    // one offered and there is no reason line to explain a narrowing.
    expect(shareButtonEnabled(tester, 'Check in and share my suburb'), isFalse);
    expect(find.textContaining('Your sharing level is'), findsNothing);
    await tester.tap(find.text('Check in and share my location'));
    await tester.pumpAndSettle();
    expect(await result, CheckInConsentChoice.checkInAndShareLocation);
  });

  testWidgets('approximate offers a suburb, not a pin', (tester) async {
    final result = await pumpSheet(tester, FamilySharingLevel.approximate);
    expect(find.text('Check in and share my suburb'), findsOneWidget);
    expect(shareButtonEnabled(tester, 'Check in and share my suburb'), isTrue);
    // The precise pin is rendered but cannot be chosen at this level.
    expect(
      shareButtonEnabled(tester, 'Check in and share my location'),
      isFalse,
    );
    expect(find.textContaining('never a precise pin'), findsOneWidget);
    await tester.tap(find.text('Check in and share my suburb'));
    await tester.pumpAndSettle();
    expect(await result, CheckInConsentChoice.checkInAndShareLocation);
  });

  testWidgets('off disables both location buttons and explains why',
      (tester) async {
    final result = await pumpSheet(tester, FamilySharingLevel.off);
    expect(
      shareButtonEnabled(tester, 'Check in and share my location'),
      isFalse,
    );
    expect(shareButtonEnabled(tester, 'Check in and share my suburb'), isFalse);
    expect(find.textContaining('Your sharing level is Off'), findsOneWidget);
    expect(find.textContaining('no location is ever shared'), findsOneWidget);
    // A disabled sharing button must not resolve the sheet.
    await tester.tap(
      find.text('Check in and share my location'),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    expect(find.text('Just check in'), findsOneWidget);
    await tester.tap(find.text('Just check in'));
    await tester.pumpAndSettle();
    expect(await result, CheckInConsentChoice.checkInOnly);
  });

  testWidgets('alertsOnly behaves like off', (tester) async {
    final result = await pumpSheet(tester, FamilySharingLevel.alertsOnly);
    expect(
      shareButtonEnabled(tester, 'Check in and share my location'),
      isFalse,
    );
    expect(shareButtonEnabled(tester, 'Check in and share my suburb'), isFalse);
    expect(find.textContaining('Your sharing level is Alerts only'),
        findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(await result, isNull);
  });

  testWidgets('"I need help" sits between the share buttons and Cancel',
      (tester) async {
    final result = await pumpSheet(
      tester,
      FamilySharingLevel.precise,
      offerNeedHelp: true,
    );
    expect(find.text('I need help'), findsOneWidget);
    // Order on the sheet: Just check in, the two share buttons, I need
    // help, Cancel.
    final suburbY =
        tester.getTopLeft(find.text('Check in and share my suburb')).dy;
    final helpY = tester.getTopLeft(find.text('I need help')).dy;
    final cancelY = tester.getTopLeft(find.text('Cancel')).dy;
    expect(helpY, greaterThan(suburbY));
    expect(cancelY, greaterThan(helpY));
    await tester.tap(find.text('I need help'));
    await tester.pumpAndSettle();
    expect(await result, CheckInConsentChoice.needHelp);
  });
}
