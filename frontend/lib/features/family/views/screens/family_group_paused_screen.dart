import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';

/// The paused group: the host's ALRT+ lapsed and safety features stopped.
///
/// Unreachable until billing ships — isPaused can only be true once
/// BILLING_ENABLED is on — but built now so flipping that switch needs no
/// app release. The tone is deliberate: nothing is deleted, nobody is
/// blamed, and the two ways forward are stated as facts. Taking over is
/// offered to members; the backend is the judge of eligibility, so the
/// button always tries and the refusal reason comes back in plain words.
class FamilyGroupPausedScreen extends ConsumerStatefulWidget {
  const FamilyGroupPausedScreen({super.key});

  static const route = '/family-group-paused';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FamilyGroupPausedScreenState();
}

class _FamilyGroupPausedScreenState
    extends ConsumerState<FamilyGroupPausedScreen> {
  static const _page = Color(0xFFF5F2F7);
  static const _amberTop = Color(0xFFF0A030);
  static const _amberBottom = Color(0xFFE08812);
  static const _purpleBorder = Color(0xFFC77DDB);
  static const _purpleInk = Color(0xFF8E24AA);

  bool _takingOver = false;

  @override
  Widget build(BuildContext context) {
    final circle = ref.watch(providerOfFamily.select((s) => s.circle));
    if (circle == null) return const SizedBox.shrink();

    final isOwner = circle.me?.role == FamilyRole.owner;
    final isGuest = circle.me?.role == FamilyRole.guest;

    return Scaffold(
      backgroundColor: _page,
      body: ListView(
        padding: EdgeInsets.only(bottom: 40.spMin),
        children: [
          _headerBuilder(circle),
          _whatsHappeningCardBuilder(),
          if (!isOwner && !isGuest) _takeOverCardBuilder(circle),
          if (isOwner) ..._hostOptionsBuilder(circle),
        ],
      ),
    );
  }

  Widget _headerBuilder(final FamilyCircle circle) {
    final host = circle.pausedHostName ?? 'The host';
    final days = circle.graceDaysLeft;

    return Container(
      padding: EdgeInsets.fromLTRB(16.spMin, 52.spMin, 16.spMin, 18.spMin),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.6, -1),
          end: Alignment(0.6, 1),
          colors: [_amberTop, _amberBottom],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 30.spMin,
              height: 30.spMin,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 14.spMin,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 10.spMin),
          Text(
            '${circle.name} is paused',
            style: TextStyle(
              fontSize: 20.spMin,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 3.spMin),
          Text(
            days == null
                ? "$host's ALRT+ ended"
                : "$host's ALRT+ ended · $days "
                      '${days == 1 ? 'day' : 'days'} before anything '
                      'is removed',
            style: TextStyle(
              fontSize: 12.spMin,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _whatsHappeningCardBuilder() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.spMin, 13.spMin, 16.spMin, 0),
      padding: EdgeInsets.symmetric(horizontal: 15.spMin, vertical: 13.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.spMin),
        boxShadow: [
          BoxShadow(
            color: FamilyColors.v31CardShadow,
            blurRadius: 10.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's happening",
            style: TextStyle(fontSize: 13.spMin, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 4.spMin),
          Text(
            'Check-ins, snapshots and SOS are paused for this group. '
            'Everyone still gets their own alerts and map as normal. '
            'Nothing has been deleted.',
            style: TextStyle(
              fontSize: 12.spMin,
              height: 1.7,
              color: FamilyColors.v31Ink,
            ),
          ),
        ],
      ),
    );
  }

  /// Offered to every ordinary member; the backend decides eligibility and
  /// its refusal reason is shown verbatim rather than pre-judged here.
  Widget _takeOverCardBuilder(final FamilyCircle circle) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.spMin, 10.spMin, 16.spMin, 0),
      padding: EdgeInsets.all(15.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.spMin),
        border: Border.all(color: _purpleBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You could take it over',
            style: TextStyle(
              fontSize: 13.spMin,
              fontWeight: FontWeight.w800,
              color: _purpleInk,
            ),
          ),
          SizedBox(height: 4.spMin),
          Text(
            'Taking over makes you the host, moves this group onto your '
            'ALRT+ seats, and everything switches back on for everyone. '
            "You'll need an active subscription and enough free seats "
            'for all ${circle.members.length} members.',
            style: TextStyle(
              fontSize: 12.spMin,
              height: 1.7,
              color: FamilyColors.v31Ink,
            ),
          ),
          SizedBox(height: 11.spMin),
          SizedBox(
            height: 44.spMin,
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFC939DD),
                    Color(0xFFA22CC6),
                    Color(0xFF7E1FA8),
                    Color(0xFF5C1585),
                  ],
                  stops: [0.0, 0.4, 0.74, 1.0],
                ),
                borderRadius: BorderRadius.circular(14.spMin),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9C27B0).withValues(alpha: 0.3),
                    blurRadius: 18.0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.spMin),
                  ),
                ),
                onPressed: _takingOver ? null : _takeOver,
                child: Text(
                  _takingOver ? 'Taking over…' : 'Take over as host',
                  style: TextStyle(
                    fontSize: 12.5.spMin,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 7.spMin),
          Center(
            child: Text(
              '${circle.pausedHostName ?? 'The current host'} stays in the '
              'group as a member.',
              style: TextStyle(
                fontSize: 10.spMin,
                color: FamilyColors.v31Ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The lapsed host's own ways forward: resubscribe is handled by the
  /// billing banner; here are the other two, stated without pressure.
  List<Widget> _hostOptionsBuilder(final FamilyCircle circle) {
    return [
      Padding(
        padding: EdgeInsets.fromLTRB(16.spMin, 15.spMin, 16.spMin, 7.spMin),
        child: Text(
          'IF YOU WANT TO STEP BACK INSTEAD',
          style: TextStyle(
            fontSize: 10.spMin,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.7,
            color: const Color(0xFFB06FC9),
          ),
        ),
      ),
      Container(
        margin: EdgeInsets.symmetric(horizontal: 16.spMin),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.spMin),
          boxShadow: [
            BoxShadow(
              color: FamilyColors.v31CardShadow,
              blurRadius: 10.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ListTile(
              title: Text(
                'Hand the group to someone',
                style: TextStyle(
                  fontSize: 13.spMin,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                'An eligible member takes over hosting and their '
                'subscription carries the group',
                style: TextStyle(
                  fontSize: 10.5.spMin,
                  color: FamilyColors.v31Ink,
                ),
              ),
              trailing: Icon(Icons.chevron_right_rounded, size: 18.spMin),
              onTap: () => Navigator.of(context).maybePop('transfer'),
            ),
            const Divider(height: 1, color: FamilyColors.v31Divider),
            ListTile(
              title: Text(
                'Close the group',
                style: TextStyle(
                  fontSize: 13.spMin,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFC0271B),
                ),
              ),
              subtitle: Text(
                'Everyone removed and told. All snapshots deleted. '
                'Seats return',
                style: TextStyle(
                  fontSize: 10.5.spMin,
                  color: FamilyColors.v31Ink,
                ),
              ),
              onTap: () => Navigator.of(context).maybePop('close'),
            ),
          ],
        ),
      ),
    ];
  }

  void _takeOver() async {
    setState(() => _takingOver = true);
    final refusal = await ref.read(providerOfFamily.notifier).takeOverCircle();
    if (!mounted) return;
    setState(() => _takingOver = false);
    if (refusal == null) {
      context.showSuccessToast(
        message: "You're hosting now — everything is back on",
      );
      Navigator.of(context).maybePop();
    } else {
      context.showErrorToast(message: refusal);
    }
  }
}
