import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_receiver_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_screen.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

/// The red strip pinned to the top of EVERY home tab while any SOS in any
/// of your groups is running: who, which group, how long, and who has seen
/// it. It is impossible to be on the map or in Alerts and not know an SOS
/// is live (product owner 2026-09-04).
///
/// Names, never a bare count: the sender reads who has seen it (locked
/// rule), the receiver reads whether they have responded yet. Tapping
/// opens the SOS: the sender's own screen for their SOS, the receiver
/// screen for anyone else's. Location is never shown here.
///
/// Absent when nothing is running, so the tabs lay out exactly as before.
class FamilySosStrip extends ConsumerStatefulWidget {
  const FamilySosStrip({super.key});

  @override
  ConsumerState<FamilySosStrip> createState() => _FamilySosStripState();
}

class _FamilySosStripState extends ConsumerState<FamilySosStrip> {
  /// "Started 4 min ago" has to keep moving on its own.
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(
      providerOfFamily.select((s) => s.activeSosEvents),
    );
    if (events.isEmpty) return const SizedBox.shrink();

    final myUserId = ref.watch(providerOfLoggedInUser.select((u) => u?.id));
    final myMemberId = ref.watch(
      providerOfFamily.select((s) => s.circle?.myMemberId),
    );
    // Someone ELSE's SOS is the one to surface first: it needs a response.
    // My own is still shown when it is the only one.
    final sos = events.firstWhere(
      (e) => !_isMine(e, myUserId, myMemberId),
      orElse: () => events.first,
    );
    final isMine = _isMine(sos, myUserId, myMemberId);
    final groupName = _groupName(sos.circleId);
    final name = sos.member?.displayName ?? 'A family member';

    final title = isMine
        ? 'Your SOS is live${groupName == null ? '' : ' · $groupName'}'
        : "$name's SOS is live${groupName == null ? '' : ' · $groupName'}";
    final subtitle = _subtitle(sos, isMine: isMine, myMemberId: myMemberId);
    final others = events.length - 1;

    return Semantics(
      button: true,
      label: '$title. $subtitle. Open SOS',
      child: GestureDetector(
        onTap: () => _open(sos, isMine: isMine),
        child: Container(
          color: FamilyColors.sosRed,
          padding: EdgeInsets.fromLTRB(16.spMin, 10.spMin, 12.spMin, 10.spMin),
          child: Row(
            children: [
              const _PulsingDot(),
              SizedBox(width: 10.spMin),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.spMin,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2.spMin),
                    Text(
                      others > 0 ? '$subtitle · +$others more SOS' : subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 12.spMin,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.spMin),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.spMin,
                  vertical: 8.spMin,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.spMin),
                ),
                child: Text(
                  'Open',
                  style: TextStyle(
                    color: FamilyColors.sosRed,
                    fontSize: 13.spMin,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isMine(
    final FamilySosEvent sos,
    final String? myUserId,
    final String? myMemberId,
  ) {
    final senderUserId = sos.member?.user?.id;
    return (myMemberId != null && sos.memberId == myMemberId) ||
        (senderUserId != null && senderUserId == myUserId);
  }

  /// The group the SOS belongs to, by name: the open circle, or any other
  /// group you are in (the switcher list), or nothing if unknown.
  String? _groupName(final String circleId) {
    final state = ref.read(providerOfFamily);
    if (state.circle?.id == circleId) return state.circle?.name;
    for (final summary in state.circles) {
      if (summary.circleId == circleId) return summary.name;
    }
    return null;
  }

  String _subtitle(
    final FamilySosEvent sos, {
    required final bool isMine,
    required final String? myMemberId,
  }) {
    final started = sos.createdAt == null
        ? null
        : 'Started ${timeago.format(sos.createdAt!)}';
    final seen = sos.responses
        .where((r) => r.type == FamilySosResponseType.seen)
        .toList();
    final String tail;
    if (isMine) {
      // The sender's reassurance is WHO has seen it, by name.
      tail = seen.isEmpty
          ? 'nobody has seen it yet'
          : 'seen by ${seen.map((r) => r.member?.displayName ?? 'a member').join(', ')}';
    } else {
      final iHaveSeen =
          myMemberId != null && seen.any((r) => r.memberId == myMemberId);
      tail = iHaveSeen ? "you've seen this" : 'tap to see and respond';
    }
    return [if (started != null) started, tail].join(' · ');
  }

  void _open(final FamilySosEvent sos, {required final bool isMine}) {
    if (isMine) {
      context.push(FamilySosScreen.route);
      return;
    }
    context.push(
      FamilySosReceiverScreen.route,
      extra: FamilySosReceiverScreenArgs(sosEvent: sos),
    );
  }
}

/// A white dot that breathes, so the strip reads as LIVE, not a static
/// banner that was left behind.
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Container(
        width: 10.spMin,
        height: 10.spMin,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(
                alpha: 0.15 + 0.35 * _controller.value,
              ),
              spreadRadius: 3 + 3 * _controller.value,
            ),
          ],
        ),
      ),
    );
  }
}
