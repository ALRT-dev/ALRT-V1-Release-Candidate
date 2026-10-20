import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/screens/family_share_ending_screen.dart';
import 'package:hazard_app/features/family/views/widgets/family_app_bar.dart';
import 'package:hazard_app/features/family/views/widgets/family_board_widgets.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/subscription/views/widgets/access_refusal_sheet.dart';
import 'package:hazard_app/others/app_colors.dart';

/// Share a journey (12 Oct 2026 mockup): who sees it, how long, periodic
/// or live, on one card. The traveller picks exactly who, and the journey
/// always stops itself at the time they chose. Nothing here is gated on
/// ALRT+.
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

  /// Periodic updates are the locked default; live is opted into per
  /// journey.
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
      backgroundColor: kFamilyBoardPage,
      appBar: const FamilyWhiteAppBar(title: 'Share my journey'),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16.spMin,
          14.spMin,
          16.spMin,
          120.spMin + MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: activeJourney != null && activeJourney.isActive
            ? _runningBuilder(activeJourney)
            : _setupBuilder(
                others,
                snapPointsOnly: circle.journeysSnapPointsOnly,
              ),
      ),
    );
  }

  // ── Setup ────────────────────────────────────────────────────────────

  Widget _setupBuilder(
    final List<FamilyMember> others, {
    required final bool snapPointsOnly,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _cardBuilder(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _labelBuilder('WHO SEES IT'),
              SizedBox(height: 10.spMin),
              if (others.isEmpty)
                Text(
                  'Invite someone to your group first.',
                  style: TextStyle(
                    fontSize: 13.spMin,
                    color: AppColors.mediumGrey,
                  ),
                )
              else
                Wrap(
                  spacing: 8.spMin,
                  runSpacing: 8.spMin,
                  children: [
                    for (final member in others) _recipientChipBuilder(member),
                  ],
                ),
              SizedBox(height: 18.spMin),
              _labelBuilder('HOW LONG WILL YOU BE?'),
              SizedBox(height: 10.spMin),
              Wrap(
                spacing: 8.spMin,
                runSpacing: 8.spMin,
                children: [
                  for (final minutes in _durations)
                    _durationPillBuilder(minutes),
                ],
              ),
              SizedBox(height: 14.spMin),
              _liveToggleBuilder(snapPointsOnly),
              SizedBox(height: 10.spMin),
              const FamilyBoardMuted(
                'Periodic updates: your departure, an update about every 10 '
                'minutes, and your arrival. Up to 4 hours in total.',
                size: 12,
              ),
              SizedBox(height: 14.spMin),
              _startButtonBuilder(),
            ],
          ),
        ),
        SizedBox(height: 14.spMin),
        const FamilyBoardNote(
          'A journey is seen only by the people you pick. It ends on time '
          'or when you stop it, whichever comes first.',
        ),
      ],
    );
  }

  /// One chip per other member: the recipient picker. Selected chips take
  /// the family indigo outline and tint (the boards' chip).
  Widget _recipientChipBuilder(final FamilyMember member) {
    final isOn = _recipientIds.contains(member.id);
    return FamilyBoardChip(
      key: Key('journey-recipient-${member.id}'),
      label: member.name,
      selected: isOn,
      onTap: () => setState(() {
        if (isOn) {
          _recipientIds.remove(member.id);
        } else {
          _recipientIds.add(member.id);
        }
      }),
    );
  }

  /// 15 / 30 / 60 min chips. The selected chip takes a 2 px ink border.
  Widget _durationPillBuilder(final int minutes) {
    return FamilyBoardChip(
      key: Key('journey-duration-$minutes'),
      label: '$minutes min',
      selected: _durationMinutes == minutes,
      color: AppColors.ink,
      tint: const Color(0xFFFAF9F7),
      onTap: () => setState(() => _durationMinutes = minutes),
    );
  }

  /// Periodic or live, chosen per journey. The group's own rule can take
  /// live off the table, in which case the switch is disabled and says why
  /// rather than being silently ignored. A live start the server still
  /// refuses (LIVE_JOURNEY_NOT_ALLOWED) comes back through journeyState and
  /// is shown by [_handleStart].
  Widget _liveToggleBuilder(final bool snapPointsOnly) {
    return Row(
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Send live updates',
                  style: TextStyle(
                    fontSize: 15.spMin,
                    color: snapPointsOnly ? FamilyColors.v31Ink : AppColors.ink,
                  ),
                ),
                if (snapPointsOnly)
                  TextSpan(
                    text: ' (this group uses periodic updates only)',
                    style: TextStyle(
                      fontSize: 12.spMin,
                      color: AppColors.mediumGrey,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Switch(
          key: const Key('journey-live'),
          value: _isLive && !snapPointsOnly,
          activeTrackColor: AppColors.green,
          inactiveTrackColor: const Color(0xFFD5D9DE),
          inactiveThumbColor: Colors.white,
          onChanged: snapPointsOnly
              ? null
              : (value) => setState(() => _isLive = value),
        ),
      ],
    );
  }

  Widget _startButtonBuilder() {
    final isBusy = ref.watch(
      providerOfFamily.select((s) => s.journeyState.isLoading),
    );
    final canStart = _recipientIds.isNotEmpty && !isBusy;

    return Opacity(
      opacity: canStart ? 1 : 0.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [FamilyColors.v31HeaderTop, FamilyColors.v31HeaderMid],
          ),
          borderRadius: BorderRadius.circular(14.spMin),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D2E2A9E),
              blurRadius: 16.0,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: SizedBox(
          height: 54.spMin,
          width: double.infinity,
          child: TextButton(
            key: const Key('journey-start'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.spMin),
              ),
            ),
            onPressed: canStart ? _handleStart : null,
            child: Text(
              isBusy ? 'Starting...' : 'Start sharing',
              style: TextStyle(
                fontSize: 16.spMin,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Running ──────────────────────────────────────────────────────────

  Widget _runningBuilder(final FamilyJourney journey) {
    final minutesLeft = journey.remaining.inMinutes;

    // ALRT asks before sharing ends rather than letting it lapse quietly.
    if (minutesLeft <= 10 && _endingPromptShownFor != journey.id) {
      _endingPromptShownFor = journey.id;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showEndingPrompt(journey),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FamilyBoardCard(
          children: [
            Text(
              'Journey active',
              style: TextStyle(
                fontSize: 16.spMin,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            FamilyBoardMuted(
              '${minutesLeft < 1 ? 'Stopping now' : 'Stops in $minutesLeft min'}. '
              '${journey.isLive ? 'Live sharing is on until it ends.' : 'Periodic updates: your departure, an update about every 10 minutes, and your arrival.'}',
            ),
            if (journey.recipients.isNotEmpty)
              FamilyBoardMuted(
                'Seen by ${journey.recipients.map((r) => r.name).join(', ')}',
                size: 12,
              ),
            Row(
              children: [
                if (journey.canExtend) ...[
                  Expanded(
                    child: _smallBuilder(
                      key: 'journey-extend',
                      label: 'Keep sharing 1 more hour',
                      onPressed: _handleExtend,
                    ),
                  ),
                  SizedBox(width: 8.spMin),
                ],
                Expanded(
                  child: _smallBuilder(
                    key: 'journey-stop',
                    label: 'Stop sharing now',
                    onPressed: _handleStop,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ── Shared pieces ────────────────────────────────────────────────────

  /// The boards' small outlined button, keyed for tests.
  Widget _smallBuilder({
    required final String key,
    required final String label,
    required final VoidCallback onPressed,
  }) {
    return KeyedSubtree(
      key: Key(key),
      child: FamilyBoardSmallButton(label: label, onPressed: onPressed),
    );
  }

  Widget _cardBuilder({required final Widget child}) {
    return FamilyBoardCard(children: [child]);
  }

  Widget _labelBuilder(final String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.spMin,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: AppColors.sectionLabel,
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
      return;
    }
    // LIVE_JOURNEY_NOT_ALLOWED and the access refusals arrive here as the
    // provider's journeyState error, each with its own wording.
    final error = ref.read(providerOfFamily).journeyState.error;
    error != null
        ? await showFamilyActionError(context, ref, error)
        : context.showErrorToast(message: 'Could not start sharing');
  }

  Future<void> _handleExtend() async {
    final ok = await ref.read(providerOfFamily.notifier).extendJourney();
    if (!mounted) return;
    if (ok) {
      context.showSuccessToast(message: 'Sharing extended');
      return;
    }
    final error = ref.read(providerOfFamily).journeyState.error;
    error != null
        ? await showFamilyActionError(context, ref, error)
        : context.showErrorToast(message: 'Could not extend');
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
