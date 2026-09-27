import 'package:google_sign_in/google_sign_in.dart';
import 'package:hazard_app/api/rest_client.dart';
import 'package:hazard_app/features/auth/models/auth_success_model.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';
import 'package:hazard_app/features/shared/utils/either.dart';
import 'package:hazard_app/others/env.dart';
import 'package:msal_auth/msal_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

abstract class AuthRepository {
  Future<Either<void, AppError>> initializeGoogleSignIn();

  Future<Either<AuthSuccess, AppError>> signInWithGoogle();

  Future<Either<AuthSuccess, AppError>> signInWithGoogleUser({
    required GoogleSignInAccount googleUser,
  });

  Future<Either<AuthSuccess, AppError>> signInWithApple();

  Future<Either<AuthSuccess, AppError>> signInWithMicrosoft();

  Future<Either<AuthSuccess, AppError>> loginWithEmail({
    required final String email,
    required final String password,
  });

  Future<Either<AuthSuccess, AppError>> registerWithEmail({
    required final String email,
    required final String password,
  });

  /// Starts a password reset. Always resolves the same way regardless of
  /// whether the email is registered - the backend never reveals that.
  Future<Either<void, AppError>> requestPasswordReset({
    required final String email,
  });
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required final RestClient restClient,
    required final GoogleSignIn googleSignIn,
  }) : _restClient = restClient,
       _googleSignIn = googleSignIn;

  final RestClient _restClient;
  final GoogleSignIn _googleSignIn;
  SingleAccountPca? _msalAuth;

  @override
  Future<Either<void, AppError>> initializeGoogleSignIn() {
    return runAsyncCall(
      name: 'initializeGoogleSignIn',
      future: () async {
        await _googleSignIn.initialize(
          serverClientId: Env.googleAuthServerClientId,
        );
        return const Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<AuthSuccess, AppError>> signInWithGoogle() {
    return runAsyncCall(
      name: 'signInWithGoogle',
      future: () async {
        final account = await _googleSignIn.authenticate();

        final googleAuth = account.authentication;
        if (googleAuth.idToken == null) {
          throw AppError(message: 'Failed to get authentication token');
        }

        final result = await _restClient.verifyGoogleOAuth(
          idToken: googleAuth.idToken!,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<AuthSuccess, AppError>> signInWithGoogleUser({
    required GoogleSignInAccount googleUser,
  }) {
    return runAsyncCall(
      name: 'signInWithGoogleUser',
      future: () async {
        final googleAuth = googleUser.authentication;
        if (googleAuth.idToken == null) {
          throw AppError(message: 'Failed to get authentication token');
        }

        final result = await _restClient.verifyGoogleOAuth(
          idToken: googleAuth.idToken!,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<AuthSuccess, AppError>> signInWithApple() {
    return runAsyncCall(
      name: 'signInWithApple',
      future: () async {
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        final identityToken = credential.identityToken;
        if (identityToken == null) {
          throw AppError(message: 'Failed to get identity token from Apple');
        }

        final result = await _restClient.verifyAppleOAuth(
          identityToken: identityToken,
          firstName: credential.givenName,
          lastName: credential.familyName,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<AuthSuccess, AppError>> signInWithMicrosoft() {
    return runAsyncCall(
      name: 'signInWithMicrosoft',
      future: () async {
        // Initialize MSAL if not already initialized
        _msalAuth ??= await SingleAccountPca.create(
          clientId: Env.microsoftClientId,
          androidConfig: AndroidConfig(
            configFilePath: 'assets/msal_config.json',
            // Must match the BrowserTabActivity intent-filter registered in
            // AndroidManifest.xml (host = the real applicationId, path =
            // the URL-encoded signature hash) AND the redirect URI
            // registered against this app in the Azure app registration.
            // The previous value here (com.example.hazard_app/
            // YOUR_SIGNATURE_HASH) was a literal, never-replaced
            // placeholder that did not match either — Microsoft sign-in on
            // Android could never have completed with it.
            redirectUri:
                'msauth://com.safetyalrt.alrt/hyOO%2FXSiCQvGcPDoA8%2F2xATQZi8%3D',
          ),
          appleConfig: AppleConfig(
            authority:
                'https://login.microsoftonline.com/${Env.microsoftTenantId}',
            authorityType: AuthorityType.aad,
            broker: Broker.msAuthenticator,
          ),
        );

        // Acquire token interactively
        final authResult = await _msalAuth!.acquireToken(
          scopes: [
            'https://graph.microsoft.com/user.read',
            'email',
          ],
          prompt: Prompt.login,
        );

        final idToken = authResult.idToken;
        if (idToken == null || idToken.isEmpty) {
          throw AppError(
            message: 'Failed to get identity token from Microsoft',
          );
        }

        // Verify with backend
        final result = await _restClient.verifyMicrosoftOAuth(
          idToken: idToken,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<AuthSuccess, AppError>> loginWithEmail({
    required final String email,
    required final String password,
  }) {
    return runAsyncCall(
      name: 'loginWithEmail',
      future: () async {
        final result = await _restClient.loginWithEmail(
          email: email,
          password: password,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<AuthSuccess, AppError>> registerWithEmail({
    required final String email,
    required final String password,
  }) {
    return runAsyncCall(
      name: 'registerWithEmail',
      future: () async {
        final result = await _restClient.registerWithEmail(
          email: email,
          password: password,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> requestPasswordReset({
    required final String email,
  }) {
    return runAsyncCall(
      name: 'requestPasswordReset',
      future: () async {
        await _restClient.requestPasswordReset(email: email);
        return const Success(null);
      },
      onError: Failure.new,
    );
  }
}
