import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hazard_app/api/rest_client.dart';
import 'package:hazard_app/features/notification/models/push_notification_settings_model.dart';
import 'package:hazard_app/features/shared/enums/alrt_media_source_types.dart';
import 'package:hazard_app/features/shared/models/alrt_media_model.dart';
import 'package:hazard_app/features/shared/models/app_user_model.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/models/location_subscription_model.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

abstract class UserRepository {
  Future<Either<AppUser, AppError>> getCurrentUser();

  Future<Either<AppUser, AppError>> updateCurrentUser({
    required final AppUser user,
    final CancelToken? cancelToken,
  });

  Future<Either<AppUser, AppError>> updateUserProfilePicture({
    required final AlrtMedia profilePicture,
    void Function(int, int)? onSendProgress,
  });

  Future<Either<LocationSubscription, AppError>> subscribeToLocation({
    required final double northeastLat,
    required final double northeastLng,
    required final double southwestLat,
    required final double southwestLng,
    final String? name,
    final String? address,
  });

  Future<Either<void, AppError>> unsubscribeFromLocation({
    required final String subscriptionId,
  });

  Future<Either<List<LocationSubscription>, AppError>>
  getLocationSubscriptions();

  Future<Either<LocationSubscription, AppError>> updateOwnLocationSubscription({
    required final double latitude,
    required final double longitude,
    final String? locationName,
  });

  Future<Either<LocationSubscription, AppError>>
  updateOwnLocationSubscriptionRadius({
    required final double radiusKm,
  });

  Future<Either<PushNotificationSettings, AppError>>
  getPushNotificationSettings();

  Future<Either<PushNotificationSettings, AppError>>
  updatePushNotificationSettings({
    required final PushNotificationSettings pushNotificationSettings,
  });

  Future<Either<void, AppError>> deleteAccount();

  Future<Either<void, AppError>> cancelAccountDeletion();
}

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    required RestClient restClient,
  }) : _restClient = restClient;

  final RestClient _restClient;

  @override
  Future<Either<AppUser, AppError>> getCurrentUser() {
    return runAsyncCall(
      name: 'getCurrentUser',
      future: () async {
        final result = await _restClient.getCurrentUser();
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<AppUser, AppError>> updateCurrentUser({
    required AppUser user,
    CancelToken? cancelToken,
  }) {
    return runAsyncCall(
      name: 'updateCurrentUser',
      future: () async {
        final result = await _restClient.updateCurrentUser(
          user: user,
          cancelToken: cancelToken,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<AppUser, AppError>> updateUserProfilePicture({
    required AlrtMedia profilePicture,
    void Function(int, int)? onSendProgress,
  }) {
    return runAsyncCall(
      name: 'updateUserProfilePicture',
      future: () async {
        if (profilePicture.source != AlrtMediaSource.file) {
          throw AppError(
            message: 'Profile picture must be a file.',
          );
        }

        final result = await _restClient.updateUserProfilePicture(
          profilePictureFile: File(profilePicture.value),
          onSendProgress: onSendProgress,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<LocationSubscription, AppError>> subscribeToLocation({
    required double northeastLat,
    required double northeastLng,
    required double southwestLat,
    required double southwestLng,
    String? name,
    String? address,
  }) {
    return runAsyncCall(
      name: 'subscribeToLocation',
      future: () async {
        final result = await _restClient.subscribeToLocation(
          northeastLat: northeastLat,
          northeastLng: northeastLng,
          southwestLat: southwestLat,
          southwestLng: southwestLng,
          name: name,
          address: address,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> unsubscribeFromLocation({
    required String subscriptionId,
  }) {
    return runAsyncCall(
      name: 'unsubscribeFromLocation',
      future: () async {
        await _restClient.unsubscribeFromLocation(
          subscriptionId: subscriptionId,
        );
        return Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<List<LocationSubscription>, AppError>>
  getLocationSubscriptions() {
    return runAsyncCall(
      name: 'getLocationSubscriptions',
      future: () async {
        final result = await _restClient.getLocationSubscriptions();
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<PushNotificationSettings, AppError>>
  getPushNotificationSettings() {
    return runAsyncCall(
      name: 'getPushNotificationSettings',
      future: () async {
        final result = await _restClient.getPushNotificationSettings();
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<PushNotificationSettings, AppError>>
  updatePushNotificationSettings({
    required PushNotificationSettings pushNotificationSettings,
  }) {
    return runAsyncCall(
      name: 'updatePushNotificationSettings',
      future: () async {
        final result = await _restClient.updatePushNotificationSettings(
          pushNotificationSettings: pushNotificationSettings,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<LocationSubscription, AppError>> updateOwnLocationSubscription({
    required double latitude,
    required double longitude,
    String? locationName,
  }) {
    return runAsyncCall(
      name: 'updateOwnLocationSubscription',
      future: () async {
        final result = await _restClient.updateOwnLocationSubscription(
          latitude: latitude,
          longitude: longitude,
          locationName: locationName,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<LocationSubscription, AppError>>
  updateOwnLocationSubscriptionRadius({required double radiusKm}) {
    return runAsyncCall(
      name: 'updateOwnLocationSubscriptionRadius',
      future: () async {
        final result = await _restClient.updateOwnLocationSubscriptionRadius(
          radiusKm: radiusKm,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> deleteAccount() {
    return runAsyncCall(
      name: 'deleteAccount',
      future: () async {
        await _restClient.deleteAccount();
        return Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> cancelAccountDeletion() {
    return runAsyncCall(
      name: 'cancelAccountDeletion',
      future: () async {
        await _restClient.cancelAccountDeletion();
        return Success(null);
      },
      onError: Failure.new,
    );
  }
}
