import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Child mode: a parent-set restriction on THIS phone.
///
/// What it is for: a parent signs into ALRT on their child's phone so the
/// child can see hazards near them, send an SOS, and answer a check-in.
/// What the child should not be doing is publishing to strangers, so
/// Report an ALRT is removed.
///
/// What it deliberately is NOT: an age gate, an identity claim, or
/// anything the app tells a server. Nothing about a child is collected or
/// transmitted; this is a switch on a device. That distinction matters
/// beyond tidiness, because declaring a child audience to the app stores
/// pulls in verifiable parental consent and a much heavier set of
/// obligations around a product that handles location.
///
/// It is honest about what it is: a helpful restriction, not a security
/// boundary. Turning it off needs the PIN when one is set, which stops the
/// casual case, and the copy does not pretend to do more than that.
class ChildModeSettings {
  const ChildModeSettings({required this.isOn, required this.hasPin});

  final bool isOn;

  /// Whether a PIN guards turning it off.
  final bool hasPin;
}

class ChildModeNotifier extends Notifier<ChildModeSettings> {
  static const _onKey = 'child_mode_enabled';
  static const _pinKey = 'child_mode_pin';

  String? _pin;
  bool _loaded = false;

  @override
  ChildModeSettings build() {
    if (!_loaded) _load();
    return const ChildModeSettings(isOn: false, hasPin: false);
  }

  Future<void> _load() async {
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    _pin = prefs.getString(_pinKey);
    state = ChildModeSettings(
      isOn: prefs.getBool(_onKey) ?? false,
      hasPin: _pin != null && _pin!.isNotEmpty,
    );
  }

  /// Turns child mode on, optionally guarded by a PIN.
  Future<void> enable({final String? pin}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onKey, true);
    if (pin != null && pin.isNotEmpty) {
      _pin = pin;
      await prefs.setString(_pinKey, pin);
    }
    state = ChildModeSettings(
      isOn: true,
      hasPin: _pin != null && _pin!.isNotEmpty,
    );
  }

  /// Turns it off. Returns false when a PIN is set and the wrong one (or
  /// none) was given, so the caller can say so without guessing why.
  Future<bool> disable({final String? pin}) async {
    if (_pin != null && _pin!.isNotEmpty && pin != _pin) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onKey, false);
    state = ChildModeSettings(
      isOn: false,
      hasPin: _pin != null && _pin!.isNotEmpty,
    );
    return true;
  }

  /// Clears the PIN, leaving child mode as it is.
  Future<void> clearPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
    _pin = null;
    state = ChildModeSettings(isOn: state.isOn, hasPin: false);
  }
}

final providerOfChildMode =
    NotifierProvider<ChildModeNotifier, ChildModeSettings>(
      ChildModeNotifier.new,
    );

/// The one thing most of the app needs to ask.
final providerOfIsChildMode = Provider<bool>(
  (ref) => ref.watch(providerOfChildMode).isOn,
);
