import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/notification/providers/last_feed_fetch_provider.dart';
import 'package:hazard_app/features/shared/enums/network_connection_status.dart';
import 'package:hazard_app/features/shared/providers/network_connection_checker_provider.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A banner that appears when the device is offline, showing the time
/// alerts were last fetched so the user knows how stale the data is.
///
/// Displays: "Showing alerts as of HH:MM"
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatus = ref.watch(providerOfNetworkConnectionStatus);
    final lastFetch = ref.watch(providerOfLastFeedFetchAt);

    // Only show the banner when disconnected.
    if (networkStatus != NetworkConnectionStatus.disconnected) {
      return const SizedBox.shrink();
    }

    final timeString = lastFetch != null
        ? DateFormat('h:mm a').format(lastFetch).toLowerCase()
        : null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16.spMin,
        vertical: 10.spMin,
      ),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.12),
        border: Border(
          bottom: BorderSide(
            color: AppColors.info.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.wifiOff,
            size: 16.spMin,
            color: AppColors.info,
          ),
          SizedBox(width: 8.spMin),
          Expanded(
            child: Text(
              timeString != null
                  ? 'Showing alerts as of $timeString'
                  : 'You are offline',
              style: TextStyle(
                fontSize: 13.spMin,
                fontWeight: FontWeight.w500,
                color: AppColors.info,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
