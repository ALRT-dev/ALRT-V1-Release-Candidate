import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/extensions/date_time_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:timeago/timeago.dart' as timeago;

class HazardExpiryTimer extends ConsumerStatefulWidget {
  const HazardExpiryTimer({
    super.key,
    required this.expiryDateTime,
    this.style,
    this.expiredColor = AppColors.red,
    this.activeColor = AppColors.black,
    this.warningColor = AppColors.orange,
    this.iconData,
    this.iconSize = 20.0,
  });

  final DateTime expiryDateTime;
  final TextStyle? style;
  final Color expiredColor;
  final Color activeColor;
  final Color warningColor;
  final IconData? iconData;
  final double iconSize;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _HazardExpiryTimerState();
}

class _HazardExpiryTimerState extends ConsumerState<HazardExpiryTimer> {
  Timer? _timer;
  Duration _timeRemaining = Duration.zero;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _calculateTimeRemaining();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _calculateTimeRemaining() {
    final now = DateTime.now();
    final difference = widget.expiryDateTime.difference(now);

    if (difference.isNegative) {
      _timeRemaining = Duration.zero;
      _isExpired = true;
    } else {
      _timeRemaining = difference;
      _isExpired = false;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _calculateTimeRemaining();
        });
      }

      if (_isExpired) {
        timer.cancel();
      }
    });
  }

  String _formatDuration(Duration duration) {
    if (_isExpired) {
      return 'Expired ${timeago.format(widget.expiryDateTime)}';
    }

    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  Color _getTimerColor() {
    if (_isExpired) {
      return widget.expiredColor;
    }

    final totalMinutes = _timeRemaining.inMinutes;

    if (totalMinutes <= 5) {
      return widget.expiredColor; // Critical - less than 5 minutes
    } else if (totalMinutes <= 10) {
      return widget.warningColor; // Warning - less than 10 minutes
    } else {
      return widget.activeColor; // Normal
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerColor = _getTimerColor();
    final textStyle =
        widget.style?.copyWith(color: timerColor) ??
        TextStyle(
          color: timerColor,
          fontWeight: FontWeight.w600,
          fontSize: 14.spMin,
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.iconData != null) ...[
          Icon(
            widget.iconData,
            color: timerColor,
            size: widget.iconSize.spMin,
          ),
          4.wSizedBox,
        ],
        Text(
          // if remaining time is greater than 1 month, show the exact expiry date
          _timeRemaining.inDays > 30
              ? widget.expiryDateTime.formattedDateOnly
              : _formatDuration(_timeRemaining),
          style: textStyle,
        ),
      ],
    );
  }
}
