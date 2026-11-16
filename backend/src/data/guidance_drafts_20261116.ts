/**
 * New and replacement Learn guides drafted 16 November 2026 from the official
 * pages named on each section. They import as IN REVIEW: nothing reaches the
 * app until the owner approves the sections and publishes the guide in admin
 * (Guidance Library, then Guides, Publish). Agency advice is attributed to the
 * agency; ALRT adds no leave, shelter, stay or return direction of its own.
 */
export interface DraftGuide {
  slug: string;
  topicSlug: string;
  title: string;
  summary: string;
  jurisdiction: string;
  categoryKeywords: string[];
  /** Replaces an existing guide with the wrong credit, when set. */
  replaces?: string;
  sections: { stage: "before" | "during" | "after"; title: string; body: string; sourceAgency: string; sourceUrl: string }[];
}

const HEALTHYWA_SMOKE = "https://www.healthywa.wa.gov.au/Articles/S_T/Smoke-hazard-from-bushfires";
const DFES_HOME = "https://dfes.wa.gov.au/hazard-information/fire-in-the-home";
const DFES_HOME_RECOVER = "https://dfes.wa.gov.au/hazard-information/fire-in-the-home/recovering";
const DFES_HAZMAT = "https://dfes.wa.gov.au/hazard-information/hazmat";
const TAS_LANDSLIDE = "https://alert.tas.gov.au/get-ready/landslide";
const VICSES_LANDSLIDE = "https://www.ses.vic.gov.au/landslide";
const NATSEC_ATTACK = "https://www.nationalsecurity.gov.au/what-can-i-do/what-to-do-in-an-attack";
const WAPOL_BURGLARY = "https://www.wa.gov.au/media/48439/download";
const HEALTHYWA_WATER = "https://healthywa.wa.gov.au/Articles/A_E/Emergency-treatment-of-drinking-water-supplies";
const WATERCORP_CYCLONE = "https://www.watercorporation.com.au/-/media/WaterCorp/Documents/Help-and-advice/Water-supply/cyclone-prepare-information-sheet-v2.pdf";

export const DRAFT_GUIDES: DraftGuide[] = [
  {
    slug: "smoke-air-quality", topicSlug: "bushfire-heat", jurisdiction: "AU-WA",
    title: "Smoke and poor air quality",
    summary: "What the WA Department of Health suggests when bushfire or burn-off smoke affects the air you breathe.",
    categoryKeywords: ["smoke", "air quality", "asthma", "ashfall"],
    sections: [
      { stage: "before", title: "Know who is most sensitive", body: "The WA Department of Health lists people with asthma or other lung conditions, heart disease or diabetes, children, older adults and pregnant women as most at risk from smoke.", sourceAgency: "WA Department of Health (HealthyWA)", sourceUrl: HEALTHYWA_SMOKE },
      { stage: "before", title: "Check the air quality readings", body: "The Department of Water and Environmental Regulation posts hourly fine particle (PM2.5) readings with health advice. HealthyWA suggests checking them when smoke is around.", sourceAgency: "WA Department of Health (HealthyWA)", sourceUrl: HEALTHYWA_SMOKE },
      { stage: "during", title: "Keep smoke out of the house", body: "HealthyWA suggests keeping windows and doors closed and using reverse cycle air conditioning or fans that recirculate indoor air. Evaporative coolers draw smoke in. A portable HEPA air cleaner sized for the room can help.", sourceAgency: "WA Department of Health (HealthyWA)", sourceUrl: HEALTHYWA_SMOKE },
      { stage: "during", title: "Masks and activity", body: "Only a well-fitted P1 or P2 (N95) mask filters smoke; paper and cloth masks do not. HealthyWA suggests avoiding strenuous outdoor activity, and people with heart or lung conditions asking their doctor before using a mask.", sourceAgency: "WA Department of Health (HealthyWA)", sourceUrl: HEALTHYWA_SMOKE },
      { stage: "after", title: "Watch for symptoms", body: "Trouble breathing, chest pain or tightness are reasons to call 000. For other symptoms, such as sore eyes or a cough, HealthyWA suggests healthdirect or your doctor. Most people recover quickly once the air clears.", sourceAgency: "WA Department of Health (HealthyWA)", sourceUrl: HEALTHYWA_SMOKE },
    ],
  },
  {
    slug: "house-fire", topicSlug: "bushfire-heat", jurisdiction: "AU-WA",
    title: "House and building fires",
    summary: "DFES advice on preventing fires at home, smoke alarms and what happens after a fire.",
    categoryKeywords: ["structural fire", "structure fire", "building fire", "house fire"],
    sections: [
      { stage: "before", title: "Working smoke alarms", body: "DFES reminds households that only a working smoke alarm gives early warning. Test alarms regularly and keep the vents clear of dust.", sourceAgency: "Department of Fire and Emergency Services (DFES)", sourceUrl: DFES_HOME },
      { stage: "before", title: "A home fire escape plan", body: "DFES suggests making a home fire escape plan, putting it where everyone can see it, and practising it with the whole household. A room can be engulfed in under five minutes.", sourceAgency: "Department of Fire and Emergency Services (DFES)", sourceUrl: DFES_HOME },
      { stage: "before", title: "Common causes", body: "DFES links many WA house fires to heaters, power boards, dryers and lithium-ion batteries. It suggests keeping items a metre from heaters and charging batteries on a hard surface, away from things that burn, and not overnight.", sourceAgency: "Department of Fire and Emergency Services (DFES)", sourceUrl: DFES_HOME },
      { stage: "during", title: "Call 000", body: "If there is a fire, call 000 as soon as you can do so safely and follow the instructions of fire crews.", sourceAgency: "Department of Fire and Emergency Services (DFES)", sourceUrl: DFES_HOME },
      { stage: "after", title: "Investigation and insurance", body: "After a house fire, official investigations and insurance assessments help work out the cause and support recovery. DFES explains each step on its recovery page.", sourceAgency: "Department of Fire and Emergency Services (DFES)", sourceUrl: DFES_HOME_RECOVER },
    ],
  },
  {
    slug: "hazardous-materials", topicSlug: "power-utilities", jurisdiction: "AU-WA",
    title: "Chemical and hazardous material incidents",
    summary: "What DFES advises about HAZMAT incidents, warnings and staying informed.",
    categoryKeywords: ["chemical", "hazmat", "hazardous"],
    sections: [
      { stage: "before", title: "Plan for smoke and fumes", body: "DFES suggests your household plan covers how to switch off air conditioning and seal windows and doors, how family will reunite, and what you will do for pets.", sourceAgency: "Department of Fire and Emergency Services (DFES)", sourceUrl: DFES_HAZMAT },
      { stage: "before", title: "An emergency kit", body: "DFES suggests a waterproof kit with key documents, a battery radio and torch, first aid supplies, medicines, spare clothes, pet supplies, and phone chargers.", sourceAgency: "Department of Fire and Emergency Services (DFES)", sourceUrl: DFES_HAZMAT },
      { stage: "during", title: "Reporting an incident", body: "Call 000 and ask for fire services. DFES says it helps to give the location, the four-digit UN number on the container if you can see it, roughly how much is involved, and whether anyone is hurt.", sourceAgency: "Department of Fire and Emergency Services (DFES)", sourceUrl: DFES_HAZMAT },
      { stage: "during", title: "If a HAZMAT Warning is issued", body: "The DFES advice in a HAZMAT Warning is to avoid the area and follow emergency advice. Follow the instructions in the warning and keep clear of smoke and fumes.", sourceAgency: "Department of Fire and Emergency Services (DFES)", sourceUrl: DFES_HAZMAT },
      { stage: "after", title: "Controlled and contained", body: "When DFES changes the warning to Controlled and Contained, smoke and fumes no longer affect the area. If you have health concerns, contact your doctor or healthdirect.", sourceAgency: "Department of Fire and Emergency Services (DFES)", sourceUrl: DFES_HAZMAT },
    ],
  },
  {
    slug: "landslide", topicSlug: "earthquake-tsunami", jurisdiction: "AU",
    title: "Landslides",
    summary: "Signs of ground movement and what state emergency services suggest before and after a landslide.",
    categoryKeywords: ["landslide", "land slip", "landslip"],
    sections: [
      { stage: "before", title: "Know the warning signs", body: "Tasmania's emergency service lists signs such as long curved cracks in the ground, fences or retaining walls moving out of line, and broken water or sewer pipes.", sourceAgency: "TasALERT (Tasmanian Government)", sourceUrl: TAS_LANDSLIDE },
      { stage: "before", title: "Insurance and planning", body: "Landslide insurance is not available anywhere in Australia, so TasALERT suggests checking local landslide mapping and following planning rules on slope stability.", sourceAgency: "TasALERT (Tasmanian Government)", sourceUrl: TAS_LANDSLIDE },
      { stage: "during", title: "Tell officials and neighbours", body: "If ground movement has started or seems likely, TasALERT suggests alerting officials and neighbours, especially those downslope, and following instructions from emergency services.", sourceAgency: "TasALERT (Tasmanian Government)", sourceUrl: TAS_LANDSLIDE },
      { stage: "after", title: "More slides and flooding", body: "Further slides and flooding can follow a landslide. VICSES suggests keeping clear of affected areas so crews can work, and having power, gas and water checked by a licensed technician before use.", sourceAgency: "VICSES", sourceUrl: VICSES_LANDSLIDE },
    ],
  },
  {
    slug: "armed-attack-escape-hide-tell", topicSlug: "personal-safety", jurisdiction: "AU",
    replaces: "crowded-events-civil-unrest",
    title: "Crowded places: Escape. Hide. Tell.",
    summary: "The Australian Government's advice for an armed attack in a crowded place.",
    categoryKeywords: ["terror", "venue evacuation", "concert", "festival", "sporting event"],
    sections: [
      { stage: "before", title: "Remember three words", body: "The national advice for an armed attack is ESCAPE. HIDE. TELL. Knowing it before you need it can save lives.", sourceAgency: "Australian National Security (Department of Home Affairs)", sourceUrl: NATSEC_ATTACK },
      { stage: "during", title: "Escape. Hide.", body: "The national advice is to get away quickly and quietly only if it is safe, without going back for belongings. If that is not safe, get out of sight, silence your phone and lock or block doors.", sourceAgency: "Australian National Security (Department of Home Affairs)", sourceUrl: NATSEC_ATTACK },
      { stage: "during", title: "Tell.", body: "When it is safe, call 000 and give your location, a description of the attacker, any weapons and how many people are hurt.", sourceAgency: "Australian National Security (Department of Home Affairs)", sourceUrl: NATSEC_ATTACK },
      { stage: "after", title: "When police arrive", body: "Follow officers' instructions, keep your hands visible and avoid sudden movements or shouting.", sourceAgency: "Australian National Security (Department of Home Affairs)", sourceUrl: NATSEC_ATTACK },
    ],
  },
  {
    slug: "home-security", topicSlug: "personal-safety", jurisdiction: "AU-WA",
    replaces: "home-security",
    title: "Home security",
    summary: "WA Police Force advice on making your home harder to break into.",
    categoryKeywords: ["crime"],
    sections: [
      { stage: "before", title: "Lock every way in", body: "WA Police suggest locking doors, windows, gates, sheds, pet doors and skylights, and not hiding spare keys outside.", sourceAgency: "Western Australia Police Force", sourceUrl: WAPOL_BURGLARY },
      { stage: "before", title: "Keep valuables out of sight", body: "WA Police suggest keeping valuables out of view from windows, recording serial numbers, and photographing valuable items.", sourceAgency: "Western Australia Police Force", sourceUrl: WAPOL_BURGLARY },
      { stage: "before", title: "Lighting and visibility", body: "WA Police suggest keeping your house visible from the street, trimming shrubs that give hiding spots, and using sensor lights at entries.", sourceAgency: "Western Australia Police Force", sourceUrl: WAPOL_BURGLARY },
      { stage: "after", title: "If something happens", body: "In a life-threatening situation call 000. WA Police also take reports of break-ins and suspicious activity through their non-emergency channels.", sourceAgency: "Western Australia Police Force", sourceUrl: WAPOL_BURGLARY },
    ],
  },
  {
    slug: "water-contamination", topicSlug: "power-utilities", jurisdiction: "AU-WA",
    replaces: "water-contamination",
    title: "Boil water alerts and unsafe water",
    summary: "WA Department of Health and Water Corporation advice when tap water may not be safe.",
    categoryKeywords: ["boil water", "water issue", "water supply"],
    sections: [
      { stage: "during", title: "How to boil water", body: "Water Corporation advises bringing water to a rolling boil for at least one minute and letting it cool before use.", sourceAgency: "Water Corporation", sourceUrl: WATERCORP_CYCLONE },
      { stage: "during", title: "What needs boiled or bottled water", body: "Water Corporation lists drinking, preparing food, washing raw food, making ice, cleaning teeth and pets' drinking water. Wash dishes in hot soapy water or a dishwasher.", sourceAgency: "Water Corporation", sourceUrl: WATERCORP_CYCLONE },
      { stage: "during", title: "Boiling does not remove chemicals", body: "The WA Department of Health notes that boiling kills germs but does not remove chemical contamination. Follow the advice in the notice.", sourceAgency: "WA Department of Health (HealthyWA)", sourceUrl: HEALTHYWA_WATER },
      { stage: "after", title: "When the alert is lifted", body: "Follow the Department of Health and Water Corporation instructions for flushing your household pipes before using tap water again.", sourceAgency: "Water Corporation", sourceUrl: WATERCORP_CYCLONE },
    ],
  },
];

/**
 * Safety Profile lines for the two new groups (decision D8): people who rely
 * on powered medical equipment, and people with an assistance animal.
 * Imported IN REVIEW for the owner to approve.
 */
const WP_OUTAGE = "https://www.westernpower.com.au/faqs/outages/prepare-for-an-extended-power-outage/";
const DPIRD_ANIMALS = "https://agric.wa.gov.au/animalwelfare/evacuating-animals-emergencies";
export const DRAFT_PROFILE_LINES: { hazard: string; cohort: "powered" | "assistance"; text: string; sourceAgency: string; sourceUrl: string }[] = [
  { hazard: "utility_outage", cohort: "powered", text: "Making sure your electricity retailer knows you use life support equipment, and asking your equipment provider how long it runs on battery, may help.", sourceAgency: "Western Power", sourceUrl: WP_OUTAGE },
  { hazard: "severe_weather", cohort: "powered", text: "Storms can cut power for long periods. Checking your equipment's backup batteries are charged and your outage plan is ready may help.", sourceAgency: "Western Power", sourceUrl: WP_OUTAGE },
  { hazard: "bushfire", cohort: "powered", text: "Power can be off for days during and after a bushfire. Charging backup batteries early and keeping your outage plan with your kit may help.", sourceAgency: "Western Power", sourceUrl: WP_OUTAGE },
  { hazard: "cyclone", cohort: "powered", text: "Cyclones can cut power for days. Talking with your equipment provider now about backup options may help.", sourceAgency: "Western Power", sourceUrl: WP_OUTAGE },
  { hazard: "heatwave", cohort: "powered", text: "Heatwaves can strain the power network. Keeping backup batteries charged and your outage plan handy may help.", sourceAgency: "Western Power", sourceUrl: WP_OUTAGE },
  { hazard: "flood", cohort: "powered", text: "Floods can cut power and access for days. Having backup batteries charged and your equipment provider's number in your plan may help.", sourceAgency: "Western Power", sourceUrl: WP_OUTAGE },
  { hazard: "bushfire", cohort: "assistance", text: "Recognised assistance animals are allowed inside emergency relief centres. Keeping their harness, lead, food and papers with your kit may help.", sourceAgency: "Department of Primary Industries and Regional Development (WA)", sourceUrl: DPIRD_ANIMALS },
  { hazard: "flood", cohort: "assistance", text: "Floodwater can hide hazards for an animal too. Keeping your assistance animal's harness, food and papers in a waterproof bag may help.", sourceAgency: "Department of Primary Industries and Regional Development (WA)", sourceUrl: DPIRD_ANIMALS },
  { hazard: "cyclone", cohort: "assistance", text: "Packing food, water and papers for your assistance animal in your cyclone kit may help.", sourceAgency: "Department of Primary Industries and Regional Development (WA)", sourceUrl: DPIRD_ANIMALS },
  { hazard: "evac_centre", cohort: "assistance", text: "Recognised assistance animals are allowed inside emergency relief centres, unlike most pets. Bringing their harness and papers may help.", sourceAgency: "Department of Primary Industries and Regional Development (WA)", sourceUrl: DPIRD_ANIMALS },
];
