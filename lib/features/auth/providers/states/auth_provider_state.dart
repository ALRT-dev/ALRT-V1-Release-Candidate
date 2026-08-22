import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';

part 'auth_provider_state.freezed.dart';

@freezed
abstract class AuthProviderState with _$AuthProviderState {
  const factory AuthProviderState({
    /// The state of signing in with Google.
    @Default(SignInWithGoogleState.initial())
    SignInWithGoogleState signInWithGoogleState,

    /// The state of signing in with Apple.
    @Default(SignInWithAppleState.initial())
    SignInWithAppleState signInWithAppleState,

    /// The state of signing in with Microsoft.
    @Default(SignInWithMicrosoftState.initial())
    SignInWithMicrosoftState signInWithMicrosoftState,

    /// The state of signing in / registering with email + password.
    @Default(SignInWithEmailState.initial())
    SignInWithEmailState signInWithEmailState,
  }) = _AuthProviderState;
}

@freezed
class SignInWithGoogleState with _$SignInWithGoogleState {
  const factory SignInWithGoogleState.initial() = SignInWithGoogleStateInitial;
  const factory SignInWithGoogleState.loading() = SignInWithGoogleStateLoading;
  const factory SignInWithGoogleState.success() = SignInWithGoogleStateSuccess;
  const factory SignInWithGoogleState.error(
    final AppError error,
  ) = SignInWithGoogleStateError;
}

@freezed
class SignInWithAppleState with _$SignInWithAppleState {
  const factory SignInWithAppleState.initial() = SignInWithAppleStateInitial;
  const factory SignInWithAppleState.loading() = SignInWithAppleStateLoading;
  const factory SignInWithAppleState.success() = SignInWithAppleStateSuccess;
  const factory SignInWithAppleState.error(
    final AppError error,
  ) = SignInWithAppleStateError;
}

@freezed
class SignInWithMicrosoftState with _$SignInWithMicrosoftState {
  const factory SignInWithMicrosoftState.initial() =
      SignInWithMicrosoftStateInitial;
  const factory SignInWithMicrosoftState.loading() =
      SignInWithMicrosoftStateLoading;
  const factory SignInWithMicrosoftState.success() =
      SignInWithMicrosoftStateSuccess;
  const factory SignInWithMicrosoftState.error(
    final AppError error,
  ) = SignInWithMicrosoftStateError;
}

@freezed
class SignInWithEmailState with _$SignInWithEmailState {
  const factory SignInWithEmailState.initial() = SignInWithEmailStateInitial;
  const factory SignInWithEmailState.loading() = SignInWithEmailStateLoading;
  const factory SignInWithEmailState.success() = SignInWithEmailStateSuccess;
  const factory SignInWithEmailState.error(
    final AppError error,
  ) = SignInWithEmailStateError;
}
