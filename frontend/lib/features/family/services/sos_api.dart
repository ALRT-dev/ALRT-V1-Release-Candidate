import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/api/endpoints.dart';
import 'package:hazard_app/features/family/providers/selected_circle_provider.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/providers/dio_instance_provider.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

/// Who an SOS would reach right now, as the backend decides it
/// (GET /api/family/sos/preview). The send repeats the same check, so this
/// is a preview, never a promise; and eligibility is never a promise of
/// delivery.
enum SosPreviewState {
  ok,
  noPeople,
  noneEligible,
  presetInvalid,
  senderNoAccess,
}

class SosPreviewPerson {
  const SosPreviewPerson({
    required this.memberId,
    required this.name,
    this.deliveryLimited = false,
    this.reason,
  });

  final String memberId;
  final String name;

  /// No phone registered for notifications: they see it in the app, but a
  /// notification may not arrive.
  final bool deliveryLimited;

  /// Why left out: needs_individual | sponsorship_paused.
  final String? reason;
}

class SosPresetStatus {
  const SosPresetStatus({
    required this.id,
    required this.name,
    required this.state,
    required this.removedCount,
    required this.otherGroupCount,
  });

  final String id;
  final String name;

  /// ok | outdated | otherGroup | empty
  final String state;
  final int removedCount;
  final int otherGroupCount;

  bool get needsRepair => state == 'otherGroup' || state == 'empty';
}

class SosPreview {
  const SosPreview({
    required this.state,
    required this.recipients,
    required this.excluded,
    this.preset,
  });

  factory SosPreview.fromJson(final Map<String, dynamic> json) {
    SosPreviewPerson person(final Map m) => SosPreviewPerson(
      memberId: m['memberId']?.toString() ?? '',
      name: m['name']?.toString() ?? 'Family member',
      deliveryLimited: m['deliveryLimited'] == true,
      reason: m['reason']?.toString(),
    );
    final preset = json['preset'];
    return SosPreview(
      state: switch (json['state']) {
        'noPeople' => SosPreviewState.noPeople,
        'noneEligible' => SosPreviewState.noneEligible,
        'presetInvalid' => SosPreviewState.presetInvalid,
        'senderNoAccess' => SosPreviewState.senderNoAccess,
        _ => SosPreviewState.ok,
      },
      recipients: [
        for (final r in (json['recipients'] as List? ?? const []))
          if (r is Map) person(r),
      ],
      excluded: [
        for (final r in (json['excluded'] as List? ?? const []))
          if (r is Map) person(r),
      ],
      preset: preset is Map
          ? SosPresetStatus(
              id: preset['id']?.toString() ?? '',
              name: preset['name']?.toString() ?? '',
              state: preset['state']?.toString() ?? 'ok',
              removedCount: preset['removedCount'] is int
                  ? preset['removedCount'] as int
                  : 0,
              otherGroupCount: preset['otherGroupCount'] is int
                  ? preset['otherGroupCount'] as int
                  : 0,
            )
          : null,
    );
  }

  final SosPreviewState state;
  final List<SosPreviewPerson> recipients;
  final List<SosPreviewPerson> excluded;
  final SosPresetStatus? preset;

  /// Can the hold button send? Only when someone eligible is there.
  bool get canSend => state == SosPreviewState.ok && recipients.isNotEmpty;
}

final providerOfSosApi = Provider<SosApi>(
  (ref) => SosApi(
    dio: ref.watch(providerOfDioInstance(false)),
    circleId: () => ref.read(providerOfSelectedCircleId),
  ),
);

class SosApi {
  SosApi({required final Dio dio, required this.circleId}) : _dio = dio;

  final Dio _dio;
  final String? Function() circleId;

  Map<String, dynamic> _circle() {
    final id = circleId();
    return id == null ? const {} : {'circleId': id};
  }

  Future<Either<SosPreview, AppError>> preview({final String? sosListId}) =>
      runAsyncCall(
        name: 'previewSos',
        future: () async {
          final response = await _dio.get<Map<String, dynamic>>(
            kUrlFamilySosPreview,
            queryParameters: {..._circle(), 'sosListId': ?sosListId},
          );
          return Success(SosPreview.fromJson(response.data ?? const {}));
        },
        onError: Failure.new,
      );

  /// The sender changes what their running SOS shares: stop sharing
  /// ([mode] "none") or suburb only ([precision] "approximate"), or turn
  /// it back on. The backend clears stored coordinates and tells the
  /// SOS's recipients; a later location update can never undo it.
  Future<Either<Map<String, dynamic>, AppError>> setLocationConsent({
    required final String sosEventId,
    final String? mode,
    final String? precision,
  }) => runAsyncCall(
    name: 'setSosLocationConsent',
    future: () async {
      final response = await _dio.put<Map<String, dynamic>>(
        kUrlFamilySosLocationConsent(sosEventId),
        data: {'locationMode': ?mode, 'locationPrecision': ?precision},
      );
      return Success(response.data ?? const <String, dynamic>{});
    },
    onError: Failure.new,
  );

  /// The sender keeps their running SOS going for another hour from now
  /// (POST /api/family/sos/:id/extend). Answers the new end time from the
  /// stored row; the backend refuses an SOS that has already ended (409)
  /// or isn't the caller's own (404).
  Future<Either<DateTime?, AppError>> extend({
    required final String sosEventId,
  }) => runAsyncCall(
    name: 'extendSos',
    future: () async {
      final response = await _dio.post<dynamic>(
        kUrlFamilySosExtend(sosEventId),
      );
      final data = response.data;
      final raw = data is Map ? data['liveUntil'] : null;
      return Success(raw is String ? DateTime.tryParse(raw) : null);
    },
    onError: Failure.new,
  );

  /// One live point for the sender's own live SOS (its audience only).
  Future<Either<void, AppError>> sendLivePoint({
    required final String sosEventId,
    required final double latitude,
    required final double longitude,
    required final DateTime capturedAt,
    final double? accuracy,
  }) => runAsyncCall(
    name: 'sendSosLivePoint',
    future: () async {
      await _dio.post<dynamic>(
        kUrlFamilySosLocation(sosEventId),
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'capturedAt': capturedAt.toUtc().toIso8601String(),
          'accuracy': ?accuracy,
        },
      );
      return const Success(null);
    },
    onError: Failure.new,
  );
}
