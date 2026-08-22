import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// The mark is TRACED from the supplied master artwork and must never be
/// redrawn or simplified.
///
/// The geometry itself was verified against the master by rasterizing the
/// same primitives and diffing them pixel by pixel: 1.34% of covered
/// pixels differ, all of it edge anti-aliasing. These tests guard the
/// things that can silently regress afterwards.
///
/// The previous version of this asset parsed perfectly while being wrong:
/// its bars were 457 wide instead of 484.5, so they never reached the
/// dots and the overlap that defines the mark simply was not there. A
/// test that only checks "does it render" would have passed it, which is
/// why the numbers are asserted too.
void main() {
  testWidgets('the ALRT mark renders from the SVG asset', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 32,
            height: 26,
            child: SvgPicture.asset(
              'assets/logos/alrt_logo.svg',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(SvgPicture), findsOneWidget);
  });

  test('the mark keeps the master artwork geometry and colours', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final svg = await rootBundle.loadString('assets/logos/alrt_logo.svg');

    // Six shapes plus the two overlap lenses.
    expect('<rect'.allMatches(svg).length, 3, reason: 'three bars');
    expect('<circle'.allMatches(svg).length, 3, reason: 'three dots');
    expect(
      '<path'.allMatches(svg).length,
      2,
      reason: 'rows 1 and 3 each carry an overlap lens',
    );

    // The master's own colours, including the overlap, which is a distinct
    // colour and not a blend: compositing red and orange at any alpha
    // leaves blue near 0, and the master's overlap has blue 58.
    expect(svg, contains('#FF0004'), reason: 'master red');
    expect(svg, contains('#FF6B00'), reason: 'master orange');
    expect(svg, contains('#DE3A3A'), reason: 'master overlap');

    // The bars must reach the dots, or there is no overlap to draw. This
    // is the exact number that was wrong before.
    expect(
      svg,
      contains('width="484.5"'),
      reason: 'bar width measured off the master; 457 loses the overlap',
    );
    expect(svg, contains('viewBox="0 0 555 412"'));
  });
}
