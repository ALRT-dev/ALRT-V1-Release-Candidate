import 'package:freezed_annotation/freezed_annotation.dart';

part 'family_models.freezed.dart';
part 'family_models.g.dart';

enum FamilyRole {
  owner,
  adult,
  child,

  /// Receives the circle's alerts and can say "I'm Safe". Never requests
  /// anyone's location, and consumes no seat on the owner's plan.
  guest,
}

enum FamilySharingLevel {
  precise,
  approximate,
  alertsOnly,
  off,
}

enum FamilyPlaceIcon {
  home,
  work,
  school,
  heart,
  other,
}

enum FamilyCheckInStatus {
  safe,
  needsHelp,
}

enum FamilyScheduledCheckInMode {
  automatic,
  prompted,
}

enum FamilySosStatus {
  active,
  resolved,
  cancelled,
}

enum FamilySosResponseType {
  seen,
  onMyWay,
  called,
}

/// How a location snapshot came to be shared — always a deliberate action.
enum FamilySnapshotSource {
  checkIn,
  request,
  sos,
  manual,
}

enum FamilyLocationRequestStatus {
  pending,
  shared,
  declined,
  expired,
}

/// Response of `GET /api/family/circle` — the family hub payload.
@freezed
abstract class FamilyCircle with _$FamilyCircle {
  const FamilyCircle._();

  const factory FamilyCircle({
    required final String id,
    required final String name,
    @Default('plus') final String plan,
    @Default(10) final int maxMembers,

    // Group rules (owner-set toggles, locked spec).
    /// The beacon colour: marks the group on member dots, snapshot pins,
    /// journey points and the widget.
    final String? themeColor,

    /// The group picture, set by the owner. Null means the circle is drawn
    /// as its initial on [themeColor], which is the default look.
    final String? photoUrl,

    /// True while this circle has no current, entitled host: the owner's
    /// ALRT+ lapsed, or they left/deleted their account. SOS, check-ins,
    /// journeys and the member list are never gated on this — only
    /// [hostTransitionLocked] restricts anything, and only invites/circle
    /// settings.
    @Default(false) final bool hostTransitionActive,

    /// 'owner_left' or 'entitlement_lapsed'. Only set while
    /// [hostTransitionActive].
    final String? hostTransitionReason,

    /// The departed/lapsed host's name, when known. Only set while
    /// [hostTransitionActive].
    final String? hostTransitionHostName,

    /// Days left before host-admin actions lock, counting down from 7.
    /// Only meaningful while [hostTransitionActive].
    final int? hostTransitionDaysLeft,

    /// True once the 7-day window has passed with nobody taking over:
    /// invites and circle settings lock, but every safety feature and the
    /// member list keep working, and nothing is removed automatically.
    @Default(false) final bool hostTransitionLocked,
    @Default(true) final bool anyoneCanRequestSnapshot,
    @Default(true) final bool sosToWholeGroup,
    @Default(true) final bool journeysSnapPointsOnly,
    required final String myMemberId,
    @Default(<FamilyMember>[]) final List<FamilyMember> members,
    @Default(<FamilySavedPlace>[]) final List<FamilySavedPlace> places,
    @Default(<FamilySosEvent>[]) final List<FamilySosEvent> activeSosEvents,
    final FamilyCheckInRequest? latestCheckInRequest,
    final DateTime? createdAt,
  }) = _FamilyCircle;

  FamilyMember? get me =>
      members.where((m) => m.id == myMemberId).firstOrNull;

  List<FamilyMember> get others =>
      members.where((m) => m.id != myMemberId).toList();

  /// The outstanding check-in request I still owe an answer to, if any -
  /// null when nobody has asked, when I'm the one who asked, or when I've
  /// already checked in since the ask. Any UI that is about to answer a
  /// check-in request (as opposed to a spontaneous "I'm Safe") should
  /// gate on this first: answering one is the one place a location-share
  /// consent choice is required before anything is sent.
  FamilyCheckInRequest? get checkInRequestOwedByMe {
    final request = latestCheckInRequest;
    if (request == null) return null;
    if (request.requestedById == myMemberId) return null;
    if (!request.isAimedAt(myMemberId)) return null;
    final askedAt = request.createdAt;
    final myLastCheckIn = me?.lastCheckInAt;
    final alreadyAnswered =
        askedAt != null &&
        myLastCheckIn != null &&
        myLastCheckIn.isAfter(askedAt);
    return alreadyAnswered ? null : request;
  }

  factory FamilyCircle.fromJson(Map<String, dynamic> json) =>
      _$FamilyCircleFromJson(json);
}

@freezed
abstract class FamilyMember with _$FamilyMember {
  const FamilyMember._();

  const factory FamilyMember({
    required final String id,
    required final String userId,
    @Default('Family member') final String name,
    final String? profilePictureUrl,
    final String? colorHex,
    @JsonKey(unknownEnumValue: FamilyRole.adult)
    @Default(FamilyRole.adult)
    final FamilyRole role,
    @JsonKey(unknownEnumValue: FamilySharingLevel.precise)
    @Default(FamilySharingLevel.precise)
    final FamilySharingLevel sharingLevel,
    final double? latitude,
    final double? longitude,
    final String? locationLabel,
    final DateTime? locationUpdatedAt,
    final DateTime? locationExpiresAt,
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    final FamilySnapshotSource? locationSharedVia,
    final int? batteryLevel,
    @Default(false) final bool isMoving,
    final String? currentPlaceId,
    final DateTime? lastCheckInAt,
    final DateTime? createdAt,
  }) = _FamilyMember;

  /// Two-letter initials for the avatar pin.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// True only while the server would still consider this snapshot valid.
  ///
  /// The server nulls out coordinates on expiry (both at every read and on
  /// a 5-minute sweep), so a fresh fetch is always correct — but a session
  /// that's been sitting on the map screen for over an hour with no other
  /// reason to reload would otherwise keep drawing a pin the server has
  /// already cleared. Checking [locationExpiresAt] here as well means the
  /// map stops drawing it the moment local time catches up, not just on
  /// the next reload.
  bool get hasLiveLocation =>
      latitude != null &&
      longitude != null &&
      (locationExpiresAt == null || locationExpiresAt!.isAfter(DateTime.now()));

  /// Checked in within the last 24 hours counts as "safe".
  bool get isCheckedInRecently =>
      lastCheckInAt != null &&
      DateTime.now().difference(lastCheckInAt!).inHours < 24;

  factory FamilyMember.fromJson(Map<String, dynamic> json) =>
      _$FamilyMemberFromJson(json);
}

@freezed
abstract class FamilyInvite with _$FamilyInvite {
  const factory FamilyInvite({
    required final String id,
    required final String code,
    @Default(0) final int useCount,
    @Default(10) final int maxUses,

    /// Whoever redeems this code joins as a guest.
    @Default(false) final bool isGuestInvite,
    final DateTime? expiresAt,
    final DateTime? createdAt,
  }) = _FamilyInvite;

  factory FamilyInvite.fromJson(Map<String, dynamic> json) =>
      _$FamilyInviteFromJson(json);
}

@freezed
abstract class FamilySavedPlace with _$FamilySavedPlace {
  const factory FamilySavedPlace({
    required final String id,
    required final String name,
    @JsonKey(unknownEnumValue: FamilyPlaceIcon.other)
    @Default(FamilyPlaceIcon.other)
    final FamilyPlaceIcon icon,
    required final double latitude,
    required final double longitude,
    @Default(300) final int radiusMeters,
    final String? address,
    @Default(<FamilyPlaceNotificationPref>[])
    final List<FamilyPlaceNotificationPref> notificationPrefs,
  }) = _FamilySavedPlace;

  factory FamilySavedPlace.fromJson(Map<String, dynamic> json) =>
      _$FamilySavedPlaceFromJson(json);
}

@freezed
abstract class FamilyPlaceNotificationPref with _$FamilyPlaceNotificationPref {
  const factory FamilyPlaceNotificationPref({
    required final String placeId,
    required final String subjectMemberId,
    @Default(true) final bool notifyArrivals,
    @Default(true) final bool notifyDepartures,
  }) = _FamilyPlaceNotificationPref;

  factory FamilyPlaceNotificationPref.fromJson(Map<String, dynamic> json) =>
      _$FamilyPlaceNotificationPrefFromJson(json);
}

/// Nested member snippet included in check-ins / SOS payloads.
@freezed
abstract class FamilyMemberSnippet with _$FamilyMemberSnippet {
  const FamilyMemberSnippet._();

  const factory FamilyMemberSnippet({
    required final String id,
    final String? nickname,
    final FamilyMemberUserSnippet? user,
  }) = _FamilyMemberSnippet;

  String get displayName => nickname ?? user?.name ?? 'Family member';

  factory FamilyMemberSnippet.fromJson(Map<String, dynamic> json) =>
      _$FamilyMemberSnippetFromJson(json);
}

@freezed
abstract class FamilyMemberUserSnippet with _$FamilyMemberUserSnippet {
  const factory FamilyMemberUserSnippet({
    required final String id,
    final String? name,
    final String? profilePictureUrl,
  }) = _FamilyMemberUserSnippet;

  factory FamilyMemberUserSnippet.fromJson(Map<String, dynamic> json) =>
      _$FamilyMemberUserSnippetFromJson(json);
}

@freezed
abstract class FamilyCheckIn with _$FamilyCheckIn {
  const factory FamilyCheckIn({
    required final String id,
    required final String circleId,
    required final String memberId,
    @JsonKey(unknownEnumValue: FamilyCheckInStatus.safe)
    @Default(FamilyCheckInStatus.safe)
    final FamilyCheckInStatus status,
    final String? message,
    final double? latitude,
    final double? longitude,
    final String? requestId,
    final String? hazardId,
    final FamilyMemberSnippet? member,
    final DateTime? createdAt,
  }) = _FamilyCheckIn;

  factory FamilyCheckIn.fromJson(Map<String, dynamic> json) =>
      _$FamilyCheckInFromJson(json);
}

/// An SOS recipient preset (locked spec §28): a named list owned by the
/// sender, configured in advance — never during an emergency.
@freezed
abstract class FamilySosList with _$FamilySosList {
  const factory FamilySosList({
    required final String id,
    required final String ownerUserId,
    required final String name,
    @Default(false) final bool isDefault,
    @Default(<String>[]) final List<String> memberIds,
    final DateTime? createdAt,
  }) = _FamilySosList;

  factory FamilySosList.fromJson(Map<String, dynamic> json) =>
      _$FamilySosListFromJson(json);
}

/// A member the host could hand the circle to (§29 TRANSFER), with
/// eligibility. Ineligible members are shown greyed with [reason],
/// never hidden.
@freezed
abstract class FamilyTransferCandidate with _$FamilyTransferCandidate {
  const factory FamilyTransferCandidate({
    required final String memberId,
    required final String name,
    final String? profilePictureUrl,
    @JsonKey(unknownEnumValue: FamilyRole.adult)
    @Default(FamilyRole.adult)
    final FamilyRole role,
    @Default(false) final bool eligible,

    /// Why the member cannot take over, when [eligible] is false.
    final String? reason,
  }) = _FamilyTransferCandidate;

  factory FamilyTransferCandidate.fromJson(Map<String, dynamic> json) =>
      _$FamilyTransferCandidateFromJson(json);
}

/// One group in GET /api/family/sos-recipients: a circle the user belongs
/// to, with the members an SOS list could reach.
@freezed
abstract class FamilySosRecipientGroup with _$FamilySosRecipientGroup {
  const factory FamilySosRecipientGroup({
    required final String circleId,
    required final String name,
    final String? themeColor,
    @Default(<FamilySosRecipient>[]) final List<FamilySosRecipient> members,
  }) = _FamilySosRecipientGroup;

  factory FamilySosRecipientGroup.fromJson(Map<String, dynamic> json) =>
      _$FamilySosRecipientGroupFromJson(json);
}

@freezed
abstract class FamilySosRecipient with _$FamilySosRecipient {
  const factory FamilySosRecipient({
    required final String memberId,
    required final String name,
    final String? profilePictureUrl,
    @JsonKey(unknownEnumValue: FamilyRole.adult)
    @Default(FamilyRole.adult)
    final FamilyRole role,
  }) = _FamilySosRecipient;

  factory FamilySosRecipient.fromJson(Map<String, dynamic> json) =>
      _$FamilySosRecipientFromJson(json);
}

/// GET /api/family/circle/transfer-candidates response.
@freezed
abstract class FamilyTransferCandidates with _$FamilyTransferCandidates {
  const factory FamilyTransferCandidates({
    required final String circleId,
    @Default(0) final int memberCount,
    @Default(<FamilyTransferCandidate>[])
    final List<FamilyTransferCandidate> candidates,
  }) = _FamilyTransferCandidates;

  factory FamilyTransferCandidates.fromJson(Map<String, dynamic> json) =>
      _$FamilyTransferCandidatesFromJson(json);
}

/// One row of GET /api/family/circles — a circle the user belongs to,
/// with just enough for the group switcher and the ALRT+ seat ledger.
@freezed
abstract class FamilyCircleSummary with _$FamilyCircleSummary {
  const factory FamilyCircleSummary({
    required final String circleId,
    required final String name,
    final String? themeColor,
    final String? photoUrl,
    @JsonKey(unknownEnumValue: FamilyRole.adult)
    @Default(FamilyRole.adult)
    final FamilyRole role,
    required final String myMemberId,
    @Default(0) final int memberCount,

    /// Members who hold a seat: everyone except guests, who join free.
    @Default(0) final int seatCount,

    /// True when the caller owns (pays for) this circle — its members
    /// consume the caller's seats.
    @Default(false) final bool isOwned,
    final DateTime? joinedAt,

    /// Members who checked in within the last day.
    @Default(0) final int checkedInCount,

    /// Names of members who have not checked in within the last day.
    @Default(<String>[]) final List<String> waitingOn,

    /// The latest SOS running in this circle, if any. Who and when only.
    final FamilyCircleSosSummary? activeSos,
  }) = _FamilyCircleSummary;

  factory FamilyCircleSummary.fromJson(Map<String, dynamic> json) =>
      _$FamilyCircleSummaryFromJson(json);
}

/// An SOS as the group list carries it: enough to say "SOS live · Tom" on
/// a group you do not have open. Never a location.
@freezed
abstract class FamilyCircleSosSummary with _$FamilyCircleSosSummary {
  const factory FamilyCircleSosSummary({
    required final String id,
    required final String memberId,
    @Default('Family member') final String memberName,
    final DateTime? createdAt,
  }) = _FamilyCircleSosSummary;

  factory FamilyCircleSosSummary.fromJson(Map<String, dynamic> json) =>
      _$FamilyCircleSosSummaryFromJson(json);
}

@freezed
abstract class FamilyScheduledCheckIn with _$FamilyScheduledCheckIn {
  const factory FamilyScheduledCheckIn({
    required final String id,
    required final String circleId,
    required final String memberId,

    /// "HH:mm" 24h, Australia/Brisbane local time.
    required final String timeOfDay,
    @JsonKey(unknownEnumValue: FamilyScheduledCheckInMode.prompted)
    @Default(FamilyScheduledCheckInMode.prompted)
    final FamilyScheduledCheckInMode mode,
    final DateTime? lastFiredAt,
    final FamilyMemberSnippet? member,
    final DateTime? createdAt,
  }) = _FamilyScheduledCheckIn;

  factory FamilyScheduledCheckIn.fromJson(Map<String, dynamic> json) =>
      _$FamilyScheduledCheckInFromJson(json);
}

@freezed
abstract class FamilyCheckInRequest with _$FamilyCheckInRequest {
  const factory FamilyCheckInRequest({
    required final String id,
    required final String circleId,
    required final String requestedById,
    final String? hazardId,
    final String? message,
    final FamilyMemberSnippet? requestedBy,
    @Default(<FamilyCheckIn>[]) final List<FamilyCheckIn> checkIns,

    /// Who this ask is aimed at. Empty = everyone in the circle.
    @Default(<String>[]) final List<String> targetMemberIds,
    final DateTime? createdAt,
  }) = _FamilyCheckInRequest;

  const FamilyCheckInRequest._();

  /// Whether [memberId] is one of the people this ask is waiting on.
  bool isAimedAt(final String memberId) =>
      targetMemberIds.isEmpty || targetMemberIds.contains(memberId);

  factory FamilyCheckInRequest.fromJson(Map<String, dynamic> json) =>
      _$FamilyCheckInRequestFromJson(json);
}

@freezed
abstract class FamilySosEvent with _$FamilySosEvent {
  const factory FamilySosEvent({
    required final String id,
    required final String circleId,
    required final String memberId,
    @JsonKey(unknownEnumValue: FamilySosStatus.active)
    @Default(FamilySosStatus.active)
    final FamilySosStatus status,
    // Whether the sender chose live location sharing for this SOS.
    // Defaults true: every SOS from before this field existed was live.
    @Default(true) final bool isLive,
    final double? latitude,
    final double? longitude,
    final String? locationLabel,
    final FamilyMemberSnippet? member,
    @Default(<FamilySosResponse>[]) final List<FamilySosResponse> responses,
    final DateTime? resolvedAt,
    final DateTime? createdAt,
  }) = _FamilySosEvent;

  factory FamilySosEvent.fromJson(Map<String, dynamic> json) =>
      _$FamilySosEventFromJson(json);
}

/// One point of an SOS live trail. These rows exist only while the SOS
/// runs: stand-down deletes them, so a trail can never outlive its SOS.
@freezed
abstract class FamilySosTrailPoint with _$FamilySosTrailPoint {
  const factory FamilySosTrailPoint({
    required final double latitude,
    required final double longitude,
    @Default(false) final bool isMoving,
    final DateTime? createdAt,
  }) = _FamilySosTrailPoint;

  factory FamilySosTrailPoint.fromJson(Map<String, dynamic> json) =>
      _$FamilySosTrailPointFromJson(json);
}

/// The movement trail of an active SOS, oldest point first.
@freezed
abstract class FamilySosTrail with _$FamilySosTrail {
  const factory FamilySosTrail({
    required final String sosEventId,
    @Default(<FamilySosTrailPoint>[]) final List<FamilySosTrailPoint> points,
  }) = _FamilySosTrail;

  factory FamilySosTrail.fromJson(Map<String, dynamic> json) =>
      _$FamilySosTrailFromJson(json);
}

/// "Sarah asked where you are" — a one-time, consent-gated location request.
@freezed
abstract class FamilyLocationRequest with _$FamilyLocationRequest {
  const factory FamilyLocationRequest({
    required final String id,
    required final String circleId,
    required final String requesterId,
    required final String targetMemberId,
    @JsonKey(unknownEnumValue: FamilyLocationRequestStatus.pending)
    @Default(FamilyLocationRequestStatus.pending)
    final FamilyLocationRequestStatus status,
    final String? message,
    final FamilyMemberSnippet? requester,
    final DateTime? respondedAt,
    final DateTime? expiresAt,
    final DateTime? createdAt,
  }) = _FamilyLocationRequest;

  factory FamilyLocationRequest.fromJson(Map<String, dynamic> json) =>
      _$FamilyLocationRequestFromJson(json);
}

@freezed
abstract class FamilySosResponse with _$FamilySosResponse {
  const factory FamilySosResponse({
    required final String id,
    required final String sosEventId,
    required final String memberId,
    @JsonKey(unknownEnumValue: FamilySosResponseType.seen)
    @Default(FamilySosResponseType.seen)
    final FamilySosResponseType type,
    final FamilyMemberSnippet? member,
    final DateTime? createdAt,
  }) = _FamilySosResponse;

  factory FamilySosResponse.fromJson(Map<String, dynamic> json) =>
      _$FamilySosResponseFromJson(json);
}

/// Who a journey is being shared with.
@freezed
abstract class FamilyJourneyRecipient with _$FamilyJourneyRecipient {
  const factory FamilyJourneyRecipient({
    required final String memberId,
    @Default('Family member') final String name,
    final String? profilePictureUrl,
  }) = _FamilyJourneyRecipient;

  factory FamilyJourneyRecipient.fromJson(Map<String, dynamic> json) =>
      _$FamilyJourneyRecipientFromJson(json);
}

/// A trip someone chose to share, always with a stop time they picked.
///
/// Snap points are the default; [isLive] is a per-journey opt-in. A journey
/// that has ended carries no coordinates at all: the times survive, the
/// places do not.
@freezed
abstract class FamilyJourney with _$FamilyJourney {
  const FamilyJourney._();

  const factory FamilyJourney({
    required final String id,
    required final String circleId,
    required final String memberId,
    @Default('Family member') final String memberName,
    @Default('active') final String status,
    @Default(false) final bool isLive,
    required final DateTime endsAt,
    final DateTime? endedAt,
    @Default(0) final int grantedMinutes,
    @Default(true) final bool canExtend,
    @Default(240) final int maxTotalMinutes,
    final double? latitude,
    final double? longitude,
    final String? locationLabel,
    @Default(<FamilyJourneyRecipient>[])
    final List<FamilyJourneyRecipient> recipients,
    final DateTime? createdAt,
  }) = _FamilyJourney;

  /// Still sharing: not stopped, and the chosen stop time has not passed.
  bool get isActive => status == 'active' && endsAt.isAfter(DateTime.now());

  /// How long is left before it stops itself.
  Duration get remaining {
    final left = endsAt.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  factory FamilyJourney.fromJson(Map<String, dynamic> json) =>
      _$FamilyJourneyFromJson(json);
}
