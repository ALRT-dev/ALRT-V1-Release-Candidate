import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final workflow in ['android-release.yml', 'ios-testflight.yml']) {
    test('$workflow passes its environment file into the compiled app', () {
      // GitHub executes the repository-root workflows, not the historical
      // copies under frontend/.github. Env uses String.fromEnvironment.
      final path = '${Directory.current.parent.path}/.github/workflows/$workflow';
      final source = File(path).readAsStringSync();
      final buildCommands = source
          .replaceAll(RegExp(r'\\\r?\n\s*'), ' ')
          .split('\n')
          .where((line) => line.trimLeft().startsWith('flutter build '));
      expect(buildCommands, isNotEmpty);
      for (final command in buildCommands) {
        expect(command, contains('--dart-define-from-file=.env'),
            reason: 'Writing .env alone leaves sign-in and billing keys empty.');
      }
    });
  }
}
