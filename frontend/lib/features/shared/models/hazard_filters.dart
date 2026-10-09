import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/shared/models/hazard_category_model.dart';
import 'package:hazard_app/features/shared/models/hazard_severity_with_count_model.dart';

part 'hazard_filters.freezed.dart';
part 'hazard_filters.g.dart';

@freezed
abstract class HazardFilters with _$HazardFilters {
  const factory HazardFilters({
    /// List of hazard category filters
    @Default(<HazardCategory>[]) final List<HazardCategory> categoryFilters,

    /// List of hazard severity filters for AWS hazards
    @Default(<HazardSeverityWithCount>[])
    final List<HazardSeverityWithCount> severityFiltersAws,

    /// List of hazard severity filters for non-AWS hazards
    @Default(<HazardSeverityWithCount>[])
    final List<HazardSeverityWithCount> severityFiltersNonAws,
  }) = _HazardFilters;

  factory HazardFilters.fromJson(Map<String, dynamic> json) =>
      _$HazardFiltersFromJson(json);
}
