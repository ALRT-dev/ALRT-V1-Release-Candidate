import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_socket_manager_provider.dart';
import 'package:hazard_app/features/family/services/family_service.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';

/// State for the recipient's shared-journey viewer screen.
class ViewedJourneyState {
  const ViewedJourneyState({this.journey, this.loading = false, this.error});

  final FamilyJourney? journey;
  final bool loading;
  final AppError? error;
}

/// Loads and polls a single shared journey by id for the recipient viewer
/// screen — the screen a journey-share notification deep-links into.
///
/// This reuses the app's existing journey machinery rather than standing up
/// a second real-time stack: the same single-journey GET the traveller's own
/// device already has, polled at the cadence [FamilyProvider] uses to post
/// journey points (so a live journey refreshes about as often as it moves),
/// plus an immediate refetch on the existing `familyCircleUpdate` socket
/// ping, which already fires when a journey starts or stops.
class ViewedJourneyNotifier extends Notifier<ViewedJourneyState> {
  /// Matches FamilyProvider's snap-journey point cadence.
  static const _snapPollInterval = Duration(minutes: 10);

  /// Matches FamilyProvider's live-journey point cadence.
  static const _livePollInterval = Duration(seconds: 45);

  Timer? _pollTimer;
  String? _journeyId;

  FamilyService get _familyService => ref.read(providerOfFamilyService);

  @override
  ViewedJourneyState build() {
    final sub = ref
        .read(providerOfFamilySocketManager)
        .circleUpdateStream
        .listen((_) {
          final journeyId = _journeyId;
          if (journeyId != null) unawaited(_fetch(journeyId));
        });
    ref.onDispose(() {
      _pollTimer?.cancel();
      unawaited(sub.cancel());
    });
    return const ViewedJourneyState();
  }

  /// Loads [journeyId] and starts polling while it's still active.
  Future<void> load(final String journeyId) async {
    _journeyId = journeyId;
    state = const ViewedJourneyState(loading: true);
    await _fetch(journeyId);
  }

  /// Stops polling. Call when the viewer screen is closed.
  void stopWatching() {
    _journeyId = null;
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _fetch(final String journeyId) async {
    final result = await _familyService.getFamilyJourney(
      journeyId: journeyId,
    );
    // The screen may have navigated away (or on to a different journey)
    // while this request was in flight.
    if (_journeyId != journeyId) return;

    result.when(
      (journey) {
        state = ViewedJourneyState(journey: journey);
        journey.isActive ? _schedulePoll(journey) : _stopPolling();
      },
      (error) {
        _stopPolling();
        state = ViewedJourneyState(error: error);
      },
    );
  }

  void _schedulePoll(final FamilyJourney journey) {
    _pollTimer?.cancel();
    final journeyId = journey.id;
    _pollTimer = Timer(
      journey.isLive ? _livePollInterval : _snapPollInterval,
      () => unawaited(_fetch(journeyId)),
    );
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }
}

final providerOfViewedJourney =
    NotifierProvider<ViewedJourneyNotifier, ViewedJourneyState>(
      ViewedJourneyNotifier.new,
    );
