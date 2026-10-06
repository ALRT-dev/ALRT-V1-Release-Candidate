import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/models/location_subscription_model.dart';

part 'main_search_provider_state.freezed.dart';

@freezed
abstract class MainSearchProviderState with _$MainSearchProviderState {
  const factory MainSearchProviderState({
    /// The location selected from the search results.
    final AlrtLocation? searchedLocation,

    /// The hazards fetched from the search results after a successful fetch.
    @Default(<Hazard>[]) final List<Hazard> hazards,

    /// The current page of hazards being viewed.
    @Default(1) final int currentPage,

    /// The ID of the subscription to the current searched location.
    final String? subscriptionId,

    /// The state of fetching hazards by location.
    @Default(GetHazardsByLocationState.initial())
    final GetHazardsByLocationState getHazardsByLocationState,

    /// The state of fetching the next page of hazards by location.
    @Default(GetHazardsByLocationState.initial())
    final GetHazardsByLocationState getNextHazardsByLocationState,

    /// The state of subscribing to location.
    @Default(SubscribeToLocationState.initial())
    final SubscribeToLocationState subscribeToLocationState,

    /// The state of unsubscribing from location.
    @Default(UnsubscribeFromLocationState.initial())
    final UnsubscribeFromLocationState unsubscribeFromLocationState,
  }) = _MainSearchProviderState;
}

@freezed
class GetHazardsByLocationState with _$GetHazardsByLocationState {
  const factory GetHazardsByLocationState.initial() =
      _GetHazardsByLocationStateInitial;
  const factory GetHazardsByLocationState.loading() =
      _GetHazardsByLocationStateLoading;
  const factory GetHazardsByLocationState.success(
    final List<Hazard> hazards,
  ) = _GetHazardsByLocationStateSuccess;
  const factory GetHazardsByLocationState.error(
    final AppError error,
  ) = _GetHazardsByLocationStateError;
}

@freezed
class SubscribeToLocationState with _$SubscribeToLocationState {
  const factory SubscribeToLocationState.initial() =
      _SubscribeToLocationStateInitial;
  const factory SubscribeToLocationState.loading() =
      _SubscribeToLocationStateLoading;
  const factory SubscribeToLocationState.success(
    final LocationSubscription subscription,
  ) = _SubscribeToLocationStateSuccess;
  const factory SubscribeToLocationState.error(
    final AppError error,
  ) = _SubscribeToLocationStateError;
}

@freezed
class UnsubscribeFromLocationState with _$UnsubscribeFromLocationState {
  const factory UnsubscribeFromLocationState.initial() =
      _UnsubscribeFromLocationStateInitial;
  const factory UnsubscribeFromLocationState.loading() =
      _UnsubscribeFromLocationStateLoading;
  const factory UnsubscribeFromLocationState.success() =
      _UnsubscribeFromLocationStateSuccess;
  const factory UnsubscribeFromLocationState.error(
    final AppError error,
  ) = _UnsubscribeFromLocationStateError;
}
