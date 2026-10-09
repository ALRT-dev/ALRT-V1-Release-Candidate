import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/notification/providers/notifications_feed_provider.dart';
import 'package:hazard_app/features/notification/views/widgets/hazard_notifications_list.dart';
import 'package:hazard_app/features/notification/views/widgets/notifications_appbar.dart';
import 'package:hazard_app/features/notification/views/widgets/subscribed_locations_filters_list.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

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
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(providerOfNotificationsFeed.notifier)
            .getNotificationsFeedHazards(silent: true),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            NotificationsAppBar(),
            10.hSizedBox.sliverBox,
            SubscribedLocationsFiltersList().sliverBox,
            10.hSizedBox.sliverBox,
            HazardNotificationsList(),
            30.hSizedBox.sliverBox,
          ],
        ),
      ),
    ).keyboardDismisser(context);
  }

  void _onInit() {
    // Removes expired hazards from the notifications feed upon initialization.
    ref.read(providerOfNotificationsFeed.notifier).removeExpiredHazards();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreNotifications();
    }
  }

  void _loadMoreNotifications() {
    ref
        .read(providerOfNotificationsFeed.notifier)
        .getNextNotificationsFeedHazards();
  }
}
