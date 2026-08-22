import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/shared/enums/alrt_media_source_types.dart';
import 'package:hazard_app/features/shared/enums/alrt_media_types.dart';
import 'package:hazard_app/features/shared/models/alrt_media_model.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/models/s3_media_model.dart';
import 'package:hazard_app/features/shared/providers/repository_providers.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/features/shared/repositories/media_repository.dart';
import 'package:hazard_app/features/shared/services/cache_manager_service.dart';
import 'package:hazard_app/features/shared/utils/either.dart';
import 'package:image_picker/image_picker.dart';

class MediaService {
  const MediaService(final Ref ref) : _ref = ref;

  final Ref _ref;
  MediaRepository get _mediaRepository => _ref.read(providerOfMediaRepository);
  CacheManagerService get _cacheManagerService =>
      _ref.read(providerOfCacheManagerService);

  /// Picks an image from the specified [source] (gallery or camera).
  Future<Either<AlrtMedia?, AppError>> pickImage({
    final ImageSource source = ImageSource.gallery,
  }) {
    return _mediaRepository.pickImage(source: source);
  }

  /// Picks a video from the specified [source] (gallery or camera).
  Future<Either<AlrtMedia?, AppError>> pickVideo({
    final ImageSource source = ImageSource.gallery,
  }) {
    return _mediaRepository.pickVideo(source: source);
  }

  /// Picks multiple images from the gallery.
  Future<Either<List<AlrtMedia>, AppError>> pickMedias() {
    return _mediaRepository.pickMedias();
  }

  /// Converts a list of [S3Media] objects to a list of [AlrtMedia] objects.
  Future<List<AlrtMedia>> convertS3MediaToAlrtMedia({
    required final List<S3Media> s3Medias,
  }) async {
    final futures = <Future<AlrtMedia>>[];

    for (final s3Media in s3Medias) {
      final alrtMedia = s3Media.toAlrtMedia();

      final future = _cacheManagerService
          .getSingleFileFromCache(key: alrtMedia.id)
          .then(
            (result) => result.when(
              (file) {
                if (file != null) {
                  return alrtMedia.copyWith(
                    value: file.path,
                    source: AlrtMediaSource.file,
                  );
                } else {
                  final fileExtension =
                      s3Media.s3Key.split('.').lastOrNull ??
                      (alrtMedia.type == AlrtMediaType.video ? 'mov' : 'jpg');

                  // If the file is not in cache, download it and cache it.
                  _cacheManagerService.getSingleFile(
                    url: alrtMedia.value,
                    key: alrtMedia.id,
                    fileExtension: fileExtension,
                  );

                  return alrtMedia;
                }
              },
              (failure) => alrtMedia,
            ),
          );

      futures.add(future);
    }

    return Future.wait(
      futures,
    ).then((value) => value.whereType<AlrtMedia>().toList());
  }
}
