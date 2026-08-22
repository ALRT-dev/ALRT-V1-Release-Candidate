import 'package:hazard_app/features/shared/enums/alrt_media_source_types.dart';
import 'package:hazard_app/features/shared/extensions/xfile_extension.dart';
import 'package:hazard_app/features/shared/models/alrt_media_model.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';
import 'package:hazard_app/features/shared/utils/either.dart';
import 'package:image_picker/image_picker.dart';

abstract class MediaRepository {
  /// Picks an image from the specified [source] (gallery or camera) and returns
  /// an [Either] containing the picked [AlrtMedia] on success or an [AppError] on failure.
  Future<Either<AlrtMedia?, AppError>> pickImage({
    final ImageSource source = ImageSource.gallery,
  });

  /// Picks a video from the specified [source] (gallery or camera) and returns
  /// an [Either] containing the picked [AlrtMedia] on success or an [AppError] on failure.
  Future<Either<AlrtMedia?, AppError>> pickVideo({
    final ImageSource source = ImageSource.gallery,
  });

  /// Picks multiple images from the gallery and returns an [Either] containing
  /// a list of picked [AlrtMedia] on success or an [AppError] on failure.
  Future<Either<List<AlrtMedia>, AppError>> pickMedias();
}

class MediaRepositoryImpl implements MediaRepository {
  @override
  Future<Either<AlrtMedia?, AppError>> pickImage({
    ImageSource source = ImageSource.gallery,
  }) {
    return runAsyncCall(
      name: 'pickImage',
      future: () async {
        final pickedMedia = await ImagePicker().pickImage(source: source);
        if (pickedMedia == null) return Success(null);

        return Success(
          AlrtMedia(
            id: pickedMedia.id,
            value: pickedMedia.path,
            type: pickedMedia.mediaType,
            source: AlrtMediaSource.file,
          ),
        );
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<AlrtMedia?, AppError>> pickVideo({
    ImageSource source = ImageSource.gallery,
  }) {
    return runAsyncCall(
      name: 'pickVideo',
      future: () async {
        final pickedMedia = await ImagePicker().pickVideo(source: source);
        if (pickedMedia == null) return Success(null);

        return Success(
          AlrtMedia(
            id: pickedMedia.id,
            value: pickedMedia.path,
            type: pickedMedia.mediaType,
            source: AlrtMediaSource.file,
          ),
        );
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<List<AlrtMedia>, AppError>> pickMedias() {
    return runAsyncCall(
      name: 'pickMedias',
      future: () async {
        final pickedMedias = await ImagePicker().pickMultipleMedia();
        if (pickedMedias.isEmpty) return Success(<AlrtMedia>[]);

        final medias = pickedMedias.map((pickedMedia) {
          return AlrtMedia(
            id: pickedMedia.id,
            value: pickedMedia.path,
            type: pickedMedia.mediaType,
            source: AlrtMediaSource.file,
          );
        }).toList();

        return Success(medias);
      },
      onError: Failure.new,
    );
  }
}
