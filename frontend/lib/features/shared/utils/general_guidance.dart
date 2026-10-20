/// ALRT's general guidance for an official alert whose agency published no
/// instructions (product owner, 16 Oct 2026: "I need some kind of advice,
/// generic: if you are travelling around the area, reconsider your route
/// if required; check official sources for updates"). Mirrors the backend
/// alert template library (alert_template_seed.util.ts) so the app shows
/// the same lines whether or not a template is published on the server.
///
/// Voice: "Consider ...", or a plain safety statement. Never an
/// instruction, never a claim about the agency, never a phone number.
/// The What to do block labels these as general guidance from ALRT.
abstract final class GeneralGuidance {
  static const _checkSource = 'Check official sources for updates.';

  /// Lines for an alert, by its title and category names (own, then
  /// parent). Always returns at least the check-official-sources line.
  static List<String> forAlert({
    final String? title,
    final String? categoryName,
    final String? parentCategoryName,
  }) {
    final t = (title ?? '').toLowerCase();
    final names = [categoryName, parentCategoryName]
        .map((n) => (n ?? '').toLowerCase())
        .join(' ');
    final all = '$t $names';

    if (_any(all, [
      'bushfire', 'grass fire', 'grassfire', 'burning', 'burn off',
      'burn-off', 'hazard reduction', 'smoke',
    ])) {
      return const [
        'Smoke can travel a long way from a fire. If you can smell smoke, '
            'consider keeping windows and doors closed.',
        'Any official warning for this fire takes priority over this.',
        _checkSource,
      ];
    }
    if (_any(all, ['flood', 'storm', 'cyclone', 'rain'])) {
      return const [
        'Driving through flood water is dangerous. Consider your route '
            'before driving.',
        'Consider whether the affected area overlaps your travel or '
            'outdoor plans.',
        _checkSource,
      ];
    }
    if (_any(all, ['crash', 'traffic', 'transport', 'road', 'rail', 'bus', 'closure'])) {
      return const [
        'If you are travelling around the area, consider your route and '
            'allow extra time.',
        _checkSource,
      ];
    }
    if (_any(all, ['health', 'air', 'outbreak', 'pollen'])) {
      return const [
        'Consider checking the health authority\'s advice for the area, '
            'including for anyone in your care.',
        _checkSource,
      ];
    }
    if (_any(all, ['police', 'security', 'crime', 'alarm', 'siege'])) {
      return const [
        'Consider avoiding the area until police say it is clear. Any '
            'directions from police take priority.',
        _checkSource,
      ];
    }
    if (_any(all, ['utilit', 'power', 'outage', 'water', 'gas', 'telecom'])) {
      return const [
        'Consider checking the provider\'s service updates and your backup '
            'arrangements for the affected service.',
        _checkSource,
      ];
    }
    if (_any(all, ['community', 'info', 'event'])) {
      return const [
        'Consider checking with the named service or organiser before '
            'changing your plans.',
        _checkSource,
      ];
    }
    return const [
      'Consider whether the affected place is part of your plans today.',
      _checkSource,
    ];
  }

  /// A needle matches at the start of a word only, so "rain" does not
  /// match "train", "air" does not match "repair" and "road" does not
  /// match "Broadmeadows"; "utilit" still matches "utilities" and "info"
  /// still matches "information".
  static bool _any(final String haystack, final List<String> needles) =>
      needles.any(
        (n) => RegExp('\\b${RegExp.escape(n)}').hasMatch(haystack),
      );
}
