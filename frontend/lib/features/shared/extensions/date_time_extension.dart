import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

extension DateTimeExt on DateTime {
  /// Returns a formatted string representation of the DateTime object.
  ///
  /// Eg. 5 minutes ago
  String get timeAgo {
    return timeago.format(this);
  }

  /// Returns a formatted string representation of the DateTime object.
  ///
  /// Eg. 5th June 2023 at 5:30pm
  String get formattedWithTime {
    final dayWithSuffix = _getDayWithOrdinalSuffix(day);

    final isToday =
        DateTime.now().year == year &&
        DateTime.now().month == month &&
        DateTime.now().day == day;

    final isYesterday =
        DateTime.now().year == year &&
        DateTime.now().month == month &&
        DateTime.now().day - 1 == day;

    if (isToday) {
      return 'Today at ${DateFormat('h:mma').format(this).toLowerCase()}';
    }

    if (isYesterday) {
      return 'Yesterday at ${DateFormat('h:mma').format(this).toLowerCase()}';
    }

    return '${DateFormat('MMMM yyyy').format(this).replaceFirst(
      DateFormat('MMMM').format(this),
      '$dayWithSuffix ${DateFormat('MMMM').format(this)}',
    )} at ${DateFormat('h:mma').format(this)}';
  }

  /// Returns a formatted string representation of the DateTime object.
  ///
  /// Eg. 5th June 2023
  String get formattedDateOnly {
    final dayWithSuffix = _getDayWithOrdinalSuffix(day);

    return DateFormat('MMMM yyyy')
        .format(this)
        .replaceFirst(
          DateFormat('MMMM').format(this),
          '$dayWithSuffix ${DateFormat('MMMM').format(this)}',
        );
  }

  /// Returns the day with the appropriate ordinal suffix (st, nd, rd, th)
  String _getDayWithOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }

    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }
}
