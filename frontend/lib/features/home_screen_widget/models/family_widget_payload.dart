/// One family group as the home-screen widget draws it: its name, the
/// rendered icon file, and whether it is the group the headline is about.
class FamilyWidgetGroup {
  const FamilyWidgetGroup({
    required this.circleId,
    required this.name,
    required this.isCurrent,
    this.iconPath,
  });

  final String circleId;
  final String name;

  /// True for the group whose status the headline reports.
  final bool isCurrent;

  /// Absolute path to the PNG rendered by FamilyGroupIconRenderer. Null
  /// when the render failed, in which case the native side skips the slot
  /// rather than drawing a blank.
  final String? iconPath;

  Map<String, dynamic> toJson() => {
        'circleId': circleId,
        'name': name,
        'isCurrent': isCurrent,
        if (iconPath != null) 'iconPath': iconPath,
      };
}

/// Payload for the ALRT Family status home-screen widget.
///
/// One headline + one sub-line about the group in scope, plus the row of
/// group icons, so every group the user is in is visible from the home
/// screen rather than only the one being reported on.
class FamilyWidgetPayload {
  const FamilyWidgetPayload({
    required this.state,
    required this.headline,
    required this.sub,
    required this.deeplink,
    this.circleName,
    this.groups = const <FamilyWidgetGroup>[],
  });

  /// One of: `sos`, `safe`, `partial`, `no_circle`.
  final String state;

  /// e.g. "Mum needs help", "Everyone's safe", "2 of 4 checked in".
  final String headline;

  /// e.g. "Kinglake West · just now", "Updated 9:42 am", "Set up in the app".
  final String sub;

  /// Deep link opened on tap. A live family SOS opens the SOS receiver; other
  /// states open the Family tab. A tap never triggers or resolves an SOS.
  final String deeplink;

  /// The circle's name, shown as the kicker when present.
  final String? circleName;

  /// The user's groups, the one in scope first, capped at [maxGroups].
  final List<FamilyWidgetGroup> groups;

  /// The most icons a small widget card fits without them shrinking past
  /// recognisable.
  static const maxGroups = 4;

  /// A live family SOS is the only critical state → the locked solid red.
  bool get isCritical => state == 'sos';

  Map<String, dynamic> toJson() => {
        'state': state,
        'headline': headline,
        'sub': sub,
        'deeplink': deeplink,
        if (circleName != null) 'circleName': circleName,
        'isCritical': isCritical,
        'groups': groups.map((group) => group.toJson()).toList(),
      };
}
