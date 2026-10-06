import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hazard_app/features/auth/enums/auth_method_types.dart';
import 'package:hazard_app/features/auth/models/auth_success_model.dart';
import 'package:hazard_app/features/auth/providers/repository_providers.dart';
import 'package:hazard_app/features/auth/repositories/auth_repository.dart';
import 'package:hazard_app/features/shared/enums/shared_prefs_key_types.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/providers/repository_providers.dart';
import 'package:hazard_app/features/shared/repositories/shared_prefs_repository.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

class AuthService {
  const AuthService(Ref ref) : _ref = ref;

  final Ref _ref;
  AuthRepository get _authRepository => _ref.read(providerOfAuthRepository);
  SharedPreferencesRepository get _sharedPrefRepository =>
      _ref.read(providerOfSharedPreferencesRepository);

  /// Initializes Google Sign-In.
  Future<Either<void, AppError>> initializeGoogleSignIn() async {
    return _authRepository.initializeGoogleSignIn();
  }

  /// Signs in the user with Google.
  ///
  /// This method is used for non-web platforms where the Google Sign-In
  /// process is handled within the app. It retrieves the Google account,
  /// exchanges the authentication token with the backend, and stores the
  /// access and refresh tokens locally.
  Future<Either<AuthSuccess, AppError>> signInWithGoogle() async {
    final result = await _authRepository.signInWithGoogle();

    await result.whenSuccess((response) {
      log('Access Token ::  ${response.accessToken}');
      log('Refresh Token ::  ${response.refreshToken}');
      return Future.wait([
        _saveAuthMethod(
          authMethod: AuthMethod.google,
        ),
        _saveAuthTokens(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        ),
      ]);
    });

    return result;
  }

  /// Signs in the user with an already authenticated Google account (for web).
  ///
  /// This method is used for web platforms where the Google Sign-In
  /// process is handled externally (e.g., via a popup). It takes the
  /// authenticated Google account, exchanges the authentication token
  /// with the backend, and stores the access and refresh tokens locally.
  Future<Either<AuthSuccess, AppError>> signInWithGoogleUser({
    required GoogleSignInAccount googleUser,
  }) async {
    final result = await _authRepository.signInWithGoogleUser(
      googleUser: googleUser,
    );

    await result.whenSuccess((response) {
      log('Access Token ::  ${response.accessToken}');
      log('Refresh Token ::  ${response.refreshToken}');
      return Future.wait([
        _saveAuthMethod(
          authMethod: AuthMethod.google,
        ),
        _saveAuthTokens(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        ),
      ]);
    });

    return result;
  }

  /// Signs in the user with Apple.
  Future<Either<AuthSuccess, AppError>> signInWithApple() async {
    final result = await _authRepository.signInWithApple();

    await result.whenSuccess((response) {
      log('Access Token ::  ${response.accessToken}');
      log('Refresh Token ::  ${response.refreshToken}');
      return Future.wait([
        _saveAuthMethod(
          authMethod: AuthMethod.apple,
        ),
        _saveAuthTokens(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        ),
      ]);
    });

    return result;
  }

  /// Signs in the user with Microsoft.
  Future<Either<AuthSuccess, AppError>> signInWithMicrosoft() async {
    final result = await _authRepository.signInWithMicrosoft();

    await result.whenSuccess((response) {
      log('Access Token ::  ${response.accessToken}');
      log('Refresh Token ::  ${response.refreshToken}');
      return Future.wait([
        _saveAuthMethod(
          authMethod: AuthMethod.microsoft,
        ),
        _saveAuthTokens(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        ),
      ]);
    });

    return result;
  }

  /// Signs in the user with email + password.
  Future<Either<AuthSuccess, AppError>> loginWithEmail({
    required final String email,
    required final String password,
  }) async {
    final result = await _authRepository.loginWithEmail(
      email: email,
      password: password,
    );

    await result.whenSuccess((response) {
      return Future.wait([
        _saveAuthMethod(authMethod: AuthMethod.email),
        _saveAuthTokens(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        ),
      ]);
    });

    return result;
  }

  /// Registers a new user with email + password (and signs them in).
  Future<Either<AuthSuccess, AppError>> registerWithEmail({
    required final String email,
    required final String password,
  }) async {
    final result = await _authRepository.registerWithEmail(
      email: email,
      password: password,
    );

    await result.whenSuccess((response) {
      return Future.wait([
        _saveAuthMethod(authMethod: AuthMethod.email),
        _saveAuthTokens(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        ),
      ]);
    });

    return result;
  }

  /// Starts a password reset. Always resolves the same way regardless of
  /// whether the email is registered - the backend never reveals that.
  Future<Either<void, AppError>> requestPasswordReset({
    required final String email,
  }) {
    return _authRepository.requestPasswordReset(email: email);
  }

  /// Logs out the user by deleting the access token from local storage.
  Future<Either<void, AppError>> logout() async {
    await _deleteAccessToken();
    return Success(null);
  }

  // --------------------------------------- LOCAL STORAGE --------------------------------------- //

  /// Saves the auth method in local storage.
  Future<void> _saveAuthMethod({
    required final AuthMethod authMethod,
  }) async {
    await _sharedPrefRepository.saveString(
      key: SharedPrefsKey.authMethod,
      value: authMethod.name,
    );
  }

  /// Saves the access token in local storage.
  ///
  /// The [accessToken] is the access token of the user.
  Future<void> _saveAuthTokens({
    required final String accessToken,
    required final String refreshToken,
  }) async {
    await Future.wait([
      _sharedPrefRepository.saveString(
        key: SharedPrefsKey.accessToken,
        value: accessToken,
      ),
      _sharedPrefRepository.saveString(
        key: SharedPrefsKey.refreshToken,
        value: refreshToken,
      ),
    ]);
  }

  /// Deletes the access token from local storage.
  // ignore: unused_element
  Future<void> _deleteAccessToken() async {
    await Future.wait([
      _sharedPrefRepository.removeKey(
        key: SharedPrefsKey.accessToken,
      ),
      _sharedPrefRepository.removeKey(
        key: SharedPrefsKey.refreshToken,
      ),
    ]);
  }
}
