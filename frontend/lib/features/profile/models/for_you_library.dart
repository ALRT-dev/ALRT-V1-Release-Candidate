import 'package:hazard_app/features/profile/models/safety_cohort.dart';

/// The Standing For You Library — rows carried VERBATIM from Sarah's
/// reviewed library document (approved Aug 2026). Zero AI at generation and
/// render. Hazards on the Empty-by-design register (police operation, crash,
/// road closure, events) deliberately have no rows: no genuine cohort
/// difference means no line, and a missing row shows nothing — never a
/// substitute from another hazard.
///
/// Voice (product owner, hedge rule): every line ends on what MAY help,
/// never an instruction ("... may help", not "... is advisable" or "... is
/// a good idea"). These bundled rows are only the fallback for alerts that
/// carry no published template rows; published rows win.
abstract final class ForYouLibrary {
  /// Coarse bucket for an alert. The title is checked for specific hazards
  /// first (cyclone, heatwave, snakes...), then the (parent) category name
  /// as the fallback. Returns null when no guidance applies.
  /// Most specific wins: the alert title, then its own category, then the
  /// parent category.
  ///
  /// Passing only the parent was quietly losing the point of this library.
  /// Every hazard sits under a broad parent ("Weather & Environment"), so
  /// a Flood alert matched severe_weather and a Bushfire alert matched
  /// severe_weather, even though both have their own reviewed guidance.
  /// Unless the title happened to say the word, the reader got generic
  /// advice for a specific emergency.
  static String? bucketFor({
    final String? categoryName,
    final String? title,
    final String? parentCategoryName,
  }) {
    final t = (title ?? '').toLowerCase();
    // Hazards with NO reviewed rows, checked first so a broad category
    // never lends them another hazard's lines. A gas smell reported under
    // Utilities was showing power-outage lines, and "gas leak" used to
    // reach the chemical rows, whose shelter-indoors advice is the opposite
    // of what gas networks advise (phone review, 14 Oct 2026).
    if (_noGuidanceKeywords.any(t.contains)) return null;
    for (final entry in _titleKeywords) {
      if (entry.$1.any(t.contains)) return entry.$2;
    }
    // The alert's own category, then the parent it hangs under.
    for (final candidate in [categoryName, parentCategoryName]) {
      final bucket = _bucketForName(candidate);
      if (bucket != null) return bucket;
    }
    return null;
  }

  static String? _bucketForName(final String? categoryName) {
    final name = (categoryName ?? '').toLowerCase();
    if (name.isEmpty) return null;
    if (_noGuidanceKeywords.any(name.contains)) return null;
    // The specific hazards first: these are subcategory names, and each
    // has its own reviewed rows.
    for (final entry in _titleKeywords) {
      if (entry.$1.any(name.contains)) return entry.$2;
    }
    // A burning car is a traffic incident, not a bushfire: it has no
    // reviewed guidance, so it shows nothing (never another hazard's).
    if (name.contains('vehicle')) return null;
    // Planned and prescribed burns matter to a profile through their smoke.
    if (name.contains('burn')) return 'smoke';
    if (name.contains('fire') && name.contains('smoke')) return 'smoke';
    if (name.contains('fire')) return 'bushfire';
    if (name.contains('smoke')) return 'smoke';
    if (name.contains('flood')) return 'flood';
    if (name.contains('weather') || name.contains('environment')) {
      return 'severe_weather';
    }
    if (name.contains('air')) return 'air_quality';
    if (name.contains('health')) return 'public_health';
    // "Utilities" alone is not an outage (gas, water mains, comms are all
    // in it): outage rows need the title or category to say outage.
    if (name.contains('power') || name.contains('electric')) {
      return 'utility_outage';
    }
    if (name.contains('chemical')) return 'chemical';
    return null;
  }

  /// Hazards that deliberately show no For You lines.
  static const _noGuidanceKeywords = <String>[
    'smell of gas',
    'gas smell',
    'gas leak',
    'gas main',
    'water main',
    'burst main',
  ];

  /// Title keywords checked most-specific-first.
  static const _titleKeywords = <(List<String>, String)>[
    (['tsunami'], 'tsunami'),
    (['shark'], 'shark'),
    (['crocodile'], 'crocodile'),
    (['landslide', 'mudslide', 'rockfall'], 'landslide'),
    (['tornado'], 'tornado'),
    (['cyclone'], 'cyclone'),
    (['earthquake', 'tremor', 'aftershock'], 'earthquake'),
    (['grass fire', 'grassfire'], 'grass_fire'),
    (['bushfire', 'bush fire'], 'bushfire'),
    (
      ['structure fire', 'structural fire', 'building fire', 'house fire'],
      'structure_fire',
    ),
    (['dust storm', 'dust'], 'dust_storm'),
    (['heatwave', 'extreme heat', 'heat wave'], 'heatwave'),
    (['cold snap', 'black ice', 'frost', 'extreme cold'], 'cold_snap'),
    (['pollen', 'thunderstorm asthma'], 'pollen'),
    (['haze'], 'haze'),
    (['boil water', 'water quality', 'algae', 'contaminat'], 'water_quality'),
    (['snake'], 'snakes'),
    (['wildlife', 'animal'], 'wildlife'),
    (['surf', 'rip current', 'king tide', 'coastal hazard'], 'rough_surf'),
    (['fuel'], 'fuel_supply'),
    (['evacuation centre', 'evacuation center'], 'evac_centre'),
    (['hospital', 'ambulance'], 'health_capacity'),
    (['school holiday'], 'school_holidays'),
    (['power outage', 'blackout', 'outage'], 'utility_outage'),
    (['chemical', 'hazmat'], 'chemical'),
    (['smoke'], 'smoke'),
    (['flood'], 'flood'),
    (['storm'], 'severe_weather'),
    (['air quality'], 'air_quality'),
    (['unrest', 'protest', 'riot'], 'civil_unrest'),
    (['outbreak', 'measles', 'disease'], 'public_health'),
  ];

  /// Region-agnostic cohort guidance for global/humanitarian alerts (GDACS
  /// and similar). Used when [isGlobal] is true on the For You card so the
  /// Australia-specific [rows] wording is not shown for overseas events.
  /// One entry per [SafetyCohort]; never empty (the For You card hides
  /// itself when no entry exists for the viewer's cohorts).
  static const Map<SafetyCohort, String> globalRows = {
    SafetyCohort.older:
        'Older adults are often disproportionately affected by major disasters. Following official guidance early and letting someone know your plans may help.',
    SafetyCohort.kids:
        'Children can be unsettled by distant disasters. Keeping routines calm and explaining the event simply may help.',
    SafetyCohort.mobility:
        'Major disasters can disrupt accessible transport and infrastructure. Checking that your usual routes and services are unaffected may help.',
    SafetyCohort.medical:
        'Global disasters can affect international supply chains for medicines and medical equipment. Keeping a reasonable stock of essentials may help.',
    SafetyCohort.deaf:
        'Emergency broadcasts during major events may be audio-only. Keeping vibration alerts on and checking text sources may help.',
    SafetyCohort.vision:
        'Humanitarian events can produce misinformation online. Checking official sources directly rather than shared images or posts may help.',
    SafetyCohort.visitor:
        'If you are travelling near the affected area, checking with your accommodation and registering with your government travel service may help.',
    SafetyCohort.worker:
        'If your work involves the affected region, checking with your employer on any supply or travel impacts may help.',
    SafetyCohort.pets:
        'Major global events rarely affect pets directly, but disruption to supply chains can affect pet food and medication. Keeping a small stock may help.',
  };

  /// hazard bucket -> cohort -> line (verbatim reviewed wording).
  static const Map<String, Map<SafetyCohort, String>> rows = {
    'bushfire': {
      SafetyCohort.older:
          'Ember attacks and fast changes are hardest on people who move more slowly. Deciding early whether to leave, rather than waiting to see may help.',
      SafetyCohort.kids:
          'Children breathe faster and worry spreads quickly. Packing early, keeping kids indoors and explaining the plan calmly may help.',
      SafetyCohort.mobility:
          'Evacuating with mobility needs takes longer than warnings allow for. Leaving well before an Emergency Warning, and telling someone your route may help.',
      SafetyCohort.medical:
          'If a medical condition applies, smoke and exertion can both make it worse. Keeping medication within reach and avoiding heavy work like yard clearing may help.',
      SafetyCohort.deaf:
          'Sirens and doorknocks may not reach you. Keeping strong vibration and screen flash alerts on, and asking a neighbour to check in may help.',
      SafetyCohort.vision:
          'Smoke lowers visibility for everyone, and unfamiliar evacuation routes are harder without sight. Arranging transport with a sighted person early may help.',
      SafetyCohort.visitor:
          'Australian bushfires move faster than most visitors expect. Following the official warning level for this area and leaving early if advised may help.',
      SafetyCohort.worker:
          'If you are required on site, confirming your workplace\'s fire plan and a route in and out before travelling may help.',
      SafetyCohort.pets:
          'Animals are easier to find and load before smoke arrives. Knowing where carriers and leads are now may save time later.',
    },
    'grass_fire': {
      SafetyCohort.older:
          'Grass fires move faster than a person can walk. Leaving early rather than staying to defend, and keeping your phone with you may help.',
      SafetyCohort.kids:
          'Grass fires can cut roads in minutes. Keeping children close and not driving toward smoke, even for pickup may help.',
      SafetyCohort.mobility:
          'Grass fires give little warning time. Leaving at the first sign of smoke rather than waiting for an official warning may help.',
      SafetyCohort.medical:
          'Even brief smoke can trigger symptoms, and a rushed move is a strain in itself. Keeping medication handy and preparing essentials early may help.',
      SafetyCohort.deaf:
          'Grass fires spread too fast for doorknocking. Keeping vibration alerts on and checking this app when you see any smoke may help.',
      SafetyCohort.vision:
          'Fast moving smoke changes conditions quickly. Asking someone nearby to describe what they can see, and leaving early together may help.',
      SafetyCohort.visitor:
          'Grass fires are common in Australian summers and move extremely fast. Following local directions rather than stopping to watch may help.',
      SafetyCohort.worker:
          'If working outdoors nearby, moving vehicles and machinery off dry grass and agreeing a trigger point to stop work may help.',
      SafetyCohort.pets:
          'Grass fires leave no time to search for a hiding pet. Bringing animals in at the first sign of smoke, with carriers ready may help.',
    },
    'flood': {
      SafetyCohort.older:
          'Flood evacuations are best done early and in daylight. Moving medicines, glasses and essentials above floor level now may help.',
      SafetyCohort.kids:
          'Floodwater fascinates kids and hides currents and sharp objects. Keeping children away from all water, even shallow water over drains may help.',
      SafetyCohort.mobility:
          'Floodwater makes surfaces impassable for wheels and unsteady feet. Arranging to move before water is anywhere near, not during may help.',
      SafetyCohort.medical:
          'Keeping medication dry in a sealed bag you can grab may help, and asking for help with heavy work like sandbags rather than doing it alone.',
      SafetyCohort.deaf:
          'Rising water at night gives little visual warning. Keeping vibration alerts on while you sleep, and checking levels before bed may help.',
      SafetyCohort.vision:
          'Floodwater hides depth and edges, even on familiar streets. Arranging a sighted companion or transport before water rises, rather than after may help.',
      SafetyCohort.visitor:
          'Emergency services advise against driving through floodwater, whatever your car handles at home. Vehicles are involved in many flood deaths.',
      SafetyCohort.worker:
          'If travel to work is essential, checking closures before leaving and agreeing an alternative with your employer may help. Not driving through water over a road may help.',
      SafetyCohort.pets:
          'Floodwater strands animals quickly. Moving stock to higher paddocks early is standing advice, and pets travelling in carriers rather than loose in vehicles may help.',
    },
    'cyclone': {
      SafetyCohort.older:
          'Cyclone preparation is heavy work best done early. Asking for help securing loose items now, and knowing your nearest shelter may help.',
      SafetyCohort.kids:
          'The noise of a cyclone frightens children. Setting up your shelter room with games, snacks and torches before the wind arrives may help.',
      SafetyCohort.mobility:
          'Sheltering and evacuating are harder in high wind. Registering early with local emergency services if you may need evacuation help may help.',
      SafetyCohort.medical:
          'Power loss can affect medical equipment and routines. Charging devices, stocking medication and planning for outages before the cyclone arrives may help.',
      SafetyCohort.deaf:
          'Warning changes come fast as a cyclone approaches. Keeping vibration alerts on, and a torch handy for lip reading if power fails may help.',
      SafetyCohort.vision:
          'Sheltering changes room layouts. Walking your shelter space while conditions are calm, and keeping aids and a torch within reach may help.',
      SafetyCohort.visitor:
          'Cyclone warnings here use categories 1 to 5. Following your accommodation\'s instructions and staying inside through the eye of the storm may help.',
      SafetyCohort.worker:
          'If required to work through the warning, agreeing a stand down trigger with your employer before conditions deteriorate may help.',
      SafetyCohort.pets:
          'Secure or shelter animals before winds arrive. Bringing pets indoors with water, and moving stock away from trees and fences, is standing preparation advice.',
    },
    'smoke': {
      SafetyCohort.older:
          'Smoke settles hardest on older lungs. Staying indoors with windows shut, and cooling the house rather than airing it may help.',
      SafetyCohort.kids:
          'Smoke affects small lungs first. Keeping windows shut and staying indoors may help while smoke is nearby.',
      SafetyCohort.mobility:
          'If leaving the area is a big effort, one well sealed room beats a late move. Choosing your cleanest room and keeping doors shut may help.',
      SafetyCohort.medical:
          'If a medical condition applies, having medication on hand and limiting exertion may help while smoke is nearby.',
      SafetyCohort.deaf:
          'Smoke can arrive before any visible fire. Keeping vibration and screen flash alerts on while smoke is in your area may help.',
      SafetyCohort.vision:
          'Smoke irritates eyes and flattens what vision remains. Staying indoors and postponing unfamiliar journeys until it clears may help.',
      SafetyCohort.visitor:
          'Bushfire smoke can blanket areas far from any fire. Checking air quality before outdoor plans and keeping windows shut may help.',
      SafetyCohort.worker:
          'If working outdoors, a properly fitted P2 mask and regular indoor breaks may help while smoke is present.',
      SafetyCohort.pets:
          'Smoke affects animals too, especially birds and older pets. Bringing them indoors and limiting exercise while smoke is nearby may help.',
    },
    'chemical': {
      SafetyCohort.older:
          'Chemical incidents usually call for shelter, not evacuation. Going indoors, shutting windows and turning off the aircon may help.',
      SafetyCohort.kids:
          'Children are more affected by fumes. Bringing kids indoors, shutting windows and turning off any air intake may help.',
      SafetyCohort.mobility:
          'Shelter in place is the usual advice here, which works in your favour. Sealing the room you are in and waiting until officials say it is over may help.',
      SafetyCohort.medical:
          'Fumes and stress can both trigger symptoms quickly. Sealing your room, keeping medication with you, and seeking help early if symptoms start may help.',
      SafetyCohort.deaf:
          'Hazmat instructions are often given by loudspeaker. Keeping vibration alerts on and checking this app for the written update that it is over may help.',
      SafetyCohort.vision:
          'Chemical incidents rely on visual cordons and signage. Staying indoors and asking someone to confirm when officials say it is over may help.',
      SafetyCohort.visitor:
          'Australian practice for chemical incidents is shelter in place unless police say leave. Going indoors and following this app\'s updates may help.',
      SafetyCohort.worker:
          'If your site is inside the cordon, following your workplace\'s hazmat procedure and not re-entering until cleared may help.',
      SafetyCohort.pets:
          'Pets shelter with you in a chemical incident. Bringing them indoors now and keeping them in until officials say it is over may help.',
    },
    'severe_weather': {
      SafetyCohort.older:
          'Falls rise sharply in storms and on wet ground. Postponing errands until the weather passes, and charging your phone now may help.',
      SafetyCohort.kids:
          'Storms pass faster when kids are settled. Bringing outdoor toys in, charging devices and planning an indoor afternoon may help.',
      SafetyCohort.mobility:
          'Wet ramps, debris and blocked footpaths outlast the storm. Planning to stay in through the warning period may help.',
      SafetyCohort.medical:
          'Storms can stir pollen and dust sharply, and cleanup is an overexertion trap. Keeping medication close and pacing any heavy work may help.',
      SafetyCohort.deaf:
          'Thunder is the warning most people rely on. Keeping vibration alerts on and an eye on the sky while the warning is active may help.',
      SafetyCohort.vision:
          'Debris can change familiar paths after a storm. Keeping aids charged, and asking a neighbour to check outside routes before heading out may help.',
      SafetyCohort.visitor:
          'Australian storms can be stronger than they look. Staying clear of trees, creeks and the coast during warnings may help.',
      SafetyCohort.worker:
          'If working outdoors or at height, agreeing when work stops before the front arrives may help. Stopping outdoor work when lightning is close may help.',
      SafetyCohort.pets:
          'Pets often bolt in storms. Keeping them indoors with identification, and checking gates and fencing afterwards may help.',
    },
    'air_quality': {
      SafetyCohort.older:
          'Poor air days are hardest on older lungs and hearts. Keeping activity light and staying indoors during the worst hours may help.',
      SafetyCohort.kids:
          'Children take in more air for their size. Moving play indoors and keeping windows shut on poor air days may help.',
      SafetyCohort.mobility:
          'If getting out takes real effort, timing matters more. Planning essential trips for when air quality improves may help.',
      SafetyCohort.medical:
          'Poor air can build symptoms slowly across a day. Following your usual care plan, keeping medication within reach and skipping strenuous activity may help.',
      SafetyCohort.deaf:
          'Air quality changes silently. Checking this app\'s readings morning and evening while this alert is active may help.',
      SafetyCohort.vision:
          'Haze flattens contrast and landmarks. Allowing extra time for travel, or delaying it, may help while visibility is reduced.',
      SafetyCohort.visitor:
          'Air quality here can shift quickly with wind and fire. Checking readings before hikes or runs may help while this alert is active.',
      SafetyCohort.worker:
          'For outdoor work, more frequent breaks and a properly fitted P2 mask may help while air quality remains poor.',
      SafetyCohort.pets:
          'Poor air affects animals too, especially birds and flat faced breeds. Keeping pets indoors and walks short may help.',
    },
    'public_health': {
      SafetyCohort.older:
          'Older adults are usually the first group health alerts apply to. Reading this alert\'s specific advice and acting on it early may help.',
      SafetyCohort.kids:
          'Health alerts often carry specific advice for children. Checking whether schools or childcare are affected may help.',
      SafetyCohort.mobility:
          'If the advice means avoiding certain places, planning accessible alternatives early, before options thin out may help.',
      SafetyCohort.medical:
          'Health alerts can matter more with a medical condition. Following the alert\'s specific guidance alongside your usual care plan may help.',
      SafetyCohort.deaf:
          'Health advice often updates through radio and press conferences. Relying on this app and official websites for written updates may help.',
      SafetyCohort.vision:
          'Maps and signage often carry health advice. The alert text here carries the same advice in full, with key actions first for screen readers.',
      SafetyCohort.visitor:
          'Local health alerts apply to visitors too, and your travel insurer may ask whether you followed them. Reading the specific advice may help.',
      SafetyCohort.worker:
          'If you work with the public, checking whether this alert changes your workplace\'s requirements before your shift may help.',
      SafetyCohort.pets:
          'Some health alerts cover animals too, such as water or algae warnings. Checking whether this one affects pets may help.',
    },
    'civil_unrest': {
      SafetyCohort.older:
          'Crowded, volatile areas are hardest to leave quickly. Avoiding the area entirely until it settles may help.',
      SafetyCohort.kids:
          'Crowds and children separate easily. Avoiding the area with kids, and agreeing a meeting point if you must be nearby may help.',
      SafetyCohort.mobility:
          'Moving against a crowd is the hardest move there is. Staying well clear of the area rather than skirting its edge may help.',
      SafetyCohort.medical:
          'Crowd control agents and stress can both trigger symptoms. Staying upwind and well away, with medication on hand may help.',
      SafetyCohort.deaf:
          'Police move on directions are usually shouted. Keeping visual distance from any crowd and following this app\'s updates may help.',
      SafetyCohort.vision:
          'Crowd situations change too fast to navigate without sight. Avoiding the area completely, and travelling with someone if nearby may help.',
      SafetyCohort.visitor:
          'Steering well clear of protests may help. Involvement can affect visas, and crowd dynamics are hard to read in an unfamiliar city.',
      SafetyCohort.worker:
          'If your workplace is inside the affected area, contacting your employer before travelling in, and using an agreed entrance may help.',
      SafetyCohort.pets:
          'Crowds and noise panic animals. Walking dogs well away from the area until it settles may help.',
    },
    'structure_fire': {
      SafetyCohort.older:
          'Building fires can spread to neighbouring properties. If you are close by, preparing to leave before being told may help.',
      SafetyCohort.kids:
          'Fire trucks draw children toward the scene. Keeping kids indoors and away from windows near a building fire may help.',
      SafetyCohort.mobility:
          'If you are in an affected or neighbouring building, starting your exit early matters most. Not waiting for the situation to worsen may help.',
      SafetyCohort.medical:
          'Structure fires produce heavy, toxic smoke. Staying indoors with windows shut if nearby, and moving calmly with medication if you leave may help.',
      SafetyCohort.deaf:
          'Building alarms are sound first. If you are near the scene, watching for others evacuating and keeping vibration alerts on may help.',
      SafetyCohort.vision:
          'Smoke and fire crews change familiar exits. Asking for guidance early rather than navigating alone may help if you are close.',
      SafetyCohort.visitor:
          'If your hotel or hostel is nearby, following staff instructions, and taking your passport if you evacuate may help.',
      SafetyCohort.worker:
          'If this is near your workplace, expecting cordons around the block and checking access before travelling in may help.',
      SafetyCohort.pets:
          'Smoke and sirens carry further than the cordon. Keeping pets indoors and dog walks away from the scene may help.',
    },
    'utility_outage': {
      SafetyCohort.older:
          'Outages hit lifts, hot water and phones together. Checking your phone\'s charge now and keeping a torch within reach may help.',
      SafetyCohort.kids:
          'Outages unsettle bedtime fast. Finding torches before dark and charging a device for the kids now may help.',
      SafetyCohort.mobility:
          'If lifts or powered doors are part of your route, planning around them before you need them may help while power is out.',
      SafetyCohort.medical:
          'If powered medical equipment or refrigerated medication applies, acting on your backup plan early, before batteries run down may help.',
      SafetyCohort.deaf:
          'Outage updates often come by radio. This app and SMS from your provider are the written channels. Keeping vibration alerts on may help.',
      SafetyCohort.vision:
          'An outage removes the lighting others rely on, not your navigation. Checking on neighbours who may be struggling in the dark may help.',
      SafetyCohort.visitor:
          'Outages can affect card payments and fuel pumps locally. Keeping some cash and a charged phone while the outage lasts may help.',
      SafetyCohort.worker:
          'If your work depends on this utility, confirming with your site before travelling in may help. Restoration estimates in this alert update live.',
      SafetyCohort.pets:
          'Aquariums, heat lamps and electric fences stop with the power. Checking any animal setup that relies on it early may help.',
    },
    'dust_storm': {
      SafetyCohort.older:
          'Dust is hard on lungs and visibility together. Staying indoors with windows shut until the front passes may help.',
      SafetyCohort.kids:
          'Dust storms pass quickly but hit small lungs hard. Keeping children indoors and windows shut until it clears may help.',
      SafetyCohort.mobility:
          'A dust storm outlasts most short trips. Waiting it out indoors rather than pushing through may help.',
      SafetyCohort.medical:
          'Dust can trigger breathing and heart symptoms fast. Staying indoors with medication close until the air clears may help.',
      SafetyCohort.deaf:
          'Dust fronts arrive with almost no sound. Keeping vibration alerts on and checking the horizon before driving may help.',
      SafetyCohort.vision:
          'Dust cuts everyone\'s vision to near zero. Staying indoors, and asking others nearby whether it has passed may help.',
      SafetyCohort.visitor:
          'If a dust storm hits while driving, the local practice is to pull right off the road with lights off. Waiting it out may help.',
      SafetyCohort.worker:
          'Dust ends fine outdoor tasks and driving visibility fast. Pausing work and sealing machinery cabs until it passes may help.',
      SafetyCohort.pets:
          'Dust irritates animals\' eyes and lungs too. Bringing pets in, and giving stock shelter and clean water may help.',
    },
    'pollen': {
      SafetyCohort.older:
          'High pollen days can affect breathing even without a hay fever history. Keeping outdoor time short and windows shut may help.',
      SafetyCohort.kids:
          'Pollen peaks in the morning and early evening. Timing outdoor play around those windows on high pollen days may help.',
      SafetyCohort.mobility:
          'If your routes pass parks or grassland, exposure is higher. Planning trips for after rain, when pollen drops may help.',
      SafetyCohort.medical:
          'High pollen plus a storm can trigger thunderstorm asthma, even with only hay fever. Staying indoors before storm fronts, with medication close may help.',
      SafetyCohort.deaf:
          'Pollen warnings are easy to miss in spoken forecasts. Checking this app\'s alerts on spring storm days may help.',
      SafetyCohort.vision:
          'Itchy, watering eyes make remaining vision harder to use. Keeping windows shut and limiting time outside on peak days may help.',
      SafetyCohort.visitor:
          'Southern Australia\'s spring pollen is severe by world standards. Taking hay fever seriously here, especially before storms may help.',
      SafetyCohort.worker:
          'Mowing, landscaping and outdoor work spike exposure on high pollen days. A mask and shorter stints may help.',
      SafetyCohort.pets:
          'Pets carry pollen inside in their coats. Wiping coats down after walks on high pollen days may help.',
    },
    'haze': {
      SafetyCohort.older:
          'Haze usually means fine particles, even when you cannot smell smoke. Keeping activity light and indoors until it lifts may help.',
      SafetyCohort.kids:
          'Haze is easy to underestimate because it looks calm. Keeping play indoors and windows shut while it lingers may help.',
      SafetyCohort.mobility:
          'Haze can linger for days rather than hours. Timing essential trips for the clearest part of the day may help.',
      SafetyCohort.medical:
          'Haze can build symptoms slowly. Keeping medication within reach and limiting exertion until it clears may help.',
      SafetyCohort.deaf:
          'Haze arrives without a sound. Checking this app\'s air readings while visibility stays low may help.',
      SafetyCohort.vision:
          'Haze removes the contrast that landmarks rely on. Allowing extra time, or delaying unfamiliar trips may help.',
      SafetyCohort.visitor:
          'Haze here can come from fires hundreds of kilometres away. Checking air quality readings rather than judging by smell may help.',
      SafetyCohort.worker:
          'Haze lowers air quality and driving visibility together. Headlights on, longer following gaps, and indoor breaks may help.',
      SafetyCohort.pets:
          'Haze affects animals the same way it affects you. Shorter walks and indoor time until it lifts may help.',
    },
    'water_quality': {
      SafetyCohort.older:
          'Water alerts usually mean boiling before drinking or brushing teeth. Following the alert\'s exact instructions until cleared may help.',
      SafetyCohort.kids:
          'Children swallow more water in baths and pools. Following the alert\'s advice for drinking, teeth and bathing until the agency says the water is fine to use may help.',
      SafetyCohort.mobility:
          'If collecting bottled water is difficult, asking a neighbour or your council for help early, before supplies thin out may help.',
      SafetyCohort.medical:
          'Water quality matters more with a medical condition. Using boiled or bottled water for drinking and taking medication until cleared may help.',
      SafetyCohort.deaf:
          'Boil water notices often spread by radio and doorknock. This alert carries the full written advice; checking it for updates may help.',
      SafetyCohort.vision:
          'Affected water usually looks completely normal. Treating all tap water as per this alert, rather than judging by sight may help.',
      SafetyCohort.visitor:
          'Tap water in Australia is normally trusted, so a water alert here is genuine. Using bottled or boiled water until the agency says the water is fine to use may help.',
      SafetyCohort.worker:
          'If your work uses mains water for food, drink or care, checking whether this alert changes your site\'s procedures before your shift may help.',
      SafetyCohort.pets:
          'Water warnings apply to animals too, especially algae warnings. Keeping pets and stock away from affected water and on a clean supply may help.',
    },
    'wildlife': {
      SafetyCohort.older:
          'Startled animals are unpredictable at close range. Giving them space and taking a different path may help.',
      SafetyCohort.kids:
          'Children read animals as friendly by default. Keeping kids close, and teaching look but do not touch, may help even for animals that seem calm.',
      SafetyCohort.mobility:
          'An animal blocking a path can mean a real detour. Checking the location on the map and choosing an alternative route early may help.',
      SafetyCohort.medical:
          'A sudden animal encounter is a jolt at the best of times. Keeping distance and letting the animal move on in its own time may help.',
      SafetyCohort.deaf:
          'Animal warnings are often sound first, a hiss, buzz or bark. Extra visual scanning near bush, long grass and water may help.',
      SafetyCohort.vision:
          'Snakes and swooping birds are usually seen before heard. Asking exactly where the hazard is, and travelling with someone past it may help.',
      SafetyCohort.visitor:
          'Australian wildlife is best admired from a distance, and animals cross roads most at dawn and dusk. Slowing down through this area may help.',
      SafetyCohort.worker:
          'Displaced wildlife turns up in sheds, sites and machinery after fire and flood. Checking before reaching in, and calling wildlife rescue rather than handling may help.',
      SafetyCohort.pets:
          'Your pets are the most likely point of contact. Keeping dogs leashed and cats in until the animal hazard clears may help.',
    },
    'health_capacity': {
      SafetyCohort.older:
          'When hospitals are stretched, waits are longest for non urgent care. Handling routine matters by phone where possible may help. If you are experiencing an emergency, call your local emergency number.',
      SafetyCohort.kids:
          'Emergency departments triage children on urgency, not arrival time. For non urgent worries, trying a GP or nurse service first may help. If you are experiencing an emergency, call your local emergency number.',
      SafetyCohort.mobility:
          'Patient transport runs slower when the system is stretched. Booking accessible transport for appointments earlier than usual may help.',
      SafetyCohort.medical:
          'Keeping regular medication topped up matters more when services are stretched. Renewing scripts before you run low may help. If you are experiencing an emergency, call your local emergency number.',
      SafetyCohort.deaf:
          'Stretched hospitals have less time to arrange interpreters. Booking Auslan support ahead for planned visits, and stating your needs on arrival may help.',
      SafetyCohort.vision:
          'Busy waiting rooms rely on called names and screens. Telling triage staff how to reach you when it is your turn may help.',
      SafetyCohort.visitor:
          'Travel insurance details speed everything up in an Australian hospital. Keeping your policy number with you while services are stretched may help.',
      SafetyCohort.worker:
          'If you work in or around care services, expecting longer handovers and confirming shift arrangements early may help.',
      SafetyCohort.pets:
          'Vets are often stretched by the same events as hospitals. Booking routine animal care ahead, and keeping pet medication topped up may help.',
    },
    'evac_centre': {
      SafetyCohort.older:
          'Evacuation centres help with medication, mobility and quiet space if you ask at the desk. Arriving before dark may help.',
      SafetyCohort.kids:
          'Centres are calmer for kids with familiar things. Bringing comfort items, snacks and something to do may help.',
      SafetyCohort.mobility:
          'Centres usually have accessible facilities, and arriving early helps staff set you up well. Mentioning your needs at the registration desk may help.',
      SafetyCohort.medical:
          'Centres can store and help manage medication. Bringing yours, with its usual instructions, and telling staff on arrival may help.',
      SafetyCohort.deaf:
          'Centre announcements are usually spoken. Telling registration staff you need written or signed updates may help; staff can usually arrange it.',
      SafetyCohort.vision:
          'Centres are unfamiliar layouts by definition. Asking staff for an orientation walk on arrival may help.',
      SafetyCohort.visitor:
          'Evacuation centres are usually free and open to visitors too. Registering on arrival so family can find you may help.',
      SafetyCohort.worker:
          'If you are supporting others, registering yourself as well may help. Centres keep a record of who has arrived, including helpers.',
      SafetyCohort.pets:
          'Many centres take pets, and some use a nearby animal shelter instead. Checking this alert for the pet arrangement before travelling may help.',
    },
    'heatwave': {
      SafetyCohort.older:
          'Heat builds in the body over consecutive days. Using the coolest room, drinking regularly and asking someone to check in daily may help.',
      SafetyCohort.kids:
          'Children overheat faster than adults, especially in cars. Not leaving kids in a parked car, and planning indoor hours over the peak may help.',
      SafetyCohort.mobility:
          'Heat makes transfers and outdoor waits harder. Booking travel for early morning and allowing extra rest stops may help.',
      SafetyCohort.medical:
          'Some conditions and medications make heat harder to handle. Staying cool, drinking regularly and following your usual care plan may help.',
      SafetyCohort.deaf:
          'Heat warnings often extend day by day. Checking this app each evening for the next day\'s rating may help.',
      SafetyCohort.vision:
          'Glare is harshest over the heat peak. Planning travel for early or late in the day may help.',
      SafetyCohort.visitor:
          'Australian heat is drier and stronger than most visitors are used to. Planning sightseeing before mid morning and drinking more than feels necessary may help.',
      SafetyCohort.worker:
          'Outdoor work in a heatwave needs a plan, not toughness. Agreeing rest cycles, shade and water breaks with your site before your shift may help.',
      SafetyCohort.pets:
          'Animals overheat faster than people. Shade and extra water for pets and stock is standing advice. Not leaving animals in vehicles may help.',
    },
    'cold_snap': {
      SafetyCohort.older:
          'Cold snaps raise risks indoors as much as outside. Heating the room you live in, and layering rather than relying on one heater may help.',
      SafetyCohort.kids:
          'Kids lose heat faster than they notice. Layers, dry clothes after outdoor play and warm sleep spaces may help through the cold snap.',
      SafetyCohort.mobility:
          'Frost keeps ramps and paths slippery well after sunrise. Timing trips for the warmest part of the day may help.',
      SafetyCohort.medical:
          'Cold air and cold nights can worsen some conditions. Keeping warm, keeping medication close and heating your main room may help.',
      SafetyCohort.deaf:
          'Black ice gives no visual warning and no sound either. Assuming frost on shaded roads and paths through the morning may help.',
      SafetyCohort.vision:
          'Frost and black ice are invisible hazards by definition. Waiting for the day to warm before heading out, or taking an arm may help.',
      SafetyCohort.visitor:
          'Australian buildings are often colder inside than visitors expect. Packing warm layers for indoors as well as out may help.',
      SafetyCohort.worker:
          'Early starts meet the coldest roads of the day. Allowing extra travel time and checking for ice on site may help.',
      SafetyCohort.pets:
          'Outdoor animals feel cold snaps hardest. Bringing pets in overnight, and giving stock windbreaks and unfrozen water may help.',
    },
    'rough_surf': {
      SafetyCohort.older:
          'Rough surf can knock you down in ankle deep water. Enjoying the beach from well above the waterline may help.',
      SafetyCohort.kids:
          'Waves and rips take children first. Keeping kids out of the water, and away from rocks and drop offs, may help during a surf warning.',
      SafetyCohort.mobility:
          'Soft sand and surf spray make beach access points hazardous in rough conditions. Choosing lookouts over beach level until it calms may help.',
      SafetyCohort.medical:
          'A struggle in rough water is maximum exertion, instantly. Staying out of the water entirely during the warning may help.',
      SafetyCohort.deaf:
          'Surf lifesavers signal with whistles and megaphones. Swimming near the flags where you can see the signals, or staying out entirely may help.',
      SafetyCohort.vision:
          'Rips and drop offs are read by eye. Staying out of the water during rough surf, and enjoying the coast from a distance may help.',
      SafetyCohort.visitor:
          'Australian surf is stronger than it looks, and rips are the main danger. Swimming only between the red and yellow flags, and not at all during warnings may help.',
      SafetyCohort.worker:
          'Rock platforms and breakwalls are wave traps in heavy swell. Postponing coastal work, or staying above the spray zone may help.',
      SafetyCohort.pets:
          'Dogs chase waves with no sense of rips. Keeping dogs leashed near rough surf, and not going in after one may help.',
    },
    'earthquake': {
      SafetyCohort.older:
          'Aftershocks follow the main tremor. Staying clear of brick walls and chimneys, and expecting a few more shakes may help.',
      SafetyCohort.kids:
          'Children take their cue from adults after a tremor. Doing drop, cover and hold on together, then checking in calmly may help.',
      SafetyCohort.mobility:
          'Drop, cover and hold on adapts to you: lock wheels, cover your head, stay put. Moving only after the shaking fully stops may help.',
      SafetyCohort.medical:
          'The best move in a tremor is the least movement. Taking cover in place, and gathering medication once the shaking stops may help.',
      SafetyCohort.deaf:
          'Aftershock updates come as alerts, not sound. Keeping vibration alerts on in the hours after a tremor may help.',
      SafetyCohort.vision:
          'Objects and broken glass shift underfoot after shaking. Sturdy shoes kept by the bed, and checking paths with a companion, is standing advice.',
      SafetyCohort.visitor:
          'Australian earthquakes are usually small but can surprise. Drop, cover and hold on, then following this app\'s updates may help.',
      SafetyCohort.worker:
          'Buildings need checking before re-entry after a tremor. Waiting for your site to confirm re-entry rather than going straight back in may help.',
      SafetyCohort.pets:
          'Animals often bolt during tremors. Keeping pets contained afterwards, since fences and gates may have shifted may help.',
    },
    'tsunami': {
      SafetyCohort.older:
          'A land warning means moving away from the coast, not watching it. Moving inland or uphill early, without rushing may help.',
      SafetyCohort.kids:
          'A tsunami can arrive as many waves over hours. Moving kids inland early and staying away until officials say it is over may help.',
      SafetyCohort.mobility:
          'Tsunami timing is uncertain, which favours the early mover. Heading inland or to a higher floor as soon as the warning lands may help.',
      SafetyCohort.medical:
          'Taking medication with you when you move may help; warnings can last hours. Moving early and calmly beats moving late.',
      SafetyCohort.deaf:
          'Coastal sirens are the traditional channel. Keeping vibration alerts on, and acting on this app\'s warning without waiting for confirmation may help.',
      SafetyCohort.vision:
          'Ask anyone nearby to guide you to higher ground now. Bystander help is expected in tsunami evacuations.',
      SafetyCohort.visitor:
          'In Australia a marine warning means leave the water and shore; a land warning means move inland. Following this alert\'s level may help.',
      SafetyCohort.worker:
          'If you work on or near the water, moving inland matters more than the gear. Securing only what is quick, then following the warning level may help.',
      SafetyCohort.pets:
          'Taking pets with you when moving inland may help; returning can take hours. Keeping leads and carriers by the door helps.',
    },
    'school_holidays': {
      SafetyCohort.older:
          'School holidays change traffic and quiet hours. Timing errands for early morning, before attractions open may help.',
      SafetyCohort.kids:
          'Holiday crowds peak at pools, parks and cinemas mid morning. Booking ahead where possible, and agreeing meeting points at busy venues may help.',
      SafetyCohort.mobility:
          'Holiday crowds fill accessible parking early at popular spots. Arriving early, or choosing quieter days for outings may help.',
      SafetyCohort.medical:
          'Busy holiday venues mean longer stretches away from home. Carrying medication rather than planning to duck back for it may help.',
      SafetyCohort.deaf:
          'More children about means more that is easy to miss around driveways and carparks. Extra visual checks in low speed areas may help.',
      SafetyCohort.vision:
          'Footpaths carry more scooters, bikes and prams in the holidays. Allowing extra time and taking familiar routes at quieter hours may help.',
      SafetyCohort.visitor:
          'Australian school holidays vary by state and fill accommodation fast. Booking travel and attractions ahead during these weeks may help.',
      SafetyCohort.worker:
          'Holiday traffic moves from school zones to attractions. Allowing extra time on routes past pools, beaches and shopping centres may help.',
      SafetyCohort.pets:
          'Parks are fuller and louder in the holidays. Walking dogs at quieter hours, and keeping them leashed around playing children may help.',
    },
    'snakes': {
      SafetyCohort.older:
          'Snakes hold still and rely on not being seen. Sticking to clear paths, and wearing solid shoes in long grass may help.',
      SafetyCohort.kids:
          'Children explore with their hands at snake height. Teaching kids to back away and tell an adult, and not to touch may help.',
      SafetyCohort.mobility:
          'Snakes rest on warm paths and ramps in the morning. Scanning ahead on sunny paths, and keeping to open routes may help.',
      SafetyCohort.medical:
          'For any suspected bite, keeping completely still may help for everyone, and not driving yourself. If you are experiencing an emergency, call your local emergency number.',
      SafetyCohort.deaf:
          'A warning rustle or hiss is easy to miss. Extra visual scanning near long grass, water and wood piles may help.',
      SafetyCohort.vision:
          'Snakes are seen rather than heard, which makes shared awareness matter. Walking with someone in bush or long grass this season may help.',
      SafetyCohort.visitor:
          'Australian snakes avoid people given the chance. Solid shoes, staying on paths, and leaving any snake alone may help. Not trying to move one may help.',
      SafetyCohort.worker:
          'Snakes shelter in sheds, pipes and machinery. Checking before reaching into dark spaces, and wearing gloves and boots may help.',
      SafetyCohort.pets:
          'Curious dogs and cats meet most of the snakes. Keeping dogs leashed, cats in, and yards clear of long grass may help. After any suspected strike, seeing a vet urgently may help.',
    },
    'fuel_supply': {
      SafetyCohort.older:
          'Fuel queues are usually worse than the shortage itself. Topping up at half a tank, at off peak times, may help rather than queuing on empty.',
      SafetyCohort.kids:
          'Long fuel queues are hard with kids aboard. Filling up before the school run, or at quiet hours, may help while supply is short.',
      SafetyCohort.mobility:
          'If accessible pumps are limited near you, shortages make them scarcer. Topping up early, before queues build may help.',
      SafetyCohort.medical:
          'If driving supports your treatment or care, fuel is part of the care plan. Keeping the tank above half while this alert is active may help.',
      SafetyCohort.deaf:
          'Station closures are often announced on local radio first. Checking this app and fuel apps for live availability may help.',
      SafetyCohort.vision:
          'If you rely on lifts, your drivers will be juggling queues too. Booking transport earlier than usual while supply is short may help.',
      SafetyCohort.visitor:
          'Distances between stations here can exceed a full tank. Fuelling at every reasonable stop in affected areas may help.',
      SafetyCohort.worker:
          'If your work depends on driving, agreeing priority fuelling with your employer early in a shortage may help.',
      SafetyCohort.pets:
          'Queues in warm cars are hard on animals. Leaving pets at home when heading out for fuel may help.',
    },
    'shark': {
      SafetyCohort.older:
          'Sharks can be a risk close to shore too. Keeping out of the water while the alert is active, and enjoying the beach from the sand may help.',
      SafetyCohort.kids:
          'Children are harder to watch in the water. Keeping kids out of the water and off the shoreline edge while the alert is active may help.',
      SafetyCohort.mobility:
          'Leaving the water quickly is harder with limited mobility. Choosing dry beach activities while the alert is active may help.',
      SafetyCohort.medical:
          'A sudden scare in the water strains the heart and breathing. Staying out of the water while the alert is active may help.',
      SafetyCohort.deaf:
          'Beach sirens and lifesaver calls may not reach you. Keeping vibration alerts on and watching for flags and signs may help.',
      SafetyCohort.vision:
          'Warning flags and signs are visual. Asking a lifeguard or someone with you about beach conditions before entering the water may help.',
      SafetyCohort.visitor:
          'Local beach warnings apply to visitors too. Checking flags and signs, and staying out of the water while the alert is active may help.',
      SafetyCohort.worker:
          'If your work is on or in the water, checking with your supervisor before starting, and following any stand down may help.',
      SafetyCohort.pets:
          'Dogs swim after anything. Keeping dogs leashed and out of the water while the alert is active may help.',
    },
    'crocodile': {
      SafetyCohort.older:
          'Crocodiles can be close to the water\'s edge. Keeping well back from banks, jetties and boat ramps may help.',
      SafetyCohort.kids:
          'Children go close to the water\'s edge without thinking. Keeping kids well back from banks, creeks and boat ramps may help.',
      SafetyCohort.mobility:
          'Jetties and boat ramps put you near the water\'s edge. Choosing spots away from the edge while the alert is active may help.',
      SafetyCohort.medical:
          'A sudden animal encounter is a shock to the body. Staying well back from the water\'s edge may help.',
      SafetyCohort.deaf:
          'Crocodile warnings rely on signs and word of mouth. Reading local signs and checking this app for updates may help.',
      SafetyCohort.vision:
          'Warning signs are visual. Asking someone with you to read local signs and describe the water\'s edge may help.',
      SafetyCohort.visitor:
          'In northern Australia, any waterway can hold crocodiles. Obeying local signs, staying out of the water and away from the edge may help.',
      SafetyCohort.worker:
          'If working near waterways, checking your site\'s crocodile controls and staying back from the edge may help.',
      SafetyCohort.pets:
          'Dogs at the water\'s edge are at risk. Keeping dogs leashed and away from banks may help.',
    },
    'landslide': {
      SafetyCohort.older:
          'Slopes can give way with little warning after heavy rain. Staying away from steep slopes and cuttings, and moving early if you live below one may help.',
      SafetyCohort.kids:
          'Children are drawn to mud and rubble. Keeping kids away from slopes, cuttings and slip debris may help.',
      SafetyCohort.mobility:
          'Roads and paths near slopes can close suddenly. Checking your route before leaving and choosing flatter alternatives may help.',
      SafetyCohort.medical:
          'Closed roads can delay care and supplies. Keeping medication stocked and checking access routes early may help.',
      SafetyCohort.deaf:
          'Slope movement can be silent. Keeping vibration alerts on and heeding barriers and signs may help.',
      SafetyCohort.vision:
          'Debris changes familiar paths. Avoiding the area, and asking someone to check the route first may help.',
      SafetyCohort.visitor:
          'Tracks and roads in steep country can close after rain. Checking local advice before hikes and drives, and staying out of closed areas may help.',
      SafetyCohort.worker:
          'If your work is near slopes or cuttings, checking with your site before entering and following any exclusion zone may help.',
      SafetyCohort.pets:
          'Pets investigate rubble and fresh slips. Keeping them away from slopes and debris may help.',
    },
    'tornado': {
      SafetyCohort.older:
          'Tornadoes give very little notice. Moving to an inner room or the lowest floor, away from windows, when a warning applies to you may help.',
      SafetyCohort.kids:
          'Frightened children need a calm plan. Keeping kids close and moving together to an inner room away from windows may help.',
      SafetyCohort.mobility:
          'Moving to shelter takes longer with limited mobility. Choosing your inner room now, before a warning may help.',
      SafetyCohort.medical:
          'Power loss can follow a tornado. Keeping medication close and devices charged may help.',
      SafetyCohort.deaf:
          'Sirens and shouted warnings may not reach you. Keeping vibration alerts on and checking this app for the latest warning may help.',
      SafetyCohort.vision:
          'Debris changes familiar paths quickly. Staying in your shelter room until officials say it is over, and asking for help to move around afterwards may help.',
      SafetyCohort.visitor:
          'Tornadoes are rare in Australia but can happen with severe storms. Following the warning and your accommodation\'s instructions may help.',
      SafetyCohort.worker:
          'If working outdoors, stopping work and moving to solid shelter when a warning applies to you may help.',
      SafetyCohort.pets:
          'Pets often bolt in storms. Bringing them indoors with identification before the storm arrives may help.',
    },
  };
}
