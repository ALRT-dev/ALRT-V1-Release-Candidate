import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/services/voice_input_controller.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// The dark "listening" sheet: a live waveform, the running transcript and the
/// on-device privacy promise. Starts listening on open and pops with the
/// recognised text the moment the speaker stops (or null if cancelled/empty).
/// What a finished dictation is for: searching a place or posting an ALRT.
enum VoiceIntent { search, report }

/// A finished dictation plus the detected intent.
typedef VoiceDictation = ({String text, VoiceIntent intent});

class VoiceListeningSheet extends StatefulWidget {
  const VoiceListeningSheet({
    super.key,
    required this.controller,
    this.detectIntent = false,
  });

  final VoiceInputController controller;

  /// When true the sheet shows a live "→ Search locations" /
  /// "→ Post an ALRT" line while speaking and returns the detected intent.
  final bool detectIntent;

  static Future<String?> show(
    BuildContext context,
    VoiceInputController controller,
  ) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => VoiceListeningSheet(controller: controller),
    );
  }

  /// Same sheet, but the caller also learns whether the words sounded like
  /// something to search for or something to report.
  static Future<VoiceDictation?> showForIntent(
    BuildContext context,
    VoiceInputController controller,
  ) async {
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (_) =>
          VoiceListeningSheet(controller: controller, detectIntent: true),
    );
    if (text == null || text.trim().isEmpty) return null;
    return (text: text.trim(), intent: detectIntentOf(text));
  }

  /// Lightweight on-device heuristic. Search phrasing wins outright
  /// ("find", "where is", "take me to"); otherwise first-person hazard
  /// phrasing and hazard nouns read as a report.
  static VoiceIntent detectIntentOf(final String transcript) {
    final t = ' ${transcript.toLowerCase().trim()} ';

    const searchStarts = [
      'search', 'find', 'where', 'show me', 'take me', 'navigate',
      'directions', 'go to', 'look up',
    ];
    for (final phrase in searchStarts) {
      if (t.trimLeft().startsWith(phrase)) return VoiceIntent.search;
    }

    const reportPhrases = [
      'report', "there's a", 'there is a', 'i can see', 'i see ',
      'i want to report', 'happening on', 'happening at',
    ];
    const hazardNouns = [
      ' fire ', ' smoke ', ' flood', ' floodwater', ' water rising',
      ' crash ', ' accident ', ' fallen tree', ' tree down',
      ' powerline', ' power line', ' power out', ' gas leak', ' spill ',
      ' storm damage', ' road blocked', ' road closed', ' hazard ',
    ];
    for (final phrase in reportPhrases) {
      if (t.contains(phrase)) return VoiceIntent.report;
    }
    for (final noun in hazardNouns) {
      if (t.contains(noun)) return VoiceIntent.report;
    }
    return VoiceIntent.search;
  }

  @override
  State<VoiceListeningSheet> createState() => _VoiceListeningSheetState();
}

class _VoiceListeningSheetState extends State<VoiceListeningSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  String _transcript = '';
  double _level = 0.0;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  Future<void> _startListening() async {
    try {
      await widget.controller.speech.listen(
        onResult: (result) {
          if (!mounted) return;
          setState(() => _transcript = result.recognizedWords);
          if (result.finalResult) {
            _complete(result.recognizedWords);
          }
        },
        onSoundLevelChange: (level) {
          if (mounted) setState(() => _level = level);
        },
        listenOptions: SpeechListenOptions(
          onDevice: true,
          listenMode: ListenMode.search,
          partialResults: true,
          cancelOnError: true,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 2),
        ),
      );
    } catch (_) {
      _complete('');
    }
  }

  void _complete(String text) {
    if (_completed) return;
    _completed = true;
    final trimmed = text.trim();
    Navigator.of(context).pop(trimmed.isEmpty ? null : trimmed);
  }

  Future<void> _cancel() async {
    if (_completed) return;
    _completed = true;
    await widget.controller.cancel();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B1F).withValues(alpha: 0.98),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      padding: EdgeInsets.fromLTRB(18.spMin, 18.spMin, 18.spMin, 14.spMin),
      child: SafeArea(
        top: false,
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _waveBuilder(),
          SizedBox(height: 6.spMin),
          Text(
            _transcript.isEmpty ? 'Listening…' : '"$_transcript"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.spMin,
              fontWeight: FontWeight.w800,
              color: _transcript.isEmpty
                  ? Colors.white.withValues(alpha: 0.4)
                  : Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          if (widget.detectIntent && _transcript.isNotEmpty) ...[
            SizedBox(height: 6.spMin),
            Text(
              VoiceListeningSheet.detectIntentOf(_transcript) ==
                      VoiceIntent.report
                  ? '\u2192 Post an ALRT'
                  : '\u2192 Search locations',
              style: TextStyle(
                fontSize: 11.spMin,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFFF8C00),
              ),
            ),
          ],
          SizedBox(height: 8.spMin),
          Text(
            'Listening · recognised on this phone · nothing is recorded or sent\n'
            'Releases the moment you stop speaking',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.5.spMin,
              color: Colors.white.withValues(alpha: 0.5),
              height: 1.6,
            ),
          ),
          SizedBox(height: 14.spMin),
          SizedBox(
            width: 120.spMin,
            height: 38.spMin,
            child: OutlinedButton(
              onPressed: _cancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.spMin),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 11.spMin,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _waveBuilder() {
    const barCount = 10;
    return SizedBox(
      height: 44.spMin,
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, _) {
          final phase = _waveController.value * 2 * math.pi;
          // Sound level nudges the amplitude; clamp so it always animates.
          final levelBoost = (_level.abs() / 10).clamp(0.0, 1.0);
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(barCount, (i) {
              final wobble = math.sin(phase + i * 0.7).abs();
              final height = (10 + wobble * (18 + levelBoost * 16)).spMin;
              return Container(
                width: 4.spMin,
                height: height,
                margin: EdgeInsets.symmetric(horizontal: 2.spMin),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFF8C00), Color(0xFFFF2020)],
                  ),
                  borderRadius: BorderRadius.circular(3.spMin),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
