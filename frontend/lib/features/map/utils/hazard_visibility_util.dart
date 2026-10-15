import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_types.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/providers/states/hazard_filters_provider_state.dart';

/// Pure, unit-testable copies of MapProvider's private `_isInBounds`/
/// `_matchesFilters` predicates - extracted so the Map tab's exact
/// visibility rules (in particular, that a child category id like
/// "bushfire" correctly matches a filter selection that only contains its
/// parent id, e.g. "weatherAndEnvironment", and vice versa) can be
/// regression-tested without instantiating the whole provider. Behaviour is
/// unchanged from what MapProvider already did - see
/// frontend/test/hazard_visibility_util_test.dart.

/// Whether [hazard]'s point falls within [bounds]. A hazard with no
/// latitude/longitude is never in bounds.
///
/// The viewport can cross the antimeridian: zoom out from Australia and the
/// east edge passes 180 and comes back negative, so the south-west longitude
/// is GREATER than the north-east one. A plain `lng >= west && lng <= east`
/// is then false for every longitude on earth, which is why the map and the
/// Alerts list went blank on zoom out. A wrapped viewport covers everything
/// east of the west edge OR west of the east edge instead.
bool hazardIsInMapBounds(Hazard hazard, LatLngBounds bounds) {
  final lat = hazard.latitude;
  final lng = hazard.longitude;
  if (lat == null || lng == null) return false;
  if (lat < bounds.southwest.latitude || lat > bounds.northeast.latitude) {
    return false;
  }
  final west = bounds.southwest.longitude;
  final east = bounds.northeast.longitude;
  return west > east
      ? lng >= west || lng <= east
      : lng >= west && lng <= east;
}

/// Whether [hazard] passes the given source/category filters. Category
/// matching checks both the hazard's own categoryId AND its parent's id
/// against [filters.selectedCategoryIds] - a hazard is shown if either one
/// is selected, so a preset/report filed under a child category (e.g.
/// "bushfire") is still shown when only the parent ("weatherAndEnvironment")
/// is selected, and vice versa.
bool hazardMatchesMapFilters(Hazard hazard, HazardFiltersProviderState filters) {
  // Official warnings are always visible: an AWS Emergency Warning and any
  // official (not user-reported) critical-band alert match regardless of the
  // category selection and of the source switches.
  if (_isAlwaysVisibleOfficialWarning(hazard)) return true;

  final categoryId = hazard.categoryId;
  final parentCategoryId = hazard.category?.parentId;
  final isCategorySelected =
      categoryId != null && filters.selectedCategoryIds.contains(categoryId);
  final isParentCategorySelected =
      parentCategoryId != null &&
      filters.selectedCategoryIds.contains(parentCategoryId);
  if (filters.selectedCategoryIds.isNotEmpty &&
      !isCategorySelected &&
      !isParentCategorySelected) {
    return false;
  }

  if (hazard.isUserReported) return filters.userReported;

  if (hazard.isAwsCompliant == true) {
    // The official AWS level, the same field the server filters on
    // (isAwsCompliant + severity). The derived band is only the fallback
    // for a hazard the server sent without a severity.
    return switch (hazard.severity) {
      HazardSeverity.emergency => filters.awsEmergency,
      HazardSeverity.watchAndAct => filters.awsWatchAndAct,
      HazardSeverity.advice => filters.awsAdvice,
      HazardSeverity.info || HazardSeverity.unknown => filters.awsAdvice,
      null => switch (hazard.severityBand) {
        HazardSeverityBand.critical => filters.awsEmergency,
        HazardSeverityBand.action => filters.awsWatchAndAct,
        _ => filters.awsAdvice,
      },
    };
  }

  // Official (non-AWS) sources: the server returns every one of them under
  // officialNonAws; the two source switches the API predates (Global
  // humanitarian, ALRT Intel) are applied here, the same way the feed
  // applies them, so one filter state means the same thing on both tabs.
  if (!filters.officialNonAws) return false;
  return filters.allowsHazard(hazard);
}

/// AWS emergency warnings and official critical-band alerts are never hidden
/// by a filter. User-reported alerts are not official, so they stay filterable.
bool _isAlwaysVisibleOfficialWarning(Hazard hazard) {
  if (hazard.isUserReported) return false;
  if (hazard.isAwsCompliant == true &&
      hazard.severity == HazardSeverity.emergency) {
    return true;
  }
  return hazard.severityBand == HazardSeverityBand.critical;
}
