import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/profile/providers/my_hazards_provider.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/features/shared/providers/states/view_hazard_provider_state.dart';
import 'package:hazard_app/features/shared/services/hazard_service.dart';

final providerOfViewHazard =
    StateNotifierProvider.family<
      ViewHazardProvider,
      ViewHazardProviderState,
      String
    >(
      (ref, hazardId) {
        return ViewHazardProvider(
          ref: ref,
          hazardId: hazardId,
          state: ViewHazardProviderState(),
        );
      },
    );

class ViewHazardProvider extends StateNotifier<ViewHazardProviderState> {
  ViewHazardProvider({
    required final Ref ref,
    required final String hazardId,
    required final ViewHazardProviderState state,
  }) : _ref = ref,
       _hazardId = hazardId,
       super(state) {
    viewHazard();
  }

  final Ref _ref;
  final String _hazardId;
  HazardService get _hazardService => _ref.read(providerOfHazardService);
  MyHazardsProvider get _myHazardsProvider =>
      _ref.read(providerOfMyHazards.notifier);
  MapProvider get _mapProvider => _ref.read(providerOfMap.notifier);

  /// Handles viewing the hazard.
  Future<void> viewHazard() async {
    state = state.copyWith(
      viewHazardState: const ViewHazardState.loading(),
    );

    final result = await _hazardService.viewHazard(
      hazardId: _hazardId,
    );
    if (!mounted) return;

    result.when(
      (response) {
        state = state.copyWith(
          viewHazardState: ViewHazardState.success(response),
        );

        // Updates the hazardsViewedCount for the user by 1 if the view is recorded
        if (response.isViewRecorded) {
          _ref
              .read(providerOfLoggedInUser.notifier)
              .update(
                (user) => user?.copyWith(
                  hazardsViewedCount: user.hazardsViewedCount + 1,
                ),
              );
        }
      },
      (error) {
        state = state.copyWith(
          viewHazardState: ViewHazardState.error(error),
        );
      },
    );
  }

  /// Handles deleting the hazard.
  Future<void> deleteHazard() async {
    state = state.copyWith(
      deleteHazardState: const DeleteHazardState.loading(),
    );

    final result = await _hazardService.deleteHazard(
      hazardId: _hazardId,
    );
    if (!mounted) return;

    result.when(
      (_) {
        state = state.copyWith(
          deleteHazardState: const DeleteHazardState.success(),
        );

        // Updates the hazardsReportedCount for the user by -1
        _ref
            .read(providerOfLoggedInUser.notifier)
            .update(
              (user) => user?.copyWith(
                hazardsReportedCount: max(user.hazardsReportedCount - 1, 0),
              ),
            );

        /// Remove the hazard from MapProvider
        _mapProvider.removeFromHazards(_hazardId);

        // Remove the hazard from MyHazardsProvider
        _myHazardsProvider
          ..removeFromMyAcceptedHazards(_hazardId)
          ..removeFromMyRejectedHazards(_hazardId);
      },
      (error) {
        state = state.copyWith(
          deleteHazardState: DeleteHazardState.error(error),
        );
      },
    );
  }

  /// Updates [ViewHazardProviderState.hazard] with the provided [hazard].
  void updateHazard(final Hazard hazard) {
    state = state.copyWith(
      hazard: hazard,
    );
  }
}
