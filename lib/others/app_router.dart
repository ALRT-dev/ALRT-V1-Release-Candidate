import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/auth/views/screens/auth_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_group_settings_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_switch_group_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_check_in_roll_call_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_lists_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_list_edit_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_group_paused_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_share_ending_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_resolved_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_journey_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_invite_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_place_edit_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_places_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_sharing_level_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_receiver_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_screen.dart';
import 'package:hazard_app/features/home/views/screens/home_screen.dart';
import 'package:hazard_app/features/learn/views/screens/guide_detail_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_circle_profile_screen.dart';
import 'package:hazard_app/features/profile/views/screens/how_points_work_screen.dart';
import 'package:hazard_app/features/profile/views/screens/leaderboard_screen.dart';
import 'package:hazard_app/features/profile/views/screens/points_breakdown_screen.dart';
import 'package:hazard_app/features/auth/views/screens/email_auth_screen.dart';
import 'package:hazard_app/features/profile/views/screens/safety_profile_screen.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_manage_screen.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_paywall_screen.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_welcome_screen.dart';
import 'package:hazard_app/features/learn/views/screens/learn_topics_screen.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/providers/states/map_provider_state.dart';
import 'package:hazard_app/features/map/views/screens/select_location_on_map_screen.dart';
import 'package:hazard_app/features/map/views/screens/select_location_screen.dart';
import 'package:hazard_app/features/notification/views/screens/manage_notifications_screen.dart';
import 'package:hazard_app/features/onboarding/views/onboarding_complete_screen.dart';
import 'package:hazard_app/features/onboarding/views/onboarding_disclaimer_screen.dart';
import 'package:hazard_app/features/onboarding/views/onboarding_legal_screen.dart';
import 'package:hazard_app/features/onboarding/views/onboarding_welcome_screen.dart';
import 'package:hazard_app/features/profile/views/screens/my_hazards_screen.dart';
import 'package:hazard_app/features/profile/views/screens/delete_account_screen.dart';
import 'package:hazard_app/features/profile/views/screens/deleted_account_info_screen.dart';
import 'package:hazard_app/features/profile/views/screens/support_request_screen.dart';
import 'package:hazard_app/features/report/views/screens/create_update_report_screen.dart';
import 'package:hazard_app/features/shared/providers/navigator_key_provider.dart';
import 'package:hazard_app/features/shared/views/screens/splash_screen.dart';
import 'package:hazard_app/features/shared/views/screens/view_hazard_screen.dart';
import 'package:hazard_app/others/app_wrapper.dart';
import 'package:hazard_app/features/profile/views/screens/blocked_accounts_screen.dart';
import 'package:hazard_app/features/profile/providers/child_mode_provider.dart';
import 'package:hazard_app/features/profile/views/screens/child_mode_screen.dart';

class AppRouter {
  /// Builds and returns a [GoRouter] instance configured with routes and navigation settings.
  static GoRouter buildRouter(final WidgetRef ref) {
    return GoRouter(
      debugLogDiagnostics: true,
      initialLocation: AppWrapper.route,
      navigatorKey: ref.read(providerOfGlobalNavigatorKey),
      routes: [
        GoRoute(
          path: AppWrapper.route,
          builder: (context, state) {
            return AppWrapper(
              args: (state.extra as AppWrapperArgs?) ?? const AppWrapperArgs(),
            );
          },
        ),
        GoRoute(
          path: SplashScreen.route,
          builder: (context, state) {
            return const SplashScreen();
          },
        ),
        GoRoute(
          path: AuthScreen.route,
          builder: (context, state) {
            return const AuthScreen();
          },
        ),
        GoRoute(
          path: OnboardingWelcomeScreen.route,
          builder: (context, state) {
            return const OnboardingWelcomeScreen();
          },
        ),
        GoRoute(
          path: OnboardingDisclaimerScreen.route,
          builder: (context, state) {
            return const OnboardingDisclaimerScreen();
          },
        ),
        GoRoute(
          path: OnboardingLegalScreen.route,
          builder: (context, state) {
            return const OnboardingLegalScreen();
          },
        ),
        GoRoute(
          path: OnboardingCompleteScreen.route,
          builder: (context, state) {
            return const OnboardingCompleteScreen();
          },
        ),
        GoRoute(
          path: HomeScreen.route,
          builder: (context, state) {
            return HomeScreen(
              args: (state.extra as HomeScreenArgs?) ?? HomeScreenArgs(),
            );
          },
        ),
        GoRoute(
          path: SelectLocationScreen.route,
          builder: (context, state) {
            return SelectLocationScreen(
              args: state.extra as SelectLocationScreenArgs?,
            );
          },
        ),
        GoRoute(
          path: SelectLocationOnMapScreen.route,
          builder: (context, state) {
            return ProviderScope(
              // Create a new ProviderScope to ensure a fresh state for the map screen.
              overrides: [
                providerOfMap.overrideWith(
                  (ref) => MapProvider(
                    ref: ref,
                    state: MapProviderState(
                      getMapHazardsCancelToken: CancelToken(),
                      getHazardsToAvoidCancelToken: CancelToken(),
                    ),
                  ),
                ),
              ],
              child: SelectLocationOnMapScreen(
                args: state.extra as SelectLocationOnMapScreenArgs?,
              ),
            );
          },
        ),
        // ------------------------- FAMILY MODE -------------------------
        GoRoute(
          path: FamilyInviteScreen.route,
          builder: (context, state) => const FamilyInviteScreen(),
        ),
        GoRoute(
          path: FamilyGroupSettingsScreen.route,
          builder: (context, state) => const FamilyGroupSettingsScreen(),
        ),
        GoRoute(
          path: FamilySwitchGroupScreen.route,
          builder: (context, state) => const FamilySwitchGroupScreen(),
        ),
        GoRoute(
          path: FamilySosListsScreen.route,
          builder: (context, state) => const FamilySosListsScreen(),
        ),
        GoRoute(
          path: FamilyCheckInRollCallScreen.route,
          builder: (context, state) => const FamilyCheckInRollCallScreen(),
        ),
        GoRoute(
          path: FamilySosListEditScreen.route,
          builder: (context, state) => FamilySosListEditScreen(
            args: state.extra as FamilySosListEditScreenArgs?,
          ),
        ),
        GoRoute(
          path: FamilyGroupPausedScreen.route,
          builder: (context, state) => const FamilyGroupPausedScreen(),
        ),
        GoRoute(
          path: FamilyShareEndingScreen.route,
          builder: (context, state) => FamilyShareEndingScreen(
            args: state.extra as FamilyShareEndingScreenArgs,
          ),
        ),
        GoRoute(
          path: FamilySosResolvedScreen.route,
          builder: (context, state) => FamilySosResolvedScreen(
            args: state.extra as FamilySosResolvedScreenArgs,
          ),
        ),
        GoRoute(
          path: FamilyJourneyScreen.route,
          builder: (context, state) => const FamilyJourneyScreen(),
        ),
        GoRoute(
          path: FamilyPlacesScreen.route,
          builder: (context, state) => const FamilyPlacesScreen(),
        ),
        GoRoute(
          path: FamilyPlaceEditScreen.route,
          builder: (context, state) => FamilyPlaceEditScreen(
            args: state.extra as FamilyPlaceEditScreenArgs?,
          ),
        ),
        GoRoute(
          path: FamilySharingLevelScreen.route,
          builder: (context, state) => const FamilySharingLevelScreen(),
        ),
        GoRoute(
          path: FamilySosScreen.route,
          builder: (context, state) => const FamilySosScreen(),
        ),
        GoRoute(
          path: FamilySosReceiverScreen.route,
          builder: (context, state) => FamilySosReceiverScreen(
            args: state.extra as FamilySosReceiverScreenArgs,
          ),
        ),
        // ------------------------- LEARN HUB -------------------------
        GoRoute(
          path: ChildModeScreen.route,
          builder: (context, state) => const ChildModeScreen(),
        ),
        GoRoute(
          path: BlockedAccountsScreen.route,
          builder: (context, state) => const BlockedAccountsScreen(),
        ),
        GoRoute(
          path: LearnTopicsScreen.route,
          builder: (context, state) => const LearnTopicsScreen(),
        ),
        GoRoute(
          path: GuideDetailScreen.route,
          builder: (context, state) => GuideDetailScreen(
            args: state.extra as GuideDetailScreenArgs,
          ),
        ),
        GoRoute(
          path: FamilyCircleProfileScreen.route,
          builder: (context, state) => FamilyCircleProfileScreen(
            args: state.extra as FamilyCircleProfileArgs?,
          ),
        ),
        GoRoute(
          path: HowPointsWorkScreen.route,
          builder: (context, state) => const HowPointsWorkScreen(),
        ),
        GoRoute(
          path: LeaderboardScreen.route,
          builder: (context, state) => const LeaderboardScreen(),
        ),
        GoRoute(
          path: PointsBreakdownScreen.route,
          builder: (context, state) => const PointsBreakdownScreen(),
        ),
        GoRoute(
          path: AlrtPlusPaywallScreen.route,
          builder: (context, state) => const AlrtPlusPaywallScreen(),
        ),
        GoRoute(
          path: AlrtPlusWelcomeScreen.route,
          builder: (context, state) => const AlrtPlusWelcomeScreen(),
        ),
        GoRoute(
          path: AlrtPlusManageScreen.route,
          builder: (context, state) => const AlrtPlusManageScreen(),
        ),
        GoRoute(
          path: SafetyProfileScreen.onboardingRoute,
          builder: (context, state) =>
              const SafetyProfileScreen(isOnboarding: true),
        ),
        GoRoute(
          path: SafetyProfileScreen.route,
          builder: (context, state) => const SafetyProfileScreen(),
        ),
        GoRoute(
          path: EmailAuthScreen.route,
          builder: (context, state) => const EmailAuthScreen(),
        ),
        GoRoute(
          path: ViewHazardScreen.route,
          builder: (context, state) {
            return ViewHazardScreen(
              args: state.extra as ViewHazardScreenArgs,
            );
          },
        ),
        GoRoute(
          path: MyHazardsScreen.route,
          builder: (context, state) {
            return MyHazardsScreen(
              args:
                  (state.extra as MyHazardsScreenArgs?) ??
                  const MyHazardsScreenArgs(),
            );
          },
        ),
        GoRoute(
          path: CreateUpdateReportScreen.createRoute,
          // Child mode hides the ALRT slot, but voice dictation and any
          // deep link still route here, so the gate lives on the route
          // rather than on one button.
          redirect: (context, state) =>
              ref.read(providerOfIsChildMode) ? HomeScreen.route : null,
          builder: (context, state) {
            return CreateUpdateReportScreen(
              args: state.extra as CreateUpdateReportScreenArgs?,
            );
          },
        ),
        GoRoute(
          path: CreateUpdateReportScreen.updateRoute,
          builder: (context, state) {
            return CreateUpdateReportScreen(
              args: state.extra as CreateUpdateReportScreenArgs?,
            );
          },
        ),
        GoRoute(
          path: ManageNotificationsScreen.route,
          builder: (context, state) {
            return ManageNotificationsScreen(
              args:
                  (state.extra as ManageNotificationsScreenArgs?) ??
                  const ManageNotificationsScreenArgs(),
            );
          },
        ),
        GoRoute(
          path: SupportRequestScreen.route,
          builder: (context, state) {
            return const SupportRequestScreen();
          },
        ),
        GoRoute(
          path: DeleteAccountScreen.route,
          builder: (context, state) {
            return const DeleteAccountScreen();
          },
        ),
        GoRoute(
          path: DeletedAccountInfoScreen.route,
          builder: (context, state) {
            return const DeletedAccountInfoScreen();
          },
        ),
      ],
    );
  }
}
