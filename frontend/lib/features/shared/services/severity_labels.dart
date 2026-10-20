/// Severity label cache populated at startup from GET /api/app/config.
///
/// Falls back to Australian Warning System defaults so the app is always
/// functional even when the network call hasn't completed yet.
///
/// Usage:
///   SeverityLabels.emergency()          // "Emergency Warning" (or admin value)
///   SeverityLabels.forSeverity(severity) // convenience wrapper
library;

import 'package:hazard_app/features/shared/enums/hazard_severity_types.dart';

class SeverityLabels {
  SeverityLabels._();

  static Map<String, String> _labels = {};

  /// Called once on startup when GET /api/app/config resolves.
  static void update(Map<String, dynamic> labels) {
    _labels = labels.map((k, v) => MapEntry(k, v?.toString() ?? ''));
  }

  static String emergency() =>
      _labels['emergency']?.isNotEmpty == true
          ? _labels['emergency']!
          : 'Emergency Warning';

  static String watchAndAct() =>
      _labels['watchAndAct']?.isNotEmpty == true
          ? _labels['watchAndAct']!
          : 'Watch and Act';

  static String advice() =>
      _labels['advice']?.isNotEmpty == true ? _labels['advice']! : 'Advice';

  static String defaultLabel() =>
      _labels['default']?.isNotEmpty == true ? _labels['default']! : 'Alert';

  /// Returns the admin-configured label for an AWS severity level.
  /// Mirrors [HazardSeverity.titleAws] but reads from the live cache.
  static String forSeverity(HazardSeverity severity) {
    return switch (severity) {
      HazardSeverity.unknown => 'Unknown',
      // AWS has no Info level — Info maps to Advice (owner ruling 14 Oct 2026)
      HazardSeverity.info => advice(),
      HazardSeverity.advice => advice(),
      HazardSeverity.watchAndAct => watchAndAct(),
      HazardSeverity.emergency => emergency(),
    };
  }
}
