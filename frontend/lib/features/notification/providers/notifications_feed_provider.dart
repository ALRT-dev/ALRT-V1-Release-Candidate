import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hazard_app/features/notification/providers/service_providers.dart';
import 'package:hazard_app/features/notification/providers/states/notifications_feed_provider_state.dart';
import 'package:hazard_app/features/notification/services/notification_service.dart';
import 'package:hazard_app/features/search/models/hazard_search_params.dart';
import 'package:hazard_app/features/shared/enums/hazard_review_status_types.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/providers/hazard_filters_provider.dart';
import 'package:hazard_app/features/shared/providers/hazard_socket_manager_provider.dart';

final providerOfNotificationsFeed =
    StateNotifierProvider.autoDispose<
      NotificationsFeedProvider,
      NotificationsFeedProviderState
    >(
      (ref) => NotificationsFeedProvider(
        ref: ref,
        state: NotificationsFeedProviderState(),
      ),
    );

class NotificationsFeedProvider
    extends StateNotifier<NotificationsFeedProviderState> {
  NotificationsFeedProvider({
    required final Ref ref,
    required final NotificationsFeedProviderState state,
  }) : _ref = ref,
       super(state) {
    getNotificationsFeedHazards();
    _listenToSocketForHazards();
  }

  final Ref _ref;

  NotificationService get _notificationService =>
      _ref.read(providerOfNotificationService);

  /// Listens to the socket for hazard updates, new hazards, and deletions.
  void _listenToSocketForHazards() {
    final newHazardSubscription = _ref
        .read(providerOfHazardSocketManager)
        .newHazardStream
        .listen((newHazard) {
          // if search string is not empty, check if the new hazard matches the search string
          // if it does, add it to the list of hazards
          // otherwise, ignore it
          if (state.searchString.isNotEmpty) {
            final title = newHazard.title ?? '';
            final description = newHazard.description ?? '';
            if (title.toLowerCase().contains(
                  state.searchString.toLowerCase(),
                ) ||
                description.toLowerCase().contains(
                  state.searchString.toLowerCase(),
                )) {
              addToHazards(newHazard);
            }
          } else {
            addToHazards(newHazard);
          }
        });

    final updateHazardSubscription = _ref
        .read(providerOfHazardSocketManager)
        .updateHazardStream
        .listen((updatedHazard) {
          if (updatedHazard.id != null) {
            if (updatedHazard.reviewStatus != HazardReviewStatus.accepted) {
              // If the updated hazard is not accepted, remove it from the list
              removeFromHazards(updatedHazard.id!);
            }
          }
        });

    final deleteHazardSubscription = _ref
        .read(providerOfHazardSocketManager)
        .deleteHazardStream
        .listen((hazardId) {
          removeFromHazards(hazardId);
        });

    // Clean up subscription when provider is disposed
    _ref.onDispose(() {
      newHazardSubscription.cancel();
      updateHazardSubscription.cancel();
      deleteHazardSubscription.cancel();
    });
  }

  /// Fetches the hazards that the user has subscribed to for notifications
  Future<void> getNotificationsFeedHazards() async {
    final selectedCategoryIds = _ref
        .read(providerOfHazardFiltersForNotifications)
        .selectedCategoryIds
        .toList();
    final selectedLocationIds = _ref
        .read(providerOfHazardFiltersForNotifications)
        .selectedLocationIds
        .toList();
    final awsEmergency = _ref
        .read(providerOfHazardFiltersForNotifications)
        .awsEmergency;
    final awsWatchAndAct = _ref
        .read(providerOfHazardFiltersForNotifications)
        .awsWatchAndAct;
    final awsAdvice = _ref
        .read(providerOfHazardFiltersForNotifications)
        .awsAdvice;
    final officialNonAws = _ref
        .read(providerOfHazardFiltersForNotifications)
        .officialNonAws;
    final userReported = _ref
        .read(providerOfHazardFiltersForNotifications)
        .userReported;

    state = state.copyWith(
      getNotificationsFeedHazardsState:
          const GetNotificationsFeedHazardsState.loading(),
    );

    // Reset current page to 1 when fetching the first page
    updateCurrentPage(1);

    final result = await _notificationService.getNotificationsFeed(
      searchParams: HazardSearchParams(
        searchString: state.searchString,
        categoryIds: selectedCategoryIds,
        locationIds: selectedLocationIds,
        awsEmergency: awsEmergency,
        awsWatchAndAct: awsWatchAndAct,
        awsAdvice: awsAdvice,
        officialNonAws: officialNonAws,
        userReported: userReported,

        // Pass the current page
        page: state.currentPage,
      ),
    );
    if (!mounted) return;

    result.when(
      (hazards) {
        // The two newest source toggles filter on the phone.
        final filters = _ref.read(providerOfHazardFiltersForNotifications);
        final visible = hazards.where(filters.allowsHazard).toList();
        state = state.copyWith(
          getNotificationsFeedHazardsState:
              GetNotificationsFeedHazardsState.success(
                visible,
              ),
        );
        updateHazards(visible);
      },
      (error) {
        state = state.copyWith(
          getNotificationsFeedHazardsState:
              GetNotificationsFeedHazardsState.error(error),
        );
      },
    );
  }

  /// Fetches the hazards that the user has subscribed to for notifications
  Future<void> getNextNotificationsFeedHazards() async {
    final isLoading = state.getNextNotificationsFeedHazardsState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isLoading) return; // Prevent multiple simultaneous fetches

    final selectedCategoryIds = _ref
        .read(providerOfHazardFiltersForNotifications)
        .selectedCategoryIds
        .toList();
    final selectedLocationIds = _ref
        .read(providerOfHazardFiltersForNotifications)
        .selectedLocationIds
        .toList();
    final awsEmergency = _ref
        .read(providerOfHazardFiltersForNotifications)
        .awsEmergency;
    final awsWatchAndAct = _ref
        .read(providerOfHazardFiltersForNotifications)
        .awsWatchAndAct;
    final awsAdvice = _ref
        .read(providerOfHazardFiltersForNotifications)
        .awsAdvice;
    final officialNonAws = _ref
        .read(providerOfHazardFiltersForNotifications)
        .officialNonAws;
    final userReported = _ref
        .read(providerOfHazardFiltersForNotifications)
        .userReported;

    state = state.copyWith(
      getNextNotificationsFeedHazardsState:
          const GetNotificationsFeedHazardsState.loading(),
    );

    // Update the current page by 1, since we are fetching the next page
    updateCurrentPage(state.currentPage + 1);

    final result = await _notificationService.getNotificationsFeed(
      searchParams: HazardSearchParams(
        searchString: state.searchString,
        categoryIds: selectedCategoryIds,
        locationIds: selectedLocationIds,
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
      (hazards) {
        final filters = _ref.read(providerOfHazardFiltersForNotifications);
        final visible = hazards.where(filters.allowsHazard).toList();
        state = state.copyWith(
          getNextNotificationsFeedHazardsState:
              GetNotificationsFeedHazardsState.success(visible),
        );
        addMultipleToHazards(visible);
      },
      (error) {
        state = state.copyWith(
          getNextNotificationsFeedHazardsState:
              GetNotificationsFeedHazardsState.error(error),
        );
      },
    );
  }

  /// Updates [NotificationsFeedProviderState.searchString] with the provided [searchString].
  void updateSearchString(final String searchString) {
    state = state.copyWith(
      searchString: searchString,
    );
  }

  /// Updates [NotificationsFeedProviderState.hazards] with the provided [hazards].
  void updateHazards(final List<Hazard> hazards) {
    state = state.copyWith(
      hazards: hazards,
    );
  }

  /// Updates a hazard in the existing list of hazards in the state.
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

  /// Removes hazards that have expired from the existing list of hazards in the state.
  void removeExpiredHazards() {
    final updatedHazards = state.hazards
        .where((hazard) => !hazard.isExpired)
        .toList();
    updateHazards(updatedHazards);
  }

  /// Updates [NotificationsFeedProviderState.getNotificationsFeedHazardsState] to loading state.
  void updateGetNotificationsFeedStateToLoading() {
    state = state.copyWith(
      getNotificationsFeedHazardsState:
          const GetNotificationsFeedHazardsState.loading(),
    );
  }

  /// Updates [NotificationsFeedProviderState.currentPage] with the provided [currentPage].
  void updateCurrentPage(final int currentPage) {
    state = state.copyWith(
      currentPage: currentPage,
    );
  }
}
