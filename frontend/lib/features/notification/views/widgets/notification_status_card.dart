import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/notification/providers/accessible_alerts_provider.dart';
import 'package:hazard_app/features/notification/providers/service_providers.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Whether this phone can receive ALRT notifications, in plain words, with
/// the one route to the phone's own settings when it cannot, and a
/// clearly labelled test that sends a push to THIS account's phones only.
/// It never turns anything on by itself, never touches silent mode or Do
/// Not Disturb, and never sends a real alert.
class NotificationStatusCard extends ConsumerStatefulWidget {
  const NotificationStatusCard({super.key});

  @override
  ConsumerState<NotificationStatusCard> createState() =>
      _NotificationStatusCardState();
}

class _NotificationStatusCardState extends ConsumerState<NotificationStatusCard>
    with WidgetsBindingObserver {
  AuthorizationStatus? _status;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back from the phone's settings: re-read the permission.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final result = await ref
        .read(providerOfNotificationService)
        .getNotificationPermissionStatus();
    if (!mounted) return;
    setState(() => _status = result.when((s) => s, (_) => null));
  }

  bool get _allowed =>
      _status == AuthorizationStatus.authorized ||
      _status == AuthorizationStatus.provisional;

  String get _statusLine => switch (_status) {
    AuthorizationStatus.authorized =>
      'Notifications are allowed on this phone.',
    AuthorizationStatus.provisional =>
      'Notifications arrive quietly (no sound) until you allow them fully.',
    AuthorizationStatus.denied =>
      'Notifications for ALRT are turned off in your phone settings. No alert can reach this phone until they are on.',
    AuthorizationStatus.notDetermined =>
      'Your phone has not been asked yet. Open ALRT alerts to allow them.',
    _ => 'Checking your phone\'s notification setting…',
  };

  Future<void> _sendTest() async {
    if (_sending) return;
    setState(() => _sending = true);
    final urgent = ref.read(providerOfAccessibleAlerts).strongVibration;
    final result = await ref
        .read(providerOfNotificationService)
        .sendTestNotification(urgent: urgent);
    if (!mounted) return;
    setState(() => _sending = false);
    result.when(
      (data) {
        final sent = data['sent'] == true;
        if (!sent) {
          context.showWarningToast(
            message:
                data['message']?.toString() ??
                'No phone is registered for notifications on this account.',
          );
          return;
        }
        context.showSuccessToast(
          message: urgent
              ? 'Test sent to your phones on the urgent channel. Lock the phone: it should arrive within a few seconds.'
              : 'Test sent to your phones. Lock the phone: it should arrive within a few seconds.',
        );
      },
      (error) => context.showErrorToast(message: error.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.spMin, 12.spMin, 16.spMin, 4.spMin),
      padding: EdgeInsets.all(14.spMin),
      decoration: BoxDecoration(
        color: _allowed ? const Color(0xFFEEF8F1) : const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(14.spMin),
        border: Border.all(
          color: _allowed ? const Color(0xFFBFE3CC) : const Color(0xFFF5D6A8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _allowed ? LucideIcons.bellRing : LucideIcons.bellOff,
                size: 18.spMin,
                color: _allowed
                    ? const Color(0xFF1F6E3A)
                    : const Color(0xFF9A5B00),
              ),
              SizedBox(width: 8.spMin),
              Expanded(
                child: Text(
                  'Can alerts reach this phone?',
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.spMin),
          Text(
            _statusLine,
            style: TextStyle(
              fontSize: 12.5.spMin,
              height: 1.4,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 4.spMin),
          Text(
            'Silent mode, Do Not Disturb and your phone\'s per-channel settings still apply; ALRT never overrides them. Force-stopping the app stops all pushes until it is opened again.',
            style: TextStyle(
              fontSize: 11.spMin,
              height: 1.4,
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: 8.spMin),
          Wrap(
            spacing: 8.spMin,
            children: [
              if (!_allowed)
                TextButton.icon(
                  onPressed: () => AppSettings.openAppSettings(
                    type: AppSettingsType.notification,
                  ),
                  icon: Icon(LucideIcons.settings, size: 16.spMin),
                  label: const Text('Open phone settings'),
                ),
              TextButton.icon(
                onPressed: _allowed && !_sending ? _sendTest : null,
                icon: Icon(LucideIcons.send, size: 16.spMin),
                label: Text(_sending ? 'Sending…' : 'Send a test notification'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
