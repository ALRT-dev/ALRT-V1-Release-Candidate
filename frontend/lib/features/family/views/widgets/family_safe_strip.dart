import 'package:flutter/material.dart';
import 'package:hazard_app/features/home/views/screens/home_screen.dart';
import 'package:hazard_app/features/home/providers/home_tab_provider.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';
import 'package:hazard_app/features/family/views/widgets/family_choose_circle_sheet.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_check_in_consent_sheet.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// "Tell your family you're safe" strip on the alert detail screen.
/// Shown only to members of a family circle. Tapping it asks the consent
/// question first (check in only, or share a snapshot too), then sends a
/// safe check-in referencing this alert so the whole circle stops worrying.
class FamilySafeStrip extends ConsumerStatefulWidget {
  const FamilySafeStrip({super.key, required this.hazard});

  final Hazard hazard;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FamilySafeStripState();
}

class _FamilySafeStripState extends ConsumerState<FamilySafeStrip> {
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    final circleName = ref.watch(
      providerOfFamily.select((s) => s.circle?.name),
    );
    final circleCount = ref.watch(
      providerOfFamily.select((s) => s.circles.length),
    );
    final loaded = ref.watch(
      providerOfFamily.select((s) => s.hasLoadedOnce),
    );
    if (circleName == null && !loaded) return _loadingBuilder(context);
    if (circleName == null) return _noCircleBuilder(context);

    final isSending = ref.watch(
      providerOfFamily.select((s) => s.checkInState.isLoading),
    );

    return Container(
      margin: EdgeInsets.only(top: 14.spMin),
      padding: EdgeInsets.all(14.spMin),
      decoration: BoxDecoration(
        color: FamilyColors.indigoLight,
        borderRadius: BorderRadius.circular(16.spMin),
      ),
      child: Row(
        children: [
          Icon(
            _sent ? LucideIcons.circleCheck : LucideIcons.users,
            color: _sent ? FamilyColors.safeGreen : FamilyColors.indigo,
            size: 22.spMin,
          ),
          SizedBox(width: 10.spMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _sent
                      ? 'Your family has been told you are safe.'
                      : 'Near this alert? Let your family know you are okay.',
                  style: TextStyle(
                    fontSize: 13.spMin,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    height: 1.35,
                  ),
                ),
                // Where the check-in goes is always visible, and can be
                // changed before sending when there is more than one circle.
                if (!_sent)
                  GestureDetector(
                    onTap: circleCount > 1
                        ? () => showChooseCircleSheet(context, ref)
                        : null,
                    child: Text(
                      circleCount > 1
                          ? 'To $circleName · change circle'
                          : 'To $circleName',
                      style: TextStyle(
                        fontSize: 12.spMin,
                        fontWeight: FontWeight.w600,
                        color: FamilyColors.indigo,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!_sent) ...[
            SizedBox(width: 10.spMin),
            SizedBox(
              height: 36.spMin,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: FamilyColors.indigo,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 14.spMin),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.spMin),
                  ),
                ),
                onPressed: isSending ? null : _sendSafeCheckIn,
                child: isSending
                    ? SizedBox(
                        width: 16.spMin,
                        height: 16.spMin,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Check in',
                        style: TextStyle(
                          fontSize: 13.spMin,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _sendSafeCheckIn() async {
    final title = widget.hazard.title;
    final choice = await showCheckInConsentSheet(
      context,
      contextLine: title == null ? null : 'About the alert: $title',
      sharingLevel: ref.read(providerOfFamily).circle?.me?.sharingLevel,
    );
    if (choice == null || !mounted) return;
    await ref
        .read(providerOfFamily.notifier)
        .checkIn(
          message: title == null ? "I'm safe" : 'Safe — near "$title"',
          shareLocation: choice == CheckInConsentChoice.checkInAndShareLocation,
          hazardId: widget.hazard.id,
        );
    if (!mounted) return;

    final failed = ref.read(providerOfFamily).checkInState.isError;
    if (!failed) {
      setState(() => _sent = true);
      context.showSuccessToast(
        message: 'Checked in · your circle has been notified.',
      );
    }
  }

  /// The circle has not been read yet (cold start): say so, rather than
  /// telling a member they have no circle.
  Widget _loadingBuilder(final BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 14.spMin),
      padding: EdgeInsets.all(14.spMin),
      decoration: BoxDecoration(
        color: FamilyColors.indigoLight,
        borderRadius: BorderRadius.circular(16.spMin),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18.spMin,
            height: 18.spMin,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10.spMin),
          Expanded(
            child: Text(
              'Loading your family circle…',
              style: TextStyle(fontSize: 13.spMin, color: AppColors.black),
            ),
          ),
        ],
      ),
    );
  }

  /// No circle yet: say so, and point at the Family tab. Never a dead
  /// space, never a button that would fail.
  Widget _noCircleBuilder(final BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 14.spMin),
      padding: EdgeInsets.all(14.spMin),
      decoration: BoxDecoration(
        color: FamilyColors.indigoLight,
        borderRadius: BorderRadius.circular(16.spMin),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.users, color: FamilyColors.indigo, size: 22.spMin),
          SizedBox(width: 10.spMin),
          Expanded(
            child: Text(
              'Join or create a family circle to check in from an alert.',
              style: TextStyle(
                fontSize: 13.spMin,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
                height: 1.35,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(providerOfHomeTab.notifier).state = HomeTab.family;
              context.go(HomeScreen.route);
            },
            child: Text(
              'Family',
              style: TextStyle(
                fontSize: 13.spMin,
                fontWeight: FontWeight.w700,
                color: FamilyColors.indigo,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
