import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/notification/providers/last_feed_fetch_provider.dart';
import 'package:hazard_app/features/notification/providers/notifications_feed_provider.dart';
import 'package:hazard_app/features/shared/enums/network_connection_status.dart';
import 'package:hazard_app/features/shared/providers/network_connection_checker_provider.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// True while the phone has no connection.
bool isOfflineNow(final WidgetRef ref) =>
    ref.watch(providerOfNetworkConnectionStatus) ==
    NetworkConnectionStatus.disconnected;

/// "9:14 am": when the alerts on screen were last fetched, or null.
String? _lastFetchTime(final WidgetRef ref) {
  final lastFetch = ref.watch(providerOfLastFeedFetchAt);
  return lastFetch == null
      ? null
      : DateFormat('h:mm a').format(lastFetch).toLowerCase();
}

/// The dark strip across the top of every tab while offline (prototype
/// board Offline, 16 Oct 2026): "Offline. Showing alerts as of 9:14 am."
/// Home puts it under the status bar; it draws nothing when online.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isOfflineNow(ref)) return const SizedBox.shrink();
    final time = _lastFetchTime(ref);

    return Container(
      width: double.infinity,
      color: AppColors.ink,
      padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 10.spMin),
      child: Text(
        time == null
            ? 'Offline. Showing alerts from earlier.'
            : 'Offline. Showing alerts as of $time.',
        style: TextStyle(
          fontSize: 13.spMin,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
    );
  }
}

/// The yellow card at the top of the Alerts list while offline (board
/// Offline): "Can't update right now", when the alerts are from, Retry.
class OfflineAlertsCard extends ConsumerWidget {
  const OfflineAlertsCard({super.key});

  static const _wash = Color(0xFFFFF6E0);
  static const _border = Color(0xFFF3DDA0);
  static const _titleInk = Color(0xFF5E3C00);
  static const _bodyInk = Color(0xFF6B4A10);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isOfflineNow(ref)) return const SizedBox.shrink();
    final time = _lastFetchTime(ref);

    return Padding(
      padding: EdgeInsets.fromLTRB(16.spMin, 0, 16.spMin, 10.spMin),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 12.spMin),
        decoration: BoxDecoration(
          color: _wash,
          borderRadius: BorderRadius.circular(14.spMin),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.wifiOff, size: 20.spMin, color: _titleInk),
            SizedBox(width: 12.spMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Can't update right now",
                    style: TextStyle(
                      fontSize: 14.spMin,
                      fontWeight: FontWeight.w700,
                      color: _titleInk,
                    ),
                  ),
                  SizedBox(height: 2.spMin),
                  Text(
                    time == null
                        ? 'Showing the alerts loaded earlier.'
                        : 'Showing alerts from $time.',
                    style: TextStyle(fontSize: 13.spMin, color: _bodyInk),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.spMin),
            Material(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(10.spMin),
              child: InkWell(
                borderRadius: BorderRadius.circular(10.spMin),
                onTap: () {
                  ref.read(providerOfMap.notifier).getMapHazards();
                  ref
                      .read(providerOfNotificationsFeed.notifier)
                      .getNotificationsFeedHazards(silent: true);
                },
                child: Container(
                  height: 36.spMin,
                  padding: EdgeInsets.symmetric(horizontal: 14.spMin),
                  alignment: Alignment.center,
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
            ),
          ],
        ),
      ),
    );
  }
}

/// The line under the Alerts list while offline (board Offline).
class OfflineAlertsFootnote extends ConsumerWidget {
  const OfflineAlertsFootnote({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isOfflineNow(ref)) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.fromLTRB(20.spMin, 12.spMin, 20.spMin, 0),
      child: Text(
        'These alerts may be out of date. For anything urgent, check your '
        'local emergency service directly.',
        style: TextStyle(
          fontSize: 13.spMin,
          height: 1.45,
          color: AppColors.mediumGrey,
        ),
      ),
    );
  }
}
