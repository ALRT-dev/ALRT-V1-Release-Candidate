import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local, device-only appearance preference (Profile > Preferences >
/// Appearance). Never synced to the account - a fresh install or a
/// different device always starts back at [ThemeMode.system].
const _prefsKey = 'appearance_theme_mode';

String _encode(final ThemeMode mode) => switch (mode) {
  ThemeMode.light => 'light',
  ThemeMode.dark => 'dark',
  ThemeMode.system => 'system',
};

ThemeMode _decode(final String? value) => switch (value) {
  'light' => ThemeMode.light,
  'dark' => ThemeMode.dark,
  _ => ThemeMode.system,
};

final providerOfAppearance =
    NotifierProvider<AppearanceNotifier, ThemeMode>(AppearanceNotifier.new);

class AppearanceNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = _decode(prefs.getString(_prefsKey));
  }

  Future<void> setThemeMode(final ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _encode(mode));
  }
}
