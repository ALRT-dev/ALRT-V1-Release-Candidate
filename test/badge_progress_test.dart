import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/profile/models/xp_summary_models.dart';

/// The badge shelf's own rules, pinned.
///
/// Points and Badge Logic v1.1: every badge counts what other people
/// confirmed about your reports. Nothing here rewards volume, and an
/// earned badge always reads as complete.
void main() {
  group('badge progress', () {
    test('a locked badge reports how far along it is', () {
      const badge = SafetyBadge(
        id: 'accurate_5',
        name: 'Trusted Reporter',
        threshold: 5,
        progress: 2,
      );
      expect(badge.fraction, 0.4);
      expect(badge.earned, isFalse);
    });

    test('an earned badge is full, never over', () {
      const badge = SafetyBadge(
        id: 'corroborated_25',
        name: 'Community Hero',
        threshold: 25,
        progress: 40,
        earned: true,
      );
      expect(badge.fraction, 1.0);
    });

    test('a badge nobody has started reads as empty, not as an error', () {
      const badge = SafetyBadge(
        id: 'corroborated_100',
        name: 'Crowd Favourite',
        threshold: 100,
      );
      expect(badge.fraction, 0.0);
    });

    test('a zero threshold cannot divide by zero', () {
      const badge = SafetyBadge(id: 'x', name: 'X', threshold: 0, progress: 3);
      expect(badge.fraction, 0.0);
    });

    test('the summary parses the badge list the backend sends', () {
      final summary = XpSummary.fromJson({
        'xpPoints': 40,
        'badges': [
          {
            'id': 'accurate_5',
            'name': 'Trusted Reporter',
            'description': '5 of your reports were confirmed by people nearby',
            'threshold': 5,
            'progress': 1,
            'earned': false,
            'earnedAt': null,
          },
        ],
      });

      expect(summary.badges, hasLength(1));
      expect(summary.badges.single.name, 'Trusted Reporter');
      expect(summary.badges.single.earned, isFalse);
      expect(summary.badges.single.fraction, 0.2);
    });

    test('a summary from before badges existed still parses', () {
      final summary = XpSummary.fromJson({'xpPoints': 20});
      expect(summary.badges, isEmpty);
    });
  });
}
