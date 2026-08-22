import 'package:hazard_app/features/learn/models/guide_models.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';

/// Plain immutable state for [providerOfGuideDetail].
///
/// Written by hand (no freezed) because codegen is not available for this
/// feature; keep [copyWith] in sync when adding fields.
class GuideDetailProviderState {
  const GuideDetailProviderState({
    this.detail,
    this.isLoading = false,
    this.error,
    this.isCompleting = false,
    this.completionError,
  });

  /// The loaded guide; `null` until the first load succeeds.
  final GuideDetail? detail;

  /// Whether the guide detail is being fetched.
  final bool isLoading;

  /// Error from the most recent failed detail load, if any.
  final AppError? error;

  /// Whether a completion request is in flight.
  final bool isCompleting;

  /// Error from the most recent failed completion attempt, if any.
  final AppError? completionError;

  bool get hasData => detail != null;

  bool get isCompleted => detail?.completed ?? false;

  GuideDetailProviderState copyWith({
    final GuideDetail? detail,
    final bool? isLoading,
    final AppError? error,
    final bool? isCompleting,
    final AppError? completionError,
    final bool clearError = false,
    final bool clearCompletionError = false,
  }) {
    return GuideDetailProviderState(
      detail: detail ?? this.detail,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isCompleting: isCompleting ?? this.isCompleting,
      completionError: clearCompletionError
          ? null
          : (completionError ?? this.completionError),
    );
  }
}
