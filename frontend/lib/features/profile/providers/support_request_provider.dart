import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hazard_app/features/profile/providers/states/support_request_provider_state.dart';
import 'package:hazard_app/features/shared/enums/support_request_types.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/features/shared/services/support_service.dart';

final providerOfSupportRequest =
    StateNotifierProvider.autoDispose<
      SupportRequestProvider,
      SupportRequestProviderState
    >(
      (ref) => SupportRequestProvider(
        ref: ref,
        state: const SupportRequestProviderState(),
      ),
    );

class SupportRequestProvider
    extends StateNotifier<SupportRequestProviderState> {
  SupportRequestProvider({
    required final Ref ref,
    required final SupportRequestProviderState state,
  }) : _ref = ref,
       super(state);

  final Ref _ref;
  SupportService get _supportService => _ref.read(providerOfSupportService);

  /// Updates the request type.
  void updateRequestType(final SupportRequestType requestType) {
    state = state.copyWith(requestType: requestType);
  }

  /// Updates the details.
  void updateDetails(final String details) {
    state = state.copyWith(details: details);
  }

  /// Updates the request submitted status.
  void updateRequestSubmitted(final bool submitted) {
    state = state.copyWith(requestSubmitted: submitted);
  }

  /// Submits the support request.
  Future<void> submitSupportRequest() async {
    if (state.requestType == null || state.details.isEmpty) {
      return;
    }

    updateRequestSubmitted(true);

    state = state.copyWith(
      submitState: const SubmitSupportRequestState.loading(),
    );

    final result = await _supportService.submitSupportRequest(
      requestType: state.requestType!,
      details: state.details,
    );
    if (!mounted) return;

    result.when(
      (_) {
        state = state.copyWith(
          submitState: const SubmitSupportRequestState.success(),
        );
      },
      (error) {
        state = state.copyWith(
          submitState: SubmitSupportRequestState.error(error),
        );
      },
    );
  }

  /// Resets all fields to their initial values.
  void resetAllFields() {
    state = state.copyWith(
      requestType: null,
      details: '',
    );
  }
}
