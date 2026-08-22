import 'package:hazard_app/features/profile/models/safety_cohort.dart';

/// The Standing For You Library — rows carried VERBATIM from Sarah's
/// reviewed library document (approved Aug 2026). Zero AI at generation and
/// render. Hazards on the Empty-by-design register (police operation, crash,
/// road closure, events) deliberately have no rows: no genuine cohort
/// difference means no line, and a missing row shows nothing — never a
/// substitute from another hazard.
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
    // The specific hazards first: these are subcategory names, and each
    // has its own reviewed rows.
    for (final entry in _titleKeywords) {
      if (entry.$1.any(name.contains)) return entry.$2;
    }
    if (name.contains('fire') && name.contains('smoke')) return 'smoke';
    if (name.contains('fire')) return 'bushfire';
    if (name.contains('smoke')) return 'smoke';
    if (name.contains('flood')) return 'flood';
    if (name.contains('weather') || name.contains('environment')) {
      return 'severe_weather';
    }
    if (name.contains('air')) return 'air_quality';
    if (name.contains('health')) return 'public_health';
    if (name.contains('utilit')) return 'utility_outage';
    if (name.contains('chemical')) return 'chemical';
    return null;
  }

  /// Title keywords checked most-specific-first.
  static const _titleKeywords = <(List<String>, String)>[
    (['tsunami'], 'tsunami'),
    (['cyclone'], 'cyclone'),
    (['earthquake', 'tremor', 'aftershock'], 'earthquake'),
    (['grass fire', 'grassfire'], 'grass_fire'),
    (['bushfire', 'bush fire'], 'bushfire'),
    (['structure fire', 'building fire', 'house fire'], 'structure_fire'),
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
    (['chemical', 'hazmat', 'gas leak'], 'chemical'),
    (['smoke'], 'smoke'),
    (['flood'], 'flood'),
    (['storm'], 'severe_weather'),
    (['air quality'], 'air_quality'),
    (['unrest', 'protest', 'riot'], 'civil_unrest'),
    (['outbreak', 'measles', 'disease'], 'public_health'),
  ];

  /// hazard bucket -> cohort -> line (verbatim reviewed wording).
  static const Map<String, Map<SafetyCohort, String>> rows = {
    'bushfire': {
      SafetyCohort.older:
          'Ember attacks and fast changes are hardest on people who move '
          'more slowly. Deciding early whether to leave, rather than '
          'waiting to see, is advisable.',
      SafetyCohort.kids:
          'Children breathe faster and worry spreads quickly. Packing '
          'early, keeping kids indoors and explaining the plan calmly is '
          'advisable.',
      SafetyCohort.mobility:
          'Evacuating with mobility needs takes longer than warnings allow '
          'for. Leaving well before an Emergency Warning, and telling '
          'someone your route, is advisable.',
      SafetyCohort.medical:
          'If a medical condition applies, smoke and exertion can both make '
          'it worse. Keeping medication within reach and avoiding heavy '
          'work like yard clearing is advisable.',
      SafetyCohort.deaf:
          'Sirens and doorknocks may not reach you. Keeping strong '
          'vibration and screen flash alerts on, and asking a neighbour to '
          'check in, is advisable.',
      SafetyCohort.vision:
          'Smoke lowers visibility for everyone, and unfamiliar evacuation '
          'routes are harder without sight. Arranging transport with a '
          'sighted person early is advisable.',
      SafetyCohort.visitor:
          'Australian bushfires move faster than most visitors expect. '
          'Following the official warning level for this area and leaving '
          'early if advised is advisable.',
      SafetyCohort.worker:
          'If you are required on site, confirming your workplace\'s fire '
          'plan and a safe route in and out before travelling is advisable.',
      SafetyCohort.pets:
          'Animals are easier to find and load before smoke arrives. '
          'Knowing where carriers and leads are now may save time later.',
    },
    'grass_fire': {
      SafetyCohort.older:
          'Grass fires move faster than a person can walk. Leaving early '
          'rather than staying to defend, and keeping your phone with you, '
          'is advisable.',
      SafetyCohort.kids:
          'Grass fires can cut roads in minutes. Keeping children close and '
          'not driving toward smoke, even for pickup, is advisable.',
      SafetyCohort.mobility:
          'Grass fires give little warning time. Moving to safety at the '
          'first sign of smoke rather than waiting for an official warning '
          'is advisable.',
      SafetyCohort.medical:
          'Even brief smoke can trigger symptoms, and a rushed move is a '
          'strain in itself. Keeping medication handy and preparing '
          'essentials early is advisable.',
      SafetyCohort.deaf:
          'Grass fires spread too fast for doorknocking. Keeping vibration '
          'alerts on and checking this app when you see any smoke is '
          'advisable.',
      SafetyCohort.vision:
          'Fast moving smoke changes conditions quickly. Asking someone '
          'nearby to describe what they can see, and leaving early '
          'together, is advisable.',
      SafetyCohort.visitor:
          'Grass fires are common in Australian summers and move extremely '
          'fast. Following local directions rather than stopping to watch '
          'is advisable.',
      SafetyCohort.worker:
          'If working outdoors nearby, moving vehicles and machinery off '
          'dry grass and agreeing a trigger point to stop work is '
          'advisable.',
      SafetyCohort.pets:
          'Grass fires leave no time to search for a hiding pet. Bringing '
          'animals in at the first sign of smoke, with carriers ready, is '
          'advisable.',
    },
    'flood': {
      SafetyCohort.older:
          'Flood evacuations are safest done early and in daylight. Moving '
          'medicines, glasses and essentials above floor level now is '
          'advisable.',
      SafetyCohort.kids:
          'Floodwater fascinates kids and hides currents and sharp objects. '
          'Keeping children away from all water, even shallow water over '
          'drains, is advisable.',
      SafetyCohort.mobility:
          'Floodwater makes surfaces impassable for wheels and unsteady '
          'feet. Arranging to move before water is anywhere near, not '
          'during, is advisable.',
      SafetyCohort.medical:
          'Keeping medication dry in a sealed bag you can grab is '
          'advisable, and asking for help with heavy work like sandbags '
          'rather than doing it alone.',
      SafetyCohort.deaf:
          'Rising water at night gives little visual warning. Keeping '
          'vibration alerts on while you sleep, and checking levels before '
          'bed, is advisable.',
      SafetyCohort.vision:
          'Floodwater hides depth and edges, even on familiar streets. '
          'Arranging a sighted companion or transport before water rises, '
          'rather than after, is advisable.',
      SafetyCohort.visitor:
          'Never drive through floodwater, whatever your car handles at '
          'home. Most Australian flood deaths happen in vehicles.',
      SafetyCohort.worker:
          'If travel to work is essential, checking closures before leaving '
          'and agreeing an alternative with your employer is advisable. '
          'Never drive through water over a road.',
      SafetyCohort.pets:
          'Floodwater strands animals quickly. Moving stock to higher '
          'paddocks early is standing advice; pets travel in carriers, '
          'never loose in vehicles.',
    },
    'cyclone': {
      SafetyCohort.older:
          'Cyclone preparation is heavy work best done early. Asking for '
          'help securing loose items now, and knowing your nearest shelter, '
          'is advisable.',
      SafetyCohort.kids:
          'The noise of a cyclone frightens children. Setting up your '
          'safest room with games, snacks and torches before the wind '
          'arrives is advisable.',
      SafetyCohort.mobility:
          'Sheltering and evacuating are harder in high wind. Registering '
          'early with local emergency services if you may need evacuation '
          'help is advisable.',
      SafetyCohort.medical:
          'Power loss can affect medical equipment and routines. Charging '
          'devices, stocking medication and planning for outages before the '
          'cyclone arrives is advisable.',
      SafetyCohort.deaf:
          'Warning changes come fast as a cyclone approaches. Keeping '
          'vibration alerts on, and a torch handy for lip reading if power '
          'fails, is advisable.',
      SafetyCohort.vision:
          'Sheltering changes room layouts. Walking your shelter space '
          'while conditions are calm, and keeping aids and a torch within '
          'reach, is advisable.',
      SafetyCohort.visitor:
          'Cyclone warnings here use categories 1 to 5. Following your '
          'accommodation\'s instructions and staying inside through the eye '
          'of the storm is advisable.',
      SafetyCohort.worker:
          'If required to work through the warning, agreeing a stand down '
          'trigger with your employer before conditions deteriorate is '
          'advisable.',
      SafetyCohort.pets:
          'Secure or shelter animals before winds arrive. Bringing pets '
          'indoors with water, and moving stock away from trees and fences, '
          'is standing preparation advice.',
    },
    'smoke': {
      SafetyCohort.older:
          'Smoke settles hardest on older lungs. Staying indoors with '
          'windows shut, and cooling the house rather than airing it, is '
          'advisable.',
      SafetyCohort.kids:
          'Smoke affects small lungs first. Keeping windows shut and '
          'staying indoors is advisable while smoke is nearby.',
      SafetyCohort.mobility:
          'If leaving the area is a big effort, one well sealed room beats '
          'a late move. Choosing your cleanest room and keeping doors shut '
          'is advisable.',
      SafetyCohort.medical:
          'If a medical condition applies, having medication on hand and '
          'limiting exertion is advisable while smoke is nearby.',
      SafetyCohort.deaf:
          'Smoke can arrive before any visible fire. Keeping vibration and '
          'screen flash alerts on while smoke is in your area is advisable.',
      SafetyCohort.vision:
          'Smoke irritates eyes and flattens what vision remains. Staying '
          'indoors and postponing unfamiliar journeys until it clears is '
          'advisable.',
      SafetyCohort.visitor:
          'Bushfire smoke can blanket areas far from any fire. Checking air '
          'quality before outdoor plans and keeping windows shut is '
          'advisable.',
      SafetyCohort.worker:
          'If working outdoors, a properly fitted P2 mask and regular '
          'indoor breaks are advisable while smoke is present.',
      SafetyCohort.pets:
          'Smoke affects animals too, especially birds and older pets. '
          'Bringing them indoors and limiting exercise while smoke is '
          'nearby is advisable.',
    },
    'chemical': {
      SafetyCohort.older:
          'Chemical incidents usually call for shelter, not evacuation. '
          'Going indoors, shutting windows and turning off the aircon is '
          'advisable.',
      SafetyCohort.kids:
          'Children are more affected by fumes. Bringing kids indoors, '
          'shutting windows and turning off any air intake is advisable.',
      SafetyCohort.mobility:
          'Shelter in place is the usual advice here, which works in your '
          'favour. Sealing the room you are in and waiting for the all '
          'clear is advisable.',
      SafetyCohort.medical:
          'Fumes and stress can both trigger symptoms quickly. Sealing your '
          'room, keeping medication with you, and seeking help early if '
          'symptoms start is advisable.',
      SafetyCohort.deaf:
          'Hazmat instructions are often given by loudspeaker. Keeping '
          'vibration alerts on and checking this app for the written all '
          'clear is advisable.',
      SafetyCohort.vision:
          'Chemical incidents rely on visual cordons and signage. Staying '
          'indoors and asking someone to confirm when the all clear is '
          'given is advisable.',
      SafetyCohort.visitor:
          'Australian practice for chemical incidents is shelter in place '
          'unless police say leave. Going indoors and following this app\'s '
          'updates is advisable.',
      SafetyCohort.worker:
          'If your site is inside the cordon, following your workplace\'s '
          'hazmat procedure and not re-entering until cleared is advisable.',
      SafetyCohort.pets:
          'Pets shelter with you in a chemical incident. Bringing them '
          'indoors now and keeping them in until the all clear is '
          'advisable.',
    },
    'severe_weather': {
      SafetyCohort.older:
          'Falls rise sharply in storms and on wet ground. Postponing '
          'errands until the weather passes, and charging your phone now, '
          'is advisable.',
      SafetyCohort.kids:
          'Storms pass faster when kids are settled. Bringing outdoor toys '
          'in, charging devices and planning an indoor afternoon is '
          'advisable.',
      SafetyCohort.mobility:
          'Wet ramps, debris and blocked footpaths outlast the storm. '
          'Planning to stay in through the warning period is advisable.',
      SafetyCohort.medical:
          'Storms can stir pollen and dust sharply, and cleanup is an '
          'overexertion trap. Keeping medication close and pacing any heavy '
          'work is advisable.',
      SafetyCohort.deaf:
          'Thunder is the warning most people rely on. Keeping vibration '
          'alerts on and an eye on the sky while the warning is active is '
          'advisable.',
      SafetyCohort.vision:
          'Debris can change familiar paths after a storm. Keeping aids '
          'charged, and asking a neighbour to check outside routes before '
          'heading out, is advisable.',
      SafetyCohort.visitor:
          'Australian storms can be stronger than they look. Staying clear '
          'of trees, creeks and the coast during warnings is advisable.',
      SafetyCohort.worker:
          'If working outdoors or at height, agreeing when work stops '
          'before the front arrives is advisable. Lightning ends outdoor '
          'work immediately.',
      SafetyCohort.pets:
          'Pets often bolt in storms. Keeping them indoors with '
          'identification, and checking gates and fencing afterwards, is '
          'advisable.',
    },
    'air_quality': {
      SafetyCohort.older:
          'Poor air days are hardest on older lungs and hearts. Keeping '
          'activity light and staying indoors during the worst hours is '
          'advisable.',
      SafetyCohort.kids:
          'Children take in more air for their size. Moving play indoors '
          'and keeping windows shut on poor air days is advisable.',
      SafetyCohort.mobility:
          'If getting out takes real effort, timing matters more. Planning '
          'essential trips for when air quality improves is advisable.',
      SafetyCohort.medical:
          'Poor air can build symptoms slowly across a day. Following your '
          'usual care plan, keeping medication within reach and skipping '
          'strenuous activity is advisable.',
      SafetyCohort.deaf:
          'Air quality changes silently. Checking this app\'s readings '
          'morning and evening while this alert is active is advisable.',
      SafetyCohort.vision:
          'Haze flattens contrast and landmarks. Allowing extra time for '
          'travel, or delaying it, is advisable while visibility is '
          'reduced.',
      SafetyCohort.visitor:
          'Air quality here can shift quickly with wind and fire. Checking '
          'readings before hikes or runs is advisable while this alert is '
          'active.',
      SafetyCohort.worker:
          'For outdoor work, more frequent breaks and a properly fitted P2 '
          'mask are advisable while air quality remains poor.',
      SafetyCohort.pets:
          'Poor air affects animals too, especially birds and flat faced '
          'breeds. Keeping pets indoors and walks short is advisable.',
    },
    'public_health': {
      SafetyCohort.older:
          'Older adults are usually the first group health alerts apply to. '
          'Reading this alert\'s specific advice and acting on it early is '
          'advisable.',
      SafetyCohort.kids:
          'Health alerts often carry specific advice for children. Checking '
          'whether schools or childcare are affected is advisable.',
      SafetyCohort.mobility:
          'If the advice means avoiding certain places, planning accessible '
          'alternatives early, before options thin out, is advisable.',
      SafetyCohort.medical:
          'Health alerts can matter more with a medical condition. '
          'Following the alert\'s specific guidance alongside your usual '
          'care plan is advisable.',
      SafetyCohort.deaf:
          'Health advice often updates through radio and press conferences. '
          'Relying on this app and official websites for written updates is '
          'advisable.',
      SafetyCohort.vision:
          'Maps and signage often carry health advice. The alert text here '
          'carries the same advice in full, with key actions first for '
          'screen readers.',
      SafetyCohort.visitor:
          'Local health alerts apply to visitors too, and your travel '
          'insurer may ask whether you followed them. Reading the specific '
          'advice is advisable.',
      SafetyCohort.worker:
          'If you work with the public, checking whether this alert changes '
          'your workplace\'s requirements before your shift is advisable.',
      SafetyCohort.pets:
          'Some health alerts cover animals too, such as water or algae '
          'warnings. Checking whether this one affects pets is advisable.',
    },
    'civil_unrest': {
      SafetyCohort.older:
          'Crowded, volatile areas are hardest to leave quickly. Avoiding '
          'the area entirely until it settles is advisable.',
      SafetyCohort.kids:
          'Crowds and children separate easily. Avoiding the area with '
          'kids, and agreeing a meeting point if you must be nearby, is '
          'advisable.',
      SafetyCohort.mobility:
          'Moving against a crowd is the hardest move there is. Staying '
          'well clear of the area rather than skirting its edge is '
          'advisable.',
      SafetyCohort.medical:
          'Crowd control agents and stress can both trigger symptoms. '
          'Staying upwind and well away, with medication on hand, is '
          'advisable.',
      SafetyCohort.deaf:
          'Police move on directions are usually shouted. Keeping visual '
          'distance from any crowd and following this app\'s updates is '
          'advisable.',
      SafetyCohort.vision:
          'Crowd situations change too fast to navigate safely without '
          'sight. Avoiding the area completely, and travelling with someone '
          'if nearby, is advisable.',
      SafetyCohort.visitor:
          'Steering well clear of protests is advisable. Involvement can '
          'affect visas, and crowd dynamics are hard to read in an '
          'unfamiliar city.',
      SafetyCohort.worker:
          'If your workplace is inside the affected area, contacting your '
          'employer before travelling in, and using an agreed entrance, is '
          'advisable.',
      SafetyCohort.pets:
          'Crowds and noise panic animals. Walking dogs well away from the '
          'area until it settles is advisable.',
    },
    'structure_fire': {
      SafetyCohort.older:
          'Building fires can spread to neighbouring properties. If you are '
          'close by, preparing to leave before being told is advisable.',
      SafetyCohort.kids:
          'Fire trucks draw children toward the scene. Keeping kids indoors '
          'and away from windows near a building fire is advisable.',
      SafetyCohort.mobility:
          'If you are in an affected or neighbouring building, starting '
          'your exit early matters most. Not waiting for the situation to '
          'worsen is advisable.',
      SafetyCohort.medical:
          'Structure fires produce heavy, toxic smoke. Staying indoors with '
          'windows shut if nearby, and moving calmly with medication if you '
          'leave, is advisable.',
      SafetyCohort.deaf:
          'Building alarms are sound first. If you are near the scene, '
          'watching for others evacuating and keeping vibration alerts on '
          'is advisable.',
      SafetyCohort.vision:
          'Smoke and fire crews change familiar exits. Asking for guidance '
          'early rather than navigating alone is advisable if you are '
          'close.',
      SafetyCohort.visitor:
          'If your hotel or hostel is nearby, following staff instructions, '
          'and taking your passport if you evacuate, is advisable.',
      SafetyCohort.worker:
          'If this is near your workplace, expecting cordons around the '
          'block and checking access before travelling in is advisable.',
      SafetyCohort.pets:
          'Smoke and sirens carry further than the cordon. Keeping pets '
          'indoors and dog walks away from the scene is advisable.',
    },
    'utility_outage': {
      SafetyCohort.older:
          'Outages hit lifts, hot water and phones together. Checking your '
          'phone\'s charge now and keeping a torch within reach is '
          'advisable.',
      SafetyCohort.kids:
          'Outages unsettle bedtime fast. Finding torches before dark and '
          'charging a device for the kids now is advisable.',
      SafetyCohort.mobility:
          'If lifts or powered doors are part of your route, planning '
          'around them before you need them is advisable while power is '
          'out.',
      SafetyCohort.medical:
          'If powered medical equipment or refrigerated medication applies, '
          'acting on your backup plan early, before batteries run down, is '
          'advisable.',
      SafetyCohort.deaf:
          'Outage updates often come by radio. This app and SMS from your '
          'provider are the written channels. Keeping vibration alerts on '
          'is advisable.',
      SafetyCohort.vision:
          'An outage removes the lighting others rely on, not your '
          'navigation. Checking on neighbours who may be struggling in the '
          'dark is advisable.',
      SafetyCohort.visitor:
          'Outages can affect card payments and fuel pumps locally. Keeping '
          'some cash and a charged phone while the outage lasts is '
          'advisable.',
      SafetyCohort.worker:
          'If your work depends on this utility, confirming with your site '
          'before travelling in is advisable. Restoration estimates in this '
          'alert update live.',
      SafetyCohort.pets:
          'Aquariums, heat lamps and electric fences stop with the power. '
          'Checking any animal setup that relies on it early is advisable.',
    },
    'dust_storm': {
      SafetyCohort.older:
          'Dust is hard on lungs and visibility together. Staying indoors '
          'with windows shut until the front passes is advisable.',
      SafetyCohort.kids:
          'Dust storms pass quickly but hit small lungs hard. Keeping '
          'children indoors and windows shut until it clears is advisable.',
      SafetyCohort.mobility:
          'A dust storm outlasts most short trips. Waiting it out indoors '
          'rather than pushing through is advisable.',
      SafetyCohort.medical:
          'Dust can trigger breathing and heart symptoms fast. Staying '
          'indoors with medication close until the air clears is advisable.',
      SafetyCohort.deaf:
          'Dust fronts arrive with almost no sound. Keeping vibration '
          'alerts on and checking the horizon before driving is advisable.',
      SafetyCohort.vision:
          'Dust cuts everyone\'s vision to near zero. Staying indoors, and '
          'asking others nearby whether it has passed, is advisable.',
      SafetyCohort.visitor:
          'If a dust storm hits while driving, the local practice is to '
          'pull right off the road with lights off. Waiting it out is '
          'advisable.',
      SafetyCohort.worker:
          'Dust ends fine outdoor tasks and driving visibility fast. '
          'Pausing work and sealing machinery cabs until it passes is '
          'advisable.',
      SafetyCohort.pets:
          'Dust irritates animals\' eyes and lungs too. Bringing pets in, '
          'and giving stock shelter and clean water, is advisable.',
    },
    'pollen': {
      SafetyCohort.older:
          'High pollen days can affect breathing even without a hay fever '
          'history. Keeping outdoor time short and windows shut is '
          'advisable.',
      SafetyCohort.kids:
          'Pollen peaks in the morning and early evening. Timing outdoor '
          'play around those windows on high pollen days is advisable.',
      SafetyCohort.mobility:
          'If your routes pass parks or grassland, exposure is higher. '
          'Planning trips for after rain, when pollen drops, is advisable.',
      SafetyCohort.medical:
          'High pollen plus a storm can trigger thunderstorm asthma, even '
          'with only hay fever. Staying indoors before storm fronts, with '
          'medication close, is advisable.',
      SafetyCohort.deaf:
          'Pollen warnings are easy to miss in spoken forecasts. Checking '
          'this app\'s alerts on spring storm days is advisable.',
      SafetyCohort.vision:
          'Itchy, watering eyes make remaining vision harder to use. '
          'Keeping windows shut and limiting time outside on peak days is '
          'advisable.',
      SafetyCohort.visitor:
          'Southern Australia\'s spring pollen is severe by world '
          'standards. Taking hay fever seriously here, especially before '
          'storms, is advisable.',
      SafetyCohort.worker:
          'Mowing, landscaping and outdoor work spike exposure on high '
          'pollen days. A mask and shorter stints are advisable.',
      SafetyCohort.pets:
          'Pets carry pollen inside in their coats. Wiping coats down after '
          'walks on high pollen days is advisable.',
    },
    'haze': {
      SafetyCohort.older:
          'Haze usually means fine particles, even when you cannot smell '
          'smoke. Keeping activity light and indoors until it lifts is '
          'advisable.',
      SafetyCohort.kids:
          'Haze is easy to underestimate because it looks calm. Keeping '
          'play indoors and windows shut while it lingers is advisable.',
      SafetyCohort.mobility:
          'Haze can linger for days rather than hours. Timing essential '
          'trips for the clearest part of the day is advisable.',
      SafetyCohort.medical:
          'Haze can build symptoms slowly. Keeping medication within reach '
          'and limiting exertion until it clears is advisable.',
      SafetyCohort.deaf:
          'Haze arrives without a sound. Checking this app\'s air readings '
          'while visibility stays low is advisable.',
      SafetyCohort.vision:
          'Haze removes the contrast that landmarks rely on. Allowing extra '
          'time, or delaying unfamiliar trips, is advisable.',
      SafetyCohort.visitor:
          'Haze here can come from fires hundreds of kilometres away. '
          'Checking air quality readings rather than judging by smell is '
          'advisable.',
      SafetyCohort.worker:
          'Haze lowers air quality and driving visibility together. '
          'Headlights on, longer following gaps, and indoor breaks are '
          'advisable.',
      SafetyCohort.pets:
          'Haze affects animals the same way it affects you. Shorter walks '
          'and indoor time until it lifts are advisable.',
    },
    'water_quality': {
      SafetyCohort.older:
          'Water alerts usually mean boiling before drinking or brushing '
          'teeth. Following the alert\'s exact instructions until cleared '
          'is advisable.',
      SafetyCohort.kids:
          'Children swallow more water in baths and pools. Following the '
          'alert\'s advice for drinking, teeth and bathing until the all '
          'clear is advisable.',
      SafetyCohort.mobility:
          'If collecting bottled water is difficult, asking a neighbour or '
          'your council for help early, before supplies thin out, is '
          'advisable.',
      SafetyCohort.medical:
          'Water quality matters more with a medical condition. Using '
          'boiled or bottled water for drinking and taking medication until '
          'cleared is advisable.',
      SafetyCohort.deaf:
          'Boil water notices often spread by radio and doorknock. This '
          'alert carries the full written advice; checking it for updates '
          'is advisable.',
      SafetyCohort.vision:
          'Affected water usually looks completely normal. Treating all tap '
          'water as per this alert, rather than judging by sight, is '
          'advisable.',
      SafetyCohort.visitor:
          'Australian tap water is normally safe, so a water alert here is '
          'genuine. Using bottled or boiled water until the all clear is '
          'advisable.',
      SafetyCohort.worker:
          'If your work uses mains water for food, drink or care, checking '
          'whether this alert changes your site\'s procedures before your '
          'shift is advisable.',
      SafetyCohort.pets:
          'Water warnings apply to animals too, especially algae warnings. '
          'Keeping pets and stock away from affected water and on a clean '
          'supply is advisable.',
    },
    'wildlife': {
      SafetyCohort.older:
          'Startled animals are unpredictable at close range. Giving them '
          'space and taking a different path is advisable.',
      SafetyCohort.kids:
          'Children read animals as friendly by default. Keeping kids '
          'close, and teaching look but never touch, is advisable even for '
          'animals that seem calm.',
      SafetyCohort.mobility:
          'An animal blocking a path can mean a real detour. Checking the '
          'location on the map and choosing an alternative route early is '
          'advisable.',
      SafetyCohort.medical:
          'A sudden animal encounter is a jolt at the best of times. '
          'Keeping distance and letting the animal move on in its own time '
          'is advisable.',
      SafetyCohort.deaf:
          'Animal warnings are often sound first, a hiss, buzz or bark. '
          'Extra visual scanning near bush, long grass and water is '
          'advisable.',
      SafetyCohort.vision:
          'Snakes and swooping birds are usually seen before heard. Asking '
          'exactly where the hazard is, and travelling with someone past '
          'it, is advisable.',
      SafetyCohort.visitor:
          'Australian wildlife is best admired from a distance, and animals '
          'cross roads most at dawn and dusk. Slowing down through this '
          'area is advisable.',
      SafetyCohort.worker:
          'Displaced wildlife turns up in sheds, sites and machinery after '
          'fire and flood. Checking before reaching in, and calling '
          'wildlife rescue rather than handling, is advisable.',
      SafetyCohort.pets:
          'Your pets are the most likely point of contact. Keeping dogs '
          'leashed and cats in until the animal hazard clears is advisable.',
    },
    'health_capacity': {
      SafetyCohort.older:
          'When hospitals are stretched, waits are longest for non urgent '
          'care. Handling routine matters by phone where possible is '
          'advisable. In an emergency, always seek help immediately.',
      SafetyCohort.kids:
          'Emergency departments triage children on urgency, not arrival '
          'time. For non urgent worries, trying a GP or nurse service first '
          'is advisable. Genuine emergencies always come first.',
      SafetyCohort.mobility:
          'Patient transport runs slower when the system is stretched. '
          'Booking accessible transport for appointments earlier than usual '
          'is advisable.',
      SafetyCohort.medical:
          'Keeping regular medication topped up matters more when services '
          'are stretched. Renewing scripts before you run low is advisable. '
          'Emergencies should never wait.',
      SafetyCohort.deaf:
          'Stretched hospitals have less time to arrange interpreters. '
          'Booking Auslan support ahead for planned visits, and stating '
          'your needs on arrival, is advisable.',
      SafetyCohort.vision:
          'Busy waiting rooms rely on called names and screens. Telling '
          'triage staff how to reach you when it is your turn is advisable.',
      SafetyCohort.visitor:
          'Travel insurance details speed everything up in an Australian '
          'hospital. Keeping your policy number with you while services are '
          'stretched is advisable.',
      SafetyCohort.worker:
          'If you work in or around care services, expecting longer '
          'handovers and confirming shift arrangements early is advisable.',
      SafetyCohort.pets:
          'Vets are often stretched by the same events as hospitals. '
          'Booking routine animal care ahead, and keeping pet medication '
          'topped up, is advisable.',
    },
    'evac_centre': {
      SafetyCohort.older:
          'Evacuation centres help with medication, mobility and quiet '
          'space if you ask at the desk. Arriving before dark is advisable.',
      SafetyCohort.kids:
          'Centres are calmer for kids with familiar things. Bringing '
          'comfort items, snacks and something to do is advisable.',
      SafetyCohort.mobility:
          'Centres are accessible, and arriving early helps staff set you '
          'up well. Mentioning your needs at the registration desk is '
          'advisable.',
      SafetyCohort.medical:
          'Centres can store and help manage medication. Bringing yours, '
          'with its usual instructions, and telling staff on arrival is '
          'advisable.',
      SafetyCohort.deaf:
          'Centre announcements are usually spoken. Telling registration '
          'staff you need written or signed updates is advisable; they will '
          'arrange it.',
      SafetyCohort.vision:
          'Centres are unfamiliar layouts by definition. Asking staff for '
          'an orientation walk on arrival is advisable.',
      SafetyCohort.visitor:
          'Evacuation centres are free and open to visitors too. '
          'Registering on arrival so family can find you is advisable.',
      SafetyCohort.worker:
          'If you are supporting others, registering yourself as well is '
          'advisable. Centres track who is safe, including helpers.',
      SafetyCohort.pets:
          'Many centres take pets, and some use a nearby animal shelter '
          'instead. Checking this alert for the pet arrangement before '
          'travelling is advisable.',
    },
    'heatwave': {
      SafetyCohort.older:
          'Heat builds in the body over consecutive days. Using the coolest '
          'room, drinking regularly and asking someone to check in daily is '
          'advisable.',
      SafetyCohort.kids:
          'Children overheat faster than adults, especially in cars. Never '
          'leaving kids in a parked car, and planning indoor hours over the '
          'peak, is advisable.',
      SafetyCohort.mobility:
          'Heat makes transfers and outdoor waits harder. Booking travel '
          'for early morning and allowing extra rest stops is advisable.',
      SafetyCohort.medical:
          'Some conditions and medications make heat harder to handle. '
          'Staying cool, drinking regularly and following your usual care '
          'plan is advisable.',
      SafetyCohort.deaf:
          'Heat warnings often extend day by day. Checking this app each '
          'evening for the next day\'s rating is advisable.',
      SafetyCohort.vision:
          'Glare is harshest over the heat peak. Planning travel for early '
          'or late in the day is advisable.',
      SafetyCohort.visitor:
          'Australian heat is drier and stronger than most visitors are '
          'used to. Planning sightseeing before mid morning and drinking '
          'more than feels necessary is advisable.',
      SafetyCohort.worker:
          'Outdoor work in a heatwave needs a plan, not toughness. Agreeing '
          'rest cycles, shade and water breaks with your site before your '
          'shift is advisable.',
      SafetyCohort.pets:
          'Animals overheat faster than people. Shade and extra water for '
          'pets and stock is standing advice. Never leave animals in '
          'vehicles.',
    },
    'cold_snap': {
      SafetyCohort.older:
          'Cold snaps raise risks indoors as much as outside. Heating the '
          'room you live in, and layering rather than relying on one '
          'heater, is advisable.',
      SafetyCohort.kids:
          'Kids lose heat faster than they notice. Layers, dry clothes '
          'after outdoor play and warm sleep spaces are advisable through '
          'the cold snap.',
      SafetyCohort.mobility:
          'Frost keeps ramps and paths slippery well after sunrise. Timing '
          'trips for the warmest part of the day is advisable.',
      SafetyCohort.medical:
          'Cold air and cold nights can worsen some conditions. Keeping '
          'warm, keeping medication close and heating your main room is '
          'advisable.',
      SafetyCohort.deaf:
          'Black ice gives no visual warning and no sound either. Assuming '
          'frost on shaded roads and paths through the morning is '
          'advisable.',
      SafetyCohort.vision:
          'Frost and black ice are invisible hazards by definition. Waiting '
          'for the day to warm before heading out, or taking an arm, is '
          'advisable.',
      SafetyCohort.visitor:
          'Australian buildings are often colder inside than visitors '
          'expect. Packing warm layers for indoors as well as out is '
          'advisable.',
      SafetyCohort.worker:
          'Early starts meet the coldest roads of the day. Allowing extra '
          'travel time and checking for ice on site is advisable.',
      SafetyCohort.pets:
          'Outdoor animals feel cold snaps hardest. Bringing pets in '
          'overnight, and giving stock windbreaks and unfrozen water, is '
          'advisable.',
    },
    'rough_surf': {
      SafetyCohort.older:
          'Rough surf can knock you down in ankle deep water. Enjoying the '
          'beach from well above the waterline is advisable.',
      SafetyCohort.kids:
          'Waves and rips take children first. Keeping kids out of the '
          'water, and away from rocks and drop offs, is advisable during a '
          'surf warning.',
      SafetyCohort.mobility:
          'Soft sand and surf spray make beach access points hazardous in '
          'rough conditions. Choosing lookouts over beach level until it '
          'calms is advisable.',
      SafetyCohort.medical:
          'A struggle in rough water is maximum exertion, instantly. '
          'Staying out of the water entirely during the warning is '
          'advisable.',
      SafetyCohort.deaf:
          'Surf lifesavers signal with whistles and megaphones. Swimming '
          'near the flags where you can see the signals, or staying out '
          'entirely, is advisable.',
      SafetyCohort.vision:
          'Rips and drop offs are read by eye. Staying out of the water '
          'during rough surf, and enjoying the coast from a safe distance, '
          'is advisable.',
      SafetyCohort.visitor:
          'Australian surf is stronger than it looks, and rips are the main '
          'danger. Swimming only between the red and yellow flags, and not '
          'at all during warnings, is advisable.',
      SafetyCohort.worker:
          'Rock platforms and breakwalls are wave traps in heavy swell. '
          'Postponing coastal work, or staying above the spray zone, is '
          'advisable.',
      SafetyCohort.pets:
          'Dogs chase waves with no sense of rips. Keeping dogs leashed '
          'near rough surf, and never going in after one, is advisable.',
    },
    'earthquake': {
      SafetyCohort.older:
          'Aftershocks follow the main tremor. Staying clear of brick walls '
          'and chimneys, and expecting a few more shakes, is advisable.',
      SafetyCohort.kids:
          'Children take their cue from adults after a tremor. Doing drop, '
          'cover and hold on together, then checking in calmly, is '
          'advisable.',
      SafetyCohort.mobility:
          'Drop, cover and hold on adapts to you: lock wheels, cover your '
          'head, stay put. Moving only after the shaking fully stops is '
          'advisable.',
      SafetyCohort.medical:
          'The safest move in a tremor is the least movement. Taking cover '
          'in place, and gathering medication once the shaking stops, is '
          'advisable.',
      SafetyCohort.deaf:
          'Aftershock updates come as alerts, not sound. Keeping vibration '
          'alerts on in the hours after a tremor is advisable.',
      SafetyCohort.vision:
          'Objects and broken glass shift underfoot after shaking. Sturdy '
          'shoes kept by the bed, and checking paths with a companion, is '
          'standing advice.',
      SafetyCohort.visitor:
          'Australian earthquakes are usually small but can surprise. Drop, '
          'cover and hold on, then following this app\'s updates, is '
          'advisable.',
      SafetyCohort.worker:
          'Buildings need checking before re-entry after a tremor. Waiting '
          'for your site\'s all clear rather than going straight back in is '
          'advisable.',
      SafetyCohort.pets:
          'Animals often bolt during tremors. Keeping pets contained '
          'afterwards, since fences and gates may have shifted, is '
          'advisable.',
    },
    'tsunami': {
      SafetyCohort.older:
          'A land warning means moving away from the coast, not watching '
          'it. Moving inland or uphill early, without rushing, is '
          'advisable.',
      SafetyCohort.kids:
          'A tsunami can arrive as many waves over hours. Moving kids '
          'inland early and staying away until the official all clear is '
          'advisable.',
      SafetyCohort.mobility:
          'Tsunami timing is uncertain, which favours the early mover. '
          'Heading inland or to a higher floor as soon as the warning lands '
          'is advisable.',
      SafetyCohort.medical:
          'Taking medication with you when you move is advisable; warnings '
          'can last hours. Moving early and calmly beats moving late.',
      SafetyCohort.deaf:
          'Coastal sirens are the traditional channel. Keeping vibration '
          'alerts on, and acting on this app\'s warning without waiting for '
          'confirmation, is advisable.',
      SafetyCohort.vision:
          'Ask anyone nearby to guide you to higher ground now — bystander '
          'help is expected in tsunami evacuations.',
      SafetyCohort.visitor:
          'In Australia a marine warning means leave the water and shore; a '
          'land warning means move inland. Following this alert\'s level is '
          'advisable.',
      SafetyCohort.worker:
          'If you work on or near the water, moving inland matters more '
          'than the gear. Securing only what is quick, then following the '
          'warning level, is advisable.',
      SafetyCohort.pets:
          'Taking pets with you when moving inland is advisable; returning '
          'can take hours. Keeping leads and carriers by the door helps.',
    },
    'school_holidays': {
      SafetyCohort.older:
          'School holidays change traffic and quiet hours. Timing errands '
          'for early morning, before attractions open, is advisable.',
      SafetyCohort.kids:
          'Holiday crowds peak at pools, parks and cinemas mid morning. '
          'Booking ahead where possible, and agreeing meeting points at '
          'busy venues, is advisable.',
      SafetyCohort.mobility:
          'Holiday crowds fill accessible parking early at popular spots. '
          'Arriving early, or choosing quieter days for outings, is '
          'advisable.',
      SafetyCohort.medical:
          'Busy holiday venues mean longer stretches away from home. '
          'Carrying medication rather than planning to duck back for it is '
          'advisable.',
      SafetyCohort.deaf:
          'More children about means more that is easy to miss around '
          'driveways and carparks. Extra visual checks in low speed areas '
          'are advisable.',
      SafetyCohort.vision:
          'Footpaths carry more scooters, bikes and prams in the holidays. '
          'Allowing extra time and taking familiar routes at quieter hours '
          'is advisable.',
      SafetyCohort.visitor:
          'Australian school holidays vary by state and fill accommodation '
          'fast. Booking travel and attractions ahead during these weeks is '
          'advisable.',
      SafetyCohort.worker:
          'Holiday traffic moves from school zones to attractions. Allowing '
          'extra time on routes past pools, beaches and shopping centres is '
          'advisable.',
      SafetyCohort.pets:
          'Parks are fuller and louder in the holidays. Walking dogs at '
          'quieter hours, and keeping them leashed around playing children, '
          'is advisable.',
    },
    'snakes': {
      SafetyCohort.older:
          'Snakes hold still and rely on not being seen. Sticking to clear '
          'paths, and wearing solid shoes in long grass, is advisable.',
      SafetyCohort.kids:
          'Children explore with their hands at snake height. Teaching kids '
          'to back away and tell an adult, never to touch, is advisable.',
      SafetyCohort.mobility:
          'Snakes rest on warm paths and ramps in the morning. Scanning '
          'ahead on sunny paths, and keeping to open routes, is advisable.',
      SafetyCohort.medical:
          'For any suspected bite, keeping completely still and calling '
          'emergency services immediately is the rule for everyone. Not '
          'driving yourself is advisable.',
      SafetyCohort.deaf:
          'A warning rustle or hiss is easy to miss. Extra visual scanning '
          'near long grass, water and wood piles is advisable.',
      SafetyCohort.vision:
          'Snakes are seen rather than heard, which makes shared awareness '
          'matter. Walking with someone in bush or long grass this season '
          'is advisable.',
      SafetyCohort.visitor:
          'Australian snakes avoid people given the chance. Solid shoes, '
          'staying on paths, and leaving any snake alone is advisable. '
          'Never try to move one.',
      SafetyCohort.worker:
          'Snakes shelter in sheds, pipes and machinery. Checking before '
          'reaching into dark spaces, and wearing gloves and boots, is '
          'advisable.',
      SafetyCohort.pets:
          'Curious dogs and cats meet most of the snakes. Keeping dogs '
          'leashed, cats in, and yards clear of long grass is advisable. '
          'Any strike means the vet, urgently.',
    },
    'fuel_supply': {
      SafetyCohort.older:
          'Fuel queues are usually worse than the shortage itself. Topping '
          'up at half a tank, at off peak times, is advisable rather than '
          'queuing on empty.',
      SafetyCohort.kids:
          'Long fuel queues are hard with kids aboard. Filling up before '
          'the school run, or at quiet hours, is advisable while supply is '
          'short.',
      SafetyCohort.mobility:
          'If accessible pumps are limited near you, shortages make them '
          'scarcer. Topping up early, before queues build, is advisable.',
      SafetyCohort.medical:
          'If driving supports your treatment or care, fuel is part of the '
          'care plan. Keeping the tank above half while this alert is '
          'active is advisable.',
      SafetyCohort.deaf:
          'Station closures are often announced on local radio first. '
          'Checking this app and fuel apps for live availability is '
          'advisable.',
      SafetyCohort.vision:
          'If you rely on lifts, your drivers will be juggling queues too. '
          'Booking transport earlier than usual while supply is short is '
          'advisable.',
      SafetyCohort.visitor:
          'Distances between stations here can exceed a full tank. Fuelling '
          'at every reasonable stop in affected areas is advisable.',
      SafetyCohort.worker:
          'If your work depends on driving, agreeing priority fuelling with '
          'your employer early in a shortage is advisable.',
      SafetyCohort.pets:
          'Queues in warm cars are hard on animals. Leaving pets at home '
          'when heading out for fuel is advisable.',
    },
  };
}
