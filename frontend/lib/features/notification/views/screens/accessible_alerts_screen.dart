import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/notification/providers/accessible_alerts_provider.dart';
import 'package:hazard_app/features/profile/views/widgets/profile_page_kit.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

/// "Accessible alerts", as on the prototype "AccessibleAlerts" board:
/// white header ("Sound, vibration and read aloud. Stays on this phone."),
/// one card of switches, then "Test vibration".
///
/// The board also has a "Read urgent alerts aloud" switch. There is no
/// read-aloud engine behind one yet (AccessibleAlertsNotifier.setReadAloud
/// only stores the choice), so instead of a switch that does nothing the
/// card says how alerts are read aloud today: the Listen button.
class AccessibleAlertsScreen extends ConsumerWidget {
  const AccessibleAlertsScreen({super.key});

  static const route = '/accessible-alerts';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(providerOfAccessibleAlerts);
    final notifier = ref.read(providerOfAccessibleAlerts.notifier);

    return Scaffold(
      backgroundColor: ProfilePageKit.page,
      body: Column(
        children: [
          const ProfilePageHeader(
            title: 'Accessible alerts',
            subtitle: 'Sound, vibration and read aloud. Stays on this phone.',
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.spMin, 14.spMin, 16.spMin, 32.spMin),
              children: [
                ProfileCard(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Strong vibration for urgent alerts',
                            style: TextStyle(
                              fontSize: 15.spMin,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.spMin),
                        Switch(
                          key: const Key('accessible-vibration'),
                          value: settings.strongVibration,
                          onChanged: notifier.setStrongVibration,
                          activeTrackColor: AppColors.green,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Read urgent alerts aloud',
                                style: TextStyle(
                                  fontSize: 15.spMin,
                                  color: AppColors.ink,
                                ),
                              ),
                              const ProfileMutedText(
                                'Every alert has a Listen button that reads '
                                'it aloud.',
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 14.spMin),
                ProfileButton(
                  key: const Key('accessible-test'),
                  label: 'Test vibration',
                  kind: ProfileButtonKind.secondary,
                  onPressed: () async {
                    final shown = await notifier.testStrongVibration();
                    if (!context.mounted) return;
                    if (shown) {
                      context.showSuccessToast(message: 'Test alert sent');
                    } else {
                      context.showWarningToast(
                        message: 'Notifications for ALRT are off in your '
                            'phone settings, so nothing can vibrate.',
                      );
                    }
                  },
                ),
                SizedBox(height: 10.spMin),
                const ProfileMutedText(
                  "If it doesn't buzz: check Do Not Disturb, and your phone's "
                  'notification settings for ALRT.',
                  size: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
