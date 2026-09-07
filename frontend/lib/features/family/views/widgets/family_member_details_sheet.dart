import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/utils/family_hub_labels.dart';
import 'package:hazard_app/features/family/views/widgets/family_check_in_consent_sheet.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_member_avatar.dart';
import 'package:hazard_app/others/app_surface_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
  final VoidCallback? onAskToCheckIn,
  final VoidCallback? onRequestLocation,
  final VoidCallback? onChangeMySharing,
  final VoidCallback? onRemove,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.surfaceCard,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.spMin)),
    ),
    builder: (sheetContext) => FamilyMemberDetailsSheet(
      member: member,
      isMe: isMe,
      isNearAlert: isNearAlert,
      hasAnswered: hasAnswered,
      askedAt: askedAt,
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
  final VoidCallback? onAskToCheckIn;
  final VoidCallback? onRequestLocation;
  final VoidCallback? onChangeMySharing;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final chip = memberStatusChip(
      member: member,
      hasAnswered: hasAnswered,
      isNearAlert: isNearAlert,
    );
    final safe = chip == 'Safe';
    final chipInk = safe ? FamilyColors.safeGreen : FamilyColors.amber;
    final chipBackground =
        safe ? FamilyColors.safeGreenLight : FamilyColors.amberLight;
    final media = MediaQuery.of(context);
    final bottom =
        media.viewInsets.bottom > media.viewPadding.bottom
            ? media.viewInsets.bottom
            : media.viewPadding.bottom;

    void run(final VoidCallback action) {
      Navigator.of(context).pop();
      action();
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20.spMin, 18.spMin, 20.spMin, bottom + 20.spMin),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              FamilyMemberAvatar(
                member: member,
                size: 56.0,
                isNearAlert: isNearAlert,
              ),
              SizedBox(width: 14.spMin),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMe ? '${member.name} (You)' : member.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18.spMin,
                        fontWeight: FontWeight.w800,
                        color: context.onSurface,
                      ),
                    ),
                    SizedBox(height: 4.spMin),
                    Text(
                      _roleLine,
                      style: TextStyle(
                        fontSize: 12.5.spMin,
                        color: context.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.spMin),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.spMin, vertical: 6.spMin),
                decoration: BoxDecoration(
                  color: chipBackground,
                  borderRadius: BorderRadius.circular(20.spMin),
                ),
                child: Text(
                  chip,
                  style: TextStyle(
                    color: chipInk,
                    fontSize: 12.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.spMin),
          _lineBuilder(
            context,
            icon: LucideIcons.clock,
            text: memberStatusLine(
              member: member,
              hasAnswered: hasAnswered,
              askedAt: askedAt,
              now: now,
            ),
          ),
          SizedBox(height: 8.spMin),
          _lineBuilder(
            context,
            icon: LucideIcons.mapPin,
            text: 'Sharing level: ${sharingLevelLabel(member.sharingLevel)}',
          ),
          if (!isMe) ...[
            SizedBox(height: 12.spMin),
            Text(
              memberStatusExplanation(
                member: member,
                hasAnswered: hasAnswered,
                isNearAlert: isNearAlert,
              ),
              style: TextStyle(
                fontSize: 13.spMin,
                height: 1.45,
                color: context.onSurfaceMuted,
              ),
            ),
          ],
          SizedBox(height: 18.spMin),
          if (onAskToCheckIn != null)
            _actionBuilder(
              context,
              icon: LucideIcons.bellRing,
              label: 'Ask ${member.name} to check in',
              filled: true,
              onTap: () => run(onAskToCheckIn!),
            ),
          if (onRequestLocation != null)
            _actionBuilder(
              context,
              icon: LucideIcons.mapPin,
              label: 'Request a one-time location',
              filled: false,
              onTap: () => run(onRequestLocation!),
            ),
          if (onChangeMySharing != null)
            _actionBuilder(
              context,
              icon: LucideIcons.slidersHorizontal,
              label: 'Change my sharing level',
              filled: false,
              onTap: () => run(onChangeMySharing!),
            ),
          if (onRemove != null)
            _actionBuilder(
              context,
              icon: LucideIcons.userMinus,
              label: 'Remove from circle',
              filled: false,
              destructive: true,
              onTap: () => run(onRemove!),
            ),
          if (onAskToCheckIn == null &&
              onRequestLocation == null &&
              onChangeMySharing == null &&
              onRemove == null)
            Text(
              'Nothing to do here right now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.spMin,
                color: context.onSurfaceMuted,
              ),
            ),
        ],
      ),
    );
  }

  String get _roleLine {
    switch (member.role) {
      case FamilyRole.owner:
        return 'Hosts this circle';
      case FamilyRole.guest:
        return 'Guest · alerts only, uses no seat';
      case FamilyRole.adult:
      case FamilyRole.child:
        return 'Member of this circle';
    }
  }

  Widget _lineBuilder(
    final BuildContext context, {
    required final IconData icon,
    required final String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 2.spMin),
          child: Icon(icon, size: 15.spMin, color: context.onSurfaceMuted),
        ),
        SizedBox(width: 8.spMin),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13.5.spMin, color: context.onSurface),
          ),
        ),
      ],
    );
  }

  Widget _actionBuilder(
    final BuildContext context, {
    required final IconData icon,
    required final String label,
    required final bool filled,
    required final VoidCallback onTap,
    final bool destructive = false,
  }) {
    final ink = destructive
        ? FamilyColors.sosRed
        : filled
            ? Colors.white
            : FamilyColors.indigo;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.spMin),
      child: SizedBox(
        height: 48.spMin,
        child: TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: ink,
            backgroundColor: filled ? FamilyColors.indigo : Colors.transparent,
            side: filled
                ? null
                : BorderSide(
                    color: destructive
                        ? FamilyColors.sosRed.withValues(alpha: 0.6)
                        : FamilyColors.indigo.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.spMin),
            ),
          ),
          onPressed: onTap,
          icon: Icon(icon, size: 18.spMin),
          label: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14.spMin, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}
