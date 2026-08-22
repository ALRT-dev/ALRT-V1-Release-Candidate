import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/learn/views/screens/learn_topics_screen.dart';
import 'package:hazard_app/features/notification/providers/notifications_feed_provider.dart';
import 'package:hazard_app/features/notification/views/widgets/hazard_notifications_list.dart';
import 'package:hazard_app/features/notification/views/widgets/notifications_appbar.dart';
import 'package:hazard_app/features/notification/views/widgets/subscribed_locations_filters_list.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

/// The two feed modes: live alerts and the Learn hub.
enum _FeedMode { liveAlerts, learn }

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();
  _FeedMode _mode = _FeedMode.liveAlerts;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onInit());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          NotificationsAppBar(),
          10.hSizedBox.sliverBox,
          // Live Alerts / Learn switch (V3: the feed and the learn hub
          // share the Alerts surface).
          _modeToggleBuilder().sliverBox,
          10.hSizedBox.sliverBox,
          if (_mode == _FeedMode.liveAlerts) ...[
            SubscribedLocationsFiltersList().sliverBox,
            10.hSizedBox.sliverBox,
            HazardNotificationsList(),
            30.hSizedBox.sliverBox,
          ] else
            SliverToBoxAdapter(
              // The feed already scrolls, so Learn must not bring its own
              // scroll view: a sliver gives its child unbounded height.
              child: LearnTopicsView(
                isScrollable: false,
                padding: EdgeInsets.fromLTRB(
                  16.spMin,
                  4.spMin,
                  16.spMin,
                  120.spMin,
                ),
              ),
            ),
        ],
      ),
    ).keyboardDismisser(context);
  }

  /// Live Alerts / Learn segmented toggle.
  Widget _modeToggleBuilder() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.spMin),
      child: Container(
        height: 44.spMin,
        padding: EdgeInsets.all(4.spMin),
        decoration: BoxDecoration(
          color: const Color(0xFFEDEDEF),
          borderRadius: BorderRadius.circular(16.spMin),
        ),
        child: Row(
          children: [
            _modeButtonBuilder(
              mode: _FeedMode.liveAlerts,
              label: 'Live Alerts',
            ),
            _modeButtonBuilder(
              mode: _FeedMode.learn,
              label: 'Learn',
              isNew: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeButtonBuilder({
    required final _FeedMode mode,
    required final String label,
    final bool isNew = false,
  }) {
    final isSelected = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(13.spMin),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.spMin,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.orange : AppColors.grey,
                ),
              ),
              if (isNew) ...[
                SizedBox(width: 6.spMin),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.spMin,
                    vertical: 2.spMin,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.emergency,
                    borderRadius: BorderRadius.circular(8.spMin),
                  ),
                  child: Text(
                    'NEW',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 8.spMin,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _onInit() {
    // Removes expired hazards from the notifications feed upon initialization.
    ref.read(providerOfNotificationsFeed.notifier).removeExpiredHazards();
  }

  void _onScroll() {
    if (_mode != _FeedMode.liveAlerts) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // User has scrolled near the bottom (200 pixels before the end)
      _loadMoreNotifications();
    }
  }

  void _loadMoreNotifications() {
    ref
        .read(providerOfNotificationsFeed.notifier)
        .getNextNotificationsFeedHazards();
  }
}
