import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

abstract class CacheManagerRepository {
  Future<Either<File, AppError>> getSingleFile({
    required final String url,
    final String? key,
    String? fileExtension,
  });

  Future<Either<File?, AppError>> getSingleFileFromCache({
    required final String key,
  });

  Future<Either<void, AppError>> clearAllCache();
}

class CacheManagerRepositoryImpl extends CacheManagerRepository {
  CacheManagerRepositoryImpl({
    required final CacheManager cacheManager,
  }) : _cacheManager = cacheManager;

  final CacheManager _cacheManager;

  @override
  Future<Either<File, AppError>> getSingleFile({
    required String url,
    String? key,
    String? fileExtension,
  }) {
    return runAsyncCall(
      name: 'getSingleFile',
      future: () async {
        final fileInfo = await _cacheManager.getFileFromCache(key ?? url);
        if (fileInfo == null) {
          final downloaded = await _cacheManager.downloadFile(
            url,
            key: 'temp_$key',
          );
          final putFile = await _cacheManager.putFileStream(
            url,
            downloaded.file.openRead(),
            fileExtension: fileExtension ?? 'file',
            key: key,
          );
          _cacheManager.removeFile('temp_$key');

          return Success(putFile);
        } else {
          return Success(fileInfo.file);
        }
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<File?, AppError>> getSingleFileFromCache({
    required String key,
  }) {
    return runAsyncCall(
      name: 'getSingleFileFromCache',
      future: () async {
        final fileInfo = await _cacheManager.getFileFromCache(key);
        return Success(fileInfo?.file);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> clearAllCache() {
    return runAsyncCall(
      name: 'clearAllCache',
      future: () async {
        await _cacheManager.emptyCache();
        return Success(null);
      },
      onError: Failure.new,
    );
  }
}
