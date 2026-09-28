import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/views/screens/family_invite_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_list_edit_screen.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/utils/access_refusal.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_group_paywall_screen.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_paywall_screen.dart';
import 'package:hazard_app/features/subscription/views/widgets/paywall_parts.dart';
import 'package:hazard_app/features/subscription/views/widgets/plan_identity.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows [error] the right way: a coded access refusal gets its own sheet
/// with the one or two actions that actually help; anything else stays a
/// toast with the server's message. Returns true when a sheet was shown.
Future<bool> showFamilyActionError(
  final BuildContext context,
  final WidgetRef ref,
  final AppError error, {
  final String? circleId,
}) async {
  final refusal = AccessRefusal.fromError(error);
  if (refusal == null) {
    context.showErrorToast(message: error.message);
    return false;
  }
  await showAccessRefusalSheet(context, ref, refusal, circleId: circleId);
  return true;
}

Future<void> showAccessRefusalSheet(
  final BuildContext context,
  final WidgetRef ref,
  final AccessRefusal refusal, {
  final String? circleId,
}) async {
  final id = refusal.circleId ?? circleId;
  final access = await ref
      .read(providerOfAccess.future)
      .catchError((_) => null);
  final group = id == null ? null : access?.groupById(id);
  final p = refusalPresentation(refusal, group: group);
  if (!context.mounted) return;
  final action = await showModalBottomSheet<RefusalAction>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _RefusalSheet(presentation: p),
  );
  if (action == null || !context.mounted) return;
  switch (action) {
    case RefusalAction.seeAlrtPlus:
      await context.push(
        AlrtPlusPaywallScreen.route,
        extra: AlrtPlusPaywallArgs(
          reason: refusal.kind == AccessRefusalKind.savedPlaceLimit
              ? AlrtPlusPaywallReason.savedLocation
              : AlrtPlusPaywallReason.individualGroup,
        ),
      );
    case RefusalAction.coverGroup:
      await context.push(
        AlrtPlusGroupPaywallScreen.route,
        extra: AlrtPlusGroupPaywallArgs(circleId: id),
      );
    case RefusalAction.upgradeGroup:
      await context.push(
        AlrtPlusGroupPaywallScreen.route,
        extra: AlrtPlusGroupPaywallArgs(
          circleId: id,
          tier: group?.sponsorship?.upgradeTier,
        ),
      );
    case RefusalAction.renewInStore:
      final url = await ref.read(providerOfRevenueCat).managementUrl();
      if (url != null) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else if (context.mounted) {
        context.showErrorToast(
          message: 'Open your app store\'s subscriptions to renew it.',
        );
      }
    case RefusalAction.inviteSomeone:
      await context.push(FamilyInviteScreen.route);
    case RefusalAction.editSosList:
      await context.push(FamilySosListEditScreen.route);
  }
}

class _RefusalSheet extends StatelessWidget {
  const _RefusalSheet({required this.presentation});

  final RefusalPresentation presentation;

  @override
  Widget build(BuildContext context) {
    final p = presentation;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
      ),
      padding: EdgeInsets.fromLTRB(22.spMin, 14.spMin, 22.spMin, 16.spMin),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 38.spMin,
                height: 4.spMin,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3DFEA),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 18.spMin),
            Text(
              p.title,
              style: TextStyle(
                fontSize: 18.spMin,
                fontWeight: FontWeight.w800,
                color: kPaywallInk,
              ),
            ),
            SizedBox(height: 8.spMin),
            Text(
              p.body,
              style: TextStyle(
                fontSize: 14.spMin,
                height: 1.5,
                color: kPaywallInkSoft,
              ),
            ),
            SizedBox(height: 20.spMin),
            if (p.primary != null)
              PlanCta(
                label: p.primaryLabel!,
                identity: _identityFor(p.primary!),
                onPressed: () => Navigator.of(context).pop(p.primary),
              ),
            if (p.secondary != null) ...[
              SizedBox(height: 8.spMin),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(p.secondary),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.spMin),
                  shape: const StadiumBorder(),
                ),
                child: Text(p.secondaryLabel!),
              ),
            ],
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(p.primary == null ? 'OK' : 'Not now'),
            ),
          ],
        ),
      ),
    );
  }

  PlanIdentity _identityFor(final RefusalAction action) => switch (action) {
    RefusalAction.seeAlrtPlus => PlanIdentity.individual,
    RefusalAction.coverGroup ||
    RefusalAction.upgradeGroup ||
    RefusalAction.renewInStore => PlanIdentity.group,
    RefusalAction.inviteSomeone ||
    RefusalAction.editSosList => const PlanIdentity(
      name: '',
      accent: Color(0xFF3D3DDF),
      tint: Color(0xFFF0EEF5),
      darkAccent: Color(0xFFA5A5FF),
      gradient: [Color(0xFF3D3DDF), Color(0xFF3D3DDF)],
    ),
  };
}
