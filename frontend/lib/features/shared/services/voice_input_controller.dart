import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Thin wrapper around on-device speech recognition. Owns a single
/// [SpeechToText] instance shared across every mic in the app.
///
/// ALRT rules baked in here: tap-to-talk only (no wake word, no background
/// listening), recognition on-device, and audio is never recorded, stored or
/// sent. Initialisation is what triggers the OS microphone prompt, so callers
/// must show the priming sheet BEFORE calling [ensureInitialized].
class VoiceInputController {
  final SpeechToText speech = SpeechToText();

  bool _initialized = false;

  /// Whether on-device recognition is usable (permission granted and a
  /// recogniser exists for the device locale). Only meaningful after
  /// [ensureInitialized] has run at least once.
  bool available = false;

  bool get isListening => speech.isListening;

  /// Initialises speech recognition, requesting microphone/speech permission
  /// the first time. Returns whether recognition is available. Safe to call
  /// repeatedly; the underlying init only runs once.
  Future<bool> ensureInitialized() async {
    if (_initialized) return available;
    try {
      available = await speech.initialize(
        onError: (_) {},
        onStatus: (_) {},
        debugLogging: false,
      );
    } catch (_) {
      available = false;
    }
    _initialized = true;
    return available;
  }

  Future<void> stop() => speech.stop();

  Future<void> cancel() => speech.cancel();
}

final providerOfVoiceInput = Provider<VoiceInputController>(
  (ref) => VoiceInputController(),
);
