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

    // The prototype's empty state, in the family section's locked colours:
    // gradient header carrying the promise, one card of what a group gives
    // you, the privacy note, then the two paths. No price appears here —
    // the paywall comes only after tapping Create, and the invite path
    // never sees one.
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
                  'Know the people you care about are OK. Location is '
                  'shared only when someone chooses it.',
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
              vertical: 15.spMin,
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
                Text(
                  'What a Family circle gives you',
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 9.spMin),
                _pitchLineBuilder('One tap ', "I'm Safe", ' to everyone at once'),
                _pitchLineBuilder(
                  'Ask for a ',
                  'location snapshot',
                  ', they choose to send it',
                ),
                _pitchLineBuilder(
                  '',
                  'SOS',
                  ' to your people, with live location while it runs',
                ),
                _pitchLineBuilder(
                  'Alerts near your people, ',
                  'flagged automatically',
                  '',
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(16.spMin, 11.spMin, 16.spMin, 0),
            padding: EdgeInsets.symmetric(
              horizontal: 14.spMin,
              vertical: 12.spMin,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF6ECFA),
              borderRadius: BorderRadius.circular(14.spMin),
              border: Border.all(color: const Color(0xFFECD9F4)),
            ),
            child: Text(
              'Location is shared only when someone chooses it—for a '
              'one-time snapshot, an active SOS, or an active journey. '
              'Live sharing can be stopped at any time.',
              style: TextStyle(
                fontSize: 12.spMin,
                height: 1.7,
                color: const Color(0xFF8E4AA6),
              ),
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
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFC939DD),
                          Color(0xFFA22CC6),
                          Color(0xFF7E1FA8),
                          Color(0xFF5C1585),
                        ],
                        stops: [0.0, 0.4, 0.74, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(15.spMin),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9C27B0).withValues(
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
                // Two equal ways in with a host's invite: type the code, or
                // scan the QR on their phone. The camera is only touched
                // when the scan button itself is tapped.
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: SizedBox(
                        height: 48.spMin,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1D1D21),
                            padding: EdgeInsets.symmetric(horizontal: 8.spMin),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.spMin),
                              side: const BorderSide(
                                color: Color(0xFFE8E4EE),
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
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: 48.spMin,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: FamilyColors.indigo,
                            padding: EdgeInsets.symmetric(horizontal: 8.spMin),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.spMin),
                              side: BorderSide(
                                color: FamilyColors.indigo.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                          ),
                          onPressed: joinState.isLoading
                              ? null
                              : () => scanInviteQrAndJoin(context, ref),
                          icon: Icon(Icons.qr_code_scanner_rounded, size: 18.spMin),
                          label: Text(
                            'Scan invite QR',
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
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 14.spMin),
            child: Text(
              'No price to look. Joining is always free.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.spMin,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B6875),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// One benefit line: plain text with the load-bearing words in ink.
  Widget _pitchLineBuilder(
    final String lead,
    final String strong,
    final String tail,
  ) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: lead),
          TextSpan(
            text: strong,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D1D21),
            ),
          ),
          TextSpan(text: tail),
        ],
      ),
      style: TextStyle(
        fontSize: 13.spMin,
        height: 2.0,
        color: FamilyColors.v31Ink,
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
        context.showErrorToast(message: next.error!.message);
      }
    });
  }
}
