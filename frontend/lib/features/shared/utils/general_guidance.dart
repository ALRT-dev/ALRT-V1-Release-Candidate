/// ALRT's general guidance for an official alert whose agency published no
/// instructions (product owner, 16 Oct 2026: "I need some kind of advice,
/// generic: if you are travelling around the area, reconsider your route
/// if required; check official sources for updates"). Mirrors the backend
/// alert template library (alert_template_seed.util.ts) so the app shows
/// the same lines whether or not a template is published on the server.
///
/// Voice: direct safety statements. One clear action per line. No hedging
/// phrases, no 'is a good idea' tails.
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
        'If smoke is affecting you, keep windows and doors closed.',
        'Limit time outside if smoke is making breathing uncomfortable.',
        'Check official updates because conditions can change quickly.',
      ];
    }
    if (_any(all, ['earthquake', 'tremor', 'seismic'])) {
      return const [
        'Move away from buildings, power lines, and anything that could fall.',
        'Drop, cover, and hold on if shaking continues.',
        'Check official updates — aftershocks are common after a significant quake.',
      ];
    }
    // Tsunami must be checked before flood so 'tsunami' does not fall into the flood bucket.
    if (_any(all, ['tsunami', 'tidal wave', 'wave warning'])) {
      return const [
        'Move immediately to high ground or inland — do not wait for official orders.',
        'Stay away from the coast, rivers, and low-lying areas until the all-clear.',
        'Check official updates — a tsunami can arrive as multiple waves over hours.',
      ];
    }
    if (_any(all, ['flood', 'storm', 'cyclone', 'rain'])) {
      return const [
        'Do not drive through flood water or onto roads covered by water.',
        'Reconsider travel through the area and allow extra time.',
        'Check official updates before leaving or changing your route.',
      ];
    }
    if (_any(all, ['crash', 'traffic', 'transport', 'road', 'rail', 'bus', 'closure'])) {
      return const [
        'Expect delays and reconsider your route around the affected area.',
        'Allow extra travel time or delay your trip if needed.',
        'Check official traffic or transport updates before leaving.',
      ];
    }
    if (_any(all, ['heat', 'heatwave', 'extreme heat', 'hot'])) {
      return const [
        'Stay in a cool place during the hottest part of the day (usually 11 am to 3 pm).',
        'Drink water regularly — do not wait until you are thirsty.',
        'Check on older neighbours and anyone who may struggle in the heat.',
      ];
    }
    if (_any(all, ['frost', 'cold snap', 'snow', 'ice', 'freezing'])) {
      return const [
        'Allow extra time for icy roads — bridges and overpasses freeze first.',
        'Check on older people nearby who may be struggling to keep warm.',
        'Keep movement warm — if going outside, dress in layers.',
      ];
    }
    if (_any(all, ['snake', 'shark', 'crocodile', 'animal', 'wildlife', 'jellyfish'])) {
      return const [
        'Stay well back and do not approach — most bites happen when animals are cornered.',
        'Keep children and pets close and on a lead near the affected area.',
        'Check official advice before using the beach, water, or bushland nearby.',
      ];
    }
    if (_any(all, ['storm surge', 'coastal', 'surf', 'swell', 'rip', 'ocean hazard'])) {
      return const [
        'Stay away from beaches, rock platforms, and coastal paths.',
        'Do not enter the water — conditions can change without warning.',
        'Check official surf and coastal updates before returning.',
      ];
    }
    if (_any(all, ['health', 'air', 'outbreak', 'pollen'])) {
      return const [
        'Follow any specific advice in this alert for your situation.',
        'Limit outdoor exposure if the alert relates to air quality or airborne health risk.',
        'Check official sources for updates — health advice can change quickly.',
      ];
    }
    if (_any(all, ['police', 'security', 'crime', 'alarm', 'siege'])) {
      return const [
        'Avoid the area until police say it is clear.',
        'Follow any directions from police or emergency services.',
        'Check official updates for changes in the affected area.',
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
        'Check with the organiser or service before changing your plans.',
        'Reconfirm venue, route or timing before you leave.',
        'Check official updates for any new instructions.',
      ];
    }
    return const [
      'Check whether the affected place is part of your plans today.',
      'Reconsider travel or outdoor plans if the area may affect you.',
      'Check official sources for updates.',
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
