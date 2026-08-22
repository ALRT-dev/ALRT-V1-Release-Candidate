import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/notification/providers/notifications_feed_provider.dart';
import 'package:hazard_app/features/profile/providers/my_location_subscriptions_provider.dart';
import 'package:hazard_app/features/search/models/hazard_search_params.dart';
import 'package:hazard_app/features/search/providers/states/main_search_provider_state.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/shared/providers/hazard_filters_provider.dart';
import 'package:hazard_app/features/shared/providers/hazard_socket_manager_provider.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/features/shared/services/hazard_service.dart';
import 'package:hazard_app/features/shared/providers/navigator_key_provider.dart';
import 'package:hazard_app/features/shared/services/user_service.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_paywall_screen.dart';

final providerOfMainSearch =
    StateNotifierProvider.autoDispose<
      MainSearchProvider,
      MainSearchProviderState
    >(
      (ref) => MainSearchProvider(
        ref: ref,
        state: MainSearchProviderState(),
      ),
    );

class MainSearchProvider extends StateNotifier<MainSearchProviderState> {
  MainSearchProvider({
    required final Ref ref,
    required final MainSearchProviderState state,
  }) : _ref = ref,
       super(state) {
    _listenToSocketForHazards();
  }

  final Ref _ref;

  HazardService get _hazardService => _ref.read(providerOfHazardService);
  UserService get _userService => _ref.read(providerOfUserService);
  NotificationsFeedProvider get _notificationsFeedProvider =>
      _ref.read(providerOfNotificationsFeed.notifier);
  MyLocationSubscriptionsProvider get _myLocationSubscriptionsProvider =>
      _ref.read(providerOfMyLocationSubscriptions.notifier);

  /// Listens to the global hazard streams for updates and deletions.
  void _listenToSocketForHazards() {
    final updateHazardSubscription = _ref
        .read(providerOfHazardSocketManager)
        .updateHazardStream
        .listen(updateHazard);

    final deleteHazardSubscription = _ref
        .read(providerOfHazardSocketManager)
        .deleteHazardStream
        .listen(removeFromHazards);

    // Clean up subscription when provider is disposed
    _ref.onDispose(() {
      updateHazardSubscription.cancel();
      deleteHazardSubscription.cancel();
    });
  }

  /// Fetches hazards for the given location and updates the state accordingly.
  Future<void> getHazards() async {
    final location = state.searchedLocation;
    if (location?.bounds == null) return;

    state = state.copyWith(
      getHazardsByLocationState: const GetHazardsByLocationState.loading(),
    );

    // Reset the current page to 1 when fetching initial hazards
    updateCurrentPage(1);

    final selectedCategoryIds = _ref
        .read(providerOfHazardFiltersForSearch)
        .selectedCategoryIds
        .toList();
    final awsEmergency = _ref
        .read(providerOfHazardFiltersForSearch)
        .awsEmergency;
    final awsWatchAndAct = _ref
        .read(providerOfHazardFiltersForSearch)
        .awsWatchAndAct;
    final awsAdvice = _ref.read(providerOfHazardFiltersForSearch).awsAdvice;
    final officialNonAws = _ref
        .read(providerOfHazardFiltersForSearch)
        .officialNonAws;
    final userReported = _ref
        .read(providerOfHazardFiltersForSearch)
        .userReported;

    final result = await _hazardService.getHazardsWithSubscriptionId(
      searchParams: HazardSearchParams(
        northeastLat: location!.bounds?.northeastLat,
        northeastLng: location.bounds?.northeastLng,
        southwestLat: location.bounds?.southwestLat,
        southwestLng: location.bounds?.southwestLng,
        categoryIds: selectedCategoryIds,
        awsEmergency: awsEmergency,
        awsWatchAndAct: awsWatchAndAct,
        awsAdvice: awsAdvice,
        officialNonAws: officialNonAws,
        userReported: userReported,
      ),
    );
    if (!mounted) return;

    result.when(
      (response) {
        state = state.copyWith(
          getHazardsByLocationState: GetHazardsByLocationState.success(
            response.hazards,
          ),
        );
        updateHazards(response.hazards);

        // update subscriptionId if there's an active subscription for this location
        updateSubscriptionId(response.subscriptionId);
      },
      (error) {
        state = state.copyWith(
          getHazardsByLocationState: GetHazardsByLocationState.error(error),
        );
      },
    );
  }

  /// Fetches the next page of hazards for the given location and updates the state accordingly.
  Future<void> getNextHazards() async {
    final location = state.searchedLocation;
    if (location?.bounds == null) return;

    final isLoading = state.getNextHazardsByLocationState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isLoading) return; // Prevent multiple simultaneous fetches

    state = state.copyWith(
      getNextHazardsByLocationState: const GetHazardsByLocationState.loading(),
    );

    final selectedCategoryIds = _ref
        .read(providerOfHazardFiltersForSearch)
        .selectedCategoryIds
        .toList();
    final awsEmergency = _ref
        .read(providerOfHazardFiltersForSearch)
        .awsEmergency;
    final awsWatchAndAct = _ref
        .read(providerOfHazardFiltersForSearch)
        .awsWatchAndAct;
    final awsAdvice = _ref.read(providerOfHazardFiltersForSearch).awsAdvice;
    final officialNonAws = _ref
        .read(providerOfHazardFiltersForSearch)
        .officialNonAws;
    final userReported = _ref
        .read(providerOfHazardFiltersForSearch)
        .userReported;

    // Update the current page by 1, since we are fetching the next page
    updateCurrentPage(state.currentPage + 1);

    final result = await _hazardService.getHazardsWithSubscriptionId(
      searchParams: HazardSearchParams(
        northeastLat: location!.bounds?.northeastLat,
        northeastLng: location.bounds?.northeastLng,
        southwestLat: location.bounds?.southwestLat,
        southwestLng: location.bounds?.southwestLng,
        categoryIds: selectedCategoryIds,
        awsEmergency: awsEmergency,
        awsWatchAndAct: awsWatchAndAct,
        awsAdvice: awsAdvice,
        officialNonAws: officialNonAws,
        userReported: userReported,

        // Pass the updated current page
        page: state.currentPage,
      ),
    );
    if (!mounted) return;

    result.when(
      (response) {
        state = state.copyWith(
          getNextHazardsByLocationState: GetHazardsByLocationState.success(
            response.hazards,
          ),
        );
        addMultipleToHazards(response.hazards);
      },
      (error) {
        state = state.copyWith(
          getNextHazardsByLocationState: GetHazardsByLocationState.error(error),
        );
      },
    );
  }

  /// Subscribes to the current [MainSearchProviderState.searchedLocation].
  Future<void> subscribeToLocation() async {
    final location = state.searchedLocation;
    if (location == null) return;

    state = state.copyWith(
      subscribeToLocationState: const SubscribeToLocationState.loading(),
    );

    final result = await _userService.subscribeToLocation(
      northeastLat: location.bounds!.northeastLat,
      northeastLng: location.bounds!.northeastLng,
      southwestLat: location.bounds!.southwestLat,
      southwestLng: location.bounds!.southwestLng,
      name: location.name,
      address: location.address,
    );
    if (!mounted) return;

    result.when(
      (subscription) {
        updateSubscriptionId(subscription.id);
        state = state.copyWith(
          subscribeToLocationState: SubscribeToLocationState.success(
            subscription,
          ),
        );

        // add the new subscription to MyLocationSubscriptionsProvider
        _myLocationSubscriptionsProvider.addLocationSubscription(subscription);

        // after subscribing to a location, refresh the notifications feed
        _notificationsFeedProvider.getNotificationsFeedHazards();
      },
      (error) {
        state = state.copyWith(
          subscribeToLocationState: SubscribeToLocationState.error(error),
        );
      },
    );
  }

  /// Unsubscribes from the subscription with the given [subscriptionId].
  Future<void> unsubscribeFromLocation({
    required final String subscriptionId,
  }) async {
    final location = state.searchedLocation;
    if (location == null) return;

    state = state.copyWith(
      unsubscribeFromLocationState:
          const UnsubscribeFromLocationState.loading(),
    );

    final result = await _userService.unsubscribeFromLocation(
      subscriptionId: subscriptionId,
    );
    if (!mounted) return;

    result.when(
      (_) {
        updateSubscriptionId(null);
        state = state.copyWith(
          unsubscribeFromLocationState: UnsubscribeFromLocationState.success(),
        );

        // remove the subscription from MyLocationSubscriptionsProvider
        _myLocationSubscriptionsProvider.removeLocationSubscription(
          subscriptionId,
        );

        // after unsubscribing from a location, refresh the notifications feed
        _notificationsFeedProvider.getNotificationsFeedHazards();
      },
      (error) {
        state = state.copyWith(
          unsubscribeFromLocationState: UnsubscribeFromLocationState.error(
            error,
          ),
        );
      },
    );
  }

  /// Toggles the subscription state.
  Future<void> toggleSubscription() async {
    final subscriptionId = state.subscriptionId;
    if (subscriptionId == null) {
      // Free tier saves at most 1 location, no matter what; the second
      // save opens the ALRT+ paywall. Own-location follow never counts.
      final savedCount = _ref
          .read(providerOfMyLocationSubscriptions)
          .locationSubscriptions
          .where((subscription) => !subscription.isOwnLocation)
          .length;
      if (savedCount >= kFreeSavedLocationsLimit) {
        final isPlus = await _ref.read(providerOfAlrtPlus.future);
        if (!mounted) return;
        if (!isPlus) {
          final context = _ref
              .read(providerOfGlobalNavigatorKey)
              .currentContext;
          if (context == null || !context.mounted) return;
          final purchased = await context.push<bool>(
            AlrtPlusPaywallScreen.route,
          );
          if (!mounted || purchased != true) return;
        }
      }
      return subscribeToLocation();
    } else {
      return unsubscribeFromLocation(
        subscriptionId: subscriptionId,
      );
    }
  }

  /// Updates [MainSearchProviderState.searchedLocation] with the given [location].
  void updateSearchedLocation(final AlrtLocation? location) {
    state = state.copyWith(
      searchedLocation: location,
    );

    // every time the searched location is updated, reset the subscriptionId
    updateSubscriptionId(null);
  }

  /// Updates [MainSearchProviderState.hazards] with the given [hazards].
  void updateHazards(List<Hazard> hazards) {
    state = state.copyWith(
      hazards: hazards,
    );
  }

  /// Updates a single hazard in [MainSearchProviderState.hazards] with the given [updatedHazard].
  void updateHazard(final Hazard updatedHazard) {
    final updatedHazards = state.hazards.map((hazard) {
      if (hazard.id == updatedHazard.id) {
        return updatedHazard;
      }
      return hazard;
    }).toList();
    updateHazards(updatedHazards);
  }

  /// Adds multiple new hazards to the existing list of hazards in the state.
  ///
  /// If the hazard already exists (based on ID), it will be updated instead of added again.
  void addMultipleToHazards(final List<Hazard> newHazards) {
    final updatedHazards = List<Hazard>.from(state.hazards);
    for (final newHazard in newHazards) {
      final index = updatedHazards.indexWhere(
        (hazard) => hazard.id == newHazard.id,
      );
      if (index != -1) {
        // Hazard already exists, update it
        updatedHazards[index] = newHazard;
      } else {
        // Hazard does not exist, add it
        updatedHazards.add(newHazard);
      }
    }
    updateHazards(updatedHazards);
  }

  /// Adds a new hazard to the existing list of hazards in the state.
  void addToHazards(final Hazard newHazard) {
    final index = state.hazards.indexWhere(
      (hazard) => hazard.id == newHazard.id,
    );
    if (index != -1) return; // hazard already exists, do not add it again
    updateHazards([newHazard, ...state.hazards]);
  }

  /// Removes a hazard from the existing list of hazards in the state.
  void removeFromHazards(final String hazardId) {
    updateHazards(
      state.hazards.where((hazard) => hazard.id != hazardId).toList(),
    );
  }

  /// Updates [MainSearchProviderState.getHazardsByLocationState] to its initial state.
  void updateGetHazardsByLocationStateToInitial() {
    state = state.copyWith(
      getHazardsByLocationState: const GetHazardsByLocationState.initial(),
    );
    updateHazards([]);
  }

  /// Updates [MainSearchProviderState.subscriptionId] with the given [subscriptionId].
  void updateSubscriptionId(final String? subscriptionId) {
    state = state.copyWith(
      subscriptionId: subscriptionId,
    );
  }

  /// Updates [MainSearchProviderState.currentPage] with the given [currentPage].
  void updateCurrentPage(final int currentPage) {
    state = state.copyWith(
      currentPage: currentPage,
    );
  }
}
