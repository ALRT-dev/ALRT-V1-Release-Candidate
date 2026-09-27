import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hazard_app/features/learn/providers/service_providers.dart';
import 'package:hazard_app/features/learn/providers/states/learn_provider_state.dart';
import 'package:hazard_app/features/learn/services/learn_service.dart';

/// Guide topics + the user's learn progress.
///
/// Deliberately kept alive (not autoDispose) so the completed/total/XP
/// counters stay cached for the feed guide-strip and the profile
/// "Learn & Prepare" card. Read `completedCount`, `totalCount` and
/// `totalXpEarned` straight off the state.
final providerOfLearn =
    StateNotifierProvider<LearnProvider, LearnProviderState>(
      (ref) => LearnProvider(
        ref: ref,
        state: const LearnProviderState(),
      ),
    );

class LearnProvider extends StateNotifier<LearnProviderState> {
  LearnProvider({
    required final Ref ref,
    required final LearnProviderState state,
  }) : _ref = ref,
       super(state) {
    load();
  }

  final Ref _ref;

  LearnService get _learnService => _ref.read(providerOfLearnService);

  /// Loads the guide topics, showing the full loading state.
  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    final result = await _learnService.getGuideTopics();
    if (!mounted) return;

    result.when(
      (topicsResponse) {
        state = state.copyWith(
          topicsResponse: topicsResponse,
          isLoading: false,
          clearError: true,
        );
      },
      (error) {
        state = state.copyWith(
          isLoading: false,
          error: error,
        );
      },
    );
  }

  /// Refreshes the guide topics.
  ///
  /// Keeps the current data on screen while refreshing (pull-to-refresh);
  /// falls back to a full [load] when nothing has been loaded yet.
  Future<void> refresh() async {
    if (!state.hasData) return load();

    final result = await _learnService.getGuideTopics();
    if (!mounted) return;

    result.when(
      (topicsResponse) {
        state = state.copyWith(
          topicsResponse: topicsResponse,
          clearError: true,
        );
      },
      (error) {
        // Keep the stale data visible; surface the error for listeners.
        state = state.copyWith(
          error: error,
        );
      },
    );
  }
}
