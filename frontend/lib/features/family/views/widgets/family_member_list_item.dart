import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/utils/family_hub_labels.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_member_avatar.dart';
import 'package:hazard_app/others/app_surface_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A member row for the family hub: avatar, name, location/check-in context
/// and a Safe / Near alert chip.
class FamilyMemberListItem extends StatelessWidget {
  const FamilyMemberListItem({
    super.key,
    required this.member,
    required this.isMe,
    this.isNearAlert = false,
    this.onTap,
    this.onRequestLocation,
    this.hasAnswered,
    this.askedAt,
    this.onAskToCheckIn,
  });

  final FamilyMember member;
  final bool isMe;
  final bool isNearAlert;

  /// Opens the member's details (status, and every action the tapper may
  /// take on them). Visible actions, never long-press-only.
  final VoidCallback? onTap;

  /// Whether this member has checked in on the current roll (see
  /// CheckInRoll). Null keeps the old 24-hour reading.
  final bool? hasAnswered;

  /// When there is an outstanding ask this member has not answered, the
  /// time it was sent, so the row says "Asked 3 min ago" instead of a
  /// stale "Checked in yesterday".
  final DateTime? askedAt;

  /// "Ask" on a row that still owes a check-in: asks THIS person only.
  final VoidCallback? onAskToCheckIn;

  /// Shown as a "Request" action — asks this member for a one-time snapshot.
  final VoidCallback? onRequestLocation;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 14.spMin),
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
          children: [
            FamilyMemberAvatar(
              member: member,
              size: 48.0,
              isNearAlert: isNearAlert,
            ),
            SizedBox(width: 13.spMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          isMe ? '${member.name} (You)' : member.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16.spMin,
                            fontWeight: FontWeight.w700,
                            color: context.onSurface,
                          ),
                        ),
                      ),
                      if (member.role == FamilyRole.guest) ...[
                        SizedBox(width: 6.spMin),
                        _guestBadgeBuilder(context),
                      ],
                    ],
                  ),
                  SizedBox(height: 3.spMin),
                  Row(
                    children: [
                      Icon(
                        _subtitleIcon,
                        size: 13.spMin,
                        color: context.onSurfaceMuted,
                      ),
                      SizedBox(width: 4.spMin),
                      Flexible(
                        child: Text(
                          _subtitleText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5.spMin,
                            color: context.onSurfaceMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.spMin),
            // Ask, Request and the chip wrap onto a second line rather than
            // squeezing the name out at large text sizes; they never take
            // more than ~45% of the row.
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.45),
              child: Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6.spMin,
                runSpacing: 6.spMin,
                children: [
            if (onAskToCheckIn != null) ...[
              GestureDetector(
                onTap: onAskToCheckIn,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.spMin,
                    vertical: 7.spMin,
                  ),
                  decoration: BoxDecoration(
                    color: FamilyColors.indigo,
                    borderRadius: BorderRadius.circular(10.spMin),
                  ),
                  child: Text(
                    'Ask',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.spMin,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
            if (onRequestLocation != null) ...[
              GestureDetector(
                onTap: onRequestLocation,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.spMin,
                    vertical: 6.spMin,
                  ),
                  decoration: BoxDecoration(
                    color: FamilyColors.indigoLight,
                    borderRadius: BorderRadius.circular(10.spMin),
                  ),
                  child: Text(
                    'Request',
                    style: TextStyle(
                      color: FamilyColors.indigo,
                      fontSize: 11.spMin,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
            _statusChipBuilder(),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  IconData get _subtitleIcon {
    if (isNearAlert) return LucideIcons.triangleAlert;
    if (member.locationLabel != null) return LucideIcons.mapPin;
    return LucideIcons.clock;
  }

  String get _subtitleText => memberStatusLine(
        member: member,
        hasAnswered: hasAnswered,
        askedAt: askedAt,
        now: DateTime.now(),
      );

  /// Marks a guest so the circle can see at a glance who is along for the
  /// alerts only. Outlined, never a filled chip: it is not a status.
  Widget _guestBadgeBuilder(final BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 7.spMin,
        vertical: 1.spMin,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.spMin),
        border: Border.all(color: context.onSurfaceMuted.withValues(alpha: 0.5)),
      ),
      child: Text(
        'GUEST',
        style: TextStyle(
          fontSize: 9.spMin,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: context.onSurfaceMuted,
        ),
      ),
    );
  }

  Widget _statusChipBuilder() {
    final text = memberStatusChip(
      member: member,
      hasAnswered: hasAnswered,
      isNearAlert: isNearAlert,
    );
    final safe = text == 'Safe';
    final background = safe ? FamilyColors.safeGreenLight : FamilyColors.amberLight;
    final foreground = safe ? FamilyColors.safeGreen : FamilyColors.amber;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.spMin, vertical: 6.spMin),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20.spMin),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 12.spMin,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
