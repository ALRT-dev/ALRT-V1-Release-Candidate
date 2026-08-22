import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';

part 'hazard_item_provider_state.freezed.dart';

@freezed
abstract class HazardItemProviderState with _$HazardItemProviderState {
  const factory HazardItemProviderState({
    /// The hazard item being managed.
    final Hazard? hazard,

    /// The state of voting on the hazard.
    @Default(VoteHazardState.initial()) final VoteHazardState voteState,
  }) = _HazardItemProviderState;
}

@freezed
class VoteHazardState with _$VoteHazardState {
  const factory VoteHazardState.initial() = _VoteHazardStateInitial;
  const factory VoteHazardState.loading() = _VoteHazardStateLoading;
  const factory VoteHazardState.success() = _VoteHazardStateSuccess;
  const factory VoteHazardState.error(
    final AppError message,
  ) = _VoteHazardStateError;
}
