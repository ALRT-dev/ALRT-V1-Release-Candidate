import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_header_surface.dart';
import 'package:hazard_app/features/family/views/widgets/family_member_avatar.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';
import 'package:hazard_app/features/home/providers/home_tab_provider.dart';
import 'package:hazard_app/features/home/views/screens/home_screen.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

/// The roll call: who has answered a check-in request and who has not.
///
/// Asking the circle to check in used to produce a number and nothing else,
/// so the person who asked could not see who was still outstanding. This is
/// the answer, one row per member: their status, the snapshot they shared if
/// they shared one, and a tap through to their pin on the map.
///
/// It shows a snapshot, never a live position: a check-in shares one point
/// at the moment it is sent, and it expires on the usual hour.
class FamilyCheckInRollCallScreen extends ConsumerWidget {
  const FamilyCheckInRollCallScreen({super.key});

  static const route = '/family-check-in-roll-call';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circle = ref.watch(providerOfFamily.select((s) => s.circle));
    if (circle == null) return const SizedBox.shrink();

    final request = circle.latestCheckInRequest;
    final askedAt = request?.createdAt;

    // Answered means: checked in since the ask. With no ask on record, the
    // usual 24-hour "recently" window stands in.
    bool hasAnswered(final FamilyMember member) {
      final last = member.lastCheckInAt;
      if (last == null) return false;
      if (askedAt == null) return member.isCheckedInRecently;
      return last.isAfter(askedAt);
    }

    final members = [...circle.members]..sort((a, b) {
        final answeredA = hasAnswered(a);
        final answeredB = hasAnswered(b);
        // Waiting first: the point of this screen is who is outstanding.
        if (answeredA != answeredB) return answeredA ? 1 : -1;
        return a.name.compareTo(b.name);
      });

    final answered = members.where(hasAnswered).length;
    final waiting = members.length - answered;

    return Scaffold(
      backgroundColor: FamilyColors.v31Page,
      appBar: FamilyAppBar(
        title: 'Check-in',
        subtitle: waiting == 0
            ? 'Everyone has checked in'
            : '$answered of ${members.length} checked in',
      ),
      body: ListView(
        padding: EdgeInsets.all(20.spMin),
        children: [
          if (request != null) _askCardBuilder(request),
          if (request != null) SizedBox(height: 16.spMin),
          _labelBuilder(waiting == 0 ? 'EVERYONE' : 'WAITING ON $waiting'),
          SizedBox(height: 10.spMin),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.spMin),
            ),
            child: Column(
              children: [
                for (var i = 0; i < members.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: FamilyColors.v31Divider,
                      indent: 68.spMin,
                    ),
                  _memberRowBuilder(
                    context,
                    ref,
                    member: members[i],
                    hasAnswered: hasAnswered(members[i]),
                    isMe: members[i].id == circle.myMemberId,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 16.spMin),
          _noteBuilder(),
        ],
      ),
    );
  }

  Widget _labelBuilder(final String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.spMin,
        fontWeight: FontWeight.w700,
        color: FamilyColors.v31Label,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _askCardBuilder(final FamilyCheckInRequest request) {
    final who = request.requestedBy?.displayName ?? 'Someone';
    final when = request.createdAt;
    return Container(
      padding: EdgeInsets.all(14.spMin),
      decoration: BoxDecoration(
        color: FamilyColors.indigoLight,
        borderRadius: BorderRadius.circular(16.spMin),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.bellRing,
            size: 18.spMin,
            color: FamilyColors.indigo,
          ),
          SizedBox(width: 10.spMin),
          Expanded(
            child: Text(
              [
                '$who asked for a check-in',
                if (when != null) timeago.format(when),
              ].join(' · '),
              style: TextStyle(
                fontSize: 13.5.spMin,
                fontWeight: FontWeight.w600,
                color: FamilyColors.indigoDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _memberRowBuilder(
    final BuildContext context,
    final WidgetRef ref, {
    required final FamilyMember member,
    required final bool hasAnswered,
    required final bool isMe,
  }) {
    final last = member.lastCheckInAt;
    final subtitle = hasAnswered
        ? [
            'Checked in${last == null ? '' : ' ${timeago.format(last)}'}',
            if (member.locationLabel != null) 'near ${member.locationLabel}',
          ].join(' · ')
        : 'Waiting for their check-in';

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 14.spMin,
        vertical: 6.spMin,
      ),
      leading: FamilyMemberAvatar(member: member, size: 42),
      title: Text(
        isMe ? '${member.name} (you)' : member.name,
        style: TextStyle(fontSize: 15.spMin, fontWeight: FontWeight.w700),
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 3.spMin),
        child: Text(
          subtitle,
          style: TextStyle(fontSize: 12.5.spMin, color: FamilyColors.v31Ink),
        ),
      ),
      trailing: _trailingBuilder(
        context,
        ref,
        member: member,
        hasAnswered: hasAnswered,
        isMe: isMe,
      ),
      // Tapping anyone with a shared point drops you on their pin.
      onTap: member.hasLiveLocation
          ? () => _showOnMap(context, ref, member)
          : null,
    );
  }

  Widget _trailingBuilder(
    final BuildContext context,
    final WidgetRef ref, {
    required final FamilyMember member,
    required final bool hasAnswered,
    required final bool isMe,
  }) {
    if (member.hasLiveLocation) {
      return Icon(
        LucideIcons.mapPin,
        size: 20.spMin,
        color: FamilyColors.indigo,
      );
    }
    if (hasAnswered || isMe) {
      return Icon(
        hasAnswered ? Icons.check_circle : Icons.circle_outlined,
        size: 20.spMin,
        color: hasAnswered ? FamilyColors.safeGreen : FamilyColors.v31Border,
      );
    }
    // No point shared and still waiting: the one thing worth offering is
    // asking them directly, which is a request they can decline.
    return TextButton(
      onPressed: () async {
        final sent = await ref
            .read(providerOfFamily.notifier)
            .requestMemberLocation(memberId: member.id);
        if (!context.mounted) return;
        sent
            ? context.showSuccessToast(
                message: '${member.name} was asked to share where they are.',
              )
            : context.showErrorToast(
                message: 'Could not send the request. Try again.',
              );
      },
      child: Text(
        'Ask',
        style: TextStyle(
          fontSize: 13.spMin,
          fontWeight: FontWeight.w700,
          color: FamilyColors.indigo,
        ),
      ),
    );
  }

  /// Leaves the family stack, switches to the map and centres on the member.
  void _showOnMap(
    final BuildContext context,
    final WidgetRef ref,
    final FamilyMember member,
  ) {
    ref.read(providerOfHomeTab.notifier).state = HomeTab.map;
    ref
        .read(providerOfMap.notifier)
        .focusOnPosition(
          position: LatLng(member.latitude!, member.longitude!),
        );
    context.go(HomeScreen.route, extra: HomeScreenArgs(initialTab: HomeTab.map));
  }

  Widget _noteBuilder() {
    return Container(
      padding: EdgeInsets.all(12.spMin),
      decoration: BoxDecoration(
        color: FamilyColors.v31NoteBackground,
        borderRadius: BorderRadius.circular(14.spMin),
        border: Border.all(color: FamilyColors.v31NoteBorder),
      ),
      child: Text(
        'A check-in shares one point at the moment it is sent, and it '
        'expires after an hour. Nobody is being tracked between check-ins.',
        style: TextStyle(
          fontSize: 12.5.spMin,
          height: 1.4,
          color: FamilyColors.v31NoteInk,
        ),
      ),
    );
  }
}
