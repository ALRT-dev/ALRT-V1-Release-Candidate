import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/shared/enums/video_priority_types.dart';
import 'package:hazard_app/features/shared/models/alrt_media_model.dart';
import 'package:hazard_app/features/shared/models/video_id_priority_model.dart';
import 'package:hazard_app/features/shared/providers/video_preview_lifecycle_provider.dart';
import 'package:hazard_app/features/shared/views/widgets/native_video_player.dart';

class VideoAlrtMediaPreview extends ConsumerWidget {
  /// Displays the video media.
  const VideoAlrtMediaPreview({
    super.key,
    required this.videoMedia,
    required this.priority,
    this.withMuteButton = true,
    this.muteButtonKey,
    this.muteButtonPositionedWidget,
    this.withPlayIcon = false,
    this.playIconSize = 50.0,
    this.autoPlay = true,
    this.registerLifecycle = true,
    this.playButtonPositionedWidget,
  });

  /// The video to display.
  final AlrtMedia videoMedia;

  /// The priority of the video to be played.
  /// This can be used to determine which video to play when there are multiple videos stacked on top of each other.
  ///
  /// Eg. A video is playing in a screen, and another video is playing in a dialog on top of the screen. In this case, the video in the dialog should have a higher priority than the video in the screen
  /// so that the video in the dialog is played and the video in the screen is paused.
  final VideoPriority priority;

  /// Whether the mute button should be displayed or not.
  final bool withMuteButton;

  /// The key of the mute button.
  final GlobalKey? muteButtonKey;

  /// The Positioned widget to cover the volume button.
  final Positioned Function(Widget)? muteButtonPositionedWidget;

  /// Whether the play button should be displayed or not.
  final bool withPlayIcon;

  /// The size of the play icon.
  final double playIconSize;

  /// Whether to autoplay the video or not.
  final bool autoPlay;

  /// Whether to register the lifecycle of this video preview.
  final bool registerLifecycle;

  /// The Positioned widget to cover the play button.
  final Positioned Function(Widget)? playButtonPositionedWidget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (registerLifecycle) {
      ref.watch(
        providerOfVideoPreviewLifecycle(
          VideoIdPriority(
            id: videoMedia.id,
            priority: priority,
          ),
        ).select((value) => null),
      );
    }

    return NativeVideoPlayer(
      videoMedia: videoMedia,
      priority: priority,
      withMuteButton: withMuteButton,
      muteButtonKey: muteButtonKey,
      muteButtonPositionedWidget: muteButtonPositionedWidget,
      withPlayIcon: withPlayIcon,
      playIconSize: playIconSize,
      autoPlay: autoPlay,
      playButtonPositionedWidget: playButtonPositionedWidget,
    );
  }
}
