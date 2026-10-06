import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/shared/models/hazard_category_model.dart';
import 'package:hazard_app/features/shared/models/hazard_severity_with_count_model.dart';

part 'get_available_filters_response.freezed.dart';
part 'get_available_filters_response.g.dart';

@freezed
abstract class GetAvailableFiltersResponse with _$GetAvailableFiltersResponse {
  const factory GetAvailableFiltersResponse({
    /// The list of hazard categories that can be used as filters.
    @Default(<HazardCategory>[]) final List<HazardCategory> categoryFilters,

    /// The list of hazard severities that can be used as filters.
    @Default(<HazardSeverityWithCount>[])
    final List<HazardSeverityWithCount> severityFiltersAws,

    /// The list of hazard severities that can be used as filters.
    @Default(<HazardSeverityWithCount>[])
    final List<HazardSeverityWithCount> severityFiltersNonAws,
  }) = _GetAvailableFiltersResponse;

  factory GetAvailableFiltersResponse.fromJson(Map<String, dynamic> json) =>
      _$GetAvailableFiltersResponseFromJson(json);
}
