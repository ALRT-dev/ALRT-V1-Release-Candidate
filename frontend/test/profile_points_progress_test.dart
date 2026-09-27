import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/shared/enums/user_badge_enum.dart';

/// Pins the tier-progress formula behind the Profile header's XP bar
/// (ProfileXpProgress: "N XP to <next tier>") - the single XP/progress
/// summary now shown on Profile, after the duplicate points card below
/// the header was removed. Same source data and formula throughout,
/// never a second invented points/level system.
void main() {
  group('ALRT points progress', () {
    test('a brand new user is a Watcher, 750 points from Scout', () {
      const xpPoints = 0;
      final badge = UserBadge.forXp(xpPoints);
      final nextBadge = badge.nextBadge;

      expect(badge, UserBadge.watcher);
      expect(nextBadge, UserBadge.scout);
      expect(nextBadge.requiredXpPoints - xpPoints, 750);
    });

    test('a user partway to Scout sees the real remaining gap', () {
      const xpPoints = 590;
      final badge = UserBadge.forXp(xpPoints);
      final nextBadge = badge.nextBadge;

      expect(badge, UserBadge.watcher);
      expect(nextBadge, UserBadge.scout);
      expect(nextBadge.requiredXpPoints - xpPoints, 160);
    });

    test('exactly on a threshold counts as having reached that tier', () {
      expect(UserBadge.forXp(750), UserBadge.scout);
      expect(UserBadge.forXp(1500), UserBadge.guardian);
    });

    test('the highest tier has no further "points to next" text', () {
      const xpPoints = 1500;
      final badge = UserBadge.forXp(xpPoints);
      expect(badge, UserBadge.guardian);
      expect(badge, UserBadge.values.last);
    });

    test('points beyond the top tier still resolve to the top tier', () {
      expect(UserBadge.forXp(5000), UserBadge.guardian);
    });
  });
}
