import 'package:hazard_app/features/subscription/views/widgets/access_refusal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/utils/check_in_roll.dart';
import 'package:hazard_app/features/family/utils/family_hub_labels.dart';
import 'package:hazard_app/features/family/views/widgets/family_app_bar.dart';
import 'package:hazard_app/features/family/views/widgets/family_ask_check_in_sheet.dart';
import 'package:hazard_app/features/family/views/widgets/family_board_widgets.dart';
import 'package:hazard_app/features/family/views/widgets/family_check_in_consent_sheet.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:intl/intl.dart';

/// The roll call (approved RollCall board): who asked, when, who it is
/// still waiting on (each with "Request location") and who has checked
/// in. The person who asked can cancel the ask; anyone else answers it
/// with Check in, through the same consent sheet as the hub.
///
/// Names, never a bare count (locked rule, 4 Sep 2026): the heading names
/// who was asked and every waiting person has their own row.
class FamilyCheckInRollCallScreen extends ConsumerWidget {
  const FamilyCheckInRollCallScreen({super.key});

  static const route = '/family-check-in-roll-call';

  /// The boards' grey avatar for someone not yet checked in.
  static const _waitingGrey = Color(0xFFB9BEC8);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circle = ref.watch(providerOfFamily.select((s) => s.circle));
    if (circle == null) return const SizedBox.shrink();

    final request = circle.latestCheckInRequest;
    // One answer everywhere: the same CheckInRoll as the hub header,
    // member list and group tiles.
    final roll = CheckInRoll.of(circle);

    return Scaffold(
      backgroundColor: kFamilyBoardPage,
      appBar: const FamilyWhiteAppBar(title: 'Check-in'),
      body: request == null || roll.askedAt == null
          ? ListView(
              padding: EdgeInsets.fromLTRB(16.spMin, 14.spMin, 16.spMin, 120.spMin),
              children: const [
                FamilyBoardCard(
                  children: [FamilyBoardMuted('No check-in asks right now.')],
                ),
              ],
            )
          : _rollBuilder(context, ref, circle, request, roll),
    );
  }

  Widget _rollBuilder(
    final BuildContext context,
    final WidgetRef ref,
    final FamilyCircle circle,
    final FamilyCheckInRequest request,
    final CheckInRoll roll,
  ) {
    final iAsked = request.requestedById == circle.myMemberId;
    final asker = iAsked
        ? (circle.me?.name ?? 'You')
        : request.requestedBy?.displayName ??
            circle.members
                .where((m) => m.id == request.requestedById)
                .map((m) => m.name)
                .firstOrNull ??
            'Someone';

    // Who this ask was aimed at: its named targets, or everyone else.
    final asked = circle.members
        .where((m) => m.id != request.requestedById && request.isAimedAt(m.id))
        .toList();
    final waiting = asked.where((m) => !roll.hasAnswered(m)).toList();
    final responded = asked.where(roll.hasAnswered).toList();

    final whoWasAsked = request.targetMemberIds.isEmpty
        ? 'everyone'
        : namesLabel([
            for (final m in asked)
              m.id == circle.myMemberId ? 'you' : m.name,
          ]);
    final askedAt = request.createdAt;
    final detail = [
      if (askedAt != null) DateFormat('h:mm a').format(askedAt.toLocal()),
      if ((request.message ?? '').isNotEmpty) request.message!,
    ].join(' · ');

    return ListView(
      padding: EdgeInsets.fromLTRB(16.spMin, 14.spMin, 16.spMin, 120.spMin),
      children: [
        FamilyBoardCard(
          children: [
            Text(
              '$asker asked $whoWasAsked to check in',
              style: TextStyle(
                fontSize: 16.spMin,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (detail.isNotEmpty) FamilyBoardMuted(detail),
          ],
        ),
        SizedBox(height: 10.spMin),
        if (waiting.isNotEmpty) ...[
          FamilyBoardLabel('Waiting on ${waiting.length}'),
          SizedBox(height: 10.spMin),
          for (final member in waiting) ...[
            FamilyBoardPersonRow(
              avatar: FamilyBoardInitial(
                name: member.name,
                color: _waitingGrey,
              ),
              title: member.id == circle.myMemberId
                  ? '${member.name} (you)'
                  : member.name,
              subtitle: 'Not yet',
              trailing: member.id == circle.myMemberId ||
                      circle.me?.role == FamilyRole.guest
                  ? null
                  : FamilyBoardSmallButton(
                      label: 'Request location',
                      onPressed: () => _requestLocation(context, ref, member),
                    ),
            ),
            SizedBox(height: 10.spMin),
          ],
        ] else ...[
          FamilyBoardCard(
            children: [
              Text(
                'Everyone has checked in',
                style: TextStyle(
                  fontSize: 16.spMin,
                  fontWeight: FontWeight.w700,
                  color: FamilyColors.checkedInInk,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.spMin),
        ],
        if (responded.isNotEmpty) ...[
          const FamilyBoardLabel('Checked in'),
          SizedBox(height: 10.spMin),
          for (final member in responded) ...[
            FamilyBoardPersonRow(
              avatar: FamilyBoardInitial(
                name: member.name,
                color: AppColors.green,
              ),
              title: member.id == circle.myMemberId
                  ? '${member.name} (you)'
                  : member.name,
              subtitle: 'Checked in',
              trailing: const FamilyBoardPill.checkedIn(),
            ),
            SizedBox(height: 10.spMin),
          ],
        ],
        if (iAsked)
          FamilyBoardSecondaryButton(
            label: 'Cancel this check-in ask',
            onPressed: () => _cancelAsk(context, ref, request.id),
          )
        else
          FamilyBoardPrimaryButton(
            label: 'Check in',
            onPressed: () => _checkIn(context, ref, circle),
          ),
      ],
    );
  }

  Future<void> _requestLocation(
    final BuildContext context,
    final WidgetRef ref,
    final FamilyMember member,
  ) async {
    final notifier = ref.read(providerOfFamily.notifier);
    final sent = await notifier.requestMemberLocation(memberId: member.id);
    if (!context.mounted) return;
    final error = notifier.lastLocationError;
    if (sent) {
      context.showSuccessToast(
        message: '${member.name} was asked to share where they are.',
      );
    } else if (error != null) {
      await showFamilyActionError(context, ref, error);
    } else {
      context.showErrorToast(
        message: 'Could not send the request. Try again.',
      );
    }
  }

  /// Answering the ask: the same consent sheet as the hub's Check in.
  Future<void> _checkIn(
    final BuildContext context,
    final WidgetRef ref,
    final FamilyCircle circle,
  ) async {
    final names = circle.namesOwedMyCheckIn;
    final choice = await showCheckInConsentSheet(
      context,
      requesterName: names.isEmpty ? null : askersLabel(names),
      sharingLevel: circle.me?.sharingLevel,
      offerNeedHelp: true,
    );
    if (choice == null || !context.mounted) return;
    await ref
        .read(providerOfFamily.notifier)
        .checkIn(
          status: choice == CheckInConsentChoice.needHelp
              ? FamilyCheckInStatus.needsHelp
              : FamilyCheckInStatus.safe,
          shareLocation: choice == CheckInConsentChoice.checkInAndShareLocation,
        );
  }

  Future<void> _cancelAsk(
    final BuildContext context,
    final WidgetRef ref,
    final String requestId,
  ) async {
    await showConfirmationSheet(
      context: context,
      title: 'Cancel this check-in ask?',
      description:
          'Nobody will be asked to check in for this request any more. '
          'Anyone who already answered keeps their check-in.',
      confirmButtonText: 'Cancel ask',
      onPressedConfirm: (_, __) {
        ref.read(providerOfFamily.notifier).cancelCheckInRequest(requestId);
      },
    );
  }
}
