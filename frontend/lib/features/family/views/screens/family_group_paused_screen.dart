import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_board_kit.dart';
import 'package:hazard_app/features/family/views/widgets/family_leave_confirm_sheet.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

/// The host hand-over screen (GroupPaused board, "What's happening"): this
/// circle has no current host because the host left or deleted their
/// account. One card says who left and how long is left to choose a new
/// host, then "Take over as host" and "Leave the circle".
///
/// The copy states what the app actually does: SOS, check-ins, journeys
/// and the member list keep working; only invites and settings need a
/// host. The backend judges who may take over, so the button always tries
/// and a refusal comes back in plain words.
///
/// The host themselves (a lapsed host still in the circle) gets "Hand the
/// circle to someone" and "Close the circle"; those pop 'transfer' or
/// 'close' for the hub to run, as before.
class FamilyGroupPausedScreen extends ConsumerStatefulWidget {
  const FamilyGroupPausedScreen({super.key});

  static const route = '/family-group-paused';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FamilyGroupPausedScreenState();
}

class _FamilyGroupPausedScreenState
    extends ConsumerState<FamilyGroupPausedScreen> {
  bool _takingOver = false;

  @override
  Widget build(BuildContext context) {
    final circle = ref.watch(providerOfFamily.select((s) => s.circle));
    if (circle == null) return const SizedBox.shrink();

    final isOwner = circle.me?.role == FamilyRole.owner;
    final isGuest = circle.me?.role == FamilyRole.guest;

    return FamilyBoardScaffold(
      title: "What's happening",
      children: [
        _statusCardBuilder(circle),
        if (!isOwner && !isGuest)
          FamilyBoardPrimaryButton(
            key: const Key('takeover'),
            label: _takingOver ? 'Taking over...' : 'Take over as host',
            indigo: true,
            onPressed: _takingOver ? null : _takeOver,
          ),
        if (isOwner) ...[
          FamilyBoardSecondaryButton(
            label: 'Hand the circle to someone',
            onPressed: () => Navigator.of(context).maybePop('transfer'),
          ),
          FamilyBoardSecondaryButton(
            label: 'Close the circle',
            onPressed: () => Navigator.of(context).maybePop('close'),
          ),
        ] else
          FamilyBoardSecondaryButton(
            key: const Key('paused-leave'),
            label: 'Leave the circle',
            onPressed: _takingOver ? null : () => _leave(circle),
          ),
      ],
    );
  }

  Widget _statusCardBuilder(final FamilyCircle circle) {
    final host = circle.hostTransitionHostName ?? 'The host';
    final days = circle.hostTransitionDaysLeft;
    final locked = circle.hostTransitionLocked;
    final window = locked || days == null
        ? 'Invites and group settings are locked until someone takes over.'
        : 'Choose a new host within $days ${days == 1 ? 'day' : 'days'}. '
              'After that, invites and group settings lock until someone '
              'takes over.';

    return FamilyBoardCard(
      gap: 4,
      children: [
        Text(
          '$host left as host',
          style: TextStyle(
            fontSize: 16.spMin,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        FamilyBoardMuted(
          '$window Check in, Check on, SOS and Journey keep working, and '
          'nobody is removed. Hosting is free and how the group is paid '
          'for does not change.',
        ),
      ],
    );
  }

  Future<void> _takeOver() async {
    setState(() => _takingOver = true);
    final refusal = await ref.read(providerOfFamily.notifier).takeOverCircle();
    if (!mounted) return;
    setState(() => _takingOver = false);
    if (refusal == null) {
      context.showSuccessToast(
        message: "You're hosting now. Invites and settings are unlocked.",
      );
      Navigator.of(context).maybePop();
    } else {
      context.showErrorToast(message: refusal);
    }
  }

  Future<void> _leave(final FamilyCircle circle) async {
    final shouldLeave = await showFamilyLeaveConfirmSheet(
      context: context,
      circleName: circle.name,
      isHost: false,
    );
    if (!shouldLeave || !mounted) return;
    await ref.read(providerOfFamily.notifier).leave();
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }
}
