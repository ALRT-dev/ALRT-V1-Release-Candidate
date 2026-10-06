import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';

/// A single hazard row as rendered on the home-screen widget.
///
/// Deliberately a small, self-contained value object (not a Freezed model):
/// it is only ever serialized to the widget payload and never round-tripped
/// through the API layer.
class HomeWidgetAlert {
  const HomeWidgetAlert({
    required this.band,
    required this.severityLabel,
    required this.title,
    required this.emoji,
    this.area,
    this.distance,
    this.time,
  });

  /// Severity band drives shape + colour on the native side. The band name is
  /// what the native code switches on, so it is always sent alongside the
  /// human label (severity is never colour alone — locked rule 8).
  final HazardSeverityBand band;

  /// Human-readable severity, e.g. "Emergency", "Watch and Act". Always shown
  /// so the state reads without relying on colour.
  final String severityLabel;

  /// Short hazard title, e.g. "Bushfire".
  final String title;

  /// A monochrome-safe glyph that still carries meaning if colour is stripped.
  final String emoji;

  /// Optional area/suburb, e.g. "Kinglake West".
  final String? area;

  /// Optional distance string already localized, e.g. "3.2 km".
  final String? distance;

  /// Optional relative time already localized, e.g. "8 min ago".
  final String? time;

  Map<String, dynamic> toJson() => {
        'band': band.name,
        'severityLabel': severityLabel,
        'title': title,
        'emoji': emoji,
        if (area != null) 'area': area,
        if (distance != null) 'distance': distance,
        if (time != null) 'time': time,
      };
}

/// The complete payload the home-screen widget renders from.
///
/// One object → one JSON string → one shared key. The native widgets (iOS
/// SwiftUI + Android RemoteViews) decode exactly this shape.
class HomeWidgetPayload {
  const HomeWidgetPayload({
    required this.updatedLabel,
    required this.deeplink,
    this.primary,
    this.more = const [],
    this.activeCount = 0,
  });

  /// An all-clear payload: no active nearby hazards. Renders the green
  /// "All clear" state (locked colour: success green).
  const HomeWidgetPayload.allClear({
    required this.updatedLabel,
    required this.deeplink,
  })  : primary = null,
        more = const [],
        activeCount = 0;

  /// e.g. "Updated 9:42 am".
  final String updatedLabel;

  /// URI opened when the widget is tapped. Always opens the app; a widget never
  /// fires SOS directly (locked rule 3).
  final String deeplink;

  /// The single highest-severity nearby hazard, or null when all clear.
  final HomeWidgetAlert? primary;

  /// Additional hazards for the medium/large sizes (primary excluded).
  final List<HomeWidgetAlert> more;

  /// Total count of active nearby hazards (drives the "+N more" affordance).
  final int activeCount;

  bool get isAllClear => primary == null;

  Map<String, dynamic> toJson() => {
        'state': isAllClear ? 'all_clear' : 'alert',
        'updatedLabel': updatedLabel,
        // Stamped at push time so the widget can render a live relative
        // "Checked X min ago" on every timeline refresh.
        'updatedAtMillis': DateTime.now().millisecondsSinceEpoch,
        'deeplink': deeplink,
        'activeCount': activeCount,
        if (primary != null) 'primary': primary!.toJson(),
        'more': more.map((a) => a.toJson()).toList(),
      };
}
