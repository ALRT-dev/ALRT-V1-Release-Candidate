import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/shared/services/socket_reconnect_policy.dart';

// The live connection is what keeps the Family screen current without a
// manual refresh. These pin the reconnect rules: backoff that never tight
// loops, and recognising a token refusal so the retry fetches a fresh one.
void main() {
  group('delayForAttempt', () {
    test('doubles from 2 s and caps at 30 s', () {
      expect(SocketReconnectPolicy.delayForAttempt(1), const Duration(seconds: 2));
      expect(SocketReconnectPolicy.delayForAttempt(2), const Duration(seconds: 4));
      expect(SocketReconnectPolicy.delayForAttempt(3), const Duration(seconds: 8));
      expect(SocketReconnectPolicy.delayForAttempt(4), const Duration(seconds: 16));
      expect(SocketReconnectPolicy.delayForAttempt(5), const Duration(seconds: 30));
      expect(SocketReconnectPolicy.delayForAttempt(50), const Duration(seconds: 30));
    });

    test('never returns zero, even for a bad attempt number', () {
      expect(SocketReconnectPolicy.delayForAttempt(0), const Duration(seconds: 2));
      expect(SocketReconnectPolicy.delayForAttempt(-3), const Duration(seconds: 2));
    });
  });

  group('isAuthRefusal', () {
    test('recognises the backend socket-auth messages', () {
      expect(SocketReconnectPolicy.isAuthRefusal('Token missing'), isTrue);
      expect(
        SocketReconnectPolicy.isAuthRefusal({'message': 'Invalid or expired token'}),
        isTrue,
      );
      expect(SocketReconnectPolicy.isAuthRefusal({'message': 'Authentication error'}), isTrue);
      expect(SocketReconnectPolicy.isAuthRefusal('HTTP 401'), isTrue);
    });

    test('treats transport failures as not auth', () {
      expect(SocketReconnectPolicy.isAuthRefusal('websocket error'), isFalse);
      expect(SocketReconnectPolicy.isAuthRefusal({'message': 'timeout'}), isFalse);
      expect(SocketReconnectPolicy.isAuthRefusal(null), isFalse);
    });
  });

  test('a server-side disconnect needs our own reconnect', () {
    expect(SocketReconnectPolicy.needsManualReconnect('io server disconnect'), isTrue);
    expect(SocketReconnectPolicy.needsManualReconnect('transport close'), isFalse);
    expect(SocketReconnectPolicy.needsManualReconnect('io client disconnect'), isFalse);
    expect(SocketReconnectPolicy.needsManualReconnect(null), isFalse);
  });
}
