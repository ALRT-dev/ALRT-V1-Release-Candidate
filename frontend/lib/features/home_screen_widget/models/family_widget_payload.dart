/// One family circle as the home-screen widget draws it: its name, the
/// rendered icon file, and whether it is the circle open in the app.
class FamilyWidgetGroup {
  const FamilyWidgetGroup({
    required this.circleId,
    required this.name,
    required this.isCurrent,
    this.iconPath,
  });

  final String circleId;
  final String name;

  /// True for the circle open in the app.
  final bool isCurrent;

  /// Absolute path to the PNG rendered by FamilyGroupIconRenderer. Null
  /// when the render failed, in which case the native side skips the icon
  /// rather than drawing a blank.
  final String? iconPath;

  Map<String, dynamic> toJson() => {
    'circleId': circleId,
    'name': name,
    'isCurrent': isCurrent,
    if (iconPath != null) 'iconPath': iconPath,
  };
}

/// What one circle row says. Ordered by priority: a live SOS first, then a
/// check-in someone is waiting on from me, then asks I am waiting on,
/// then the ordinary state.
enum FamilyWidgetRowKind {
  sosMine('sos_mine', 0),
  sosOther('sos_other', 1),
  checkInRequested('check_in_requested', 2),
  waitingForResponses('waiting', 3),
  ok('ok', 4);

  const FamilyWidgetRowKind(this.wire, this.priority);
  final String wire;
  final int priority;
}

/// One circle row on the widget: the circle's name, one status line, and
/// the deep link the row opens. A row never carries a member's name, a
/// location or a safety-profile detail: the home screen is a shared,
/// glanceable surface.
class FamilyWidgetRow {
  const FamilyWidgetRow({
    required this.circleId,
    required this.name,
    required this.kind,
    required this.headline,
    required this.sub,
    required this.deeplink,
    this.isCurrent = false,
    this.iconPath,
  });

  final String circleId;
  final String name;
  final FamilyWidgetRowKind kind;

  /// e.g. "Your SOS is active", "Check-in requested", "No pending requests".
  final String headline;

  /// e.g. "Tap to open it", "2 requests · tap to check in", "3 of 4 checked in today".
  final String sub;
  final String deeplink;
  final bool isCurrent;
  final String? iconPath;

  FamilyWidgetRow withIcon(final String? path) => FamilyWidgetRow(
    circleId: circleId,
    name: name,
    kind: kind,
    headline: headline,
    sub: sub,
    deeplink: deeplink,
    isCurrent: isCurrent,
    iconPath: path,
  );

  Map<String, dynamic> toJson() => {
    'circleId': circleId,
    'name': name,
    'kind': kind.wire,
    'headline': headline,
    'sub': sub,
    'deeplink': deeplink,
    'isCurrent': isCurrent,
    if (iconPath != null) 'iconPath': iconPath,
  };
}

/// Payload for the ALRT Family status home-screen widget (version 2).
///
/// A card-level headline and sub-line summarise the most urgent thing
/// across every circle (the compact size shows only these), and one row
/// per circle (up to [maxRows]) says what is going on in each. The
/// native side prints [generatedAt] as "Updated h:mm" and marks the card
/// stale when it is old, because the platform only redraws the last
/// payload it was given.
class FamilyWidgetPayload {
  const FamilyWidgetPayload({
    required this.state,
    required this.headline,
    required this.sub,
    required this.deeplink,
    required this.generatedAt,
    this.circleName,
    this.rows = const <FamilyWidgetRow>[],
    this.moreCircles = 0,
    this.groups = const <FamilyWidgetGroup>[],
  });

  /// One of: `sos`, `check_in_requested`, `waiting`, `ok`, `no_circle`,
  /// `signed_out`.
  final String state;

  /// The card summary, e.g. "Your SOS is active", "2 check-ins requested",
  /// "No pending requests".
  final String headline;

  /// e.g. "Nixons · tap to open", "Across 2 circles", "Set up in the app".
  final String sub;

  /// Deep link opened by the card itself (compact size, or the header).
  /// A tap only ever navigates: it never checks in, shares a location,
  /// acknowledges an SOS or ends one.
  final String deeplink;

  /// When this payload was built (UTC ISO-8601), for the freshness line.
  final DateTime generatedAt;

  /// The circle the summary is about, when there is exactly one.
  final String? circleName;

  /// One row per circle, most urgent first, capped at [maxRows].
  final List<FamilyWidgetRow> rows;

  /// Circles that did not fit; the widget says "+N more circles".
  final int moreCircles;

  /// Kept for the version-1 native readers (icon strip).
  final List<FamilyWidgetGroup> groups;

  /// The most rows the full card fits at the default text size.
  static const maxRows = 4;

  /// A live family SOS is the only critical state: the locked solid red.
  bool get isCritical => state == 'sos';

  Map<String, dynamic> toJson() => {
    'version': 2,
    'state': state,
    'headline': headline,
    'sub': sub,
    'deeplink': deeplink,
    'generatedAt': generatedAt.toUtc().toIso8601String(),
    if (circleName != null) 'circleName': circleName,
    'isCritical': isCritical,
    'rows': rows.map((row) => row.toJson()).toList(),
    'moreCircles': moreCircles,
    'groups': groups.map((group) => group.toJson()).toList(),
  };
}
