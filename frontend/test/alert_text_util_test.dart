import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/shared/utils/alert_text_util.dart';

void main() {
  const dfes = 'Warning Type: Bushfire Advice\n'
      'Region: METRO NORTH COASTAL\n'
      'A Bushfire Advice is in place for people in an area in BAMBUN.\n'
      '• There is no threat to lives or homes. The fire is contained.\n'
      'WHAT TO DO\n'
      '• Stay alert and monitor your surroundings.\n'
      '• Watch for signs of a bushfire.\n'
      'ROAD CLOSURES AND CONDITIONS\n'
      'Roads have not been closed.';

  group('whatWeKnowPoints', () {
    test('keeps the facts and drops the agency instruction block', () {
      final points = AlertTextUtil.whatWeKnowPoints(dfes);
      expect(points, [
        'A Bushfire Advice is in place for people in an area in BAMBUN.',
        'There is no threat to lives or homes. The fire is contained.',
      ]);
    });

    test('never returns more than three points', () {
      final text = List.generate(8, (i) => 'Fact $i.').join('\n');
      expect(AlertTextUtil.whatWeKnowPoints(text).length, 3);
    });

    test('handles empty and missing text', () {
      expect(AlertTextUtil.whatWeKnowPoints(null), isEmpty);
      expect(AlertTextUtil.whatWeKnowPoints('  \n '), isEmpty);
    });
  });

  group('actions', () {
    test('caps at three and keeps order', () {
      final out = AlertTextUtil.capActions(['a', 'b', 'c', 'd']);
      expect(out, ['a', 'b', 'c']);
    });

    test('always at least two points, padded with lines that point at the agency', () {
      expect(AlertTextUtil.actionsWithMinimum(null, 'DFES'), [
        'If you are near the area, be ready to follow DFES instructions.',
        'Check DFES for updates.',
      ]);
      expect(AlertTextUtil.actionsWithMinimum(['Leave now.'], 'DFES'), [
        'Leave now.',
        'Check DFES for updates.',
      ]);
      expect(AlertTextUtil.actionsWithMinimum(['a', 'b', 'c', 'd'], 'DFES').length, 3);
    });

    test('fallback line names the agency and never says no advice', () {
      final line = AlertTextUtil.followAgencyLine('DFES');
      expect(line, 'If you are near the area, be ready to follow DFES instructions.');
      expect(line.toLowerCase().contains('no advice'), isFalse);
    });
  });
}
