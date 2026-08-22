import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/auth/repositories/auth_repository.dart';
import 'package:hazard_app/features/shared/providers/instance_providers.dart';
import 'package:hazard_app/features/shared/providers/rest_client_provider.dart';

final providerOfAuthRepository = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    restClient: ref.watch(providerOfRestClient),
    googleSignIn: ref.watch(providerOfGoogleSignInInstance),
  );
});
