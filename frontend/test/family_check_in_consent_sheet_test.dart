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
    FamilySharingLevel? level,
  ) async {
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
    final result = showCheckInConsentSheet(hostContext, sharingLevel: level);
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('precise offers the location button', (tester) async {
    final result = await pumpSheet(tester, FamilySharingLevel.precise);
    expect(find.text('Check in and share my location too'), findsOneWidget);
    expect(find.text('Just check in'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
    await tester.tap(find.text('Check in and share my location too'));
    await tester.pumpAndSettle();
    expect(await result, CheckInConsentChoice.checkInAndShareLocation);
  });

  testWidgets('approximate offers a suburb, not a pin', (tester) async {
    final result = await pumpSheet(tester, FamilySharingLevel.approximate);
    expect(find.text('Check in and share my suburb too'), findsOneWidget);
    expect(find.text('Check in and share my location too'), findsNothing);
    expect(find.textContaining('never a precise pin'), findsOneWidget);
    await tester.tap(find.text('Check in and share my suburb too'));
    await tester.pumpAndSettle();
    expect(await result, CheckInConsentChoice.checkInAndShareLocation);
  });

  testWidgets('off hides the location button and explains why',
      (tester) async {
    final result = await pumpSheet(tester, FamilySharingLevel.off);
    expect(find.text('Check in and share my location too'), findsNothing);
    expect(find.text('Check in and share my suburb too'), findsNothing);
    expect(find.textContaining('Your sharing level is Off'), findsOneWidget);
    expect(find.textContaining('no location is ever shared'), findsOneWidget);
    await tester.tap(find.text('Just check in'));
    await tester.pumpAndSettle();
    expect(await result, CheckInConsentChoice.checkInOnly);
  });

  testWidgets('alertsOnly behaves like off', (tester) async {
    final result = await pumpSheet(tester, FamilySharingLevel.alertsOnly);
    expect(find.text('Check in and share my location too'), findsNothing);
    expect(find.textContaining('Your sharing level is Alerts only'),
        findsOneWidget);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(await result, isNull);
  });
}
