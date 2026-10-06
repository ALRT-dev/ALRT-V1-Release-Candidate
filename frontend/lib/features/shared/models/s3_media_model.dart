import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/shared/enums/alrt_media_source_types.dart';
import 'package:hazard_app/features/shared/enums/alrt_media_types.dart';
import 'package:hazard_app/features/shared/models/alrt_media_model.dart';

part 's3_media_model.freezed.dart';
part 's3_media_model.g.dart';

@freezed
abstract class S3Media with _$S3Media {
  const S3Media._();

  const factory S3Media({
    /// The unique identifier for the media.
    required final String id,

    /// The presigned URL where the media can be accessed.
    @JsonKey(name: 'presignedUrl') required final String url,

    /// The S3 key of the media file.
    required final String s3Key,

    /// The type of the media (e.g., image, video).
    required final AlrtMediaType type,

    /// The size of the media file in bytes.
    final int? fileSize,

    /// The URL of the thumbnail for the media, if applicable.
    final String? thumbnailUrl,
  }) = _S3Media;

  /// Converts this [S3Media] instance to an [AlrtMedia] instance.
  AlrtMedia toAlrtMedia() {
    return AlrtMedia(
      id: id,
      value: url,
      type: type,
      source: AlrtMediaSource.networkUrl,
      s3Key: s3Key,
    );
  }

  factory S3Media.fromJson(Map<String, dynamic> json) =>
      _$S3MediaFromJson(json);
}
