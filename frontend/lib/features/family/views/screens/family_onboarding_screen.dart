import 'package:hazard_app/features/subscription/views/widgets/access_refusal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_header_surface.dart';
import 'package:hazard_app/features/family/views/widgets/family_group_actions.dart';
import 'package:hazard_app/features/family/views/screens/family_invite_screen.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shown when the user has no family circle yet: create one or join with a
/// code. Embedded as the Family tab body.
class FamilyOnboardingScreen extends ConsumerStatefulWidget {
  const FamilyOnboardingScreen({super.key});

  static const route = '/family-onboarding';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FamilyOnboardingScreenState();
}

class _FamilyOnboardingScreenState
    extends ConsumerState<FamilyOnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    _listenToActionStates();

    final createState = ref.watch(
      providerOfFamily.select((s) => s.createCircleState),
    );
    final joinState = ref.watch(
      providerOfFamily.select((s) => s.joinCircleState),
    );

    // The approved board's empty state in the family section's locked
    // colours: gradient header carrying the promise, one card of what a
    // group gives you, then the two paths. No price appears here: the
    // paywall comes only after tapping Create, and the invite path never
    // sees one.
    return Scaffold(
      backgroundColor: FamilyColors.v31Page,
      body: ListView(
        padding: EdgeInsets.only(bottom: 120.spMin),
        children: [
          FamilyHeaderSurface(
            padding: EdgeInsets.fromLTRB(
              16.spMin,
              56.spMin,
              16.spMin,
              20.spMin,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Family',
                  style: TextStyle(
                    fontSize: 24.spMin,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5.spMin),
                Text(
                  'Know your people are okay, in one tap.',
                  style: TextStyle(
                    fontSize: 13.spMin,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(16.spMin, 14.spMin, 16.spMin, 0),
            padding: EdgeInsets.symmetric(
              horizontal: 16.spMin,
              vertical: 6.spMin,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.spMin),
              boxShadow: [
                BoxShadow(
                  color: FamilyColors.v31CardShadow,
                  blurRadius: 12.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _featureRow(
                  icon: LucideIcons.check,
                  title: 'Check in with one tap',
                  body: 'Everyone sees it at once. No group chat.',
                ),
                const Divider(height: 1, color: FamilyColors.v31Divider),
                _featureRow(
                  icon: LucideIcons.mapPin,
                  title: 'A location only when you send it',
                  body: 'One moment, sent on purpose. Gone in an hour.',
                ),
                const Divider(height: 1, color: FamilyColors.v31Divider),
                _featureRow(
                  icon: LucideIcons.siren,
                  title: 'SOS to your group',
                  body:
                      'Hold 3 seconds. Runs for 1 hour. ALRT never contacts '
                      'emergency services.',
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.spMin, 14.spMin, 16.spMin, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 50.spMin,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: FamilyColors.headerGradient,
                      borderRadius: BorderRadius.circular(15.spMin),
                      boxShadow: [
                        BoxShadow(
                          color: FamilyColors.v31Indigo.withValues(
                            alpha: 0.32,
                          ),
                          blurRadius: 24.0,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.spMin),
                        ),
                      ),
                      onPressed: createState.isLoading
                          ? null
                          : () => showCreateGroupSheet(context, ref),
                      child: createState.isLoading
                          ? SizedBox(
                              width: 20.spMin,
                              height: 20.spMin,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Create a group',
                              style: TextStyle(
                                fontSize: 15.spMin,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 9.spMin),
                // Two ways in with a host's invite: type the code, or scan
                // the QR on their phone from the small button beside it.
                // The camera is only touched when the scan button itself
                // is tapped.
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48.spMin,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1D1D21),
                            padding: EdgeInsets.symmetric(horizontal: 8.spMin),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.spMin),
                              side: BorderSide(
                                color: FamilyColors.v31Indigo.withValues(
                                  alpha: 0.15,
                                ),
                                width: 1.5,
                              ),
                            ),
                          ),
                          onPressed: joinState.isLoading
                              ? null
                              : () => showJoinGroupSheet(context, ref),
                          child: joinState.isLoading
                              ? SizedBox(
                                  width: 20.spMin,
                                  height: 20.spMin,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'I have an invite code',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.spMin,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(width: 9.spMin),
                    SizedBox(
                      width: 48.spMin,
                      height: 48.spMin,
                      child: Tooltip(
                        message: 'Scan invite QR',
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: FamilyColors.indigo,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.spMin),
                              side: BorderSide(
                                color: FamilyColors.indigo.withValues(
                                  alpha: 0.4,
                                ),
                                width: 1.5,
                              ),
                            ),
                          ),
                          onPressed: joinState.isLoading
                              ? null
                              : () => scanInviteQrAndJoin(context, ref),
                          child: Icon(LucideIcons.qrCode, size: 20.spMin),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24.spMin, 14.spMin, 24.spMin, 0),
            child: Text(
              'Creating and joining a group is free. Check in, Check on, SOS '
              'and Journey need ALRT + for each person taking part, or one '
              'Family or Group plan that covers the whole group.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.spMin,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B6875),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// One row of the "what a group gives you" card: indigo icon, bold
  /// title, one plain line under it.
  Widget _featureRow({
    required final IconData icon,
    required final String title,
    required final String body,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.spMin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.spMin,
            height: 36.spMin,
            decoration: BoxDecoration(
              color: FamilyColors.indigoLight,
              borderRadius: BorderRadius.circular(10.spMin),
            ),
            child: Icon(icon, size: 18.spMin, color: FamilyColors.indigo),
          ),
          SizedBox(width: 12.spMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1D1D21),
                  ),
                ),
                SizedBox(height: 3.spMin),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12.5.spMin,
                    height: 1.4,
                    color: FamilyColors.v31Ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _listenToActionStates() {
    ref.listen(providerOfFamily.select((s) => s.createCircleState), (
      prev,
      next,
    ) {
      if (prev != next && next.isError && next.error != null) {
        context.showErrorToast(message: next.error!.message);
      }
      // Honour the welcome screen's "Invite your family" intent once the
      // circle actually exists.
      if (prev != next &&
          next.isSuccess &&
          ref.read(providerOfPendingFamilyInvite)) {
        ref.read(providerOfPendingFamilyInvite.notifier).set(false);
        context.push(FamilyInviteScreen.route);
      }
    });
    ref.listen(providerOfFamily.select((s) => s.joinCircleState), (
      prev,
      next,
    ) {
      if (prev != next && next.isError && next.error != null) {
        // A full group says so, with its capacity; never a payment ask.
        showFamilyActionError(context, ref, next.error!);
      }
    });
  }
}
