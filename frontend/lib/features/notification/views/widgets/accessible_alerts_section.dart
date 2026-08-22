import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/notification/providers/accessible_alerts_provider.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// How urgent alerts reach you when a ping isn't enough.
///
/// Both switches follow the safety profile until touched: ticking "Deaf or
/// hard of hearing" pre-enables strong vibration, "Vision impairment"
/// pre-enables read-aloud. The section says so, so nobody wonders why a
/// switch is already on.
class AccessibleAlertsSection extends ConsumerWidget {
  const AccessibleAlertsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(providerOfAccessibleAlerts);
    final notifier = ref.read(providerOfAccessibleAlerts.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accessible alerts',
          style: TextStyle(
            fontSize: 16.spMin,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        4.hSizedBox,
        Text(
          'For emergencies you need to feel or hear, not just see. '
          'These follow your safety profile until you set them yourself.',
          style: TextStyle(fontSize: 12.5.spMin, color: AppColors.grey),
        ),
        12.hSizedBox,
        _toggleCardBuilder(
          icon: LucideIcons.vibrate,
          title: 'Strong vibration for urgent alerts',
          subtitle: 'Take-action and critical alerts arrive with a long, '
              'hard vibration pattern. Made for deaf and hard-of-hearing '
              'users; anyone can turn it on.',
          value: settings.strongVibration,
          onChanged: notifier.setStrongVibration,
        ),
        8.hSizedBox,
        _toggleCardBuilder(
          icon: LucideIcons.volume2,
          title: 'Read urgent alerts aloud',
          subtitle: 'Take-action and critical alerts are spoken when the '
              'app is open, and every alert has a Listen button. Made for '
              'vision-impaired users; handy for anyone driving.',
          value: settings.readAloud,
          onChanged: notifier.setReadAloud,
        ),
      ],
    );
  }

  Widget _toggleCardBuilder({
    required final IconData icon,
    required final String title,
    required final String subtitle,
    required final bool value,
    required final void Function(bool value) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 12.spMin),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.spMin),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20.spMin, color: AppColors.black),
          12.wSizedBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                2.hSizedBox,
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5.spMin,
                    height: 1.4,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          8.wSizedBox,
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.orange,
          ),
        ],
      ),
    );
  }
}
