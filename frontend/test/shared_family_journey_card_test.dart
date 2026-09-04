import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/states/family_provider_state.dart';

// Locks in the two pieces the Family hub's "someone is sharing a journey
// with you" card is built on: FamilyProviderState carries the list at all
// (it used to be fetched and thrown away - the repository/service call
// existed but nothing stored the result), and FamilyJourney.isActive is
// the single rule the hub uses to decide whether a card is still shown -
// the same rule that makes it disappear on its own once a journey ends or
// its chosen stop time passes, with no separate "remove the card" step.
void main() {
  FamilyJourney journey({
    String id = 'journey-1',
    String status = 'active',
    required DateTime endsAt,
  }) {
    return FamilyJourney(
      id: id,
      circleId: 'circle-1',
      memberId: 'sarah',
      memberName: 'Sarah',
      status: status,
      endsAt: endsAt,
    );
  }

  group('FamilyJourney.isActive', () {
    test('true while active and the chosen stop time has not passed', () {
      final j = journey(endsAt: DateTime.now().add(const Duration(minutes: 10)));
      expect(j.isActive, isTrue);
    });

    test('false once the sender has stopped it (status no longer active)', () {
      final j = journey(
        status: 'ended',
        endsAt: DateTime.now().add(const Duration(minutes: 10)),
      );
      expect(j.isActive, isFalse);
    });

    test('false once its own stop time has passed, even if status lags', () {
      final j = journey(
        endsAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );
      expect(j.isActive, isFalse);
    });
  });

  group('FamilyProviderState.sharedJourneys', () {
    test('defaults to empty', () {
      expect(const FamilyProviderState().sharedJourneys, isEmpty);
    });

    test('copyWith replaces the list others are sharing with the caller', () {
      final active = journey(
        id: 'journey-2',
        endsAt: DateTime.now().add(const Duration(minutes: 20)),
      );
      final state = const FamilyProviderState().copyWith(
        sharedJourneys: [active],
      );
      expect(state.sharedJourneys, [active]);
    });

    test('other copyWith calls do not drop a previously loaded list', () {
      final active = journey(
        id: 'journey-3',
        endsAt: DateTime.now().add(const Duration(minutes: 20)),
      );
      final loaded = const FamilyProviderState().copyWith(
        sharedJourneys: [active],
      );
      final unrelatedUpdate = loaded.copyWith(hasLoadedOnce: true);
      expect(unrelatedUpdate.sharedJourneys, [active]);
    });
  });
}
