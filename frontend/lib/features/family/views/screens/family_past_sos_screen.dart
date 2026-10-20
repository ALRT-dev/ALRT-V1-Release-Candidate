import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/utils/family_sos_authorization.dart';
import 'package:hazard_app/features/family/utils/sos_record.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_resolved_screen.dart';
import 'package:hazard_app/features/family/views/widgets/family_app_bar.dart';
import 'package:hazard_app/features/family/views/widgets/family_board_widgets.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Past SOS (approved PastSOS board): the retained SOS history of the last
/// 30 days. Time and duration only, never where: the server keeps no
/// locations for these. Each row opens the after-event record.
///
/// Pushed with a plain page route from the hub's More card, so no shared
/// router entry is needed.
class FamilyPastSosScreen extends ConsumerWidget {
  const FamilyPastSosScreen({super.key});

  /// Opens this screen over the current one.
  static Future<void> open(final BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const FamilyPastSosScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circle = ref.watch(providerOfFamily.select((s) => s.circle));
    final history = ref.watch(providerOfFamily.select((s) => s.sosHistory));

    return Scaffold(
      backgroundColor: kFamilyBoardPage,
      appBar: const FamilyWhiteAppBar(title: 'Past SOS'),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.spMin, 4.spMin, 16.spMin, 120.spMin),
        children: [
          const FamilyBoardMuted(
            'Last 30 days. Time and duration only, never where.',
            size: 14,
          ),
          SizedBox(height: 14.spMin),
          if (history.isEmpty)
            const FamilyBoardCard(
              children: [FamilyBoardMuted('No SOS in the last 30 days.')],
            )
          else
            for (final sos in history) ...[
              _rowBuilder(context, ref, circle, sos),
              SizedBox(height: 10.spMin),
            ],
        ],
      ),
    );
  }

  Widget _rowBuilder(
    final BuildContext context,
    final WidgetRef ref,
    final FamilyCircle? circle,
    final FamilySosEvent sos,
  ) {
    final myUserId = ref.read(providerOfLoggedInUser)?.id;
    final isMine = isSosMine(
      sos,
      myMemberId: circle?.myMemberId,
      myUserId: myUserId,
    );
    final who = isMine ? 'You' : sosSenderName(sos);
    final started = sos.createdAt;
    final ended = sos.resolvedAt;
    final when = [
      if (started != null)
        DateFormat('d MMM yyyy, h:mm a').format(started.toLocal()),
      if (started != null && ended != null)
        sosDurationLabel(ended.difference(started)),
    ].join(' · ');
    // Who saw it, by name: never a bare count (locked rule 3 Sep 2026).
    final seen = sos.responses
        .where((r) => r.type == FamilySosResponseType.seen)
        .map((r) => r.member?.displayName ?? 'A family member')
        .toList();
    final seenLine = seen.isEmpty
        ? 'Nobody acknowledged it'
        : 'Seen by ${sosRecordNames(seen)}';

    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // Its stored audience, by name: never the group's size today.
          final audience = circle == null
              ? null
              : sosAudienceNames(
                  sos,
                  members: circle.members,
                  myUserId: myUserId,
                );
          context.push(
            FamilySosResolvedScreen.route,
            extra: FamilySosResolvedScreenArgs(
              event: sos,
              circleName: circle?.name,
              audienceNames: audience?.names,
              unnamedAudienceCount: audience?.unnamed ?? 0,
            ),
          );
        },
        child: FamilyBoardCard(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        who,
                        style: TextStyle(
                          fontSize: 15.spMin,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      SizedBox(height: 2.spMin),
                      if (when.isNotEmpty) FamilyBoardMuted(when, size: 12),
                      FamilyBoardMuted(seenLine, size: 12),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: 20.spMin,
                  color: AppColors.mediumGrey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
