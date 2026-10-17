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

    // Notifications board (16 Oct 2026): white header with back, title and
    // "Everything ALRT has sent to this phone", then one card per push.
    return Scaffold(
      backgroundColor: _page,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 72.spMin,
        titleSpacing: 0,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => context.pop(),
          icon: Icon(LucideIcons.chevronLeft, size: 24.spMin, color: _ink),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: 24.spMin,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: _ink,
              ),
            ),
            SizedBox(height: 4.spMin),
            Text(
              'Everything ALRT has sent to this phone',
              style: TextStyle(fontSize: 14.spMin, color: _muted),
            ),
          ],
        ),
      ),
      body: items.isEmpty
          ? ListView(
              padding: EdgeInsets.fromLTRB(16.spMin, 14.spMin, 16.spMin, 16.spMin),
              children: [_emptyState()],
            )
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(16.spMin, 14.spMin, 16.spMin, 16.spMin),
              itemCount: items.length,
              separatorBuilder: (_, __) => 10.hSizedBox,
              itemBuilder: (context, index) => _buildItem(items[index]),
            ),
    );
  }

  static const _page = Color(0xFFF5F5F7);
  static const _ink = Color(0xFF1C1C1E);
  static const _muted = Color(0xFF5C5C66);

  Widget _emptyState() {
    return Container(
      padding: EdgeInsets.all(16.spMin),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.spMin),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        'Nothing yet. Alerts, check-ins and SOS land here.',
        style: TextStyle(fontSize: 13.spMin, color: _muted, height: 1.45),
      ),
    );
  }

  Widget _buildItem(PushInboxItem item) {
    // Only the most serious pushes carry the red edge, as on the board.
    final isCritical = item.severityBand == 'critical';

    return GestureDetector(
      onTap: () => _navigateToAlert(item),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18.spMin),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            border: isCritical
                ? Border(
                    left: BorderSide(color: AppColors.emergency, width: 5.spMin),
                  )
                : null,
          ),
          padding: EdgeInsets.all(16.spMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 15.spMin,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                        height: 1.3,
                      ),
                    ),
                  ),
                  8.wSizedBox,
                  Text(
                    item.receivedAt.timeAgo,
                    style: TextStyle(fontSize: 12.spMin, color: _muted),
                  ),
                ],
              ),
              if (item.body.isNotEmpty) ...[
                4.hSizedBox,
                Text(
                  item.body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.spMin,
                    color: _muted,
                    height: 1.45,
                  ),
                ),
              ],
            ],
          ),
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
}
