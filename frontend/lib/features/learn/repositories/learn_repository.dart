import 'package:hazard_app/api/rest_client.dart';
import 'package:hazard_app/features/learn/models/guide_models.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

abstract class LearnRepository {
  /// Fetches all guide topics along with the user's progress.
  Future<Either<GuideTopicsResponse, AppError>> getGuideTopics();

  /// Fetches a single guide by its [slugOrId].
  Future<Either<GuideDetail, AppError>> getGuideDetail({
    required final String slugOrId,
  });

  /// Marks the guide with the given [slugOrId] as completed.
  Future<Either<GuideCompletionResponse, AppError>> completeGuide({
    required final String slugOrId,
  });

  /// Fetches the guide linked to a hazard category, if any.
  ///
  /// Resolves to `Success(null)` when no guide is linked to the category.
  Future<Either<GuideForCategory?, AppError>> getGuideForCategory({
    required final String categoryId,
  });
}

class LearnRepositoryImpl implements LearnRepository {
  LearnRepositoryImpl({
    required final RestClient restClient,
  }) : _restClient = restClient;

  final RestClient _restClient;

  @override
  Future<Either<GuideTopicsResponse, AppError>> getGuideTopics() {
    return runAsyncCall(
      name: 'getGuideTopics',
      future: () async {
        final result = await _restClient.getGuideTopics();
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<GuideDetail, AppError>> getGuideDetail({
    required final String slugOrId,
  }) {
    return runAsyncCall(
      name: 'getGuideDetail',
      future: () async {
        final result = await _restClient.getGuideDetail(
          slugOrId: slugOrId,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<GuideCompletionResponse, AppError>> completeGuide({
    required final String slugOrId,
  }) {
    return runAsyncCall(
      name: 'completeGuide',
      future: () async {
        final result = await _restClient.completeGuide(
          slugOrId: slugOrId,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<GuideForCategory?, AppError>> getGuideForCategory({
    required final String categoryId,
  }) {
    return runAsyncCall(
      name: 'getGuideForCategory',
      future: () async {
        final response = await _restClient.getGuideForCategory(
          categoryId: categoryId,
        );

        final data = response.data;

        // A null/empty body means no guide is linked to this category.
        if (data == null || (data is String && data.trim().isEmpty)) {
          return Success<GuideForCategory?, AppError>(null);
        }

        if (data is Map) {
          return Success<GuideForCategory?, AppError>(
            GuideForCategory.fromJson(Map<String, dynamic>.from(data)),
          );
        }

        // Unexpected body shape — treat as "no guide" rather than failing.
        return Success<GuideForCategory?, AppError>(null);
      },
      onError: Failure.new,
    );
  }
}
