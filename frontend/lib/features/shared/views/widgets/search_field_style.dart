import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/others/app_colors.dart';

/// The one search-bar shape: a rounded RECTANGLE, not a capsule.
///
/// The map bar and the feed bar are the same control in two places, so the
/// radius and the glow live here rather than being typed out twice and
/// drifting. Both used to ask for a 40 radius on a 48 tall bar, which
/// clamps to a full oval; the product owner wants the softer rectangle.
abstract final class SearchFieldStyle {
  /// Bar height, shared so the radius stays well under half of it.
  static double get height => 48.spMin;

  /// Rounded rectangle. Deliberately far below height/2 (24) so it can
  /// never resolve to a capsule.
  static BorderRadius get borderRadius =>
      BorderRadius.circular(16.spMin);

  /// The orange halo. [isLit] brightens it while the field has focus.
  static List<BoxShadow> glow({final bool isLit = false}) => [
        BoxShadow(
          color: AppColors.searchGlow.withValues(alpha: isLit ? 0.5 : 0.28),
          blurRadius: isLit ? 30.0 : 20.0,
          spreadRadius: isLit ? 2.0 : 0.5,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.14),
          blurRadius: 14.0,
          offset: const Offset(0, 5),
        ),
      ];
}
