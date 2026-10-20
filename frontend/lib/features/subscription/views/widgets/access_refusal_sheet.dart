import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/views/screens/family_invite_screen.dart';
import 'package:collection/collection.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_list_edit_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_lists_screen.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/repositories/access_repository.dart';
import 'package:hazard_app/features/subscription/utils/access_refusal.dart';
import 'package:hazard_app/features/subscription/utils/store_management.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_group_paywall_screen.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_paywall_screen.dart';

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
  final p = refusalPresentation(
    refusal,
    group: group,
    hasIndividual: access?.personal.isIndividual ?? false,
  );
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
      final opened = await openSubscriptionManagement(
        ref.read(providerOfRevenueCat),
      );
      if (!opened && context.mounted) {
        context.showErrorToast(
          message: 'Open your app store\'s subscriptions to renew it.',
        );
      }
    case RefusalAction.useOwnAlrtPlus:
      if (id == null) return;
      final result = await ref
          .read(providerOfAccessRepository)
          .switchToIndividualFunding(circleId: id);
      if (!context.mounted) return;
      if (result.isFailure) {
        context.showErrorToast(message: result.failure.message);
        return;
      }
      // Coverage changed: re-read access and the group so paused features
      // come back for everyone with their own ALRT +.
      ref.invalidate(providerOfAccess);
      ref.invalidate(providerOfAlrtPlus);
      unawaited(ref.read(providerOfFamily.notifier).load(silent: true));
      context.showSuccessToast(
        message:
            'This group now uses each person\'s own ALRT +. Everyone who '
            'has it can carry on.',
      );
    case RefusalAction.inviteSomeone:
      await context.push(FamilyInviteScreen.route);
    case RefusalAction.editSosList:
      // Open THAT list; if it is gone, the list of lists. Never a blank
      // new list.
      final list = ref
          .read(providerOfFamily)
          .sosLists
          .where((l) => l.id == refusal.sosListId)
          .firstOrNull;
      if (list != null) {
        await context.push(
          FamilySosListEditScreen.route,
          extra: FamilySosListEditScreenArgs(list: list),
        );
      } else {
        await context.push(FamilySosListsScreen.route);
      }
  }
}

/// The refusal sheet in the boards' language (Refusal-SavedPlace,
/// Refusal-IndividualRequired): grab handle, a 22 px title, the plain
/// reason, one orange action, an optional outlined one, then "Not now".
class _RefusalSheet extends StatelessWidget {
  const _RefusalSheet({required this.presentation});

  final RefusalPresentation presentation;

  static const _ink = Color(0xFF1C1C1E);
  static const _body = Color(0xFF3A3A42);
  static const _muted = Color(0xFF5C5C66);
  static const _handle = Color(0xFFD9D6D0);
  static const _orange = Color(0xFFE8622A);

  @override
  Widget build(BuildContext context) {
    final p = presentation;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
      ),
      padding: EdgeInsets.fromLTRB(16.spMin, 10.spMin, 16.spMin, 12.spMin),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40.spMin,
                height: 5.spMin,
                decoration: BoxDecoration(
                  color: _handle,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            SizedBox(height: 14.spMin),
            Text(
              p.title,
              style: TextStyle(
                fontSize: 22.spMin,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: _ink,
              ),
            ),
            SizedBox(height: 10.spMin),
            Text(
              p.body,
              style: TextStyle(fontSize: 14.spMin, height: 1.5, color: _body),
            ),
            SizedBox(height: 16.spMin),
            if (p.primary != null)
              Container(
                height: 54.spMin,
                decoration: BoxDecoration(
                  color: _orange,
                  borderRadius: BorderRadius.circular(14.spMin),
                  boxShadow: [
                    BoxShadow(
                      color: _orange.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14.spMin),
                    onTap: () => Navigator.of(context).pop(p.primary),
                    child: Center(
                      child: Text(
                        p.primaryLabel!,
                        style: TextStyle(
                          fontSize: 16.spMin,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (p.secondary != null) ...[
              SizedBox(height: 10.spMin),
              SizedBox(
                height: 48.spMin,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(p.secondary),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _ink,
                    side: const BorderSide(color: _handle),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.spMin),
                    ),
                  ),
                  child: Text(
                    p.secondaryLabel!,
                    style: TextStyle(
                      fontSize: 14.spMin,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
            SizedBox(height: 6.spMin),
            SizedBox(
              height: 44.spMin,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(foregroundColor: _muted),
                child: Text(
                  p.primary == null ? 'OK' : 'Not now',
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
