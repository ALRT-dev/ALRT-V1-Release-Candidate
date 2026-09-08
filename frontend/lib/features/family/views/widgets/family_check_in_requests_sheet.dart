import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_group_avatar.dart';
import 'package:hazard_app/features/family/views/widgets/family_member_avatar.dart';
import 'package:hazard_app/others/app_surface_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

/// "Check-in requests": every open ask I owe in this circle, by name and
/// time, the other circles with asks waiting, and one button that answers
/// them all. Opens from "View N requests" on the hub's check-in card.
///
/// One tap answers every ask here because a check-in after the newest ask
/// counts against all the older ones; the location choice still comes on
/// the consent sheet, after this one (locked rule: nothing leaves the
/// phone until the owner chooses).
Future<void> showCheckInRequestsSheet(
  final BuildContext context, {
  required final Future<void> Function() onCheckIn,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    // Light barrier, as on the map filters: the hub stays readable behind.
    barrierColor: Colors.black.withValues(alpha: 0.25),
    builder: (_) => _CheckInRequestsSheet(onCheckIn: onCheckIn),
  );
}

class _CheckInRequestsSheet extends ConsumerWidget {
  const _CheckInRequestsSheet({required this.onCheckIn});

  final Future<void> Function() onCheckIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(providerOfFamily);
    final circle = state.circle;
    if (circle == null) return const SizedBox.shrink();
    final asks = circle.checkInRequestsOwedByMe;
    final others = state.circles
        .where(
          (c) => c.circleId != circle.id && c.pendingCheckInRequests > 0,
        )
        .toList();
    final bottom = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceScaffold,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
      ),
      padding: EdgeInsets.fromLTRB(20.spMin, 10.spMin, 20.spMin, 16.spMin + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40.spMin,
              height: 4.spMin,
              decoration: BoxDecoration(
                color: context.outline,
                borderRadius: BorderRadius.circular(2.spMin),
              ),
            ),
          ),
          SizedBox(height: 14.spMin),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Check-in requests',
                  style: TextStyle(
                    fontSize: 22.spMin,
                    fontWeight: FontWeight.w800,
                    color: context.onSurface,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(LucideIcons.x, size: 22.spMin, color: context.onSurface),
                tooltip: 'Close',
              ),
            ],
          ),
          Text(
            '${circle.name} · ${asks.length} ${asks.length == 1 ? 'request' : 'requests'}',
            style: TextStyle(
              fontSize: 14.spMin,
              fontWeight: FontWeight.w700,
              color: context.onSurface,
            ),
          ),
          SizedBox(height: 12.spMin),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                if (asks.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.spMin),
                    child: Text(
                      'Nobody is waiting on you right now.',
                      style: TextStyle(
                        fontSize: 13.spMin,
                        color: context.onSurfaceMuted,
                      ),
                    ),
                  ),
                for (final ask in asks) _askRowBuilder(context, circle, ask),
                if (others.isNotEmpty) ...[
                  SizedBox(height: 12.spMin),
                  _otherCirclesBuilder(context, ref, others),
                ],
              ],
            ),
          ),
          SizedBox(height: 14.spMin),
          Text(
            'Choose whether to share a location in the next step.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.spMin, color: context.onSurfaceMuted),
          ),
          SizedBox(height: 10.spMin),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [FamilyColors.safeBright, FamilyColors.safeBrightDeep],
              ),
              borderRadius: BorderRadius.circular(16.spMin),
            ),
            child: SizedBox(
              height: 50.spMin,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: FamilyColors.safeInk,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.spMin),
                  ),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await onCheckIn();
                },
                icon: Icon(Icons.check_circle_rounded, size: 20.spMin),
                label: Text(
                  'Check in to ${circle.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15.spMin, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// One asker: their face, name, and how long ago they asked. A message
  /// on the ask shows under the time.
  Widget _askRowBuilder(
    final BuildContext context,
    final FamilyCircle circle,
    final FamilyCheckInRequest ask,
  ) {
    final member = circle.members
        .where((m) => m.id == ask.requestedById)
        .firstOrNull;
    final name = member?.name ?? ask.requestedBy?.displayName ?? 'Someone';
    final when = ask.createdAt == null ? null : timeago.format(ask.createdAt!);
    final message = ask.message;
    return Container(
      margin: EdgeInsets.only(bottom: 8.spMin),
      padding: EdgeInsets.symmetric(horizontal: 12.spMin, vertical: 10.spMin),
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: BorderRadius.circular(14.spMin),
        border: Border.all(color: context.outline),
      ),
      child: Row(
        children: [
          if (member != null)
            FamilyMemberAvatar(member: member, size: 40.spMin, showStatusDot: false)
          else
            Container(
              width: 40.spMin,
              height: 40.spMin,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: FamilyColors.indigoLight,
                shape: BoxShape.circle,
              ),
              child: Text(
                name.isEmpty ? '?' : name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 16.spMin,
                  fontWeight: FontWeight.w800,
                  color: FamilyColors.indigo,
                ),
              ),
            ),
          SizedBox(width: 12.spMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w800,
                    color: context.onSurface,
                  ),
                ),
                if (when != null)
                  Text(
                    when,
                    style: TextStyle(fontSize: 12.spMin, color: context.onSurfaceMuted),
                  ),
                if (message != null && message.isNotEmpty)
                  Text(
                    '"$message"',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5.spMin,
                      fontStyle: FontStyle.italic,
                      color: context.onSurface,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Circles that are not open but have asks waiting on me, each with a
  /// "Switch circle" link; answering there is a separate tap, on purpose,
  /// because a check-in goes to one circle when it answers an ask.
  Widget _otherCirclesBuilder(
    final BuildContext context,
    final WidgetRef ref,
    final List<FamilyCircleSummary> others,
  ) {
    return Container(
      padding: EdgeInsets.all(12.spMin),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? context.surfaceCard
            : FamilyColors.indigoLight,
        borderRadius: BorderRadius.circular(14.spMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Other circles',
            style: TextStyle(
              fontSize: 14.spMin,
              fontWeight: FontWeight.w800,
              color: context.onSurface,
            ),
          ),
          SizedBox(height: 8.spMin),
          for (final summary in others)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                ref.read(providerOfFamily.notifier).selectCircle(summary.circleId);
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6.spMin),
                child: Row(
                  children: [
                    FamilyGroupAvatar(
                      name: summary.name,
                      photoUrl: summary.photoUrl,
                      themeColorHex: summary.themeColor,
                      size: 36.spMin,
                    ),
                    SizedBox(width: 10.spMin),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            summary.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.spMin,
                              fontWeight: FontWeight.w800,
                              color: context.onSurface,
                            ),
                          ),
                          Text(
                            '${summary.pendingCheckInRequests} '
                            '${summary.pendingCheckInRequests == 1 ? 'request' : 'requests'}',
                            style: TextStyle(
                              fontSize: 12.spMin,
                              color: context.onSurfaceMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Switch circle',
                      style: TextStyle(
                        fontSize: 13.spMin,
                        fontWeight: FontWeight.w700,
                        color: FamilyColors.indigo,
                      ),
                    ),
                    Icon(LucideIcons.chevronRight, size: 16.spMin, color: FamilyColors.indigo),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
