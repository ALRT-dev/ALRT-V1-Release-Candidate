import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/home/providers/home_provider.dart';
import 'package:hazard_app/features/home/providers/states/home_provider_state.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shows the notification priming sheet — the value pitch that precedes the
/// OS permission prompt (or deep-links to settings after a previous deny).
Future<void> showNotificationPrimingSheet({
  required final BuildContext context,
  required final NotificationPrimingKind kind,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (_) => NotificationPrimingSheet(kind: kind),
  );
}

class NotificationPrimingSheet extends ConsumerStatefulWidget {
  const NotificationPrimingSheet({super.key, required this.kind});

  final NotificationPrimingKind kind;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NotificationPrimingSheetState();
}

class _NotificationPrimingSheetState
    extends ConsumerState<NotificationPrimingSheet> {
  bool _isBusy = false;

  bool get _wasDenied =>
      widget.kind == NotificationPrimingKind.previouslyDenied;

  /// The V3 section label used across the app.
  static const _sectionLabel = Color(0xFFB84500);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.all(12.spMin),
        padding: EdgeInsets.all(24.spMin),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.spMin),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The sheet used to be black, white and grey throughout, which
            // is the one palette the app never uses. The bell wears the
            // brand gradient with its own soft halo, the way every other
            // primary surface in the app does.
            Container(
              width: 60.spMin,
              height: 60.spMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF8C00), Color(0xFFFF6B01)],
                ),
                borderRadius: BorderRadius.circular(18.spMin),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B01).withValues(alpha: 0.35),
                    blurRadius: 18.0,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                LucideIcons.bellRing,
                color: Colors.white,
                size: 30.spMin,
              ),
            ),
            SizedBox(height: 14.spMin),
            Text(
              'NOTIFICATIONS',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5.spMin,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: _sectionLabel,
              ),
            ),
            SizedBox(height: 6.spMin),
            Text(
              'Be first to know',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21.spMin,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 8.spMin),
            Text(
              _wasDenied
                  ? 'Notifications are off, so ALRT can\'t warn you when a '
                        'hazard appears near you or your family. You can turn '
                        'them back on in Settings.'
                  : 'ALRT only notifies you about things that matter: hazards '
                        'near you, family check-ins and SOS. No marketing, no '
                        'noise.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.spMin,
                height: 1.45,
                color: AppColors.grey,
              ),
            ),
            SizedBox(height: 18.spMin),
            // Each row wears the colour that thing already has elsewhere
            // in the app: hazards orange, family indigo, official green.
            _benefitRowBuilder(
              icon: LucideIcons.triangleAlert,
              text: 'Hazard alerts in the areas you watch',
              tint: const Color(0xFFFF6B01),
            ),
            SizedBox(height: 10.spMin),
            _benefitRowBuilder(
              icon: LucideIcons.users,
              text: 'Family check-ins, snapshots and SOS',
              tint: const Color(0xFF3D3DDF),
            ),
            SizedBox(height: 10.spMin),
            _benefitRowBuilder(
              icon: LucideIcons.shieldCheck,
              text: 'Official emergency warnings, verified first',
              tint: const Color(0xFF0A8A58),
            ),
            SizedBox(height: 22.spMin),
            SizedBox(
              height: 52.spMin,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B01),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.spMin),
                  ),
                ),
                onPressed: _isBusy ? null : _onEnablePressed,
                child: _isBusy
                    ? SizedBox(
                        width: 20.spMin,
                        height: 20.spMin,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _wasDenied ? 'Open Settings' : 'Turn on alerts',
                        style: TextStyle(
                          fontSize: 16.spMin,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 8.spMin),
            SizedBox(
              height: 48.spMin,
              child: TextButton(
                style: TextButton.styleFrom(foregroundColor: AppColors.grey),
                onPressed: _isBusy ? null : _onMaybeLaterPressed,
                child: Text(
                  'Maybe later',
                  style: TextStyle(
                    fontSize: 15.spMin,
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

  Widget _benefitRowBuilder({
    required final IconData icon,
    required final String text,
    required final Color tint,
  }) {
    return Row(
      children: [
        Container(
          width: 34.spMin,
          height: 34.spMin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: tint.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.spMin),
          ),
          child: Icon(icon, size: 17.spMin, color: tint),
        ),
        SizedBox(width: 12.spMin),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.spMin,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onEnablePressed() async {
    if (_wasDenied) {
      // The OS won't re-prompt after a deny — settings is the only path.
      await ref.read(providerOfHome.notifier).snoozeNotificationPriming();
      await AppSettings.openAppSettings(type: AppSettingsType.notification);
      if (mounted) Navigator.of(context).pop();
      return;
    }

    setState(() => _isBusy = true);
    final enabled = await ref
        .read(providerOfHome.notifier)
        .enableNotificationsFromPriming();
    if (!mounted) return;
    Navigator.of(context).pop();
    if (enabled) {
      context.showSuccessToast(message: 'Alerts are on.');
    }
  }

  Future<void> _onMaybeLaterPressed() async {
    await ref.read(providerOfHome.notifier).snoozeNotificationPriming();
    if (mounted) Navigator.of(context).pop();
  }
}
