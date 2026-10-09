import 'dart:ui';

import 'package:hazard_app/others/app_colors.dart';

enum HazardSeverityBand {
  info,
  monitor,
  action,
  critical;

  /// The locked band hex for an AWS alert.
  ///
  /// AWS never renders the grey info band: its lowest level is Advice,
  /// which wears the Monitor yellow.
  Color get colorAws {
    return switch (this) {
      HazardSeverityBand.info => AppColors.advice,
      HazardSeverityBand.monitor => AppColors.advice,
      HazardSeverityBand.action => AppColors.watchAndAct,
      HazardSeverityBand.critical => AppColors.emergency,
    };
  }

  /// The locked band hex for a non-AWS alert.
  ///
  /// Info used to be transparent here, which is why low-band alerts drew
  /// as white while the legend showed the locked grey. Info is #8A93A0
  /// everywhere now.
  Color get colorNonAws {
    return switch (this) {
      HazardSeverityBand.info => AppColors.info,
      HazardSeverityBand.monitor => AppColors.advice,
      HazardSeverityBand.action => AppColors.watchAndAct,
      HazardSeverityBand.critical => AppColors.emergency,
    };
  }
}
