import { HazardSeverityBand } from "@prisma/client";
import type { AISummaryResponse } from "../models/ai_summary_response_interface.js";
import { waqiRatingFor } from "./waqi_rating.util.js";

/**
 * Deterministic, zero-AI content for Air Quality Alert category hazards
 * (WAQI-sourced today — see ingestion.service.ts's `airQualityAlert`
 * source). The classification standard's Health and Air Quality Standard
 * (§10) is explicit: "AQI cards use zero AI. Band, title, facts, and What
 * To Do all come from templates... Reviewed once by a human, rendered
 * thousands of times." Before this, AQI hazards went through the same
 * free-form AI call as every other official alert, with the model merely
 * told to "STRICTLY follow" canned example wording rather than the wording
 * being used directly and deterministically.
 *
 * The legacy fallback below now labels ALRT suggestions and defers to
 * local health advice and official fire/evacuation instructions. Published
 * templates select editable suggestions and profile rows from the reviewed
 * library. These statements are never attributed to WAQI as instructions.
 *
 * COUNTRY-SPECIFIC SUPPORT (Oct 31 2026): Health authority references and
 * advice style adapted for top Australian travel destinations plus high-
 * pollution countries (AU, NZ, US, GB, ID, TH, SG, JP, CN, IN, IT, FR, FJ,
 * MY, VN). Detects country from WAQI station location when available.
 */

/**
 * Country-specific health authority references and advice style preferences.
 * Keeps Australian "consider..." wording style for similar English-speaking
 * countries, uses direct instructions for others following local conventions.
 */
interface CountryAirQualityConfig {
  healthAuthority: string;
  adviceStyle: 'consider' | 'direct';
  pollutantContext: Record<string, string>;  // PM2.5, PM10, O3 explanations
}

const COUNTRY_CONFIGS: Record<string, CountryAirQualityConfig> = {
  'AU': {
    healthAuthority: 'your state EPA or Department of Health',
    adviceStyle: 'consider',
    pollutantContext: {
      'pm25': 'fine particle pollution, often from bushfire smoke, vehicle emissions or industry',
      'pm10': 'coarse particle pollution, often from dust storms, construction or roads',
      'o3': 'ground-level ozone, which forms on hot sunny days from vehicle and industrial emissions',
      'no2': 'nitrogen dioxide from vehicle and industrial emissions',
      'so2': 'sulfur dioxide from coal-fired power or industrial processes',
      'co': 'carbon monoxide from vehicle exhaust or combustion',
    }
  },
  'NZ': {
    healthAuthority: 'your regional council or the Ministry of Health',
    adviceStyle: 'consider',
    pollutantContext: {
      'pm25': 'fine particle pollution, which may be from bushfire smoke or local sources',
      'pm10': 'coarse particle pollution from dust, construction or traffic',
      'o3': 'ground-level ozone from vehicle emissions',
      'no2': 'nitrogen dioxide from traffic and industry',
      'so2': 'sulfur dioxide from industrial sources',
      'co': 'carbon monoxide from vehicle exhaust',
    }
  },
  'US': {
    healthAuthority: 'AirNow.gov or your state air quality agency',
    adviceStyle: 'direct',
    pollutantContext: {
      'pm25': 'fine particle pollution, common from wildfires, vehicle emissions, or industrial sources',
      'pm10': 'coarse particle pollution from dust, construction, or agricultural activities',
      'o3': 'ground-level ozone, which forms in sunlight from vehicle and industrial emissions',
      'no2': 'nitrogen dioxide from traffic and power generation',
      'so2': 'sulfur dioxide from power plants and industrial facilities',
      'co': 'carbon monoxide from vehicle exhaust and combustion',
    }
  },
  'GB': {
    healthAuthority: 'your local authority or the NHS',
    adviceStyle: 'consider',
    pollutantContext: {
      'pm25': 'fine particle pollution from traffic, heating and industry',
      'pm10': 'coarse particle pollution from traffic, construction and natural sources',
      'o3': 'ground-level ozone formed in sunlight from traffic emissions',
      'no2': 'nitrogen dioxide from road traffic',
      'so2': 'sulfur dioxide from industrial processes',
      'co': 'carbon monoxide from vehicle exhaust',
    }
  },
  'ID': {
    healthAuthority: 'local health authorities',
    adviceStyle: 'direct',
    pollutantContext: {
      'pm25': 'fine particle pollution, often from traffic or seasonal forest fires',
      'pm10': 'coarse particle pollution from dust and traffic',
      'o3': 'ground-level ozone from vehicle emissions',
      'no2': 'nitrogen dioxide from traffic',
      'so2': 'sulfur dioxide from industrial sources',
      'co': 'carbon monoxide from traffic and combustion',
    }
  },
  'TH': {
    healthAuthority: 'local health authorities',
    adviceStyle: 'direct',
    pollutantContext: {
      'pm25': 'fine particle pollution, often from traffic or seasonal agricultural burning',
      'pm10': 'coarse particle pollution from dust and traffic',
      'o3': 'ground-level ozone formed in hot weather',
      'no2': 'nitrogen dioxide from traffic',
      'so2': 'sulfur dioxide from industry',
      'co': 'carbon monoxide from traffic',
    }
  },
  'SG': {
    healthAuthority: 'the National Environment Agency',
    adviceStyle: 'direct',
    pollutantContext: {
      'pm25': 'fine particle pollution, sometimes from regional haze or traffic',
      'pm10': 'coarse particle pollution from haze or construction',
      'o3': 'ground-level ozone',
      'no2': 'nitrogen dioxide from traffic',
      'so2': 'sulfur dioxide from shipping and industry',
      'co': 'carbon monoxide from traffic',
    }
  },
  'JP': {
    healthAuthority: 'local environmental authorities',
    adviceStyle: 'consider',
    pollutantContext: {
      'pm25': 'fine particle pollution, sometimes from seasonal cross-border transport or local sources',
      'pm10': 'coarse particle pollution',
      'o3': 'ground-level ozone',
      'no2': 'nitrogen dioxide from traffic',
      'so2': 'sulfur dioxide',
      'co': 'carbon monoxide from traffic',
    }
  },
  'CN': {
    healthAuthority: 'local environmental protection bureau',
    adviceStyle: 'direct',
    pollutantContext: {
      'pm25': 'fine particle pollution from industrial emissions, heating and traffic',
      'pm10': 'coarse particle pollution from dust and industry',
      'o3': 'ground-level ozone',
      'no2': 'nitrogen dioxide from traffic and industry',
      'so2': 'sulfur dioxide from coal burning and industry',
      'co': 'carbon monoxide from traffic and combustion',
    }
  },
  'IN': {
    healthAuthority: 'local health authorities or the Central Pollution Control Board',
    adviceStyle: 'direct',
    pollutantContext: {
      'pm25': 'fine particle pollution from traffic, industry, construction and crop burning',
      'pm10': 'coarse particle pollution from dust, traffic and construction',
      'o3': 'ground-level ozone',
      'no2': 'nitrogen dioxide from traffic and industry',
      'so2': 'sulfur dioxide from industry',
      'co': 'carbon monoxide from traffic',
    }
  },
  'IT': {
    healthAuthority: 'local environmental or health authorities',
    adviceStyle: 'consider',
    pollutantContext: {
      'pm25': 'fine particle pollution from traffic and heating',
      'pm10': 'coarse particle pollution from traffic and dust',
      'o3': 'ground-level ozone',
      'no2': 'nitrogen dioxide from traffic',
      'so2': 'sulfur dioxide',
      'co': 'carbon monoxide from traffic',
    }
  },
  'FR': {
    healthAuthority: 'local environmental or health authorities',
    adviceStyle: 'consider',
    pollutantContext: {
      'pm25': 'fine particle pollution from traffic and heating',
      'pm10': 'coarse particle pollution from traffic and dust',
      'o3': 'ground-level ozone',
      'no2': 'nitrogen dioxide from traffic',
      'so2': 'sulfur dioxide',
      'co': 'carbon monoxide from traffic',
    }
  },
  'MY': {
    healthAuthority: 'local health authorities',
    adviceStyle: 'direct',
    pollutantContext: {
      'pm25': 'fine particle pollution, often from seasonal haze from forest fires',
      'pm10': 'coarse particle pollution from haze and traffic',
      'o3': 'ground-level ozone',
      'no2': 'nitrogen dioxide from traffic',
      'so2': 'sulfur dioxide',
      'co': 'carbon monoxide from traffic',
    }
  },
  'VN': {
    healthAuthority: 'local health authorities',
    adviceStyle: 'direct',
    pollutantContext: {
      'pm25': 'fine particle pollution from traffic and industry',
      'pm10': 'coarse particle pollution from dust and traffic',
      'o3': 'ground-level ozone',
      'no2': 'nitrogen dioxide from traffic',
      'so2': 'sulfur dioxide from industry',
      'co': 'carbon monoxide from traffic',
    }
  },
  'FJ': {
    healthAuthority: 'local health authorities',
    adviceStyle: 'consider',
    pollutantContext: {
      'pm25': 'fine particle pollution',
      'pm10': 'coarse particle pollution',
      'o3': 'ground-level ozone',
      'no2': 'nitrogen dioxide',
      'so2': 'sulfur dioxide',
      'co': 'carbon monoxide',
    }
  },
};

// Fallback for countries not in the list above
const DEFAULT_CONFIG: CountryAirQualityConfig = {
  healthAuthority: 'local health or environmental authorities',
  adviceStyle: 'consider',
  pollutantContext: {
    'pm25': 'fine particle pollution',
    'pm10': 'coarse particle pollution',
    'o3': 'ground-level ozone',
    'no2': 'nitrogen dioxide',
    'so2': 'sulfur dioxide',
    'co': 'carbon monoxide',
  }
};

/**
 * The summary is the source's statement, in the source's own rating words
 * and never a number (product owner, 16 Oct 2026; purge list, pack file
 * 03): "World Air Quality Index reports that air quality near {station}
 * is {rating}." The rating comes from the description line the parser
 * wrote; for an older record without that line it is WAQI's rating for
 * the machine "AQI: n" field, and the band is the last fallback.
 * 
 * POLLUTANT CONTEXT (Oct 31 2026): Optionally adds "The main pollutant is
 * {explanation}." when dominant pollutant is available in description.
 */
const RATING_BY_BAND: Record<HazardSeverityBand, string> = {
  [HazardSeverityBand.info]: "good",
  [HazardSeverityBand.monitor]: "moderate",
  [HazardSeverityBand.action]: "unhealthy for sensitive groups",
  [HazardSeverityBand.critical]: "unhealthy",
};

const summaryFor = ({
  stationName,
  rating,
  pollutantContext,
}: {
  stationName: string;
  rating: string;
  pollutantContext?: string;
}): string => {
  const base = `World Air Quality Index reports that air quality near ${stationName} is ${rating}.`;
  return pollutantContext 
    ? `${base} The main pollutant is ${pollutantContext}.`
    : base;
};

/**
 * ALRT's own practical lines, no prefix (product owner, 16 Oct 2026):
 * "Consider ..." wording, or a plain safety statement. The app labels
 * them as general guidance from ALRT under the block.
 * 
 * COUNTRY-SPECIFIC (Oct 31 2026): Adapts wording style and health authority
 * reference based on detected country. Australian style uses "Consider..."
 * throughout; some countries use more direct instructions.
 */
const getCallsToAction = (
  severityBand: HazardSeverityBand,
  config: CountryAirQualityConfig
): string[] => {
  const isConsiderStyle = config.adviceStyle === 'consider';
  
  switch (severityBand) {
    case HazardSeverityBand.info:
      return [];
      
    case HazardSeverityBand.monitor:
      return isConsiderStyle
        ? [
            "Consider keeping an eye on official air quality updates if you are sensitive to air pollution.",
          ]
        : [
            "People who are unusually sensitive to air pollution should check official updates.",
          ];
      
    case HazardSeverityBand.action:
      return isConsiderStyle
        ? [
            "Air pollution at this level can affect people with heart or lung conditions, older adults and children.",
            "Consider limiting long or strenuous outdoor activity, particularly if you have a breathing condition.",
            "If you have a breathing condition, consider keeping your usual medication within reach and following your care plan.",
            `For current health advice, consult ${config.healthAuthority}.`,
          ]
        : [
            "People with heart or lung disease, older adults, children, and those who are active outdoors should limit prolonged outdoor exertion.",
            "Everyone else can continue normal outdoor activities.",
            "Keep rescue inhalers accessible if you have asthma.",
            `Check ${config.healthAuthority} for current conditions.`,
          ];
      
    case HazardSeverityBand.critical:
      return isConsiderStyle
        ? [
            "Air pollution at this level can affect anyone. People with heart or lung conditions, older adults and children may experience more serious effects.",
            "Consider staying indoors with windows and doors closed, and limiting time outside.",
            "If you have a breathing condition, consider following your care plan and keeping medication within reach.",
            "Any official fire or evacuation directions take priority over this advice.",
            `For current health advice, consult ${config.healthAuthority}.`,
            "If breathing becomes difficult, health professionals can help.",
          ]
        : [
            "Everyone should limit prolonged outdoor exertion.",
            "People with heart or lung disease, older adults, and children should avoid prolonged outdoor exertion.",
            "Stay indoors with windows closed when possible.",
            "If you have asthma or another breathing condition, follow your care plan.",
            "Any official fire or evacuation directions take priority over this advice.",
            `Check ${config.healthAuthority} for current conditions.`,
            "If breathing becomes difficult, seek medical attention.",
          ];
      
    default:
      return [];
  }
};

/**
 * Extracts the dominant pollutant from WAQI description and returns
 * country-specific explanation. Format: "Dominant pollutant: pm25"
 */
const getPollutantContext = (
  description: string,
  config: CountryAirQualityConfig
): string | undefined => {
  const match = /Dominant pollutant:\s*([a-z0-9]+)/i.exec(description);
  const pollutant = match?.[1]?.toLowerCase();
  return pollutant && config.pollutantContext[pollutant]
    ? config.pollutantContext[pollutant]
    : undefined;
};

/**
 * Detects country from WAQI station location in description or title.
 * Format examples: "Station: Sydney, Australia" or "Delhi, India"
 * Falls back to DEFAULT_CONFIG if country cannot be detected.
 */
const detectCountryFromStation = (
  title: string,
  description: string
): CountryAirQualityConfig => {
  const text = `${title} ${description}`;
  
  // Common country name patterns in WAQI station names
  const patterns: Record<string, RegExp> = {
    'AU': /\b(Australia|Sydney|Melbourne|Brisbane|Perth|Adelaide|Canberra|Hobart|Darwin)\b/i,
    'NZ': /\b(New Zealand|Auckland|Wellington|Christchurch|Hamilton)\b/i,
    'US': /\b(United States|USA|America|New York|Los Angeles|Chicago|Houston|Phoenix|San Francisco|Seattle|Boston|Miami)\b/i,
    'GB': /\b(United Kingdom|UK|Britain|London|Manchester|Birmingham|Leeds|Glasgow|Edinburgh)\b/i,
    'ID': /\b(Indonesia|Jakarta|Surabaya|Bandung|Bali|Medan)\b/i,
    'TH': /\b(Thailand|Bangkok|Chiang Mai|Phuket|Pattaya)\b/i,
    'SG': /\b(Singapore)\b/i,
    'JP': /\b(Japan|Tokyo|Osaka|Kyoto|Yokohama|Nagoya|Sapporo|Fukuoka)\b/i,
    'CN': /\b(China|Beijing|Shanghai|Guangzhou|Shenzhen|Chengdu|Hangzhou|Wuhan|Xi'an)\b/i,
    'IN': /\b(India|Delhi|Mumbai|Bangalore|Kolkata|Chennai|Hyderabad|Pune|Ahmedabad)\b/i,
    'IT': /\b(Italy|Rome|Milan|Naples|Turin|Florence|Venice)\b/i,
    'FR': /\b(France|Paris|Marseille|Lyon|Toulouse|Nice|Bordeaux)\b/i,
    'MY': /\b(Malaysia|Kuala Lumpur|Penang|Johor Bahru)\b/i,
    'VN': /\b(Vietnam|Hanoi|Ho Chi Minh|Da Nang|Hai Phong)\b/i,
    'FJ': /\b(Fiji|Suva|Nadi|Lautoka)\b/i,
  };
  
  for (const [code, pattern] of Object.entries(patterns)) {
    if (pattern.test(text)) {
      return COUNTRY_CONFIGS[code] || DEFAULT_CONFIG;
    }
  }
  
  return DEFAULT_CONFIG;
};

/** Extracts the numeric AQI value from parseWAQIToHazards's description (machine field "AQI: 87"). Never shown to people; returns null if absent. */
export const parseAqiValueFromDescription = (
  description: string,
): number | null => {
  const match = /AQI:\s*(\d+)/.exec(description);
  if (!match || match[1] === undefined) return null;
  const value = parseInt(match[1], 10);
  return Number.isFinite(value) ? value : null;
};

/** Extracts the station name from parseWAQIToHazards's fixed-format description ("Station: X\n..."). Falls back to the given title if the format ever changes. */
export const parseStationNameFromDescription = (
  description: string,
  fallbackTitle: string,
): string => {
  const match = /Station:\s*(.+)/.exec(description);
  const name = match?.[1]?.trim();
  return name && name.length > 0 ? name : fallbackTitle;
};

/**
 * Builds the deterministic AQI card content. Confidence is always "high" —
 * there is no interpretation step to be uncertain about; the value came
 * directly from the source feed.
 * 
 * COUNTRY-AWARE (Oct 31 2026): Detects country from station location,
 * adapts health authority references and advice style, adds pollutant
 * context when available.
 */
export const getDeterministicAirQualityContent = ({
  title,
  description,
  severityBand,
}: {
  title: string;
  description: string;
  severityBand: HazardSeverityBand;
}): AISummaryResponse => {
  const stationName = parseStationNameFromDescription(description, title);
  const ratingLine = /Air quality:\s*(.+?)\s*\(World Air Quality Index rating\)/.exec(
    description,
  )?.[1]?.trim();
  const aqiValue = parseAqiValueFromDescription(description);
  const rating = (
    ratingLine ??
    (aqiValue !== null ? waqiRatingFor(aqiValue) : null) ??
    RATING_BY_BAND[severityBand]
  ).toLowerCase();
  
  // Detect country and get appropriate config
  const config = detectCountryFromStation(title, description);
  
  // Get pollutant context if available
  const pollutantContext = getPollutantContext(description, config);
  
  return {
    title,
    summary: summaryFor({ stationName, rating, ...(pollutantContext !== undefined ? { pollutantContext } : {}) }),
    callsToAction: getCallsToAction(severityBand, config),
    confidence: "high",
  };
};
