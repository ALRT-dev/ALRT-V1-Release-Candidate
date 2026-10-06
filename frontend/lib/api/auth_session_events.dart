import 'dart:async';

/// App-wide auth session signals emitted by the network layer.
///
/// The [AuthInterceptor] fires [notifySessionExpired] when the refresh token
/// is rejected — i.e. the session can no longer be recovered silently. The
/// app shell listens to [onSessionExpired] and routes back to the auth
/// screen.
class AuthSessionEvents {
  AuthSessionEvents._();

  static final _sessionExpiredController = StreamController<void>.broadcast();

  static Stream<void> get onSessionExpired => _sessionExpiredController.stream;

  static void notifySessionExpired() {
    if (!_sessionExpiredController.isClosed) {
      _sessionExpiredController.add(null);
    }
  }
}
