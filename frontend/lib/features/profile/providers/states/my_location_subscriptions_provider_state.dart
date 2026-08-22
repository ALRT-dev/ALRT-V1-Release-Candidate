import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/models/location_subscription_model.dart';

part 'my_location_subscriptions_provider_state.freezed.dart';

@freezed
abstract class MyLocationSubscriptionsProviderState
    with _$MyLocationSubscriptionsProviderState {
  const factory MyLocationSubscriptionsProviderState({
    /// The list of location subscriptions of the user.
    @Default(<LocationSubscription>[])
    final List<LocationSubscription> locationSubscriptions,

    /// The state of getting location subscriptions.
    @Default(GetLocationSubscriptionsState.initial())
    final GetLocationSubscriptionsState getLocationSubscriptionsState,

    /// The state of subscribing to a location.
    @Default(<SubscribeToLocationStateWrapper>[])
    final List<SubscribeToLocationStateWrapper>
    subscribeToLocationStateWrappers,

    /// The state of unsubscribing from a location.
    @Default(<UnsubscribeFromLocationStateWrapper>[])
    final List<UnsubscribeFromLocationStateWrapper>
    unsubscribeFromLocationStateWrappers,

    /// The state of updating a location subscription's location.
    @Default(UpdateUserLocationSubscriptionLocationState.initial())
    final UpdateUserLocationSubscriptionLocationState
    updateUserLocationSubscriptionLocationState,

    /// The state of updating a location subscription's radius.
    @Default(UpdateUserLocationSubscriptionRadiusState.initial())
    final UpdateUserLocationSubscriptionRadiusState
    updateUserLocationSubscriptionRadiusState,
  }) = _MyLocationSubscriptionsProviderState;
}

@freezed
class GetLocationSubscriptionsState with _$GetLocationSubscriptionsState {
  const factory GetLocationSubscriptionsState.initial() =
      _GetLocationSubscriptionsStateInitial;
  const factory GetLocationSubscriptionsState.loading() =
      _GetLocationSubscriptionsStateLoading;
  const factory GetLocationSubscriptionsState.success(
    final List<LocationSubscription> locationSubscriptions,
  ) = _GetLocationSubscriptionsStateSuccess;
  const factory GetLocationSubscriptionsState.error(
    final AppError error,
  ) = _GetLocationSubscriptionsStateError;
}

@freezed
abstract class SubscribeToLocationStateWrapper
    with _$SubscribeToLocationStateWrapper {
  const factory SubscribeToLocationStateWrapper({
    required final String id,
    required final LocationSubscription locationSubscription,
    required final SubscribeToLocationState subscribeToLocationState,
  }) = _SubscribeToLocationStateWrapper;
}

@freezed
abstract class UnsubscribeFromLocationStateWrapper
    with _$UnsubscribeFromLocationStateWrapper {
  const factory UnsubscribeFromLocationStateWrapper({
    required final String id,
    required final String subscriptionId,
    required final UnsubscribeFromLocationState unsubscribeFromLocationState,
  }) = _UnsubscribeFromLocationStateWrapper;
}

@freezed
class SubscribeToLocationState with _$SubscribeToLocationState {
  const factory SubscribeToLocationState.loading() =
      _SubscribeToLocationStateLoading;
  const factory SubscribeToLocationState.success() =
      _SubscribeToLocationStateSuccess;
  const factory SubscribeToLocationState.error(
    final AppError error,
  ) = _SubscribeToLocationStateError;
}

@freezed
class UnsubscribeFromLocationState with _$UnsubscribeFromLocationState {
  const factory UnsubscribeFromLocationState.loading() =
      _UnsubscribeFromLocationStateLoading;
  const factory UnsubscribeFromLocationState.success() =
      _UnsubscribeFromLocationStateSuccess;
  const factory UnsubscribeFromLocationState.error(
    final AppError error,
  ) = _UnsubscribeFromLocationStateError;
}

@freezed
class UpdateUserLocationSubscriptionLocationState
    with _$UpdateUserLocationSubscriptionLocationState {
  const factory UpdateUserLocationSubscriptionLocationState.initial() =
      _UpdateUserLocationSubscriptionLocationStateInitial;
  const factory UpdateUserLocationSubscriptionLocationState.loading() =
      _UpdateUserLocationSubscriptionLocationStateLoading;
  const factory UpdateUserLocationSubscriptionLocationState.success() =
      _UpdateUserLocationSubscriptionLocationStateSuccess;
  const factory UpdateUserLocationSubscriptionLocationState.error(
    final AppError error,
  ) = _UpdateUserLocationSubscriptionLocationStateError;
}

@freezed
class UpdateUserLocationSubscriptionRadiusState
    with _$UpdateUserLocationSubscriptionRadiusState {
  const factory UpdateUserLocationSubscriptionRadiusState.initial() =
      _UpdateUserLocationSubscriptionRadiusStateInitial;
  const factory UpdateUserLocationSubscriptionRadiusState.loading() =
      _UpdateUserLocationSubscriptionRadiusStateLoading;
  const factory UpdateUserLocationSubscriptionRadiusState.success() =
      _UpdateUserLocationSubscriptionRadiusStateSuccess;
  const factory UpdateUserLocationSubscriptionRadiusState.error(
    final AppError error,
  ) = _UpdateUserLocationSubscriptionRadiusStateError;
}
