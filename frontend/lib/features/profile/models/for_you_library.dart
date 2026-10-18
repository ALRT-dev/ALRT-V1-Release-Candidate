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
    if (name.contains('utilit')) return 'utility_outage';
    if (name.contains('chemical')) return 'chemical';
    return null;
  }

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
    (['chemical', 'hazmat', 'gas leak'], 'chemical'),
    (['smoke'], 'smoke'),
    (['flood'], 'flood'),
    (['storm'], 'severe_weather'),
    (['air quality'], 'air_quality'),
    (['unrest', 'protest', 'riot'], 'civil_unrest'),
    (['outbreak', 'measles', 'disease'], 'public_health'),
  ];

  /// hazard bucket -> cohort -> line (verbatim reviewed wording).
  /// hazard bucket -> cohort -> line. Simple, calm, one clear action each;
  /// no filler, no "is a good idea" tail. ALRT's general household guidance,
  /// never the agency's instruction.
  static const Map<String, Map<SafetyCohort, String>> rows = {
    'bushfire': {
      SafetyCohort.older: 'Leave early — fires move faster than anyone can walk. Have your phone, glasses and medicines in one bag now.',
      SafetyCohort.kids: 'Get kids packed and indoors early, and explain the plan calmly. They pick up on worry fast.',
      SafetyCohort.mobility: 'Leaving takes longer than the warning allows. Go before the Emergency Warning, and tell someone your route.',
      SafetyCohort.medical: 'Smoke and exertion both make things worse. Keep medication within reach and skip heavy work like yard clearing.',
      SafetyCohort.deaf: 'Sirens and doorknocks may not reach you. Keep vibration and screen flash on, and ask a neighbour to check in.',
      SafetyCohort.vision: 'Smoke cuts visibility for everyone. Arrange transport with a sighted person early.',
      SafetyCohort.visitor: 'Australian bushfires move faster than you would expect. Follow this area\'s official warning level and leave early if advised.',
      SafetyCohort.worker: 'If you are required on site, confirm your workplace fire plan and a route in and out before you travel.',
      SafetyCohort.pets: 'Get animals and carriers ready now, before smoke arrives. It is far harder later.',
    },
    'grass_fire': {
      SafetyCohort.older: 'Grass fires outrun anyone on foot. Leave early rather than stay to defend, and keep your phone with you.',
      SafetyCohort.kids: 'Grass fires can cut roads in minutes. Keep children close and do not drive toward smoke, even to pick them up.',
      SafetyCohort.mobility: 'Grass fires give little warning. Leave at the first sign of smoke, not when an official warning lands.',
      SafetyCohort.medical: 'Even brief smoke can trigger symptoms. Keep medication handy and pack essentials early.',
      SafetyCohort.deaf: 'Grass fires spread too fast for doorknocking. Keep vibration on and check the app when you see smoke.',
      SafetyCohort.vision: 'Fast smoke changes conditions quickly. Ask someone nearby to describe what they see and leave together.',
      SafetyCohort.visitor: 'Grass fires are common in Australian summers and move extremely fast. Follow local directions, do not stop to watch.',
      SafetyCohort.worker: 'Working outdoors nearby? Move vehicles and machinery off dry grass and agree a trigger point to stop.',
      SafetyCohort.pets: 'There is no time to search for a hiding pet. Bring animals in at the first sign of smoke, carriers ready.',
    },
    'flood': {
      SafetyCohort.older: 'Move medicines, glasses and essentials above floor level now, and leave early in daylight.',
      SafetyCohort.kids: 'Keep kids away from all water — even over the drain out front — it hides currents and sharp objects.',
      SafetyCohort.mobility: 'Floodwater makes surfaces impassable for wheels and unsteady feet. Move before water is anywhere near.',
      SafetyCohort.medical: 'Put medicines in a sealed bag you can grab, and get help with heavy work like sandbags rather than doing it alone.',
      SafetyCohort.deaf: 'Rising water at night gives little visual warning. Keep vibration on while you sleep and check levels before bed.',
      SafetyCohort.vision: 'Floodwater hides depth and edges, even on familiar streets. Arrange a sighted companion or transport before water rises.',
      SafetyCohort.visitor: 'Do not drive through floodwater, whatever your car handles at home. Vehicles are involved in many flood deaths.',
      SafetyCohort.worker: 'Check closures before leaving and agree an alternative with your employer. Do not drive through water over a road.',
      SafetyCohort.pets: 'Move stock to higher paddocks early and carry pets in carriers, not loose in vehicles.',
    },
    'cyclone': {
      SafetyCohort.older: 'Prep is heavy work. Ask for help securing loose items now, and know your nearest shelter.',
      SafetyCohort.kids: 'The noise frightens kids. Set up your shelter room with games, snacks and torches before the wind arrives.',
      SafetyCohort.mobility: 'Sheltering and evacuating are harder in high wind. Register early with local emergency services if you may need evacuation help.',
      SafetyCohort.medical: 'Power loss can hit medical equipment. Charge devices, stock medication and plan for outages before the cyclone arrives.',
      SafetyCohort.deaf: 'Warning changes come fast. Keep vibration on and have a torch handy for lip reading if power fails.',
      SafetyCohort.vision: 'Shelters change layout. Walk your shelter space while it is calm, and keep aids and a torch within reach.',
      SafetyCohort.visitor: 'Cyclone warnings here use categories 1 to 5. Follow your accommodation\'s instructions and stay inside through the eye.',
      SafetyCohort.worker: 'If you must work through it, agree a stand-down trigger with your employer before conditions deteriorate.',
      SafetyCohort.pets: 'Bring pets indoors with water and move stock away from trees and fences before winds arrive.',
    },
    'severe_weather': {
      SafetyCohort.older: 'Falls rise sharply in storms and on wet ground. Postpone errands and charge your phone now.',
      SafetyCohort.kids: 'Bring outdoor toys in, charge devices and plan an indoor afternoon.',
      SafetyCohort.mobility: 'Wet ramps, debris and blocked footpaths outlast the storm. Plan to stay in through the warning period.',
      SafetyCohort.medical: 'Storms stir pollen and dust, and cleanup is an overexertion trap. Keep medication close and pace heavy work.',
      SafetyCohort.deaf: 'Thunder is the warning most people rely on. Keep vibration on and watch the sky while the warning is active.',
      SafetyCohort.vision: 'Debris changes familiar paths. Keep aids charged and ask a neighbour to check outside routes before heading out.',
      SafetyCohort.visitor: 'Australian storms can be stronger than they look. Stay clear of trees, creeks and the coast during warnings.',
      SafetyCohort.worker: 'Agree when outdoor work stops before the front arrives. Stop outdoor work when lightning is close.',
      SafetyCohort.pets: 'Pets bolt in storms. Keep them indoors with ID and check gates and fencing afterwards.',
    },
    'heatwave': {
      SafetyCohort.older: 'Heat builds over days. Use the coolest room, drink regularly and ask someone to check in daily.',
      SafetyCohort.kids: 'Kids overheat faster than adults, especially in cars. Do not leave them in a parked car; plan indoor hours over the peak.',
      SafetyCohort.mobility: 'Heat makes transfers and outdoor waits harder. Book travel for early morning and allow extra rest stops.',
      SafetyCohort.medical: 'Some conditions and medications make heat harder to handle. Stay cool, drink regularly, follow your care plan.',
      SafetyCohort.deaf: 'Heat warnings extend day by day. Check the app each evening for the next day\'s rating.',
      SafetyCohort.vision: 'Glare is harshest over the peak. Plan travel for early or late in the day.',
      SafetyCohort.visitor: 'Australian heat is drier and stronger than you are used to. Plan sightseeing before mid-morning and drink more than feels necessary.',
      SafetyCohort.worker: 'Outdoor work in heat needs a plan, not toughness. Agree rest cycles, shade and water breaks before your shift.',
      SafetyCohort.pets: 'Animals overheat faster than people. Shade and extra water; do not leave them in vehicles.',
    },
    'smoke': {
      SafetyCohort.older: 'Smoke settles hardest on older lungs. Stay indoors with windows shut; cool the house rather than airing it.',
      SafetyCohort.kids: 'Smoke affects small lungs first. Keep windows shut and stay indoors while it is nearby.',
      SafetyCohort.mobility: 'If leaving is a big effort, one well-sealed room beats a late move. Choose your cleanest room and shut doors.',
      SafetyCohort.medical: 'Have medication on hand and limit exertion while smoke is nearby.',
      SafetyCohort.deaf: 'Smoke can arrive before any visible fire. Keep vibration and screen flash on while it is in your area.',
      SafetyCohort.vision: 'Smoke irritates eyes and flattens what vision remains. Stay indoors and postpone unfamiliar journeys.',
      SafetyCohort.visitor: 'Smoke can blanket areas far from any fire. Check air quality before outdoor plans and keep windows shut.',
      SafetyCohort.worker: 'Working outdoors? A properly fitted P2 mask and regular indoor breaks.',
      SafetyCohort.pets: 'Smoke affects animals too, especially birds and older pets. Bring them in and limit exercise.',
    },
    'air_quality': {
      SafetyCohort.older: 'Poor air days are hardest on older lungs and hearts. Keep activity light and stay indoors during the worst hours.',
      SafetyCohort.kids: 'Children take in more air for their size. Move play indoors and keep windows shut on poor air days.',
      SafetyCohort.mobility: 'If getting out takes real effort, timing matters more. Plan essential trips for when air quality improves.',
      SafetyCohort.medical: 'Poor air can build symptoms slowly. Follow your usual care plan, keep medication within reach and skip strenuous activity.',
      SafetyCohort.deaf: 'Air quality changes silently. Check the app\'s readings morning and evening while this alert is active.',
      SafetyCohort.vision: 'Haze flattens contrast and landmarks. Allow extra time for travel, or delay it, while visibility is reduced.',
      SafetyCohort.visitor: 'Air quality here can shift quickly with wind and fire. Check readings before hikes or runs while this alert is active.',
      SafetyCohort.worker: 'For outdoor work, more frequent breaks and a properly fitted P2 mask while air quality remains poor.',
      SafetyCohort.pets: 'Poor air affects animals too, especially birds and flat-faced breeds. Keep pets indoors and walks short.',
    },
    'chemical': {
      SafetyCohort.older: 'Chemical incidents usually call for shelter, not evacuation. Go indoors, shut windows and turn off the aircon.',
      SafetyCohort.kids: 'Kids are more affected by fumes. Bring them indoors, shut windows and turn off any air intake.',
      SafetyCohort.mobility: 'Shelter in place is the usual advice here, which works in your favour. Seal your room and wait until officials say it is over.',
      SafetyCohort.medical: 'Fumes and stress both trigger symptoms quickly. Seal your room, keep medication with you, and seek help early if symptoms start.',
      SafetyCohort.deaf: 'Hazmat instructions are often given by loudspeaker. Keep vibration on and check the app for the written "over" update.',
      SafetyCohort.vision: 'Chemical incidents rely on visual cordons and signage. Stay indoors and ask someone to confirm when officials say it is over.',
      SafetyCohort.visitor: 'Australian practice is shelter in place unless police say leave. Go indoors and follow this app\'s updates.',
      SafetyCohort.worker: 'If your site is inside the cordon, follow your workplace\'s hazmat procedure and do not re-enter until cleared.',
      SafetyCohort.pets: 'Pets shelter with you. Bring them in now and keep them in until officials say it is over.',
    },
    'structure_fire': {
      SafetyCohort.older: 'Building fires can spread to neighbours. If you are close, prepare to leave before you are told.',
      SafetyCohort.kids: 'Fire trucks draw kids toward the scene. Keep them indoors and away from windows near a building fire.',
      SafetyCohort.mobility: 'If you are in an affected or neighbouring building, start your exit early. Do not wait for it to worsen.',
      SafetyCohort.medical: 'Structure fires produce heavy, toxic smoke. Stay indoors with windows shut if nearby; move calmly with medication if you leave.',
      SafetyCohort.deaf: 'Building alarms are sound-first. If you are near, watch for others evacuating and keep vibration on.',
      SafetyCohort.vision: 'Smoke and crews change familiar exits. Ask for guidance early rather than navigating alone.',
      SafetyCohort.visitor: 'If your hotel or hostel is nearby, follow staff instructions and take your passport if you evacuate.',
      SafetyCohort.worker: 'Expect cordons around the block. Check access before travelling in.',
      SafetyCohort.pets: 'Smoke and sirens carry further than the cordon. Keep pets indoors and walks away from the scene.',
    },
    'utility_outage': {
      SafetyCohort.older: 'Outages hit lifts, hot water and phones together. Check your phone\'s charge now and keep a torch within reach.',
      SafetyCohort.kids: 'Outages unsettle bedtime fast. Find torches before dark and charge a device for the kids now.',
      SafetyCohort.mobility: 'If lifts or powered doors are part of your route, plan around them before you need them.',
      SafetyCohort.medical: 'If powered equipment or refrigerated medication applies, act on your backup plan early, before batteries run down.',
      SafetyCohort.deaf: 'Outage updates often come by radio. This app and SMS from your provider are the written channels. Keep vibration on.',
      SafetyCohort.vision: 'An outage removes the lighting others rely on. Check on neighbours who may be struggling in the dark.',
      SafetyCohort.visitor: 'Outages can affect card payments and fuel pumps. Keep some cash and a charged phone while the outage lasts.',
      SafetyCohort.worker: 'If your work depends on this utility, confirm with your site before travelling in.',
      SafetyCohort.pets: 'Aquariums, heat lamps and electric fences stop with the power. Check any animal setup that relies on it early.',
    },
    'dust_storm': {
      SafetyCohort.older: 'Dust is hard on lungs and visibility together. Stay indoors with windows shut until the front passes.',
      SafetyCohort.kids: 'Dust storms pass quickly but hit small lungs hard. Keep children indoors and windows shut until it clears.',
      SafetyCohort.mobility: 'A dust storm outlasts most short trips. Wait it out indoors rather than pushing through.',
      SafetyCohort.medical: 'Dust can trigger breathing and heart symptoms fast. Stay indoors with medication close until the air clears.',
      SafetyCohort.deaf: 'Dust fronts arrive with almost no sound. Keep vibration on and check the horizon before driving.',
      SafetyCohort.vision: 'Dust cuts everyone\'s vision to near zero. Stay indoors, and ask others nearby whether it has passed.',
      SafetyCohort.visitor: 'If a dust storm hits while driving, the local practice is to pull right off the road with lights off. Wait it out.',
      SafetyCohort.worker: 'Dust ends fine outdoor tasks and driving visibility fast. Pause work and seal machinery cabs until it passes.',
      SafetyCohort.pets: 'Dust irritates animals\' eyes and lungs too. Bring pets in, and give stock shelter and clean water.',
    },
    'pollen': {
      SafetyCohort.older: 'High pollen days can affect breathing even without a hay fever history. Keep outdoor time short and windows shut.',
      SafetyCohort.kids: 'Pollen peaks in the morning and early evening. Time outdoor play around those windows on high pollen days.',
      SafetyCohort.mobility: 'If your routes pass parks or grassland, exposure is higher. Plan trips for after rain, when pollen drops.',
      SafetyCohort.medical: 'High pollen plus a storm can trigger thunderstorm asthma, even with only hay fever. Stay indoors before storm fronts, with medication close.',
      SafetyCohort.deaf: 'Pollen warnings are easy to miss in spoken forecasts. Check the app\'s alerts on spring storm days.',
      SafetyCohort.vision: 'Itchy, watering eyes make remaining vision harder to use. Keep windows shut and limit time outside on peak days.',
      SafetyCohort.visitor: 'Southern Australia\'s spring pollen is severe by world standards. Take hay fever seriously here, especially before storms.',
      SafetyCohort.worker: 'Mowing, landscaping and outdoor work spike exposure on high pollen days. A mask and shorter stints.',
      SafetyCohort.pets: 'Pets carry pollen inside in their coats. Wipe coats down after walks on high pollen days.',
    },
    'haze': {
      SafetyCohort.older: 'Haze usually means fine particles, even when you cannot smell smoke. Keep activity light and indoors until it lifts.',
      SafetyCohort.kids: 'Haze is easy to underestimate because it looks calm. Keep play indoors and windows shut while it lingers.',
      SafetyCohort.mobility: 'Haze can linger for days rather than hours. Time essential trips for the clearest part of the day.',
      SafetyCohort.medical: 'Haze can build symptoms slowly. Keep medication within reach and limit exertion until it clears.',
      SafetyCohort.deaf: 'Haze arrives without a sound. Check the app\'s air readings while visibility stays low.',
      SafetyCohort.vision: 'Haze removes the contrast that landmarks rely on. Allow extra time, or delay unfamiliar trips.',
      SafetyCohort.visitor: 'Haze here can come from fires hundreds of kilometres away. Check air quality readings rather than judging by smell.',
      SafetyCohort.worker: 'Haze lowers air quality and driving visibility together. Headlights on, longer following gaps, and indoor breaks.',
      SafetyCohort.pets: 'Haze affects animals the same way it affects you. Shorter walks and indoor time until it lifts.',
    },
    'water_quality': {
      SafetyCohort.older: 'Water alerts usually mean boiling before drinking or brushing teeth. Follow the alert\'s exact instructions until cleared.',
      SafetyCohort.kids: 'Children swallow more water in baths and pools. Follow the alert\'s advice for drinking, teeth and bathing until the agency says the water is fine.',
      SafetyCohort.mobility: 'If collecting bottled water is difficult, ask a neighbour or your council for help early, before supplies thin out.',
      SafetyCohort.medical: 'Water quality matters more with a medical condition. Use boiled or bottled water for drinking and taking medication until cleared.',
      SafetyCohort.deaf: 'Boil-water notices often spread by radio and doorknock. This alert carries the full written advice; check it for updates.',
      SafetyCohort.vision: 'Affected water usually looks completely normal. Treat all tap water as per this alert, rather than judging by sight.',
      SafetyCohort.visitor: 'Tap water in Australia is normally trusted, so a water alert here is genuine. Use bottled or boiled water until the agency says it is fine.',
      SafetyCohort.worker: 'If your work uses mains water for food, drink or care, check whether this alert changes your site\'s procedures before your shift.',
      SafetyCohort.pets: 'Water warnings apply to animals too, especially algae warnings. Keep pets and stock away from affected water and on a clean supply.',
    },
    'wildlife': {
      SafetyCohort.older: 'Startled animals are unpredictable at close range. Give them space and take a different path.',
      SafetyCohort.kids: 'Children read animals as friendly by default. Keep kids close, and teach look but do not touch, even for animals that seem calm.',
      SafetyCohort.mobility: 'An animal blocking a path can mean a real detour. Check the location on the map and choose an alternative route early.',
      SafetyCohort.medical: 'A sudden animal encounter is a jolt at the best of times. Keep distance and let the animal move on in its own time.',
      SafetyCohort.deaf: 'Animal warnings are often sound first, a hiss, buzz or bark. Extra visual scanning near bush, long grass and water.',
      SafetyCohort.vision: 'Snakes and swooping birds are usually seen before heard. Ask exactly where the hazard is, and travel with someone past it.',
      SafetyCohort.visitor: 'Australian wildlife is best admired from a distance, and animals cross roads most at dawn and dusk. Slow down through this area.',
      SafetyCohort.worker: 'Displaced wildlife turns up in sheds, sites and machinery after fire and flood. Check before reaching in, and call wildlife rescue rather than handling.',
      SafetyCohort.pets: 'Your pets are the most likely point of contact. Keep dogs leashed and cats in until the animal hazard clears.',
    },
    'health_capacity': {
      SafetyCohort.older: 'When hospitals are stretched, waits are longest for non-urgent care. Handle routine matters by phone where possible. If you are experiencing an emergency, call your local emergency number.',
      SafetyCohort.kids: 'Emergency departments triage children on urgency, not arrival time. For non-urgent worries, try a GP or nurse service first. If you are experiencing an emergency, call your local emergency number.',
      SafetyCohort.mobility: 'Patient transport runs slower when the system is stretched. Book accessible transport for appointments earlier than usual.',
      SafetyCohort.medical: 'Keeping regular medication topped up matters more when services are stretched. Renew scripts before you run low. If you are experiencing an emergency, call your local emergency number.',
      SafetyCohort.deaf: 'Stretched hospitals have less time to arrange interpreters. Book Auslan support ahead for planned visits, and state your needs on arrival.',
      SafetyCohort.vision: 'Busy waiting rooms rely on called names and screens. Tell triage staff how to reach you when it is your turn.',
      SafetyCohort.visitor: 'Travel insurance details speed everything up in an Australian hospital. Keep your policy number with you while services are stretched.',
      SafetyCohort.worker: 'If you work in or around care services, expect longer handovers and confirm shift arrangements early.',
      SafetyCohort.pets: 'Vets are often stretched by the same events as hospitals. Book routine animal care ahead, and keep pet medication topped up.',
    },
    'evac_centre': {
      SafetyCohort.older: 'Evacuation centres help with medication, mobility and quiet space if you ask at the desk. Arrive before dark.',
      SafetyCohort.kids: 'Centres are calmer for kids with familiar things. Bring comfort items, snacks and something to do.',
      SafetyCohort.mobility: 'Centres usually have accessible facilities, and arriving early helps staff set you up well. Mention your needs at the registration desk.',
      SafetyCohort.medical: 'Centres can store and help manage medication. Bring yours, with its usual instructions, and tell staff on arrival.',
      SafetyCohort.deaf: 'Centre announcements are usually spoken. Tell registration staff you need written or signed updates; staff can usually arrange it.',
      SafetyCohort.vision: 'Centres are unfamiliar layouts by definition. Ask staff for an orientation walk on arrival.',
      SafetyCohort.visitor: 'Evacuation centres are usually free and open to visitors too. Register on arrival so family can find you.',
      SafetyCohort.worker: 'If you are supporting others, register yourself as well. Centres keep a record of who has arrived, including helpers.',
      SafetyCohort.pets: 'Many centres take pets, and some use a nearby animal shelter instead. Check this alert for the pet arrangement before travelling.',
    },
    'cold_snap': {
      SafetyCohort.older: 'Cold snaps raise risks indoors as much as outside. Heat the room you live in, and layer rather than relying on one heater.',
      SafetyCohort.kids: 'Kids lose heat faster than they notice. Layers, dry clothes after outdoor play and warm sleep spaces through the cold snap.',
      SafetyCohort.mobility: 'Frost keeps ramps and paths slippery well after sunrise. Time trips for the warmest part of the day.',
      SafetyCohort.medical: 'Cold air and cold nights can worsen some conditions. Keep warm, keep medication close and heat your main room.',
      SafetyCohort.deaf: 'Black ice gives no visual warning and no sound either. Assume frost on shaded roads and paths through the morning.',
      SafetyCohort.vision: 'Frost and black ice are invisible hazards by definition. Wait for the day to warm before heading out, or take an arm.',
      SafetyCohort.visitor: 'Australian buildings are often colder inside than visitors expect. Pack warm layers for indoors as well as out.',
      SafetyCohort.worker: 'Early starts meet the coldest roads of the day. Allow extra travel time and check for ice on site.',
      SafetyCohort.pets: 'Outdoor animals feel cold snaps hardest. Bring pets in overnight, and give stock windbreaks and unfrozen water.',
    },
    'rough_surf': {
      SafetyCohort.older: 'Rough surf can knock you down in ankle-deep water. Enjoy the beach from well above the waterline.',
      SafetyCohort.kids: 'Waves and rips take children first. Keep kids out of the water, and away from rocks and drop-offs, during a surf warning.',
      SafetyCohort.mobility: 'Soft sand and surf spray make beach access points hazardous in rough conditions. Choose lookouts over beach level until it calms.',
      SafetyCohort.medical: 'A struggle in rough water is maximum exertion, instantly. Stay out of the water entirely during the warning.',
      SafetyCohort.deaf: 'Surf lifesavers signal with whistles and megaphones. Swim near the flags where you can see the signals, or stay out entirely.',
      SafetyCohort.vision: 'Rips and drop-offs are read by eye. Stay out of the water during rough surf, and enjoy the coast from a distance.',
      SafetyCohort.visitor: 'Australian surf is stronger than it looks, and rips are the main danger. Swim only between the red and yellow flags, and not at all during warnings.',
      SafetyCohort.worker: 'Rock platforms and breakwalls are wave traps in heavy swell. Postpone coastal work, or stay above the spray zone.',
      SafetyCohort.pets: 'Dogs chase waves with no sense of rips. Keep dogs leashed near rough surf, and do not go in after one.',
    },
    'earthquake': {
      SafetyCohort.older: 'Aftershocks follow the main tremor. Stay clear of brick walls and chimneys, and expect a few more shakes.',
      SafetyCohort.kids: 'Children take their cue from adults after a tremor. Do drop, cover and hold on together, then check in calmly.',
      SafetyCohort.mobility: 'Drop, cover and hold on adapts to you: lock wheels, cover your head, stay put. Move only after the shaking fully stops.',
      SafetyCohort.medical: 'The best move in a tremor is the least movement. Take cover in place and gather medication once the shaking stops.',
      SafetyCohort.deaf: 'Aftershock updates come as alerts, not sound. Keep vibration on in the hours after a tremor.',
      SafetyCohort.vision: 'Objects and broken glass shift underfoot after shaking. Keep sturdy shoes by the bed and check paths with a companion.',
      SafetyCohort.visitor: 'Australian earthquakes are usually small but can surprise. Drop, cover and hold on, then follow this app\'s updates.',
      SafetyCohort.worker: 'Buildings need checking before re-entry after a tremor. Wait for your site to confirm re-entry rather than going straight back in.',
      SafetyCohort.pets: 'Animals often bolt during tremors. Keep them contained afterwards, since fences and gates may have shifted.',
    },
    'tsunami': {
      SafetyCohort.older: 'A land warning means moving away from the coast, not watching it. Move inland or uphill early, without rushing.',
      SafetyCohort.kids: 'A tsunami can arrive as many waves over hours. Move kids inland early and stay away until officials say it is over.',
      SafetyCohort.mobility: 'Tsunami timing is uncertain, which favours the early mover. Head inland or to a higher floor as soon as the warning lands.',
      SafetyCohort.medical: 'Take medication with you; warnings can last hours. Moving early and calmly beats moving late.',
      SafetyCohort.deaf: 'Coastal sirens are the traditional channel. Keep vibration on, and act on this app\'s warning without waiting for confirmation.',
      SafetyCohort.vision: 'Ask anyone nearby to guide you to higher ground now. Bystander help is expected in tsunami evacuations.',
      SafetyCohort.visitor: 'In Australia a marine warning means leave the water and shore; a land warning means move inland. Follow this alert\'s level.',
      SafetyCohort.worker: 'Moving inland matters more than the gear. Secure only what is quick, then follow the warning level.',
      SafetyCohort.pets: 'Take pets with you when moving inland; returning can take hours. Keep leads and carriers by the door.',
    },
    'school_holidays': {
      SafetyCohort.older: 'School holidays change traffic and quiet hours. Time errands for early morning, before attractions open.',
      SafetyCohort.kids: 'Holiday crowds peak at pools, parks and cinemas mid-morning. Book ahead where possible, and agree meeting points at busy venues.',
      SafetyCohort.mobility: 'Holiday crowds fill accessible parking early at popular spots. Arrive early, or choose quieter days for outings.',
      SafetyCohort.medical: 'Busy holiday venues mean longer stretches away from home. Carry medication rather than planning to duck back for it.',
      SafetyCohort.deaf: 'More children about means more that is easy to miss around driveways and carparks. Extra visual checks in low-speed areas.',
      SafetyCohort.vision: 'Footpaths carry more scooters, bikes and prams in the holidays. Allow extra time and take familiar routes at quieter hours.',
      SafetyCohort.visitor: 'Australian school holidays vary by state and fill accommodation fast. Book travel and attractions ahead during these weeks.',
      SafetyCohort.worker: 'Holiday traffic moves from school zones to attractions. Allow extra time on routes past pools, beaches and shopping centres.',
      SafetyCohort.pets: 'Parks are fuller and louder in the holidays. Walk dogs at quieter hours, and keep them leashed around playing children.',
    },
    'snakes': {
      SafetyCohort.older: 'Snakes hold still and rely on not being seen. Stick to clear paths and wear solid shoes in long grass.',
      SafetyCohort.kids: 'Children explore with their hands at snake height. Teach kids to back away, tell an adult and not to touch.',
      SafetyCohort.mobility: 'Snakes rest on warm paths and ramps in the morning. Scan ahead on sunny paths and keep to open routes.',
      SafetyCohort.medical: 'For any suspected bite, keep completely still and do not drive yourself. If you are experiencing an emergency, call your local emergency number.',
      SafetyCohort.deaf: 'A warning rustle or hiss is easy to miss. Scan extra near long grass, water and wood piles.',
      SafetyCohort.vision: 'Snakes are seen rather than heard. Walk with someone in bush or long grass this season.',
      SafetyCohort.visitor: 'Snakes avoid people given the chance. Solid shoes, stay on paths, and leave any snake alone. Do not try to move one.',
      SafetyCohort.worker: 'Snakes shelter in sheds, pipes and machinery. Check before reaching into dark spaces; wear gloves and boots.',
      SafetyCohort.pets: 'Curious dogs and cats meet most of the snakes. Keep dogs leashed, cats in, and yards clear of long grass. After any suspected strike, see a vet urgently.',
    },
    'fuel_supply': {
      SafetyCohort.older: 'Fuel queues are usually worse than the shortage itself. Top up at half a tank, at off-peak times, rather than queuing on empty.',
      SafetyCohort.kids: 'Long fuel queues are hard with kids aboard. Fill up before the school run, or at quiet hours, while supply is short.',
      SafetyCohort.mobility: 'If accessible pumps are limited near you, shortages make them scarcer. Top up early, before queues build.',
      SafetyCohort.medical: 'If driving supports your treatment or care, fuel is part of the care plan. Keep the tank above half while this alert is active.',
      SafetyCohort.deaf: 'Station closures are often announced on local radio first. Check this app and fuel apps for live availability.',
      SafetyCohort.vision: 'If you rely on lifts, your drivers will be juggling queues too. Book transport earlier than usual while supply is short.',
      SafetyCohort.visitor: 'Distances between stations here can exceed a full tank. Fuel at every reasonable stop in affected areas.',
      SafetyCohort.worker: 'If your work depends on driving, agree priority fuelling with your employer early in a shortage.',
      SafetyCohort.pets: 'Queues in warm cars are hard on animals. Leave pets at home when heading out for fuel.',
    },
    'shark': {
      SafetyCohort.older: 'Sharks can be a risk close to shore too. Stay out of the water while the alert is active; enjoy the beach from the sand.',
      SafetyCohort.kids: 'Children are harder to watch in the water. Keep kids out and off the shoreline edge while the alert is active.',
      SafetyCohort.mobility: 'Leaving the water quickly is harder with limited mobility. Choose dry beach activities while the alert is active.',
      SafetyCohort.medical: 'A sudden scare in the water strains the heart and breathing. Stay out of the water while the alert is active.',
      SafetyCohort.deaf: 'Beach sirens and lifesaver calls may not reach you. Keep vibration on and watch for flags and signs.',
      SafetyCohort.vision: 'Warning flags and signs are visual. Ask a lifeguard or someone with you about conditions before entering the water.',
      SafetyCohort.visitor: 'Local beach warnings apply to you too. Check flags and signs and stay out of the water while the alert is active.',
      SafetyCohort.worker: 'If your work is on or in the water, check with your supervisor before starting and follow any stand-down.',
      SafetyCohort.pets: 'Dogs swim after anything. Keep them leashed and out of the water while the alert is active.',
    },
    'crocodile': {
      SafetyCohort.older: 'Crocodiles can be close to the water\'s edge. Keep well back from banks, jetties and boat ramps.',
      SafetyCohort.kids: 'Children go close to the water\'s edge without thinking. Keep kids well back from banks, creeks and boat ramps.',
      SafetyCohort.mobility: 'Jetties and boat ramps put you near the water\'s edge. Choose spots away from the edge while the alert is active.',
      SafetyCohort.medical: 'A sudden animal encounter is a shock to the body. Stay well back from the water\'s edge.',
      SafetyCohort.deaf: 'Crocodile warnings rely on signs and word of mouth. Read local signs and check this app for updates.',
      SafetyCohort.vision: 'Warning signs are visual. Ask someone with you to read local signs and describe the water\'s edge.',
      SafetyCohort.visitor: 'In northern Australia, any waterway can hold crocodiles. Obey local signs, stay out of the water and away from the edge.',
      SafetyCohort.worker: 'If working near waterways, check your site\'s crocodile controls and stay back from the edge.',
      SafetyCohort.pets: 'Dogs at the water\'s edge are at risk. Keep dogs leashed and away from banks.',
    },
    'landslide': {
      SafetyCohort.older: 'Slopes can give way with little warning after heavy rain. Stay away from steep slopes and cuttings, and move early if you live below one.',
      SafetyCohort.kids: 'Children are drawn to mud and rubble. Keep kids away from slopes, cuttings and slip debris.',
      SafetyCohort.mobility: 'Roads and paths near slopes can close suddenly. Check your route before leaving and choose flatter alternatives.',
      SafetyCohort.medical: 'Closed roads can delay care and supplies. Keep medication stocked and check access routes early.',
      SafetyCohort.deaf: 'Slope movement can be silent. Keep vibration on and heed barriers and signs.',
      SafetyCohort.vision: 'Debris changes familiar paths. Avoid the area, and ask someone to check the route first.',
      SafetyCohort.visitor: 'Tracks and roads in steep country can close after rain. Check local advice before hikes and drives, and stay out of closed areas.',
      SafetyCohort.worker: 'If your work is near slopes or cuttings, check with your site before entering and follow any exclusion zone.',
      SafetyCohort.pets: 'Pets investigate rubble and fresh slips. Keep them away from slopes and debris.',
    },
    'tornado': {
      SafetyCohort.older: 'Tornadoes give very little notice. Move to an inner room or the lowest floor, away from windows, when a warning applies to you.',
      SafetyCohort.kids: 'Frightened children need a calm plan. Keep kids close and move together to an inner room away from windows.',
      SafetyCohort.mobility: 'Moving to shelter takes longer with limited mobility. Choose your inner room now, before a warning.',
      SafetyCohort.medical: 'Power loss can follow a tornado. Keep medication close and devices charged.',
      SafetyCohort.deaf: 'Sirens and shouted warnings may not reach you. Keep vibration on and check this app for the latest warning.',
      SafetyCohort.vision: 'Debris changes familiar paths quickly. Stay in your shelter room until officials say it is over, and ask for help to move around afterwards.',
      SafetyCohort.visitor: 'Tornadoes are rare in Australia but can happen with severe storms. Follow the warning and your accommodation\'s instructions.',
      SafetyCohort.worker: 'If working outdoors, stop work and move to solid shelter when a warning applies to you.',
      SafetyCohort.pets: 'Pets often bolt in storms. Bring them indoors with identification before the storm arrives.',
    },
    'civil_unrest': {
      SafetyCohort.older: 'Crowded, volatile areas are hardest to leave quickly. Avoid the area entirely until it settles.',
      SafetyCohort.kids: 'Crowds and children separate easily. Avoid the area with kids, and agree a meeting point if you must be nearby.',
      SafetyCohort.mobility: 'Moving against a crowd is the hardest move there is. Stay well clear of the area rather than skirting its edge.',
      SafetyCohort.medical: 'Crowd control agents and stress can both trigger symptoms. Stay upwind and well away, with medication on hand.',
      SafetyCohort.deaf: 'Police move-on directions are usually shouted. Keep visual distance from any crowd and follow this app\'s updates.',
      SafetyCohort.vision: 'Crowd situations change too fast to navigate without sight. Avoid the area completely, and travel with someone if nearby.',
      SafetyCohort.visitor: 'Steer well clear of protests. Involvement can affect visas, and crowd dynamics are hard to read in an unfamiliar city.',
      SafetyCohort.worker: 'If your workplace is inside the affected area, contact your employer before travelling in, and use an agreed entrance.',
      SafetyCohort.pets: 'Crowds and noise panic animals. Walk dogs well away from the area until it settles.',
    },
    'public_health': {
      SafetyCohort.older: 'Older adults are usually the first group health alerts apply to. Read this alert\'s specific advice and act on it early.',
      SafetyCohort.kids: 'Health alerts often carry specific advice for children. Check whether schools or childcare are affected.',
      SafetyCohort.mobility: 'If the advice means avoiding certain places, plan accessible alternatives early, before options thin out.',
      SafetyCohort.medical: 'Health alerts can matter more with a medical condition. Follow the alert\'s specific guidance alongside your usual care plan.',
      SafetyCohort.deaf: 'Health advice often updates through radio and press conferences. Rely on this app and official websites for written updates.',
      SafetyCohort.vision: 'Maps and signage often carry health advice. The alert text here carries the same advice in full, with key actions first.',
      SafetyCohort.visitor: 'Local health alerts apply to visitors too, and your travel insurer may ask whether you followed them. Read the specific advice.',
      SafetyCohort.worker: 'If you work with the public, check whether this alert changes your workplace\'s requirements before your shift.',
      SafetyCohort.pets: 'Some health alerts cover animals too, such as water or algae warnings. Check whether this one affects pets.',
    },
  };
  /// Region-agnostic For You guidance for global/GDACS events. No country
  /// references — general household response that applies anywhere, so a
  /// reader in another country is never handed "Australian earthquakes are
  /// usually small". Used when the alert is a global humanitarian event.
  static const Map<SafetyCohort, String> globalRows = {
    SafetyCohort.older:
        'Older adults are most at risk in a fast-moving emergency. Moving early and calmly, rather than waiting to see, is the safer choice.',
    SafetyCohort.kids:
        'Keep children close and explain the plan calmly. They pick up on worry fast.',
    SafetyCohort.mobility:
        'Leaving takes longer than warnings allow. Go early and tell someone your route.',
    SafetyCohort.medical:
        'Keep medication and essentials together, and seek help early if symptoms start.',
    SafetyCohort.deaf:
        'Sirens and loudspeakers may not reach you. Keep vibration and screen-flash alerts on.',
    SafetyCohort.vision:
        'Ask someone nearby to guide you, and agree a meeting point early.',
    SafetyCohort.visitor:
        'Follow local instructions and keep your passport and essentials together.',
    SafetyCohort.worker:
        'If required on site, confirm the plan and a route in and out before you travel.',
    SafetyCohort.pets:
        'Bring animals and carriers with you — returning can take hours.',
  };
}
