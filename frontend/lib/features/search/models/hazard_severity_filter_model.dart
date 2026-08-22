import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_types.dart';

part 'hazard_severity_filter_model.freezed.dart';
part 'hazard_severity_filter_model.g.dart';

@freezed
abstract class HazardSeverityFilter with _$HazardSeverityFilter {
  const factory HazardSeverityFilter({
    /// The list of AWS compliant severity levels to filter hazards.
    @Default(<HazardSeverity>[]) final List<HazardSeverity> aws,

    /// The list of non-AWS compliant severity levels to filter hazards.
    @Default(<HazardSeverity>[]) final List<HazardSeverity> nonAws,
  }) = _HazardSeverityFilter;

  factory HazardSeverityFilter.fromJson(Map<String, dynamic> json) =>
      _$HazardSeverityFilterFromJson(json);
}
