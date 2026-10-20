import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/utils/sos_record.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_member_avatar.dart';
import 'package:hazard_app/others/app_surface_colors.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A member row for the family hub (approved Family board, 12 Oct 2026):
/// a 40 px initial avatar in the member's colour, "`<Name>` (you) · host",
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
  /// an open ask, a check-in today, or "No check-in asked" (ruling 9 Oct
  /// 2026: until someone asks, nothing is waiting on anyone).
  String get _stateLine {
    final sos = liveSos;
    if (sos != null) return 'SOS live · ${_sosLocationLine(sos)}';
    if (hasAnswered == false && askedAt != null) {
      return 'Asked to check in ${_clock(askedAt!)}';
    }
    final last = member.lastCheckInAt;
    if (hasAnswered == true && last != null) {
      return 'Checked in ${_clock(last)}';
    }
    if (isNearAlert) return 'Near an active alert · no check-in asked';
    return 'No check-in asked';
  }

  /// "12:04 PM", in the phone's local time (the boards' clock).
  static String _clock(final DateTime at) =>
      DateFormat('h:mm a').format(at.toLocal());

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
        background: const Color(0xFFFDE8EA),
        foreground: const Color(0xFFB3141F),
      );
    }
    if (hasAnswered == true) {
      return _pillBuilder(
        'Checked in',
        background: const Color(0xFFE6F6EC),
        foreground: FamilyColors.checkedInInk,
      );
    }
    // "Waiting" only while a real ask is open for this person; the hub
    // passes false here only in that case (CheckInRoll.isAskedOf).
    if (hasAnswered == false && askedAt != null) {
      return _pillBuilder(
        'Waiting',
        background: const Color(0x1F0D9488),
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
      // The boards' indigo "Check on" pill: asks THIS person only.
      return Semantics(
        button: true,
        label: 'Check on ${member.name}',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onAsk,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 6.spMin),
            child: _pillBuilder(
              'Check on',
              background: const Color(0xFFEEEEFB),
              foreground: FamilyColors.indigo,
            ),
          ),
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
      height: 26.spMin,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 10.spMin),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(13.spMin),
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
