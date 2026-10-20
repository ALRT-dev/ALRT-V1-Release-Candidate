import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/views/widgets/family_board_widgets.dart';
import 'package:hazard_app/features/family/views/widgets/family_check_in_consent_sheet.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

/// What a tap on a member row opens: who they are, what their chip means,
/// and every action the tapper is allowed to take on them — visible and
/// labelled, instead of hidden behind a long-press.
///
/// Permissions are decided by the caller (the hub knows roles); a null
/// callback simply hides that action. Every action closes the sheet first
/// and then runs, so confirmations open on the hub, not on top of this.
Future<void> showFamilyMemberDetailsSheet(
  final BuildContext context, {
  required final FamilyMember member,
  required final bool isMe,
  required final bool isNearAlert,
  required final bool? hasAnswered,
  final DateTime? askedAt,
  final FamilyCheckIn? lastCheckIn,
  final VoidCallback? onAskToCheckIn,
  final VoidCallback? onRequestLocation,
  final VoidCallback? onChangeMySharing,
  final VoidCallback? onRemove,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.spMin)),
    ),
    builder: (sheetContext) => FamilyMemberDetailsSheet(
      member: member,
      isMe: isMe,
      isNearAlert: isNearAlert,
      hasAnswered: hasAnswered,
      askedAt: askedAt,
      lastCheckIn: lastCheckIn,
      onAskToCheckIn: onAskToCheckIn,
      onRequestLocation: onRequestLocation,
      onChangeMySharing: onChangeMySharing,
      onRemove: onRemove,
    ),
  );
}

class FamilyMemberDetailsSheet extends StatelessWidget {
  const FamilyMemberDetailsSheet({
    super.key,
    required this.member,
    required this.isMe,
    required this.isNearAlert,
    required this.hasAnswered,
    this.askedAt,
    this.lastCheckIn,
    this.onAskToCheckIn,
    this.onRequestLocation,
    this.onChangeMySharing,
    this.onRemove,
  });

  final FamilyMember member;
  final bool isMe;
  final bool isNearAlert;
  final bool? hasAnswered;
  final DateTime? askedAt;

  /// This member's most recent check-in, when the hub has it: carries the
  /// alert it was made from ("near `<alert>`") and any message.
  final FamilyCheckIn? lastCheckIn;
  final VoidCallback? onAskToCheckIn;
  final VoidCallback? onRequestLocation;
  final VoidCallback? onChangeMySharing;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final media = MediaQuery.of(context);
    final bottom =
        media.viewInsets.bottom > media.viewPadding.bottom
            ? media.viewInsets.bottom
            : media.viewPadding.bottom;

    void run(final VoidCallback action) {
      Navigator.of(context).pop();
      action();
    }

    final name = isMe ? '${member.name} (you)' : member.name;
    final title = member.role == FamilyRole.owner
        ? '$name · hosts this circle'
        : name;
    final snapshot = member.locationLabel;
    final expiresAt = member.locationExpiresAt;
    final message = lastCheckIn?.message;

    // The approved MemberSheet board: name, one line of facts, an optional
    // last snapshot, then one outlined button per action and Close.
    return Padding(
      padding: EdgeInsets.fromLTRB(20.spMin, 12.spMin, 20.spMin, bottom + 12.spMin),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FamilyBoardSheetHandle(),
          SizedBox(height: 14.spMin),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FamilyBoardSheetTitle(
                  title: title,
                  subtitle: '${_factLine(now)} · sharing '
                      '${sharingLevelLabel(member.sharingLevel).toLowerCase()}',
                ),
              ),
              if (_pill != null) ...[
                SizedBox(width: 8.spMin),
                _pill!,
              ],
            ],
          ),
          if (isNearAlert) ...[
            SizedBox(height: 8.spMin),
            const FamilyBoardMuted(
              'Their last known area is near an active alert.',
            ),
          ],
          if (lastCheckIn?.hazard != null) ...[
            SizedBox(height: 8.spMin),
            FamilyBoardMuted(
              'Checked in near "${lastCheckIn!.hazard!.title}"',
            ),
          ],
          if (message != null && message.isNotEmpty) ...[
            SizedBox(height: 8.spMin),
            FamilyBoardMuted('"$message"'),
          ],
          if (snapshot != null && snapshot.isNotEmpty) ...[
            SizedBox(height: 12.spMin),
            FamilyBoardCard(
              children: [
                Text(
                  'Last snapshot',
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                FamilyBoardMuted(
                  [
                    snapshot,
                    if (expiresAt != null && expiresAt.isAfter(now))
                      'expires ${DateFormat('h:mm a').format(expiresAt.toLocal())}',
                  ].join(' · '),
                ),
              ],
            ),
          ],
          SizedBox(height: 16.spMin),
          if (onAskToCheckIn != null) ...[
            FamilyBoardSecondaryButton(
              label: 'Ask ${member.name} to check in',
              onPressed: () => run(onAskToCheckIn!),
            ),
            SizedBox(height: 10.spMin),
          ],
          if (onRequestLocation != null) ...[
            FamilyBoardSecondaryButton(
              label: 'Request a one-time location',
              onPressed: () => run(onRequestLocation!),
            ),
            SizedBox(height: 10.spMin),
          ],
          if (onChangeMySharing != null) ...[
            FamilyBoardSecondaryButton(
              label: 'Change my sharing level',
              onPressed: () => run(onChangeMySharing!),
            ),
            SizedBox(height: 10.spMin),
          ],
          if (onRemove != null) ...[
            FamilyBoardSecondaryButton(
              label: 'Remove from circle',
              onPressed: () => run(onRemove!),
            ),
            SizedBox(height: 10.spMin),
          ],
          if (onAskToCheckIn == null &&
              onRequestLocation == null &&
              onChangeMySharing == null &&
              onRemove == null) ...[
            const FamilyBoardMuted('Nothing to do here right now.'),
            SizedBox(height: 6.spMin),
          ],
          FamilyBoardGhostButton(
            label: 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// "Asked 2 minutes ago", "Checked in 12:04 PM" or "No check-in yet".
  String _factLine(final DateTime now) {
    final asked = askedAt;
    if (hasAnswered == false && asked != null) {
      return 'Asked ${timeago.format(asked, clock: now)}';
    }
    final last = member.lastCheckInAt;
    if (last != null) {
      return 'Checked in ${DateFormat('h:mm a').format(last.toLocal())}';
    }
    return 'No check-in yet';
  }

  /// "Waiting" only while a check-in was actually asked of them and not
  /// answered (ruling 9 Oct 2026); "Checked in" once they have; nothing
  /// otherwise.
  Widget? get _pill {
    if (hasAnswered == true) return const FamilyBoardPill.checkedIn();
    if (hasAnswered == false && askedAt != null) {
      return const FamilyBoardPill.waiting();
    }
    return null;
  }
}
