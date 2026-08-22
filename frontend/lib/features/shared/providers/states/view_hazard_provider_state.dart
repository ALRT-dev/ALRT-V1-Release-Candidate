import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/models/view_hazard_response_model.dart';

part 'view_hazard_provider_state.freezed.dart';

@freezed
abstract class ViewHazardProviderState with _$ViewHazardProviderState {
  const factory ViewHazardProviderState({
    /// The hazard being viewed.
    final Hazard? hazard,

    /// The state of viewing the hazard.
    @Default(ViewHazardState.initial()) final ViewHazardState viewHazardState,

    /// The state of deleting the hazard.
    @Default(DeleteHazardState.initial())
    final DeleteHazardState deleteHazardState,
  }) = _ViewHazardProviderState;
}

@freezed
class ViewHazardState with _$ViewHazardState {
  const factory ViewHazardState.initial() = _ViewHazardStateInitial;
  const factory ViewHazardState.loading() = _ViewHazardStateLoading;
  const factory ViewHazardState.success(
    final ViewHazardResponse response,
  ) = _ViewHazardStateSuccess;
  const factory ViewHazardState.error(final AppError error) =
      _ViewHazardStateError;
}

@freezed
class DeleteHazardState with _$DeleteHazardState {
  const factory DeleteHazardState.initial() = _DeleteHazardStateInitial;
  const factory DeleteHazardState.loading() = _DeleteHazardStateLoading;
  const factory DeleteHazardState.success() = _DeleteHazardStateSuccess;
  const factory DeleteHazardState.error(final AppError error) =
      _DeleteHazardStateError;
}
