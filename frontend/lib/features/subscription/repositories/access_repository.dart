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
  Future<Either<SponsorshipIntentResult, AppError>> createSponsorshipIntent({
    required final String circleId,
    required final PlanTier tier,
  });

  /// After a purchase or Restore: asks the backend to check the store's
  /// server record and returns what it found plus the resulting access.
  Future<Either<ReconcileResult, AppError>> reconcile({
    final List<String> productIds = const [],
  });

  /// Applies an already-verified group purchase to one hosted group, once.
  /// With [replaceExisting] the payer explicitly replaces THEIR OWN smaller
  /// plan on that group (recovery after an upgrade the store sent as a
  /// purchase ALRT could not match to one group).
  Future<Either<BindResult, AppError>> bindSponsorship({
    required final String subscriptionId,
    required final String circleId,
    final bool replaceExisting = false,
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
  Future<Either<SponsorshipIntentResult, AppError>> createSponsorshipIntent({
    required final String circleId,
    required final PlanTier tier,
  }) {
    return runAsyncCall(
      name: 'createSponsorshipIntent',
      future: () async {
        final response = await _dio.post<dynamic>(
          kUrlAccessSponsorshipIntents,
          data: {'circleId': circleId, 'tier': tier.name},
        );
        final data = response.data;
        return Success(
          data is Map
              ? SponsorshipIntentResult.fromJson(
                  Map<String, dynamic>.from(data),
                )
              : const SponsorshipIntentResult(),
        );
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<ReconcileResult, AppError>> reconcile({
    final List<String> productIds = const [],
  }) {
    return runAsyncCall(
      name: 'reconcileAccess',
      future: () async {
        // The ids are only looked up by the backend; they never grant.
        final response = await _dio.post<Map<String, dynamic>>(
          kUrlAccessReconcile,
          data: {'productIds': productIds},
        );
        return Success(ReconcileResult.fromJson(response.data ?? const {}));
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<BindResult, AppError>> bindSponsorship({
    required final String subscriptionId,
    required final String circleId,
    final bool replaceExisting = false,
  }) {
    return runAsyncCall(
      name: 'bindSponsorship',
      future: () async {
        final response = await _dio.post<dynamic>(
          kUrlAccessBindSponsorship(subscriptionId),
          data: {
            'circleId': circleId,
            if (replaceExisting) 'replaceExisting': true,
          },
        );
        final data = response.data;
        return Success(
          data is Map
              ? BindResult.fromJson(Map<String, dynamic>.from(data))
              : const BindResult(),
        );
      },
      onError: Failure.new,
    );
  }
}
