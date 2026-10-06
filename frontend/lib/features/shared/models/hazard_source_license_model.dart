import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/others/app_colors.dart';

part 'hazard_source_license_model.freezed.dart';
part 'hazard_source_license_model.g.dart';

@freezed
abstract class HazardSourceLicense with _$HazardSourceLicense {
  const factory HazardSourceLicense({
    /// The badge for the hazard source license.
    required final String badgeText,

    /// The full text of the hazard source license.
    required final String licenseText,

    /// The background color for the hazard source license badge.
    @ColorConverter()
    @Default(AppColors.extraLightblue)
    final Color backgroundColor,

    /// The foreground color for the hazard source license badge.
    @ColorConverter() @Default(AppColors.blue) final Color foregroundColor,

    /// The link associated with the hazard source license.
    final String? link,
  }) = _HazardSourceLicense;

  factory HazardSourceLicense.fromJson(Map<String, dynamic> json) =>
      _$HazardSourceLicenseFromJson(json);
}

class ColorConverter implements JsonConverter<Color, String> {
  const ColorConverter();

  @override
  Color fromJson(String json) {
    final hexColor = json.replaceFirst('#', '');
    if (hexColor.length == 6) {
      return Color(int.parse('FF$hexColor', radix: 16));
    } else if (hexColor.length == 8) {
      return Color(int.parse(hexColor, radix: 16));
    }
    return AppColors.black;
  }

  @override
  String toJson(Color object) {
    // ignore: deprecated_member_use
    return '#${object.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}
