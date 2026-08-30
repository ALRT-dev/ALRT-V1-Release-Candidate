import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_resolved_screen.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

class FamilySosReceiverScreenArgs {
  const FamilySosReceiverScreenArgs({required this.sosEvent});

  final FamilySosEvent sosEvent;
}

/// What the circle sees when someone triggers SOS: a live map of the
/// person's movements and an automatic "I've seen this" acknowledgment
/// the moment they open this screen. There is no in-app call action here
/// (product-owner instruction 2026-08-30) — anyone worried should call
/// their own local emergency number from their own phone.
///
/// SOS is the one place location updates automatically: triggering it starts
/// the live share (product owner 2026-08-06), so this screen follows the
/// person while the SOS runs. Stand-down wipes the trail server-side, so a
/// resolved SOS goes back to a static snapshot with nothing to replay.
class FamilySosReceiverScreen extends ConsumerStatefulWidget {
  const FamilySosReceiverScreen({super.key, required this.args});

  static const route = '/family-sos-receiver';

  final FamilySosReceiverScreenArgs args;

  @override
  ConsumerState<FamilySosReceiverScreen> createState() =>
      _FamilySosReceiverScreenState();
}

class _FamilySosReceiverScreenState
    extends ConsumerState<FamilySosReceiverScreen> {
  /// A shade slower than the sender's 20 s share loop, so most polls find
  /// at most one new point and none are wasted.
  static const _trailRefreshInterval = Duration(seconds: 25);

  Timer? _trailTimer;
  List<FamilySosTrailPoint> _trail = const [];
  GoogleMapController? _mapController;
  LatLng? _followedTarget;

  @override
  void initState() {
    super.initState();
    if (widget.args.sosEvent.status == FamilySosStatus.active) {
      _markSeen();
      _refreshTrail();
      _trailTimer = Timer.periodic(
        _trailRefreshInterval,
        (_) => _refreshTrail(),
      );
    }
  }

  bool _seenPosted = false;
  ProviderSubscription<String?>? _seenRetry;

  /// "I've seen this" is automatic (locked rule): opening the SOS is what
  /// seeing it means, so the person in trouble learns someone is looking
  /// without anyone having to press anything. There is no deliberate
  /// response left in this flow (product-owner instruction 2026-08-30
  /// removed "On my way").
  ///
  /// A push can open this screen before the circle has loaded, so when
  /// myMemberId is not known yet the post waits for it instead of being
  /// dropped: losing the signal because the app was cold is exactly the
  /// silent failure the automatic rule exists to prevent.
  void _markSeen() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final myMemberId = ref.read(providerOfFamily).circle?.myMemberId;
      if (myMemberId != null) {
        _postSeenIfNotMine(myMemberId);
        return;
      }
      _seenRetry = ref.listenManual<String?>(
        providerOfFamily.select((s) => s.circle?.myMemberId),
        (_, memberId) {
          if (memberId == null) return;
          _seenRetry?.close();
          _seenRetry = null;
          _postSeenIfNotMine(memberId);
        },
      );
    });
  }

  void _postSeenIfNotMine(final String myMemberId) {
    // Never against your own SOS, and never twice. "Own" is checked by
    // USER as well as member id: member ids differ per circle, so on a
    // cross-group SOS the member-id check alone let the sender's phone
    // post "Seen" on their own SOS.
    final sosEvent = widget.args.sosEvent;
    final myUserId = ref.read(providerOfLoggedInUser)?.id;
    final senderUserId = sosEvent.member?.user?.id;
    final isMine = sosEvent.memberId == myMemberId ||
        (senderUserId != null && senderUserId == myUserId);
    if (_seenPosted || isMine) return;
    _seenPosted = true;
    unawaited(
      ref.read(providerOfFamily.notifier).respondToSos(
            sosEventId: widget.args.sosEvent.id,
            type: FamilySosResponseType.seen,
          ),
    );
  }

  @override
  void dispose() {
    _trailTimer?.cancel();
    _seenRetry?.close();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _refreshTrail() async {
    final live = ref
        .read(providerOfFamily)
        .activeSosEvents
        .any(
          (e) =>
              e.id == widget.args.sosEvent.id &&
              e.status == FamilySosStatus.active,
        );
    if (!live) {
      _trailTimer?.cancel();
      return;
    }

    final trail = await ref
        .read(providerOfFamily.notifier)
        .getSosTrail(sosEventId: widget.args.sosEvent.id);
    if (!mounted || trail == null) return;
    setState(() => _trail = trail.points);
  }

  /// Keeps the camera on the person as new points arrive, without fighting
  /// the map on rebuilds that changed nothing.
  void _followPosition(final LatLng target) {
    if (_followedTarget == target) return;
    _followedTarget = target;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController?.animateCamera(CameraUpdate.newLatLng(target));
    });
  }

  @override
  Widget build(BuildContext context) {
    // Prefer the live copy from state (updated by socket events).
    final sos = ref.watch(
          providerOfFamily.select(
            (s) => s.activeSosEvents
                .where((e) => e.id == widget.args.sosEvent.id)
                .firstOrNull,
          ),
        ) ??
        widget.args.sosEvent;

    final name = sos.member?.displayName ?? 'A family member';
    final myMemberId = ref.watch(
      providerOfFamily.select((s) => s.circle?.myMemberId),
    );
    final myUserId = ref.watch(
      providerOfLoggedInUser.select((user) => user?.id),
    );
    // By user as well as member id: cross-group, the sender's member id
    // in the SOS's circle never equals their id in the selected circle.
    final isMine = sos.memberId == myMemberId ||
        (sos.member?.user?.id != null && sos.member?.user?.id == myUserId);
    final isResolved = sos.status != FamilySosStatus.active;

    // Where the person is right now: the socket-patched member location is
    // the freshest, then the newest trail point, then the trigger snapshot.
    final liveMember = ref.watch(
      providerOfFamily.select(
        (s) => s.circle?.members
            .where((m) => m.id == sos.memberId)
            .firstOrNull,
      ),
    );
    final position = !isResolved && (liveMember?.hasLiveLocation ?? false)
        ? LatLng(liveMember!.latitude!, liveMember.longitude!)
        : !isResolved && _trail.isNotEmpty
            ? LatLng(_trail.last.latitude, _trail.last.longitude)
            : sos.latitude != null && sos.longitude != null
                ? LatLng(sos.latitude!, sos.longitude!)
                : null;
    if (!isResolved && position != null) _followPosition(position);

    return Scaffold(
      backgroundColor: FamilyColors.v31Page,
      body: Column(
        children: [
          _headerBuilder(context, sos, name, isResolved),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20.spMin),
              children: [
                if (position != null)
                  _mapBuilder(position, isLive: !isResolved && sos.isLive),
                SizedBox(height: 14.spMin),
                _locationCardBuilder(sos, isResolved),
                SizedBox(height: 16.spMin),
                if (!isResolved && isMine) ...[
                  _resolveButtonBuilder(context, ref, sos),
                  SizedBox(height: 10.spMin),
                  _shareUpdatedLocationButtonBuilder(context, ref),
                ],
                SizedBox(height: 20.spMin),
                _responsesBuilder(sos),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerBuilder(
    final BuildContext context,
    final FamilySosEvent sos,
    final String name,
    final bool isResolved,
  ) {
    return Container(
      color: isResolved ? FamilyColors.safeGreen : FamilyColors.sosRed,
      padding: EdgeInsets.fromLTRB(20.spMin, 0, 20.spMin, 18.spMin),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isResolved ? '$name is marked safe' : '$name triggered SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.spMin,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (sos.createdAt != null)
                    Text(
                      isResolved
                          ? 'SOS ended'
                          : sos.isLive
                              ? 'Live location on · started ${timeago.format(sos.createdAt!)}'
                              : 'Started ${timeago.format(sos.createdAt!)} · live location off',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12.spMin,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The live map: the person's current position plus the trail of points
  /// shared since the SOS started, so movement reads at a glance. Once the
  /// SOS is resolved the trail is gone (deleted server-side) and the map
  /// drops back to a static snapshot.
  Widget _mapBuilder(final LatLng position, {required final bool isLive}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.spMin),
      child: SizedBox(
        height: 240.spMin,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: position, zoom: 15.5),
          onMapCreated: (controller) => _mapController = controller,
          markers: {
            Marker(markerId: const MarkerId('sos'), position: position),
          },
          polylines: {
            if (isLive && _trail.length >= 2)
              Polyline(
                polylineId: const PolylineId('sosTrail'),
                points: [
                  for (final point in _trail)
                    LatLng(point.latitude, point.longitude),
                  position,
                ],
                color: FamilyColors.sosRed,
                width: 4,
              ),
          },
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          // Lite mode renders a static image: fine for a resolved SOS,
          // useless for following someone, so live maps use the real thing.
          liteModeEnabled: !isLive,
        ),
      ),
    );
  }

  Widget _locationCardBuilder(final FamilySosEvent sos, final bool isResolved) {
    return Container(
      padding: EdgeInsets.all(14.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.spMin),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.mapPin, size: 18.spMin, color: FamilyColors.sosRed),
          SizedBox(width: 8.spMin),
          Expanded(
            child: Text(
              sos.locationLabel != null
                  ? 'Near ${sos.locationLabel}'
                  : isResolved
                      ? 'Location was shared with the circle'
                      : 'Live location shared with the circle',
              style: TextStyle(
                fontSize: 14.spMin,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resolveButtonBuilder(
    final BuildContext context,
    final WidgetRef ref,
    final FamilySosEvent sos,
  ) {
    return SizedBox(
      height: 50.spMin,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: FamilyColors.safeGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.spMin),
          ),
        ),
        onPressed: () => _confirmAndResolve(context, ref, sos),
        child: Text(
          "I'm safe",
          style: TextStyle(fontSize: 15.spMin, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  /// Two-tier confirmation before an SOS actually stops, so the sender
  /// understands what is about to happen before it happens — not just
  /// after. When live location sharing is active, a second, live-specific
  /// confirmation follows the first: stopping SOS and stopping live
  /// sharing are two things happening at once, and both need to be said,
  /// not just one generic "are you sure".
  Future<void> _confirmAndResolve(
    final BuildContext context,
    final WidgetRef ref,
    final FamilySosEvent sos,
  ) async {
    var confirmedStop = false;
    await showConfirmationSheet(
      context: context,
      title: 'Stop your SOS?',
      description: 'Your family stops seeing this alert and it moves to '
          'your history.',
      confirmButtonText: 'Stop SOS',
      onPressedConfirm: (_, __) => confirmedStop = true,
    );
    if (!confirmedStop || !context.mounted) return;

    if (sos.isLive) {
      var confirmedStopLive = false;
      await showConfirmationSheet(
        context: context,
        title: 'Also stop sharing your live location?',
        description: 'Live location sharing ends immediately and the '
            'trail is deleted. This cannot be undone.',
        confirmButtonText: 'Stop live sharing',
        onPressedConfirm: (_, __) => confirmedStopLive = true,
      );
      if (!confirmedStopLive || !context.mounted) return;
    }

    await _resolveAndShowSummary(context, ref, sos);
  }

  /// Stands the SOS down and then shows the after-event record, so the
  /// promise that the location data is gone is stated, not assumed.
  Future<void> _resolveAndShowSummary(
    final BuildContext context,
    final WidgetRef ref,
    final FamilySosEvent sos,
  ) async {
    final circleName = ref.read(providerOfFamily).circle?.name;
    final memberCount = ref.read(providerOfFamily).circle?.members.length;

    await ref.read(providerOfFamily.notifier).resolveSos(sosEventId: sos.id);
    if (!context.mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => FamilySosResolvedScreen(
          args: FamilySosResolvedScreenArgs(
            event: sos.copyWith(
              status: FamilySosStatus.resolved,
              resolvedAt: DateTime.now(),
            ),
            circleName: circleName,
            // Everyone but the person in SOS could see it.
            recipientCount: memberCount == null ? null : memberCount - 1,
          ),
        ),
      ),
    );
  }

  /// Lets the person in SOS push a fresh point right now, without waiting
  /// for the automatic live share's next tick.
  Widget _shareUpdatedLocationButtonBuilder(
    final BuildContext context,
    final WidgetRef ref,
  ) {
    return SizedBox(
      height: 50.spMin,
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: FamilyColors.indigo,
          backgroundColor: Colors.white,
          side: BorderSide(color: FamilyColors.indigo.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.spMin),
          ),
        ),
        onPressed: () async {
          final shared =
              await ref.read(providerOfFamily.notifier).shareSnapshotNow();
          if (!context.mounted) return;
          shared
              ? context.showSuccessToast(
                  message: 'Updated snapshot shared with your circle.',
                )
              : context.showErrorToast(
                  message:
                      'Could not get your location. Check location '
                      'permissions and try again.',
                );
        },
        icon: Icon(LucideIcons.mapPin, size: 18.spMin),
        label: Text(
          'Share updated location',
          style: TextStyle(fontSize: 15.spMin, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _responsesBuilder(final FamilySosEvent sos) {
    // "On my way" is removed from the flow entirely, so past responses of
    // that type are hidden here too, not just relabeled. The switch
    // expressions below still cover it - required for exhaustiveness over
    // FamilySosResponseType - but that branch is unreachable.
    final visibleResponses = sos.responses
        .where((response) => response.type != FamilySosResponseType.onMyWay)
        .toList();
    if (visibleResponses.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CIRCLE RESPONSES',
          style: TextStyle(
            fontSize: 13.spMin,
            fontWeight: FontWeight.w700,
            color: FamilyColors.sosRed,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 10.spMin),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.spMin),
          ),
          child: Column(
            children: [
              for (final response in visibleResponses)
                ListTile(
                  dense: true,
                  leading: Icon(
                    switch (response.type) {
                      FamilySosResponseType.onMyWay => LucideIcons.navigation,
                      FamilySosResponseType.called => Icons.phone,
                      FamilySosResponseType.seen => LucideIcons.eye,
                    },
                    size: 18.spMin,
                    color: FamilyColors.indigo,
                  ),
                  title: Text(
                    response.member?.displayName ?? 'Family member',
                    style: TextStyle(
                      fontSize: 14.spMin,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Text(
                    switch (response.type) {
                      FamilySosResponseType.onMyWay =>
                        'On my way${response.createdAt != null ? ' · ${timeago.format(response.createdAt!)}' : ''}',
                      FamilySosResponseType.called => 'Called for help',
                      FamilySosResponseType.seen =>
                        "I've seen this${response.createdAt != null ? ' · ${timeago.format(response.createdAt!)}' : ''}",
                    },
                    style: TextStyle(
                      fontSize: 12.spMin,
                      color: AppColors.grey,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
