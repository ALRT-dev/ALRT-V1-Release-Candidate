import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/map/utils/constants.dart';
import 'package:hazard_app/features/shared/models/app_user_model.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/utils/location_helper.dart';

part 'location_permission_provider_state.freezed.dart';

@freezed
abstract class LocationProviderState with _$LocationProviderState {
  const LocationProviderState._();

  const factory LocationProviderState({
    /// Current user's location.
    ///
    /// Defaults to [kDefaultUserLocation].
    @Default(kDefaultUserLocation) final AlrtLocation location,

    /// Whether the app is using the device's location.
    @Default(false) final bool isUsingDeviceLocation,

    /// Cancel token for updating the user's location.
    required final CancelToken updateLocationCancelToken,

    /// The state of getting the current user's location.
    @Default(GetLocationState.initial())
    final GetLocationState getLocationState,

    /// The state of getting the location permission of the device.
    @Default(GetLocationPremissionState.initial())
    final GetLocationPremissionState getLocationPremissionState,

    /// The state of updating the user's location.
    @Default(UpdateUserLocationState.initial())
    final UpdateUserLocationState updateUserLocationState,
  }) = _LocationProviderState;

  /// Calculates the distance in meters from the user's location to another geographical point.
  double distanceTo(double otherLatitude, double otherLongitude) {
    return calculateDistanceInMeters(
      location.latitude,
      location.longitude,
      otherLatitude,
      otherLongitude,
    );
  }
}

@freezed
class GetLocationState with _$GetLocationState {
  const factory GetLocationState.initial() = GetLocationStateInitial;
  const factory GetLocationState.loading() = GetLocationStateLoading;
  const factory GetLocationState.success(
    final AlrtLocation location,
  ) = GetLocationStateSuccess;
  const factory GetLocationState.error(
    final AppError error,
  ) = GetLocationStateError;
}

@freezed
class GetLocationPremissionState with _$GetLocationPremissionState {
  const factory GetLocationPremissionState.initial() =
      GetLocationPremissionStateInitial;
  const factory GetLocationPremissionState.loading() =
      GetLocationPremissionStateLoading;
  const factory GetLocationPremissionState.success() =
      GetLocationPremissionStateSuccess;
  const factory GetLocationPremissionState.error(
    final AppError error,
  ) = GetLocationPremissionStateError;
}

@freezed
class UpdateUserLocationState with _$UpdateUserLocationState {
  const factory UpdateUserLocationState.initial() =
      UpdateUserLocationStateInitial;
  const factory UpdateUserLocationState.loading() =
      UpdateUserLocationStateLoading;
  const factory UpdateUserLocationState.success(
    final AppUser updatedUser,
  ) = UpdateUserLocationStateSuccess;
  const factory UpdateUserLocationState.error(
    final AppError error,
  ) = UpdateUserLocationStateError;
}
