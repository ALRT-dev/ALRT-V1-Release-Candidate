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
    test('keeps every instruction in order', () {
      final out = AlertTextUtil.capActions(['a', 'b', 'c', 'd']);
      expect(out, ['a', 'b', 'c', 'd']);
    });

    test('shows only what the agency gave, no padding', () {
      expect(AlertTextUtil.capActions(['Leave now.']), ['Leave now.']);
      expect(AlertTextUtil.capActions([]), isEmpty);
    });

    test('community report always has at least one what-we-know point', () {
      final none = AlertTextUtil.communityPoints('Smell of gas', null);
      expect(none.length, 2);
      expect(none.first, 'A community member has reported: Smell of gas.');
      expect(AlertTextUtil.communityPoints(null, null).isNotEmpty, isTrue);
      expect(AlertTextUtil.communityPoints('A', 'Strong smell near the park').length, 3);
    });

    test('fallback line names the agency and never says no advice', () {
      final line = AlertTextUtil.followAgencyLine('DFES');
      expect(line, 'If you are near the area, be ready to follow DFES instructions.');
      expect(line.toLowerCase().contains('no advice'), isFalse);
    });

    test('what we know always has a line, even with no details', () {
      expect(
        AlertTextUtil.noDetailsLine('DFES'),
        'DFES has not published further details yet.',
      );
      expect(
        AlertTextUtil.noDetailsLine(null),
        'The source has not published further details yet.',
      );
    });
  });
}
