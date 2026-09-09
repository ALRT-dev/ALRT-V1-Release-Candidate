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
      expect(host.plus, contains('$kAlrtPlusSeats seats'));
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

  testWidgets('the table renders every row with a Free and an ALRT+ value', (
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
    for (final b in alrtPlusBenefits) {
      expect(find.text(b.label), findsOneWidget);
      expect(find.text('ALRT+: ${b.plus}'), findsWidgets);
      expect(find.text('Free: ${b.free ?? 'Not included'}'), findsWidgets);
    }
  });
}
