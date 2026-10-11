import 'package:hazard_app/api/rest_client.dart';
import 'package:hazard_app/features/ready/models/ready_models.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

abstract class ReadyRepository {
  Future<Either<ReadySummary, AppError>> getSummary();
  Future<Either<List<EmergencyPlan>, AppError>> listPlans();
  Future<Either<EmergencyPlan, AppError>> getPlan(String planId);
  Future<Either<EmergencyPlan, AppError>> createPlan(
      Map<String, dynamic> body);
  Future<Either<EmergencyPlan, AppError>> updatePlan(
      String planId, Map<String, dynamic> body);
  Future<Either<void, AppError>> deletePlan(String planId);
  Future<Either<List<EmergencyDrill>, AppError>> listDrills();
  Future<Either<EmergencyDrill, AppError>> createDrill(
      Map<String, dynamic> body);
  Future<Either<void, AppError>> deleteDrill(String drillId);
}

class ReadyRepositoryImpl implements ReadyRepository {
  ReadyRepositoryImpl({required RestClient restClient})
      : _restClient = restClient;

  final RestClient _restClient;

  @override
  Future<Either<ReadySummary, AppError>> getSummary() {
    return runAsyncCall(
      name: 'getReadySummary',
      future: () async {
        final response = await _restClient.getReadySummary();
        final data = response.data as Map<String, dynamic>;
        return Success(ReadySummary.fromJson(data));
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<List<EmergencyPlan>, AppError>> listPlans() {
    return runAsyncCall(
      name: 'listReadyPlans',
      future: () async {
        final response = await _restClient.getReadyPlans();
        final data = response.data as List<dynamic>;
        final plans = data
            .map((e) => EmergencyPlan.fromJson(e as Map<String, dynamic>))
            .toList();
        return Success(plans);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<EmergencyPlan, AppError>> getPlan(String planId) {
    return runAsyncCall(
      name: 'getReadyPlan',
      future: () async {
        final response = await _restClient.getReadyPlan(planId: planId);
        final data = response.data as Map<String, dynamic>;
        return Success(EmergencyPlan.fromJson(data));
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<EmergencyPlan, AppError>> createPlan(
      Map<String, dynamic> body) {
    return runAsyncCall(
      name: 'createReadyPlan',
      future: () async {
        final response = await _restClient.createReadyPlan(body: body);
        final data = response.data as Map<String, dynamic>;
        return Success(EmergencyPlan.fromJson(data));
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<EmergencyPlan, AppError>> updatePlan(
      String planId, Map<String, dynamic> body) {
    return runAsyncCall(
      name: 'updateReadyPlan',
      future: () async {
        final response =
            await _restClient.updateReadyPlan(planId: planId, body: body);
        final data = response.data as Map<String, dynamic>;
        return Success(EmergencyPlan.fromJson(data));
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> deletePlan(String planId) {
    return runAsyncCall(
      name: 'deleteReadyPlan',
      future: () async {
        await _restClient.deleteReadyPlan(planId: planId);
        return const Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<List<EmergencyDrill>, AppError>> listDrills() {
    return runAsyncCall(
      name: 'listReadyDrills',
      future: () async {
        final response = await _restClient.getReadyDrills();
        final data = response.data as List<dynamic>;
        final drills = data
            .map((e) => EmergencyDrill.fromJson(e as Map<String, dynamic>))
            .toList();
        return Success(drills);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<EmergencyDrill, AppError>> createDrill(
      Map<String, dynamic> body) {
    return runAsyncCall(
      name: 'createReadyDrill',
      future: () async {
        final response = await _restClient.createReadyDrill(body: body);
        final data = response.data as Map<String, dynamic>;
        return Success(EmergencyDrill.fromJson(data));
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> deleteDrill(String drillId) {
    return runAsyncCall(
      name: 'deleteReadyDrill',
      future: () async {
        await _restClient.deleteReadyDrill(drillId: drillId);
        return const Success(null);
      },
      onError: Failure.new,
    );
  }
}
