import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/notification/providers/notifications_feed_provider.dart';
import 'package:hazard_app/features/onboarding/providers/service_providers.dart';
import 'package:hazard_app/features/onboarding/services/onboarding_service.dart';
import 'package:hazard_app/features/profile/providers/states/my_location_subscriptions_provider_state.dart';
import 'package:hazard_app/features/shared/models/location_subscription_model.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/features/shared/services/user_service.dart';
import 'package:uuid/uuid.dart';

final providerOfMyLocationSubscriptions =
    StateNotifierProvider.autoDispose<
      MyLocationSubscriptionsProvider,
      MyLocationSubscriptionsProviderState
    >(
      (ref) => MyLocationSubscriptionsProvider(
        ref: ref,
        state: MyLocationSubscriptionsProviderState(),
      ),
    );

class MyLocationSubscriptionsProvider
    extends StateNotifier<MyLocationSubscriptionsProviderState> {
  MyLocationSubscriptionsProvider({
    required final Ref ref,
    required final MyLocationSubscriptionsProviderState state,
  }) : _ref = ref,
       super(state) {
    getLocationSubscriptions();
  }

  final Ref _ref;
  UserService get _userService => _ref.read(providerOfUserService);
  NotificationsFeedProvider get _notificationsFeedProvider =>
      _ref.read(providerOfNotificationsFeed.notifier);

  OnboardingService get _onboardingService =>
      _ref.read(providerOfOnboardingService);

  /// Fetches the location subscriptions for the current user.
  Future<void> getLocationSubscriptions() async {
    state = state.copyWith(
      getLocationSubscriptionsState:
          const GetLocationSubscriptionsState.loading(),
    );

    final result = await _userService.getLocationSubscriptions();
    if (!mounted) return;

    result.when(
      (subscriptions) {
        state = state.copyWith(
          locationSubscriptions: subscriptions,
          getLocationSubscriptionsState: GetLocationSubscriptionsState.success(
            subscriptions,
          ),
        );
      },
      (error) {
        state = state.copyWith(
          getLocationSubscriptionsState: GetLocationSubscriptionsState.error(
            error,
          ),
        );
      },
    );
  }

  /// Subscribes to the given [location].
  Future<void> subscribeToLocation({
    required final AlrtLocation location,
  }) async {
    final locationSubscription = LocationSubscription(
      northeastLat: location.bounds!.northeastLat,
      northeastLng: location.bounds!.northeastLng,
      southwestLat: location.bounds!.southwestLat,
      southwestLng: location.bounds!.southwestLng,
      name: location.name,
      address: location.address,
    );

    final subscribeToLocationStateWrapper = SubscribeToLocationStateWrapper(
      id: Uuid().v1(),
      locationSubscription: locationSubscription,
      subscribeToLocationState: const SubscribeToLocationState.loading(),
    );
    state = state.copyWith(
      subscribeToLocationStateWrappers: [
        ...state.subscribeToLocationStateWrappers,
        subscribeToLocationStateWrapper,
      ],
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
        state = state.copyWith(
          subscribeToLocationStateWrappers: state
              .subscribeToLocationStateWrappers
              .map((wrapper) {
                if (wrapper.id == subscribeToLocationStateWrapper.id) {
                  return wrapper.copyWith(
                    locationSubscription: subscription,
                    subscribeToLocationState:
                        SubscribeToLocationState.success(),
                  );
                }
                return wrapper;
              })
              .toList(),
        );

        addLocationSubscription(locationSubscription);

        // after subscribing to a location, refresh the notifications feed
        _notificationsFeedProvider.getNotificationsFeedHazards();
      },
      (error) {
        state = state.copyWith(
          subscribeToLocationStateWrappers: state
              .subscribeToLocationStateWrappers
              .map((wrapper) {
                if (wrapper.id == subscribeToLocationStateWrapper.id) {
                  return wrapper.copyWith(
                    subscribeToLocationState: SubscribeToLocationState.error(
                      error,
                    ),
                  );
                }
                return wrapper;
              })
              .toList(),
        );
      },
    );
  }

  /// Unsubscribes from the subscription with the given [subscriptionId].
  Future<void> unsubscribeFromLocation({
    required final String subscriptionId,
  }) async {
    final unsubscribeFromLocationStateWrapper =
        UnsubscribeFromLocationStateWrapper(
          id: Uuid().v1(),
          subscriptionId: subscriptionId,
          unsubscribeFromLocationState:
              const UnsubscribeFromLocationState.loading(),
        );
    state = state.copyWith(
      unsubscribeFromLocationStateWrappers: [
        ...state.unsubscribeFromLocationStateWrappers,
        unsubscribeFromLocationStateWrapper,
      ],
    );

    final result = await _userService.unsubscribeFromLocation(
      subscriptionId: subscriptionId,
    );
    if (!mounted) return;

    result.when(
      (_) {
        state = state.copyWith(
          unsubscribeFromLocationStateWrappers: state
              .unsubscribeFromLocationStateWrappers
              .map((wrapper) {
                if (wrapper.id == unsubscribeFromLocationStateWrapper.id) {
                  return wrapper.copyWith(
                    unsubscribeFromLocationState:
                        const UnsubscribeFromLocationState.success(),
                  );
                }
                return wrapper;
              })
              .toList(),
        );

        removeLocationSubscription(subscriptionId);

        // after unsubscribing from a location, refresh the notifications feed
        _notificationsFeedProvider.getNotificationsFeedHazards();
      },
      (error) {
        state = state.copyWith(
          unsubscribeFromLocationStateWrappers: state
              .unsubscribeFromLocationStateWrappers
              .map((wrapper) {
                if (wrapper.id == unsubscribeFromLocationStateWrapper.id) {
                  return wrapper.copyWith(
                    unsubscribeFromLocationState:
                        UnsubscribeFromLocationState.error(error),
                  );
                }
                return wrapper;
              })
              .toList(),
        );
      },
    );
  }

  /// Updates the location subscription's location.
  Future<void> updateLocationSubscriptionLocation({
    required final AlrtLocation newLocation,
  }) async {
    state = state.copyWith(
      updateUserLocationSubscriptionLocationState:
          const UpdateUserLocationSubscriptionLocationState.loading(),
    );

    final result = await _onboardingService.setOnboardingLocation(
      latitude: newLocation.latitude,
      longitude: newLocation.longitude,
      locationName: newLocation.name,
    );
    if (!mounted) return;

    result.when(
      (_) {
        state = state.copyWith(
          updateUserLocationSubscriptionLocationState:
              const UpdateUserLocationSubscriptionLocationState.success(),
        );

        // Refresh the location subscriptions
        getLocationSubscriptions();

        // after updating a location subscription, refresh the notifications feed
        _notificationsFeedProvider.getNotificationsFeedHazards();
      },
      (error) {
        state = state.copyWith(
          updateUserLocationSubscriptionLocationState:
              UpdateUserLocationSubscriptionLocationState.error(error),
        );
      },
    );
  }

  /// Updates the location subscription's radius.
  Future<void> updateLocationSubscriptionRadius({
    required final double newRadiusInKm,
  }) async {
    state = state.copyWith(
      updateUserLocationSubscriptionRadiusState:
          const UpdateUserLocationSubscriptionRadiusState.loading(),
    );
    final result = await _userService.updateOwnLocationSubscriptionRadius(
      radiusKm: newRadiusInKm,
    );
    if (!mounted) return;

    result.when(
      (_) {
        state = state.copyWith(
          updateUserLocationSubscriptionRadiusState:
              const UpdateUserLocationSubscriptionRadiusState.success(),
        );

        // update the logged in user's ownLocationSubscriptionRadiusKm
        _ref
            .read(providerOfLoggedInUser.notifier)
            .update(
              (user) => user?.copyWith(
                ownLocationSubscriptionRadiusKm: newRadiusInKm.toInt(),
              ),
            );

        // Refresh the location subscriptions
        getLocationSubscriptions();

        // after updating a location subscription, refresh the notifications feed
        _notificationsFeedProvider.getNotificationsFeedHazards();
      },
      (error) {
        state = state.copyWith(
          updateUserLocationSubscriptionRadiusState:
              UpdateUserLocationSubscriptionRadiusState.error(error),
        );
      },
    );
  }

  /// Updates [MyLocationSubscriptionsProviderState.locationSubscriptions]  with the given [locationSubscriptions].
  void updateLocationSubscriptions({
    required final List<LocationSubscription> locationSubscriptions,
  }) {
    state = state.copyWith(
      locationSubscriptions: locationSubscriptions,
    );
  }

  /// Adds the given [locationSubscription] to [MyLocationSubscriptionsProviderState.locationSubscriptions].
  void addLocationSubscription(
    final LocationSubscription locationSubscription,
  ) {
    final updatedLocationSubscriptions = [
      locationSubscription,
      ...state.locationSubscriptions,
    ];

    // sort isOwnLocation subscriptions first
    updatedLocationSubscriptions.sort(
      (a, b) {
        if (a.isOwnLocation && !b.isOwnLocation) {
          return -1;
        } else if (!a.isOwnLocation && b.isOwnLocation) {
          return 1;
        } else {
          return 0;
        }
      },
    );

    updateLocationSubscriptions(
      locationSubscriptions: updatedLocationSubscriptions,
    );
  }

  /// Removes the location subscription with the given [subscriptionId] from [MyLocationSubscriptionsProviderState.locationSubscriptions].
  void removeLocationSubscription(final String subscriptionId) {
    updateLocationSubscriptions(
      locationSubscriptions: state.locationSubscriptions
          .where((subscription) => subscription.id != subscriptionId)
          .toList(),
    );
  }

  /// Updates the user's own location subscription based on the logged in user's location and radius.
  void updateOwnLocationSubscription() {
    final latitude = _ref.read(providerOfLoggedInUser)?.latitude;
    final longitude = _ref.read(providerOfLoggedInUser)?.longitude;
    final locationName = _ref.read(providerOfLoggedInUser)?.locationName;
    final radiusKm = _ref
        .read(providerOfLoggedInUser)
        ?.ownLocationSubscriptionRadiusKm;

    if (latitude != null && longitude != null && radiusKm != null) {
      // Calculate bounding box for the subscription area
      // The frontend calculates radius as distance from center to corner (diagonal)
      // For a square bounding box, corner distance = edge distance * √2
      // So we need to divide the radius by √2 to get the edge distance
      final earthRadiusKm = 6371.0;
      final edgeRadiusKm = radiusKm / sqrt(2);

      // Convert latitude to radians
      final latRad = (latitude * pi) / 180;

      // Calculate angular distance in radians
      final angularDistance = edgeRadiusKm / earthRadiusKm;

      // Calculate latitude delta (same in all directions)
      final latDelta = (angularDistance * 180) / pi;

      // Calculate longitude delta (varies with latitude)
      final lngDelta = (angularDistance * 180) / pi / cos(latRad);

      final northeastLat = latitude + latDelta;
      final northeastLng = longitude + lngDelta;
      final southwestLat = latitude - latDelta;
      final southwestLng = longitude - lngDelta;

      final index = state.locationSubscriptions.indexWhere(
        (subscription) => subscription.isOwnLocation,
      );
      if (index != -1) {
        final updatedLocationSubscription = state.locationSubscriptions[index]
            .copyWith(
              northeastLat: northeastLat,
              northeastLng: northeastLng,
              southwestLat: southwestLat,
              southwestLng: southwestLng,
              name: locationName,
            );
        updateLocationSubscriptions(
          locationSubscriptions: state.locationSubscriptions.map((
            subscription,
          ) {
            if (subscription.isOwnLocation) {
              return updatedLocationSubscription;
            }
            return subscription;
          }).toList(),
        );
      } else {
        addLocationSubscription(
          LocationSubscription(
            isOwnLocation: true,
            northeastLat: northeastLat,
            northeastLng: northeastLng,
            southwestLat: southwestLat,
            southwestLng: southwestLng,
            name: locationName,
            createdAt: DateTime.now(),
          ),
        );
      }
    }
  }
}
