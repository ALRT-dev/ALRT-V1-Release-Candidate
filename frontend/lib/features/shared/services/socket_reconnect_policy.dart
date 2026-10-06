/// The rules the live (Socket.IO) connection follows when it drops, kept
/// free of any socket type so they can be unit-tested on their own.
///
/// Why this exists: the socket used to log in ONCE with the access token
/// of that moment. When the token expired and the connection dropped (the
/// app backgrounded, a network switch, the proxy closing an idle
/// connection) the server refused the reconnect and the client gave up
/// for good, so the Family screen silently stopped updating until the app
/// was killed. Every reconnect now fetches a fresh token, and a refusal
/// is retried with backoff instead of ending the connection.
class SocketReconnectPolicy {
  const SocketReconnectPolicy._();

  static const Duration firstDelay = Duration(seconds: 2);
  static const Duration maxDelay = Duration(seconds: 30);

  /// Wait before reconnect attempt number [attempt] (1-based): 2 s, 4 s,
  /// 8 s, 16 s, then capped at [maxDelay]. Never a tight loop.
  static Duration delayForAttempt(final int attempt) {
    final n = attempt < 1 ? 1 : attempt;
    var delay = firstDelay;
    for (var i = 1; i < n; i++) {
      delay *= 2;
      if (delay >= maxDelay) return maxDelay;
    }
    return delay > maxDelay ? maxDelay : delay;
  }

  /// Whether a socket error payload is the server refusing our token
  /// (the auth middleware answers 401 with one of these messages), as
  /// opposed to a transport problem. Both are retried, but a refusal is
  /// what makes fetching a fresh token before the retry matter.
  static bool isAuthRefusal(final Object? error) {
    final message = _messageOf(error).toLowerCase();
    if (message.isEmpty) return false;
    return message.contains('401') ||
        message.contains('token') ||
        message.contains('unauthori') ||
        message.contains('authentication');
  }

  /// Reasons for which the client library will NOT reconnect on its own,
  /// so we must. A plain transport drop is retried by the library itself.
  static bool needsManualReconnect(final String? disconnectReason) {
    return disconnectReason == 'io server disconnect';
  }

  static String _messageOf(final Object? error) {
    if (error == null) return '';
    if (error is String) return error;
    if (error is Map) {
      final message = error['message'];
      if (message != null) return message.toString();
      return error.toString();
    }
    return error.toString();
  }
}
