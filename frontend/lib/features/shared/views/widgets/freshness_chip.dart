import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// "Live · updated 2 min ago" — how recently this alert was actually
/// touched.
///
/// The rule that matters: it never fakes liveness. Green only while the
/// alert really was updated inside the last hour; past that it falls back
/// to neutral grey and plain wording ("Updated 3 hrs ago"). The timestamp
/// is the newest real one we hold, so an old alert cannot be dressed up as
/// a fresh one. Pure timestamp maths, deterministic, no AI.
///
/// Re-renders on the minute so "2 min ago" does not quietly become a lie
/// while the sheet sits open.
class FreshnessChip extends StatefulWidget {
  const FreshnessChip({
    super.key,
    required this.updatedAt,
    this.createdAt,
  });

  /// Last time the SOURCE updated the alert.
  final DateTime? updatedAt;

  /// When we first ingested it. Used only when it is newer than
  /// [updatedAt], which is the "whichever is newer" half of the rule.
  final DateTime? createdAt;

  /// Green (genuinely live) only within this window.
  static const liveWindow = Duration(minutes: 60);

  /// The newest real timestamp we hold, or null if we hold none.
  static DateTime? freshest(final DateTime? updatedAt, final DateTime? createdAt) {
    if (updatedAt == null) return createdAt;
    if (createdAt == null) return updatedAt;
    return createdAt.isAfter(updatedAt) ? createdAt : updatedAt;
  }

  /// "2 min ago", "3 hrs ago", "4 days ago". Whole units only: a rounded
  /// number that is honest beats a precise one nobody reads.
  static String agoLabel(final Duration elapsed) {
    if (elapsed.inMinutes < 1) return 'just now';
    if (elapsed.inMinutes < 60) return '${elapsed.inMinutes} min ago';
    if (elapsed.inHours < 24) {
      return '${elapsed.inHours} ${elapsed.inHours == 1 ? 'hr' : 'hrs'} ago';
    }
    return '${elapsed.inDays} ${elapsed.inDays == 1 ? 'day' : 'days'} ago';
  }

  @override
  State<FreshnessChip> createState() => _FreshnessChipState();
}

class _FreshnessChipState extends State<FreshnessChip> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Tick on the minute boundary, then every minute, so every chip on
    // screen changes together instead of drifting.
    final now = DateTime.now();
    final toNextMinute = Duration(
      seconds: 60 - now.second,
      milliseconds: -now.millisecond,
    );
    _ticker = Timer(toNextMinute, () {
      if (!mounted) return;
      setState(() {});
      _ticker = Timer.periodic(
        const Duration(minutes: 1),
        (_) => mounted ? setState(() {}) : null,
      );
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stamp = FreshnessChip.freshest(widget.updatedAt, widget.createdAt);
    if (stamp == null) return const SizedBox.shrink();

    final elapsed = DateTime.now().difference(stamp);
    // A clock skewed into the future must not read as "live".
    if (elapsed.isNegative) return const SizedBox.shrink();

    final isLive = elapsed < FreshnessChip.liveWindow;
    final label = FreshnessChip.agoLabel(elapsed);
    final text = isLive ? 'Live · updated $label' : 'Updated $label';

    final ink = isLive ? const Color(0xFF14804A) : const Color(0xFF6B6875);
    final background =
        isLive ? const Color(0xFFE7F6EE) : const Color(0xFFF1F0F3);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.spMin, vertical: 3.spMin),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLive) ...[
            Container(
              width: 6.spMin,
              height: 6.spMin,
              decoration: const BoxDecoration(
                color: Color(0xFF17A05E),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 5.spMin),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 10.5.spMin,
              fontWeight: FontWeight.w700,
              color: ink,
            ),
          ),
        ],
      ),
    );
  }
}
