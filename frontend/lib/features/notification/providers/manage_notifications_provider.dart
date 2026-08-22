import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hazard_app/features/notification/models/push_notification_settings_model.dart';
import 'package:hazard_app/features/notification/providers/states/manage_notifications_provider_state.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/features/shared/services/user_service.dart';

final providerOfManageNotifications =
    StateNotifierProvider<
      ManageNotificationsProvider,
      ManageNotificationsProviderState
    >(
      (final ref) => ManageNotificationsProvider(
        ref: ref,
        state: ManageNotificationsProviderState(),
      ),
    );

class ManageNotificationsProvider
    extends StateNotifier<ManageNotificationsProviderState> {
  ManageNotificationsProvider({
    required final Ref ref,
    required ManageNotificationsProviderState state,
  }) : _ref = ref,
       super(state) {
    getPushNotificationSettings();
  }

  final Ref _ref;
  UserService get _userService => _ref.read(providerOfUserService);

  /// Fetches the push notification settings for the current user.
  Future<void> getPushNotificationSettings() async {
    state = state.copyWith(
      getPushNotificationSettingsState:
          const GetPushNotificationSettingsState.loading(),
    );

    final result = await _userService.getPushNotificationSettings();
    if (!mounted) return;

    result.when(
      (settings) {
        state = state.copyWith(
          pushNotificationSettings: settings,
          getPushNotificationSettingsState:
              GetPushNotificationSettingsState.success(settings),
        );
      },
      (error) {
        state = state.copyWith(
          getPushNotificationSettingsState:
              GetPushNotificationSettingsState.error(error),
        );
      },
    );
  }

  /// Updates the push notification settings for the current user.
  Future<void> updatePushNotificationSettingsInTheServer() async {
    state = state.copyWith(
      updatePushNotificationSettingsState:
          const UpdatePushNotificationSettingsState.loading(),
    );

    final result = await _userService.updatePushNotificationSettings(
      pushNotificationSettings: state.pushNotificationSettings,
    );
    if (!mounted) return;

    result.when(
      (settings) {
        state = state.copyWith(
          updatePushNotificationSettingsState:
              UpdatePushNotificationSettingsState.success(),
        );
      },
      (error) {
        state = state.copyWith(
          updatePushNotificationSettingsState:
              UpdatePushNotificationSettingsState.error(error),
        );
      },
    );
  }

  /// Updates [ManageNotificationsProviderState.pushNotificationSettings] with the given [settings].
  void updatePushNotificationSettings(final PushNotificationSettings settings) {
    state = state.copyWith(
      pushNotificationSettings: settings,
    );

    updatePushNotificationSettingsInTheServer();
  }

  /// Updates the AWS Emergency filter state.
  void updateAwsEmergency(bool value) {
    updatePushNotificationSettings(
      state.pushNotificationSettings.copyWith(
        awsEmergency: value,
      ),
    );
  }

  /// Updates the AWS Watch and Act filter state.
  void updateAwsWatchAndAct(bool value) {
    updatePushNotificationSettings(
      state.pushNotificationSettings.copyWith(
        awsWatchAndAct: value,
      ),
    );
  }

  /// Updates the AWS Advice filter state.
  void updateAwsAdvice(bool value) {
    updatePushNotificationSettings(
      state.pushNotificationSettings.copyWith(
        awsAdvice: value,
      ),
    );
  }

  /// Updates the Official Non-AWS filter state.
  void updateOfficialNonAws(bool value) {
    updatePushNotificationSettings(
      state.pushNotificationSettings.copyWith(
        officialNonAws: value,
      ),
    );
  }

  /// Updates the User Reported filter state.
  void updateUserReported(bool value) {
    updatePushNotificationSettings(
      state.pushNotificationSettings.copyWith(
        userReported: value,
      ),
    );
  }

  /// Updates all available category IDs.
  void updateAllCategories(Set<String> categoryIds) {
    updatePushNotificationSettings(
      state.pushNotificationSettings.copyWith(
        subscribedCategoryIds: categoryIds,
      ),
    );
  }

  /// Updates the selected category IDs.
  void updateSelectedCategories(Set<String> categoryIds) {
    updatePushNotificationSettings(
      state.pushNotificationSettings.copyWith(
        subscribedCategoryIds: categoryIds,
      ),
    );
  }

  /// Adds a category ID to the selected categories.
  void addSelectedCategory(String categoryId) {
    final updatedSet = Set<String>.from(
      state.pushNotificationSettings.subscribedCategoryIds,
    );
    updatedSet.add(categoryId);
    updateSelectedCategories(updatedSet);
  }

  /// Removes a category ID from the selected categories.
  void removeSelectedCategory(String categoryId) {
    final updatedSet = Set<String>.from(
      state.pushNotificationSettings.subscribedCategoryIds,
    );
    updatedSet.remove(categoryId);
    updateSelectedCategories(updatedSet);
  }

  /// Toggles a category selection.
  void toggleCategory(String categoryId) {
    if (state.pushNotificationSettings.subscribedCategoryIds.contains(
      categoryId,
    )) {
      removeSelectedCategory(categoryId);
    } else {
      addSelectedCategory(categoryId);
    }
  }
}
