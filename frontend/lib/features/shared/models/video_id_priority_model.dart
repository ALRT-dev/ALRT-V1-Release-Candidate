import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/shared/enums/video_priority_types.dart';

part 'video_id_priority_model.freezed.dart';
part 'video_id_priority_model.g.dart';

@freezed
abstract class VideoIdPriority with _$VideoIdPriority {
  const factory VideoIdPriority({
    required String id,
    required VideoPriority priority,
  }) = _VideoIdPriority;

  factory VideoIdPriority.fromJson(Map<String, dynamic> json) =>
      _$VideoIdPriorityFromJson(json);
}
