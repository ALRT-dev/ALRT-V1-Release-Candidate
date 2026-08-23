import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/auth/providers/service_providers.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';

/// State for the "forgot password" screen. Plain hand-rolled state (not
/// Freezed, unlike the rest of AuthProviderState) so this screen has no
/// codegen dependency of its own.
class ForgotPasswordState {
  const ForgotPasswordState({
    this.isLoading = false,
    this.submitted = false,
    this.error,
  });

  final bool isLoading;
  /// True once a request has completed (success or failure alike - the
  /// screen shows the same generic "check your email" outcome either way,
  /// per the backend's non-enumerating response).
  final bool submitted;
  final AppError? error;
}

class ForgotPasswordNotifier extends Notifier<ForgotPasswordState> {
  @override
  ForgotPasswordState build() => const ForgotPasswordState();

  Future<void> submit(final String email) async {
    state = const ForgotPasswordState(isLoading: true);
    final result = await ref
        .read(providerOfAuthService)
        .requestPasswordReset(email: email);
    result.when(
      (_) => state = const ForgotPasswordState(submitted: true),
      (error) {
        // A real network/server failure (not "email unknown" - the backend
        // never distinguishes that) still deserves visible feedback rather
        // than a false "check your email".
        state = ForgotPasswordState(error: error);
      },
    );
  }
}

final providerOfForgotPassword =
    NotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>(
      ForgotPasswordNotifier.new,
    );
