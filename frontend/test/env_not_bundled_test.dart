/// Tests for R-05: .env must NOT be bundled as a Flutter asset.
///
/// Verifies that:
/// 1. pubspec.yaml does not list .env as an asset (plaintext in the APK/IPA).
/// 2. No Dart source imports flutter_dotenv (the package that reads assets).
/// 3. env.dart uses compile-time String.fromEnvironment, not dotenv.env.
/// 4. Every CI workflow passes --dart-define-from-file to flutter build.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final frontendDir =
      Directory.fromUri(Platform.script.resolve('../'));

  group('R-05: .env not bundled as Flutter asset', () {
    test('pubspec.yaml does not list .env as an asset', () {
      final pubspec =
          File('${frontendDir.path}/pubspec.yaml').readAsStringSync();
      // The old line was literally "    - .env" under the assets key.
      // A bare ".env" on an asset line (with leading whitespace + dash)
      // means it ships in the bundle.
      expect(
        pubspec.contains(RegExp(r'^\s+-\s+\.env\s*$', multiLine: true)),
        isFalse,
        reason: '.env must not appear as a Flutter asset -- '
            'it ships plaintext in the APK/IPA',
      );
    });

    test('no Dart source imports flutter_dotenv', () {
      final libDir = Directory('${frontendDir.path}/lib');
      final dartFiles = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      final importPattern =
          RegExp(r'''^\s*import\s+['"]package:flutter_dotenv''', multiLine: true);
      final offenders = <String>[];
      for (final file in dartFiles) {
        final content = file.readAsStringSync();
        if (importPattern.hasMatch(content)) {
          offenders.add(file.path);
        }
      }

      expect(
        offenders,
        isEmpty,
        reason: 'These files still import flutter_dotenv: $offenders\n'
            'Use String.fromEnvironment instead.',
      );
    });

    test('env.dart uses String.fromEnvironment, not dotenv.env', () {
      final envDart =
          File('${frontendDir.path}/lib/others/env.dart').readAsStringSync();

      expect(envDart, contains('String.fromEnvironment'));
      // Verify no executable code uses dotenv.env — comments mentioning the
      // old approach are fine.
      final nonCommentLines = envDart
          .split('\n')
          .where((l) => !l.trimLeft().startsWith('//') &&
                        !l.trimLeft().startsWith('///'));
      for (final line in nonCommentLines) {
        expect(
          line.contains('dotenv.env'),
          isFalse,
          reason: 'Non-comment line still references dotenv.env: $line',
        );
      }
      // Check for the import, not doc-comment mentions of the old approach.
      expect(
        envDart,
        isNot(contains("import 'package:flutter_dotenv")),
        reason: 'env.dart must not import flutter_dotenv',
      );
    });

    test('flutter_dotenv is not a dependency in pubspec.yaml', () {
      final pubspec =
          File('${frontendDir.path}/pubspec.yaml').readAsStringSync();
      expect(
        pubspec,
        isNot(contains('flutter_dotenv')),
        reason: 'flutter_dotenv should be removed from dependencies -- '
            'the app now uses --dart-define-from-file instead',
      );
    });

    test('CI workflows pass --dart-define-from-file to flutter build', () {
      final workflowDir =
          Directory('${frontendDir.path}/.github/workflows');
      if (!workflowDir.existsSync()) {
        // Workflows live in the repo but may not be present locally.
        return;
      }

      final workflows = workflowDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.yml'));

      for (final wf in workflows) {
        final content = wf.readAsStringSync();
        // Only check workflows that actually run flutter build.
        if (!content.contains('flutter build')) continue;

        expect(
          content,
          contains('--dart-define-from-file=.env'),
          reason:
              '${wf.uri.pathSegments.last} runs flutter build but does '
              'not pass --dart-define-from-file=.env',
        );
      }
    });
  });
}
