import 'package:hazard_app/features/home_screen_widget/home_widget_keys.dart';
import 'package:hazard_app/features/home_screen_widget/models/home_widget_alert.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_types.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';

/// The band word, which is what the widget chip writes when the source
/// publishes no level of its own (locked rule 8: never colour alone).
extension HazardSeverityBandWidgetLabel on HazardSeverityBand {
  String get widgetLabel => switch (this) {
        HazardSeverityBand.info => 'Info',
        HazardSeverityBand.monitor => 'Monitor',
        HazardSeverityBand.action => 'Action',
        HazardSeverityBand.critical => 'Critical',
      };

  /// Monochrome-safe glyphs per band. No longer drawn on the widget (the
  /// system font rendered them as gradient blobs beside the chip), kept
  /// for any surface that wants a colour-free marker.
  String get widgetEmoji => switch (this) {
        HazardSeverityBand.info => '🔵',
        HazardSeverityBand.monitor => '🟡',
        HazardSeverityBand.action => '🟠',
        HazardSeverityBand.critical => '🔴',
      };
}

/// Maps app hazard concepts onto the [HomeWidgetPayload] the native widgets
/// render. Keeping this in one place means wiring the widget to real hazard
/// data is a single call from wherever the nearby-alerts list already lives.
extension HazardSeverityWidgetBand on HazardSeverity {
  /// Collapses the 5-value app severity onto the 4 widget bands. The `critical`
  /// band is the only one that earns the solid red gradient on the widget
  /// (locked rule 6: "the two reds").
  HazardSeverityBand get widgetBand => switch (this) {
        HazardSeverity.unknown => HazardSeverityBand.info,
        HazardSeverity.info => HazardSeverityBand.info,
        HazardSeverity.advice => HazardSeverityBand.monitor,
        HazardSeverity.watchAndAct => HazardSeverityBand.action,
        HazardSeverity.emergency => HazardSeverityBand.critical,
      };
}

class HomeWidgetMapper {
  const HomeWidgetMapper._();

  /// Builds a single widget row from the fields a hazard already carries.
  /// Severity label + emoji are always populated so the row reads without
  /// colour (locked rule 8).
  static HomeWidgetAlert alert({
    required final HazardSeverity severity,
    required final String title,
    final String? area,
    final String? distance,
    final String? time,
  }) {
    return HomeWidgetAlert(
      band: severity.widgetBand,
      severityLabel: severity.titleAws,
      title: title,
      emoji: severity.emojiAws,
      area: area,
      distance: distance,
      time: time,
    );
  }

  /// Builds a widget row straight from a [Hazard]. Uses the hazard's own
  /// [Hazard.severityBand] and [Hazard.severityTitle] so it stays consistent
  /// with how the hazard renders everywhere else in the app.
  static HomeWidgetAlert fromHazard(
    final Hazard hazard, {
    final String? distance,
    final String? time,
  }) {
    final band = hazard.severityBand ??
        hazard.severity?.widgetBand ??
        HazardSeverityBand.info;
    // A hazard with no published severity resolved to the literal word
    // "Unknown", which is what the widget chip printed. It tells a reader
    // nothing and looks broken; the band we already computed is the
    // honest label for a source that publishes no level of its own.
    final title = hazard.severityTitle.trim();
    final label = (title.isEmpty || title.toLowerCase() == 'unknown')
        ? band.widgetLabel
        : title;
    return HomeWidgetAlert(
      band: band,
      severityLabel: label,
      title: hazard.title ?? hazard.category?.name ?? 'Hazard',
      emoji: band.widgetEmoji,
      area: hazard.locationName,
      distance: distance,
      time: time,
    );
  }

  /// Builds the full payload from an ordered (highest-severity-first) list of
  /// nearby alerts. Pass an empty list to render the green "All clear" state.
  static HomeWidgetPayload payload({
    required final List<HomeWidgetAlert> nearby,
    required final String updatedLabel,
    final String deeplink = '${HomeWidgetKeys.deeplinkScheme}://open?screen=alerts',
  }) {
    if (nearby.isEmpty) {
      return HomeWidgetPayload.allClear(
        updatedLabel: updatedLabel,
        deeplink: deeplink,
      );
    }
    return HomeWidgetPayload(
      updatedLabel: updatedLabel,
      deeplink: deeplink,
      primary: nearby.first,
      more: nearby.skip(1).take(3).toList(),
      activeCount: nearby.length,
    );
  }
}
