import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hazard_app/api/rest_client.dart';
import 'package:hazard_app/features/search/models/hazard_search_params.dart';
import 'package:hazard_app/features/shared/enums/hazard_vote_types.dart';
import 'package:hazard_app/features/shared/models/alrt_media_model.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/models/hazard_category_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/models/get_hazards_with_subscription_id_reponse.dart';
import 'package:hazard_app/features/shared/models/view_hazard_response_model.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

abstract class HazardRepository {
  Future<Either<List<Hazard>, AppError>> getHazards({
    required final HazardSearchParams searchParams,
    final CancelToken? cancelToken,
  });

  Future<Either<GetHazardsWithSubscriptionIdResponse, AppError>>
  getGetHazardsWithSubscriptionId({
    required final HazardSearchParams searchParams,
  });

  Future<Either<List<HazardCategory>, AppError>> getAllHazardCategories();

  Future<Either<List<HazardCategory>, AppError>> getAllParentHazardCategories();

  Future<Either<List<HazardCategory>, AppError>> getAllSubHazardCategories();

  Future<Either<Hazard, AppError>> createHazardReport({
    required final Hazard hazard,
    final List<AlrtMedia>? mediaFiles,
  });

  Future<Either<Hazard, AppError>> updateHazardReport({
    required final Hazard hazard,
    final List<AlrtMedia>? mediaFiles,
    final List<String>? removedMediaIds,
  });

  Future<Either<void, AppError>> deleteHazard({
    required final String hazardId,
  });

  Future<Either<void, AppError>> voteHazard({
    required final String hazardId,
    required final HazardVoteType voteType,
  });

  Future<Either<ViewHazardResponse, AppError>> viewHazard({
    required final String hazardId,
  });
}

class HazardRepositoryImpl extends HazardRepository {
  HazardRepositoryImpl({
    required final RestClient restClient,
  }) : _restClient = restClient;

  final RestClient _restClient;

  @override
  Future<Either<List<Hazard>, AppError>> getHazards({
    required final HazardSearchParams searchParams,
    final CancelToken? cancelToken,
  }) {
    return runAsyncCall(
      name: 'getHazards',
      future: () async {
        final result = await _restClient.getHazards(
          searchParams: searchParams,
          cancelToken: cancelToken,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<GetHazardsWithSubscriptionIdResponse, AppError>>
  getGetHazardsWithSubscriptionId({
    required HazardSearchParams searchParams,
  }) {
    return runAsyncCall(
      name: 'getGetHazardsWithSubscriptionId',
      future: () async {
        final result = await _restClient.getGetHazardsWithSubscriptionId(
          searchParams: searchParams,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<List<HazardCategory>, AppError>> getAllHazardCategories() {
    return runAsyncCall(
      name: 'getAllHazardCategories',
      future: () async {
        final result = await _restClient.getAllHazardCategories();
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<Hazard, AppError>> createHazardReport({
    required Hazard hazard,
    List<AlrtMedia>? mediaFiles,
  }) {
    return runAsyncCall(
      name: 'createHazardReport',
      future: () async {
        final result = await _restClient.createHazardReport(
          hazard: hazard.toJson(),
          mediaFiles: mediaFiles?.map((media) => File(media.value)).toList(),
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> voteHazard({
    required String hazardId,
    required HazardVoteType voteType,
  }) {
    return runAsyncCall(
      name: 'voteHazard',
      future: () async {
        await _restClient.voteHazard(
          hazardId: hazardId,
          voteType: voteType.name,
        );
        return Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<ViewHazardResponse, AppError>> viewHazard({
    required String hazardId,
  }) {
    return runAsyncCall(
      name: 'viewHazard',
      future: () async {
        final result = await _restClient.viewHazard(
          hazardId: hazardId,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> deleteHazard({required String hazardId}) {
    return runAsyncCall(
      name: 'deleteHazard',
      future: () async {
        await _restClient.deleteHazardReport(
          hazardId: hazardId,
        );
        return Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<Hazard, AppError>> updateHazardReport({
    required Hazard hazard,
    List<AlrtMedia>? mediaFiles,
    List<String>? removedMediaIds,
  }) {
    return runAsyncCall(
      name: 'updateHazardReport',
      future: () async {
        final result = await _restClient.updateHazardReport(
          hazardId: hazard.id!,
          hazard: hazard.toJson(),
          mediaFiles: mediaFiles?.map((media) => File(media.value)).toList(),
          removedMediaIds: removedMediaIds,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<List<HazardCategory>, AppError>>
  getAllParentHazardCategories() {
    return runAsyncCall(
      name: 'getAllParentHazardCategories',
      future: () async {
        final result = await _restClient.getAllParentHazardCategories();
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<List<HazardCategory>, AppError>> getAllSubHazardCategories() {
    return runAsyncCall(
      name: 'getAllSubHazardCategories',
      future: () async {
        final result = await _restClient.getAllSubHazardCategories();
        return Success(result);
      },
      onError: Failure.new,
    );
  }
}
