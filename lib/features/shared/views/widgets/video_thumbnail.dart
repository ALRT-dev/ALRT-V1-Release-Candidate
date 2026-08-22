import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/shared/enums/video_priority_types.dart';
import 'package:hazard_app/features/shared/models/alrt_media_model.dart';
import 'package:hazard_app/features/shared/views/widgets/native_video_player.dart';

class VideoThumbnail extends ConsumerWidget {
  /// Displays the thumbnail of the provided video.
  const VideoThumbnail({
    super.key,
    required this.videoMedia,
    this.withPlayIcon = true,
    this.playButtonPositionedWidget,
    this.playIconSize = 50.0,
  });

  /// The video file to display thumbnail of.
  final AlrtMedia videoMedia;

  /// The Positioned widget to cover the play button.
  final Positioned Function(Widget)? playButtonPositionedWidget;

  /// The size of the play icon.
  final double playIconSize;

  /// Whether to display the play icon or not.
  final bool withPlayIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NativeVideoPlayer(
      videoMedia: videoMedia,
      priority: VideoPriority.level1,
      autoPlay: false,
      withPlayIcon: withPlayIcon,
      playButtonPositionedWidget: playButtonPositionedWidget,
      playIconSize: playIconSize,
    );
  }
}
