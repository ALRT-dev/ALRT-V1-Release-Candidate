import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/shared/enums/support_request_types.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/providers/repository_providers.dart';
import 'package:hazard_app/features/shared/repositories/support_repository.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

class SupportService {
  const SupportService(final Ref ref) : _ref = ref;

  final Ref _ref;
  SupportRepository get _supportRepository =>
      _ref.read(providerOfSupportRepository);

  /// Submits a support request.
  Future<Either<void, AppError>> submitSupportRequest({
    required final SupportRequestType requestType,
    required final String details,
    final String? userName,
    final String? userEmail,
  }) async {
    return _supportRepository.submitSupportRequest(
      requestType: requestType,
      details: details,
      userName: userName,
      userEmail: userEmail,
    );
  }
}
