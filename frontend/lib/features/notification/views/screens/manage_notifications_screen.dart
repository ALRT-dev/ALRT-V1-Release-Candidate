import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/notification/views/widgets/all_location_subscriptions_list.dart';
import 'package:hazard_app/features/notification/views/widgets/manage_push_notifications_list.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

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
      appBar: AppBar(
        title: Text(
          'Manage Notifications',
          style: TextStyle(
            fontSize: 18.spMin,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.spMin),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          dividerColor: AppColors.transparent,
          tabs: [
            Tab(
              icon: Icon(Icons.notifications_outlined),
              text: 'Categories',
            ),
            Tab(
              icon: Icon(Icons.location_on_outlined),
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

  Widget _buildNotificationCategoriesTab() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.spMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notification Categories',
                style: TextStyle(
                  fontSize: 18.spMin,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              8.spMin.hSizedBox,
              Text(
                'Choose which types of alrts you want to receive on your device.',
                style: TextStyle(
                  fontSize: 14.spMin,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ),
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
            'Manage your subscribed locations for targeted hazard alrts. Your own location is always subscribed.',
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
