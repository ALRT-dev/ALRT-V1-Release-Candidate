import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';

part 'my_hazards_provider_state.freezed.dart';

@freezed
abstract class MyHazardsProviderState with _$MyHazardsProviderState {
  const factory MyHazardsProviderState({
    /// The list of hazards reported by the logged-in user which were accepted.
    @Default(<Hazard>[]) final List<Hazard> myAcceptedHazards,

    /// The list of hazards reported by the logged-in user which were rejected.
    @Default(<Hazard>[]) final List<Hazard> myRejectedHazards,

    /// The state of fetching hazards reported by the logged-in user.
    @Default(GetMyHazardsState.initial())
    final GetMyHazardsState getMyAcceptedHazardsState,

    /// The state of fetching hazards reported by the logged-in user.
    @Default(GetMyHazardsState.initial())
    final GetMyHazardsState getMyRejectedHazardsState,
  }) = _MyHazardsProviderState;
}

@freezed
class GetMyHazardsState with _$GetMyHazardsState {
  const factory GetMyHazardsState.initial() = _GetMyHazardsStateInitial;
  const factory GetMyHazardsState.loading() = _GetMyHazardsStateLoading;
  const factory GetMyHazardsState.success(
    final List<Hazard> hazards,
  ) = _GetMyHazardsStateSuccess;
  const factory GetMyHazardsState.error(
    final AppError error,
  ) = _GetMyHazardsStateError;
}
