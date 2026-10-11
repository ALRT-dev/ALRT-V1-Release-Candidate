// R-06 regression tests: auth tokens use encrypted storage
//
// These tests verify the structural requirements of the encrypted-token-
// storage migration. Because the cloud CI has no Flutter runtime, each
// test is a static-analysis check over the source tree that will also
// pass under `dart test` or `flutter test` on a developer machine.

import 'dart:io';
import 'package:test/test.dart';

void main() {
  group('R-06 – encrypted token storage', () {
    // ------------------------------------------------------------------ //
    // 1. SecureTokenStorage exists and wraps FlutterSecureStorage
    // ------------------------------------------------------------------ //
    test('SecureTokenStorage class exists and uses FlutterSecureStorage', () {
      final file = File(
        'lib/features/shared/repositories/secure_token_storage.dart',
      );
      expect(file.existsSync(), isTrue, reason: 'SecureTokenStorage file must exist');
      final content = file.readAsStringSync();
      expect(
        content.contains('FlutterSecureStorage'),
        isTrue,
        reason: 'SecureTokenStorage must delegate to FlutterSecureStorage',
      );
      expect(
        content.contains('encryptedSharedPreferences: true'),
        isTrue,
        reason:
            'Android must use EncryptedSharedPreferences for Keystore-backed storage',
      );
    });

    // ------------------------------------------------------------------ //
    // 2. SecureTokenStorage manages exactly the three token keys
    // ------------------------------------------------------------------ //
    test('SecureTokenStorage manages accessToken, refreshToken, authMethod', () {
      final content = File(
        'lib/features/shared/repositories/secure_token_storage.dart',
      ).readAsStringSync();
      for (final key in ['accessToken', 'refreshToken', 'authMethod']) {
        expect(
          content.contains('SharedPrefsKey.$key'),
          isTrue,
          reason: 'SecureTokenStorage must manage SharedPrefsKey.$key',
        );
      }
    });

    // ------------------------------------------------------------------ //
    // 3. Migration from plaintext SharedPreferences is wired up at startup
    // ------------------------------------------------------------------ //
    test('App initialization triggers token migration', () {
      final content = File(
        'lib/features/shared/providers/app_initialization_provider.dart',
      ).readAsStringSync();
      expect(
        content.contains('migrateFromSharedPrefs'),
        isTrue,
        reason:
            'app_initialization_provider must call migrateFromSharedPrefs to '
            'move plaintext tokens into encrypted storage on first launch',
      );
      expect(
        content.contains('_migrateTokensToSecureStorage'),
        isTrue,
        reason: 'Migration helper must be defined and called',
      );
    });

    // ------------------------------------------------------------------ //
    // 4. AuthInterceptor no longer takes SharedPreferencesRepository
    // ------------------------------------------------------------------ //
    test('AuthInterceptor uses SecureTokenStorage, not SharedPreferencesRepository',
        () {
      final content = File(
        'lib/api/interceptors/auth_interceptor.dart',
      ).readAsStringSync();
      expect(
        content.contains('SecureTokenStorage'),
        isTrue,
        reason: 'AuthInterceptor must depend on SecureTokenStorage',
      );
      expect(
        content.contains('SharedPreferencesRepository'),
        isFalse,
        reason:
            'AuthInterceptor must NOT depend on SharedPreferencesRepository '
            'for token operations',
      );
    });

    // ------------------------------------------------------------------ //
    // 5. AuthService uses SecureTokenStorage for saving/deleting tokens
    // ------------------------------------------------------------------ //
    test('AuthService uses SecureTokenStorage', () {
      final content = File(
        'lib/features/auth/services/auth_service.dart',
      ).readAsStringSync();
      expect(
        content.contains('SecureTokenStorage'),
        isTrue,
        reason: 'AuthService must use SecureTokenStorage',
      );
      expect(
        content.contains('_secureTokenStorage.write'),
        isTrue,
        reason: 'Token saves must go through SecureTokenStorage.write',
      );
      expect(
        content.contains('_secureTokenStorage.delete'),
        isTrue,
        reason: 'Token deletes must go through SecureTokenStorage.delete',
      );
    });

    // ------------------------------------------------------------------ //
    // 6. Dio instance wiring passes SecureTokenStorage
    // ------------------------------------------------------------------ //
    test('dioInstance accepts SecureTokenStorage parameter', () {
      final content = File('lib/api/dio_instance.dart').readAsStringSync();
      expect(
        content.contains('SecureTokenStorage secureTokenStorage'),
        isTrue,
        reason: 'dioInstance must accept SecureTokenStorage',
      );
      expect(
        content.contains('SharedPreferencesRepository'),
        isFalse,
        reason:
            'dioInstance must NOT reference SharedPreferencesRepository',
      );
    });

    test('dio_instance_provider passes SecureTokenStorage', () {
      final content = File(
        'lib/features/shared/providers/dio_instance_provider.dart',
      ).readAsStringSync();
      expect(
        content.contains('providerOfSecureTokenStorage'),
        isTrue,
        reason:
            'dio_instance_provider must read providerOfSecureTokenStorage',
      );
      expect(
        content.contains('providerOfSharedPreferencesRepository'),
        isFalse,
        reason:
            'dio_instance_provider must NOT use providerOfSharedPreferencesRepository '
            'for token operations',
      );
    });

    // ------------------------------------------------------------------ //
    // 7. SocketService uses SecureTokenStorage for AuthInterceptor
    // ------------------------------------------------------------------ //
    test('SocketService uses SecureTokenStorage', () {
      final content = File(
        'lib/features/shared/services/socket_service.dart',
      ).readAsStringSync();
      expect(
        content.contains('SecureTokenStorage'),
        isTrue,
        reason: 'SocketService must use SecureTokenStorage',
      );
      expect(
        content.contains('secureTokenStorage: _secureTokenStorage'),
        isTrue,
        reason:
            'SocketService must pass secureTokenStorage to AuthInterceptor',
      );
    });

    // ------------------------------------------------------------------ //
    // 8. UserService uses SecureTokenStorage for AuthInterceptor
    // ------------------------------------------------------------------ //
    test('UserService uses SecureTokenStorage', () {
      final content = File(
        'lib/features/shared/services/user_service.dart',
      ).readAsStringSync();
      expect(
        content.contains('SecureTokenStorage'),
        isTrue,
        reason: 'UserService must use SecureTokenStorage',
      );
      expect(
        content.contains('secureTokenStorage: _secureTokenStorage'),
        isTrue,
        reason:
            'UserService must pass secureTokenStorage to AuthInterceptor',
      );
    });

    // ------------------------------------------------------------------ //
    // 9. AppWrapper checks sign-in from SecureTokenStorage
    // ------------------------------------------------------------------ //
    test('AppWrapper reads refreshToken from SecureTokenStorage', () {
      final content = File('lib/others/app_wrapper.dart').readAsStringSync();
      expect(
        content.contains('providerOfSecureTokenStorage'),
        isTrue,
        reason:
            '_hasStoredSignIn must read refreshToken from encrypted storage',
      );
      expect(
        content.contains('providerOfSharedPreferencesRepository'),
        isFalse,
        reason:
            'AppWrapper must NOT use providerOfSharedPreferencesRepository '
            'for token checks',
      );
    });

    // ------------------------------------------------------------------ //
    // 10. No file under lib/ passes SharedPreferencesRepository to
    //     AuthInterceptor (the old insecure pattern)
    // ------------------------------------------------------------------ //
    test('No code passes SharedPreferencesRepository to AuthInterceptor', () {
      final libDir = Directory('lib');
      final dartFiles = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));
      final offenders = <String>[];
      // The old constructor parameter name that carried plaintext storage
      final oldPattern = RegExp(
        r'AuthInterceptor\s*\([^)]*sharedPreferencesRepository',
        multiLine: true,
      );
      for (final file in dartFiles) {
        final content = file.readAsStringSync();
        if (oldPattern.hasMatch(content)) {
          offenders.add(file.path);
        }
      }
      expect(
        offenders,
        isEmpty,
        reason:
            'These files still pass SharedPreferencesRepository to '
            'AuthInterceptor: $offenders',
      );
    });

    // ------------------------------------------------------------------ //
    // 11. flutter_secure_storage is declared as a dependency
    // ------------------------------------------------------------------ //
    test('pubspec.yaml includes flutter_secure_storage', () {
      final content = File('pubspec.yaml').readAsStringSync();
      expect(
        content.contains('flutter_secure_storage:'),
        isTrue,
        reason:
            'flutter_secure_storage must be declared in pubspec.yaml dependencies',
      );
    });

    // ------------------------------------------------------------------ //
    // 12. Provider is registered in instance_providers.dart
    // ------------------------------------------------------------------ //
    test('providerOfSecureTokenStorage is registered', () {
      final content = File(
        'lib/features/shared/providers/instance_providers.dart',
      ).readAsStringSync();
      expect(
        content.contains('providerOfSecureTokenStorage'),
        isTrue,
        reason:
            'instance_providers must export providerOfSecureTokenStorage',
      );
      expect(
        content.contains('SecureTokenStorage()'),
        isTrue,
        reason: 'Provider must create a SecureTokenStorage instance',
      );
    });
  });
}
