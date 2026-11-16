/** Same as matching.normalize, kept local so this module has no dependencies. */
const normalize = (text: string): string =>
  text.toLowerCase().replace(/[^a-z0-9\s]/g, " ").replace(/\s+/g, " ").trim();

/**
 * Ask ALRT resolves the place a question is about BEFORE it answers
 * (owner decision D1, 16 November 2026). Order:
 *   1. a place named in the question ("road rules in Bali")
 *   2. the place of the alert the person opened Ask ALRT from
 *   3. a trip destination the person set
 *   4. the device's country and state (coarse, never coordinates)
 *   5. nothing known and the answer depends on local law: ask which place.
 * Zero AI. The result goes into the AI context and picks jurisdiction
 * records from the guidance library.
 */

export type PlaceBasis = "question" | "alert" | "trip" | "device" | "none";
export interface ResolvedPlace {
  /** ISO country, or country-state ("AU-WA"); null when unknown. */
  jurisdiction: string | null;
  label: string | null;
  basis: PlaceBasis;
  /** True when the answer depends on local law and no place is known. */
  askPlace: boolean;
}

export interface PlaceContext {
  deviceCountry?: string | null;
  deviceState?: string | null;
  alertJurisdiction?: string | null;
  tripDestination?: string | null;
}

export const AU_STATES: Record<string, string> = {
  WA: "Western Australia", NSW: "New South Wales", VIC: "Victoria", QLD: "Queensland",
  SA: "South Australia", TAS: "Tasmania", NT: "Northern Territory", ACT: "the Australian Capital Territory",
};

/** Lower-case phrase -> jurisdiction. Matched as whole words. */
const PLACES: Record<string, string> = {
  // Australian states by name
  "western australia": "AU-WA", "new south wales": "AU-NSW", victoria: "AU-VIC", queensland: "AU-QLD",
  "south australia": "AU-SA", tasmania: "AU-TAS", "northern territory": "AU-NT", "australian capital territory": "AU-ACT",
  nsw: "AU-NSW", qld: "AU-QLD", vic: "AU-VIC", tas: "AU-TAS",
  // WA
  perth: "AU-WA", fremantle: "AU-WA", cottesloe: "AU-WA", scarborough: "AU-WA", mandurah: "AU-WA", rockingham: "AU-WA",
  joondalup: "AU-WA", bunbury: "AU-WA", busselton: "AU-WA", "margaret river": "AU-WA", albany: "AU-WA", esperance: "AU-WA",
  geraldton: "AU-WA", kalgoorlie: "AU-WA", broome: "AU-WA", karratha: "AU-WA", "port hedland": "AU-WA", "south hedland": "AU-WA",
  newman: "AU-WA", exmouth: "AU-WA", "rottnest": "AU-WA", pilbara: "AU-WA", kimberley: "AU-WA", "the pilbara": "AU-WA",
  // NSW and ACT
  sydney: "AU-NSW", bondi: "AU-NSW", manly: "AU-NSW", newcastle: "AU-NSW", wollongong: "AU-NSW", "byron bay": "AU-NSW",
  "blue mountains": "AU-NSW", "central coast": "AU-NSW", albury: "AU-NSW", dubbo: "AU-NSW", canberra: "AU-ACT",
  // VIC
  melbourne: "AU-VIC", geelong: "AU-VIC", ballarat: "AU-VIC", bendigo: "AU-VIC", "great ocean road": "AU-VIC",
  // QLD
  brisbane: "AU-QLD", "gold coast": "AU-QLD", "sunshine coast": "AU-QLD", cairns: "AU-QLD", townsville: "AU-QLD",
  mackay: "AU-QLD", toowoomba: "AU-QLD", "whitsundays": "AU-QLD",
  // SA, TAS, NT
  adelaide: "AU-SA", "barossa": "AU-SA", "kangaroo island": "AU-SA", hobart: "AU-TAS", launceston: "AU-TAS",
  darwin: "AU-NT", "alice springs": "AU-NT", uluru: "AU-NT", kakadu: "AU-NT",
  // Common destinations named by place rather than country
  bali: "ID", lombok: "ID", jakarta: "ID", "gili islands": "ID", phuket: "TH", bangkok: "TH", "chiang mai": "TH",
  tokyo: "JP", kyoto: "JP", osaka: "JP", niseko: "JP", hokkaido: "JP", london: "GB", england: "GB", scotland: "GB", wales: "GB",
  uk: "GB", britain: "GB", usa: "US", america: "US", hawaii: "US", "new york": "US", "los angeles": "US", "las vegas": "US",
  auckland: "NZ", queenstown: "NZ", wellington: "NZ", christchurch: "NZ", nz: "NZ", singapore: "SG", "hong kong": "HK",
  hanoi: "VN", "ho chi minh": "VN", vietnam: "VN", paris: "FR", rome: "IT", fiji: "FJ", nadi: "FJ", "port moresby": "PG",
  dubai: "AE", "kuala lumpur": "MY", manila: "PH", "south korea": "KR", seoul: "KR", "sri lanka": "LK", maldives: "MV",
};

/** Names that are also ordinary words or US states: matched only after "in", "to", "for"... */
const NEEDS_PREPOSITION = new Set(["georgia", "jordan", "chad", "turkey", "china", "victoria", "wales", "america", "guinea", "niger", "peru", "cuba", "malta", "iceland"]);

const countryNames = (() => {
  const out: Record<string, string> = {};
  const names = new Intl.DisplayNames(["en"], { type: "region", fallback: "none" });
  const codes = "AD AE AF AG AL AM AO AR AT AU AZ BA BB BD BE BF BG BH BI BJ BN BO BR BS BT BW BY BZ CA CD CF CG CH CI CL CM CN CO CR CU CV CY CZ DE DJ DK DM DO DZ EC EE EG ER ES ET FI FJ FM FR GA GB GD GE GH GM GN GQ GR GT GW GY HK HN HR HT HU ID IE IL IN IQ IR IS IT JM JO JP KE KG KH KI KM KN KP KR KW KZ LA LB LC LI LK LR LS LT LU LV LY MA MC MD ME MG MH MK ML MM MN MO MR MT MU MV MW MX MY MZ NA NC NE NG NI NL NO NP NR NZ OM PA PE PF PG PH PK PL PR PS PT PW PY QA RO RS RU RW SA SB SC SD SE SG SI SK SL SM SN SO SR SS ST SV SY SZ TD TG TH TJ TL TM TN TO TR TT TV TW TZ UA UG US UY UZ VA VC VE VN VU WS YE ZA ZM ZW".split(" ");
  for (const code of codes) {
    const name = names.of(code);
    if (name && name !== code) out[name.toLowerCase()] = code;
  }
  out["united states"] = "US";
  out["united kingdom"] = "GB";
  out["new zealand"] = "NZ";
  return out;
})();

const COUNTRY_LABEL = (code: string): string => {
  try {
    return new Intl.DisplayNames(["en"], { type: "region" }).of(code) ?? code;
  } catch {
    return code;
  }
};

export const labelFor = (jurisdiction: string): string => {
  const [country, state] = jurisdiction.split("-");
  if (country === "AU" && state && AU_STATES[state]) return AU_STATES[state]!;
  return COUNTRY_LABEL(country!);
};

/** Questions whose answer depends on the local law or rules. */
const LOCAL_RULE = /\b(law|laws|legal|illegal|allowed|permitted|permit|licen[cs]e|rules?|road rules|speed limit|fine|fines|penalt(?:y|ies)|drink.?driv\w*|blood alcohol|car seats?|booster|helmet|fireworks?|pepper spray|total fire ban|fire ban|burn(?:ing)? off|campfire|insurance)\b/i;

const PREP = "(?:in|to|for|at|from|visiting|around|near|across|throughout|travelling|traveling|holiday in|trip to)";

/** The place named in the question, most specific (state, city) first. */
export const placeInQuestion = (question: string): string | null => {
  const norm = ` ${normalize(question)} `;
  // Upper-case abbreviations that are also words: WA, SA, NT, ACT.
  const abbrev = question.match(/\b(WA|SA|NT|ACT)\b/);
  const hits: { j: string; at: number; len: number }[] = [];
  if (abbrev) hits.push({ j: `AU-${abbrev[1]}`, at: abbrev.index ?? 0, len: abbrev[1]!.length });
  const scan = (table: Record<string, string>) => {
    for (const [name, j] of Object.entries(table)) {
      const key = normalize(name);
      if (!key) continue;
      if (NEEDS_PREPOSITION.has(key)) {
        const m = norm.match(new RegExp(`\\b${PREP}\\s+${key.replace(/ /g, "\\s+")}\\b`));
        if (m) hits.push({ j, at: m.index ?? 0, len: key.length });
        continue;
      }
      const at = norm.indexOf(` ${key} `);
      if (at >= 0) hits.push({ j, at, len: key.length });
    }
  };
  scan(PLACES);
  scan(countryNames);
  if (!hits.length) return null;
  // Prefer a state-level place, then the longest name ("south australia" over "australia").
  hits.sort((a, b) => Number(b.j.includes("-")) - Number(a.j.includes("-")) || b.len - a.len || a.at - b.at);
  return hits[0]!.j;
};

const clean = (country?: string | null, state?: string | null): string | null => {
  const c = country?.trim().toUpperCase();
  if (!c || !/^[A-Z]{2}$/.test(c)) return null;
  const s = state?.trim().toUpperCase();
  return c === "AU" && s && AU_STATES[s] ? `AU-${s}` : c;
};

export const resolvePlace = (question: string, ctx: PlaceContext = {}): ResolvedPlace => {
  const named = placeInQuestion(question);
  const fromAlert = ctx.alertJurisdiction ? clean(...(ctx.alertJurisdiction.split("-") as [string, string?])) : null;
  const fromTrip = ctx.tripDestination ? placeInQuestion(ctx.tripDestination) ?? clean(ctx.tripDestination) : null;
  const fromDevice = clean(ctx.deviceCountry, ctx.deviceState);
  const pick: [string | null, PlaceBasis][] = [[named, "question"], [fromAlert, "alert"], [fromTrip, "trip"], [fromDevice, "device"]];
  const hit = pick.find(([j]) => j);
  const localRule = LOCAL_RULE.test(question);
  if (hit) {
    const [j, basis] = hit as [string, PlaceBasis];
    // Australia-wide is not enough for a state law question.
    const askPlace = localRule && j === "AU" && basis !== "question";
    return { jurisdiction: j, label: labelFor(j), basis, askPlace };
  }
  return { jurisdiction: null, label: null, basis: "none", askPlace: localRule };
};

export const ASK_PLACE_ANSWER =
  "Rules differ between states and countries. Which state or country is this for? Tell me and I will answer for that place.";

/** The context line given to the model. */
export const placeContextLine = (p: ResolvedPlace): string =>
  p.jurisdiction
    ? `- Place this question is about: ${p.label} (${p.jurisdiction}), taken from ${
        { question: "the place named in the question", alert: "the alert the user opened", trip: "the user's trip destination", device: "the user's current country and state", none: "" }[p.basis]
      }. Answer for this place only and say which place you mean (for example "In ${p.label}, ..."). If you do not know the rule for this place, say so and point to that place's official source.`
    : "- The place is not known. If the answer depends on local law or rules, say rules differ by place and ask which state or country.";
