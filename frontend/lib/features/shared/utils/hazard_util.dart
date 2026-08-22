import 'package:geolocator/geolocator.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';
import 'package:hazard_app/features/shared/enums/sort_category_types.dart';
import 'package:hazard_app/features/shared/enums/sort_order_types.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';

class HazardUtil {
  /// Sorts a list of hazards based on the provided sort settings.
  ///
  /// This method supports multi-level sorting with the following categories:
  /// - [SortCategory.severityBand]: Sort by severity band (critical > action > monitor > info)
  /// - [SortCategory.distance]: Sort by distance from user's current location
  /// - [SortCategory.createdAt]: Sort by creation date
  /// - [SortCategory.confidenceScore]: Sort by AI confidence score
  ///
  /// Each sort category can be in ascending or descending order.
  /// The sorting is performed in the order of the provided sort settings.
  ///
  /// For distance sorting, provide [userLatitude] and [userLongitude].
  /// Hazards without valid coordinates or when user location is unavailable
  /// will be treated as infinitely distant (placed at the end in ascending order).
  ///
  /// The implementation uses a highly optimized approach:
  /// - Pre-calculates distances once before sorting
  /// - Uses chained comparators for multi-level sorting
  /// - Employs stable sorting to preserve relative order of equal elements
  static List<Hazard> sortHazards(
    final List<Hazard> hazards,
    final List<Map<SortCategory, SortOrder>> sortSettings, {
    final double? userLatitude,
    final double? userLongitude,
  }) {
    if (hazards.isEmpty || sortSettings.isEmpty) {
      return hazards;
    }

    // Create a mutable copy to sort
    final sortableHazards = List<Hazard>.from(hazards);

    // Define severity band ordering (higher index = more severe)
    const severityOrder = {
      HazardSeverityBand.info: 0,
      HazardSeverityBand.monitor: 1,
      HazardSeverityBand.action: 2,
      HazardSeverityBand.critical: 3,
    };

    // Pre-calculate distances if distance sorting is needed
    Map<String, double>? distanceCache;
    if (sortSettings.any((s) => s.containsKey(SortCategory.distance))) {
      distanceCache = _calculateDistances(
        hazards,
        userLatitude,
        userLongitude,
      );
    }

    // Build a composite comparator from all sort settings
    int Function(Hazard, Hazard)? comparator;

    for (final sortSetting in sortSettings) {
      final category = sortSetting.keys.first;
      final order = sortSetting.values.first;
      final isAscending = order == SortOrder.asc;

      // Create comparator for this sort category
      final categoryComparator = _createComparator(
        category,
        isAscending,
        severityOrder,
        distanceCache,
      );

      // Chain comparators for multi-level sorting
      if (comparator == null) {
        comparator = categoryComparator;
      } else {
        final previousComparator = comparator;
        comparator = (a, b) {
          final result = previousComparator(a, b);
          return result != 0 ? result : categoryComparator(a, b);
        };
      }
    }

    // Sort using the composite comparator
    if (comparator != null) {
      sortableHazards.sort(comparator);
    }

    return sortableHazards;
  }

  /// Creates a comparator function for a specific sort category.
  static int Function(Hazard, Hazard) _createComparator(
    final SortCategory category,
    final bool isAscending,
    final Map<HazardSeverityBand, int> severityOrder,
    final Map<String, double>? distanceCache,
  ) {
    return (a, b) {
      int result;

      switch (category) {
        case SortCategory.severityBand:
          final aSeverity = severityOrder[a.severityBand] ?? -1;
          final bSeverity = severityOrder[b.severityBand] ?? -1;
          result = aSeverity.compareTo(bSeverity);
          break;

        case SortCategory.distance:
          if (distanceCache == null) {
            result = 0;
            break;
          }
          final aDistance = distanceCache[a.id] ?? double.infinity;
          final bDistance = distanceCache[b.id] ?? double.infinity;
          result = aDistance.compareTo(bDistance);
          break;

        case SortCategory.createdAt:
          final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
          final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
          result = aTime.compareTo(bTime);
          break;

        case SortCategory.confidenceScore:
          final aScore = a.confidenceScore ?? -1;
          final bScore = b.confidenceScore ?? -1;
          result = aScore.compareTo(bScore);
          break;
      }

      // Reverse if descending order
      return isAscending ? result : -result;
    };
  }

  /// Pre-calculates distances from user's current location to all hazards.
  ///
  /// Returns a map of hazard ID to distance in meters.
  /// Hazards without valid coordinates will not be included in the map.
  ///
  /// This is a performance optimization to avoid calculating distances
  /// multiple times during sorting comparisons.
  ///
  /// Uses the Haversine formula via Geolocator for accurate distance calculation.
  static Map<String, double> _calculateDistances(
    final List<Hazard> hazards,
    final double? userLatitude,
    final double? userLongitude,
  ) {
    final distances = <String, double>{};

    // Return empty map if user location is not available
    if (userLatitude == null || userLongitude == null) {
      return distances;
    }

    // Calculate distances for all hazards with valid coordinates
    for (final hazard in hazards) {
      if (hazard.id != null &&
          hazard.latitude != null &&
          hazard.longitude != null) {
        try {
          final distance = Geolocator.distanceBetween(
            userLatitude,
            userLongitude,
            hazard.latitude!,
            hazard.longitude!,
          );
          distances[hazard.id!] = distance;
        } catch (e) {
          // Skip hazards with invalid coordinates
          continue;
        }
      }
    }

    return distances;
  }
}
