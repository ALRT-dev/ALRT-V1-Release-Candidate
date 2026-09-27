import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/family/models/family_models.dart';

// FamilyCircle.hostTransition* replaced the old isPaused/pausedHostName/
// graceDaysLeft fields (7-day host-transition window, not the old 30-day
// entitlement-only pause). These pin the JSON contract so a backend field
// rename or a default-value regression breaks a test instead of silently
// leaving the hub banner and the host-transition screen with stale data.
Map<String, dynamic> baseCircleJson({
  final Map<String, dynamic> overrides = const {},
}) => {
  'id': 'c1',
  'name': 'The Nixons',
  'myMemberId': 'me',
  ...overrides,
};

void main() {
  group('FamilyCircle host-transition fields', () {
    test('default to inactive/unlocked when absent from the payload', () {
      final circle = FamilyCircle.fromJson(baseCircleJson());
      expect(circle.hostTransitionActive, isFalse);
      expect(circle.hostTransitionReason, isNull);
      expect(circle.hostTransitionHostName, isNull);
      expect(circle.hostTransitionDaysLeft, isNull);
      expect(circle.hostTransitionLocked, isFalse);
    });

    test('parse an active, not-yet-locked owner_left transition', () {
      final circle = FamilyCircle.fromJson(
        baseCircleJson(
          overrides: {
            'hostTransitionActive': true,
            'hostTransitionReason': 'owner_left',
            'hostTransitionHostName': 'Sarah',
            'hostTransitionDaysLeft': 4,
            'hostTransitionLocked': false,
          },
        ),
      );
      expect(circle.hostTransitionActive, isTrue);
      expect(circle.hostTransitionReason, 'owner_left');
      expect(circle.hostTransitionHostName, 'Sarah');
      expect(circle.hostTransitionDaysLeft, 4);
      expect(circle.hostTransitionLocked, isFalse);
    });

    test('parse a locked entitlement_lapsed transition', () {
      final circle = FamilyCircle.fromJson(
        baseCircleJson(
          overrides: {
            'hostTransitionActive': true,
            'hostTransitionReason': 'entitlement_lapsed',
            'hostTransitionDaysLeft': 0,
            'hostTransitionLocked': true,
          },
        ),
      );
      expect(circle.hostTransitionActive, isTrue);
      expect(circle.hostTransitionReason, 'entitlement_lapsed');
      expect(circle.hostTransitionDaysLeft, 0);
      expect(circle.hostTransitionLocked, isTrue);
    });

    test('round-trips through toJson', () {
      final original = FamilyCircle.fromJson(
        baseCircleJson(
          overrides: {
            'hostTransitionActive': true,
            'hostTransitionReason': 'owner_left',
            'hostTransitionHostName': 'Sarah',
            'hostTransitionDaysLeft': 2,
            'hostTransitionLocked': false,
          },
        ),
      );
      final roundTripped = FamilyCircle.fromJson(original.toJson());
      expect(roundTripped, original);
    });
  });
}
