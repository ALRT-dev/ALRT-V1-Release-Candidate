import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hazard_app/features/shared/enums/shared_prefs_key_types.dart';
import 'package:hazard_app/features/shared/repositories/shared_prefs_repository.dart';

/// Encrypted storage for authentication tokens.
///
/// Uses the platform keychain/keystore (iOS Keychain, Android EncryptedSharedPreferences)
/// so tokens are never readable from disk, backups or rooted-device file access.
///
/// On first use after upgrading from the old plaintext storage, tokens are
/// automatically migrated: read from [SharedPreferencesRepository], written
/// here, then deleted from SharedPreferences.
class SecureTokenStorage {
  SecureTokenStorage({
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _secureStorage;

  /// The three keys that hold authentication secrets.
  static const _secureKeys = {
    SharedPrefsKey.accessToken,
    SharedPrefsKey.refreshToken,
    SharedPrefsKey.authMethod,
  };

  /// Whether [key] is one this storage manages.
  static bool manages(SharedPrefsKey key) => _secureKeys.contains(key);

  // ---------------------------------------------------------------------------
  // Read / write / delete
  // ---------------------------------------------------------------------------

  Future<String?> read(SharedPrefsKey key) async {
    assert(manages(key), '$key is not a secure-token key');
    try {
      return await _secureStorage.read(key: key.name);
    } catch (_) {
      // A corrupted keystore entry is treated as absent rather than crashing
      // the auth flow. The next login writes a fresh value.
      return null;
    }
  }

  Future<void> write(SharedPrefsKey key, String value) async {
    assert(manages(key), '$key is not a secure-token key');
    await _secureStorage.write(key: key.name, value: value);
  }

  Future<void> delete(SharedPrefsKey key) async {
    assert(manages(key), '$key is not a secure-token key');
    await _secureStorage.delete(key: key.name);
  }

  // ---------------------------------------------------------------------------
  // One-time migration from plaintext SharedPreferences
  // ---------------------------------------------------------------------------

  /// Migrates any tokens still sitting in plaintext SharedPreferences into
  /// encrypted storage and removes the plaintext copies.
  ///
  /// Safe to call on every cold start — it no-ops when there is nothing to
  /// migrate (the SharedPreferences keys are already gone).
  Future<void> migrateFromSharedPrefs(
    SharedPreferencesRepository prefs,
  ) async {
    for (final key in _secureKeys) {
      final result = await prefs.getString(key: key);
      final plaintext = result.whenSuccess((value) => value);
      if (plaintext != null && plaintext.isNotEmpty) {
        // Write to encrypted storage, then remove the plaintext copy.
        await write(key, plaintext);
        await prefs.removeKey(key: key);
      }
    }
  }
}
