import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hazard_app/features/profile/providers/states/my_hazards_provider_state.dart';
import 'package:hazard_app/features/search/models/hazard_search_params.dart';
import 'package:hazard_app/features/shared/enums/hazard_review_status_types.dart';
import 'package:hazard_app/features/shared/enums/sort_category_types.dart';
import 'package:hazard_app/features/shared/enums/sort_order_types.dart';
import 'package:hazard_app/features/shared/models/app_user_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/features/shared/services/hazard_service.dart';

final providerOfMyHazards =
    StateNotifierProvider.autoDispose<
      MyHazardsProvider,
      MyHazardsProviderState
    >(
      (ref) => MyHazardsProvider(
        ref: ref,
        state: const MyHazardsProviderState(),
      ),
    );

class MyHazardsProvider extends StateNotifier<MyHazardsProviderState> {
  MyHazardsProvider({
    required final Ref ref,
    required final MyHazardsProviderState state,
  }) : _ref = ref,
       super(state) {
    getMyAcceptedHazards();
    getMyRejectedHazards();
  }

  final Ref _ref;
  HazardService get _hazardService => _ref.read(providerOfHazardService);
  AppUser? get _loggedInUser => _ref.read(providerOfLoggedInUser);

  /// Fetches hazards reported by the logged-in user that have been accepted.
  Future<void> getMyAcceptedHazards() async {
    if (_loggedInUser?.id == null) return;

    state = state.copyWith(
      getMyAcceptedHazardsState: const GetMyHazardsState.loading(),
    );

    final result = await _hazardService.getHazards(
      searchParams: HazardSearchParams(
        reportedById: _loggedInUser!.id,
        reviewStatus: HazardReviewStatus.accepted,
        showExpired: true,
        sortSettings: [
          {SortCategory.createdAt: SortOrder.desc},
        ],
      ),
    );
    if (!mounted) return;

    result.when(
      (hazards) {
        state = state.copyWith(
          myAcceptedHazards: hazards,
          getMyAcceptedHazardsState: GetMyHazardsState.success(
            hazards,
          ),
        );
      },
      (error) {
        state = state.copyWith(
          getMyAcceptedHazardsState: GetMyHazardsState.error(
            error,
          ),
        );
      },
    );
  }

  /// Fetches hazards reported by the logged-in user that have been rejected.
  Future<void> getMyRejectedHazards() async {
    if (_loggedInUser == null) return;

    state = state.copyWith(
      getMyRejectedHazardsState: const GetMyHazardsState.loading(),
    );

    final result = await _hazardService.getHazards(
      searchParams: HazardSearchParams(
        reportedById: _loggedInUser!.id,
        reviewStatus: HazardReviewStatus.rejected,
        sortSettings: [
          {SortCategory.createdAt: SortOrder.desc},
        ],
      ),
    );
    if (!mounted) return;

    result.when(
      (hazards) {
        state = state.copyWith(
          myRejectedHazards: hazards,
          getMyRejectedHazardsState: GetMyHazardsState.success(
            hazards,
          ),
        );
      },
      (error) {
        state = state.copyWith(
          getMyRejectedHazardsState: GetMyHazardsState.error(
            error,
          ),
        );
      },
    );
  }

  /// Updates [MyHazardsProviderState.myAcceptedHazards] with the given [hazards].
  void updateMyAcceptedHazards(final List<Hazard> hazards) {
    state = state.copyWith(
      myAcceptedHazards: hazards,
    );
  }

  /// Updates a hazard in [MyHazardsProviderState.myAcceptedHazards] with the given [hazard].
  void updateMyAcceptedHazard(final Hazard hazard) {
    final updatedHazards = state.myAcceptedHazards.map((h) {
      if (h.id == hazard.id) {
        return hazard;
      }
      return h;
    }).toList();
    updateMyAcceptedHazards(updatedHazards);
  }

  /// Adds a hazard to [MyHazardsProviderState.myAcceptedHazards].
  void addToMyAcceptedHazards(final Hazard hazard) {
    final updatedHazards = List<Hazard>.from(state.myAcceptedHazards)
      ..insert(0, hazard);
    updateMyAcceptedHazards(updatedHazards);
  }

  /// Adds or updates a hazard in [MyHazardsProviderState.myAcceptedHazards].
  void addOrUpdateAcceptedHazard(final Hazard hazard) {
    final index = state.myAcceptedHazards.indexWhere((h) => h.id == hazard.id);
    if (index != -1) {
      // Update existing hazard
      updateMyAcceptedHazard(hazard);
    } else {
      // Add new hazard
      addToMyAcceptedHazards(hazard);
    }
  }

  /// Removes a hazard from [MyHazardsProviderState.myAcceptedHazards] by its [hazardId].
  void removeFromMyAcceptedHazards(final String hazardId) {
    final updatedHazards = state.myAcceptedHazards
        .where((hazard) => hazard.id != hazardId)
        .toList();
    updateMyAcceptedHazards(updatedHazards);
  }

  /// Removes the expired hazards from [MyHazardsProviderState.myAcceptedHazards].
  void removeExpiredAcceptedHazards() {
    final updatedHazards = state.myAcceptedHazards
        .where((hazard) => !hazard.isExpired)
        .toList();
    updateMyAcceptedHazards(updatedHazards);
  }

  /// Updates [MyHazardsProviderState.myRejectedHazards] with the given [hazards].
  void updateMyRejectedHazards(final List<Hazard> hazards) {
    state = state.copyWith(
      myRejectedHazards: hazards,
    );
  }

  /// Updates a hazard in [MyHazardsProviderState.myRejectedHazards] with the given [hazard].
  void updateMyRejectedHazard(final Hazard hazard) {
    final updatedHazards = state.myRejectedHazards.map((h) {
      if (h.id == hazard.id) {
        return hazard;
      }
      return h;
    }).toList();
    updateMyRejectedHazards(updatedHazards);
  }

  /// Adds a hazard to [MyHazardsProviderState.myRejectedHazards].
  void addToMyRejectedHazards(final Hazard hazard) {
    final updatedHazards = List<Hazard>.from(state.myRejectedHazards)
      ..insert(0, hazard);
    updateMyRejectedHazards(updatedHazards);
  }

  /// Adds or updates a hazard in [MyHazardsProviderState.myRejectedHazards].
  void addOrUpdateRejectedHazard(final Hazard hazard) {
    final index = state.myRejectedHazards.indexWhere((h) => h.id == hazard.id);
    if (index != -1) {
      // Update existing hazard
      updateMyRejectedHazard(hazard);
    } else {
      // Add new hazard
      addToMyRejectedHazards(hazard);
    }
  }

  /// Removes a hazard from [MyHazardsProviderState.myRejectedHazards] by its [hazardId].
  void removeFromMyRejectedHazards(final String hazardId) {
    final updatedHazards = state.myRejectedHazards
        .where((hazard) => hazard.id != hazardId)
        .toList();
    updateMyRejectedHazards(updatedHazards);
  }
}
