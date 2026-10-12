import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/utils/sos_record.dart';
import 'package:hazard_app/features/family/utils/sos_timing.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_member_avatar.dart';
import 'package:hazard_app/others/app_surface_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A member row for the family hub (approved Family board, 12 Oct 2026):
/// a 40 px initial avatar in the member's colour, "<Name> (you) · host",
/// one factual state line, and one pill or button on the right.
///
/// The pill is factual only: "Checked in", "Waiting" ONLY while an ask is
/// open for this person, red "SOS" while theirs is live, or a "Check on"
/// button for someone nobody has asked. Not checking in is silence, never
/// danger, so it is never painted as a warning.
class FamilyMemberListItem extends StatelessWidget {
  const FamilyMemberListItem({
    super.key,
    required this.member,
    required this.isMe,
    this.isNearAlert = false,
    this.onTap,
    this.hasAnswered,
    this.askedAt,
    this.liveSos,
    this.onAskToCheckIn,
    this.ringColor,
  });

  final FamilyMember member;
  final bool isMe;
  final bool isNearAlert;

  /// Opens the member's details (status, and every action the tapper may
  /// take on them). Visible actions, never long-press-only.
  final VoidCallback? onTap;

  /// This member's state on the current CheckInRoll: true checked in,
  /// false asked and still unanswered, null nothing asked of them (the
  /// plain reading applies).
  final bool? hasAnswered;

  /// When [hasAnswered] is false, the time the open ask was sent.
  final DateTime? askedAt;

  /// This member's running SOS, when they have one. Drives the red ring,
  /// the "SOS live" line and the red pill.
  final FamilySosEvent? liveSos;

  /// Optional ring drawn around the avatar for state emphasis: teal when
  /// a check-in is asked of this member, red while an SOS is live.
  final Color? ringColor;

  /// "Check on" for a row nobody has asked yet: asks THIS person only.
  final VoidCallback? onAskToCheckIn;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 12.spMin),
        child: Row(
          children: [
            FamilyMemberAvatar(
              member: member,
              size: 40.0,
              showStatusDot: false,
              isNearAlert: isNearAlert,
              ringColor: ringColor,
            ),
            SizedBox(width: 12.spMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _nameLine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w700,
                      color: context.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.spMin),
                  Text(
                    _stateLine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5.spMin,
                      color: liveSos != null
                          ? FamilyColors.sosRed
                          : context.onSurfaceMuted,
                      fontWeight: liveSos != null
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.spMin),
            _trailingBuilder(context),
          ],
        ),
      ),
    );
  }

  /// "Sarah (you) · host", "Tom · host", "Amy", "Ben · guest".
  String get _nameLine {
    final parts = <String>[
      isMe ? '${member.name} (you)' : member.name,
      if (member.role == FamilyRole.owner) 'host',
      if (member.role == FamilyRole.guest) 'guest',
    ];
    return parts.join(' · ');
  }

  /// The one factual line under the name, in priority order: a live SOS,
  /// an open ask, a check-in today, or "Not checked in today".
  String get _stateLine {
    final sos = liveSos;
    if (sos != null) return 'SOS live · ${_sosLocationLine(sos)}';
    if (hasAnswered == false && askedAt != null) {
      return 'Asked to check in ${sosClock(askedAt!)}';
    }
    final last = member.lastCheckInAt;
    if (hasAnswered == true && last != null) {
      return 'Checked in ${sosClock(last)}';
    }
    if (isNearAlert) return 'Near an active alert · not checked in today';
    return 'Not checked in today';
  }

  /// What the sender chose to share with their SOS, read from the event.
  static String _sosLocationLine(final FamilySosEvent sos) {
    final suburbOnly = sos.locationPrecision == 'approximate';
    final what = suburbOnly ? 'suburb' : 'exact location';
    return switch (sosRecordLocationMode(sos)) {
      'once' => '$what shared once',
      'live' => '$what shared live',
      _ => 'no location shared',
    };
  }

  Widget _trailingBuilder(final BuildContext context) {
    if (liveSos != null) {
      return _pillBuilder(
        'SOS',
        background: FamilyColors.sosRed,
        foreground: Colors.white,
      );
    }
    if (hasAnswered == true) {
      return _pillBuilder(
        'Checked in',
        background: FamilyColors.checkedInWash,
        foreground: FamilyColors.checkedInInk,
      );
    }
    // "Waiting" only while a real ask is open for this person; the hub
    // passes false here only in that case (CheckInRoll.isAskedOf).
    if (hasAnswered == false && askedAt != null) {
      return _pillBuilder(
        'Waiting',
        background: const Color(0xFFE6F7F5),
        foreground: FamilyColors.teal,
      );
    }
    if (isNearAlert) {
      return _pillBuilder(
        'Near',
        background: FamilyColors.amberLight,
        foreground: FamilyColors.amber,
      );
    }
    final onAsk = onAskToCheckIn;
    if (onAsk != null) {
      return TextButton(
        style: TextButton.styleFrom(
          foregroundColor: FamilyColors.indigo,
          padding: EdgeInsets.symmetric(horizontal: 10.spMin),
          minimumSize: Size(0, 34.spMin),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.spMin),
          ),
        ),
        onPressed: onAsk,
        child: Text(
          'Check on',
          style: TextStyle(fontSize: 13.spMin, fontWeight: FontWeight.w700),
        ),
      );
    }
    return Icon(
      LucideIcons.chevronRight,
      size: 18.spMin,
      color: context.onSurfaceMuted,
    );
  }

  Widget _pillBuilder(
    final String text, {
    required final Color background,
    required final Color foreground,
  }) {
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
