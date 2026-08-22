import 'package:hazard_app/api/rest_client.dart';
import 'package:hazard_app/features/shared/enums/support_request_types.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

abstract class SupportRepository {
  Future<Either<void, AppError>> submitSupportRequest({
    required final SupportRequestType requestType,
    required final String details,
    final String? userEmail,
    final String? userName,
  });
}

class SupportRepositoryImpl implements SupportRepository {
  SupportRepositoryImpl({
    required RestClient restClient,
  }) : _restClient = restClient;

  final RestClient _restClient;

  @override
  Future<Either<void, AppError>> submitSupportRequest({
    required final SupportRequestType requestType,
    required final String details,
    final String? userName,
    final String? userEmail,
  }) {
    return runAsyncCall(
      name: 'submitSupportRequest',
      future: () async {
        await _restClient.submitSupportRequest(
          requestType: requestType.value,
          details: details,
          userName: userName,
          userEmail: userEmail,
        );
        return Success(null);
      },
      onError: Failure.new,
    );
  }
}
