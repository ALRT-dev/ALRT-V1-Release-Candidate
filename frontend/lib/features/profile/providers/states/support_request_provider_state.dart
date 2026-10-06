import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/shared/enums/support_request_types.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';

part 'support_request_provider_state.freezed.dart';

@freezed
abstract class SupportRequestProviderState with _$SupportRequestProviderState {
  const factory SupportRequestProviderState({
    /// The type of support request.
    final SupportRequestType? requestType,

    /// The details of the support request.
    @Default('') final String details,

    /// Whether the request has been submitted.
    @Default(false) final bool requestSubmitted,

    /// The state of submitting the support request.
    @Default(SubmitSupportRequestState.initial())
    final SubmitSupportRequestState submitState,
  }) = _SupportRequestProviderState;
}

@freezed
class SubmitSupportRequestState with _$SubmitSupportRequestState {
  const factory SubmitSupportRequestState.initial() =
      _SubmitSupportRequestStateInitial;
  const factory SubmitSupportRequestState.loading() =
      _SubmitSupportRequestStateLoading;
  const factory SubmitSupportRequestState.success() =
      _SubmitSupportRequestStateSuccess;
  const factory SubmitSupportRequestState.error(final AppError error) =
      _SubmitSupportRequestStateFailure;
}
