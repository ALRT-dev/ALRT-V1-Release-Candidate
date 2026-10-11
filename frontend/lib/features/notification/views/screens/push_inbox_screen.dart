import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/notification/models/push_inbox_item_model.dart';
import 'package:hazard_app/features/notification/providers/push_inbox_provider.dart';
import 'package:hazard_app/features/shared/extensions/date_time_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/views/screens/view_hazard_screen.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PushInboxScreen extends ConsumerStatefulWidget {
  const PushInboxScreen({super.key});

  static const route = '/push-inbox';

  @override
  ConsumerState<PushInboxScreen> createState() => _PushInboxScreenState();
}

class _PushInboxScreenState extends ConsumerState<PushInboxScreen> {
  @override
  void initState() {
    super.initState();
    // Mark everything read when the inbox is opened.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(providerOfPushInbox.notifier).markAllRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(providerOfPushInbox);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18.spMin,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(LucideIcons.arrowLeft, size: 22.spMin),
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: items.isEmpty
          ? _emptyState()
          : ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: 16.spMin,
                vertical: 16.spMin,
              ),
              itemCount: items.length,
              separatorBuilder: (_, __) => 8.hSizedBox,
              itemBuilder: (context, index) => _buildItem(items[index]),
            ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.bellOff,
            size: 48.spMin,
            color: AppColors.grey.withValues(alpha: 0.4),
          ),
          16.hSizedBox,
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 16.spMin,
              fontWeight: FontWeight.w600,
              color: AppColors.grey,
            ),
          ),
          8.hSizedBox,
          Text(
            'Push notifications you receive will\nappear here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.spMin,
              color: AppColors.grey.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(PushInboxItem item) {
    final bandColor = _bandColor(item.severityBand);

    return GestureDetector(
      onTap: () => _navigateToAlert(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.spMin),
          border: Border(
            left: BorderSide(
              color: bandColor,
              width: 4.spMin,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 14.spMin,
          vertical: 12.spMin,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14.spMin,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                      height: 1.3,
                    ),
                  ),
                ),
                8.wSizedBox,
                Text(
                  item.receivedAt.timeAgo,
                  style: TextStyle(
                    fontSize: 12.spMin,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
            if (item.body.isNotEmpty) ...[
              6.hSizedBox,
              Text(
                item.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.spMin,
                  color: AppColors.mediumGrey,
                  height: 1.35,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Navigates to the alert detail screen. If the stored payload contains
  /// enough data to build a full Hazard we use that; otherwise we create a
  /// minimal Hazard with just the id and let ViewHazardScreen fetch the
  /// rest from the server.
  void _navigateToAlert(PushInboxItem item) {
    if (item.hazardId == null) return;

    Hazard hazard;
    if (item.payload != null && item.payload!.isNotEmpty) {
      try {
        final decoded = jsonDecode(item.payload!);
        if (decoded is Map<String, dynamic>) {
          hazard = Hazard.fromJson(decoded);
        } else {
          hazard = Hazard(id: item.hazardId);
        }
      } catch (_) {
        hazard = Hazard(id: item.hazardId);
      }
    } else {
      hazard = Hazard(id: item.hazardId);
    }

    context.push(
      ViewHazardScreen.route,
      extra: ViewHazardScreenArgs(hazard: hazard),
    );
  }

  Color _bandColor(String? band) {
    switch (band) {
      case 'critical':
        return AppColors.emergency;
      case 'action':
        return AppColors.watchAndAct;
      case 'monitor':
        return AppColors.advice;
      case 'info':
        return AppColors.info;
      default:
        return AppColors.grey;
    }
  }
}
