import 'package:hazard_app/features/profile/models/for_you_library.dart';

/// ALRT's on-device "What to do" content: how urgent a source instruction is,
/// and what ALRT suggests when the agency published no instruction at all.
///
/// Zero AI. Curated, reviewed content (owner-approved Aug–Oct 2026). All of it
/// lives on-device, matching the privacy-by-design Safety Profile pattern.
///
/// Two jobs:
/// 1. `priorityTier` ranks an agency instruction so the life-safety ones
///    always surface first (the "What to do" cap is 3).
/// 2. `considerRows` gives the user something genuinely useful when the
///    agency published no directive — the old "the source has not published
///    further details" dead-end is gone.
///
/// Extending this is a content edit, not a logic change: add a word to a tier
/// list, or add a row to a hazard's `considerRows`, and it just works.
abstract final class AlertGuidanceLibrary {
  /// The hazard bucket an alert belongs to. Reuses the same matching that
  /// drives the For You card, so For You and Consider never disagree on what
  /// a hazard is. Returns null when no guidance applies.
  static String? bucketFor({
    final String? categoryName,
    final String? parentCategoryName,
    final String? title,
  }) =>
      ForYouLibrary.bucketFor(
        categoryName: categoryName,
        parentCategoryName: parentCategoryName,
        title: title,
      );

  /// How urgent an agency instruction is. 1 = life-safety (always pinned),
  /// 2 = prepare/protect, 3 = monitor/info (folds behind "Show all").
  ///
  /// Words are the source's own and are never changed — this only decides
  /// display order. Stable within a tier (source order preserved).
  static int priorityTier(final String action) {
    final a = action.toLowerCase();
    if (_tier1.any(a.contains)) return 1;
    if (_tier2.any(a.contains)) return 2;
    return 3;
  }

  /// Ranks a list of agency instructions Tier 1 → 3, keeping the source's own
  /// order within each tier.
  static List<String> rankActions(final List<String> actions) {
    final indexed = <(String, int)>[
      for (final (i, a) in actions.indexed)
        (a.trim(), i),
    ]..removeWhere((e) => e.$1.isEmpty);
    indexed.sort((x, y) {
      final t = priorityTier(x.$1).compareTo(priorityTier(y.$1));
      return t != 0 ? t : x.$2.compareTo(y.$2);
    });
    return indexed.map((e) => e.$1).toList();
  }

  /// The "Consider" guidance for a hazard, in source-agnostic, calm, actionable
  /// language. Shown only when the agency published no directive. Labelled as
  /// ALRT's general guidance, never as the agency's instruction.
  static List<String> considerRows(final String? bucket) {
    return _consider[bucket] ?? const <String>[];
  }

  static const List<String> _tier1 = [
    'leave now',
    'leave immediately',
    'evacuate',
    'act immediately',
    'act now',
    'do not drive through floodwater',
    'don\'t drive through floodwater',
    'move to higher ground',
    'go now',
    'danger',
    'life threatening',
    'immediately',
    'call emergency',
    'shelter now',
  ];

  static const List<String> _tier2 = [
    'take shelter',
    'shelter',
    'stay inside',
    'stay indoors',
    'keep clear',
    'keep away',
    'move valuables',
    'move vehicles',
    'prepare to leave',
    'above floor level',
    'get ready',
    'close windows',
    'turn off',
    'grab bag',
  ];

  static const Map<String, List<String>> _consider = {
    'bushfire': [
      'Consider a grab bag ready with water, snacks, a torch and a phone charger.',
      'Check your bushfire emergency plan is up to date and everyone knows it.',
      'Know your safest route out and where you\'ll go.',
      'Keep your phone charged and listen to official updates.',
      'If you need help leaving, arrange it before the fire gets close.',
    ],
    'grass_fire': [
      'Consider a grab bag ready with water, snacks, a torch and a phone charger.',
      'Know your safest route out and where you\'ll go.',
      'Keep your phone charged and listen to official updates.',
      'Grass fires move very fast — leave at the first sign of smoke.',
    ],
    'flood': [
      'Consider moving valuables and important documents above floor level.',
      'Know your safest route out and where the high ground is.',
      'Keep a grab bag ready — water, snacks, torch, charger, medications.',
      'Don\'t walk or drive through floodwater, even if it looks shallow.',
      'Keep your phone charged and monitor official updates.',
    ],
    'cyclone': [
      'Consider securing loose items outside before the wind arrives.',
      'Check your emergency kit — torches, batteries, water, first aid.',
      'Know your nearest shelter or safest room (away from windows).',
      'Charge your phone and keep a battery bank ready for power outages.',
      'Plan indoor activities for the worst of the weather.',
    ],
    'severe_weather': [
      'Consider securing loose items outside before the storm arrives.',
      'Check your emergency kit — torches, batteries, water, first aid.',
      'Stay clear of trees, creeks and the coast during the warning.',
      'Charge your phone and keep a battery bank ready for power outages.',
    ],
    'heatwave': [
      'Consider staying in the coolest room and drinking regularly.',
      'Check on older or less mobile neighbours and relatives.',
      'Never leave children or pets in a parked car.',
      'Plan outdoor activities for early morning or late evening.',
      'Keep a supply of water and fans available.',
    ],
    'earthquake': [
      'Consider a grab bag ready — water, snacks, torch, charger, first aid.',
      'Agree a meeting point with your family in case you\'re separated.',
      'Expect aftershocks; stay away from brick walls and tall structures.',
      'Keep your phone charged and monitor official updates.',
    ],
    'tsunami': [
      'Consider a grab bag ready — water, snacks, torch, charger, first aid.',
      'Agree a meeting point with your family in case you\'re separated.',
      'If you are near the coast, know your route to higher ground.',
      'Keep your phone charged and monitor official updates.',
    ],
    'smoke': [
      'Consider staying indoors with windows closed.',
      'Limit outdoor exercise while smoke is nearby.',
      'If you must go out, use a properly fitted P2 or N95 mask.',
      'Keep medication on hand if you have a heart or lung condition.',
    ],
    'air_quality': [
      'Consider staying indoors with windows closed.',
      'Limit outdoor exercise while air quality is poor.',
      'If you must go out, use a properly fitted P2 or N95 mask.',
      'Keep medication on hand if you have a heart or lung condition.',
      'Check the air quality readings before outdoor plans.',
    ],
    'haze': [
      'Consider staying indoors with windows closed.',
      'Limit outdoor exercise while visibility is low.',
      'If you must go out, use a properly fitted P2 or N95 mask.',
      'Keep medication on hand if you have a heart or lung condition.',
    ],
    'chemical': [
      'Consider going indoors, shutting windows and turning off air intake.',
      'Stay in one sealed room and wait for official advice.',
      'Keep clear of the affected area and any cordons.',
      'Keep medication with you and seek help early if symptoms start.',
    ],
    'snakes': [
      'Consider sticking to clear paths and wearing solid shoes in long grass.',
      'Keep children close and teach them not to touch wildlife.',
      'Don\'t try to move a snake — give it space to move on.',
      'Keep dogs leashed and cats in until the hazard clears.',
    ],
    'wildlife': [
      'Consider sticking to clear paths and wearing solid shoes.',
      'Keep children close and teach them not to touch wildlife.',
      'Don\'t try to move an animal — give it space.',
      'Keep dogs leashed and cats in until the hazard clears.',
    ],
    'rough_surf': [
      'Consider enjoying the beach from above the waterline during the warning.',
      'Keep children out of the water and away from the shoreline edge.',
      'If you enter the water, swim between the red and yellow flags.',
      'Stay out of the water entirely if you have a heart or lung condition.',
    ],
    'shark': [
      'Consider enjoying the beach from above the waterline during the warning.',
      'Keep children out of the water and away from the shoreline edge.',
      'Stay out of the water entirely if you have a heart or lung condition.',
      'Check flags and signs before entering the water.',
    ],
    // Global / GDACS — region-agnostic. Must NOT use the Australia-specific
    // "Visiting Australia" line or "Australian earthquakes are usually small".
    'global': [
      'Consider a grab bag ready — water, snacks, torch, charger, first aid.',
      'Agree a meeting point with family in case you\'re separated.',
      'Keep your phone charged and monitor official updates.',
      'Check on neighbours, especially older or less mobile people.',
      'Follow local emergency instructions as they are published.',
    ],
    'crocodile': [
      'Consider staying well back from the water\'s edge, jetties and boat ramps.',
      'Keep children and pets away from the edge.',
      'Obey local signs and keep out of the water.',
      'Don\'t feed or approach crocodiles.',
    ],
    'tornado': [
      'Consider moving to an inner room or the lowest floor, away from windows.',
      'Keep children close and move together to shelter.',
      'Charge your phone and keep a torch handy.',
      'Stay in shelter until officials say it is over.',
    ],
    'landslide': [
      'Consider staying away from steep slopes, cuttings and slip debris.',
      'Know your route out and choose flatter alternatives.',
      'Keep children and pets away from fresh slips.',
      'Monitor local advice and road closures.',
    ],
    'cold_snap': [
      'Consider heating the room you live in and layering up.',
      'Keep medication close and check on older or less mobile people.',
      'Never leave children or pets in a cold car.',
      'Allow extra travel time for icy roads and paths.',
    ],
    'water_quality': [
      'Consider using boiled or bottled water for drinking and brushing teeth.',
      'Follow the alert\'s exact advice until the agency says the water is fine.',
      'Keep pets and stock away from affected water.',
      'If collecting bottled water is hard, ask a neighbour or council for help early.',
    ],
  };

  /// Extracts a few headline facts from the source's own description — only
  /// numbers and specifics the agency actually wrote (distance, time window,
  /// wind, size, water level). Never computed, never invented. Used for the
  /// optional "Key facts" strip so the reader can scan the essentials fast.
  /// Returns up to [maxFacts] (label, value) pairs.
  static List<(String, String)> keyFacts(final String? description) {
    if (description == null) return const [];
    final d = description.toLowerCase();
    final out = <(String, String)>[];
    void add(String label, String? value) {
      final v = (value ?? '').trim();
      if (v.isEmpty) return;
      if (out.any((e) => e.$2 == v)) return;
      out.add((label, v));
    }

    final km = RegExp(r'(up to |within |about )?(\d+(?:\.\d+)?)\s*(km|kilometres?|kilometers?)')
        .allMatches(d)
        .map((m) => m.group(0))
        .toList();
    if (km.isNotEmpty) add('Distance', km.first);

    final time = RegExp(r'(within|in|over the next)\s+\d+\s*(hours?|minutes?|days?)')
        .allMatches(d)
        .map((m) => m.group(0))
        .toList();
    if (time.isNotEmpty) add('Timeframe', time.first);

    final wind = RegExp(r'\d+\s*km/h').allMatches(d).map((m) => m.group(0)).toList();
    if (wind.isNotEmpty) add('Wind', wind.first);

    final ha = RegExp(r'\d+(?:,\d+)*\s*hectares?').allMatches(d).map((m) => m.group(0)).toList();
    if (ha.isNotEmpty) add('Size', ha.first);

    final level = RegExp(r'(minor|moderate|major)\s*flood\s*(level|peak)').allMatches(d)
        .map((m) => m.group(0))
        .toList();
    if (level.isNotEmpty) add('Water', level.first);

    return out.take(maxFacts).toList();
  }

  /// Maximum headline facts shown in the Key facts strip.
  static const int maxFacts = 4;
}
