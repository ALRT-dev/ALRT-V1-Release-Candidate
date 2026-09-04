import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/api/rest_client.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/family/providers/selected_circle_provider.dart';
import 'package:hazard_app/features/shared/providers/rest_client_provider.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

/// Provides [FamilyRepository].
final providerOfFamilyRepository = Provider<FamilyRepository>((ref) {
  return FamilyRepositoryImpl(
    restClient: ref.watch(providerOfRestClient),
    // Read at call time so switching circles never rebuilds the repository.
    selectedCircleId: () => ref.read(providerOfSelectedCircleId),
  );
});

abstract class FamilyRepository {
  /// Returns the user's family circle, or `null` when they have none.
  Future<Either<FamilyCircle?, AppError>> getFamilyCircle();

  /// All circles the user belongs to (for the switcher and seat ledger).
  Future<Either<List<FamilyCircleSummary>, AppError>> getFamilyCircles();

  Future<Either<FamilyCircle, AppError>> createFamilyCircle({
    required final String name,
  });

  Future<Either<void, AppError>> updateFamilyCircle({
    final String? name,
    final String? themeColor,
    final bool? anyoneCanRequestSnapshot,
    final bool? sosToWholeGroup,
    final bool? journeysSnapPointsOnly,
  });

  Future<Either<void, AppError>> deleteFamilyCircle();

  Future<Either<void, AppError>> leaveFamilyCircle();

  Future<Either<FamilyTransferCandidates, AppError>>
  getFamilyTransferCandidates();

  Future<Either<FamilyCircle, AppError>> transferFamilyOwnership({
    required final String newOwnerMemberId,
  });

  Future<Either<void, AppError>> removeFamilyMember({
    required final String memberId,
  });

  Future<Either<void, AppError>> updateOwnFamilyMember({
    final String? nickname,
    final FamilySharingLevel? sharingLevel,
    final String? colorHex,
  });

  Future<Either<void, AppError>> updateOwnFamilyMemberPhoto({
    required final File photo,
  });

  /// The group picture for the whole circle (owner only).
  Future<Either<void, AppError>> updateFamilyCirclePhoto({
    required final File photo,
  });

  Future<Either<void, AppError>> removeFamilyCirclePhoto();

  Future<Either<FamilyInvite, AppError>> createFamilyInvite({
    final bool isGuestInvite = false,
  });

  Future<Either<List<FamilyInvite>, AppError>> getFamilyInvites();

  Future<Either<void, AppError>> revokeFamilyInvite({
    required final String inviteId,
  });

  Future<Either<FamilyCircle, AppError>> joinFamilyCircle({
    required final String code,
  });

  Future<Either<void, AppError>> sendFamilyLocationPing({
    required final double latitude,
    required final double longitude,
    final double? accuracy,
    final double? speed,
    final int? batteryLevel,
    final bool? isMoving,
  });

  Future<Either<FamilyLocationRequest, AppError>> createFamilyLocationRequest({
    required final String memberId,
  });

  /// Selected members, or the whole group — pass every member id wanted.
  /// Returns the ids that failed their own checks (e.g. sharing off)
  /// alongside the ones that succeeded, rather than failing the whole ask.
  Future<Either<List<String>, AppError>> createFamilyLocationRequestsBulk({
    required final List<String> memberIds,
  });

  Future<Either<void, AppError>> cancelFamilyLocationRequest({
    required final String requestId,
  });

  Future<Either<List<FamilyLocationRequest>, AppError>>
  getPendingFamilyLocationRequests();

  Future<Either<FamilyLocationRequest, AppError>>
  respondToFamilyLocationRequest({
    required final String requestId,
    required final bool share,
    final double? latitude,
    final double? longitude,
  });

  Future<Either<FamilyCheckIn, AppError>> sendFamilyCheckIn({
    final FamilyCheckInStatus? status,
    final String? message,
    final double? latitude,
    final double? longitude,
    final String? requestId,
    final String? hazardId,
    final String? circleId,
  });

  Future<Either<FamilyCheckInRequest, AppError>> requestFamilyCheckIn({
    final String? message,
    final String? hazardId,
  });

  Future<Either<void, AppError>> cancelFamilyCheckInRequest({
    required final String requestId,
  });

  Future<Either<List<FamilyCheckIn>, AppError>> getFamilyCheckIns({
    final int? limit,
  });

  Future<Either<FamilyScheduledCheckIn, AppError>>
  createFamilyScheduledCheckIn({
    required final String timeOfDay,
    final FamilyScheduledCheckInMode? mode,
  });

  Future<Either<List<FamilyScheduledCheckIn>, AppError>>
  getFamilyScheduledCheckIns();

  Future<Either<void, AppError>> deleteFamilyScheduledCheckIn({
    required final String scheduledCheckInId,
  });

  Future<Either<List<FamilySavedPlace>, AppError>> getFamilyPlaces();

  Future<Either<FamilySavedPlace, AppError>> createFamilyPlace({
    required final String name,
    required final double latitude,
    required final double longitude,
    final FamilyPlaceIcon? icon,
    final int? radiusMeters,
    final String? address,
  });

  Future<Either<FamilySavedPlace, AppError>> updateFamilyPlace({
    required final String placeId,
    final String? name,
    final FamilyPlaceIcon? icon,
    final double? latitude,
    final double? longitude,
    final int? radiusMeters,
    final String? address,
  });

  Future<Either<void, AppError>> deleteFamilyPlace({
    required final String placeId,
  });

  Future<Either<FamilyPlaceNotificationPref, AppError>> updateFamilyPlacePref({
    required final String placeId,
    required final String subjectMemberId,
    required final bool notifyArrivals,
    required final bool notifyDepartures,
  });

  Future<Either<FamilySosEvent, AppError>> triggerFamilySos({
    final double? latitude,
    final double? longitude,
    final String? sosListId,
    required final bool isLive,
  });

  /// Starts a journey shared with the chosen members.
  Future<Either<FamilyJourney, AppError>> startFamilyJourney({
    required final int durationMinutes,
    required final List<String> recipientMemberIds,
    final bool isLive = false,
  });

  /// The caller's own running journey, or null.
  Future<Either<FamilyJourney?, AppError>> getMyFamilyJourney();

  /// Running journeys the caller was picked to see.
  Future<Either<List<FamilyJourney>, AppError>> getFamilyJourneysSharedWithMe();

  /// A single journey, for the traveller or a recipient they were shared
  /// with - including after it has ended. Backend enforces access; anyone
  /// else gets an [AppError].
  Future<Either<FamilyJourney, AppError>> getFamilyJourney({
    required final String journeyId,
  });

  /// Extends a running journey by one more block.
  Future<Either<FamilyJourney, AppError>> extendFamilyJourney({
    required final String journeyId,
    final int? minutes,
  });

  /// Stops a journey now.
  Future<Either<FamilyJourney, AppError>> stopFamilyJourney({
    required final String journeyId,
  });

  Future<Either<FamilyJourney, AppError>> postFamilyJourneyPoint({
    required final String journeyId,
    required final double latitude,
    required final double longitude,
    final String? locationLabel,
  });

  Future<Either<List<FamilySosList>, AppError>> getFamilySosLists();

  Future<Either<List<FamilySosRecipientGroup>, AppError>>
  getFamilySosRecipients();

  Future<Either<void, AppError>> takeOverFamilyCircle();

  Future<Either<FamilySosList, AppError>> createFamilySosList({
    required final String name,
    required final List<String> memberIds,
    final bool? isDefault,
  });

  Future<Either<FamilySosList, AppError>> updateFamilySosList({
    required final String sosListId,
    final String? name,
    final List<String>? memberIds,
    final bool? isDefault,
  });

  Future<Either<void, AppError>> deleteFamilySosList({
    required final String sosListId,
  });

  Future<Either<List<FamilySosEvent>, AppError>> getActiveFamilySosEvents();

  /// Stood-down SOS events with who acknowledged them (never locations).
  Future<Either<List<FamilySosEvent>, AppError>> getFamilySosHistory();

  Future<Either<FamilySosResponse, AppError>> respondToFamilySos({
    required final String sosEventId,
    required final FamilySosResponseType type,
  });

  Future<Either<FamilySosEvent, AppError>> resolveFamilySos({
    required final String sosEventId,
  });

  Future<Either<FamilySosTrail, AppError>> getFamilySosTrail({
    required final String sosEventId,
  });
}

class FamilyRepositoryImpl implements FamilyRepository {
  FamilyRepositoryImpl({
    required RestClient restClient,
    final String? Function()? selectedCircleId,
  }) : _restClient = restClient,
       _selectedCircleId = selectedCircleId ?? (() => null);

  final RestClient _restClient;

  /// Resolves the circle every family call is scoped to; null = first circle.
  final String? Function() _selectedCircleId;
  String? get _circleId => _selectedCircleId();

  @override
  Future<Either<FamilyCircle?, AppError>> getFamilyCircle() {
    return runAsyncCall(
      name: 'getFamilyCircle',
      future: () async {
        final response = await _restClient.getFamilyCircle(circleId: _circleId);
        final data = response.data;
        if (data == null) return const Success(null);
        return Success(
          FamilyCircle.fromJson(Map<String, dynamic>.from(data as Map)),
        );
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<List<FamilyCircleSummary>, AppError>> getFamilyCircles() {
    return runAsyncCall(
      name: 'getFamilyCircles',
      future: () async {
        final result = await _restClient.getFamilyCircles();
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<FamilyCircle, AppError>> createFamilyCircle({
    required String name,
  }) {
    return runAsyncCall(
      name: 'createFamilyCircle',
      future: () async {
        final result = await _restClient.createFamilyCircle(name: name);
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> updateFamilyCircle({
    String? name,
    String? themeColor,
    bool? anyoneCanRequestSnapshot,
    bool? sosToWholeGroup,
    bool? journeysSnapPointsOnly,
  }) {
    return runAsyncCall(
      name: 'updateFamilyCircle',
      future: () async {
        await _restClient.updateFamilyCircle(
          name: name,
          themeColor: themeColor,
          anyoneCanRequestSnapshot: anyoneCanRequestSnapshot,
          sosToWholeGroup: sosToWholeGroup,
          journeysSnapPointsOnly: journeysSnapPointsOnly,
          circleId: _circleId,
        );
        return const Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> deleteFamilyCircle() {
    return runAsyncCall(
      name: 'deleteFamilyCircle',
      future: () async {
        await _restClient.deleteFamilyCircle(circleId: _circleId);
        return const Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> leaveFamilyCircle() {
    return runAsyncCall(
      name: 'leaveFamilyCircle',
      future: () async {
        await _restClient.leaveFamilyCircle(circleId: _circleId);
        return const Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<FamilyTransferCandidates, AppError>>
  getFamilyTransferCandidates() {
    return runAsyncCall(
      name: 'getFamilyTransferCandidates',
      future: () async {
        final candidates = await _restClient.getFamilyTransferCandidates(
          circleId: _circleId,
        );
        return Success(candidates);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<FamilyCircle, AppError>> transferFamilyOwnership({
    required String newOwnerMemberId,
  }) {
    return runAsyncCall(
      name: 'transferFamilyOwnership',
      future: () async {
        final circle = await _restClient.transferFamilyOwnership(
          newOwnerMemberId: newOwnerMemberId,
          circleId: _circleId,
        );
        return Success(circle);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> removeFamilyMember({
    required String memberId,
  }) {
    return runAsyncCall(
      name: 'removeFamilyMember',
      future: () async {
        await _restClient.removeFamilyMember(memberId: memberId);
        return const Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> updateOwnFamilyMember({
    String? nickname,
    FamilySharingLevel? sharingLevel,
    String? colorHex,
  }) {
    return runAsyncCall(
      name: 'updateOwnFamilyMember',
      future: () async {
        await _restClient.updateOwnFamilyMember(
          nickname: nickname,
          sharingLevel: sharingLevel?.name,
          colorHex: colorHex,
          circleId: _circleId,
        );
        return const Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> updateOwnFamilyMemberPhoto({
    required File photo,
  }) {
    return runAsyncCall(
      name: 'updateOwnFamilyMemberPhoto',
      future: () async {
        await _restClient.updateOwnFamilyMemberPhoto(
          photo: photo,
          circleId: _circleId,
        );
        return const Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> updateFamilyCirclePhoto({
    required File photo,
  }) {
    return runAsyncCall(
      name: 'updateFamilyCirclePhoto',
      future: () async {
        await _restClient.updateFamilyCirclePhoto(
          photo: photo,
          circleId: _circleId,
        );
        return const Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> removeFamilyCirclePhoto() {
    return runAsyncCall(
      name: 'removeFamilyCirclePhoto',
      future: () async {
        await _restClient.removeFamilyCirclePhoto(circleId: _circleId);
        return const Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<FamilyInvite, AppError>> createFamilyInvite({
    final bool isGuestInvite = false,
  }) {
    return runAsyncCall(
      name: 'createFamilyInvite',
      future: () async {
        final result = await _restClient.createFamilyInvite(
          circleId: _circleId,
          body: {'isGuestInvite': isGuestInvite},
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<List<FamilyInvite>, AppError>> getFamilyInvites() {
    return runAsyncCall(
      name: 'getFamilyInvites',
      future: () async {
        final result = await _restClient.getFamilyInvites(circleId: _circleId);
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> revokeFamilyInvite({
    required String inviteId,
  }) {
    return runAsyncCall(
      name: 'revokeFamilyInvite',
      future: () async {
        await _restClient.revokeFamilyInvite(inviteId: inviteId);
        return const Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<FamilyCircle, AppError>> joinFamilyCircle({
    required String code,
  }) {
    return runAsyncCall(
      name: 'joinFamilyCircle',
      future: () async {
        final result = await _restClient.joinFamilyCircle(code: code);
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> sendFamilyLocationPing({
    required double latitude,
    required double longitude,
    double? accuracy,
    double? speed,
    int? batteryLevel,
    bool? isMoving,
  }) {
    return runAsyncCall(
      name: 'sendFamilyLocationPing',
      future: () async {
        await _restClient.sendFamilyLocationPing(
          latitude: latitude,
          longitude: longitude,
          accuracy: accuracy,
          speed: speed,
          batteryLevel: batteryLevel,
          isMoving: isMoving,
          circleId: _circleId,
        );
        return const Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<FamilyLocationRequest, AppError>> createFamilyLocationRequest({
    required String memberId,
  }) {
    return runAsyncCall(
      name: 'createFamilyLocationRequest',
      future: () async {
        final request = await _restClient.createFamilyLocationRequest(
          memberId: memberId,
        );
        return Success(request);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<List<String>, AppError>> createFamilyLocationRequestsBulk({
    required List<String> memberIds,
  }) {
    return runAsyncCall(
      name: 'createFamilyLocationRequestsBulk',
      future: () async {
        final result = await _restClient.createFamilyLocationRequestsBulk(
          body: {'memberIds': memberIds},
        );
        final failed = (result['failed'] as List? ?? const [])
            .map((f) => (f as Map)['targetMemberId'] as String)
            .toList();
        return Success(failed);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> cancelFamilyLocationRequest({
    required String requestId,
  }) {
    return runAsyncCall(
      name: 'cancelFamilyLocationRequest',
      future: () async {
        await _restClient.cancelFamilyLocationRequest(requestId: requestId);
        return const Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<List<FamilyLocationRequest>, AppError>>
  getPendingFamilyLocationRequests() {
    return runAsyncCall(
      name: 'getPendingFamilyLocationRequests',
      future: () async {
        final requests = await _restClient.getPendingFamilyLocationRequests();
        return Success(requests);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<FamilyLocationRequest, AppError>>
  respondToFamilyLocationRequest({
    required String requestId,
    required bool share,
    double? latitude,
    double? longitude,
  }) {
    return runAsyncCall(
      name: 'respondToFamilyLocationRequest',
      future: () async {
        final request = await _restClient.respondToFamilyLocationRequest(
          requestId: requestId,
          share: share,
          latitude: latitude,
          longitude: longitude,
        );
        return Success(request);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<FamilyCheckIn, AppError>> sendFamilyCheckIn({
    FamilyCheckInStatus? status,
    String? message,
    double? latitude,
    double? longitude,
    String? requestId,
    String? hazardId,
    String? circleId,
  }) {
    return runAsyncCall(
      name: 'sendFamilyCheckIn',
      future: () async {
        final result = await _restClient.sendFamilyCheckIn(
          status: status?.name,
          message: message,
          latitude: latitude,
          longitude: longitude,
          requestId: requestId,
          hazardId: hazardId,
          circleId: circleId ?? _circleId,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<FamilyCheckInRequest, AppError>> requestFamilyCheckIn({
    String? message,
    String? hazardId,
  }) {
    return runAsyncCall(
      name: 'requestFamilyCheckIn',
      future: () async {
        final result = await _restClient.requestFamilyCheckIn(
          message: message,
          hazardId: hazardId,
          circleId: _circleId,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> cancelFamilyCheckInRequest({
    required String requestId,
  }) {
    return runAsyncCall(
      name: 'cancelFamilyCheckInRequest',
      future: () async {
        await _restClient.cancelFamilyCheckInRequest(requestId: requestId);
        return const Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<List<FamilyCheckIn>, AppError>> getFamilyCheckIns({
    int? limit,
  }) {
    return runAsyncCall(
      name: 'getFamilyCheckIns',
      future: () async {
        final result = await _restClient.getFamilyCheckIns(
          limit: limit,
          circleId: _circleId,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<FamilyScheduledCheckIn, AppError>>
  createFamilyScheduledCheckIn({
    required String timeOfDay,
    FamilyScheduledCheckInMode? mode,
  }) {
    return runAsyncCall(
      name: 'createFamilyScheduledCheckIn',
      future: () async {
        final result = await _restClient.createFamilyScheduledCheckIn(
          timeOfDay: timeOfDay,
          mode: mode?.name,
          circleId: _circleId,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<List<FamilyScheduledCheckIn>, AppError>>
  getFamilyScheduledCheckIns() {
    return runAsyncCall(
      name: 'getFamilyScheduledCheckIns',
      future: () async {
        final result = await _restClient.getFamilyScheduledCheckIns(circleId: _circleId);
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> deleteFamilyScheduledCheckIn({
    required String scheduledCheckInId,
  }) {
    return runAsyncCall(
      name: 'deleteFamilyScheduledCheckIn',
      future: () async {
        await _restClient.deleteFamilyScheduledCheckIn(
          scheduledCheckInId: scheduledCheckInId,
        );
        return const Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<List<FamilySavedPlace>, AppError>> getFamilyPlaces() {
    return runAsyncCall(
      name: 'getFamilyPlaces',
      future: () async {
        final result = await _restClient.getFamilyPlaces(circleId: _circleId);
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<FamilySavedPlace, AppError>> createFamilyPlace({
    required String name,
    required double latitude,
    required double longitude,
    FamilyPlaceIcon? icon,
    int? radiusMeters,
    String? address,
  }) {
    return runAsyncCall(
      name: 'createFamilyPlace',
      future: () async {
        final result = await _restClient.createFamilyPlace(
          name: name,
          icon: icon?.name,
          latitude: latitude,
          longitude: longitude,
          radiusMeters: radiusMeters,
          address: address,
          circleId: _circleId,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<FamilySavedPlace, AppError>> updateFamilyPlace({
    required String placeId,
    String? name,
    FamilyPlaceIcon? icon,
    double? latitude,
    double? longitude,
    int? radiusMeters,
    String? address,
  }) {
    return runAsyncCall(
      name: 'updateFamilyPlace',
      future: () async {
        final result = await _restClient.updateFamilyPlace(
          placeId: placeId,
          name: name,
          icon: icon?.name,
          latitude: latitude,
          longitude: longitude,
          radiusMeters: radiusMeters,
          address: address,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> deleteFamilyPlace({required String placeId}) {
    return runAsyncCall(
      name: 'deleteFamilyPlace',
      future: () async {
        await _restClient.deleteFamilyPlace(placeId: placeId);
        return const Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<FamilyPlaceNotificationPref, AppError>> updateFamilyPlacePref({
    required String placeId,
    required String subjectMemberId,
    required bool notifyArrivals,
    required bool notifyDepartures,
  }) {
    return runAsyncCall(
      name: 'updateFamilyPlacePref',
      future: () async {
        final result = await _restClient.updateFamilyPlacePref(
          placeId: placeId,
          subjectMemberId: subjectMemberId,
          notifyArrivals: notifyArrivals,
          notifyDepartures: notifyDepartures,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<FamilySosEvent, AppError>> triggerFamilySos({
    double? latitude,
    double? longitude,
    String? sosListId,
    required bool isLive,
  }) {
    return runAsyncCall(
      name: 'triggerFamilySos',
      future: () async {
        final result = await _restClient.triggerFamilySos(
          latitude: latitude,
          longitude: longitude,
          sosListId: sosListId,
          isLive: isLive,
          circleId: _circleId,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<List<FamilySosEvent>, AppError>> getActiveFamilySosEvents() {
    return runAsyncCall(
      name: 'getActiveFamilySosEvents',
      future: () async {
        final result = await _restClient.getActiveFamilySosEvents(circleId: _circleId);
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<List<FamilySosEvent>, AppError>> getFamilySosHistory() {
    return runAsyncCall(
      name: 'getFamilySosHistory',
      future: () async {
        final result = await _restClient.getFamilySosHistory(circleId: _circleId);
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<FamilyJourney, AppError>> startFamilyJourney({
    required final int durationMinutes,
    required final List<String> recipientMemberIds,
    final bool isLive = false,
  }) {
    return runAsyncCall(
      name: 'startFamilyJourney',
      future: () async {
        final result = await _restClient.startFamilyJourney(
          circleId: _circleId,
          durationMinutes: durationMinutes,
          recipientMemberIds: recipientMemberIds,
          isLive: isLive,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<FamilyJourney?, AppError>> getMyFamilyJourney() {
    return runAsyncCall(
      name: 'getMyFamilyJourney',
      future: () async {
        final result = await _restClient.getMyFamilyJourney(
          circleId: _circleId,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<List<FamilyJourney>, AppError>>
      getFamilyJourneysSharedWithMe() {
    return runAsyncCall(
      name: 'getFamilyJourneysSharedWithMe',
      future: () async {
        final result = await _restClient.getFamilyJourneysSharedWithMe(
          circleId: _circleId,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<FamilyJourney, AppError>> getFamilyJourney({
    required final String journeyId,
  }) {
    return runAsyncCall(
      name: 'getFamilyJourney',
      future: () async {
        final result = await _restClient.getFamilyJourney(
          journeyId: journeyId,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<FamilyJourney, AppError>> extendFamilyJourney({
    required final String journeyId,
    final int? minutes,
  }) {
    return runAsyncCall(
      name: 'extendFamilyJourney',
      future: () async {
        final result = await _restClient.extendFamilyJourney(
          journeyId: journeyId,
          minutes: minutes,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<FamilyJourney, AppError>> stopFamilyJourney({
    required final String journeyId,
  }) {
    return runAsyncCall(
      name: 'stopFamilyJourney',
      future: () async {
        final result = await _restClient.stopFamilyJourney(
          journeyId: journeyId,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<FamilyJourney, AppError>> postFamilyJourneyPoint({
    required final String journeyId,
    required final double latitude,
    required final double longitude,
    final String? locationLabel,
  }) {
    return runAsyncCall(
      name: 'postFamilyJourneyPoint',
      future: () async {
        final result = await _restClient.postFamilyJourneyPoint(
          journeyId: journeyId,
          latitude: latitude,
          longitude: longitude,
          locationLabel: locationLabel,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<List<FamilySosList>, AppError>> getFamilySosLists() {
    return runAsyncCall(
      name: 'getFamilySosLists',
      future: () async {
        final result = await _restClient.getFamilySosLists();
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<List<FamilySosRecipientGroup>, AppError>>
  getFamilySosRecipients() {
    return runAsyncCall(
      name: 'getFamilySosRecipients',
      future: () async {
        final result = await _restClient.getFamilySosRecipients();
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> takeOverFamilyCircle() {
    return runAsyncCall(
      name: 'takeOverFamilyCircle',
      future: () async {
        await _restClient.takeOverFamilyCircle(circleId: _circleId);
        return const Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<FamilySosList, AppError>> createFamilySosList({
    required String name,
    required List<String> memberIds,
    bool? isDefault,
  }) {
    return runAsyncCall(
      name: 'createFamilySosList',
      future: () async {
        final result = await _restClient.createFamilySosList(
          name: name,
          memberIds: memberIds,
          isDefault: isDefault,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<FamilySosList, AppError>> updateFamilySosList({
    required String sosListId,
    String? name,
    List<String>? memberIds,
    bool? isDefault,
  }) {
    return runAsyncCall(
      name: 'updateFamilySosList',
      future: () async {
        final result = await _restClient.updateFamilySosList(
          sosListId: sosListId,
          name: name,
          memberIds: memberIds,
          isDefault: isDefault,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> deleteFamilySosList({
    required String sosListId,
  }) {
    return runAsyncCall(
      name: 'deleteFamilySosList',
      future: () async {
        await _restClient.deleteFamilySosList(sosListId: sosListId);
        return const Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<FamilySosResponse, AppError>> respondToFamilySos({
    required String sosEventId,
    required FamilySosResponseType type,
  }) {
    return runAsyncCall(
      name: 'respondToFamilySos',
      future: () async {
        final result = await _restClient.respondToFamilySos(
          sosEventId: sosEventId,
          type: type.name,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<FamilySosEvent, AppError>> resolveFamilySos({
    required String sosEventId,
  }) {
    return runAsyncCall(
      name: 'resolveFamilySos',
      future: () async {
        final result = await _restClient.resolveFamilySos(
          sosEventId: sosEventId,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<FamilySosTrail, AppError>> getFamilySosTrail({
    required String sosEventId,
  }) {
    return runAsyncCall(
      name: 'getFamilySosTrail',
      future: () async {
        final result = await _restClient.getFamilySosTrail(
          sosEventId: sosEventId,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }
}
