import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/screens/family_share_ending_screen.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_member_avatar.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

/// Share a journey: live location while you travel, on your terms.
///
/// The traveller picks how long and exactly who, and the journey always
/// stops itself at the time they chose. Nothing here is gated on ALRT+.
class FamilyJourneyScreen extends ConsumerStatefulWidget {
  const FamilyJourneyScreen({super.key});

  static const route = '/family-journey';

  @override
  ConsumerState<FamilyJourneyScreen> createState() =>
      _FamilyJourneyScreenState();
}

class _FamilyJourneyScreenState extends ConsumerState<FamilyJourneyScreen> {
  /// The offered blocks. Anything longer is reached by extending, so the
  /// traveller is asked again rather than committing up front.
  static const _durations = [15, 30, 60];

  int _durationMinutes = 60;
  final Set<String> _recipientIds = {};

  /// Snap points are the locked default; live is opted into per journey.
  bool _isLive = false;

  /// The prompt is raised once per journey, never on a loop.
  String? _endingPromptShownFor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(providerOfFamily.notifier).loadMyJourney(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final circle = ref.watch(providerOfFamily.select((s) => s.circle));
    final activeJourney = ref.watch(
      providerOfFamily.select((s) => s.activeJourney),
    );

    if (circle == null) return const SizedBox.shrink();

    final others = circle.members
        .where((m) => m.id != circle.myMemberId)
        .toList();

    return Scaffold(
      backgroundColor: FamilyColors.v31Page,
      body: Column(
        children: [
          _headerBuilder(circle.name),
          Expanded(
            child: activeJourney != null && activeJourney.isActive
                ? _runningBuilder(activeJourney)
                : _setupBuilder(
                    others,
                    snapPointsOnly: circle.journeysSnapPointsOnly,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _headerBuilder(final String circleName) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        // The shared family header blend (FamilyColors.headerGradient), so
        // this screen matches the hub, the invite screen and the rest of
        // the section instead of carrying its own copy of the stops.
        gradient: FamilyColors.headerGradient,
      ),
      child: Stack(
        children: [
          // The soft blob of light in the top-right corner.
          Positioned(
            top: -40.spMin,
            right: -30.spMin,
            child: Container(
              width: 180.spMin,
              height: 180.spMin,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    FamilyColors.v31HeaderGlow.withValues(alpha: 0.4),
                    FamilyColors.v31HeaderGlow.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.68],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16.spMin,
              8.spMin,
              16.spMin,
              22.spMin,
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 30.spMin,
                height: 30.spMin,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 15.spMin,
                  color: Colors.white,
                ),
              ),
            ),
            14.hSizedBox,
            Text(
              circleName.toUpperCase(),
              style: TextStyle(
                fontSize: 11.spMin,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            4.hSizedBox,
            Text(
              'Share my journey',
              style: TextStyle(
                fontSize: 22.spMin,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
                height: 1.15,
              ),
            ),
            5.hSizedBox,
                  Text(
                    'A few points along the way, on your terms',
                    style: TextStyle(
                      fontSize: 12.5.spMin,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Setup ────────────────────────────────────────────────────────────

  Widget _setupBuilder(final List<FamilyMember> others, {
    required final bool snapPointsOnly,
  }) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.spMin, 16.spMin, 16.spMin, 28.spMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _cardBuilder(
            label: 'How long',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    for (final minutes in _durations) ...[
                      Expanded(child: _durationChipBuilder(minutes)),
                      if (minutes != _durations.last)
                        SizedBox(width: 10.spMin),
                    ],
                  ],
                ),
                12.hSizedBox,
                Text(
                  'Sharing always stops on its own at the time you pick, '
                  '1 hour at most per extension. ALRT asks before it ends '
                  'and only you can extend.',
                  style: TextStyle(
                    fontSize: 11.spMin,
                    height: 1.6,
                    color: FamilyColors.v31Ink,
                  ),
                ),
              ],
            ),
          ),
          11.hSizedBox,
          _cardBuilder(
            label: 'Who sees it',
            padding: EdgeInsets.zero,
            child: others.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(16.spMin),
                    child: Text(
                      'Invite someone to your circle first.',
                      style: TextStyle(
                        fontSize: 13.spMin,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (final (index, member) in others.indexed) ...[
                        if (index > 0)
                          Divider(
                            height: 1,
                            indent: 68.spMin,
                            color: const Color(0xFFF0F0F2),
                          ),
                        _recipientRowBuilder(member),
                      ],
                    ],
                  ),
          ),
          11.hSizedBox,
          _cardBuilder(
            label: 'How much detail',
            child: _liveToggleBuilder(snapPointsOnly),
          ),
          14.hSizedBox,
          _noteBuilder(
            'A banner stays visible the whole time you are sharing, and '
            'Stop is one tap. Not an ALRT+ upsell.',
          ),
          18.hSizedBox,
          _startButtonBuilder(),
        ],
      ),
    );
  }

  /// Snap points or live, chosen per journey. The group's own rule can
  /// take live off the table, in which case the switch is stated as
  /// unavailable rather than silently ignored.
  Widget _liveToggleBuilder(final bool snapPointsOnly) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Send live updates',
                style: TextStyle(
                  fontSize: 14.spMin,
                  fontWeight: FontWeight.w700,
                  color: snapPointsOnly
                      ? FamilyColors.v31Ink
                      : AppColors.black,
                ),
              ),
            ),
            Switch(
              value: _isLive && !snapPointsOnly,
              activeTrackColor: FamilyColors.v31ToggleOn,
              inactiveTrackColor: FamilyColors.v31ToggleOff,
              inactiveThumbColor: Colors.white,
              onChanged: snapPointsOnly
                  ? null
                  : (value) => setState(() => _isLive = value),
            ),
          ],
        ),
        8.hSizedBox,
        Text(
          snapPointsOnly
              ? 'This circle is set to snap points only: your circle sees '
                    'your departure, a point about every 10 minutes, and '
                    'your arrival.'
              : _isLive
                  ? 'Your position updates as you move, until the journey '
                        'stops. It still ends at the time you picked.'
                  : 'Snap points: your departure, a point about every 10 '
                        'minutes, and your arrival. Nothing in between.',
          style: TextStyle(
            fontSize: 11.spMin,
            height: 1.6,
            color: FamilyColors.v31Ink,
          ),
        ),
      ],
    );
  }

  Widget _durationChipBuilder(final int minutes) {
    final isSelected = _durationMinutes == minutes;
    return GestureDetector(
      onTap: () => setState(() => _durationMinutes = minutes),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        height: 44.spMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? FamilyColors.v31Indigo : Colors.white,
          borderRadius: BorderRadius.circular(12.spMin),
          border: Border.all(
            color: isSelected
                ? FamilyColors.v31Indigo
                : FamilyColors.v31Border,
            width: 1.5,
          ),
        ),
        child: Text(
          minutes < 60 ? '$minutes min' : '${minutes ~/ 60} hour',
          style: TextStyle(
            fontSize: 14.spMin,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : FamilyColors.v31Indigo,
          ),
        ),
      ),
    );
  }

  Widget _recipientRowBuilder(final FamilyMember member) {
    final isOn = _recipientIds.contains(member.id);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 8.spMin),
      child: Row(
        children: [
          FamilyMemberAvatar(member: member, isNearAlert: false),
          SizedBox(width: 12.spMin),
          Expanded(
            child: Text(
              member.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.spMin,
                fontWeight: FontWeight.w700,
                color: isOn ? AppColors.black : FamilyColors.v31Ink,
              ),
            ),
          ),
          Switch(
            value: isOn,
            activeTrackColor: FamilyColors.v31ToggleOn,
            inactiveTrackColor: FamilyColors.v31ToggleOff,
            inactiveThumbColor: Colors.white,
            onChanged: (value) => setState(() {
              if (value) {
                _recipientIds.add(member.id);
              } else {
                _recipientIds.remove(member.id);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _startButtonBuilder() {
    final isBusy = ref.watch(
      providerOfFamily.select((s) => s.journeyState.isLoading),
    );
    final canStart = _recipientIds.isNotEmpty && !isBusy;
    final endsAt = TimeOfDay.fromDateTime(
      DateTime.now().add(Duration(minutes: _durationMinutes)),
    );

    return SizedBox(
      height: 50.spMin,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: FamilyColors.v31Indigo,
          disabledBackgroundColor:
              FamilyColors.v31Indigo.withValues(alpha: 0.4),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.spMin),
          ),
        ),
        onPressed: canStart ? _handleStart : null,
        child: Text(
          _recipientIds.isEmpty
              ? 'Pick who sees it'
              : 'Start sharing until ${endsAt.format(context)}',
          style: TextStyle(fontSize: 15.spMin, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  // ── Running ──────────────────────────────────────────────────────────

  Widget _runningBuilder(final FamilyJourney journey) {
    final endsAt = TimeOfDay.fromDateTime(journey.endsAt);
    final minutesLeft = journey.remaining.inMinutes;

    // ALRT asks before sharing ends rather than letting it lapse quietly.
    if (minutesLeft <= 10 && _endingPromptShownFor != journey.id) {
      _endingPromptShownFor = journey.id;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showEndingPrompt(journey),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.spMin, 16.spMin, 16.spMin, 28.spMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _cardBuilder(
            label: 'Sharing now',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  minutesLeft < 1
                      ? 'Stopping now'
                      : 'Stops in $minutesLeft min',
                  style: TextStyle(
                    fontSize: 22.spMin,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
                4.hSizedBox,
                Text(
                  'Ends at ${endsAt.format(context)} on its own. '
                  'Nothing renews unless you choose it.',
                  style: TextStyle(
                    fontSize: 12.5.spMin,
                    height: 1.45,
                    color: AppColors.mediumGrey,
                  ),
                ),
                8.hSizedBox,
                Text(
                  journey.isLive
                      ? 'Live updates as you move.'
                      : 'Snap points: departure, about every 10 minutes, '
                            'and arrival.',
                  style: TextStyle(
                    fontSize: 12.5.spMin,
                    fontWeight: FontWeight.w600,
                    color: FamilyColors.v31Indigo,
                  ),
                ),
                if (journey.recipients.isNotEmpty) ...[
                  12.hSizedBox,
                  Text(
                    'Seen by ${journey.recipients.map((r) => r.name).join(', ')}',
                    style: TextStyle(
                      fontSize: 12.5.spMin,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          14.hSizedBox,
          _noteBuilder(
            'When it stops, your last position is deleted. History keeps '
            'the time and how long, never where you were.',
          ),
          18.hSizedBox,
          if (journey.canExtend)
            SizedBox(
              height: 52.spMin,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: FamilyColors.indigo,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: FamilyColors.indigo),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.spMin),
                  ),
                ),
                onPressed: _handleExtend,
                child: Text(
                  'Keep sharing 1 more hour',
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          10.hSizedBox,
          SizedBox(
            height: 56.spMin,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: FamilyColors.sosRed,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.spMin),
                ),
              ),
              onPressed: _handleStop,
              child: Text(
                'Stop sharing now',
                style: TextStyle(
                  fontSize: 16.spMin,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared pieces ────────────────────────────────────────────────────

  Widget _cardBuilder({
    required final String label,
    required final Widget child,
    final EdgeInsetsGeometry? padding,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.spMin),
        boxShadow: const [
          BoxShadow(
            color: FamilyColors.v31CardShadow,
            blurRadius: 10.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: padding ?? EdgeInsets.fromLTRB(15.spMin, 14.spMin, 15.spMin, 14.spMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: padding == EdgeInsets.zero
                ? EdgeInsets.fromLTRB(16.spMin, 16.spMin, 16.spMin, 10.spMin)
                : EdgeInsets.only(bottom: 12.spMin),
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10.spMin,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: FamilyColors.v31Label,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _noteBuilder(final String text) {
    return Container(
      decoration: BoxDecoration(
        color: FamilyColors.v31NoteBackground,
        borderRadius: BorderRadius.circular(14.spMin),
        border: Border.all(color: FamilyColors.v31NoteBorder, width: 1.5),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 14.spMin,
        vertical: 11.spMin,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.spMin,
          height: 1.6,
          color: FamilyColors.v31NoteInk,
        ),
      ),
    );
  }

  /// The last-minutes warning: extend, stop now, or do nothing and let it
  /// end itself.
  void _showEndingPrompt(final FamilyJourney journey) {
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => FamilyShareEndingScreen(
          args: FamilyShareEndingScreenArgs(
            endsAt: journey.endsAt,
            minutesLeft: journey.remaining.inMinutes,
            isSos: false,
            onExtend: journey.canExtend
                ? () => ref.read(providerOfFamily.notifier).extendJourney()
                : null,
            onStopNow: () =>
                ref.read(providerOfFamily.notifier).stopJourney(),
          ),
        ),
      ),
    );
  }

  Future<void> _handleStart() async {
    final snapPointsOnly = ref.read(
      providerOfFamily.select((s) => s.circle?.journeysSnapPointsOnly ?? false),
    );
    final ok = await ref
        .read(providerOfFamily.notifier)
        .startJourney(
          durationMinutes: _durationMinutes,
          recipientMemberIds: _recipientIds.toList(),
          isLive: _isLive && !snapPointsOnly,
        );
    if (!mounted) return;
    if (ok) {
      context.showSuccessToast(message: 'Sharing your journey');
    } else {
      context.showErrorToast(message: 'Could not start sharing');
    }
  }

  Future<void> _handleExtend() async {
    final ok = await ref.read(providerOfFamily.notifier).extendJourney();
    if (!mounted) return;
    context.showSuccessToast(
      message: ok ? 'Sharing extended' : 'Could not extend',
    );
  }

  Future<void> _handleStop() async {
    final ok = await ref.read(providerOfFamily.notifier).stopJourney();
    if (!mounted) return;
    if (ok) {
      context.showSuccessToast(message: 'Sharing stopped');
      Navigator.of(context).maybePop();
    } else {
      context.showErrorToast(message: 'Could not stop sharing');
    }
  }
}
