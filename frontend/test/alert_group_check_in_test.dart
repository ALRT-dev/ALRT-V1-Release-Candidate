import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/providers/states/family_provider_state.dart';
import 'package:hazard_app/features/family/services/family_service.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

class RecordingService extends FamilyService {
  RecordingService(super.ref);
  final calls = <Map<String, Object?>>[];
  bool fail = false;
  @override
  Future<Either<FamilyCheckIn, AppError>> sendFamilyCheckIn({
    FamilyCheckInStatus? status,
    String? message,
    double? latitude,
    double? longitude,
    String? requestId,
    String? hazardId,
    String? circleId,
  }) async {
    calls.add({
      'circleId': circleId,
      'hazardId': hazardId,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'requestId': requestId,
    });
    if (fail) return const Failure(AppError(message: 'Unavailable'));
    return Success(
      FamilyCheckIn(
        id: 'check',
        circleId: circleId!,
        memberId: 'me',
        status: status!,
      ),
    );
  }
}

void main() {
  test(
    'alert check-in targets only the named group and sends no location without consent',
    () async {
      late RecordingService service;
      final container = ProviderContainer(
        overrides: [
          providerOfFamilyService.overrideWith(
            (ref) => service = RecordingService(ref),
          ),
          providerOfFamily.overrideWith(
            (ref) => FamilyProvider(
              ref: ref,
              bootstrap: false,
              state: const FamilyProviderState(
                circle: FamilyCircle(
                  id: 'other',
                  name: 'Other',
                  myMemberId: 'other-me',
                ),
                circles: [
                  FamilyCircleSummary(
                    circleId: 'chosen',
                    name: 'Chosen',
                    myMemberId: 'me',
                  ),
                  FamilyCircleSummary(
                    circleId: 'other',
                    name: 'Other',
                    myMemberId: 'other-me',
                  ),
                ],
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final result = await container
          .read(providerOfFamily.notifier)
          .checkInToCircle(
            circleId: 'chosen',
            hazardId: 'incident',
            shareLocation: false,
            status: FamilyCheckInStatus.needsHelp,
          );
      expect(result, AlertCheckInOutcome.sent);
      expect(service.calls, [
        {
          'circleId': 'chosen',
          'hazardId': 'incident',
          'status': FamilyCheckInStatus.needsHelp,
          'latitude': null,
          'longitude': null,
          'requestId': null,
        },
      ]);
      expect(container.read(providerOfFamily).recentCheckIns, isEmpty);
      service.fail = true;
      expect(
        await container
            .read(providerOfFamily.notifier)
            .checkInToCircle(
              circleId: 'chosen',
              hazardId: 'incident',
              shareLocation: false,
            ),
        AlertCheckInOutcome.failed,
      );
      expect(container.read(providerOfFamily).checkInState.isError, isTrue);
    },
  );
}
