import 'package:hazard_app/features/shared/enums/alrt_media_types.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';

extension XFileExtension on XFile {
  /// Generates a unique identifier for the file.
  String get id => const Uuid().v4();

  /// Determines the media type (image or video) based on the file's MIME type.
  AlrtMediaType get mediaType {
    final mimeType = lookupMimeType(path);

    if (mimeType != null) {
      if (mimeType.startsWith('image/')) {
        return AlrtMediaType.image;
      } else if (mimeType.startsWith('video/')) {
        return AlrtMediaType.video;
      }
    }

    return AlrtMediaType.unknown;
  }
}
