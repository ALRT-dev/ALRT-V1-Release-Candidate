import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_member_avatar.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

/// A member row for the family hub: avatar, name, location/check-in context
/// and a Safe / Near alert chip.
class FamilyMemberListItem extends StatelessWidget {
  const FamilyMemberListItem({
    super.key,
    required this.member,
    required this.isMe,
    this.isNearAlert = false,
    this.onLongPress,
    this.onRequestLocation,
    this.hasAnswered,
    this.askedAt,
    this.onAskToCheckIn,
  });

  final FamilyMember member;
  final bool isMe;
  final bool isNearAlert;
  final VoidCallback? onLongPress;

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
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 12.spMin),
        child: Row(
          children: [
            FamilyMemberAvatar(member: member, isNearAlert: isNearAlert),
            SizedBox(width: 12.spMin),
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
                            fontSize: 15.spMin,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      if (member.role == FamilyRole.guest) ...[
                        SizedBox(width: 6.spMin),
                        _guestBadgeBuilder(),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.spMin),
                  Row(
                    children: [
                      Icon(
                        _subtitleIcon,
                        size: 12.spMin,
                        color: AppColors.grey,
                      ),
                      SizedBox(width: 4.spMin),
                      Flexible(
                        child: Text(
                          _subtitleText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.spMin,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.spMin),
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
              SizedBox(width: 6.spMin),
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
              SizedBox(width: 6.spMin),
            ],
            _statusChipBuilder(),
          ],
        ),
      ),
    );
  }

  IconData get _subtitleIcon {
    if (isNearAlert) return LucideIcons.triangleAlert;
    if (member.locationLabel != null) return LucideIcons.mapPin;
    return LucideIcons.clock;
  }

  String get _subtitleText {
    // An unanswered ask is the most important thing to say about a row.
    final asked = askedAt;
    if (asked != null && hasAnswered == false) {
      final last = member.lastCheckInAt;
      final lastLabel = last == null
          ? 'no check-in yet'
          : 'last check-in ${timeago.format(last)}';
      return 'Asked ${timeago.format(asked)} · $lastLabel';
    }
    final label = member.locationLabel;
    final sharedAt = member.locationUpdatedAt;
    final expiresAt = member.locationExpiresAt;
    if (label != null && label.isNotEmpty) {
      // Snapshots are explicit shares — say when it was shared, and when it
      // expires, both honestly.
      final expiryLabel = expiresAt != null && expiresAt.isAfter(DateTime.now())
          ? ' · expires ${timeago.format(expiresAt, allowFromNow: true)}'
          : '';
      return sharedAt != null
          ? '$label · shared ${timeago.format(sharedAt)}$expiryLabel'
          : '$label$expiryLabel';
    }
    if (member.sharingLevel == FamilySharingLevel.off ||
        member.sharingLevel == FamilySharingLevel.alertsOnly) {
      return 'Location hidden';
    }
    final lastCheckIn = member.lastCheckInAt;
    if (lastCheckIn != null) {
      return 'Checked in ${timeago.format(lastCheckIn)}';
    }
    return 'No snapshot yet';
  }

  /// Marks a guest so the circle can see at a glance who is along for the
  /// alerts only. Outlined, never a filled chip: it is not a status.
  Widget _guestBadgeBuilder() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 7.spMin,
        vertical: 1.spMin,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.spMin),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.5)),
      ),
      child: Text(
        'GUEST',
        style: TextStyle(
          fontSize: 9.spMin,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: AppColors.grey,
        ),
      ),
    );
  }

  Widget _statusChipBuilder() {
    final String text;
    final Color background;
    final Color foreground;

    if (isNearAlert) {
      text = 'Near';
      background = FamilyColors.amberLight;
      foreground = FamilyColors.amber;
    } else if (hasAnswered ?? member.isCheckedInRecently) {
      text = 'Safe';
      background = FamilyColors.safeGreenLight;
      foreground = FamilyColors.safeGreen;
    } else {
      text = 'Not yet';
      background = FamilyColors.amberLight;
      foreground = FamilyColors.amber;
    }

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
