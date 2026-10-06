import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/family/utils/invite_code.dart';

// The QR scanner and manual entry both feed parseInviteCode before the
// unchanged join call. These pin what counts as an invite code (the
// backend's ALRT-XXXXX shape over its 0/O/1/I/L-free alphabet) and what
// must be rejected instead of being sent to the server.
void main() {
  group('parseInviteCode accepts', () {
    test('a canonical code unchanged', () {
      expect(parseInviteCode('ALRT-7F3K2'), 'ALRT-7F3K2');
    });

    test('lower case and surrounding whitespace', () {
      expect(parseInviteCode('  alrt-7f3k2 \n'), 'ALRT-7F3K2');
    });

    test('a code typed without the prefix', () {
      expect(parseInviteCode('7F3K2'), 'ALRT-7F3K2');
      expect(parseInviteCode('7f3k2'), 'ALRT-7F3K2');
    });

    test('a code read out with a space or an extra dash', () {
      expect(parseInviteCode('ALRT 7F3K2'), 'ALRT-7F3K2');
      expect(parseInviteCode('ALRT-7F3-K2'), 'ALRT-7F3K2');
      expect(parseInviteCode('ALRT7F3K2'), 'ALRT-7F3K2');
    });
  });

  group('parseInviteCode rejects', () {
    test('empty input', () {
      expect(parseInviteCode(''), isNull);
      expect(parseInviteCode('   '), isNull);
    });

    test('the wrong length', () {
      expect(parseInviteCode('ALRT-7F3K'), isNull);
      expect(parseInviteCode('ALRT-7F3K22'), isNull);
    });

    test('characters outside the alphabet (0, O, 1, I, L)', () {
      expect(parseInviteCode('ALRT-0F3K2'), isNull);
      expect(parseInviteCode('ALRT-OF3K2'), isNull);
      expect(parseInviteCode('ALRT-1F3K2'), isNull);
      expect(parseInviteCode('ALRT-IF3K2'), isNull);
      expect(parseInviteCode('ALRT-LF3K2'), isNull);
    });

    test('URLs and other apps\' QR payloads', () {
      expect(parseInviteCode('https://www.safetyalrt.com/get'), isNull);
      expect(parseInviteCode('WIFI:S:home;T:WPA;P:secret;;'), isNull);
      expect(parseInviteCode('alrt://join?code=7F3K2'), isNull);
    });
  });

  test('the alphabet has no 0, O, 1, I or L', () {
    for (final c in ['0', 'O', '1', 'I', 'L']) {
      expect(inviteCodeAlphabet.contains(c), isFalse, reason: c);
    }
    expect(inviteCodeAlphabet.length, 31);
  });
}
