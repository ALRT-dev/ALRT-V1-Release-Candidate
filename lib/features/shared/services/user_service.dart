import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/api/interceptors/auth_interceptor.dart';
import 'package:hazard_app/features/notification/models/push_notification_settings_model.dart';
import 'package:hazard_app/features/shared/enums/alrt_media_source_types.dart';
import 'package:hazard_app/features/shared/enums/alrt_media_types.dart';
import 'package:hazard_app/features/shared/models/alrt_media_model.dart';
import 'package:hazard_app/features/shared/models/app_user_model.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/models/location_subscription_model.dart';
import 'package:hazard_app/features/shared/providers/dio_instance_provider.dart';
import 'package:hazard_app/features/shared/providers/repository_providers.dart';
import 'package:hazard_app/features/shared/repositories/shared_prefs_repository.dart';
import 'package:hazard_app/features/shared/repositories/user_repository.dart';
import 'package:hazard_app/features/shared/utils/either.dart';
import 'package:uuid/uuid.dart';

class UserService {
  const UserService(final Ref ref) : _ref = ref;

  final Ref _ref;
  UserRepository get _userRepository => _ref.read(providerOfUserRepository);
  Dio get _dio => _ref.read(providerOfDioInstance(false));
  SharedPreferencesRepository get _sharedPrefRepository =>
      _ref.read(providerOfSharedPreferencesRepository);

  /// Fetches the current logged-in user.
  Future<Either<AppUser, AppError>> getCurrentUser() async {
    final accessToken = await AuthInterceptor(
      dio: _dio,
      sharedPreferencesRepository: _sharedPrefRepository,
    ).getAccessToken();

    if (accessToken == null) {
      return Failure(
        AppError(message: 'No access token found'),
      );
    }

    log('Access Token :: $accessToken');

    final result = await _userRepository.getCurrentUser();

    final success = await result.whenSuccess(populateUserWithRequiredData);

    return result.copyWith(
      success: (_) => success,
    );
  }

  /// Updates the current logged-in user.
  Future<Either<AppUser, AppError>> updateCurrentUser({
    required final AppUser user,
    final CancelToken? cancelToken,
  }) async {
    final result = await _userRepository.updateCurrentUser(
      user: user,
      cancelToken: cancelToken,
    );

    final success = await result.whenSuccess(populateUserWithRequiredData);

    return result.copyWith(
      success: (_) => success,
    );
  }

  /// Updates the profile picture of the current logged-in user.
  Future<Either<AppUser, AppError>> updateUserProfilePicture({
    required AlrtMedia profilePicture,
    final void Function(int, int)? onSendProgress,
  }) async {
    final result = await _userRepository.updateUserProfilePicture(
      profilePicture: profilePicture,
      onSendProgress: onSendProgress,
    );

    final success = await result.whenSuccess(populateUserWithRequiredData);

    return result.copyWith(
      success: (_) => success,
    );
  }

  /// Subscribes the current user to location.
  Future<Either<LocationSubscription, AppError>> subscribeToLocation({
    required double northeastLat,
    required double northeastLng,
    required double southwestLat,
    required double southwestLng,
    String? name,
    String? address,
  }) {
    return _userRepository.subscribeToLocation(
      northeastLat: northeastLat,
      northeastLng: northeastLng,
      southwestLat: southwestLat,
      southwestLng: southwestLng,
      name: name,
      address: address,
    );
  }

  /// Unsubscribes the current user from location.
  Future<Either<void, AppError>> unsubscribeFromLocation({
    required String subscriptionId,
  }) {
    return _userRepository.unsubscribeFromLocation(
      subscriptionId: subscriptionId,
    );
  }

  /// Fetches the location subscriptions of the current user.
  Future<Either<List<LocationSubscription>, AppError>>
  getLocationSubscriptions() {
    return _userRepository.getLocationSubscriptions();
  }

  /// Updates the own location subscription of the current user.
  Future<Either<LocationSubscription, AppError>> updateOwnLocationSubscription({
    required final double latitude,
    required final double longitude,
    final String? locationName,
  }) {
    return _userRepository.updateOwnLocationSubscription(
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
    );
  }

  /// Updates the own location subscription radius of the current user.
  Future<Either<LocationSubscription, AppError>>
  updateOwnLocationSubscriptionRadius({
    required final double radiusKm,
  }) {
    return _userRepository.updateOwnLocationSubscriptionRadius(
      radiusKm: radiusKm,
    );
  }

  /// Fetches the push notification settings of the current user.
  Future<Either<PushNotificationSettings, AppError>>
  getPushNotificationSettings() {
    return _userRepository.getPushNotificationSettings();
  }

  /// Updates the push notification settings of the current user.
  Future<Either<PushNotificationSettings, AppError>>
  updatePushNotificationSettings({
    required final PushNotificationSettings pushNotificationSettings,
  }) {
    return _userRepository.updatePushNotificationSettings(
      pushNotificationSettings: pushNotificationSettings,
    );
  }

  /// Deletes the current user's account.
  Future<Either<void, AppError>> deleteAccount() {
    return _userRepository.deleteAccount();
  }

  /// Cancels the scheduled account deletion.
  Future<Either<void, AppError>> cancelAccountDeletion() {
    return _userRepository.cancelAccountDeletion();
  }

  /// Populates the given [appUser] with required data such as processed profile picture.
  Future<AppUser> populateUserWithRequiredData(final AppUser appUser) async {
    return appUser.copyWith(
      processedProfilePicture: appUser.profilePictureUrl == null
          ? null
          : AlrtMedia(
              id: appUser.id ?? const Uuid().v4(),
              value: appUser.profilePictureUrl!,
              type: AlrtMediaType.image,
              source: AlrtMediaSource.networkUrl,
            ),
    );
  }
}
