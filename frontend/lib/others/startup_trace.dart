import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A short, human-readable record of what start-up did, kept in memory.
///
/// TEST builds show it on the splash screen when start-up takes longer than
/// it should, so a tester can screenshot exactly which step it is waiting
/// on or which error stopped it. Nothing is sent anywhere.
class StartupTrace {
  StartupTrace._();

  static final DateTime _start = DateTime.now();

  /// Newest last. Capped so a loop can't grow it without bound.
  static final ValueNotifier<List<String>> lines = ValueNotifier(const []);

  static void mark(final String message) {
    final ms = DateTime.now().difference(_start).inMilliseconds;
    final line = '${(ms / 1000).toStringAsFixed(1)}s  $message';
    debugPrint('[startup] $line');
    final next = [...lines.value, line];
    lines.value = next.length > 60 ? next.sublist(next.length - 60) : next;
  }

  /// Records every uncaught Flutter and Dart error, keeping the existing
  /// handlers working.
  static void captureErrors() {
    final previousFlutter = FlutterError.onError;
    FlutterError.onError = (details) {
      mark('FLUTTER ERROR: ${_short(details.exceptionAsString())}');
      final where = details.stack?.toString().split('\n').take(3).join(' | ');
      if (where != null) mark('  at $where');
      previousFlutter?.call(details);
    };
    final previousPlatform = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stack) {
      mark('ERROR: ${_short(error.toString())}');
      mark('  at ${stack.toString().split('\n').take(3).join(' | ')}');
      return previousPlatform?.call(error, stack) ?? true;
    };
  }

  static String _short(final String text) =>
      text.length > 300 ? '${text.substring(0, 300)}...' : text;
}

/// Shown over the splash screen on TEST builds once start-up has run longer
/// than [after]: the trace, newest at the bottom, and a Copy button.
class StartupTraceOverlay extends StatefulWidget {
  const StartupTraceOverlay({
    super.key,
    this.after = const Duration(seconds: 10),
  });

  final Duration after;

  @override
  State<StartupTraceOverlay> createState() => _StartupTraceOverlayState();
}

class _StartupTraceOverlayState extends State<StartupTraceOverlay> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.after, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.55,
          ),
          decoration: BoxDecoration(
            color: const Color(0xEE23252B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ValueListenableBuilder<List<String>>(
            valueListenable: StartupTrace.lines,
            builder: (context, lines, _) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Start-up is taking longer than it should. '
                        'Screenshot this and send it to the ALRT team.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Clipboard.setData(
                        ClipboardData(text: lines.join('\n')),
                      ),
                      child: const Text('Copy'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: SingleChildScrollView(
                    reverse: true,
                    child: Text(
                      lines.join('\n'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontFamily: 'Courier',
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
