import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/screens/family_tab_view.dart';
import 'package:hazard_app/features/family/views/widgets/family_location_request_sheet.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';
import 'package:hazard_app/features/home/providers/home_provider.dart';
import 'package:hazard_app/features/home/providers/home_tab_provider.dart';
import 'package:hazard_app/features/home/widgets/home_tabbar.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/providers/map_search_text_editing_controller_provider.dart';
import 'package:hazard_app/features/map/providers/places_provider.dart';
import 'package:hazard_app/features/map/views/screens/map_screen.dart';
import 'package:hazard_app/features/notification/enums/push_notification_types.dart';
import 'package:hazard_app/features/notification/extensions/remote_message_extension.dart';
import 'package:hazard_app/features/notification/providers/manage_notifications_provider.dart';
import 'package:hazard_app/features/notification/providers/notifications_feed_provider.dart';
import 'package:hazard_app/features/notification/providers/push_notification_message_provider.dart';
import 'package:hazard_app/features/notification/views/widgets/notification_priming_sheet.dart';
import 'package:hazard_app/features/notification/views/screens/notifications_screen.dart';
import 'package:hazard_app/features/profile/providers/my_hazards_provider.dart';
import 'package:hazard_app/features/profile/providers/my_location_subscriptions_provider.dart';
import 'package:hazard_app/features/profile/providers/profile_provider.dart';
import 'package:hazard_app/features/profile/views/screens/profile_screen.dart';
import 'package:hazard_app/features/report/providers/create_update_report_provider.dart';
import 'package:hazard_app/features/report/providers/states/create_update_report_provider_state.dart';
import 'package:hazard_app/features/report/views/screens/create_update_report_screen.dart';
import 'package:hazard_app/features/report/views/widgets/alrt_approved_toast.dart';
import 'package:hazard_app/features/search/providers/main_search_provider.dart';
import 'package:hazard_app/features/search/views/screens/hazard_search_screen.dart';
import 'package:hazard_app/features/shared/enums/hazard_review_status_types.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/providers/hazard_filters_provider.dart';
import 'package:hazard_app/features/shared/providers/repository_providers.dart';
import 'package:hazard_app/features/shared/utils/review_prompt.dart';
import 'package:hazard_app/features/shared/providers/hazard_socket_manager_provider.dart';
import 'package:hazard_app/features/shared/providers/user_socket_manager_provider.dart';
import 'package:hazard_app/features/shared/views/screens/view_hazard_screen.dart';
import 'package:toastification/toastification.dart';

class HomeScreenArgs {
  final HomeTab initialTab;

  HomeScreenArgs({
    this.initialTab = HomeTab.map,
  });
}

class HomeScreen extends ConsumerStatefulWidget {
  /// Displays the home screen of the app.
  const HomeScreen({
    super.key,
    required this.args,
  });

  final HomeScreenArgs args;

  static const route = '/home';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final _tabController = TabController(
    length: HomeTab.values.length,
    initialIndex: widget.args.initialTab.index,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onInit());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // register this provider to the lifecycle of this screen
    ref.watch(providerOfHome.select((value) => null));
    ref.watch(providerOfHazardFiltersForMap.select((value) => null));
    ref.watch(providerOfHazardFiltersForSearch.select((value) => null));
    ref.watch(
      providerOfHazardFiltersForNotifications.select((value) => null),
    );
    ref.watch(providerOfMap.select((value) => null));
    ref.watch(providerOfCreateReport.select((value) => null));
    ref.watch(providerOfProfile.select((value) => null));
    ref.watch(providerOfMyHazards.select((value) => null));
    ref.watch(providerOfMyLocationSubscriptions.select((value) => null));
    ref.watch(providerOfMapSearchTextEditingController.select((value) => null));
    ref.watch(providerOfPlacesForMap.select((value) => null));
    ref.watch(providerOfPlacesForSearch.select((value) => null));
    ref.watch(providerOfMainSearch.select((value) => null));
    ref.watch(providerOfNotificationsFeed.select((value) => null));
    ref.watch(providerOfPushNotificationMessage.select((value) => null));
    ref.watch(providerOfHazardSocketManager.select((value) => null));
    ref.watch(providerOfUserSocketManager.select((value) => null));
    ref.watch(providerOfManageNotifications.select((value) => null));

    _listenToHomeTabStateChanges();
    _listenToCreateReportState();
    _listenToTheMessageRecievedFromThePushNotification();
    _listenToNotificationPrimingRequests();

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const MapScreen(),
                const HazardSearchScreen(),
                const CreateUpdateReportScreen(),
                const NotificationsScreen(),
                const FamilyTabView(),
                const ProfileScreen(),
              ],
            ).pB(HomeTabbar.height - 20.0),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: HomeTabbar(
              tabController: _tabController,
            ),
          ),
        ],
      ),
    );
  }

  /// Listens to changes in the selected tab and updates the tab controller.
  void _listenToHomeTabStateChanges() {
    ref.listen<HomeTab>(
      providerOfHomeTab,
      (previous, next) {
        if (previous != next) {
          _tabController.animateTo(next.index);
        }
      },
    );
  }

  /// Listens to changes in the create report state and shows appropriate toasts.
  void _listenToCreateReportState() {
    ref.listen(
      providerOfCreateReport.select(
        (value) => value.creatingUpdatingHazardReports,
      ),
      (prev, next) {
        if (prev != next) {
          final newItems = next.where(
            (item) => !(prev ?? []).any(
              (prevItem) => prevItem.state == item.state,
            ),
          );

          for (final report in newItems) {
            report.state.maybeWhen(
              success: (hazard) {
                if (hazard.reviewStatus == HazardReviewStatus.accepted) {
                  _showAlrtApprovedToast();
                  // A just-approved report is the happiest moment we have —
                  // ask for a store review once the toast has landed.
                  Future.delayed(const Duration(seconds: 5), () {
                    if (!mounted) return;
                    maybeAskForReview(
                      prefs: ref.read(providerOfSharedPreferencesRepository),
                    );
                  });
                } else if (hazard.reviewStatus == HazardReviewStatus.rejected) {
                  context.showErrorToast(
                    message:
                        'Your alrt report has been reviewed and rejected. Please check your profile for feedback.',
                    autoCloseDuration: Duration(seconds: 7),
                  );
                }
              },
              error: _handleError,
              orElse: () {},
            );
          }
        }
      },
    );
  }

  void _onInit() {
    ref.read(providerOfHomeTab.notifier).state = widget.args.initialTab;
  }

  /// Listens to the message received from the push notification.
  void _listenToTheMessageRecievedFromThePushNotification() {
    ref.listen(
      providerOfPushNotificationMessage.select(
        (value) => value.receivedPushNotifMessage,
      ),
      (prev, remoteMessage) {
        if (remoteMessage != null) {
          log('Remote Message: ${remoteMessage.data}');

          switch (remoteMessage.type) {
            case PushNotificationType.viewHazard:
              return _gotoViewHazardScreen(
                Hazard.fromJson(remoteMessage.payload),
              );
            case PushNotificationType.familyHazardProximity:
              // Payload carries the hazard near the family member/place.
              return _gotoViewHazardScreen(
                Hazard.fromJson(remoteMessage.payload),
              );
            case PushNotificationType.familyLocationRequest:
              // Consent-first: open the Share once / Not now sheet.
              final requestId = remoteMessage.data['locationRequestId'];
              if (requestId is String && requestId.isNotEmpty) {
                showFamilyLocationRequestSheet(
                  context: context,
                  requestId: requestId,
                  requesterName: remoteMessage.data['requesterName'],
                );
              }
              return;
            case PushNotificationType.familyCheckIn:
            case PushNotificationType.familyCheckInRequest:
            case PushNotificationType.familyScheduledCheckInPrompt:
            case PushNotificationType.familyPlaceEvent:
            case PushNotificationType.familySos:
            case PushNotificationType.familySosResponse:
            case PushNotificationType.familySosResolved:
            case PushNotificationType.familyCircleUpdate:
            case PushNotificationType.familyLocationShared:
            case PushNotificationType.familyJourneyShared:
              // Land on the family hub with fresh data.
              ref.read(providerOfFamily.notifier).load(silent: true);
              ref.read(providerOfHomeTab.notifier).state = HomeTab.family;
              return;
            case PushNotificationType.badgeEarned:
              // The badge shelf lives on the profile.
              ref.read(providerOfHomeTab.notifier).state = HomeTab.profile;
              return;
            default:
          }
        }
      },
    );
  }

  /// Shows the notification priming sheet when the home provider decides
  /// permission should be pitched (before the OS prompt / after a deny).
  void _listenToNotificationPrimingRequests() {
    ref.listen(
      providerOfHome.select((s) => s.notificationPrimingRequest),
      (prev, next) {
        if (next != null && prev == null) {
          showNotificationPrimingSheet(context: context, kind: next);
        }
      },
    );
  }

  /// Handles errors by showing a toast message.
  void _handleError(AppError error) {
    context.showErrorToast(
      message: error.message,
    );
  }

  void _showAlrtApprovedToast() {
    Toastification().showCustom(
      context: context,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 5),
      animationDuration: const Duration(milliseconds: 400),
      builder: (context, holder) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top: 8.spMin),
            child: AlrtApprovedToast(
              autoCloseDuration: const Duration(seconds: 5),
              onDismiss: () => Toastification().dismiss(holder),
            ),
          ),
        );
      },
    );
  }

  /// Navigates to the view hazard screen with the hazard from the [data].
  void _gotoViewHazardScreen(final Hazard hazard) {
    context.push(
      ViewHazardScreen.route,
      extra: ViewHazardScreenArgs(hazard: hazard),
    );
  }
}
