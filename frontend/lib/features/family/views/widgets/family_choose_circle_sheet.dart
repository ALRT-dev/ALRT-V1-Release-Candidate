import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/utils/family_hub_labels.dart';
import 'package:hazard_app/features/family/utils/group_state.dart';
import 'package:hazard_app/features/family/views/screens/family_invite_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_switch_group_screen.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_group_actions.dart';
import 'package:hazard_app/features/family/views/widgets/family_group_avatar.dart';
import 'package:hazard_app/others/app_surface_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// "Choose a circle": the one place to switch, add people, join or create,
/// opened from the circle name in the hub header (approved design). It
/// replaces the strip of circle tiles and the header buttons, so the hub
/// itself stays calm.
///
/// Every row goes to a real flow: switching rescopes the family tab,
/// "Add a person" is the host's invite screen (invites spend the host's
/// seats, so only the host of the OPEN circle sees it), "Join with code"
/// and "Create another circle" are the existing sheets (creating is
/// ALRT+-gated inside showCreateGroupSheet, joining never is).
Future<void> showChooseCircleSheet(
  final BuildContext context,
  final WidgetRef ref,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.surfaceCard,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.spMin)),
    ),
    builder: (sheetContext) => const _ChooseCircleSheet(),
  );
}

class _ChooseCircleSheet extends ConsumerWidget {
  const _ChooseCircleSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circles = ref.watch(providerOfFamily.select((s) => s.circles));
    final open = ref.watch(providerOfFamily.select((s) => s.circle));
    final activeSos = ref.watch(
      providerOfFamily.select((s) => s.activeSosEvents),
    );
    final isHostOfOpen = open?.me?.role == FamilyRole.owner;
    final seatsUsed = seatsUsedAcrossHostedCircles(circles);
    final media = MediaQuery.of(context);
    final bottom = media.viewInsets.bottom > media.viewPadding.bottom
        ? media.viewInsets.bottom
        : media.viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.spMin, 10.spMin, 16.spMin, bottom + 16.spMin),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36.spMin,
              height: 4.spMin,
              decoration: BoxDecoration(
                color: context.outline,
                borderRadius: BorderRadius.circular(2.spMin),
              ),
            ),
          ),
          SizedBox(height: 12.spMin),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Choose a circle',
                  style: TextStyle(
                    fontSize: 18.spMin,
                    fontWeight: FontWeight.w800,
                    color: context.onSurface,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(LucideIcons.x, size: 20.spMin, color: context.onSurfaceMuted),
              ),
            ],
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final summary in circles) ...[
                    _circleRowBuilder(
                      context,
                      ref,
                      summary,
                      isSelected: summary.circleId == open?.id,
                      state: groupStateOf(
                        summary,
                        openCircle: open,
                        activeSosEvents: activeSos,
                      ),
                    ),
                    SizedBox(height: 8.spMin),
                  ],
                  if (circles.any((c) => c.isOwned)) ...[
                    _membershipCardBuilder(context, seatsUsed),
                    SizedBox(height: 8.spMin),
                  ],
                  if (isHostOfOpen)
                    _actionRowBuilder(
                      context,
                      icon: LucideIcons.userPlus,
                      label: 'Add a person',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push(FamilyInviteScreen.route);
                      },
                    ),
                  _actionRowBuilder(
                    context,
                    icon: LucideIcons.qrCode,
                    label: 'Join with code',
                    onTap: () {
                      Navigator.of(context).pop();
                      showJoinGroupSheet(context, ref);
                    },
                  ),
                  SizedBox(height: 6.spMin),
                  SizedBox(
                    height: 48.spMin,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FamilyColors.indigoDark,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.spMin),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        showCreateGroupSheet(context, ref);
                      },
                      icon: Icon(LucideIcons.plus, size: 18.spMin),
                      label: Text(
                        'Create another circle',
                        style: TextStyle(fontSize: 14.spMin, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push(FamilySwitchGroupScreen.route);
                    },
                    child: Text(
                      'Manage all circles',
                      style: TextStyle(
                        fontSize: 12.5.spMin,
                        fontWeight: FontWeight.w700,
                        color: FamilyColors.indigo,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleRowBuilder(
    final BuildContext context,
    final WidgetRef ref,
    final FamilyCircleSummary summary, {
    required final bool isSelected,
    required final GroupState state,
  }) {
    final attention = state.kind == GroupStateKind.sos ||
        state.kind == GroupStateKind.waiting;
    final subtitle = summary.isOwned
        ? '${summary.seatCount} ${summary.seatCount == 1 ? 'seat' : 'seats'} · you host'
        : '${summary.memberCount} ${summary.memberCount == 1 ? 'person' : 'people'} · joined';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        ref.read(providerOfFamily.notifier).selectCircle(summary.circleId);
        Navigator.of(context).pop();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.spMin, vertical: 12.spMin),
        decoration: BoxDecoration(
          color: context.surfaceCard,
          borderRadius: BorderRadius.circular(14.spMin),
          border: Border.all(
            color: isSelected
                ? FamilyColors.indigoDark
                : (state.kind == GroupStateKind.sos
                    ? FamilyColors.sosRed
                    : (attention ? FamilyColors.amber : context.outline)),
            width: isSelected || attention ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            FamilyGroupAvatar(
              name: summary.name,
              photoUrl: summary.photoUrl,
              themeColorHex: summary.themeColor,
              size: 40.spMin,
            ),
            SizedBox(width: 12.spMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          summary.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.spMin,
                            fontWeight: FontWeight.w800,
                            color: context.onSurface,
                          ),
                        ),
                      ),
                      if (summary.isOwned) ...[
                        SizedBox(width: 6.spMin),
                        Icon(LucideIcons.crown, size: 13.spMin, color: context.onSurfaceMuted),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.spMin),
                  Text(
                    attention ? state.label : subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.spMin,
                      fontWeight: attention ? FontWeight.w700 : FontWeight.w500,
                      color: state.kind == GroupStateKind.sos
                          ? FamilyColors.sosRed
                          : (attention ? FamilyColors.amber : context.onSurfaceMuted),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.spMin),
            if (isSelected)
              Container(
                width: 22.spMin,
                height: 22.spMin,
                decoration: const BoxDecoration(
                  color: FamilyColors.indigoDark,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, size: 14.spMin, color: Colors.white),
              )
            else
              Icon(Icons.chevron_right, size: 20.spMin, color: context.onSurfaceMuted),
          ],
        ),
      ),
    );
  }

  Widget _membershipCardBuilder(final BuildContext context, final int seatsUsed) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.spMin, vertical: 12.spMin),
      decoration: BoxDecoration(
        color: FamilyColors.indigoLight,
        borderRadius: BorderRadius.circular(14.spMin),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.users, size: 18.spMin, color: FamilyColors.indigoDark),
          SizedBox(width: 10.spMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Circle membership',
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w800,
                    color: FamilyColors.indigoDark,
                  ),
                ),
                Text(
                  'Seats across the circles you host',
                  style: TextStyle(fontSize: 12.spMin, color: FamilyColors.v31Ink),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.spMin, vertical: 5.spMin),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.spMin),
            ),
            child: Text(
              '$seatsUsed of $kFamilyMaxSeats seats',
              style: TextStyle(
                fontSize: 12.spMin,
                fontWeight: FontWeight.w800,
                color: FamilyColors.indigoDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionRowBuilder(
    final BuildContext context, {
    required final IconData icon,
    required final String label,
    required final VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.spMin),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 13.spMin),
          decoration: BoxDecoration(
            color: context.surfaceCard,
            borderRadius: BorderRadius.circular(14.spMin),
            border: Border.all(color: context.outline),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18.spMin, color: context.onSurface),
              SizedBox(width: 12.spMin),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w800,
                    color: context.onSurface,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 20.spMin, color: context.onSurfaceMuted),
            ],
          ),
        ),
      ),
    );
  }
}
