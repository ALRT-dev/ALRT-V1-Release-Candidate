import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/api/auth_session_events.dart';
import 'package:hazard_app/api/interceptors/auth_interceptor.dart';
import 'package:hazard_app/features/shared/enums/socket_event_types.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/providers/dio_instance_provider.dart';
import 'package:hazard_app/features/shared/providers/repository_providers.dart';
import 'package:hazard_app/features/shared/repositories/shared_prefs_repository.dart';
import 'package:hazard_app/features/shared/services/socket_reconnect_policy.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';
import 'package:hazard_app/features/shared/utils/either.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketService {
  SocketService(final Ref ref) : _ref = ref;

  final Ref _ref;
  SharedPreferencesRepository get _sharedPrefRepository =>
      _ref.read(providerOfSharedPreferencesRepository);
  Dio get _dioInstance => _ref.read(providerOfDioInstance(true));

  Socket? _socket;
  var _isSocketConnected = false;
  var _disposed = false;

  /// Our own reconnect loop. The client library retries a dropped
  /// transport by itself, but NOT a connection the server refused (an
  /// expired token) or ended: on those it tears the socket down and stops,
  /// which is exactly how the Family screen used to go quiet until the app
  /// was killed. Every attempt here fetches a fresh access token first.
  Timer? _reconnectTimer;
  var _reconnectAttempt = 0;
  StreamSubscription<void>? _sessionExpiredSubscription;

  final _onSocketConnectionChangedStreamController =
      StreamController<bool>.broadcast();

  /// The live socket. Only valid after [connect] has been called; callers
  /// go through [listenToEvent] or check [isSocketConnected] first.
  Socket get socket => _socket!;
  bool get isSocketConnected => _isSocketConnected;

  Stream<bool> get onSocketConnectionChanged =>
      _onSocketConnectionChangedStreamController.stream;

  StreamSubscription<bool>? _onSocketConnectionChangedListener;
  final Map<String, void Function(dynamic)> _pendingEventListeners = {};
  final Map<String, void Function(dynamic)> _activeEventListeners = {};

  void _setConnected(final bool connected) {
    _isSocketConnected = connected;
    if (!_onSocketConnectionChangedStreamController.isClosed) {
      _onSocketConnectionChangedStreamController.add(connected);
    }
  }

  /// A fresh access token for the handshake, refreshed through the same
  /// path the HTTP layer uses when it is expired. Null when the session is
  /// gone (no refresh token, or the refresh was rejected).
  Future<String?> _freshAccessToken() {
    final authInterceptor = AuthInterceptor(
      dio: _dioInstance,
      sharedPreferencesRepository: _sharedPrefRepository,
    );
    return authInterceptor.getAccessToken();
  }

  /// Connects to the Socket.IO server with authentication.
  ///
  /// Resolves once the first connection is up, or fails with the first
  /// error; either way the socket keeps reconnecting on its own after
  /// that, so a caller only needs to call this once per session.
  Future<Either<void, AppError>> connect() {
    return runAsyncCall(
      name: 'connectSocket',
      future: () async {
        if (_isSocketConnected) {
          await disconnect();
        }
        _disposed = false;
        _cancelReconnect();

        final completer = Completer<void>();

        final token = await _freshAccessToken();
        if (token == null) throw AppError(message: 'No auth token found!');

        final socketUrl = _dioInstance.options.baseUrl;

        log('Attempting to connect to socket at: $socketUrl');

        final socket = io(
          socketUrl,
          OptionBuilder()
              // WebSocket first; long-polling only if the upgrade is
              // blocked somewhere between the phone and the server.
              // Never "no live updates at all" because of a proxy.
              .setTransports(['websocket', 'polling'])
              // Called by the library on EVERY connect attempt, so a
              // reconnect after the token expired sends a fresh one
              // instead of the one captured at app start.
              .setAuthFn((callback) {
                _freshAccessToken().then(
                  (fresh) => callback({'token': fresh ?? token}),
                  onError: (_) => callback({'token': token}),
                );
              })
              .enableForceNew()
              .build(),
        );
        _socket = socket;

        socket.onConnect((_) {
          log('SOCKET CONNECTED');
          _reconnectAttempt = 0;
          _cancelReconnect();
          _setConnected(true);

          // Register any pending event listeners
          _pendingEventListeners.forEach((eventName, callback) {
            socket.on(eventName, callback);
            _activeEventListeners[eventName] = callback;
          });
          _pendingEventListeners.clear();

          if (!completer.isCompleted) {
            completer.complete();
          }
        });

        socket.onDisconnect((reason) {
          log('SOCKET DISCONNECTED: $reason');
          _setConnected(false);
          // Clear active listeners as socket is disconnected
          _activeEventListeners.clear();
          if (SocketReconnectPolicy.needsManualReconnect(
            reason?.toString(),
          )) {
            _scheduleReconnect();
          }
        });

        // The server refusing the handshake (expired token) arrives here
        // as `error`, and the library destroys the socket: without this
        // the app would stay offline until restarted.
        socket.onError((error) {
          log('SOCKET ERROR: $error');
          _setConnected(false);
          if (SocketReconnectPolicy.isAuthRefusal(error)) {
            log('SOCKET AUTH REFUSED - reconnecting with a fresh token');
          }
          _scheduleReconnect();
          if (!completer.isCompleted) {
            completer.completeError(error ?? 'socket error');
          }
        });

        // A transport-level failure: the library keeps retrying this one
        // itself (with a fresh token each time, via the auth callback), so
        // no reconnect of our own here - two loops would open two engines.
        socket.onConnectError((error) {
          log('SOCKET CONNECT ERROR: $error');
          log('Verify that Socket.IO server is running on: $socketUrl');
          _setConnected(false);
          if (!completer.isCompleted) {
            completer.completeError(
              'Failed to connect to Socket.IO server at $socketUrl. Error: $error',
            );
          }
        });

        socket.onAnyOutgoing((event, data) {
          log('SOCKET OUTGOING: $event, data: $data');
        });

        socket.onAny((event, data) {
          log('SOCKET INCOMING: $event, data: $data');
        });

        // A session that can no longer be refreshed must not keep
        // hammering the server with a dead token.
        _sessionExpiredSubscription ??= AuthSessionEvents.onSessionExpired
            .listen((_) => disconnect());

        await completer.future;

        return Success(null);
      },
      onError: Failure.new,
    );
  }

  /// Reconnects now if the socket is down: called when the app returns to
  /// the foreground, where a connection killed in the background is the
  /// common case. A no-op while connected, or before [connect] was ever
  /// called. Resets the backoff so the retry is immediate.
  void ensureConnected() {
    if (_disposed || _socket == null || _isSocketConnected) return;
    _reconnectAttempt = 0;
    _cancelReconnect();
    _reconnectNow();
  }

  void _scheduleReconnect() {
    if (_disposed || _socket == null) return;
    if (_reconnectTimer?.isActive ?? false) return;
    _reconnectAttempt += 1;
    final delay = SocketReconnectPolicy.delayForAttempt(_reconnectAttempt);
    log('SOCKET reconnect attempt $_reconnectAttempt in ${delay.inSeconds}s');
    _reconnectTimer = Timer(delay, _reconnectNow);
  }

  Future<void> _reconnectNow() async {
    _reconnectTimer = null;
    final socket = _socket;
    if (_disposed || socket == null || _isSocketConnected) return;
    // No session left to reconnect with: stop, the app is routing to
    // sign-in. Trying again would only be refused.
    if (await _freshAccessToken() == null) {
      log('SOCKET reconnect skipped: no session');
      return;
    }
    if (_disposed || _isSocketConnected) return;
    // The library is mid-retry itself (a transport drop): leave it to it.
    if (socket.io.reconnecting || socket.io.readyState == 'opening') {
      log('SOCKET reconnect skipped: library already reconnecting');
      return;
    }
    try {
      // The library's `connect()` re-opens the manager it tore down on a
      // refused handshake; the auth callback above supplies the token.
      socket.connect();
    } catch (error) {
      log('SOCKET reconnect failed to start: $error');
      _scheduleReconnect();
    }
  }

  void _cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// Disconnects from the Socket.IO server if connected, and stops any
  /// pending reconnect.
  Future<Either<void, AppError>> disconnect() {
    return runAsyncCall(
      name: 'disconnectSocket',
      future: () async {
        _cancelReconnect();
        final socket = _socket;
        if (socket != null) {
          socket.dispose();
          _socket = null;
          _activeEventListeners.clear();
          _pendingEventListeners.clear();
          _onSocketConnectionChangedListener?.cancel();
          _onSocketConnectionChangedListener = null;
          if (_isSocketConnected) _setConnected(false);
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

    final socket = _socket;
    if (_isSocketConnected && socket != null) {
      // Remove existing listener if any
      if (_activeEventListeners.containsKey(eventName)) {
        socket.off(eventName);
      }

      // Add new listener
      socket.on(eventName, onData);
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
      _socket?.off(eventName);
      _activeEventListeners.remove(eventName);
    }

    // Also remove from pending listeners
    _pendingEventListeners.remove(eventName);
  }

  /// Removes all event listeners.
  void removeAllEventListeners() {
    if (_isSocketConnected) {
      for (final eventName in _activeEventListeners.keys) {
        _socket?.off(eventName);
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
    _disposed = true;
    await disconnect();
    await _sessionExpiredSubscription?.cancel();
    _sessionExpiredSubscription = null;
  }
}
