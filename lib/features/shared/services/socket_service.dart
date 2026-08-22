import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/api/interceptors/auth_interceptor.dart';
import 'package:hazard_app/features/shared/enums/socket_event_types.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/providers/dio_instance_provider.dart';
import 'package:hazard_app/features/shared/providers/repository_providers.dart';
import 'package:hazard_app/features/shared/repositories/shared_prefs_repository.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';
import 'package:hazard_app/features/shared/utils/either.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketService {
  SocketService(final Ref ref) : _ref = ref;

  final Ref _ref;
  SharedPreferencesRepository get _sharedPrefRepository =>
      _ref.read(providerOfSharedPreferencesRepository);
  Dio get _dioInstance => _ref.read(providerOfDioInstance(true));

  late Socket _socket;
  var _isSocketConnected = false;

  final _onSocketConnectionChangedStreamController =
      StreamController<bool>.broadcast();

  Socket get socket => _socket;
  bool get isSocketConnected => _isSocketConnected;

  Stream<bool> get onSocketConnectionChanged =>
      _onSocketConnectionChangedStreamController.stream;

  StreamSubscription<bool>? _onSocketConnectionChangedListener;
  final Map<String, void Function(dynamic)> _pendingEventListeners = {};
  final Map<String, void Function(dynamic)> _activeEventListeners = {};

  /// Connects to the Socket.IO server with authentication.
  Future<Either<void, AppError>> connect() {
    return runAsyncCall(
      name: 'connectSocket',
      future: () async {
        if (_isSocketConnected) {
          await disconnect();
        }

        final completer = Completer();

        final authInterceptor = AuthInterceptor(
          dio: _dioInstance,
          sharedPreferencesRepository: _sharedPrefRepository,
        );
        final token = await authInterceptor.getAccessToken();
        if (token == null) throw AppError(message: 'No auth token found!');

        final socketUrl = _dioInstance.options.baseUrl;

        log('Attempting to connect to socket at: $socketUrl');

        _socket = io(
          socketUrl,
          OptionBuilder()
              .setTransports(['websocket'])
              .setAuth({'token': token})
              .enableForceNew()
              .build(),
        );

        _socket.onConnect((_) {
          log('SOCKET CONNECTED');

          _isSocketConnected = true;
          _onSocketConnectionChangedStreamController.add(true);

          // Register any pending event listeners
          _pendingEventListeners.forEach((eventName, callback) {
            _socket.on(eventName, callback);
            _activeEventListeners[eventName] = callback;
          });
          _pendingEventListeners.clear();

          if (!completer.isCompleted) {
            completer.complete();
          }
        });

        _socket.onDisconnect((_) {
          log('SOCKET DISCONNECTED');

          _isSocketConnected = false;
          _onSocketConnectionChangedStreamController.add(false);

          // Clear active listeners as socket is disconnected
          _activeEventListeners.clear();
        });

        _socket.onError((error) {
          log('SOCKET ERROR: $error');

          _isSocketConnected = false;
          _onSocketConnectionChangedStreamController.add(false);

          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        });

        _socket.onConnectError((error) {
          log('SOCKET CONNECT ERROR: $error');
          log('Verify that Socket.IO server is running on: $socketUrl');

          _isSocketConnected = false;
          _onSocketConnectionChangedStreamController.add(false);

          if (!completer.isCompleted) {
            completer.completeError(
              'Failed to connect to Socket.IO server at $socketUrl. Error: $error',
            );
          }
        });

        _socket.onAnyOutgoing((event, data) {
          log('SOCKET OUTGOING: $event, data: $data');
        });

        _socket.onAny((event, data) {
          log('SOCKET INCOMING: $event, data: $data');
        });

        await completer.future;

        return Success(null);
      },
      onError: Failure.new,
    );
  }

  /// Disconnects from the Socket.IO server if connected.
  Future<Either<void, AppError>> disconnect() {
    return runAsyncCall(
      name: 'disconnectSocket',
      future: () async {
        if (_isSocketConnected) {
          _socket.dispose();
          _activeEventListeners.clear();
          _pendingEventListeners.clear();
          _onSocketConnectionChangedListener?.cancel();
          _onSocketConnectionChangedListener = null;
        }
        return Success(null);
      },
      onError: Failure.new,
    );
  }

  /// Listens to the specified [event] and invokes [onData] when the event is received.
  /// If the same event is registered multiple times, the previous listener will be replaced.
  Future<void> listenToEvent(
    SocketEvent event,
    void Function(dynamic data) onData,
  ) async {
    final eventName = event.name;

    if (_isSocketConnected) {
      // Remove existing listener if any
      if (_activeEventListeners.containsKey(eventName)) {
        _socket.off(eventName);
      }

      // Add new listener
      _socket.on(eventName, onData);
      _activeEventListeners[eventName] = onData;
    } else {
      // Store the listener to be registered when socket connects
      _pendingEventListeners[eventName] = onData;

      // Set up connection listener only if not already listening
      _onSocketConnectionChangedListener ??=
          _onSocketConnectionChangedStreamController.stream.listen(
            (isConnected) {
              if (isConnected && _pendingEventListeners.isNotEmpty) {
                // Listeners will be registered in the onConnect callback
                _onSocketConnectionChangedListener?.cancel();
                _onSocketConnectionChangedListener = null;
              }
            },
          );
    }
  }

  /// Removes the listener for the specified [event].
  void removeEventListener(final SocketEvent event) {
    final eventName = event.name;

    if (_isSocketConnected && _activeEventListeners.containsKey(eventName)) {
      _socket.off(eventName);
      _activeEventListeners.remove(eventName);
    }

    // Also remove from pending listeners
    _pendingEventListeners.remove(eventName);
  }

  /// Removes all event listeners.
  void removeAllEventListeners() {
    if (_isSocketConnected) {
      for (final eventName in _activeEventListeners.keys) {
        _socket.off(eventName);
      }
    }

    _activeEventListeners.clear();
    _pendingEventListeners.clear();
    _onSocketConnectionChangedListener?.cancel();
    _onSocketConnectionChangedListener = null;
  }

  /// Disposes of all resources and closes the socket connection.
  /// Call this when the SocketService is no longer needed.
  Future<void> dispose() async {
    await disconnect();
    await _onSocketConnectionChangedStreamController.close();
  }
}
