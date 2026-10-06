import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/shared/enums/alrt_media_source_types.dart';
import 'package:hazard_app/features/shared/enums/alrt_media_types.dart';

part 'alrt_media_model.freezed.dart';
part 'alrt_media_model.g.dart';

@freezed
abstract class AlrtMedia with _$AlrtMedia {
  const factory AlrtMedia({
    /// The unique identifier for the media.
    required final String id,

    /// The [value] parameter represents either the local path of the file or network url of the file.
    required final String value,

    /// The type of media.
    ///
    /// E.g: image or video.
    required final AlrtMediaType type,

    /// The source of the media.
    ///
    /// E.g: file, networkUrl, or asset.
    required final AlrtMediaSource source,

    /// The S3 key of the media file if it's stored in S3.
    final String? s3Key,
  }) = _AlrtMedia;

  factory AlrtMedia.fromJson(Map<String, dynamic> json) =>
      _$AlrtMediaFromJson(json);
}
