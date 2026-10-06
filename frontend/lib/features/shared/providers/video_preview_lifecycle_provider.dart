import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/shared/models/video_id_priority_model.dart';
import 'package:hazard_app/features/shared/providers/currently_playing_video_priorities_provider.dart';

/// A provider that manages the lifecycle of [VideoAlrtMediaPreview] widget.
///
/// When a [VideoAlrtMediaPreview] is created, it adds a given [VideoPriority] to the list of currently playing video priorities.
/// When the [VideoAlrtMediaPreview] is disposed, it removes the given [VideoPriority] from the list of currently playing video priorities.
final providerOfVideoPreviewLifecycle = Provider.autoDispose
    .family<void, VideoIdPriority>(
      (ref, videoIdPriority) {
        Future.microtask(() {
          ref
              .read(providerOfCurrentlyPlayingVideoPriorities.notifier)
              .addPriority(videoIdPriority.priority);
        });

        final provider = ref.read(
          providerOfCurrentlyPlayingVideoPriorities.notifier,
        );

        ref.onDispose(() {
          provider.removePriority(videoIdPriority.priority);
        });
      },
    );
