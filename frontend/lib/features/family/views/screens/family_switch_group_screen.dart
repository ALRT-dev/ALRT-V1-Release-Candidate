import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/providers/selected_circle_provider.dart';
import 'package:hazard_app/features/family/utils/group_state.dart';
import 'package:hazard_app/features/family/utils/invite_code.dart';
import 'package:hazard_app/features/family/views/widgets/family_board_kit.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_group_actions.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/subscription/views/widgets/access_refusal_sheet.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// "Your family circles" (SwitchCircle board): one card per circle with
/// its colour as a left edge, how many people and whether you host it,
/// "Current" on the one in view; then a card to join with a code or
/// create another circle. Joining and creating are free and unlimited.
///
/// A circle with an SOS running says so on its card ("SOS live · name"),
/// so an SOS is never hidden behind the switcher.
class FamilySwitchGroupScreen extends ConsumerStatefulWidget {
  const FamilySwitchGroupScreen({super.key});

  static const route = '/family-switch-group';

  @override
  ConsumerState<FamilySwitchGroupScreen> createState() =>
      _FamilySwitchGroupScreenState();
}

class _FamilySwitchGroupScreenState
    extends ConsumerState<FamilySwitchGroupScreen> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(providerOfFamily.select((s) => s.joinCircleState), (
      prev,
      next,
    ) {
      if (prev != next && next.isError && next.error != null) {
        // A full group says so, with its capacity; never a payment ask.
        showFamilyActionError(context, ref, next.error!);
      }
    });
    ref.listen(providerOfFamily.select((s) => s.createCircleState), (
      prev,
      next,
    ) {
      if (prev != next && next.isError && next.error != null) {
        context.showErrorToast(message: next.error!.message);
      }
    });

    final circles = ref.watch(providerOfFamily.select((s) => s.circles));
    final selectedId = ref.watch(providerOfSelectedCircleId);
    final circle = ref.watch(providerOfFamily.select((s) => s.circle));

    // With no explicit selection the family tab shows the first circle, so
    // the switcher has to highlight the same one or Current lies.
    final currentId = selectedId ?? circles.firstOrNull?.circleId;

    return FamilyBoardScaffold(
      title: 'Your family circles',
      gap: 10,
      children: [
        for (final summary in circles)
          _circleCardBuilder(
            summary,
            isCurrent: summary.circleId == currentId,
            loaded: summary.circleId == currentId ? circle : null,
          ),
        _joinOrCreateCardBuilder(),
      ],
    );
  }

  Widget _circleCardBuilder(
    final FamilyCircleSummary summary, {
    required final bool isCurrent,
    required final FamilyCircle? loaded,
  }) {
    final state = groupStateOf(
      summary,
      openCircle: loaded,
      loadedCircles: ref.watch(providerOfFamily.select((s) => s.loadedCircles)),
      activeSosEvents: ref.watch(
        providerOfFamily.select((s) => s.activeSosEvents),
      ),
    );
    final isSos = state.kind == GroupStateKind.sos;
    final people =
        '${summary.memberCount} ${summary.memberCount == 1 ? 'person' : 'people'}';
    final subtitle = summary.isOwned ? '$people · you host' : people;

    return Material(
      key: Key('circle-pick-${summary.circleId}'),
      color: Colors.white,
      borderRadius: BorderRadius.circular(18.spMin),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _pick(summary, isCurrent: isCurrent),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: FamilyColors.beaconOf(summary.themeColor),
                width: 5,
              ),
            ),
          ),
          padding: EdgeInsets.fromLTRB(16.spMin, 14.spMin, 16.spMin, 14.spMin),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.spMin,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 2.spMin),
                    FamilyBoardMuted(subtitle, size: 12),
                    if (isSos) ...[
                      SizedBox(height: 6.spMin),
                      FamilyBoardPill(
                        state.label,
                        background: FamilyColors.sosRedLight,
                        foreground: FamilyColors.sosRed,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.spMin),
              if (isCurrent)
                const FamilyBoardPill('Current')
              else
                Icon(
                  LucideIcons.chevronRight,
                  size: 18.spMin,
                  color: AppColors.mediumGrey,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _joinOrCreateCardBuilder() {
    return FamilyBoardCard(
      children: [
        TextField(
          key: const Key('join-code'),
          controller: _codeController,
          textCapitalization: TextCapitalization.characters,
          style: familyBoardInputStyle(),
          decoration: familyBoardInputDecoration('Invite code'),
        ),
        FamilyBoardSecondaryButton(
          key: const Key('join-with-code'),
          label: 'Join with a code',
          onPressed: _join,
        ),
        FamilyBoardSecondaryButton(
          key: const Key('join-scan'),
          label: 'Scan invite QR',
          onPressed: () => scanInviteQrAndJoin(context, ref),
        ),
        TextField(
          key: const Key('new-circle-name'),
          controller: _nameController,
          maxLength: 50,
          textCapitalization: TextCapitalization.words,
          style: familyBoardInputStyle(),
          decoration: familyBoardInputDecoration('New circle name'),
        ),
        FamilyBoardSecondaryButton(
          key: const Key('create-circle'),
          label: 'Create another circle',
          onPressed: _create,
        ),
        const FamilyBoardMuted(
          'Joining with a code is always free. A person can be in several '
          'circles.',
          size: 12,
        ),
      ],
    );
  }

  /// Tapping rescopes the whole Family tab and returns, so the switch is
  /// felt on the hub, not here.
  Future<void> _pick(
    final FamilyCircleSummary summary, {
    required final bool isCurrent,
  }) async {
    if (!isCurrent) {
      await ref.read(providerOfFamily.notifier).selectCircle(summary.circleId);
    }
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  /// The same checks as the "Join with a code" sheet, then the same join.
  void _join() {
    final raw = _codeController.text.trim();
    if (raw.isEmpty) {
      context.showErrorToast(message: 'Enter or scan an invite code first');
      return;
    }
    final code = parseInviteCode(raw);
    if (code == null) {
      context.showErrorToast(
        message:
            "That doesn't look like an invite code. Codes look like "
            'ALRT-7F3K2. Check it with the host.',
      );
      return;
    }
    FocusScope.of(context).unfocus();
    _codeController.clear();
    ref.read(providerOfFamily.notifier).join(code: code);
  }

  /// Creating a circle is free and unlimited (V1 access model).
  void _create() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      context.showErrorToast(message: 'Give your circle a name first');
      return;
    }
    FocusScope.of(context).unfocus();
    _nameController.clear();
    ref.read(providerOfFamily.notifier).createCircle(name: name);
  }
}
