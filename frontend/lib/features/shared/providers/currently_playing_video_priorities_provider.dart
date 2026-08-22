import 'package:flutter_riverpod/legacy.dart';
import 'package:hazard_app/features/shared/enums/video_priority_types.dart';

final providerOfCurrentlyPlayingVideoPriorities =
    StateNotifierProvider<
      CurrentlyPlayingVideoPrioritiesProvider,
      List<VideoPriority>
    >(
      (ref) => CurrentlyPlayingVideoPrioritiesProvider(),
    );

class CurrentlyPlayingVideoPrioritiesProvider
    extends StateNotifier<List<VideoPriority>> {
  CurrentlyPlayingVideoPrioritiesProvider() : super([]);

  void addPriority(VideoPriority priority) {
    state = [...state, priority];
  }

  void removePriority(VideoPriority priority) {
    final index = state.indexOf(priority);
    if (index != -1) {
      final newState = [...state];
      newState.removeAt(index);
      state = newState;
    }
  }
}
