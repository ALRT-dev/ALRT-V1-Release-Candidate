import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';
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
bool hazardIsInMapBounds(Hazard hazard, LatLngBounds bounds) {
  final lat = hazard.latitude;
  final lng = hazard.longitude;
  if (lat == null || lng == null) return false;
  return lat >= bounds.southwest.latitude &&
      lat <= bounds.northeast.latitude &&
      lng >= bounds.southwest.longitude &&
      lng <= bounds.northeast.longitude;
}

/// Whether [hazard] passes the given source/category filters. Category
/// matching checks both the hazard's own categoryId AND its parent's id
/// against [filters.selectedCategoryIds] - a hazard is shown if either one
/// is selected, so a preset/report filed under a child category (e.g.
/// "bushfire") is still shown when only the parent ("weatherAndEnvironment")
/// is selected, and vice versa.
bool hazardMatchesMapFilters(Hazard hazard, HazardFiltersProviderState filters) {
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
    return switch (hazard.severityBand) {
      HazardSeverityBand.critical => filters.awsEmergency,
      HazardSeverityBand.action => filters.awsWatchAndAct,
      _ => filters.awsAdvice,
    };
  }

  return filters.officialNonAws;
}
