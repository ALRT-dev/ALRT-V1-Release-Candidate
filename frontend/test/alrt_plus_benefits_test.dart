import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/subscription/utils/alrt_plus_limits.dart';
import 'package:hazard_app/features/subscription/views/widgets/alrt_plus_benefits.dart';

/// The ALRT+ explanation quotes the enforced allowances and nothing else
/// (issue 11): the numbers the backend enforces, joining always free, no
/// invented benefits, no trial or price promises (those come from the
/// store at display time).
void main() {
  test('the allowances quoted are the enforced ones', () {
    expect(kFreeSavedLocationsLimit, 1);
    expect(kAlrtPlusMaxOwnedCircles, 4);
    expect(kAlrtPlusSeats, 8);
  });

  test(
    'joining stays free, hosting and extra saved locations are the paid benefits',
    () {
      final labels = alrtPlusBenefits.map((b) => b.label).join('\n');
      expect(labels, contains('Join a family circle someone else hosts'));
      final join = alrtPlusBenefits.firstWhere(
        (b) => b.label.startsWith('Join'),
      );
      expect(join.free, 'Always free');
      final host = alrtPlusBenefits.firstWhere(
        (b) => b.label.startsWith('Host'),
      );
      expect(host.free, isNull);
      expect(host.plus, contains('$kAlrtPlusMaxOwnedCircles circles'));
      final seats = alrtPlusBenefits.firstWhere(
        (b) => b.label.startsWith('Seats'),
      );
      expect(seats.free, isNull);
      expect(seats.plus, contains('$kAlrtPlusSeats seats'));
      expect(seats.plusCell, '$kAlrtPlusSeats seats');
      final saved = alrtPlusBenefits.firstWhere(
        (b) => b.label.startsWith('Saved locations'),
      );
      expect(saved.free, '$kFreeSavedLocationsLimit location');
      for (final b in alrtPlusBenefits) {
        expect(b.label.toLowerCase(), isNot(contains('trial')));
        expect(b.plus.toLowerCase(), isNot(contains('guarantee')));
        expect(b.plus, isNot(contains('\$')));
      }
    },
  );

  testWidgets('the table renders every row as Free and ALRT+ columns', (
    tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: AlrtPlusBenefitsTable()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('FREE'), findsOneWidget);
    expect(find.text('ALRT+'), findsOneWidget);
    for (final b in alrtPlusBenefits) {
      expect(find.text(b.label), findsOneWidget);
    }
    // Always-free rows: a tick and the word in both columns; nothing is
    // colour-only.
    final always = alrtPlusBenefits.where((b) => !b.isPaidDifference).length;
    expect(find.text(AlrtPlusBenefit.kAlwaysCell), findsNWidgets(always * 2));
    // Paid rows: the free cell is a short allowance or a dash, the ALRT+
    // cell a short allowance.
    final dashes = alrtPlusBenefits.where((b) => b.freeCell == null).length;
    expect(find.text('\u2014'), findsNWidgets(dashes));
    expect(find.text('$kFreeSavedLocationsLimit place'), findsOneWidget);
    expect(find.text('Unlimited'), findsOneWidget);
    expect(find.text('Up to $kAlrtPlusMaxOwnedCircles'), findsOneWidget);
    expect(find.text('$kAlrtPlusSeats seats'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('the free promise and the host line quote the same allowances', () {
    expect(kAlrtPlusFreeLead, 'Alerts are always free.');
    expect(kAlrtPlusFreeText, contains('everyone informed'));
    expect(kAlrtPlusFreeText, contains('joining a circle'));
    expect(kAlrtPlusHostLine, contains('$kAlrtPlusSeats people'));
    for (final line in [kAlrtPlusFreeText, kAlrtPlusHostLine]) {
      expect(line.toLowerCase(), isNot(contains('trial')));
      expect(line, isNot(contains('\$')));
    }
    expect(
      alrtPlusBenefits.where((b) => b.isPaidDifference).length,
      4,
      reason: 'saved locations, hosting, seats, check-ins in hosted circles',
    );
  });
}
