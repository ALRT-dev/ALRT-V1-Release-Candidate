import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';
import 'package:hazard_app/features/home/providers/home_tab_provider.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The strip under the map search bar (prototype board "Main", 9 Oct 2026):
/// how many warnings are loaded on the map right now, and a tap through to
/// the Alerts tab.
///
/// A "warning" is an alert in the Action or Critical band from an official
/// or ALRT source. Community reports never count: they are unverified and
/// the circle carries no official severity.
class MapWarningsBanner extends ConsumerWidget {
  const MapWarningsBanner({super.key});

  static const _textColor = Color(0xFF1C1C1E);
  static const _chevronColor = Color(0xFF5C5C66);
  static const _warningDotColor = AppColors.emergency;
  static const _clearDotColor = Color(0xFF16A34A);

  /// Counts the loaded hazards that are warnings. Kept static and pure so
  /// the select below only rebuilds the banner when the number changes.
  static int countWarnings(final List<Hazard> hazards) {
    var count = 0;
    for (final hazard in hazards) {
      if (hazard.isUserReported) continue;
      final band = hazard.severityBand;
      if (band == HazardSeverityBand.action ||
          band == HazardSeverityBand.critical) {
        count++;
      }
    }
    return count;
  }

  static String labelFor(final int count) {
    // The count is of the alerts in the map's current view, so the copy
    // says "in this area", not "near you", and stays short enough to fit a
    // narrow phone on one line.
    if (count == 0) return 'No warnings in this area right now';
    if (count == 1) return '1 warning in this area';
    return '$count warnings in this area';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(
      providerOfMap.select((value) => countWarnings(value.hazards)),
    );

    return Semantics(
      button: true,
      label: labelFor(count),
      child: Container(
        decoration: BoxDecoration(
          // Opaque: at 94% the map's own labels showed through and ran
          // into the text and chevron on the right.
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.spMin),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 14.spMin,
          vertical: 10.spMin,
        ),
        child: Row(
          children: [
            Container(
              width: 10.spMin,
              height: 10.spMin,
              decoration: BoxDecoration(
                color: count > 0 ? _warningDotColor : _clearDotColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 10.spMin),
            Expanded(
              child: Text(
                labelFor(count),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.spMin,
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                ),
              ),
            ),
            SizedBox(width: 8.spMin),
            Icon(
              LucideIcons.chevronRight,
              size: 16.spMin,
              color: _chevronColor,
            ),
          ],
        ),
      ).onPressed(
        () => ref.read(providerOfHomeTab.notifier).state =
            HomeTab.notifications,
      ),
    );
  }
}
