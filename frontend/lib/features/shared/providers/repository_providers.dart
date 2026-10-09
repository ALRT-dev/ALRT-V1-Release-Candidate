import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/shared/providers/instance_providers.dart';
import 'package:hazard_app/features/shared/providers/rest_client_provider.dart';
import 'package:hazard_app/features/shared/repositories/cache_manager_repository.dart';
import 'package:hazard_app/features/shared/repositories/hazard_repository.dart';
import 'package:hazard_app/features/shared/repositories/media_repository.dart';
import 'package:hazard_app/features/shared/repositories/shared_prefs_repository.dart';
import 'package:hazard_app/features/shared/repositories/support_repository.dart';
import 'package:hazard_app/features/shared/repositories/user_repository.dart';

/// Provides [SharedPreferencesRepository].
final providerOfSharedPreferencesRepository =
    Provider<SharedPreferencesRepository>((ref) {
      return SharedPrefsRepositoryImpl(
        sharedPreferences: ref.watch(providerOfSharedPreferencesInstance)!,
      );
    });

/// Provides [UserRepository].
final providerOfUserRepository = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    restClient: ref.watch(providerOfRestClient),
  );
});

/// Provides [HazardRepository].
final providerOfHazardRepository = Provider<HazardRepository>((ref) {
  return HazardRepositoryImpl(
    restClient: ref.watch(providerOfRestClient),
  );
});

/// Provides [MediaRepository].
final providerOfMediaRepository = Provider<MediaRepository>((ref) {
  return MediaRepositoryImpl();
});

/// Provider of [CacheManagerRepository].
final providerOfCacheManagerRepository = Provider<CacheManagerRepository>(
  (ref) {
    return CacheManagerRepositoryImpl(
      cacheManager: ref.watch(providerOfCacheManagerInstance),
    );
  },
);

/// Provides [SupportRepository].
final providerOfSupportRepository = Provider<SupportRepository>((ref) {
  return SupportRepositoryImpl(
    restClient: ref.watch(providerOfRestClient),
  );
});
