import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/shared/enums/socket_event_types.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/features/shared/services/hazard_service.dart';
import 'package:hazard_app/features/shared/services/socket_service.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';

final providerOfHazardSocketManager = Provider<HazardSocketManager>(
  (ref) => HazardSocketManager(ref: ref),
);

/// A global notifier that listens to all hazard socket events and broadcasts them
/// to any interested parties via separate streams. This solves the issue where multiple
/// providers were conflicting with each other's socket listeners.
class HazardSocketManager {
  HazardSocketManager({required Ref ref}) : _ref = ref {
    _setupSocketListeners();
  }

  final Ref _ref;

  final StreamController<Hazard> _updateHazardStreamController =
      StreamController<Hazard>.broadcast();
  final StreamController<Hazard> _newHazardStreamController =
      StreamController<Hazard>.broadcast();
  final StreamController<String> _deleteHazardStreamController =
      StreamController<String>.broadcast();

  SocketService get _socketService => _ref.read(providerOfSocketService);
  HazardService get _hazardService => _ref.read(providerOfHazardService);

  /// Stream that broadcasts hazard updates to all listeners
  Stream<Hazard> get updateHazardStream => _updateHazardStreamController.stream;

  /// Stream that broadcasts new hazards to all listeners
  Stream<Hazard> get newHazardStream => _newHazardStreamController.stream;

  /// Stream that broadcasts hazard deletions (hazard IDs) to all listeners
  Stream<String> get deleteHazardStream => _deleteHazardStreamController.stream;

  /// Sets up socket listeners for all hazard events.
  /// This is the single point where we listen to all hazard socket events.
  void _setupSocketListeners() {
    _socketService.listenToEvent(
      SocketEvent.newHazard,
      (data) async {
        if (data is Map<String, dynamic>) {
          return runAsyncCall(
            name: 'Listen to newHazard socket event',
            future: () async {
              final newHazard = Hazard.fromJson(data);
              final result = await _hazardService
                  .populateHazardWithRequiredData(newHazard);
              _newHazardStreamController.add(result);
            },
            onError: (_) {},
          );
        }
      },
    );

    _socketService.listenToEvent(
      SocketEvent.updateHazard,
      (data) async {
        if (data is Map<String, dynamic>) {
          return runAsyncCall(
            name: 'Listen to updateHazard socket event',
            future: () async {
              final updatedHazard = Hazard.fromJson(data);
              final result = await _hazardService
                  .populateHazardWithRequiredData(updatedHazard);
              _updateHazardStreamController.add(result);
            },
            onError: (_) {},
          );
        }
      },
    );

    _socketService.listenToEvent(
      SocketEvent.deleteHazard,
      (data) async {
        if (data is Map<String, dynamic>) {
          return runAsyncCall(
            name: 'Listen to deleteHazard socket event',
            future: () async {
              final hazardId = data['id'] as String?;
              if (hazardId != null) {
                _deleteHazardStreamController.add(hazardId);
              }
            },
            onError: (_) {},
          );
        }
      },
    );
  }

  /// Disposes of all stream controllers when no longer needed
  void dispose() {
    _updateHazardStreamController.close();
    _newHazardStreamController.close();
    _deleteHazardStreamController.close();
  }
}
