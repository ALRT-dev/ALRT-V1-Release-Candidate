import 'dart:ui';

import 'package:hazard_app/others/app_colors.dart';

enum UserReportsStatus {
  unverified,
  emerging,
  verified;

  /// Returns the title string for each status type.
  String get title {
    switch (this) {
      case UserReportsStatus.unverified:
        return 'Unverified';
      case UserReportsStatus.emerging:
        return 'Emerging';
      case UserReportsStatus.verified:
        return 'Verified';
    }
  }

  /// Returns the associated color for each status type.
  Color get color {
    switch (this) {
      case UserReportsStatus.unverified:
        return AppColors.lightGrey;
      case UserReportsStatus.emerging:
        return AppColors.brown;
      case UserReportsStatus.verified:
        return AppColors.green;
    }
  }
}
