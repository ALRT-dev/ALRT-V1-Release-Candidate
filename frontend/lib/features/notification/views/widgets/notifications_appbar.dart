import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hazard_app/features/notification/providers/notifications_feed_provider.dart';
import 'package:hazard_app/features/notification/providers/states/notifications_feed_provider_state.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/providers/hazard_filters_provider.dart';
import 'package:hazard_app/features/shared/views/widgets/filter_widgets/hazard_filters_button.dart';
import 'package:hazard_app/others/app_colors.dart';

class NotificationsAppBar extends ConsumerStatefulWidget {
  const NotificationsAppBar({super.key});

  static const filtersKey = 'NotificationsAppBarFilters';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NotificationsAppBarState();
}

class _NotificationsAppBarState extends ConsumerState<NotificationsAppBar> {
  final _searchFocusNode = FocusNode();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(providerOfNotificationsFeed).searchString;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final isHazardsLoading = ref.watch(
          providerOfNotificationsFeed.select(
            (value) => value.getNotificationsFeedHazardsState.maybeWhen(
              orElse: () => false,
              loading: () => true,
            ),
          ),
        );
        final isHazardsPresent = ref.watch(
          providerOfNotificationsFeed.select(
            (value) =>
                value.searchString.isNotEmpty ? true : value.hazards.isNotEmpty,
          ),
        );
        final hasFiltersSelected = ref.watch(
          providerOfHazardFiltersForNotifications.select(
            (value) => value.hasFiltersSelected,
          ),
        );
        return SliverAppBar(
          backgroundColor: AppColors.transparent,
          surfaceTintColor: AppColors.transparent,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.orange300,
                  AppColors.red200,
                ],
              ),
            ),
          ),
          floating: true,
          pinned: true,
          leading: const SizedBox(),
          leadingWidth: 5.spMin,
          toolbarHeight: 50.spMin,
          expandedHeight: 120.spMin,
          centerTitle: false,
          title: Text(
            'ALRT Feed',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 24.spMin,
            ),
          ),
          bottom: !isHazardsPresent && !isHazardsLoading && !hasFiltersSelected
              ? PreferredSize(
                  preferredSize: Size.fromHeight(0),
                  child: Divider(
                    height: 0.0,
                    color: AppColors.lightGrey.withValues(alpha: 0.5),
                  ),
                )
              : PreferredSize(
                  preferredSize: Size.fromHeight(63.spMin),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _searchbarBuilder()),
                          _filtersButtonBuilder(),
                        ],
                      ).pX(18.0),
                      13.hSizedBox,
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _searchbarBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final isSearchActive = ref.watch(
          providerOfNotificationsFeed.select(
            (value) => value.searchString.isNotEmpty,
          ),
        );
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.spMin),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 10.0,
                offset: Offset(0, 2.0),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(vertical: 1.spMin),
          child: TextFormField(
            focusNode: _searchFocusNode,
            controller: _searchController,
            textInputAction: TextInputAction.search,
            textAlignVertical: TextAlignVertical.center,
            onChanged: _handleSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search alerts around you...',
              contentPadding: EdgeInsets.only(
                top: 5.spMin,
                bottom: 5.spMin,
                left: 20.spMin,
                right: 10.spMin,
              ),
              hintStyle: TextStyle(
                color: AppColors.grey.withValues(alpha: 0.7),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              prefixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/icons/search.svg',
                    width: 25.spMin,
                    height: 25.spMin,
                    color: AppColors.grey.withValues(alpha: 0.6),
                  ).pL(15.0),
                ],
              ),
              suffixIcon: !isSearchActive
                  ? null
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: _handleClearSearchPressed,
                          icon: Icon(
                            Icons.close_rounded,
                            size: 20.spMin,
                            color: AppColors.black,
                          ),
                        ).pR(5.0),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _filtersButtonBuilder() {
    return HazardFiltersButton(
      filtersKey: NotificationsAppBar.filtersKey,
      onFiltersUpdated: () => _getHazards(),
      buttonShadow: [],
      useTransparentStyle: true,
    ).pL(10.0);
  }

  /// Updates the state with the given search string.
  void _handleSearchChanged(String value) {
    ref.read(providerOfNotificationsFeed.notifier)
      ..updateSearchString(value.trim())
      ..updateGetNotificationsFeedStateToLoading();
    EasyDebounce.debounce(
      'notifications-search',
      const Duration(milliseconds: 300),
      () {
        if (!mounted) return;
        ref
            .read(providerOfNotificationsFeed.notifier)
            .getNotificationsFeedHazards();
      },
    );
  }

  /// Clears the search input field.
  void _handleClearSearchPressed() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    ref.read(providerOfNotificationsFeed.notifier)
      ..updateSearchString('')
      ..getNotificationsFeedHazards();
  }

  /// Fetches the hazards for the notifications feed.
  void _getHazards() {
    ref
        .read(providerOfNotificationsFeed.notifier)
        .getNotificationsFeedHazards();
  }
}
