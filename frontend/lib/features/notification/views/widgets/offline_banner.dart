import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/notification/providers/last_feed_fetch_provider.dart';
import 'package:hazard_app/features/notification/providers/notifications_feed_provider.dart';
import 'package:hazard_app/features/shared/enums/network_connection_status.dart';
import 'package:hazard_app/features/shared/providers/network_connection_checker_provider.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A card that appears when the device is offline, showing the time
/// alerts were last fetched so the user knows how stale the data is.
///
/// Displays: "Can't update right now" / "Showing alerts from HH:MM"
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  static const _cardColor = Color(0xFFFFF6D6);

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

    return Padding(
      padding: EdgeInsets.fromLTRB(16.spMin, 8.spMin, 16.spMin, 0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 14.spMin,
          vertical: 12.spMin,
        ),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(14.spMin),
        ),
        child: Row(
          children: [
            Icon(
              LucideIcons.wifiOff,
              size: 18.spMin,
              color: AppColors.ink,
            ),
            SizedBox(width: 10.spMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Can't update right now",
                    style: TextStyle(
                      fontSize: 14.spMin,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 2.spMin),
                  Text(
                    timeString != null
                        ? 'Showing alerts from $timeString'
                        : 'You are offline',
                    style: TextStyle(
                      fontSize: 12.5.spMin,
                      fontWeight: FontWeight.w500,
                      color: AppColors.mediumGrey,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.spMin),
            GestureDetector(
              onTap: () => ref
                  .read(providerOfNotificationsFeed.notifier)
                  .getNotificationsFeedHazards(silent: true),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14.spMin,
                  vertical: 8.spMin,
                ),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(20.spMin),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 13.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
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
