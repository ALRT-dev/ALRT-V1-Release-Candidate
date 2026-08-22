import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hazard_app/features/learn/models/guide_models.dart';
import 'package:hazard_app/features/learn/providers/learn_provider.dart';
import 'package:hazard_app/features/learn/providers/service_providers.dart';
import 'package:hazard_app/features/learn/providers/states/guide_detail_provider_state.dart';
import 'package:hazard_app/features/learn/services/learn_service.dart';
import 'package:hazard_app/features/shared/services/analytics_service.dart';

/// A single guide, keyed by its slug (or id). Loads on first watch.
final providerOfGuideDetail = StateNotifierProvider.autoDispose
    .family<GuideDetailProvider, GuideDetailProviderState, String>(
      (ref, slugOrId) => GuideDetailProvider(
        ref: ref,
        slugOrId: slugOrId,
        state: const GuideDetailProviderState(),
      ),
    );

class GuideDetailProvider extends StateNotifier<GuideDetailProviderState> {
  GuideDetailProvider({
    required final Ref ref,
    required this.slugOrId,
    required final GuideDetailProviderState state,
  }) : _ref = ref,
       super(state) {
    loadGuideDetail();
  }

  final Ref _ref;
  final String slugOrId;

  LearnService get _learnService => _ref.read(providerOfLearnService);

  /// Loads (or reloads) the guide detail.
  Future<void> loadGuideDetail() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    final result = await _learnService.getGuideDetail(
      slugOrId: slugOrId,
    );
    if (!mounted) return;

    result.when(
      (detail) {
        state = state.copyWith(
          detail: detail,
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

  /// Marks this guide as completed.
  ///
  /// On success, updates the local detail to completed, refreshes the
  /// topics/progress in [providerOfLearn], and returns the
  /// [GuideCompletionResponse] (XP awarded, new XP total). Returns `null`
  /// on failure — the error is available via
  /// [GuideDetailProviderState.completionError].
  Future<GuideCompletionResponse?> completeGuide() async {
    if (state.isCompleting) return null;

    state = state.copyWith(
      isCompleting: true,
      clearCompletionError: true,
    );

    final result = await _learnService.completeGuide(
      slugOrId: slugOrId,
    );
    if (!mounted) return null;

    return result.when(
      (completion) {
        AnalyticsService.guideCompleted(guideSlug: slugOrId);
        state = state.copyWith(
          isCompleting: false,
          detail: state.detail?.copyWith(
            completed: true,
            completedAt: state.detail?.completedAt ?? DateTime.now(),
          ),
        );

        // Keep the hero card / topic progress in sync.
        _ref.read(providerOfLearn.notifier).refresh();

        return completion;
      },
      (error) {
        state = state.copyWith(
          isCompleting: false,
          completionError: error,
        );
        return null;
      },
    );
  }
}
