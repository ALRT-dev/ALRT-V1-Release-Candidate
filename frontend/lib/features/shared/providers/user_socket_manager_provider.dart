import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/shared/enums/socket_event_types.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/features/shared/services/socket_service.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';

final providerOfUserSocketManager = Provider<UserSocketManager>(
  (ref) => UserSocketManager(ref: ref),
);

/// A global notifier that listens to all user socket events and broadcasts them
/// to any interested parties via separate streams. This solves the issue where multiple
/// providers were conflicting with each other's socket listeners.
class UserSocketManager {
  UserSocketManager({required Ref ref}) : _ref = ref {
    _setupSocketListeners();
  }

  final Ref _ref;

  final StreamController<int> _userXpUpdateStreamController =
      StreamController<int>.broadcast();
  final StreamController<double> _userReliabilityUpdateStreamController =
      StreamController<double>.broadcast();
  final StreamController<int> _userUpvotesReceivedCountUpdateStreamController =
      StreamController<int>.broadcast();

  /// Badge name and description, as the banner needs them.
  final StreamController<({String name, String description})>
  _badgeEarnedStreamController =
      StreamController<({String name, String description})>.broadcast();

  SocketService get _socketService => _ref.read(providerOfSocketService);

  /// Stream that broadcasts user XP updates to all listeners
  Stream<int> get userXpUpdateStream => _userXpUpdateStreamController.stream;

  /// Stream that broadcasts user reliability updates to all listeners
  Stream<double> get userReliabilityUpdateStream =>
      _userReliabilityUpdateStreamController.stream;

  /// Stream that broadcasts user upvotes received count updates to all listeners
  Stream<int> get userUpvotesReceivedCountUpdateStream =>
      _userUpvotesReceivedCountUpdateStreamController.stream;

  /// Fires when the backend awards a badge, so it can be celebrated where
  /// the person is rather than only appearing on the profile later.
  Stream<({String name, String description})> get badgeEarnedStream =>
      _badgeEarnedStreamController.stream;

  /// Sets up socket listeners for all user events.
  /// This is the single point where we listen to all user socket events.
  void _setupSocketListeners() {
    _socketService.listenToEvent(
      SocketEvent.updateUserXp,
      (data) async {
        if (data is Map<String, dynamic>) {
          return runAsyncCall(
            name: 'Listen to updateUserXp socket event',
            future: () async {
              final xpPoints = data['xpPoints'] as int?;
              final reliabilityScore = (data['reliabilityScore'] as num?)
                  ?.toDouble();

              if (xpPoints != null) {
                _userXpUpdateStreamController.add(xpPoints);
              }
              if (reliabilityScore != null) {
                _userReliabilityUpdateStreamController.add(reliabilityScore);
              }
            },
            onError: (_) {},
          );
        }
      },
    );

    _socketService.listenToEvent(
      SocketEvent.badgeEarned,
      (data) async {
        if (data is Map<String, dynamic>) {
          return runAsyncCall(
            name: 'Listen to badgeEarned socket event',
            future: () async {
              final name = data['name'] as String?;
              if (name == null) return;
              _badgeEarnedStreamController.add((
                name: name,
                description: data['description'] as String? ?? '',
              ));
            },
            onError: (_) {},
          );
        }
      },
    );

    _socketService.listenToEvent(
      SocketEvent.updateUserUpvotesReceivedCount,
      (data) async {
        if (data is Map<String, dynamic>) {
          return runAsyncCall(
            name: 'Listen to updateUserUpvotesReceivedCount socket event',
            future: () async {
              final upvotesReceivedCount = data['upvotesReceivedCount'] as int?;

              if (upvotesReceivedCount != null) {
                _userUpvotesReceivedCountUpdateStreamController.add(
                  upvotesReceivedCount,
                );
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
    _userXpUpdateStreamController.close();
    _userUpvotesReceivedCountUpdateStreamController.close();
    _badgeEarnedStreamController.close();
  }
}
