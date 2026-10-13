import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/notification/views/widgets/map_area_alerts_list.dart';
import 'package:hazard_app/features/notification/views/widgets/notifications_appbar.dart';
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(providerOfMap.notifier).getMapHazards(),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Plain white header: title and one filters button. The
            // location chips row is gone; the list starts 14 px below the
            // header on the light page colour.
            const NotificationsAppBar(),
            14.hSizedBox.sliverBox,
            // The alerts in the map's current view, most serious first
            // (product owner, 14 Oct 2026). Same list the map rail opens.
            const MapAreaAlertsList(),
            30.hSizedBox.sliverBox,
          ],
        ),
      ),
    ).keyboardDismisser(context);
  }
}
