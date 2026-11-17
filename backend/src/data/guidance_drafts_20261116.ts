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

/**
 * National (generic) versions of the main hazard guides (owner, 17 Nov 2026).
 * The Australian Warning System is the same in every state, so one national
 * guide per hazard is accurate everywhere; a state version (AU-WA) can be
 * added later where the advice differs. Publishing one replaces the older
 * state-sourced text on the same guide. Agency directions are attributed.
 */
const AWS = "https://www.australianwarningsystem.com.au/#warning";
const REDCROSS_PREPARE = "https://www.redcross.org.au/prepare/";
const HEALTHDIRECT_HEAT = "https://www.healthdirect.gov.au/hot-weather-risks-and-staying-cool";
const BOM_SEVERE = "https://www.bom.gov.au/knowyourweather/";
const QLD_CYCLONE_FAQ = "https://getready.qld.gov.au/cyclone-frequently-asked-questions";
const AWS_AGENCY = "Australian Warning System (Australian Government and state emergency services)";

const warningLevels = (hazard: string) => ({
  stage: "before" as const,
  title: "Know the three warning levels",
  body: `${hazard} warnings use the national Australian Warning System. Advice (yellow) means an incident has started with no immediate danger. Watch and Act (orange) means conditions are changing and it is time to start protecting yourself and your family. Emergency Warning (red) is the highest level: you may be in danger and need to act immediately.`,
  sourceAgency: AWS_AGENCY,
  sourceUrl: AWS,
});
const plan = {
  stage: "before" as const,
  title: "Make a household plan",
  body: "Australian Red Cross suggests four steps: get in the know about your risks, get connected with the people who can help you, get organised with a written plan, and get packing with an emergency kit. Its free Get Prepared app walks you through each step.",
  sourceAgency: "Australian Red Cross",
  sourceUrl: REDCROSS_PREPARE,
};
const followWarning = (hazard: string) => ({
  stage: "during" as const,
  title: "Follow the call to action",
  body: `Every ${hazard.toLowerCase()} warning carries a call to action from the agency, such as Prepare now, Stay informed or Avoid the area. Follow the call to action in the current warning, and check again often because it can change quickly.`,
  sourceAgency: AWS_AGENCY,
  sourceUrl: AWS,
});

export const NATIONAL_GUIDES: DraftGuide[] = [
  {
    slug: "bushfire-being-prepared", topicSlug: "bushfire-heat", jurisdiction: "AU",
    title: "Bushfire: being prepared", summary: "How bushfire warnings work in Australia and how to get your household ready.",
    categoryKeywords: ["bushfire", "grass fire", "scrub fire"],
    sections: [warningLevels("Bushfire"), plan,
      { stage: "before", title: "Pack an emergency kit", body: "A kit with water, medicines, important documents, a battery radio, a torch and phone chargers saves time when every minute matters. Keep it where everyone can find it.", sourceAgency: "Australian Red Cross", sourceUrl: REDCROSS_PREPARE }],
  },
  {
    slug: "bushfire-during", topicSlug: "bushfire-heat", jurisdiction: "AU",
    title: "Bushfire: during a fire", summary: "Understanding bushfire warnings while a fire is burning.",
    categoryKeywords: ["bushfire"],
    sections: [followWarning("Bushfire"),
      { stage: "during", title: "Emergency Warning", body: "An Emergency Warning is the highest level. The national system says it means you may be in danger and need to act immediately, because any delay puts your life at risk. Call 000 if your life is in danger.", sourceAgency: AWS_AGENCY, sourceUrl: AWS }],
  },
  {
    slug: "bushfire-after", topicSlug: "bushfire-heat", jurisdiction: "AU",
    title: "Bushfire: after a fire", summary: "What to expect once a fire has passed.",
    categoryKeywords: ["bushfire"],
    sections: [{ stage: "after", title: "Wait for official advice", body: "Warnings can still be current after the fire front passes. The national system uses calls to action such as Return with caution and Avoid smoke once conditions ease. Keep checking the current warning for your area.", sourceAgency: AWS_AGENCY, sourceUrl: AWS },
      { stage: "after", title: "Look after yourself and others", body: "Australian Red Cross notes that emergencies affect wellbeing and connection as well as property. Checking in on neighbours and talking about what happened helps recovery.", sourceAgency: "Australian Red Cross", sourceUrl: REDCROSS_PREPARE }],
  },
  {
    slug: "flood-being-prepared", topicSlug: "severe-weather-flood", jurisdiction: "AU",
    title: "Flood: being prepared", summary: "How flood warnings work and how to get ready.",
    categoryKeywords: ["flood", "riverine flood"],
    sections: [warningLevels("Flood"), plan, followWarning("Flood")],
  },
  {
    slug: "flash-flooding", topicSlug: "severe-weather-flood", jurisdiction: "AU",
    title: "Flash flooding", summary: "Flash floods happen fast. What the warnings mean and why floodwater is so dangerous.",
    categoryKeywords: ["flash flood", "heavy rain"],
    sections: [{ stage: "before", title: "Severe weather season", body: "The Bureau of Meteorology says Australia faces a higher risk of severe weather from October to April. Heavy rain can turn creeks, roads and drains into fast-moving water within minutes.", sourceAgency: "Bureau of Meteorology", sourceUrl: BOM_SEVERE },
      { stage: "during", title: "Floodwater", body: "Floodwater can hide fast currents, debris and washed-out roads. Emergency services across Australia advise never driving, walking or swimming through floodwater. If your life is in danger, call 000.", sourceAgency: "Bureau of Meteorology", sourceUrl: BOM_SEVERE }],
  },
  {
    slug: "severe-storm", topicSlug: "severe-weather-flood", jurisdiction: "AU",
    title: "Severe storms", summary: "Damaging winds, hail and heavy rain: what to expect and how to prepare.",
    categoryKeywords: ["storm", "damaging winds", "hail"],
    sections: [{ stage: "before", title: "Storm season", body: "The Bureau of Meteorology says the risk of severe weather is higher from October to April. Checking forecasts and warnings during that period gives you time to prepare.", sourceAgency: "Bureau of Meteorology", sourceUrl: BOM_SEVERE }, plan, followWarning("Storm")],
  },
  {
    slug: "cyclone", topicSlug: "severe-weather-flood", jurisdiction: "AU",
    title: "Tropical cyclones", summary: "Cyclone watches, warnings and what to do before and after.",
    categoryKeywords: ["cyclone"],
    sections: [
      { stage: "before", title: "Watch and warning", body: "The Bureau of Meteorology issues a Tropical Cyclone Watch when gales are expected within 24 to 48 hours, and a Tropical Cyclone Warning when gales are expected within 24 hours or are already happening.", sourceAgency: "Bureau of Meteorology (via Queensland Government Get Ready)", sourceUrl: QLD_CYCLONE_FAQ },
      plan,
      { stage: "after", title: "After the cyclone", body: "Strong winds and heavy rain can continue after a cyclone is downgraded. The Bureau of Meteorology warns that coastal areas can be extremely dangerous before, during and after a cyclone.", sourceAgency: "Bureau of Meteorology", sourceUrl: BOM_SEVERE },
    ],
  },
  {
    slug: "heatwave", topicSlug: "bushfire-heat", jurisdiction: "AU",
    title: "Heatwaves", summary: "Heat is Australia's deadliest natural hazard. Signs of heat illness and how to stay cool.",
    categoryKeywords: ["heatwave", "heat"],
    sections: [
      { stage: "before", title: "Who is most at risk", body: "healthdirect notes that heat-related illness can affect anyone, and older people, babies and young children, pregnant people and people with medical conditions are at greater risk.", sourceAgency: "healthdirect (Australian Government)", sourceUrl: HEALTHDIRECT_HEAT },
      { stage: "during", title: "Keep cool and drink water", body: "healthdirect says the best way to prevent heat-related illness is to drink plenty of water and stay as cool as possible.", sourceAgency: "healthdirect (Australian Government)", sourceUrl: HEALTHDIRECT_HEAT },
      { stage: "during", title: "When to call 000", body: "Heat-related illness can quickly become life-threatening. healthdirect advises calling 000 for an ambulance if someone is very unwell and does not respond to cooling and drinking water within about 10 minutes.", sourceAgency: "healthdirect (Australian Government)", sourceUrl: HEALTHDIRECT_HEAT },
    ],
  },
];

/**
 * Ask ALRT answers built from the same sourced guide content (owner, 17 Nov
 * 2026), so Learn and Ask ALRT say the same thing. Under 70 words, no
 * movement directions, only emergency numbers.
 */
export const GUIDE_ANSWERS: { id: string; triggers: string[]; text: string; sourceAgency: string; sourceUrl: string }[] = [
  { id: "warning-levels", triggers: ["what do the warning levels mean", "what is watch and act", "what does watch and act mean", "what does emergency warning mean", "what is an emergency warning", "what does advice mean", "australian warning system"], text: "Australia uses three warning levels. Advice (yellow): an incident has started, no immediate danger. Watch and Act (orange): conditions are changing, start protecting yourself and your family. Emergency Warning (red): you may be in danger and need to act immediately. Each warning also has a call to action from the agency, so follow that.", sourceAgency: AWS_AGENCY, sourceUrl: AWS },
  { id: "emergency-plan", triggers: ["how do i make an emergency plan", "emergency plan", "how do i prepare for an emergency", "household plan"], text: "Australian Red Cross suggests four steps: learn your local risks, connect with people who can help, write a household plan, and pack an emergency kit. Its free Get Prepared app walks you through each step.", sourceAgency: "Australian Red Cross", sourceUrl: REDCROSS_PREPARE },
  { id: "bushfire-prepare", triggers: ["how do i prepare for bushfire", "bushfire season", "bushfire plan", "get ready for bushfire"], text: "Bushfire warnings use the national levels: Advice, Watch and Act, Emergency Warning. Getting ready early helps: make a household plan, pack a kit with water, medicines, documents, a battery radio and chargers, and check warnings for your area often.", sourceAgency: AWS_AGENCY, sourceUrl: AWS },
  { id: "floodwater", triggers: ["can i drive through floodwater", "is floodwater dangerous", "flash flood", "driving in flood"], text: "Floodwater can hide fast currents, debris and washed-out roads, and it rises quickly in heavy rain. Emergency services across Australia advise never driving, walking or swimming through it. If your life is in danger, call 000.", sourceAgency: "Bureau of Meteorology", sourceUrl: BOM_SEVERE },
  { id: "cyclone-watch-warning", triggers: ["cyclone watch", "cyclone warning", "difference between cyclone watch and warning", "cyclone"], text: "The Bureau of Meteorology issues a Tropical Cyclone Watch when gales are expected within 24 to 48 hours, and a Tropical Cyclone Warning when gales are expected within 24 hours or have started. Strong winds and rain can continue after a cyclone is downgraded.", sourceAgency: "Bureau of Meteorology (via Queensland Government Get Ready)", sourceUrl: QLD_CYCLONE_FAQ },
  { id: "heat-illness", triggers: ["heat stroke", "heat exhaustion", "signs of heat illness", "heatwave", "too hot"], text: "Drink plenty of water and keep as cool as you can. Older people, babies, young children, pregnant people and people with medical conditions are at greater risk. healthdirect advises calling 000 if someone is very unwell and not improving within about 10 minutes of cooling and drinking water.", sourceAgency: "healthdirect (Australian Government)", sourceUrl: HEALTHDIRECT_HEAT },
  { id: "smoke", triggers: ["bushfire smoke", "smoke outside", "is the smoke dangerous", "air quality smoke"], text: "The WA Department of Health suggests keeping windows and doors closed, using air conditioning on recirculate, and that only a fitted P2 (N95) mask filters smoke. People with asthma, heart or lung conditions, children, older people and pregnant women are most at risk. Trouble breathing or chest pain: call 000.", sourceAgency: "WA Department of Health (HealthyWA)", sourceUrl: HEALTHYWA_SMOKE },
  { id: "hazmat-report", triggers: ["chemical spill", "hazmat", "how do i report a chemical spill", "smell of chemicals"], text: "Call 000 and ask for fire services. DFES says it helps to give the location, the four-digit UN number on the container if you can see it, how much is involved and whether anyone is hurt. If a HAZMAT Warning is issued, follow its advice.", sourceAgency: "Department of Fire and Emergency Services (DFES)", sourceUrl: DFES_HAZMAT },
  { id: "boil-water", triggers: ["boil water notice", "boil water alert", "how long do i boil water", "is tap water safe"], text: "Water Corporation advises a rolling boil for at least one minute, then letting it cool. Use boiled or bottled water for drinking, cooking, ice, brushing teeth and pets. Boiling kills germs but does not remove chemicals, so follow the notice.", sourceAgency: "Water Corporation", sourceUrl: WATERCORP_CYCLONE },
  { id: "escape-hide-tell", triggers: ["armed attack", "what to do in an attack", "escape hide tell", "active shooter"], text: "The national advice is ESCAPE. HIDE. TELL. Get away only if it is safe; if not, get out of sight, silence your phone and lock doors. When safe, call 000 with your location, a description and any weapons.", sourceAgency: "Australian National Security (Department of Home Affairs)", sourceUrl: NATSEC_ATTACK },
];

/**
 * Other countries' official warning levels (owner, 17 Nov 2026), as Ask ALRT
 * answers keyed to the country, so "what do the warning levels mean" is
 * answered for the place the question is about (D1).
 */
export const COUNTRY_WARNING_ANSWERS: { jurisdiction: string; text: string; sourceAgency: string; sourceUrl: string }[] = [
  { jurisdiction: "NZ", text: "MetService uses Outlooks, yellow Watches (stay alert), Orange Warnings (take action) and Red Warnings (act now), the last for the worst weather New Zealand sees. Thunderstorm Warnings are always red. During a Red Warning, follow official authorities and emergency services. In an emergency call 111.", sourceAgency: "MetService (New Zealand)", sourceUrl: "https://about.metservice.com/about-severe-weather-warnings" },
  { jurisdiction: "GB", text: "The Met Office uses yellow, amber and red warnings, set by how likely the weather is and how much impact it could have. Yellow: be aware. Amber: be prepared to change plans. Red: dangerous weather is expected and action is needed, with risk to life likely. In an emergency call 999.", sourceAgency: "Met Office (UK)", sourceUrl: "https://www.metoffice.gov.uk/weather/warnings-and-advice/uk-warnings" },
  { jurisdiction: "US", text: "The National Weather Service uses Advisories (be aware: less serious but disruptive weather), Watches (be prepared: conditions favour hazardous weather) and Warnings (take action: hazardous weather is happening or about to). In an emergency call 911.", sourceAgency: "National Weather Service (US)", sourceUrl: "https://www.weather.gov/safety/" },
  { jurisdiction: "CA", text: "Since November 2025, Environment and Climate Change Canada colour-codes every Warning, Advisory and Watch. Yellow: hazardous weather with moderate, local impacts. Orange: severe weather likely to cause significant damage or disruption. Red: very dangerous and rare, with extreme, widespread impacts. In an emergency call 911.", sourceAgency: "Environment and Climate Change Canada", sourceUrl: "https://www.canada.ca/en/environment-climate-change/news/2025/11/colour-coded-weather-alerts.html" },
  { jurisdiction: "JP", text: "Japan uses five levels for heavy rain, floods, landslides and storm surges. Level 1 Early Advisory and Level 2 Advisory are for getting ready. Levels 3 and 4 are warnings, when local authorities issue their own instructions. Level 5 Emergency Warning (black) means a disaster may already be happening. Police 110, fire and ambulance 119.", sourceAgency: "Japan Meteorological Agency (summary by Nippon.com)", sourceUrl: "https://www.nippon.com/en/japan-data/h02798/" },
];
