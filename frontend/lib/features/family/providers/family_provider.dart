import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_socket_manager_provider.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/features/family/providers/selected_circle_provider.dart';
import 'package:hazard_app/features/family/providers/states/family_provider_state.dart';
import 'package:hazard_app/features/family/services/family_location_service.dart';
import 'package:hazard_app/features/family/services/family_service.dart';
import 'package:hazard_app/features/home_screen_widget/family_widget_sync.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/providers/navigator_key_provider.dart';
import 'package:hazard_app/features/shared/services/analytics_service.dart';
import 'package:hazard_app/features/family/views/widgets/family_location_request_sheet.dart';
import 'package:hazard_app/features/family/views/widgets/incoming_family_alert_overlay.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_receiver_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

final providerOfFamily =
    StateNotifierProvider<FamilyProvider, FamilyProviderState>(
      (ref) => FamilyProvider(
        ref: ref,
        state: const FamilyProviderState(),
      ),
    );

class FamilyProvider extends StateNotifier<FamilyProviderState> {
  FamilyProvider({
    required final Ref ref,
    required final FamilyProviderState state,
  }) : _ref = ref,
       super(state) {
    _listenToSocketEvents();
    // Load the circle right away: the socket listeners above drop events
    // when circle is null, so a phone that had not opened the family tab
    // yet missed its check-in banner (QA 2026-08-06, one of two phones).
    Future<void>.microtask(() => load(silent: true));
    // Mirror family status onto the home-screen widget on every state change
    // (a signature guard inside suppresses redundant writes).
    addListener(FamilyWidgetSync.push, fireImmediately: true);
  }

  final Ref _ref;
  FamilyService get _familyService => _ref.read(providerOfFamilyService);
  FamilyLocationService get _familyLocationService =>
      _ref.read(providerOfFamilyLocationService);
  FamilySocketManager get _familySocketManager =>
      _ref.read(providerOfFamilySocketManager);

  static const _recentCheckInsLimit = 20;

  /// SOS live share: while MY SOS is active the phone shares a point every
  /// [_sosLiveInterval]. This is the single permitted continuous stream
  /// (locked spec); the server caps the event at 4 hours and stand-down
  /// wipes the trail.
  static const _sosLiveInterval = Duration(seconds: 20);
  Timer? _sosLiveTimer;

  void _startSosLiveShare() {
    _sosLiveTimer?.cancel();
    _sosLiveTimer = Timer.periodic(_sosLiveInterval, (_) async {
      // Stop the loop the moment my SOS is no longer active, whichever
      // side ended it (my stand-down, or the server's 4-hour lapse).
      final myMemberId = state.circle?.myMemberId;
      final mineActive = state.activeSosEvents.any(
        (event) =>
            event.memberId == myMemberId &&
            event.status == FamilySosStatus.active,
      );
      if (!mineActive) {
        _stopSosLiveShare();
        return;
      }
      await _familyLocationService.shareSnapshotNow();
    });
  }

  void _stopSosLiveShare() {
    _sosLiveTimer?.cancel();
    _sosLiveTimer = null;
  }

  // ---------------------------- SOCKET EVENTS ----------------------------

  void _listenToSocketEvents() {
    final subscriptions = <StreamSubscription>[
      _familySocketManager.circleUpdateStream.listen(
        (_) => load(silent: true),
      ),
      _familySocketManager.locationUpdateStream.listen(_patchMemberLocation),
      _familySocketManager.checkInStream.listen(_onCheckInReceived),
      _familySocketManager.checkInRequestStream.listen(
        _onCheckInRequestReceived,
      ),
      _familySocketManager.locationRequestStream.listen(
        _onLocationRequestReceived,
      ),
      _familySocketManager.placeEventStream.listen((_) => _refreshPlaces()),
      _familySocketManager.sosStream.listen(_onSosReceived),
      _familySocketManager.sosResponseStream.listen(_onSosResponseReceived),
      _familySocketManager.sosResolvedStream.listen(_onSosResolved),
      _familySocketManager.hazardProximityStream.listen(_onHazardProximity),
    ];

    // The live connection itself: while it is down, nothing above fires,
    // so the hub polls instead; when it comes back, everything that
    // happened in the gap is fetched in one go.
    final socketService = _ref.read(providerOfSocketService);
    final liveSubscription = socketService.onSocketConnectionChanged.listen(
      _onLiveConnectionChanged,
    );
    if (!socketService.isSocketConnected) _startStalePolling();

    _ref.onDispose(() {
      _stopSosLiveShare();
      _stopJourneyPoints();
      _stopStalePolling();
      liveSubscription.cancel();
      for (final subscription in subscriptions) {
        subscription.cancel();
      }
    });
  }

  /// While the socket is down the hub refreshes itself this often, so a
  /// check-in or SOS never sits unseen behind a dead connection. Cheap:
  /// one circle fetch, only when a circle is loaded and not mid-load.
  static const _stalePollInterval = Duration(seconds: 30);
  Timer? _stalePollTimer;
  var _wasLiveBefore = false;

  void _onLiveConnectionChanged(final bool connected) {
    if (!connected) {
      _startStalePolling();
      return;
    }
    _stopStalePolling();
    // A RE-connect means events were missed in the gap: catch up now.
    // The very first connect at app start needs nothing, the initial
    // load is already in flight.
    if (_wasLiveBefore && state.hasLoadedOnce && !state.loadState.isLoading) {
      unawaited(load(silent: true));
    }
    _wasLiveBefore = true;
  }

  void _startStalePolling() {
    if (_stalePollTimer?.isActive ?? false) return;
    _stalePollTimer = Timer.periodic(_stalePollInterval, (_) {
      if (!mounted) return;
      if (state.circle == null || state.loadState.isLoading) return;
      unawaited(load(silent: true));
    });
  }

  void _stopStalePolling() {
    _stalePollTimer?.cancel();
    _stalePollTimer = null;
  }

  /// Patches the live location fields of a member in the circle.
  void _patchMemberLocation(final FamilyMember incoming) {
    final circle = state.circle;
    if (circle == null) return;

    final members = circle.members.map((member) {
      if (member.id != incoming.id) return member;
      return member.copyWith(
        latitude: incoming.latitude,
        longitude: incoming.longitude,
        locationLabel: incoming.locationLabel ?? member.locationLabel,
        locationUpdatedAt: incoming.locationUpdatedAt ?? DateTime.now(),
        batteryLevel: incoming.batteryLevel ?? member.batteryLevel,
        isMoving: incoming.isMoving,
        currentPlaceId: incoming.currentPlaceId,
      );
    }).toList();

    state = state.copyWith(circle: circle.copyWith(members: members));
  }

  /// Appends a check-in, updates the member's last check-in time and shows a
  /// quiet toast when it came from another member.
  void _onCheckInReceived(final FamilyCheckIn checkIn) {
    _appendCheckIn(checkIn);
    _refreshGroupListIfOtherCircle(checkIn.circleId);

    if (checkIn.memberId != state.circle?.myMemberId) {
      final name = checkIn.member?.displayName ?? 'A family member';
      final label = checkIn.status == FamilyCheckInStatus.safe
          ? '$name checked in safe'
          : '$name needs help';
      _showToast(message: label, isWarning: checkIn.status != FamilyCheckInStatus.safe);
    }
  }

  void _onCheckInRequestReceived(final FamilyCheckInRequest request) {
    // Same user-level guard as SOS: member ids differ per circle, so the
    // requester's own phone must be recognised by USER id too.
    final myUserId = _ref.read(providerOfLoggedInUser)?.id;
    final requesterUserId = request.requestedBy?.user?.id;
    final isMine = requesterUserId != null && requesterUserId == myUserId;

    final circle = state.circle;
    if (circle == null) {
      // The event beat the first load. The backend only emits to members
      // of the circle, so the request is real: alert now, catch up after.
      unawaited(load(silent: true));
      if (isMine) return;
      final name = request.requestedBy?.displayName ?? 'A family member';
      // The in-app alert has no consent UI, so its one tap checks in
      // WITHOUT location - exactly what a check-in request asks for.
      // Sharing a snapshot stays a deliberate choice on the Family hub.
      _showBigAlert(
        title: '$name asked for a check-in',
        body: 'One tap to let them know you are safe.',
        isSos: false,
        onTap: () => checkIn(shareLocation: false),
      );
      return;
    }

    state = state.copyWith(
      circle: circle.copyWith(latestCheckInRequest: request),
    );

    if (!isMine && request.requestedById != circle.myMemberId) {
      final name = request.requestedBy?.displayName ?? 'A family member';
      // "Everyone" was confusing: the requester is not waiting on
      // themself. Count who is actually outstanding.
      final waitingOn = circle.others
          .where((m) => !m.isCheckedInRecently)
          .length;
      // The server sends a targeted ask to its targets only, so one that
      // names people and reached this phone is aimed at me.
      final targeted = request.targetMemberIds.isNotEmpty;
      _showBigAlert(
        title: targeted
            ? '$name asked you to check in'
            : '$name asked for a check-in',
        body: !targeted && waitingOn > 1
            ? 'Waiting on $waitingOn people. One tap says you are safe.'
            : 'One tap to let them know you are safe.',
        isSos: false,
        // No consent UI on the alert itself: check in without location.
        onTap: () => checkIn(shareLocation: false),
      );
    }
  }

  /// Request ids the consent sheet has already been raised for, so a
  /// socket event and the pending-requests catch-up never double-prompt.
  final Set<String> _promptedLocationRequestIds = {};

  /// Raises the Share once / Not now sheet for a "where are you" ask.
  ///
  /// The push notification used to be the ONLY path to this sheet, so a
  /// phone with notifications off never saw the ask and the requester
  /// waited forever. The socket brings it up while the app is open.
  void _onLocationRequestReceived(final FamilyLocationRequest request) {
    _promptLocationRequest(request);
  }

  void _promptLocationRequest(final FamilyLocationRequest request) {
    if (_promptedLocationRequestIds.contains(request.id)) return;

    // The id is recorded only once the sheet actually shows: on a cold
    // start this can run before the navigator exists, and marking the
    // request "prompted" then would suppress it for the whole session.
    final context = _ref.read(providerOfGlobalNavigatorKey).currentContext;
    if (context == null || !context.mounted) return;
    _promptedLocationRequestIds.add(request.id);
    unawaited(
      showFamilyLocationRequestSheet(
        context: context,
        requestId: request.id,
        requesterName: request.requester?.displayName,
      ).then((_) {
        // One sheet at a time: once this ask is answered or dismissed,
        // surface the next pending one, if another arrived meanwhile.
        if (mounted) _checkPendingLocationRequests();
      }),
    );
  }

  /// Catch-up for asks that arrived while the app was closed and whose
  /// push never landed (notifications off). Called after each load and
  /// after each answered sheet.
  Future<void> _checkPendingLocationRequests() async {
    final result = await _familyService.getPendingFamilyLocationRequests();
    if (!mounted) return;
    result.whenSuccess((requests) {
      // Newest first; prompt one at a time, never a stack of sheets.
      for (final request in requests) {
        if (!_promptedLocationRequestIds.contains(request.id)) {
          _promptLocationRequest(request);
          break;
        }
      }
      return null;
    });
  }

  void _onSosReceived(final FamilySosEvent sosEvent) {
    _upsertSosEvent(sosEvent);
    _refreshGroupListIfOtherCircle(sosEvent.circleId);

    // "Mine" is decided by USER, not by member id: member ids differ per
    // circle, so a cross-group SOS (or a not-yet-loaded circle) made the
    // member-id check pass on the sender's own phone and showed them the
    // "needs help" banner for their own SOS (two-phone QA 2026-08-07).
    final myUserId = _ref.read(providerOfLoggedInUser)?.id;
    final senderUserId = sosEvent.member?.user?.id;
    final isMine =
        sosEvent.memberId == state.circle?.myMemberId ||
        (senderUserId != null && senderUserId == myUserId);

    if (!isMine && sosEvent.status == FamilySosStatus.active) {
      final name = sosEvent.member?.displayName ?? 'A family member';
      // Screen already on and in the app: a corner toast is the wrong
      // size for this. Take the top of the screen with a bright pulsing
      // outline, and open the SOS on tap.
      _showBigAlert(
        title: '$name triggered SOS',
        body: sosEvent.locationLabel != null
            ? 'Live location shared near ${sosEvent.locationLabel}.'
            : 'Live location shared. Open to respond.',
        isSos: true,
        onTap: () {
          final context =
              _ref.read(providerOfGlobalNavigatorKey).currentContext;
          if (context == null || !context.mounted) return;
          context.push(
            FamilySosReceiverScreen.route,
            extra: FamilySosReceiverScreenArgs(sosEvent: sosEvent),
          );
        },
      );
    }
  }

  void _onSosResponseReceived(final FamilySosResponse response) {
    final events = state.activeSosEvents.map((event) {
      if (event.id != response.sosEventId) return event;
      final responses = [
        ...event.responses.where(
          (r) => r.memberId != response.memberId || r.type != response.type,
        ),
        response,
      ];
      return event.copyWith(responses: responses);
    }).toList();

    state = state.copyWith(activeSosEvents: events);

    // The person IN SOS is told, loudly, who has seen it and who is
    // coming — that reassurance is the point of responding (product
    // owner 2026-08-07). Only for MY event, and never for my own tap.
    FamilySosEvent? event;
    for (final e in events) {
      if (e.id == response.sosEventId) {
        event = e;
        break;
      }
    }
    if (event == null) return;

    final myUserId = _ref.read(providerOfLoggedInUser)?.id;
    final eventIsMine =
        event.memberId == state.circle?.myMemberId ||
        (event.member?.user?.id != null &&
            event.member?.user?.id == myUserId);
    final responderIsMe =
        response.memberId == state.circle?.myMemberId ||
        (response.member?.user?.id != null &&
            response.member?.user?.id == myUserId);
    if (!eventIsMine || responderIsMe) return;

    final name = response.member?.displayName ?? 'A family member';
    final title = switch (response.type) {
      FamilySosResponseType.onMyWay => '$name is on their way to you',
      FamilySosResponseType.called => '$name is calling for help for you',
      _ => '$name has seen your SOS',
    };
    _showBigAlert(
      title: title,
      body: 'They can see your live location.',
      isSos: false,
      onTap: null,
    );
  }

  /// An SOS ended (stood down by hand, or lapsed server-side). It leaves the
  /// active list and moves straight into [FamilyProviderState.sosHistory]
  /// with every acknowledgment it collected, so the record stays on screen
  /// without waiting for a refetch. Locations are dropped on the way: the
  /// retained history is who/when, never where. The server copy is then
  /// refreshed so the entry matches what every other member sees.
  void _onSosResolved(final FamilySosEvent sosEvent) {
    final ended = state.activeSosEvents
        .where((event) => event.id == sosEvent.id)
        .firstOrNull;
    final source = ended ?? sosEvent;
    final historyEntry = source.copyWith(
      status: sosEvent.status == FamilySosStatus.active
          ? FamilySosStatus.resolved
          : sosEvent.status,
      resolvedAt: sosEvent.resolvedAt ?? source.resolvedAt ?? DateTime.now(),
      responses: source.responses.isNotEmpty
          ? source.responses
          : sosEvent.responses,
      latitude: null,
      longitude: null,
      locationLabel: null,
    );
    state = state.copyWith(
      activeSosEvents: state.activeSosEvents
          .where((event) => event.id != sosEvent.id)
          .toList(),
      sosHistory: [
        historyEntry,
        ...state.sosHistory.where((event) => event.id != sosEvent.id),
      ],
    );
    unawaited(_refreshSosHistory());
    _refreshGroupListIfOtherCircle(sosEvent.circleId);
  }

  /// The group tiles show state for groups that are NOT open, read from
  /// the group list. A live event from one of those groups (a check-in, an
  /// SOS starting or ending) refreshes that list so the tile moves at
  /// once; events for the open group already patch its members directly.
  void _refreshGroupListIfOtherCircle(final String circleId) {
    if (circleId == state.circle?.id) return;
    if (!state.circles.any((c) => c.circleId == circleId)) return;
    unawaited(_refreshCircleList());
  }

  void _onHazardProximity(final Map<String, dynamic> payload) {
    final memberId = payload['memberId']?.toString();
    if (memberId == null) return;

    final isNear =
        (payload['isNear'] ?? payload['inProximity'] ?? true) == true;

    final ids = {...state.memberIdsNearAlert};
    isNear ? ids.add(memberId) : ids.remove(memberId);
    state = state.copyWith(memberIdsNearAlert: ids);
  }

  // ---------------------------- CIRCLE ----------------------------

  /// Loads the family circle and, when one exists, its recent check-ins and
  /// active SOS events.
  Future<void> load({final bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(loadState: const FamilyActionState.loading());
    }

    await _refreshCircleList();

    final result = await _familyService.getFamilyCircle();
    if (!mounted) return;

    await result.when(
      (circle) async {
        state = state.copyWith(
          circle: circle,
          hasLoadedOnce: true,
          loadState: const FamilyActionState.success(),
          activeSosEvents: circle?.activeSosEvents ?? const [],
        );

        if (circle != null) {
          await Future.wait([
            _refreshRecentCheckIns(),
            _refreshActiveSosEvents(),
            _refreshSosHistory(),
            _checkPendingLocationRequests(),
          ]);
        }
      },
      (error) async {
        // A silent failure is only allowed to stay silent when the screen
        // already shows a truthful answer — a loaded circle, OR a prior
        // successful load that said "no group" (a failed background
        // refresh must not swap the onboarding pitch for an error). With
        // nothing loaded yet, swallowing the error made the tab conclude
        // "no group" and show the create-a-group pitch — on a phone with
        // patchy network the group looked like it had vanished every
        // cold start.
        final canStaySilent =
            silent && (state.circle != null || state.loadState.isSuccess);
        state = state.copyWith(
          hasLoadedOnce: true,
          loadState: canStaySilent
              ? state.loadState
              : FamilyActionState.error(error),
        );
      },
    );
  }

  /// Refreshes the list of all circles the user belongs to, and drops a
  /// stale selection (e.g. after leaving the selected circle).
  Future<void> _refreshCircleList() async {
    final result = await _familyService.getFamilyCircles();
    if (!mounted) return;

    result.whenSuccess((circles) {
      state = state.copyWith(circles: circles);

      final selected = _ref.read(providerOfSelectedCircleId);
      if (selected != null && !circles.any((c) => c.circleId == selected)) {
        _ref.read(providerOfSelectedCircleId.notifier).select(null);
      }
      return null;
    });
  }

  /// Switches the family tab to [circleId] (null = first circle) and
  /// reloads everything under the new scope.
  Future<void> selectCircle(final String? circleId) async {
    if (_ref.read(providerOfSelectedCircleId) == circleId) return;
    _ref.read(providerOfSelectedCircleId.notifier).select(circleId);
    await load();
  }

  /// Owner-only: updates the circle's name and group rules, then reloads.
  Future<bool> updateGroupSettings({
    final String? name,
    final String? themeColor,
    final bool? anyoneCanRequestSnapshot,
    final bool? sosToWholeGroup,
    final bool? journeysSnapPointsOnly,
  }) async {
    final result = await _familyService.updateFamilyCircle(
      name: name,
      themeColor: themeColor,
      anyoneCanRequestSnapshot: anyoneCanRequestSnapshot,
      sosToWholeGroup: sosToWholeGroup,
      journeysSnapPointsOnly: journeysSnapPointsOnly,
    );
    if (!mounted) return false;

    return result.when(
      (_) {
        load(silent: true);
        return true;
      },
      (_) => false,
    );
  }

  /// Owner-only (§29 TRANSFER): members the host could hand the circle to,
  /// with eligibility. Returns null on failure.
  Future<FamilyTransferCandidates?> loadTransferCandidates() async {
    final result = await _familyService.getFamilyTransferCandidates();
    if (!mounted) return null;
    return result.when((candidates) => candidates, (_) => null);
  }

  /// Owner-only (§29 TRANSFER): hands the circle — and its seats — to
  /// [newOwnerMemberId]. The prior host stays on as an adult member.
  Future<bool> transferOwnership({
    required final String newOwnerMemberId,
  }) async {
    final result = await _familyService.transferFamilyOwnership(
      newOwnerMemberId: newOwnerMemberId,
    );
    if (!mounted) return false;

    return result.when(
      (_) {
        load(silent: true);
        _refreshCircleList();
        return true;
      },
      (_) => false,
    );
  }

  // ------------------------ SOS RECIPIENT PRESETS ------------------------

  Future<void> loadSosLists() async {
    final result = await _familyService.getFamilySosLists();
    if (!mounted) return;
    result.whenSuccess((lists) {
      state = state.copyWith(sosLists: lists);
      return null;
    });
  }

  /// Everyone the user could put on a list, grouped by circle. Returns null
  /// on failure so the editor can show a retry instead of an empty page.
  Future<List<FamilySosRecipientGroup>?> loadSosRecipients() async {
    final result = await _familyService.getFamilySosRecipients();
    if (!mounted) return null;
    return result.when((groups) => groups, (_) => null);
  }

  /// Takeover: revive the paused circle by becoming its host. Returns null
  /// on success, otherwise the backend's refusal in plain words — the
  /// backend is the only judge of eligibility, so its reason is shown
  /// verbatim rather than pre-computed client-side.
  Future<String?> takeOverCircle() async {
    final result = await _familyService.takeOverFamilyCircle();
    if (!mounted) return 'Something went wrong';
    return result.when(
      (_) {
        load(silent: true);
        return null;
      },
      (error) => error.message,
    );
  }

  /// Creates or updates a preset; pass [sosListId] to edit an existing one.
  Future<bool> saveSosList({
    final String? sosListId,
    required final String name,
    required final List<String> memberIds,
    final bool? isDefault,
  }) async {
    final result = sosListId == null
        ? await _familyService.createFamilySosList(
            name: name,
            memberIds: memberIds,
            isDefault: isDefault,
          )
        : await _familyService.updateFamilySosList(
            sosListId: sosListId,
            name: name,
            memberIds: memberIds,
            isDefault: isDefault,
          );
    if (!mounted) return false;

    return result.when(
      (_) {
        loadSosLists();
        return true;
      },
      (_) => false,
    );
  }

  Future<bool> removeSosList({required final String sosListId}) async {
    final result = await _familyService.deleteFamilySosList(
      sosListId: sosListId,
    );
    if (!mounted) return false;

    return result.when(
      (_) {
        state = state.copyWith(
          sosLists: state.sosLists
              .where((list) => list.id != sosListId)
              .toList(),
        );
        return true;
      },
      (_) => false,
    );
  }

  Future<void> createCircle({required final String name}) async {
    state = state.copyWith(
      createCircleState: const FamilyActionState.loading(),
    );

    final result = await _familyService.createFamilyCircle(name: name);
    if (!mounted) return;

    await result.when(
      (circle) async {
        // Scope the tab to the group just made. Without this the selection
        // still points at the oldest membership, so the next load — a
        // socket update, a pull-to-refresh, an app resume — quietly
        // switched back and the new group looked like it had not been
        // created. It also has to reach the circles list, or the switcher
        // and the home-screen widget never learn about it.
        _ref.read(providerOfSelectedCircleId.notifier).select(circle.id);
        state = state.copyWith(
          circle: circle,
          hasLoadedOnce: true,
          loadState: const FamilyActionState.success(),
          createCircleState: const FamilyActionState.success(),
        );
        await _refreshCircleList();
      },
      (error) async {
        state = state.copyWith(
          createCircleState: FamilyActionState.error(error),
        );
      },
    );
  }

  Future<void> join({required final String code}) async {
    state = state.copyWith(joinCircleState: const FamilyActionState.loading());

    final result = await _familyService.joinFamilyCircle(code: code);
    if (!mounted) return;

    await result.when(
      (circle) async {
        // Same as creating: scope to the group just joined and pull it into
        // the circles list, so it survives the next load and shows up in
        // the switcher.
        _ref.read(providerOfSelectedCircleId.notifier).select(circle.id);
        state = state.copyWith(
          circle: circle,
          hasLoadedOnce: true,
          loadState: const FamilyActionState.success(),
          joinCircleState: const FamilyActionState.success(),
        );
        await _refreshCircleList();
      },
      (error) async {
        state = state.copyWith(joinCircleState: FamilyActionState.error(error));
      },
    );
  }

  Future<void> leave() => _leaveOrDelete(isDelete: false);

  Future<void> deleteCircle() => _leaveOrDelete(isDelete: true);

  Future<void> _leaveOrDelete({required final bool isDelete}) async {
    state = state.copyWith(
      leaveDeleteState: const FamilyActionState.loading(),
    );

    final result = isDelete
        ? await _familyService.deleteFamilyCircle()
        : await _familyService.leaveFamilyCircle();
    if (!mounted) return;

    result.when(
      (_) {
        state = const FamilyProviderState(
          hasLoadedOnce: true,
          loadState: FamilyActionState.success(),
          leaveDeleteState: FamilyActionState.success(),
        );
      },
      (error) {
        state = state.copyWith(
          leaveDeleteState: FamilyActionState.error(error),
        );
      },
    );
  }

  Future<void> removeMember({required final String memberId}) async {
    final result = await _familyService.removeFamilyMember(memberId: memberId);
    if (!mounted) return;

    result.when(
      (_) => load(silent: true),
      (error) => _showToast(message: error.message, isWarning: true),
    );
  }

  // ---------------------------- OWN MEMBER ----------------------------

  Future<void> updateSharingLevel(final FamilySharingLevel level) async {
    state = state.copyWith(
      memberUpdateState: const FamilyActionState.loading(),
    );

    final result = await _familyService.updateOwnFamilyMember(
      sharingLevel: level,
    );
    if (!mounted) return;

    result.when(
      (_) {
        final circle = state.circle;
        final members = circle?.members
            .map(
              (member) => member.id == circle.myMemberId
                  ? member.copyWith(sharingLevel: level)
                  : member,
            )
            .toList();

        state = state.copyWith(
          circle: members == null ? circle : circle?.copyWith(members: members),
          memberUpdateState: const FamilyActionState.success(),
        );
      },
      (error) {
        state = state.copyWith(
          memberUpdateState: FamilyActionState.error(error),
        );
      },
    );
  }

  /// Updates the member's circle profile (nickname and/or accent colour).
  Future<bool> updateMyProfile({
    final String? nickname,
    final String? colorHex,
  }) async {
    state = state.copyWith(
      memberUpdateState: const FamilyActionState.loading(),
    );

    final result = await _familyService.updateOwnFamilyMember(
      nickname: nickname,
      colorHex: colorHex,
    );
    if (!mounted) return false;

    return result.when(
      (_) {
        state = state.copyWith(
          memberUpdateState: const FamilyActionState.success(),
        );
        load(silent: true);
        return true;
      },
      (error) {
        state = state.copyWith(
          memberUpdateState: FamilyActionState.error(error),
        );
        return false;
      },
    );
  }

  /// Uploads a circle-specific photo for the member.
  Future<bool> updateMyPhoto(final File photo) async {
    state = state.copyWith(
      memberUpdateState: const FamilyActionState.loading(),
    );

    final result = await _familyService.updateOwnFamilyMemberPhoto(
      photo: photo,
    );
    if (!mounted) return false;

    return result.when(
      (_) {
        state = state.copyWith(
          memberUpdateState: const FamilyActionState.success(),
        );
        load(silent: true);
        return true;
      },
      (error) {
        state = state.copyWith(
          memberUpdateState: FamilyActionState.error(error),
        );
        return false;
      },
    );
  }

  /// Sets the group picture for the whole circle. Owner-only server-side,
  /// and the settings screen only offers it to owners.
  Future<bool> updateGroupPhoto(final File photo) async {
    final result = await _familyService.updateFamilyCirclePhoto(photo: photo);
    if (!mounted) return false;

    return result.when(
      (_) {
        load(silent: true);
        return true;
      },
      (_) => false,
    );
  }

  /// Clears the group picture, dropping back to the initial + theme colour.
  Future<bool> removeGroupPhoto() async {
    final result = await _familyService.removeFamilyCirclePhoto();
    if (!mounted) return false;

    return result.when(
      (_) {
        load(silent: true);
        return true;
      },
      (_) => false,
    );
  }

  Future<void> updateNickname(final String nickname) async {
    state = state.copyWith(
      memberUpdateState: const FamilyActionState.loading(),
    );

    final result = await _familyService.updateOwnFamilyMember(
      nickname: nickname,
    );
    if (!mounted) return;

    result.when(
      (_) {
        state = state.copyWith(
          memberUpdateState: const FamilyActionState.success(),
        );
        load(silent: true);
      },
      (error) {
        state = state.copyWith(
          memberUpdateState: FamilyActionState.error(error),
        );
      },
    );
  }

  // ---------------------------- LOCATION SNAPSHOTS ----------------------------
  // ALRT never live-tracks: these are one-time, expiring, member-initiated.

  /// Asks [memberId] to share a one-time location snapshot.
  /// Returns true when the request was sent.
  Future<bool> requestMemberLocation({required final String memberId}) async {
    final result = await _familyService.createFamilyLocationRequest(
      memberId: memberId,
    );
    if (!mounted) return false;
    return result.when((_) => true, (_) => false);
  }

  /// Asks every one of [memberIds] to share a one-time snapshot in one go
  /// — "selected people" or "the whole group," depending on which ids are
  /// passed. Each person still gets their own request and their own
  /// consent prompt; this only saves asking one at a time. Returns the ids
  /// that failed their own check (e.g. sharing off) so the caller can tell
  /// the user, rather than pretending every ask went out.
  Future<List<String>> requestMembersLocation({
    required final List<String> memberIds,
  }) async {
    if (memberIds.isEmpty) return const [];
    final result = await _familyService.createFamilyLocationRequestsBulk(
      memberIds: memberIds,
    );
    if (!mounted) return const [];
    return result.when((failed) => failed, (_) => memberIds);
  }

  /// Cancels a pending location request the caller sent.
  Future<bool> cancelLocationRequest({required final String requestId}) async {
    final result = await _familyService.cancelFamilyLocationRequest(
      requestId: requestId,
    );
    if (!mounted) return false;
    return result.when((_) => true, (_) => false);
  }

  /// Answers a "where are you" request. When [share] is true the current
  /// position is attached; declining sends nothing.
  Future<bool> respondToLocationRequest({
    required final String requestId,
    required final bool share,
  }) async {
    double? latitude;
    double? longitude;
    if (share) {
      final position = await _familyLocationService
          .getLastKnownOrCurrentPosition();
      if (position == null) return false;
      latitude = position.latitude;
      longitude = position.longitude;
    }
    if (!mounted) return false;

    final result = await _familyService.respondToFamilyLocationRequest(
      requestId: requestId,
      share: share,
      latitude: latitude,
      longitude: longitude,
    );
    if (!mounted) return false;
    return result.when(
      (_) {
        if (share) AnalyticsService.familySnapshotShared(via: 'request');
        return true;
      },
      (_) => false,
    );
  }

  /// Explicitly shares a fresh snapshot (e.g. re-sharing during an SOS).
  Future<bool> shareSnapshotNow() async {
    final shared = await _familyLocationService.shareSnapshotNow();
    if (shared) {
      AnalyticsService.familySnapshotShared(via: 'manual');
    }
    if (shared && mounted) {
      await load(silent: true);
    }
    return shared;
  }

  // ---------------------------- CHECK-INS ----------------------------

  /// Sends a check-in, with a location snapshot only when [shareLocation].
  ///
  /// A check-in answering a specific request (`requestId` set, e.g. a
  /// scheduled prompt or someone's "ask everyone") stays scoped to that
  /// request's own circle — answering it must not silently mark the user
  /// safe in circles nobody asked in. A proactive "I'm Safe" tap (no
  /// pending request) is the app's one-tap-to-everyone action per the
  /// onboarding pitch and the Ask ALRT system prompt's own description of
  /// the feature, so it fans out to every circle the user belongs to.
  ///
  /// [shareLocation] gates whether this check-in attaches a location
  /// snapshot at all, and it has NO default on purpose: every caller must
  /// pass the person's own explicit choice (locked rule - location leaves
  /// a phone only by the owner's action). Interactive callers collect it
  /// with showCheckInConsentSheet; background callers with no UI to ask
  /// (notification quick actions) pass false. A check-in never requires
  /// or implies location, so nothing is fetched unless the person said
  /// yes in this very moment.
  Future<void> checkIn({
    final FamilyCheckInStatus status = FamilyCheckInStatus.safe,
    final String? message,
    required final bool shareLocation,
  }) async {
    state = state.copyWith(checkInState: const FamilyActionState.loading());

    final position = shareLocation
        ? await _familyLocationService.getLastKnownOrCurrentPosition()
        : null;
    if (!mounted) return;

    final requestId = state.circle?.latestCheckInRequest?.id;
    final targetCircleIds = requestId != null
        ? <String>[]
        : state.circles.map((c) => c.circleId).toSet().toList();

    if (targetCircleIds.length <= 1) {
      final result = await _familyService.sendFamilyCheckIn(
        status: status,
        message: message,
        latitude: position?.latitude,
        longitude: position?.longitude,
        requestId: requestId,
      );
      if (!mounted) return;

      result.when(
        (checkInResult) {
          AnalyticsService.familyCheckIn();
          _appendCheckIn(checkInResult);
          state = state.copyWith(
            checkInState: const FamilyActionState.success(),
          );
        },
        (error) {
          state = state.copyWith(checkInState: FamilyActionState.error(error));
        },
      );
      return;
    }

    // More than one circle and no specific request to answer: broadcast.
    final results = await Future.wait(
      targetCircleIds.map(
        (circleId) => _familyService.sendFamilyCheckIn(
          status: status,
          message: message,
          latitude: position?.latitude,
          longitude: position?.longitude,
          circleId: circleId,
        ),
      ),
    );
    if (!mounted) return;

    // The currently-selected circle's own result drives the visible check-in
    // feed and success/error state; the other circles' sends are best-effort
    // fan-out (each already reached its own circle regardless).
    final selectedId =
        _ref.read(providerOfSelectedCircleId) ?? state.circle?.id;
    final primaryIndex = selectedId == null
        ? 0
        : targetCircleIds.indexOf(selectedId).clamp(0, results.length - 1);

    results[primaryIndex].when(
      (checkInResult) {
        AnalyticsService.familyCheckIn();
        _appendCheckIn(checkInResult);
        state = state.copyWith(
          checkInState: const FamilyActionState.success(),
        );
      },
      (error) {
        state = state.copyWith(checkInState: FamilyActionState.error(error));
      },
    );
  }

  /// Asks for a check-in: everyone in the circle, or only [memberIds]
  /// ("Ask Amy"). Only the people asked are notified and see it as owed;
  /// the requester keeps it as their tracker. Returns true when sent.
  Future<bool> requestCheckIn({
    final String? message,
    final List<String>? memberIds,
  }) async {
    state = state.copyWith(
      requestCheckInState: const FamilyActionState.loading(),
    );

    final result = await _familyService.requestFamilyCheckIn(
      message: message,
      memberIds: memberIds,
    );
    if (!mounted) return false;

    return result.when(
      (request) {
        state = state.copyWith(
          circle: state.circle?.copyWith(latestCheckInRequest: request),
          requestCheckInState: const FamilyActionState.success(),
        );
        return true;
      },
      (error) {
        state = state.copyWith(
          requestCheckInState: FamilyActionState.error(error),
        );
        return false;
      },
    );
  }

  /// Cancels an outstanding "ask everyone to check in" request the caller
  /// (or the circle owner) sent. Only the requester/owner can call this
  /// server-side; the request simply stops being anyone's "latest" once
  /// gone, so the roll-call screen drops it on the next load.
  Future<void> cancelCheckInRequest(final String requestId) async {
    state = state.copyWith(
      requestCheckInState: const FamilyActionState.loading(),
    );

    final result = await _familyService.cancelFamilyCheckInRequest(
      requestId: requestId,
    );
    if (!mounted) return;

    result.when(
      (_) {
        final current = state.circle;
        final shouldClear = current?.latestCheckInRequest?.id == requestId;
        state = state.copyWith(
          circle: shouldClear
              ? current!.copyWith(latestCheckInRequest: null)
              : current,
          requestCheckInState: const FamilyActionState.success(),
        );
      },
      (error) {
        state = state.copyWith(
          requestCheckInState: FamilyActionState.error(error),
        );
      },
    );
  }

  /// Adds [checkIn] to the recent list and stamps the member's
  /// `lastCheckInAt` so "Safe" chips update immediately.
  void _appendCheckIn(final FamilyCheckIn checkIn) {
    final circle = state.circle;

    final members = circle?.members
        .map(
          (member) => member.id == checkIn.memberId
              ? member.copyWith(
                  lastCheckInAt: checkIn.createdAt ?? DateTime.now(),
                )
              : member,
        )
        .toList();

    state = state.copyWith(
      circle: members == null ? circle : circle?.copyWith(members: members),
      recentCheckIns: [
        checkIn,
        ...state.recentCheckIns.where((c) => c.id != checkIn.id),
      ].take(_recentCheckInsLimit).toList(),
    );
  }

  Future<void> _refreshRecentCheckIns() async {
    final result = await _familyService.getFamilyCheckIns(
      limit: _recentCheckInsLimit,
    );
    if (!mounted) return;

    result.whenSuccess((checkIns) {
      state = state.copyWith(recentCheckIns: checkIns);
      return null;
    });
  }

  // ------------------------ SCHEDULED CHECK-INS ------------------------

  Future<void> loadScheduledCheckIns() async {
    final result = await _familyService.getFamilyScheduledCheckIns();
    if (!mounted) return;

    result.whenSuccess((schedules) {
      state = state.copyWith(scheduledCheckIns: schedules);
      return null;
    });
  }

  /// Adds (or updates the mode of) a daily check-in at [timeOfDay] ("HH:mm").
  Future<bool> addScheduledCheckIn({
    required final String timeOfDay,
    final FamilyScheduledCheckInMode mode = FamilyScheduledCheckInMode.prompted,
  }) async {
    final result = await _familyService.createFamilyScheduledCheckIn(
      timeOfDay: timeOfDay,
      mode: mode,
    );
    if (!mounted) return false;

    return result.when(
      (schedule) {
        state = state.copyWith(
          scheduledCheckIns: [
            ...state.scheduledCheckIns.where((s) => s.id != schedule.id),
            schedule,
          ]..sort((a, b) => a.timeOfDay.compareTo(b.timeOfDay)),
        );
        return true;
      },
      (_) => false,
    );
  }

  Future<bool> removeScheduledCheckIn({
    required final String scheduledCheckInId,
  }) async {
    final result = await _familyService.deleteFamilyScheduledCheckIn(
      scheduledCheckInId: scheduledCheckInId,
    );
    if (!mounted) return false;

    return result.when(
      (_) {
        state = state.copyWith(
          scheduledCheckIns: state.scheduledCheckIns
              .where((s) => s.id != scheduledCheckInId)
              .toList(),
        );
        return true;
      },
      (_) => false,
    );
  }

  // ---------------------------- INVITES ----------------------------

  Future<void> loadInvites() async {
    state = state.copyWith(
      invitesLoadState: const FamilyActionState.loading(),
    );

    final result = await _familyService.getFamilyInvites();
    if (!mounted) return;

    result.when(
      (invites) {
        state = state.copyWith(
          invites: invites,
          invitesLoadState: const FamilyActionState.success(),
        );
      },
      (error) {
        state = state.copyWith(
          invitesLoadState: FamilyActionState.error(error),
        );
      },
    );
  }

  // ── Journeys ───────────────────────────────────────────────────────────

  /// Snap points: the locked default. Departure, a point about every ten
  /// minutes, then arrival. Nothing in between is recorded.
  static const _journeySnapInterval = Duration(minutes: 10);

  /// A live journey (per-journey opt-in, never an ALRT+ upsell) posts more
  /// often so the map moves, still ending with the journey.
  static const _journeyLiveInterval = Duration(seconds: 45);

  Timer? _journeyTimer;

  /// Loads the caller's running journey, if any.
  Future<void> loadMyJourney() async {
    final result = await _familyService.getMyFamilyJourney();
    if (!mounted) return;
    result.when(
      (journey) {
        state = state.copyWith(activeJourney: journey);
        // A journey that survived an app restart keeps sending points.
        journey != null && journey.isActive
            ? _startJourneyPoints(journey)
            : _stopJourneyPoints();
      },
      (error) => null,
    );
  }

  /// Starts the journey's point loop and posts the departure point now.
  void _startJourneyPoints(final FamilyJourney journey) {
    _journeyTimer?.cancel();
    unawaited(_postJourneyPoint());
    _journeyTimer = Timer.periodic(
      journey.isLive ? _journeyLiveInterval : _journeySnapInterval,
      (_) async {
        final current = state.activeJourney;
        // The journey's own stop time ends the loop: no journey outlives
        // the window the traveller chose.
        if (current == null || !current.isActive) {
          _stopJourneyPoints();
          return;
        }
        await _postJourneyPoint();
      },
    );
  }

  void _stopJourneyPoints() {
    _journeyTimer?.cancel();
    _journeyTimer = null;
  }

  /// Sends one point for the running journey. Failures are silent: a
  /// missed point is not worth a banner mid-trip, and the next one is due
  /// shortly.
  Future<void> _postJourneyPoint() async {
    final journey = state.activeJourney;
    if (journey == null || !journey.isActive) return;

    final position = await _familyLocationService
        .getLastKnownOrCurrentPosition();
    if (position == null || !mounted) return;

    final result = await _familyService.postFamilyJourneyPoint(
      journeyId: journey.id,
      latitude: position.latitude,
      longitude: position.longitude,
    );
    if (!mounted) return;
    result.whenSuccess((updated) {
      state = state.copyWith(activeJourney: updated);
      return null;
    });
  }

  /// Starts a journey shared with [recipientMemberIds] for [durationMinutes].
  Future<bool> startJourney({
    required final int durationMinutes,
    required final List<String> recipientMemberIds,
    final bool isLive = false,
  }) async {
    state = state.copyWith(
      journeyState: const FamilyActionState.loading(),
    );

    final result = await _familyService.startFamilyJourney(
      durationMinutes: durationMinutes,
      recipientMemberIds: recipientMemberIds,
      isLive: isLive,
    );
    if (!mounted) return false;

    return result.when(
      (journey) {
        state = state.copyWith(
          activeJourney: journey,
          journeyState: const FamilyActionState.success(),
        );
        // Departure point goes now; the rest follow on the journey's own
        // cadence. Starting a share used to send nothing at all.
        _startJourneyPoints(journey);
        return true;
      },
      (error) {
        state = state.copyWith(journeyState: FamilyActionState.error(error));
        return false;
      },
    );
  }

  /// Adds one more block to the running journey.
  Future<bool> extendJourney({final int? minutes}) async {
    final journey = state.activeJourney;
    if (journey == null) return false;

    state = state.copyWith(
      journeyState: const FamilyActionState.loading(),
    );

    final result = await _familyService.extendFamilyJourney(
      journeyId: journey.id,
      minutes: minutes,
    );
    if (!mounted) return false;

    return result.when(
      (updated) {
        state = state.copyWith(
          activeJourney: updated,
          journeyState: const FamilyActionState.success(),
        );
        return true;
      },
      (error) {
        state = state.copyWith(journeyState: FamilyActionState.error(error));
        return false;
      },
    );
  }

  /// Stops sharing now. Always one tap, never buried.
  Future<bool> stopJourney() async {
    final journey = state.activeJourney;
    if (journey == null) return false;

    state = state.copyWith(
      journeyState: const FamilyActionState.loading(),
    );

    // The arrival point, then the loop stops. Arrival is the last thing
    // the recipients see before the journey's location data is cleared.
    await _postJourneyPoint();
    _stopJourneyPoints();

    final result = await _familyService.stopFamilyJourney(
      journeyId: journey.id,
    );
    if (!mounted) return false;

    return result.when(
      (_) {
        state = state.copyWith(
          activeJourney: null,
          journeyState: const FamilyActionState.success(),
        );
        return true;
      },
      (error) {
        state = state.copyWith(journeyState: FamilyActionState.error(error));
        return false;
      },
    );
  }

  Future<FamilyInvite?> createInvite({
    final bool isGuestInvite = false,
  }) async {
    state = state.copyWith(
      createInviteState: const FamilyActionState.loading(),
    );

    final result = await _familyService.createFamilyInvite(
      isGuestInvite: isGuestInvite,
    );
    if (!mounted) return null;

    return result.when(
      (invite) {
        state = state.copyWith(
          invites: [invite, ...state.invites],
          createInviteState: const FamilyActionState.success(),
        );
        return invite;
      },
      (error) {
        state = state.copyWith(
          createInviteState: FamilyActionState.error(error),
        );
        return null;
      },
    );
  }

  Future<void> revokeInvite({required final String inviteId}) async {
    final previousInvites = state.invites;
    state = state.copyWith(
      invites: previousInvites.where((i) => i.id != inviteId).toList(),
    );

    final result = await _familyService.revokeFamilyInvite(inviteId: inviteId);
    if (!mounted) return;

    result.whenFailure((error) {
      state = state.copyWith(invites: previousInvites);
      _showToast(message: error.message, isWarning: true);
      return null;
    });
  }

  // ---------------------------- PLACES ----------------------------

  Future<bool> createPlace({
    required final String name,
    required final double latitude,
    required final double longitude,
    final FamilyPlaceIcon? icon,
    final int? radiusMeters,
    final String? address,
  }) async {
    state = state.copyWith(placeSaveState: const FamilyActionState.loading());

    final result = await _familyService.createFamilyPlace(
      name: name,
      icon: icon,
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
      address: address,
    );
    if (!mounted) return false;

    return result.when(
      (place) {
        final circle = state.circle;
        state = state.copyWith(
          circle: circle?.copyWith(places: [...circle.places, place]),
          placeSaveState: const FamilyActionState.success(),
        );
        return true;
      },
      (error) {
        state = state.copyWith(placeSaveState: FamilyActionState.error(error));
        return false;
      },
    );
  }

  Future<bool> updatePlace({
    required final String placeId,
    final String? name,
    final FamilyPlaceIcon? icon,
    final double? latitude,
    final double? longitude,
    final int? radiusMeters,
    final String? address,
  }) async {
    state = state.copyWith(placeSaveState: const FamilyActionState.loading());

    final result = await _familyService.updateFamilyPlace(
      placeId: placeId,
      name: name,
      icon: icon,
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
      address: address,
    );
    if (!mounted) return false;

    return result.when(
      (updated) {
        _replacePlace(updated);
        state = state.copyWith(
          placeSaveState: const FamilyActionState.success(),
        );
        return true;
      },
      (error) {
        state = state.copyWith(placeSaveState: FamilyActionState.error(error));
        return false;
      },
    );
  }

  Future<void> deletePlace({required final String placeId}) async {
    final result = await _familyService.deleteFamilyPlace(placeId: placeId);
    if (!mounted) return;

    result.when(
      (_) {
        final circle = state.circle;
        state = state.copyWith(
          circle: circle?.copyWith(
            places: circle.places.where((p) => p.id != placeId).toList(),
          ),
        );
      },
      (error) => _showToast(message: error.message, isWarning: true),
    );
  }

  /// Toggles a per-member arrive/leave notification preference, optimistically.
  Future<void> updatePlacePref({
    required final String placeId,
    required final String subjectMemberId,
    required final bool notifyArrivals,
    required final bool notifyDepartures,
  }) async {
    final circle = state.circle;
    final place = circle?.places.where((p) => p.id == placeId).firstOrNull;
    if (circle == null || place == null) return;

    final previousPlace = place;

    final newPref = FamilyPlaceNotificationPref(
      placeId: placeId,
      subjectMemberId: subjectMemberId,
      notifyArrivals: notifyArrivals,
      notifyDepartures: notifyDepartures,
    );
    _replacePlace(
      place.copyWith(
        notificationPrefs: [
          ...place.notificationPrefs.where(
            (pref) => pref.subjectMemberId != subjectMemberId,
          ),
          newPref,
        ],
      ),
    );

    final result = await _familyService.updateFamilyPlacePref(
      placeId: placeId,
      subjectMemberId: subjectMemberId,
      notifyArrivals: notifyArrivals,
      notifyDepartures: notifyDepartures,
    );
    if (!mounted) return;

    result.whenFailure((error) {
      _replacePlace(previousPlace);
      _showToast(message: error.message, isWarning: true);
      return null;
    });
  }

  Future<void> _refreshPlaces() async {
    final result = await _familyService.getFamilyPlaces();
    if (!mounted) return;

    result.whenSuccess((places) {
      state = state.copyWith(circle: state.circle?.copyWith(places: places));
      return null;
    });
  }

  void _replacePlace(final FamilySavedPlace place) {
    final circle = state.circle;
    if (circle == null) return;

    state = state.copyWith(
      circle: circle.copyWith(
        places: circle.places
            .map((p) => p.id == place.id ? place : p)
            .toList(),
      ),
    );
  }

  // ---------------------------- SOS ----------------------------

  /// Triggers an SOS with the user's current location attached.
  /// [isLive] is the sender's own choice, made before triggering — never
  /// assumed. Live tracking only starts when they chose it; SOS itself
  /// still reaches every recipient either way.
  Future<FamilySosEvent?> triggerSos({
    final String? sosListId,
    required final bool isLive,
  }) async {
    state = state.copyWith(sosTriggerState: const FamilyActionState.loading());

    final position = await _familyLocationService
        .getLastKnownOrCurrentPosition();
    if (!mounted) return null;

    final result = await _familyService.triggerFamilySos(
      latitude: position?.latitude,
      longitude: position?.longitude,
      sosListId: sosListId,
      isLive: isLive,
    );
    if (!mounted) return null;

    return result.when(
      (sosEvent) {
        AnalyticsService.familySosTriggered();
        _upsertSosEvent(sosEvent);
        // Only start the continuous stream when the sender chose it.
        if (isLive) _startSosLiveShare();
        state = state.copyWith(
          sosTriggerState: const FamilyActionState.success(),
        );
        return sosEvent;
      },
      (error) {
        state = state.copyWith(sosTriggerState: FamilyActionState.error(error));
        return null;
      },
    );
  }

  Future<void> respondToSos({
    required final String sosEventId,
    required final FamilySosResponseType type,
  }) async {
    state = state.copyWith(sosRespondState: const FamilyActionState.loading());

    final result = await _familyService.respondToFamilySos(
      sosEventId: sosEventId,
      type: type,
    );
    if (!mounted) return;

    result.when(
      (response) {
        _onSosResponseReceived(response);
        state = state.copyWith(
          sosRespondState: const FamilyActionState.success(),
        );
      },
      (error) {
        state = state.copyWith(sosRespondState: FamilyActionState.error(error));
      },
    );
  }

  Future<void> resolveSos({required final String sosEventId}) async {
    _stopSosLiveShare();
    final result = await _familyService.resolveFamilySos(
      sosEventId: sosEventId,
    );
    if (!mounted) return;

    result.when(
      (resolved) => _onSosResolved(resolved),
      (error) => _showToast(message: error.message, isWarning: true),
    );
  }

  /// Fetches the movement trail of an SOS for the receiver's live map.
  /// Returns null on failure so the map quietly keeps its last trail.
  Future<FamilySosTrail?> getSosTrail({
    required final String sosEventId,
  }) async {
    final result = await _familyService.getFamilySosTrail(
      sosEventId: sosEventId,
    );
    return result.when((trail) => trail, (_) => null);
  }

  Future<void> _refreshSosHistory() async {
    final result = await _familyService.getFamilySosHistory();
    if (!mounted) return;

    result.whenSuccess((events) {
      state = state.copyWith(sosHistory: events);
      return null;
    });
  }

  Future<void> _refreshActiveSosEvents() async {
    final result = await _familyService.getActiveFamilySosEvents();
    if (!mounted) return;

    result.whenSuccess((events) {
      state = state.copyWith(activeSosEvents: events);
      return null;
    });
  }

  void _upsertSosEvent(final FamilySosEvent sosEvent) {
    if (sosEvent.status != FamilySosStatus.active) {
      _onSosResolved(sosEvent);
      return;
    }

    state = state.copyWith(
      activeSosEvents: [
        sosEvent,
        ...state.activeSosEvents.where((event) => event.id != sosEvent.id),
      ],
    );
  }

  // ---------------------------- HELPERS ----------------------------

  /// Resets one-shot action states so screens don't react to stale results.
  void resetActionStates() {
    state = state.copyWith(
      checkInState: const FamilyActionState.initial(),
      requestCheckInState: const FamilyActionState.initial(),
      createCircleState: const FamilyActionState.initial(),
      joinCircleState: const FamilyActionState.initial(),
      leaveDeleteState: const FamilyActionState.initial(),
      memberUpdateState: const FamilyActionState.initial(),
      placeSaveState: const FamilyActionState.initial(),
      sosTriggerState: const FamilyActionState.initial(),
      sosRespondState: const FamilyActionState.initial(),
      createInviteState: const FamilyActionState.initial(),
    );
  }

  /// Shows a toast via the global navigator, when a context is available.
  /// The full-width in-app banner for an SOS or a check-in request.
  void _showBigAlert({
    required final String title,
    required final String body,
    required final bool isSos,
    final VoidCallback? onTap,
  }) {
    final context = _ref.read(providerOfGlobalNavigatorKey).currentContext;
    if (context == null || !context.mounted) return;
    IncomingFamilyAlert.show(
      context: context,
      title: title,
      body: body,
      isSos: isSos,
      onTap: onTap,
    );
  }

  void _showToast({
    required final String message,
    final bool isWarning = false,
  }) {
    final context = _ref
        .read(providerOfGlobalNavigatorKey)
        .currentContext;
    if (context == null || !context.mounted) return;

    isWarning
        ? context.showWarningToast(message: message)
        : context.showSuccessToast(message: message);
  }
}
