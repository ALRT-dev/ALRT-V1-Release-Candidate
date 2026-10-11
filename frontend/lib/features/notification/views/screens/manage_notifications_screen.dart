import 'package:flutter/material.dart';
import 'package:hazard_app/features/notification/views/widgets/notification_status_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/notification/views/widgets/all_location_subscriptions_list.dart';
import 'package:hazard_app/features/notification/views/widgets/manage_push_notifications_list.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ManageNotificationsScreenArgs {
  const ManageNotificationsScreenArgs({
    this.initialTab = 0,
  });

  /// The initial tab to display when the screen is opened.
  final int initialTab;
}

class ManageNotificationsScreen extends ConsumerStatefulWidget {
  const ManageNotificationsScreen({
    super.key,
    required this.args,
  });

  /// The arguments for the screen.
  final ManageNotificationsScreenArgs args;

  static const route = '/manage-notifications';

  static const filtersKey = 'ManagePushNotifications_filtersKey';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ManageNotificationsScreenState();
}

class _ManageNotificationsScreenState
    extends ConsumerState<ManageNotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.args.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18.spMin,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        foregroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, size: 24.spMin),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          dividerColor: AppColors.transparent,
          labelColor: AppColors.black,
          unselectedLabelColor: AppColors.grey,
          indicatorColor: AppColors.orange,
          tabs: [
            Tab(
              icon: Icon(LucideIcons.bell, size: 20.spMin),
              text: 'Categories',
            ),
            Tab(
              icon: Icon(LucideIcons.mapPin, size: 20.spMin),
              text: 'Locations',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationCategoriesTab(),
          _buildLocationSubscriptionsTab(),
        ],
      ),
    );
  }

  /// The first tab: the device status card, then the type toggles and the
  /// category pills. The old heading and intro paragraph are gone; the
  /// section labels say what each block is.
  Widget _buildNotificationCategoriesTab() {
    return Column(
      children: [
        8.spMin.hSizedBox,
        const NotificationStatusCard(),
        Expanded(
          child: ManagePushNotificationsList(),
        ),
      ],
    );
  }

  Widget _buildLocationSubscriptionsTab() {
    return Padding(
      padding: EdgeInsets.all(16.spMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location Subscriptions',
            style: TextStyle(
              fontSize: 18.spMin,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          8.spMin.hSizedBox,
          Text(
            'Places you follow for alerts. Where you are is always included.',
            style: TextStyle(
              fontSize: 14.spMin,
              color: AppColors.grey,
            ),
          ),
          16.spMin.hSizedBox,
          Expanded(
            child: AllLocationSubscriptionsList(),
          ),
        ],
      ),
    );
  }
}
