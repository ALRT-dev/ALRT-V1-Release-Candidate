import 'package:hazard_app/features/learn/models/guide_models.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';

/// Plain immutable state for [providerOfLearn].
///
/// Written by hand (no freezed) because codegen is not available for this
/// feature; keep [copyWith] in sync when adding fields.
class LearnProviderState {
  const LearnProviderState({
    this.topicsResponse,
    this.isLoading = false,
    this.error,
  });

  /// Latest topics + progress payload; `null` until the first load succeeds.
  final GuideTopicsResponse? topicsResponse;

  /// Whether a load/refresh network call is in flight.
  final bool isLoading;

  /// Error from the most recent failed load/refresh, if any.
  final AppError? error;

  bool get hasData => topicsResponse != null;

  List<GuideTopic> get topics => topicsResponse?.topics ?? const <GuideTopic>[];

  int get completedCount => topicsResponse?.completedCount ?? 0;

  int get totalCount => topicsResponse?.totalCount ?? 0;

  int get totalXpEarned => topicsResponse?.totalXpEarned ?? 0;

  LearnProviderState copyWith({
    final GuideTopicsResponse? topicsResponse,
    final bool? isLoading,
    final AppError? error,
    final bool clearError = false,
  }) {
    return LearnProviderState(
      topicsResponse: topicsResponse ?? this.topicsResponse,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
