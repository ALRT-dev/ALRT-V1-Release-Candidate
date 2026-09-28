import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/utils/either.dart';
import 'package:hazard_app/features/subscription/models/access_models.dart';
import 'package:hazard_app/features/subscription/repositories/access_repository.dart';

/// Answers like the backend's /api/access endpoints, from fixed values.
class FakeAccessRepository implements AccessRepository {
  FakeAccessRepository({
    required this.access,
    this.intent = const SponsorshipIntentResult(),
    this.reconcileResult,
    this.reconcileFails = false,
  });

  AccessSummary access;
  SponsorshipIntentResult intent;
  ReconcileResult? reconcileResult;
  bool reconcileFails;
  final intents = <(String, PlanTier)>[];
  int reconcileCalls = 0;
  List<String> lastProductIds = const [];
  BindResult bindResult = const BindResult();
  final binds = <(String, String, bool)>[];

  @override
  Future<Either<AccessSummary, AppError>> getAccess() async => Success(access);

  @override
  Future<Either<SponsorshipIntentResult, AppError>> createSponsorshipIntent({
    required final String circleId,
    required final PlanTier tier,
  }) async {
    intents.add((circleId, tier));
    return Success(intent);
  }

  @override
  Future<Either<ReconcileResult, AppError>> reconcile({
    final List<String> productIds = const [],
  }) async {
    reconcileCalls += 1;
    lastProductIds = productIds;
    if (reconcileFails) return Failure(const AppError(message: 'offline'));
    return Success(
      reconcileResult ??
          ReconcileResult(
            storeChecked: true,
            confirmedChanges: 0,
            unrecorded: const [],
            access: access,
          ),
    );
  }

  @override
  Future<Either<BindResult, AppError>> bindSponsorship({
    required final String subscriptionId,
    required final String circleId,
    final bool replaceExisting = false,
  }) async {
    binds.add((subscriptionId, circleId, replaceExisting));
    return Success(bindResult);
  }
}
