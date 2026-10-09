import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hazard_app/features/shared/enums/hazard_vote_types.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/providers/hazard_socket_manager_provider.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/features/shared/providers/states/hazard_item_provider_state.dart';
import 'package:hazard_app/features/shared/services/hazard_service.dart';

final providerOfHazardItem =
    StateNotifierProvider.family<
      HazardItemProvider,
      HazardItemProviderState,
      String
    >(
      (final ref, final hazardId) => HazardItemProvider(
        ref: ref,
        hazardId: hazardId,
        state: HazardItemProviderState(),
      ),
    );

class HazardItemProvider extends StateNotifier<HazardItemProviderState> {
  HazardItemProvider({
    required final Ref ref,
    required final String hazardId,
    required final HazardItemProviderState state,
  }) : _ref = ref,
       _hazardId = hazardId,
       super(state) {
    _listenToHazardUpdates();
  }

  final Ref _ref;
  final String _hazardId;

  HazardService get _hazardService => _ref.read(providerOfHazardService);

  /// Listens to the global hazard update stream and updates the hazard in the state if it matches the current hazard.
  void _listenToHazardUpdates() {
    final updateHazardSubscription = _ref
        .read(providerOfHazardSocketManager)
        .updateHazardStream
        .listen((updatedHazard) {
          if (updatedHazard.id == state.hazard?.id) {
            updateHazard(
              updatedHazard.copyWith(
                // No need to update userVoteType as it's not sent in the update
                userVoteType: state.hazard?.userVoteType,
              ),
            );
          }
        });

    // Clean up subscription when provider is disposed
    _ref.onDispose(() {
      updateHazardSubscription.cancel();
    });
  }

  /// Handles voting on the hazard.
  Future<void> voteHazard({
    required final HazardVoteType voteType,
  }) async {
    state = state.copyWith(
      voteState: const VoteHazardState.loading(),
    );

    final initialVoteType = state.hazard?.userVoteType;
    final initialUpvoteCount = state.hazard?.upvoteCount ?? 0;
    final initialDownvoteCount = state.hazard?.downvoteCount ?? 0;

    // immediately update the vote in the UI for a better user experience
    if (voteType == initialVoteType) {
      // if the user is trying to vote the same way again, it means they want to remove their vote
      updateVoteTypeInTheState(null);

      // update the vote count accordingly
      if (voteType == HazardVoteType.upvote) {
        updateUpvoteCountInTheState(initialUpvoteCount - 1);
      } else {
        updateDownvoteCountInTheState(initialDownvoteCount - 1);
      }
    } else {
      // otherwise, update the vote type to the new vote
      updateVoteTypeInTheState(voteType);

      // update the vote counts accordingly
      if (voteType == HazardVoteType.upvote) {
        updateUpvoteCountInTheState(initialUpvoteCount + 1);

        // if user had previously downvoted, decrement the downvote count
        if (initialVoteType == HazardVoteType.downvote) {
          updateDownvoteCountInTheState(initialDownvoteCount - 1);
        }
      } else {
        updateDownvoteCountInTheState(initialDownvoteCount + 1);

        // if user had previously upvoted, decrement the upvote count
        if (initialVoteType == HazardVoteType.upvote) {
          updateUpvoteCountInTheState(initialUpvoteCount - 1);
        }
      }
    }

    final result = await _hazardService.voteHazard(
      hazardId: _hazardId,
      voteType: voteType,
    );
    if (!mounted) return;

    result.when(
      (_) {
        state = state.copyWith(
          voteState: const VoteHazardState.success(),
        );
      },
      (error) {
        state = state.copyWith(
          voteState: VoteHazardState.error(error),
        );

        // if there was an error, revert the vote in the UI to the initial state
        updateVoteTypeInTheState(initialVoteType);

        // revert the vote counts to the initial state
        updateUpvoteCountInTheState(initialUpvoteCount);
        updateDownvoteCountInTheState(initialDownvoteCount);
      },
    );
  }

  /// Updates [HazardItemProviderState.hazard] with the new [hazard].
  void updateHazard(final Hazard? hazard) {
    state = state.copyWith(
      hazard: hazard,
    );
  }

  /// Updates the user vote type in the hazard state.
  void updateVoteTypeInTheState(final HazardVoteType? voteType) {
    updateHazard(
      state.hazard?.copyWith(
        userVoteType: voteType,
      ),
    );
  }

  /// Updates the upvote count in the hazard state.
  void updateUpvoteCountInTheState(final int upvoteCount) {
    updateHazard(
      state.hazard?.copyWith(
        upvoteCount: upvoteCount,
      ),
    );
  }

  /// Updates the downvote count in the hazard state.
  void updateDownvoteCountInTheState(final int downvoteCount) {
    updateHazard(
      state.hazard?.copyWith(
        downvoteCount: downvoteCount,
      ),
    );
  }
}
