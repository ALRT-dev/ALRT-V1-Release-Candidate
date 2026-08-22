import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/shared/enums/hazard_review_status_types.dart';
import 'package:hazard_app/features/shared/enums/sort_category_types.dart';
import 'package:hazard_app/features/shared/enums/sort_order_types.dart';

part 'hazard_search_params.freezed.dart';
part 'hazard_search_params.g.dart';

@freezed
abstract class HazardSearchParams with _$HazardSearchParams {
  const factory HazardSearchParams({
    /// The search string to filter hazards by their title or description.
    final String? searchString,

    /// The list of category IDs to filter hazards.
    @Default(<String>[]) final List<String> categoryIds,

    /// The list of source IDs to filter hazards.
    @Default(<String>[]) final List<String> sourceIds,

    /// The list of location subscription IDs to filter hazards.
    @Default(<String>[]) final List<String> locationIds,

    /// The id of the user who reported the hazard to filter hazards.
    final String? reportedById,

    /// The review status to filter hazards.
    ///
    /// Defaults to [HazardReviewStatus.accepted] to show only accepted hazards.
    @Default(HazardReviewStatus.accepted) final HazardReviewStatus reviewStatus,

    /// The bounds for location-based filtering.
    final double? northeastLat,

    /// The bounds for location-based filtering.
    final double? northeastLng,

    /// The bounds for location-based filtering.
    final double? southwestLat,

    /// The bounds for location-based filtering.
    final double? southwestLng,

    /// Whether to ignore the hazard bounds filter and only use lat/lng point.
    @Default(false) final bool ignoreHazardLatLngBounds,

    /// Whether to show expired hazards or not.
    @Default(false) final bool showExpired,

    /// Whether to include hazards reported by AWS Emergency level.
    @Default(true) final bool awsEmergency,

    /// Whether to include hazards reported by AWS Watch and Act level.
    @Default(true) final bool awsWatchAndAct,

    /// Whether to include hazards reported by AWS Advice level.
    @Default(true) final bool awsAdvice,

    /// Whether to include hazards reported by Official Non-AWS sources.
    @Default(true) final bool officialNonAws,

    /// Whether to include hazards reported by User.
    @Default(true) final bool userReported,

    /// The list of sorting types to sort hazards.
    @Default(
      <Map<SortCategory, SortOrder>>[
        // More severe hazards first
        {SortCategory.severityBand: SortOrder.desc},

        // Then, closer hazards first
        {SortCategory.distance: SortOrder.asc},

        // Then, most recent hazards first
        {SortCategory.createdAt: SortOrder.desc},

        // Finally, highest confidence score first
        {SortCategory.confidenceScore: SortOrder.desc},
      ],
    )
    final List<Map<SortCategory, SortOrder>> sortSettings,

    /// The page number for pagination.
    @Default(1) final int page,

    /// The number of items per page for pagination.
    @Default(20) final int pageSize,
  }) = _HazardSearchParams;

  factory HazardSearchParams.fromJson(Map<String, dynamic> json) =>
      _$HazardSearchParamsFromJson(json);
}
