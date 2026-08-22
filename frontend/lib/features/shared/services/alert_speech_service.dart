import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Speaks alerts aloud, on-device, for people who can't read them fast.
///
/// One voice at a time: a new [speak] cuts off the previous one, so a burst
/// of alerts never queues into a backlog of speech.
class AlertSpeechService {
  AlertSpeechService() {
    _tts
      // Deeper and slower than the default: an alert read at chat
      // speed is hard to follow, and a lower pitch carries better.
      ..setSpeechRate(0.38)
      ..setPitch(0.85)
      ..setVolume(1.0)
      ..awaitSpeakCompletion(true);
    _configureVoice();
  }

  final _tts = FlutterTts();
  bool _speaking = false;
  Future<void>? _voiceReady;

  bool get isSpeaking => _speaking;

  /// Picks a calm female voice, the assistant register people already trust
  /// for being read to. Device voice catalogues differ wildly, so this scores
  /// what is installed rather than naming one voice that may not exist: a
  /// female voice in the user's own language wins, then any female voice,
  /// and if the device offers none we simply keep the system default. An
  /// alert must still be spoken even when the nice voice is missing.
  Future<void> _configureVoice() async {
    _voiceReady = _pickVoice();
    await _voiceReady;
  }

  Future<void> _pickVoice() async {
    try {
      final raw = await _tts.getVoices;
      if (raw is! List) return;

      final voices = raw
          .whereType<Map>()
          .map((v) => v.map((k, value) => MapEntry('$k', '$value')))
          .toList();
      if (voices.isEmpty) return;

      int score(final Map<String, String> voice) {
        final name = (voice['name'] ?? '').toLowerCase();
        final gender = (voice['gender'] ?? '').toLowerCase();
        final locale = (voice['locale'] ?? '').toLowerCase();

        var points = 0;
        if (gender == 'female') points += 6;
        // Android rarely reports gender; these are the female variants in
        // the standard Google and Samsung voice sets.
        if (RegExp(r'#female|female|-f-|_f_').hasMatch(name)) points += 5;
        if (RegExp(r'\b(samantha|karen|moira|tessa|serena|fiona|zoe|ava|allison|susan|nicky)\b')
            .hasMatch(name)) {
          points += 5; // known calm female voices on iOS
        }
        if (locale.startsWith('en')) points += 2;
        // Prefer natural/enhanced renditions when the device has them.
        if (name.contains('enhanced') || name.contains('neural')) points += 2;
        if (name.contains('premium') || name.contains('natural')) points += 2;
        return points;
      }

      Map<String, String>? best;
      var bestScore = 0;
      for (final voice in voices) {
        final s = score(voice);
        if (s > bestScore) {
          bestScore = s;
          best = voice;
        }
      }

      // No evidence of a female voice: leave the system default alone rather
      // than swapping to an arbitrary one.
      if (best == null || bestScore < 5) return;
      final name = best['name'];
      final locale = best['locale'];
      if (name == null || locale == null) return;
      await _tts.setVoice({'name': name, 'locale': locale});
    } catch (_) {
      // Any device that will not enumerate voices keeps its default.
    }
  }

  Future<void> speak(final String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    // Never let voice selection delay an alert by more than a moment.
    await Future.any([
      if (_voiceReady != null) _voiceReady!,
      Future<void>.delayed(const Duration(milliseconds: 400)),
    ]);
    await _tts.stop();
    _speaking = true;
    try {
      await _tts.speak(trimmed);
    } finally {
      _speaking = false;
    }
  }

  Future<void> stop() async {
    _speaking = false;
    await _tts.stop();
  }
}

final providerOfAlertSpeech = Provider<AlertSpeechService>(
  (ref) => AlertSpeechService(),
);
