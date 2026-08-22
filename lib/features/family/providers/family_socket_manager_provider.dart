import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/features/shared/services/socket_service.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';

final providerOfFamilySocketManager = Provider<FamilySocketManager>(
  (ref) => FamilySocketManager(ref: ref),
);

/// The family socket event names emitted by the backend.
///
/// Kept as raw names (instead of extending the shared [SocketEvent] enum)
/// so the family feature stays self-contained.
class FamilySocketEvents {
  static const circleUpdate = 'familyCircleUpdate';
  static const locationUpdate = 'familyLocationUpdate';
  static const checkIn = 'familyCheckIn';
  static const checkInRequest = 'familyCheckInRequest';
  static const locationRequest = 'familyLocationRequest';
  static const placeEvent = 'familyPlaceEvent';
  static const sos = 'familySos';
  static const sosResponse = 'familySosResponse';
  static const sosResolved = 'familySosResolved';
  static const hazardProximity = 'familyHazardProximity';

  static const all = <String>[
    circleUpdate,
    locationUpdate,
    checkIn,
    checkInRequest,
    locationRequest,
    placeEvent,
    sos,
    sosResponse,
    sosResolved,
    hazardProximity,
  ];
}

/// A global manager that listens to all family socket events and broadcasts
/// them to interested parties via separate streams, modeled on
/// `HazardSocketManager`.
class FamilySocketManager {
  FamilySocketManager({required Ref ref}) : _ref = ref {
    _setupSocketListeners();

    _ref.onDispose(dispose);
  }

  final Ref _ref;

  SocketService get _socketService => _ref.read(providerOfSocketService);

  StreamSubscription<bool>? _connectionSubscription;

  final _circleUpdateStreamController = StreamController<void>.broadcast();
  final _locationUpdateStreamController =
      StreamController<FamilyMember>.broadcast();
  final _checkInStreamController = StreamController<FamilyCheckIn>.broadcast();
  final _checkInRequestStreamController =
      StreamController<FamilyCheckInRequest>.broadcast();
  final _locationRequestStreamController =
      StreamController<FamilyLocationRequest>.broadcast();
  final _placeEventStreamController = StreamController<void>.broadcast();
  final _sosStreamController = StreamController<FamilySosEvent>.broadcast();
  final _sosResponseStreamController =
      StreamController<FamilySosResponse>.broadcast();
  final _sosResolvedStreamController =
      StreamController<FamilySosEvent>.broadcast();
  final _hazardProximityStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Fires when the circle itself changed (members joined/left, renamed, ...).
  Stream<void> get circleUpdateStream => _circleUpdateStreamController.stream;

  /// Broadcasts live member location updates.
  Stream<FamilyMember> get locationUpdateStream =>
      _locationUpdateStreamController.stream;

  /// Broadcasts new check-ins.
  Stream<FamilyCheckIn> get checkInStream => _checkInStreamController.stream;

  /// Broadcasts new check-in requests.
  Stream<FamilyCheckInRequest> get checkInRequestStream =>
      _checkInRequestStreamController.stream;

  /// Broadcasts "where are you" asks addressed to THIS user. The server
  /// emits the event to the target only, so anything arriving here is
  /// ours to answer.
  Stream<FamilyLocationRequest> get locationRequestStream =>
      _locationRequestStreamController.stream;

  /// Fires when a place was created/updated/deleted or a member arrived/left.
  Stream<void> get placeEventStream => _placeEventStreamController.stream;

  /// Broadcasts new SOS events.
  Stream<FamilySosEvent> get sosStream => _sosStreamController.stream;

  /// Broadcasts SOS responses.
  Stream<FamilySosResponse> get sosResponseStream =>
      _sosResponseStreamController.stream;

  /// Broadcasts resolved SOS events.
  Stream<FamilySosEvent> get sosResolvedStream =>
      _sosResolvedStreamController.stream;

  /// Broadcasts raw hazard proximity payloads for circle members.
  Stream<Map<String, dynamic>> get hazardProximityStream =>
      _hazardProximityStreamController.stream;

  /// Registers listeners on the raw socket. The family events are not part of
  /// the shared [SocketEvent] enum, so we register on the socket directly and
  /// re-register whenever a (re)connection happens (each connect creates a
  /// fresh socket instance).
  void _setupSocketListeners() {
    _connectionSubscription = _socketService.onSocketConnectionChanged.listen(
      (isConnected) {
        if (isConnected) _registerRawListeners();
      },
    );

    if (_socketService.isSocketConnected) {
      _registerRawListeners();
    }
  }

  void _registerRawListeners() {
    final socket = _socketService.socket;

    // Avoid duplicated handlers when registering more than once on the
    // same socket instance.
    for (final eventName in FamilySocketEvents.all) {
      socket.off(eventName);
    }

    socket.on(
      FamilySocketEvents.circleUpdate,
      (_) => _circleUpdateStreamController.add(null),
    );

    socket.on(
      FamilySocketEvents.locationUpdate,
      (data) => _parseAndAdd(
        eventName: FamilySocketEvents.locationUpdate,
        data: data,
        parse: FamilyMember.fromJson,
        controller: _locationUpdateStreamController,
      ),
    );

    socket.on(
      FamilySocketEvents.checkIn,
      (data) => _parseAndAdd(
        eventName: FamilySocketEvents.checkIn,
        data: data,
        parse: FamilyCheckIn.fromJson,
        controller: _checkInStreamController,
      ),
    );

    socket.on(
      FamilySocketEvents.checkInRequest,
      (data) => _parseAndAdd(
        eventName: FamilySocketEvents.checkInRequest,
        data: data,
        parse: FamilyCheckInRequest.fromJson,
        controller: _checkInRequestStreamController,
      ),
    );

    socket.on(
      FamilySocketEvents.locationRequest,
      (data) => _parseAndAdd(
        eventName: FamilySocketEvents.locationRequest,
        data: data,
        parse: FamilyLocationRequest.fromJson,
        controller: _locationRequestStreamController,
      ),
    );

    socket.on(
      FamilySocketEvents.placeEvent,
      (_) => _placeEventStreamController.add(null),
    );

    socket.on(
      FamilySocketEvents.sos,
      (data) => _parseAndAdd(
        eventName: FamilySocketEvents.sos,
        data: data,
        parse: FamilySosEvent.fromJson,
        controller: _sosStreamController,
      ),
    );

    socket.on(
      FamilySocketEvents.sosResponse,
      (data) => _parseAndAdd(
        eventName: FamilySocketEvents.sosResponse,
        data: data,
        parse: FamilySosResponse.fromJson,
        controller: _sosResponseStreamController,
      ),
    );

    socket.on(
      FamilySocketEvents.sosResolved,
      (data) => _parseAndAdd(
        eventName: FamilySocketEvents.sosResolved,
        data: data,
        parse: FamilySosEvent.fromJson,
        controller: _sosResolvedStreamController,
      ),
    );

    socket.on(
      FamilySocketEvents.hazardProximity,
      (data) {
        if (data is Map) {
          _hazardProximityStreamController.add(
            Map<String, dynamic>.from(data),
          );
        }
      },
    );
  }

  /// Parses [data] with [parse] and adds it to [controller],
  /// swallowing (but logging) malformed payloads.
  void _parseAndAdd<T>({
    required final String eventName,
    required final dynamic data,
    required final T Function(Map<String, dynamic>) parse,
    required final StreamController<T> controller,
  }) {
    if (data is! Map) return;

    runAsyncCall<void>(
      name: 'Listen to $eventName socket event',
      future: () async {
        controller.add(parse(Map<String, dynamic>.from(data)));
      },
      onError: (_) {},
    );
  }

  /// Disposes of all stream controllers when no longer needed.
  void dispose() {
    _connectionSubscription?.cancel();
    _circleUpdateStreamController.close();
    _locationUpdateStreamController.close();
    _checkInStreamController.close();
    _checkInRequestStreamController.close();
    _locationRequestStreamController.close();
    _placeEventStreamController.close();
    _sosStreamController.close();
    _sosResponseStreamController.close();
    _sosResolvedStreamController.close();
    _hazardProximityStreamController.close();
  }
}
