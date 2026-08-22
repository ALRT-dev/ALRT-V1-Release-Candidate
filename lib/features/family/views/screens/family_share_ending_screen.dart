import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';

class FamilyShareEndingScreenArgs {
  const FamilyShareEndingScreenArgs({
    required this.endsAt,
    required this.minutesLeft,
    this.onExtend,
    this.onStopNow,
    this.isSos = true,
  });

  /// When sharing stops on its own.
  final DateTime endsAt;

  /// How long is left, as the prompt was raised.
  final int minutesLeft;

  /// Grants another hour. Null hides the option, e.g. at the total cap.
  final Future<bool> Function()? onExtend;

  /// Stops sharing now.
  final Future<bool> Function()? onStopNow;

  /// SOS live share, or an ordinary journey.
  final bool isSos;
}

/// The warning before sharing ends.
///
/// ALRT asks before it stops, and doing nothing is a safe answer: sharing
/// ends on its own and the circle is told. Only the person sharing can
/// extend it, and only by choosing to.
class FamilyShareEndingScreen extends ConsumerStatefulWidget {
  const FamilyShareEndingScreen({super.key, required this.args});

  final FamilyShareEndingScreenArgs args;

  static const route = '/family-share-ending';

  @override
  ConsumerState<FamilyShareEndingScreen> createState() =>
      _FamilyShareEndingScreenState();
}

class _FamilyShareEndingScreenState
    extends ConsumerState<FamilyShareEndingScreen> {
  static const _top = Color(0xFF8E1414);
  static const _bottom = Color(0xFF5C0C0C);
  static const _keepSharingInk = Color(0xFFB01212);

  bool _isBusy = false;

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    final endsAtLabel = TimeOfDay.fromDateTime(args.endsAt).format(context);
    final minutes = args.minutesLeft;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            // 175 degrees: near vertical, a hair off true.
            begin: Alignment(-0.09, -1),
            end: Alignment(0.09, 1),
            colors: [_top, _bottom],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              26.spMin,
              70.spMin,
              26.spMin,
              30.spMin,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                20.hSizedBox,
                Container(
                  width: 88.spMin,
                  height: 88.spMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.schedule_rounded,
                    size: 40.spMin,
                    color: Colors.white,
                  ),
                ),
                26.hSizedBox,
                Text(
                  minutes <= 1
                      ? 'Sharing stops in a minute'
                      : 'Sharing stops in $minutes minutes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30.spMin,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                    height: 1.15,
                    color: Colors.white,
                  ),
                ),
                14.hSizedBox,
                Text(
                  args.isSos
                      ? 'Your SOS live share reaches its 1 hour limit at '
                            '$endsAtLabel. Nothing is extended unless you '
                            'choose it.'
                      : 'Your journey reaches the time you picked at '
                            '$endsAtLabel. Nothing is extended unless you '
                            'choose it.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5.spMin,
                    height: 1.65,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const Spacer(),
                if (args.onExtend != null) ...[
                  SizedBox(
                    height: 52.spMin,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _keepSharingInk,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.spMin),
                        ),
                      ),
                      onPressed: _isBusy ? null : _handleExtend,
                      child: Text(
                        'Keep sharing 1 more hour',
                        style: TextStyle(
                          fontSize: 15.spMin,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  11.hSizedBox,
                ],
                SizedBox(
                  height: 50.spMin,
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.spMin),
                      ),
                    ),
                    onPressed: _isBusy ? null : _handleStopNow,
                    child: Text(
                      "Stop now, I'm safe",
                      style: TextStyle(
                        fontSize: 14.spMin,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                13.hSizedBox,
                Text(
                  'If you do nothing, sharing ends on its own at '
                  '$endsAtLabel and your family is told it ended.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.spMin,
                    height: 1.6,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleExtend() async {
    final extend = widget.args.onExtend;
    if (extend == null) return;

    setState(() => _isBusy = true);
    final ok = await extend();
    if (!mounted) return;
    setState(() => _isBusy = false);
    if (ok) Navigator.of(context).maybePop();
  }

  Future<void> _handleStopNow() async {
    final stop = widget.args.onStopNow;

    setState(() => _isBusy = true);
    final ok = stop == null ? true : await stop();
    if (!mounted) return;
    setState(() => _isBusy = false);
    if (ok) Navigator.of(context).maybePop();
  }
}
