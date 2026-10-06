import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_types.dart';

part 'hazard_severity_with_count_model.freezed.dart';
part 'hazard_severity_with_count_model.g.dart';

@freezed
abstract class HazardSeverityWithCount with _$HazardSeverityWithCount {
  const factory HazardSeverityWithCount({
    /// The severity level of the hazard.
    required final HazardSeverity severity,

    /// The number of hazards associated with this severity level.
    @Default(0) final int hazardsCount,
  }) = _HazardSeverityWithCount;

  factory HazardSeverityWithCount.fromJson(Map<String, dynamic> json) =>
      _$HazardSeverityWithCountFromJson(json);
}
