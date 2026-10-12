import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/screens/family_share_ending_screen.dart';
import 'package:hazard_app/features/family/views/widgets/family_app_bar.dart';
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
      backgroundColor: Colors.white,
      appBar: const FamilyWhiteAppBar(title: 'Share my journey'),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16.spMin,
          4.spMin,
          16.spMin,
          28.spMin + MediaQuery.viewPaddingOf(context).bottom,
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
              Row(
                children: [
                  for (final minutes in _durations) ...[
                    Expanded(child: _durationPillBuilder(minutes)),
                    if (minutes != _durations.last) SizedBox(width: 8.spMin),
                  ],
                ],
              ),
              SizedBox(height: 16.spMin),
              _liveToggleBuilder(snapPointsOnly),
              SizedBox(height: 16.spMin),
              _startButtonBuilder(),
            ],
          ),
        ),
        SizedBox(height: 12.spMin),
        Text(
          'A journey is seen only by the people you pick. It ends on time '
          'or when you stop it, whichever comes first.',
          style: TextStyle(
            fontSize: 12.5.spMin,
            height: 1.5,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }

  /// One chip per other member: the recipient picker. Selected chips take
  /// the family indigo.
  Widget _recipientChipBuilder(final FamilyMember member) {
    final isOn = _recipientIds.contains(member.id);
    return Semantics(
      selected: isOn,
      child: GestureDetector(
        key: Key('journey-recipient-${member.id}'),
        onTap: () => setState(() {
          if (isOn) {
            _recipientIds.remove(member.id);
          } else {
            _recipientIds.add(member.id);
          }
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: EdgeInsets.symmetric(
            horizontal: 14.spMin,
            vertical: 9.spMin,
          ),
          decoration: BoxDecoration(
            color: isOn ? FamilyColors.indigo : Colors.white,
            borderRadius: BorderRadius.circular(20.spMin),
            border: Border.all(
              color: isOn ? FamilyColors.indigo : FamilyColors.v31Border,
              width: 1.5,
            ),
          ),
          child: Text(
            member.name,
            style: TextStyle(
              fontSize: 14.spMin,
              fontWeight: FontWeight.w700,
              color: isOn ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }

  /// 15 / 30 / 60 min. The selected pill takes a 2 px ink border.
  Widget _durationPillBuilder(final int minutes) {
    final isSelected = _durationMinutes == minutes;
    return GestureDetector(
      key: Key('journey-duration-$minutes'),
      onTap: () => setState(() => _durationMinutes = minutes),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        height: 44.spMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.spMin),
          border: Border.all(
            color: isSelected ? AppColors.ink : FamilyColors.v31Border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          '$minutes min',
          style: TextStyle(
            fontSize: 14.spMin,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
      ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Send live updates',
                style: TextStyle(
                  fontSize: 14.spMin,
                  fontWeight: FontWeight.w700,
                  color: snapPointsOnly ? FamilyColors.v31Ink : AppColors.ink,
                ),
              ),
              SizedBox(height: 2.spMin),
              Text(
                snapPointsOnly
                    ? 'This group uses periodic updates only'
                    : _isLive
                    ? 'Live location until the journey stops'
                    : 'Periodic updates: departure, about every 10 minutes, '
                          'arrival',
                style: TextStyle(
                  fontSize: 12.spMin,
                  height: 1.35,
                  color: FamilyColors.v31Ink,
                ),
              ),
            ],
          ),
        ),
        Switch(
          key: const Key('journey-live'),
          value: _isLive && !snapPointsOnly,
          activeTrackColor: FamilyColors.v31ToggleOn,
          inactiveTrackColor: FamilyColors.v31ToggleOff,
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
            colors: [FamilyColors.v31Indigo, FamilyColors.v31HeaderMid],
          ),
          borderRadius: BorderRadius.circular(16.spMin),
        ),
        child: SizedBox(
          height: 54.spMin,
          child: TextButton(
            key: const Key('journey-start'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.spMin),
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
        _cardBuilder(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Journey active',
                style: TextStyle(
                  fontSize: 20.spMin,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              SizedBox(height: 4.spMin),
              Text(
                '${minutesLeft < 1 ? 'Stopping now' : 'Stops in $minutesLeft min'}. '
                '${journey.isLive ? 'Live location: updating as you move' : 'Periodic updates: about every 10 minutes'}.',
                style: TextStyle(
                  fontSize: 13.spMin,
                  height: 1.45,
                  color: FamilyColors.v31Ink,
                ),
              ),
              if (journey.recipients.isNotEmpty) ...[
                SizedBox(height: 6.spMin),
                Text(
                  'Seen by ${journey.recipients.map((r) => r.name).join(', ')}',
                  style: TextStyle(
                    fontSize: 12.5.spMin,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
              SizedBox(height: 16.spMin),
              if (journey.canExtend) ...[
                _outlinedBuilder(
                  key: 'journey-extend',
                  label: 'Keep sharing 1 more hour',
                  onPressed: _handleExtend,
                ),
                SizedBox(height: 10.spMin),
              ],
              _outlinedBuilder(
                key: 'journey-stop',
                label: 'Stop sharing now',
                color: AppColors.red,
                onPressed: _handleStop,
              ),
            ],
          ),
        ),
        SizedBox(height: 12.spMin),
        Text(
          'When it stops, your last position is deleted. History keeps the '
          'time and how long, never where you were.',
          style: TextStyle(
            fontSize: 12.5.spMin,
            height: 1.5,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }

  // ── Shared pieces ────────────────────────────────────────────────────

  Widget _outlinedBuilder({
    required final String key,
    required final String label,
    required final VoidCallback onPressed,
    final Color color = AppColors.ink,
  }) {
    return SizedBox(
      height: 50.spMin,
      child: OutlinedButton(
        key: Key(key),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          backgroundColor: Colors.white,
          side: const BorderSide(color: FamilyColors.v31Border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.spMin),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(fontSize: 15.spMin, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _cardBuilder({required final Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.spMin),
        border: Border.all(color: FamilyColors.v31Divider),
        boxShadow: const [
          BoxShadow(
            color: FamilyColors.v31CardShadow,
            blurRadius: 10.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.spMin),
      child: child,
    );
  }

  Widget _labelBuilder(final String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11.spMin,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
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
