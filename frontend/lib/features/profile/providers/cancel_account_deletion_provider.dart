import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/features/shared/services/user_service.dart';

part 'cancel_account_deletion_provider.freezed.dart';

final providerOfCancelAccountDeletion = StateNotifierProvider.autoDispose<
    CancelAccountDeletionProvider, CancelAccountDeletionProviderState>(
  (ref) => CancelAccountDeletionProvider(
    ref: ref,
    state: const CancelAccountDeletionProviderState(),
  ),
);

class CancelAccountDeletionProvider
    extends StateNotifier<CancelAccountDeletionProviderState> {
  CancelAccountDeletionProvider({
    required final Ref ref,
    required final CancelAccountDeletionProviderState state,
  })  : _ref = ref,
        super(state);

  final Ref _ref;
  UserService get _userService => _ref.read(providerOfUserService);

  /// Cancels the scheduled account deletion and reactivates the account.
  Future<void> cancelAccountDeletion() async {
    state = state.copyWith(
      cancelState: const CancelAccountDeletionState.loading(),
    );

    final result = await _userService.cancelAccountDeletion();
    if (!mounted) return;

    result.when(
      (_) {
        state = state.copyWith(
          cancelState: const CancelAccountDeletionState.success(),
        );

        // Clear the scheduledDeletionAt in the logged-in user
        _ref.read(providerOfLoggedInUser.notifier).update(
              (user) => user?.copyWith(scheduledDeletionAt: null),
            );
      },
      (error) {
        state = state.copyWith(
          cancelState: CancelAccountDeletionState.error(error),
        );
      },
    );
  }
}

@freezed
abstract class CancelAccountDeletionProviderState
    with _$CancelAccountDeletionProviderState {
  const factory CancelAccountDeletionProviderState({
    @Default(CancelAccountDeletionState.initial())
    final CancelAccountDeletionState cancelState,
  }) = _CancelAccountDeletionProviderState;
}

@freezed
class CancelAccountDeletionState with _$CancelAccountDeletionState {
  const factory CancelAccountDeletionState.initial() =
      _CancelAccountDeletionStateInitial;
  const factory CancelAccountDeletionState.loading() =
      _CancelAccountDeletionStateLoading;
  const factory CancelAccountDeletionState.success() =
      _CancelAccountDeletionStateSuccess;
  const factory CancelAccountDeletionState.error(
    final AppError error,
  ) = _CancelAccountDeletionStateError;
}
