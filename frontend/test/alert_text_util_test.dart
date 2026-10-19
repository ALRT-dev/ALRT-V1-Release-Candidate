import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/shared/utils/alert_text_util.dart';
import 'package:hazard_app/features/shared/utils/alert_guidance_library.dart';
import 'package:hazard_app/features/profile/models/for_you_library.dart';
import 'package:hazard_app/features/profile/models/safety_cohort.dart';

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

    test('all facts are available uncapped for the expander', () {
      final text = List.generate(6, (i) => 'Fact $i.').join('\n');
      expect(AlertTextUtil.whatWeKnowAllPoints(text).length, 6);
      expect(AlertTextUtil.whatWeKnowPoints(text).length, 3);
    });
  });

  group('actions', () {
    test('caps at three and keeps order', () {
      final out = AlertTextUtil.capActions(['a', 'b', 'c', 'd']);
      expect(out, ['a', 'b', 'c']);
    });

    test('shows only what the agency gave, no padding', () {
      expect(AlertTextUtil.capActions(['Leave now.']), ['Leave now.']);
      expect(AlertTextUtil.capActions([]), isEmpty);
    });

    test('community report always has at least one what-we-know point', () {
      final none = AlertTextUtil.communityPoints('Smell of gas', null);
      expect(none.length, greaterThanOrEqualTo(3));
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

  group('ranking', () {
    test('ranks life-safety instructions first', () {
      final out = AlertGuidanceLibrary.rankActions([
        'Monitor conditions and check the website.',
        'Leave now and use a route away from the fire.',
        'Move valuables above floor level.',
      ]);
      expect(out.first, contains('Leave now'));
      expect(out.last, contains('Monitor'));
    });

    test('keeps source order within a tier', () {
      final out = AlertGuidanceLibrary.rankActions([
        'Check the website.',
        'Stay informed.',
        'Listen to radio updates.',
      ]);
      expect(out, [
        'Check the website.',
        'Stay informed.',
        'Listen to radio updates.',
      ]);
    });

    test('surfaces a leave-now buried at position 5', () {
      final out = AlertTextUtil.capActions([
        'Monitor conditions.',
        'Check the website.',
        'Stay informed.',
        'Keep clear of the area.',
        'Leave now before the fire arrives.',
      ]);
      expect(out.length, 3);
      expect(out.first, contains('Leave now'));
    });

    test('consider rows exist for a hazard and are calm', () {
      final rows = AlertGuidanceLibrary.considerRows('bushfire');
      expect(rows, isNotEmpty);
      expect(rows.first, startsWith('Consider'));
    });

    test('global bucket returns region-agnostic rows', () {
      final rows = AlertGuidanceLibrary.considerRows('global');
      expect(rows, isNotEmpty);
      expect(rows.any((r) => r.contains('Australian')), isFalse);
    });

    test('keyFacts pulls numbers from the source description', () {
      final facts = AlertGuidanceLibrary.keyFacts(
        'A bushfire is burning and may impact within 2 hours. '
        'Embers are travelling up to 5 km ahead.',
      );
      expect(facts, isNotEmpty);
      expect(facts.any((f) => f.$2.contains('2 hours')), isTrue);
      expect(facts.any((f) => f.$2.contains('5 km')), isTrue);
    });

    test('keyFacts returns nothing for text with no specifics', () {
      expect(AlertGuidanceLibrary.keyFacts('A fire is burning. Stay safe.'), isEmpty);
    });

    test('ensureMinPoints pads a terse source to at least three actionable points', () {
      final points = AlertTextUtil.ensureMinPoints(
        ['DFES has issued a bushfire incident at Toodyay.'],
        'bushfire',
        3,
      );
      expect(points.length, greaterThanOrEqualTo(3));
      // Never just "an incident has occurred" — the top-up lines are actionable.
      expect(points.every((p) => p.trim().isNotEmpty), isTrue);
    });

    test('community report never reads as a single vague incident line', () {
      final points = AlertTextUtil.communityPoints('Smell of gas', null);
      expect(points.length, greaterThanOrEqualTo(3));
      expect(points.first, isNot(contains('an incident has occurred')));
    });
  });
  group('global rows', () {
    test('region-agnostic — no Australian wording', () {
      for (final line in ForYouLibrary.globalRows.values) {
        expect(line.toLowerCase().contains('australia'), isFalse,
            reason: line);
        expect(line.contains('is a good idea'), isFalse, reason: line);
      }
      expect(ForYouLibrary.globalRows.length, SafetyCohort.values.length);
    });
  });
  group('issuedLine', () {
    test('agency + incident type + place', () {
      expect(
        AlertTextUtil.issuedLine('DFES', 'bushfire', 'Toodyay'),
        'DFES has issued a bushfire incident at Toodyay.',
      );
    });
    test('no place falls back to a plain issued line', () {
      expect(
        AlertTextUtil.issuedLine('DFES', 'flood', null),
        'DFES has issued a flood incident.',
      );
    });
    test('no agency still names the incident type', () {
      expect(
        AlertTextUtil.issuedLine(null, 'bushfire', 'Bambun'),
        'A bushfire incident has been reported at Bambun.',
      );
    });
    test('no incident type never returns empty', () {
      expect(AlertTextUtil.issuedLine('DFES', null, null), isNotEmpty);
    });
    test('already-"incident" type is not doubled', () {
      expect(
        AlertTextUtil.issuedLine('DFES', 'incident', 'Bambun'),
        'DFES has issued a incident at Bambun.',
      );
    });
  });
}
