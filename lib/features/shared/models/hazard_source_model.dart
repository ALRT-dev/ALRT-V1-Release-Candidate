import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/shared/models/hazard_source_license_model.dart';

part 'hazard_source_model.freezed.dart';
part 'hazard_source_model.g.dart';

/// The shapes a source can render as. Mirrors HazardSourceShape in the
/// backend schema; the shape carries the SOURCE system, never the severity.
enum HazardSourceShape { triangle, diamond, circle, square, shield }

@freezed
abstract class HazardSource with _$HazardSource {
  const factory HazardSource({
    /// The unique identifier for the hazard source.
    required final String id,

    /// The name of the hazard source.
    final String? name,

    /// The URL associated with the hazard source.
    final String? url,

    /// The license information for the hazard source.
    final HazardSourceLicense? license,

    /// The copyright information for the hazard source.
    final String? copyrightText,

    /// The link to the copyright information for the hazard source.
    final String? copyrightLink,

    /// The advisory text provided by the hazard source.
    final String? advisoryText,

    /// The One Glance shape this source's alerts render as, straight from
    /// the backend source registry: triangle (AWS), diamond (official),
    /// circle (community), square (global humanitarian), shield (ALRT
    /// Intel). Null on older rows, where the render path falls back to the
    /// documented defaults.
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    final HazardSourceShape? shape,
  }) = _HazardSource;

  factory HazardSource.fromJson(Map<String, dynamic> json) =>
      _$HazardSourceFromJson(json);
}
