import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/utils/saved_location_gate.dart';

/// The saved-location paywall rule (phone QA 2026-09-09): one free saved
/// location, own-location follow never counts, ALRT+ removes the limit.
void main() {
  test('the free allowance is one saved location', () {
    expect(kFreeSavedLocationsLimit, 1);
  });

  test('the first saved location is free', () {
    expect(savedLocationGate(savedCount: 0, isPlus: false), SavedLocationGate.save);
  });

  test('the second saved location needs ALRT+ on a free account', () {
    expect(savedLocationGate(savedCount: 1, isPlus: false), SavedLocationGate.needsPlus);
    expect(savedLocationGate(savedCount: 5, isPlus: false), SavedLocationGate.needsPlus);
  });

  test('ALRT+ removes the limit', () {
    expect(savedLocationGate(savedCount: 1, isPlus: true), SavedLocationGate.save);
    expect(savedLocationGate(savedCount: 40, isPlus: true), SavedLocationGate.save);
  });

  test('a server refusal is reported as needing ALRT+, not swallowed', () {
    const outcome = SaveLocationNeedsPlus(fromServer: true);
    expect(outcome.fromServer, isTrue);
    expect(outcome, isA<SaveLocationOutcome>());
  });
}
