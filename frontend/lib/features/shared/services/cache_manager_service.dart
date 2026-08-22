import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/providers/repository_providers.dart';
import 'package:hazard_app/features/shared/repositories/cache_manager_repository.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

class CacheManagerService {
  const CacheManagerService(final Ref ref) : _ref = ref;

  final Ref _ref;
  CacheManagerRepository get _cacheManagerRepository =>
      _ref.read(providerOfCacheManagerRepository);

  /// Gets a single file from the cache.
  ///
  /// If the file is not found in the cache, it will be downloaded and stored in the cache. Then it will be returned.
  ///
  /// The [url] is the URL of the file to be downloaded.
  ///
  /// The [key] is an optional parameter that can be used to identify the file in the cache.
  /// If not provided, the [url] will be used as the key.
  Future<Either<File, AppError>> getSingleFile({
    required final String url,
    final String? key,
    final String? fileExtension,
  }) {
    return _cacheManagerRepository.getSingleFile(
      url: url,
      key: key,
      fileExtension: fileExtension,
    );
  }

  /// Gets a single file from the cache.
  ///
  /// The [key] is a parameter that can be used to identify the file in the cache.
  Future<Either<File?, AppError>> getSingleFileFromCache({
    required final String key,
  }) {
    return _cacheManagerRepository.getSingleFileFromCache(
      key: key,
    );
  }

  /// Downloads and saves the urls to the cache.
  ///
  /// The [urls] are the URLs of the files to be downloaded.
  ///
  /// The [keys] are optional parameters that can be used to identify the files in the cache.
  Future<void> cacheUrls({
    required final List<String> urls,
    final List<String> keys = const [],
  }) async {
    final futures = <Future>[];

    for (var i = 0; i < urls.length; i++) {
      final url = urls[i];

      String? key;
      if (i < keys.length) {
        key = keys[i];
      }

      futures.add(
        getSingleFile(
          url: url,
          key: key,
        ),
      );
    }

    await Future.wait(futures);
  }

  /// Clears all the cache.
  Future<Either<void, AppError>> clearAllCache() {
    return _cacheManagerRepository.clearAllCache();
  }
}
