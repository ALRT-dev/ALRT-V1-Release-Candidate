import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/learn/models/guide_models.dart';
import 'package:hazard_app/features/learn/providers/repository_providers.dart';
import 'package:hazard_app/features/learn/repositories/learn_repository.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

class LearnService {
  LearnService(final Ref ref) : _ref = ref;

  final Ref _ref;

  LearnRepository get _learnRepository => _ref.read(providerOfLearnRepository);

  /// Fetches all guide topics along with the user's progress.
  Future<Either<GuideTopicsResponse, AppError>> getGuideTopics() {
    return _learnRepository.getGuideTopics();
  }

  /// Fetches a single guide by its [slugOrId].
  Future<Either<GuideDetail, AppError>> getGuideDetail({
    required final String slugOrId,
  }) {
    return _learnRepository.getGuideDetail(
      slugOrId: slugOrId,
    );
  }

  /// Marks the guide with the given [slugOrId] as completed.
  Future<Either<GuideCompletionResponse, AppError>> completeGuide({
    required final String slugOrId,
  }) {
    return _learnRepository.completeGuide(
      slugOrId: slugOrId,
    );
  }

  /// Fetches the guide linked to a hazard category, if any.
  ///
  /// Resolves to `Success(null)` when no guide is linked to the category.
  Future<Either<GuideForCategory?, AppError>> getGuideForCategory({
    required final String categoryId,
  }) {
    return _learnRepository.getGuideForCategory(
      categoryId: categoryId,
    );
  }
}
