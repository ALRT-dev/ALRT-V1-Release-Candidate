import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/services/voice_input_controller.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// The "Speak to ALRT" listening sheet (VoiceListening board): a live waveform, the running transcript and the
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

  static const _ink = Color(0xFF1C1C1E);
  static const _muted = Color(0xFF5C5C66);
  static const _orange = Color(0xFFE8622A);
  static const _peach = Color(0xFFFDEDE4);
  static const _labelOrange = Color(0xFFB84500);
  static const _line = Color(0xFFD9D6D0);
  static const _tries = <String>[
    'Save Scarborough as a place',
    'Send this alert to my group',
    'Read the warning near me',
    "What's near me?",
    'Take me to Perth CBD',
    'Check in',
  ];

  /// "Tap when done": stop listening and use what was heard so far.
  Future<void> _done() async {
    if (_completed) return;
    final heard = _transcript;
    await widget.controller.stop();
    _complete(heard);
  }

  /// Tapping a TRY SAYING chip is the same as saying it.
  Future<void> _useExample(final String phrase) async {
    if (_completed) return;
    await widget.controller.cancel();
    _complete(phrase);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
      ),
      padding: EdgeInsets.fromLTRB(20.spMin, 10.spMin, 20.spMin, 8.spMin),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40.spMin,
                  height: 5.spMin,
                  decoration: BoxDecoration(
                    color: _line,
                    borderRadius: BorderRadius.circular(3.spMin),
                  ),
                ),
              ),
              SizedBox(height: 14.spMin),
              Text(
                'Speak to ALRT',
                style: TextStyle(
                  fontSize: 22.spMin,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              SizedBox(height: 4.spMin),
              Text(
                'Search, ask, or get something done. Heard on this phone.',
                style: TextStyle(fontSize: 14.spMin, color: _muted, height: 1.4),
              ),
              SizedBox(height: 18.spMin),
              Center(
                child: Container(
                  width: 72.spMin,
                  height: 72.spMin,
                  decoration: const BoxDecoration(
                    color: _peach,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.mic_none_rounded,
                      size: 30.spMin, color: _orange),
                ),
              ),
              SizedBox(height: 10.spMin),
              _waveBuilder(),
              SizedBox(height: 8.spMin),
              // A long dictation scrolls inside its own box instead of
              // pushing the sheet off the screen.
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.2,
                ),
                child: SingleChildScrollView(
                  reverse: true,
                  child: Text(
                    _transcript.isEmpty ? 'Listening...' : '"$_transcript"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17.spMin,
                      fontWeight: FontWeight.w700,
                      color: _transcript.isEmpty ? _muted : _ink,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
              if (widget.detectIntent && _transcript.isNotEmpty) ...[
                SizedBox(height: 6.spMin),
                Text(
                  VoiceListeningSheet.detectIntentOf(_transcript) ==
                          VoiceIntent.report
                      ? 'Post an ALRT'
                      : 'Search',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.spMin,
                    fontWeight: FontWeight.w700,
                    color: _labelOrange,
                  ),
                ),
              ],
              SizedBox(height: 4.spMin),
              Text(
                'Say a place, a question, or what you want done.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.spMin, color: _muted),
              ),
              SizedBox(height: 16.spMin),
              SizedBox(
                height: 48.spMin,
                child: OutlinedButton(
                  onPressed: _done,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _ink,
                    side: const BorderSide(color: _line),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.spMin),
                    ),
                  ),
                  child: Text(
                    'Tap when done',
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.spMin),
              Text(
                'TRY SAYING',
                style: TextStyle(
                  fontSize: 12.spMin,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: _labelOrange,
                ),
              ),
              SizedBox(height: 8.spMin),
              Wrap(
                spacing: 8.spMin,
                runSpacing: 8.spMin,
                children: [
                  for (final phrase in _tries)
                    InkWell(
                      onTap: () => _useExample(phrase),
                      borderRadius: BorderRadius.circular(17.spMin),
                      child: Container(
                        height: 34.spMin,
                        padding: EdgeInsets.symmetric(horizontal: 12.spMin),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(17.spMin),
                          border: Border.all(
                            color: const Color(0xFFE3E6EA),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          '\u201C$phrase\u201D',
                          style: TextStyle(
                            fontSize: 13.spMin,
                            fontWeight: FontWeight.w600,
                            color: _ink,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 14.spMin),
              Text(
                'Anything that saves, sends or checks in asks you first. '
                'SOS and reports are never done by voice. The reply is read '
                'aloud and shown here. Your voice is never recorded.',
                style: TextStyle(fontSize: 12.spMin, color: _muted, height: 1.45),
              ),
              SizedBox(height: 6.spMin),
              TextButton(
                onPressed: _cancel,
                style: TextButton.styleFrom(foregroundColor: _muted),
                child: Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _waveBuilder() {
    const barCount = 6;
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
                  color: _orange,
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
