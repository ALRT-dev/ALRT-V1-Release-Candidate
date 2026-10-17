import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/repositories/access_repository.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_group_paywall_screen.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_manage_screen.dart';
import 'package:hazard_app/features/subscription/views/widgets/access_refusal_sheet.dart';
import 'package:hazard_app/features/subscription/views/widgets/plan_identity.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// "Plan and cover" for one group (board PlanAndCover): what pays for
/// this group's connection features, read from GET /api/access.
///
/// - No live plan: "This group has no plan yet", a green "Cover this
///   group" (the group paywall pre-set to this group) and, for the host,
///   "Everyone uses their own ALRT +" (POST
///   /api/access/groups/:circleId/individual-funding).
/// - A live Family or Group plan: who covers it, and "My plans".
///
/// The app never decides access; refusals are answered by code.
class AlrtPlusPlanAndCoverScreen extends ConsumerStatefulWidget {
  const AlrtPlusPlanAndCoverScreen({super.key, required this.circleId});

  static const route = '/alrt-plus/plan-and-cover';

  /// The group this screen is about (passed as the route's extra).
  final String? circleId;

  @override
  ConsumerState<AlrtPlusPlanAndCoverScreen> createState() =>
      _AlrtPlusPlanAndCoverScreenState();
}

class _AlrtPlusPlanAndCoverScreenState
    extends ConsumerState<AlrtPlusPlanAndCoverScreen> {
  static const _page = Color(0xFFF0EEF5);
  static const _ink = Color(0xFF1C1C1E);
  static const _muted = Color(0xFF5C5C66);
  static const _line = Color(0xFFD9D6D0);

  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final access = ref.watch(providerOfAccess);
    final id = widget.circleId;
    final group = id == null ? null : access.asData?.value?.groupById(id);
    final live = group?.isSponsoredAndLive ?? false;
    final tier = group?.sponsorship?.tier;

    return Scaffold(
      backgroundColor: _page,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                16.spMin,
                14.spMin,
                16.spMin,
                24.spMin,
              ),
              children: [
                if (access.isLoading && group == null)
                  Padding(
                    padding: EdgeInsets.only(top: 40.spMin),
                    child: const Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  _card(
                    title: live && tier != null
                        ? 'Covered by ${planDisplayName(tier)}'
                        : 'This group has no plan yet',
                    body: live
                        ? 'Members join free. Everyone here gets Check in, '
                              'Check on, SOS and Journey.'
                        : 'Creating and joining is free. Connections need '
                              'ALRT + for each person, or one plan that '
                              'covers the whole group.',
                  ),
                  SizedBox(height: 14.spMin),
                  if (live)
                    _secondary(
                      'My plans',
                      () => context.push(AlrtPlusManageScreen.route),
                    )
                  else ...[
                    _coverButton(context),
                    if (group?.isHost ?? false) ...[
                      SizedBox(height: 14.spMin),
                      _secondary(
                        'Everyone uses their own ALRT +',
                        _busy ? null : _useOwnAlrtPlus,
                      ),
                    ],
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(final BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        8.spMin,
        MediaQuery.of(context).padding.top + 8.spMin,
        16.spMin,
        12.spMin,
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            icon: Icon(LucideIcons.chevronLeft, color: _ink, size: 24.spMin),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Text(
              'Plan and cover',
              style: TextStyle(
                fontSize: 24.spMin,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: _ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required final String title, required final String body}) {
    return Container(
      padding: EdgeInsets.all(16.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.spMin),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.spMin,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          SizedBox(height: 10.spMin),
          Text(
            body,
            style: TextStyle(fontSize: 13.spMin, height: 1.45, color: _muted),
          ),
        ],
      ),
    );
  }

  /// The green Family gradient: "Cover a group" before a size is chosen.
  Widget _coverButton(final BuildContext context) {
    final radius = BorderRadius.circular(14.spMin);
    return Container(
      height: 54.spMin,
      decoration: BoxDecoration(
        gradient: PlanIdentity.family.linearGradient,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: PlanIdentity.family.accent.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: () => context.push(
            AlrtPlusGroupPaywallScreen.route,
            extra: AlrtPlusGroupPaywallArgs(circleId: widget.circleId),
          ),
          child: Center(
            child: Text(
              'Cover this group',
              style: TextStyle(
                fontSize: 16.spMin,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _secondary(final String label, final VoidCallback? onTap) {
    return SizedBox(
      height: 48.spMin,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _ink,
          side: const BorderSide(color: _line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.spMin),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 14.spMin, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _useOwnAlrtPlus() async {
    final id = widget.circleId;
    if (id == null) return;
    setState(() => _busy = true);
    final result = await ref
        .read(providerOfAccessRepository)
        .switchToIndividualFunding(circleId: id);
    if (!mounted) return;
    setState(() => _busy = false);
    if (result.isFailure) {
      await showFamilyActionError(context, ref, result.failure, circleId: id);
      return;
    }
    ref.invalidate(providerOfAccess);
    ref.invalidate(providerOfAlrtPlus);
    unawaited(ref.read(providerOfFamily.notifier).load(silent: true));
    context.showSuccessToast(message: 'Everyone here uses their own ALRT +');
  }
}
