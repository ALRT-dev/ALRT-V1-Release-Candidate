import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/api/endpoints.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/providers/dio_instance_provider.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';
import 'package:hazard_app/features/shared/utils/either.dart';
import 'package:hazard_app/features/subscription/models/access_models.dart';

/// Provides [AccessRepository], on the app's authenticated Dio instance.
final providerOfAccessRepository = Provider<AccessRepository>((ref) {
  return AccessRepositoryImpl(dio: ref.watch(providerOfDioInstance(false)));
});

/// The V1 access endpoints (backend `access.route.ts`).
abstract class AccessRepository {
  /// Personal plan and each group's coverage, computed by the backend.
  Future<Either<AccessSummary, AppError>> getAccess();

  /// Records the group a Family/Group purchase will cover, before the
  /// store sheet opens. Host only; the backend checks capacity.
  Future<Either<void, AppError>> createSponsorshipIntent({
    required final String circleId,
    required final PlanTier tier,
  });

  /// Applies an already-verified group purchase to one hosted group, once.
  Future<Either<void, AppError>> bindSponsorship({
    required final String subscriptionId,
    required final String circleId,
  });
}

class AccessRepositoryImpl implements AccessRepository {
  AccessRepositoryImpl({required final Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<Either<AccessSummary, AppError>> getAccess() {
    return runAsyncCall(
      name: 'getAccess',
      future: () async {
        final response = await _dio.get<Map<String, dynamic>>(kUrlAccess);
        return Success(AccessSummary.fromJson(response.data ?? const {}));
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> createSponsorshipIntent({
    required final String circleId,
    required final PlanTier tier,
  }) {
    return runAsyncCall(
      name: 'createSponsorshipIntent',
      future: () async {
        await _dio.post<dynamic>(
          kUrlAccessSponsorshipIntents,
          data: {'circleId': circleId, 'tier': tier.name},
        );
        return const Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> bindSponsorship({
    required final String subscriptionId,
    required final String circleId,
  }) {
    return runAsyncCall(
      name: 'bindSponsorship',
      future: () async {
        await _dio.post<dynamic>(
          kUrlAccessBindSponsorship(subscriptionId),
          data: {'circleId': circleId},
        );
        return const Success(null);
      },
      onError: Failure.new,
    );
  }
}
