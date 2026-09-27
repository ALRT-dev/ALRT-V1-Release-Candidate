import 'package:flutter/foundation.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';

/// The status of an asynchronous family action.
enum FamilyActionStatus { initial, loading, success, error }

/// A lightweight, hand-written async action state
/// (kept freezed-free so no code generation is required).
@immutable
class FamilyActionState {
  const FamilyActionState._(this.status, this.error);

  const FamilyActionState.initial() : this._(FamilyActionStatus.initial, null);
  const FamilyActionState.loading() : this._(FamilyActionStatus.loading, null);
  const FamilyActionState.success() : this._(FamilyActionStatus.success, null);
  const FamilyActionState.error(final AppError error)
    : this._(FamilyActionStatus.error, error);

  final FamilyActionStatus status;
  final AppError? error;

  bool get isInitial => status == FamilyActionStatus.initial;
  bool get isLoading => status == FamilyActionStatus.loading;
  bool get isSuccess => status == FamilyActionStatus.success;
  bool get isError => status == FamilyActionStatus.error;

  @override
  bool operator ==(Object other) =>
      other is FamilyActionState &&
      other.status == status &&
      other.error == error;

  @override
  int get hashCode => Object.hash(status, error);
}

/// Sentinel used by [FamilyProviderState.copyWith] to distinguish
/// "not provided" from "explicitly set to null".
const _unset = Object();

/// The state of the family provider.
@immutable
class FamilyProviderState {
  const FamilyProviderState({
    this.circle,
    this.hasLoadedOnce = false,
    this.loadState = const FamilyActionState.initial(),
    this.activeSosEvents = const <FamilySosEvent>[],
    this.sosHistory = const <FamilySosEvent>[],
    this.recentCheckIns = const <FamilyCheckIn>[],
    this.scheduledCheckIns = const <FamilyScheduledCheckIn>[],
    this.circles = const <FamilyCircleSummary>[],
    this.sosLists = const <FamilySosList>[],
    this.invites = const <FamilyInvite>[],
    this.memberIdsNearAlert = const <String>{},
    this.invitesLoadState = const FamilyActionState.initial(),
    this.createInviteState = const FamilyActionState.initial(),
    this.checkInState = const FamilyActionState.initial(),
    this.requestCheckInState = const FamilyActionState.initial(),
    this.createCircleState = const FamilyActionState.initial(),
    this.joinCircleState = const FamilyActionState.initial(),
    this.leaveDeleteState = const FamilyActionState.initial(),
    this.memberUpdateState = const FamilyActionState.initial(),
    this.placeSaveState = const FamilyActionState.initial(),
    this.sosTriggerState = const FamilyActionState.initial(),
    this.sosRespondState = const FamilyActionState.initial(),
    this.activeJourney,
    this.journeyState = const FamilyActionState.initial(),
    this.sharedJourneys = const <FamilyJourney>[],
  });

  /// The user's family circle. `null` when the user has no circle.
  final FamilyCircle? circle;

  /// Whether [loadState] has completed at least once.
  final bool hasLoadedOnce;

  /// The state of loading the family circle.
  final FamilyActionState loadState;

  /// The currently active SOS events of the circle.
  final List<FamilySosEvent> activeSosEvents;

  /// Stood-down SOS events of the circle, newest first, each with the
  /// acknowledgments it collected while it ran. Retained history: the
  /// server never returns locations for these, only who/when.
  final List<FamilySosEvent> sosHistory;

  /// The caller's own journey while it is running, null otherwise.
  final FamilyJourney? activeJourney;

  /// Start/extend/stop progress for the journey screen.
  final FamilyActionState journeyState;

  /// Other members' journeys currently shared with the caller. Populated
  /// on every [FamilyProvider.load] (and its socket-triggered silent
  /// reloads), so a recipient sees this even if they missed the "shared
  /// with you" push notification and never had reason to visit a
  /// journey screen this session.
  final List<FamilyJourney> sharedJourneys;

  /// The most recent check-ins of the circle (newest first).
  final List<FamilyCheckIn> recentCheckIns;

  /// The circle's scheduled daily check-ins (sorted by time of day).
  final List<FamilyScheduledCheckIn> scheduledCheckIns;

  /// Every circle the user belongs to (drives the group switcher and the
  /// ALRT+ seat ledger). [circle] is the currently selected one, in full.
  final List<FamilyCircleSummary> circles;

  /// The user's SOS recipient presets (locked spec §28).
  final List<FamilySosList> sosLists;

  /// The circle's active invites.
  final List<FamilyInvite> invites;

  /// Ids of members reported near an active alert via socket proximity events.
  final Set<String> memberIdsNearAlert;

  final FamilyActionState invitesLoadState;
  final FamilyActionState createInviteState;
  final FamilyActionState checkInState;
  final FamilyActionState requestCheckInState;
  final FamilyActionState createCircleState;
  final FamilyActionState joinCircleState;
  final FamilyActionState leaveDeleteState;
  final FamilyActionState memberUpdateState;
  final FamilyActionState placeSaveState;
  final FamilyActionState sosTriggerState;
  final FamilyActionState sosRespondState;

  /// Active SOS events that were not triggered by the current user.
  List<FamilySosEvent> get activeSosFromOthers => activeSosEvents
      .where((sos) => sos.memberId != circle?.myMemberId)
      .toList();

  FamilyProviderState copyWith({
    final Object? circle = _unset,
    final bool? hasLoadedOnce,
    final FamilyActionState? loadState,
    final List<FamilySosEvent>? activeSosEvents,
    final List<FamilySosEvent>? sosHistory,
    final List<FamilyCheckIn>? recentCheckIns,
    final List<FamilyScheduledCheckIn>? scheduledCheckIns,
    final List<FamilyCircleSummary>? circles,
    final List<FamilySosList>? sosLists,
    final List<FamilyInvite>? invites,
    final Set<String>? memberIdsNearAlert,
    final FamilyActionState? invitesLoadState,
    final FamilyActionState? createInviteState,
    final FamilyActionState? checkInState,
    final FamilyActionState? requestCheckInState,
    final FamilyActionState? createCircleState,
    final FamilyActionState? joinCircleState,
    final FamilyActionState? leaveDeleteState,
    final FamilyActionState? memberUpdateState,
    final FamilyActionState? placeSaveState,
    final FamilyActionState? sosTriggerState,
    final FamilyActionState? sosRespondState,
    final Object? activeJourney = _unset,
    final FamilyActionState? journeyState,
    final List<FamilyJourney>? sharedJourneys,
  }) {
    return FamilyProviderState(
      circle: circle == _unset ? this.circle : circle as FamilyCircle?,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
      loadState: loadState ?? this.loadState,
      activeSosEvents: activeSosEvents ?? this.activeSosEvents,
      sosHistory: sosHistory ?? this.sosHistory,
      activeJourney: activeJourney == _unset
          ? this.activeJourney
          : activeJourney as FamilyJourney?,
      journeyState: journeyState ?? this.journeyState,
      sharedJourneys: sharedJourneys ?? this.sharedJourneys,
      recentCheckIns: recentCheckIns ?? this.recentCheckIns,
      scheduledCheckIns: scheduledCheckIns ?? this.scheduledCheckIns,
      circles: circles ?? this.circles,
      sosLists: sosLists ?? this.sosLists,
      invites: invites ?? this.invites,
      memberIdsNearAlert: memberIdsNearAlert ?? this.memberIdsNearAlert,
      invitesLoadState: invitesLoadState ?? this.invitesLoadState,
      createInviteState: createInviteState ?? this.createInviteState,
      checkInState: checkInState ?? this.checkInState,
      requestCheckInState: requestCheckInState ?? this.requestCheckInState,
      createCircleState: createCircleState ?? this.createCircleState,
      joinCircleState: joinCircleState ?? this.joinCircleState,
      leaveDeleteState: leaveDeleteState ?? this.leaveDeleteState,
      memberUpdateState: memberUpdateState ?? this.memberUpdateState,
      placeSaveState: placeSaveState ?? this.placeSaveState,
      sosTriggerState: sosTriggerState ?? this.sosTriggerState,
      sosRespondState: sosRespondState ?? this.sosRespondState,
    );
  }
}
