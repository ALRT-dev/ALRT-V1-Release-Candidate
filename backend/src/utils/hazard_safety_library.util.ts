import type { GuidanceEntry } from "./alert_templates.util.js";

/**
 * ALRT safety advice library (owner direction, 9 November 2026 evening):
 * two to four practical, hazard-specific points for every main hazard type,
 * used to top up What to do when the agency gives fewer than two
 * instructions. Rules for every line: practical and calm; no numbers, places
 * or phone numbers; never a leave, evacuate, shelter, stay or return
 * direction (only the agency gives those); always shown labelled as ALRT's.
 *
 * Drafted 9 November 2026 from the official guidance named in each
 * reference, for the product owner's review. Merging this library into the
 * published template is the owner's approval step (Alert Templates, then
 * preview and publish).
 */
const REVIEWED = "2026-11-09";
const AU = ["AU"];

const groups = {
  bushfire: ["bushfire", "plannedBurn", "fireWeather"],
  otherFire: ["otherFire", "structuralFire", "vehicleFire"],
  smoke: ["smoke", "smokePlume", "airQualityAlert", "asthmaAlert", "ashfall"],
  flood: ["flood", "riverRise", "heavyRain", "waterOverRoad", "damSafety", "damSpill", "damOverflow", "damDischarge"],
  storm: ["storm", "damagingWinds", "strongWinds", "largeHail", "hailStorm", "treeDown", "cyclone"],
  heat: ["extremeHeat", "heatHealthAlert", "heatStress"],
  earthquake: ["earthquake"],
  tsunami: ["tsunami"],
  coast: ["hazardousSurf", "coastalHazard"],
  dust: ["dustStorm"],
  landslide: ["landslide", "landSlip"],
  road: ["crash", "accident", "rescueRoad", "roadClosure", "laneClosure", "roadWork", "roadDamage", "maintenance", "changedTrafficConditions", "speedReduction", "breakdown", "obstruction", "debrisOnRoad", "spillOnRoad", "trafficSignalFailure", "trafficLightFlashingYellow", "trafficCongestion", "detour", "generalHazard"],
  transport: ["railDisruption", "trainDisruption", "tramDisruption", "ferryDisruption", "railDelay", "trainDelay", "ferryDelay", "ferryCancellation", "busReplacement", "publicTransportCrowding", "flightDelay", "airportClosure", "taxiwayClosure"],
  power: ["powerOutage", "powerInterruption", "lossOfPower", "brownout", "electricalHazard"],
  gas: ["gasLeak", "gasIncident"],
  hazmat: ["chemicalSpill", "hazmatSpill", "hazardousItem"],
  water: ["boilWaterNotice", "boilWaterAlert", "waterIssue", "waterSupplyInterruption", "pipeBurst", "sewerOverflow"],
  telco: ["telecommunicationsOutage", "phoneOutage", "mobileOutage", "networkOutage", "serviceDisruption"],
  publicHealth: ["publicHealthAlert", "diseaseOutbreak", "outbreak", "infection", "virus", "pandemic"],
  algae: ["algaeBloom"],
  crime: ["crime", "terror"],
  events: ["concertFestival", "protest", "largeSportingEvent"],
  wildlife: ["sharkSighting", "snakeSighting"],
} satisfies Record<string, string[]>;

type Band = GuidanceEntry["bands"][number];
const ALL: Band[] = [];
const ACTIVE: Band[] = ["monitor", "action", "critical"];
const HIGH: Band[] = ["action", "critical"];
const CRITICAL: Band[] = ["critical"];

function entry(id: string, group: keyof typeof groups, text: string, bands: Band[], reference: string, countries = AU): GuidanceEntry {
  return {
    id: `safety-${id}`, text, categoryIds: [...groups[group]], countries, bands,
    profileTags: [], approved: true, reviewedAt: REVIEWED,
    reference: `Drafted for owner review from: ${reference}`,
  };
}

const SOURCES = {
  dfesBushfire: "DFES, During a bushfire (dfes.wa.gov.au/hazard-information/bushfire/during); My Bushfire Plan, Stay informed (mybushfireplan.wa.gov.au/stay-informed)",
  smokeHealth: "NSW Health, Common health concerns during a bushfire (health.nsw.gov.au/environment/bushfire/Pages/bushfire-illness.aspx); NSW Air Quality, Bushfire smoke health advice (airquality.nsw.gov.au/health-advice/bushfire-health-advice)",
  flood: "VICSES, FloodSafe (ses.vic.gov.au/get-ready/floodsafe)",
  storm: "NSW SES, During a storm (ses.nsw.gov.au/during-emergency/during-storm); VICSES, StormSafe (ses.vic.gov.au/get-ready/stormsafe)",
  powerlines: "Powercor, Storm safety (powercor.com.au/power-outages-and-emergencies/emergency/storm-safety)",
  heat: "healthdirect, Hot weather risks and staying cool (healthdirect.gov.au/hot-weather-risks-and-staying-cool)",
  earthquake: "Geoscience Australia, The Great ShakeOut (ga.gov.au/about/earth-science-week/the-great-shakeout); DFES, Prepare for an earthquake (dfes.wa.gov.au/hazard-information/earthquake/prepare)",
  tsunami: "TasALERT, Tsunami (alert.tas.gov.au/get-ready/tsunami)",
  power: "Western Power, Prepare for an extended power outage (westernpower.com.au/faqs/outages/prepare-for-an-extended-power-outage)",
  gas: "AusNet Services, Gas safety (ausnetservices.com.au/Gas/Gas-Safety)",
  hazmat: "DFES, Hazardous materials (dfes.wa.gov.au/hazard-information/hazmat); SA Government, Chemical emergency (sa.gov.au/topics/emergencies-and-safety/types/chemical-emergency)",
  water: "NSW Health, What to do if a boil water alert is in place (health.nsw.gov.au/environment/water/Pages/bwa-what-to-do.aspx); Healthy WA, Emergency treatment of drinking water supplies",
  general: "ALRT general safety statement under the owner's 9 November 2026 rules (no agency attribution)",
};

export const hazardSafetyLibrary = (): GuidanceEntry[] => [
  // Bushfire
  entry("bushfire-updates", "bushfire", "Check official updates often. Fire conditions can change quickly.", ALL, SOURCES.dfesBushfire),
  entry("bushfire-plan", "bushfire", "Review your bushfire plan and talk it through with your household.", ALL, SOURCES.dfesBushfire),
  entry("bushfire-kit", "bushfire", "Keep your emergency kit, medicines and phone charger ready to go.", HIGH, SOURCES.dfesBushfire),
  entry("bushfire-follow", "bushfire", "Follow directions from emergency services. If you are in danger, call your local emergency number.", CRITICAL, SOURCES.dfesBushfire),
  // Other fires
  entry("fire-keep-clear", "otherFire", "Keep clear of the area so emergency crews can work.", ALL, SOURCES.general),
  entry("fire-smoke", "otherFire", "If smoke reaches you, keep windows and doors closed.", ALL, SOURCES.smokeHealth),
  entry("fire-follow", "otherFire", "Follow directions from emergency services at the scene.", HIGH, SOURCES.general),
  // Smoke and air quality
  entry("smoke-windows", "smoke", "Keep windows and doors closed while smoke is around.", ALL, SOURCES.smokeHealth),
  entry("smoke-medicines", "smoke", "If you have asthma or a heart or lung condition, keep your medicines and action plan close by.", ALL, SOURCES.smokeHealth, []),
  entry("smoke-activity", "smoke", "Consider limiting time and exercise outdoors until the air clears.", ACTIVE, SOURCES.smokeHealth, []),
  entry("smoke-help", "smoke", "If breathing becomes difficult or you have chest pain, call your local emergency number.", HIGH, SOURCES.smokeHealth, []),
  // Flood
  entry("flood-never-enter", "flood", "Never drive, ride or walk through floodwater.", ALL, SOURCES.flood),
  entry("flood-children", "flood", "Keep children and pets away from floodwater and drains.", ALL, SOURCES.flood),
  entry("flood-route", "flood", "If a road is flooded, turn around and use another route.", ACTIVE, SOURCES.flood),
  entry("flood-follow", "flood", "Follow the advice of emergency services and check official updates often.", HIGH, SOURCES.flood),
  // Storms, wind, hail, cyclone
  entry("storm-powerlines", "storm", "Keep well away from fallen power lines. Always treat them as live.", ALL, SOURCES.powerlines),
  entry("storm-secure", "storm", "Secure loose items outside, such as furniture and trampolines.", ALL, SOURCES.storm),
  entry("storm-car", "storm", "Park your car under cover and away from trees if you can.", ACTIVE, SOURCES.storm),
  entry("storm-windows", "storm", "During the storm, keep away from windows.", HIGH, SOURCES.storm),
  // Heat
  entry("heat-water", "heat", "Drink plenty of water, even if you do not feel thirsty.", ALL, SOURCES.heat, []),
  entry("heat-cool", "heat", "Keep your home cool: close curtains and blinds during the day.", ALL, SOURCES.heat, []),
  entry("heat-check", "heat", "Check on older people, young children and anyone unwell.", ACTIVE, SOURCES.heat, []),
  entry("heat-car", "heat", "Never let children or pets wait alone in a parked car.", ALL, SOURCES.heat, []),
  // Earthquake
  entry("quake-drop", "earthquake", "If the ground shakes, Drop, Cover and Hold On until the shaking stops.", ALL, SOURCES.earthquake, []),
  entry("quake-aftershocks", "earthquake", "Be ready for aftershocks, which can follow minutes or days later.", ALL, SOURCES.earthquake, []),
  entry("quake-damage", "earthquake", "Watch for damaged buildings, fallen power lines and falling debris.", ACTIVE, SOURCES.earthquake, []),
  // Tsunami
  entry("tsunami-watch", "tsunami", "Never go to the beach to watch a tsunami.", ALL, SOURCES.tsunami, []),
  entry("tsunami-follow", "tsunami", "Follow the advice of emergency services and check official updates often.", ALL, SOURCES.tsunami, []),
  // Coast and surf
  entry("surf-care", "coast", "Take extra care near the water's edge and on rock platforms.", ALL, SOURCES.general),
  entry("surf-patrolled", "coast", "Consider swimming only at patrolled beaches, between the flags.", ALL, SOURCES.general),
  // Dust
  entry("dust-windows", "dust", "Keep windows and doors closed while dust is around.", ALL, SOURCES.smokeHealth, []),
  entry("dust-driving", "dust", "If driving, slow down and turn your headlights on.", ALL, SOURCES.general, []),
  // Landslide
  entry("landslide-keep-clear", "landslide", "Keep clear of the slip area and any damaged roads.", ALL, SOURCES.general, []),
  entry("landslide-watch", "landslide", "Watch for cracks, falling rocks or tilting trees nearby.", ALL, SOURCES.general, []),
  // Roads
  entry("road-delays", "road", "Expect delays and allow extra travel time.", ALL, SOURCES.general, []),
  entry("road-route", "road", "Consider another route if you can.", ALL, SOURCES.general, []),
  entry("road-directions", "road", "Follow directions from police and traffic controllers.", ALL, SOURCES.general, []),
  // Public transport and flights
  entry("transport-check", "transport", "Check the operator's latest service updates before you travel.", ALL, SOURCES.general, []),
  entry("transport-time", "transport", "Allow extra travel time or consider another way to travel.", ALL, SOURCES.general, []),
  // Power
  entry("power-fridge", "power", "Keep your fridge and freezer closed as much as you can.", ALL, SOURCES.power),
  entry("power-medicines", "power", "Keep medicines that need to stay cold in a cooler with ice packs.", ACTIVE, SOURCES.power),
  entry("power-neighbours", "power", "Check on neighbours who may need help.", ACTIVE, SOURCES.power),
  entry("power-lines", "power", "Keep well away from fallen power lines. Always treat them as live.", ALL, SOURCES.powerlines),
  // Gas
  entry("gas-flames", "gas", "If you smell gas, do not use flames, matches or electrical switches.", ALL, SOURCES.gas, []),
  entry("gas-keep-clear", "gas", "Keep clear of the area and follow directions from emergency services.", ALL, SOURCES.gas, []),
  // Hazardous materials
  entry("hazmat-keep-clear", "hazmat", "Keep well away from the area and do not touch any spilled material.", ALL, SOURCES.hazmat, []),
  entry("hazmat-windows", "hazmat", "If smoke or fumes reach you, close windows and doors and turn off air conditioning.", ALL, SOURCES.hazmat, []),
  entry("hazmat-medical", "hazmat", "If you feel unwell, seek medical advice. In an emergency, call your local emergency number.", ACTIVE, SOURCES.hazmat, []),
  // Water
  entry("water-follow", "water", "Follow the advice issued by your water provider.", ALL, SOURCES.water, []),
  entry("water-boil", "water", "If told to boil water, use boiled and cooled or bottled water for drinking, cooking and brushing teeth.", ALL, SOURCES.water, []),
  // Phone and internet outages
  entry("telco-backup", "telco", "Keep a charged phone and a battery radio handy for updates.", ALL, SOURCES.general, []),
  entry("telco-emergency", "telco", "If you cannot make a call in an emergency, try another phone or network.", ALL, SOURCES.general, []),
  // Public health
  entry("health-advice", "publicHealth", "Follow the health authority's advice for the affected place.", ALL, SOURCES.general, []),
  entry("health-hygiene", "publicHealth", "Wash your hands often and keep away from others if you feel unwell.", ALL, SOURCES.general, []),
  entry("health-doctor", "publicHealth", "If you have symptoms, contact your doctor or a health line for advice.", ALL, SOURCES.general, []),
  // Algae
  entry("algae-water", "algae", "Keep people and pets out of the affected water.", ALL, SOURCES.general, []),
  entry("algae-fish", "algae", "Do not eat fish or shellfish from the affected water.", ALL, SOURCES.general, []),
  // Crime and security
  entry("crime-keep-clear", "crime", "Keep away from the area and follow directions from police.", ALL, SOURCES.general, []),
  entry("crime-report", "crime", "If you see something suspicious, report it to police.", ALL, SOURCES.general, []),
  // Events
  entry("events-time", "events", "Expect crowds and delays, and allow extra travel time.", ALL, SOURCES.general, []),
  entry("events-transport", "events", "Check transport and road updates before you travel.", ALL, SOURCES.general, []),
  // Wildlife
  entry("wildlife-keep-clear", "wildlife", "Keep a safe distance and do not approach the animal.", ALL, SOURCES.general, []),
  entry("wildlife-children", "wildlife", "Keep children and pets close by.", ALL, SOURCES.general, []),
];
