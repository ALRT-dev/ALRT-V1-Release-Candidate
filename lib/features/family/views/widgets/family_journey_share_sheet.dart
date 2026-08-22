import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/screens/family_journey_screen.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_member_avatar.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

/// Shares a journey from the map, where people actually are when they set
/// off, instead of making them go find the family tab first.
///
/// The whole picker is here: which group, who in it, how long, and whether
/// this one trip sends live updates or the default snap points. Everything
/// obeys the same rules as the family screen, including the group's own
/// snap-points-only setting.
Future<void> showFamilyJourneyShareSheet(final BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _JourneyShareSheet(),
  );
}

class _JourneyShareSheet extends ConsumerStatefulWidget {
  const _JourneyShareSheet();

  @override
  ConsumerState<_JourneyShareSheet> createState() => _JourneyShareSheetState();
}

class _JourneyShareSheetState extends ConsumerState<_JourneyShareSheet> {
  static const _durations = [30, 60];

  int _durationMinutes = 60;
  final Set<String> _recipientIds = {};
  bool _isLive = false;

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
    final circles = ref.watch(providerOfFamily.select((s) => s.circles));
    final journey = ref.watch(providerOfFamily.select((s) => s.activeJourney));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: FamilyColors.v31Page,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(18.spMin, 12.spMin, 18.spMin, 20.spMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40.spMin,
                  height: 4.spMin,
                  decoration: BoxDecoration(
                    color: FamilyColors.v31Border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              SizedBox(height: 16.spMin),
              if (circle == null)
                _noCircleBuilder()
              else if (journey != null && journey.isActive)
                _runningBuilder(journey)
              else
                ..._setupBuilder(circle, circles),
            ],
          ),
        ),
      ),
    );
  }

  Widget _titleBuilder(final String text, {final String? sub}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(fontSize: 19.spMin, fontWeight: FontWeight.w800),
        ),
        if (sub != null) ...[
          SizedBox(height: 4.spMin),
          Text(
            sub,
            style: TextStyle(fontSize: 12.5.spMin, color: FamilyColors.v31Ink),
          ),
        ],
      ],
    );
  }

  Widget _labelBuilder(final String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.spMin),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10.spMin,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: FamilyColors.v31Label,
        ),
      ),
    );
  }

  Widget _noCircleBuilder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _titleBuilder(
          'Share a journey',
          sub: 'Journeys are shared with a family group. Set one up first, '
              'then you can share from here.',
        ),
        SizedBox(height: 16.spMin),
        SizedBox(
          height: 48.spMin,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: FamilyColors.v31Indigo,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.spMin),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              context.push(FamilyJourneyScreen.route);
            },
            child: Text(
              'Open Family',
              style: TextStyle(fontSize: 15.spMin, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _setupBuilder(
    final FamilyCircle circle,
    final List<FamilyCircleSummary> circles,
  ) {
    final others = circle.others;
    final snapPointsOnly = circle.journeysSnapPointsOnly;

    return [
      _titleBuilder(
        'Share a journey',
        sub: 'It stops itself at the time you pick. Stop is always one tap.',
      ),
      SizedBox(height: 18.spMin),
      // Only worth asking which group when there is more than one.
      if (circles.length > 1) ...[
        _labelBuilder('Group'),
        Wrap(
          spacing: 8.spMin,
          runSpacing: 8.spMin,
          children: [
            for (final summary in circles)
              _groupChipBuilder(summary, isSelected: summary.circleId == circle.id),
          ],
        ),
        SizedBox(height: 18.spMin),
      ],
      _labelBuilder('Who sees it'),
      if (others.isEmpty)
        Text(
          'Invite someone to ${circle.name} first.',
          style: TextStyle(fontSize: 13.spMin, color: AppColors.mediumGrey),
        )
      else
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.spMin),
          ),
          child: Column(
            children: [
              for (final (index, member) in others.indexed) ...[
                if (index > 0)
                  Divider(
                    height: 1,
                    indent: 60.spMin,
                    color: FamilyColors.v31Divider,
                  ),
                _recipientRowBuilder(member),
              ],
            ],
          ),
        ),
      SizedBox(height: 18.spMin),
      _labelBuilder('How long'),
      Row(
        children: [
          for (final minutes in _durations) ...[
            Expanded(child: _durationChipBuilder(minutes)),
            if (minutes != _durations.last) SizedBox(width: 10.spMin),
          ],
        ],
      ),
      SizedBox(height: 18.spMin),
      _labelBuilder('How much detail'),
      Container(
        padding: EdgeInsets.fromLTRB(14.spMin, 6.spMin, 8.spMin, 12.spMin),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.spMin),
        ),
        child: Column(
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
            Text(
              snapPointsOnly
                  ? 'This group is set to snap points only.'
                  : _isLive
                      ? 'Your position updates as you move, until the '
                            'journey stops.'
                      : 'Snap points: departure, about every 10 minutes, '
                            'and arrival.',
              style: TextStyle(
                fontSize: 11.spMin,
                height: 1.5,
                color: FamilyColors.v31Ink,
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 18.spMin),
      _startButtonBuilder(snapPointsOnly: snapPointsOnly),
    ];
  }

  Widget _groupChipBuilder(
    final FamilyCircleSummary summary, {
    required final bool isSelected,
  }) {
    return GestureDetector(
      onTap: isSelected
          ? null
          : () async {
              // Switching group reloads members, so the picks that belonged
              // to the old group go with it.
              setState(_recipientIds.clear);
              await ref
                  .read(providerOfFamily.notifier)
                  .selectCircle(summary.circleId);
            },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 14.spMin,
          vertical: 9.spMin,
        ),
        decoration: BoxDecoration(
          color: isSelected ? FamilyColors.v31Indigo : Colors.white,
          borderRadius: BorderRadius.circular(12.spMin),
          border: Border.all(
            color: isSelected ? FamilyColors.v31Indigo : FamilyColors.v31Border,
            width: 1.5,
          ),
        ),
        child: Text(
          summary.name,
          style: TextStyle(
            fontSize: 13.spMin,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : FamilyColors.v31Indigo,
          ),
        ),
      ),
    );
  }

  Widget _recipientRowBuilder(final FamilyMember member) {
    final isOn = _recipientIds.contains(member.id);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.spMin, vertical: 4.spMin),
      child: Row(
        children: [
          FamilyMemberAvatar(member: member, size: 36, showStatusDot: false),
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
              value
                  ? _recipientIds.add(member.id)
                  : _recipientIds.remove(member.id);
            }),
          ),
        ],
      ),
    );
  }

  Widget _durationChipBuilder(final int minutes) {
    final isSelected = _durationMinutes == minutes;
    return GestureDetector(
      onTap: () => setState(() => _durationMinutes = minutes),
      child: Container(
        height: 44.spMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? FamilyColors.v31Indigo : Colors.white,
          borderRadius: BorderRadius.circular(12.spMin),
          border: Border.all(
            color: isSelected ? FamilyColors.v31Indigo : FamilyColors.v31Border,
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

  Widget _startButtonBuilder({required final bool snapPointsOnly}) {
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
        onPressed: canStart
            ? () => _handleStart(snapPointsOnly: snapPointsOnly)
            : null,
        child: Text(
          _recipientIds.isEmpty
              ? 'Pick who sees it'
              : 'Start sharing until ${endsAt.format(context)}',
          style: TextStyle(fontSize: 15.spMin, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _runningBuilder(final FamilyJourney journey) {
    final minutesLeft = journey.remaining.inMinutes;
    final endsAt = TimeOfDay.fromDateTime(journey.endsAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _titleBuilder(
          minutesLeft < 1 ? 'Stopping now' : 'Sharing for $minutesLeft min',
          sub: 'Ends at ${endsAt.format(context)} on its own. '
              '${journey.isLive ? 'Live updates as you move.' : 'Snap points along the way.'}',
        ),
        if (journey.recipients.isNotEmpty) ...[
          SizedBox(height: 12.spMin),
          Text(
            'Seen by ${journey.recipients.map((r) => r.name).join(', ')}',
            style: TextStyle(fontSize: 12.5.spMin, color: AppColors.mediumGrey),
          ),
        ],
        SizedBox(height: 18.spMin),
        if (journey.canExtend) ...[
          SizedBox(
            height: 48.spMin,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: FamilyColors.indigo,
                backgroundColor: Colors.white,
                side: const BorderSide(color: FamilyColors.indigo),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.spMin),
                ),
              ),
              onPressed: () async {
                final ok =
                    await ref.read(providerOfFamily.notifier).extendJourney();
                if (!mounted) return;
                context.showSuccessToast(
                  message: ok ? 'Sharing extended' : 'Could not extend',
                );
              },
              child: Text(
                'Keep sharing 1 more hour',
                style: TextStyle(
                  fontSize: 15.spMin,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.spMin),
        ],
        SizedBox(
          height: 52.spMin,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: FamilyColors.sosRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.spMin),
              ),
            ),
            onPressed: () async {
              final ok =
                  await ref.read(providerOfFamily.notifier).stopJourney();
              if (!mounted) return;
              Navigator.of(context).pop();
              context.showSuccessToast(
                message: ok ? 'Sharing stopped' : 'Could not stop sharing',
              );
            },
            child: Text(
              'Stop sharing now',
              style: TextStyle(fontSize: 16.spMin, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleStart({required final bool snapPointsOnly}) async {
    final ok = await ref.read(providerOfFamily.notifier).startJourney(
          durationMinutes: _durationMinutes,
          recipientMemberIds: _recipientIds.toList(),
          isLive: _isLive && !snapPointsOnly,
        );
    if (!mounted) return;
    Navigator.of(context).pop();
    ok
        ? context.showSuccessToast(message: 'Sharing your journey')
        : context.showErrorToast(message: 'Could not start sharing');
  }
}
