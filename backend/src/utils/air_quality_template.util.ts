import { HazardSeverityBand } from "@prisma/client";
import type { AISummaryResponse } from "../models/ai_summary_response_interface.js";
import { waqiRatingFor } from "./waqi_rating.util.js";

/**
 * Deterministic, zero-AI content for Air Quality Alert category hazards
 * (WAQI-sourced today — see ingestion.service.ts's `airQualityAlert`
 * source). The classification standard's Health and Air Quality Standard
 * (§10) is explicit: "AQI cards use zero AI. Band, title, facts, and What
 * To Do all come from templates... Reviewed once by a human, rendered
 * thousands of times."
 *
 * COUNTRY-SPECIFIC ALIGNMENT (Oct 31 2026): Uses each country's official
 * air quality terminology. Australian stations use Australian official
 * categories (Fair/Poor/Very Poor/Extremely Poor), US stations use US EPA
 * terminology (Moderate/Unhealthy), etc. Complies with V2 planning docs:
 * ALRT_SEVERITY_VOCABULARY_REFERENCE.md forbids US EPA terms for Australia.
 *
 * ALL WORDING IS SUGGESTIVE/INFORMATIONAL per MASTER_DECISIONS_REGISTER.md
 * lines 69-70, 96: "AI may describe what is happening; only the library
 * tells anyone what to do" + "Advisory voice throughout; no movement advice
 * in ALRT's own voice."
 */

/**
 * Country-specific air quality configuration: official terminology, health
 * authorities, and pollutant context explanations.
 */
interface CountryAirQualityConfig {
  healthAuthority: string;
  pollutantContext: Record<string, string>;
  useAustralianTerms?: boolean;  // Map US EPA to Australian official categories
}

const COUNTRY_CONFIGS: Record<string, CountryAirQualityConfig> = {
  'AU': {
    healthAuthority: 'your state EPA or Department of Health',
    useAustralianTerms: true,  // Critical: use Australian categories, not US EPA
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

const DEFAULT_CONFIG: CountryAirQualityConfig = {
  healthAuthority: 'local health or environmental authorities',
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
 * Australian official air quality categories (from ALRT_SEVERITY_VOCABULARY_
 * REFERENCE.md). Maps WAQI US EPA ratings to Australian official terms.
 * Critical: "Moderate" and "Unhealthy" are US EPA wording and must not appear
 * for Australian stations.
 */
const getAustralianAirQualityRating = (aqiValue: number): string => {
  if (aqiValue <= 33) return "good";
  if (aqiValue <= 66) return "fair";           // NOT "moderate" (US EPA)
  if (aqiValue <= 99) return "poor";           // NOT "unhealthy for sensitive groups"
  if (aqiValue <= 149) return "very poor";     // NOT "unhealthy"
  return "extremely poor";                      // NOT "very unhealthy" or "hazardous"
};

/**
 * Fallback rating by band when AQI value unavailable. Uses US EPA for
 * non-Australian stations, Australian official for AU.
 */
const RATING_BY_BAND_US_EPA: Record<HazardSeverityBand, string> = {
  [HazardSeverityBand.info]: "good",
  [HazardSeverityBand.monitor]: "moderate",
  [HazardSeverityBand.action]: "unhealthy for sensitive groups",
  [HazardSeverityBand.critical]: "unhealthy",
};

const RATING_BY_BAND_AUSTRALIAN: Record<HazardSeverityBand, string> = {
  [HazardSeverityBand.info]: "good",
  [HazardSeverityBand.monitor]: "fair",        // NOT "moderate"
  [HazardSeverityBand.action]: "poor",         // NOT "unhealthy for sensitive groups"
  [HazardSeverityBand.critical]: "very poor",  // NOT "unhealthy"
};

const summaryFor = ({
  stationName,
  rating,
  pollutantContext,
}: {
  stationName: string;
  rating: string;
  pollutantContext?: string | undefined;
}): string => {
  const base = `World Air Quality Index reports that air quality near ${stationName} is ${rating}.`;
  return pollutantContext 
    ? `${base} The main pollutant is ${pollutantContext}.`
    : base;
};

/**
 * SUGGESTIVE/INFORMATIONAL wording only (MASTER_DECISIONS_REGISTER.md).
 * ALL countries use "Consider..." / "may" / "can help" wording.
 * NO directive language ("should", "must", "avoid all") unless quoting agency.
 */
const getCallsToAction = (
  severityBand: HazardSeverityBand,
  config: CountryAirQualityConfig
): string[] => {
  switch (severityBand) {
    case HazardSeverityBand.info:
      return [];
      
    case HazardSeverityBand.monitor:
      return [
        `Consider keeping an eye on air quality updates from ${config.healthAuthority} if you are sensitive to air pollution.`,
      ];
      
    case HazardSeverityBand.action:
      return [
        "Air pollution at this level can affect people with heart or lung conditions, older adults and children.",
        "Consider limiting long or strenuous outdoor activity, particularly if you have a breathing condition.",
        "If you have a breathing condition, consider keeping your usual medication within reach and following your care plan.",
        `For current health advice, ${config.healthAuthority} can help.`,
      ];
      
    case HazardSeverityBand.critical:
      return [
        "Air pollution at this level can affect anyone. People with heart or lung conditions, older adults and children may experience more serious effects.",
        "Consider staying indoors with windows and doors closed, and limiting time outside.",
        "If you have a breathing condition, consider following your care plan and keeping medication within reach.",
        "Any official fire or evacuation directions take priority over this advice.",
        `For current health advice, ${config.healthAuthority} can help.`,
        "If breathing becomes difficult, health professionals can help.",
      ];
      
    default:
      return [];
  }
};

/**
 * Extracts dominant pollutant and returns country-specific explanation.
 * Format in description: "Dominant pollutant: pm25"
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
 * Detects country from WAQI station location in title or description.
 * Returns country code (AU, US, NZ, etc.) or null if undetectable.
 */
const detectCountryFromStation = (
  title: string,
  description: string
): string | null => {
  const text = `${title} ${description}`;
  
  const patterns: Record<string, RegExp> = {
    'AU': /\b(Australia|Sydney|Melbourne|Brisbane|Perth|Adelaide|Canberra|Hobart|Darwin|Gold Coast|Newcastle|Wollongong|Geelong|Townsville|Cairns)\b/i,
    'NZ': /\b(New Zealand|Auckland|Wellington|Christchurch|Hamilton|Tauranga|Dunedin|Palmerston North)\b/i,
    'US': /\b(United States|USA|America|New York|Los Angeles|Chicago|Houston|Phoenix|Philadelphia|San Antonio|San Diego|Dallas|San Jose|Austin|Jacksonville|Fort Worth|Columbus|San Francisco|Charlotte|Indianapolis|Seattle|Denver|Washington|Boston|El Paso|Nashville|Detroit|Oklahoma|Portland|Las Vegas|Memphis|Louisville|Baltimore|Milwaukee|Albuquerque|Tucson|Fresno|Sacramento|Mesa|Kansas City|Atlanta|Long Beach|Colorado Springs|Raleigh|Miami|Virginia Beach|Omaha|Oakland|Minneapolis|Tulsa|Arlington|Tampa|New Orleans)\b/i,
    'GB': /\b(United Kingdom|UK|Britain|England|Scotland|Wales|London|Manchester|Birmingham|Leeds|Glasgow|Sheffield|Liverpool|Edinburgh|Bristol|Cardiff|Belfast|Leicester|Coventry|Bradford|Nottingham|Kingston|Plymouth)\b/i,
    'ID': /\b(Indonesia|Jakarta|Surabaya|Bandung|Bekasi|Medan|Tangerang|Depok|Semarang|Palembang|Makassar|South Tangerang|Batam|Bogor|Pekanbaru|Bandar Lampung|Malang|Padang|Denpasar|Bali)\b/i,
    'TH': /\b(Thailand|Bangkok|Samut Prakan|Chiang Mai|Hat Yai|Nonthaburi|Pak Kret|Si Racha|Phuket|Khon Kaen|Udon Thani|Surat Thani|Nakhon Ratchasima|Pattaya)\b/i,
    'SG': /\b(Singapore)\b/i,
    'JP': /\b(Japan|Tokyo|Yokohama|Osaka|Nagoya|Sapporo|Fukuoka|Kobe|Kyoto|Kawasaki|Saitama|Hiroshima|Sendai|Kitakyushu|Chiba|Sakai|Niigata|Hamamatsu|Kumamoto|Sagamihara|Shizuoka|Okayama)\b/i,
    'CN': /\b(China|Beijing|Shanghai|Guangzhou|Shenzhen|Chengdu|Chongqing|Tianjin|Harbin|Suzhou|Wuhan|Hangzhou|Nanjing|Xi'an|Dongguan|Shenyang|Qingdao|Jinan|Changsha|Zhengzhou|Dalian|Kunming|Taiyuan|Changchun|Nanning|Hefei|Urumqi|Shijiazhuang|Guiyang|Nanchang|Lanzhou)\b/i,
    'IN': /\b(India|Delhi|Mumbai|Bangalore|Kolkata|Chennai|Hyderabad|Ahmedabad|Pune|Surat|Jaipur|Lucknow|Kanpur|Nagpur|Indore|Thane|Bhopal|Visakhapatnam|Pimpri-Chinchwad|Patna|Vadodara|Ghaziabad|Ludhiana|Agra|Nashik|Faridabad|Meerut|Rajkot|Kalyan-Dombivali|Vasai-Virar)\b/i,
    'IT': /\b(Italy|Rome|Milan|Naples|Turin|Palermo|Genoa|Bologna|Florence|Bari|Catania|Venice|Verona|Messina|Padua|Trieste|Brescia|Taranto|Prato|Reggio Calabria|Modena|Parma)\b/i,
    'FR': /\b(France|Paris|Marseille|Lyon|Toulouse|Nice|Nantes|Strasbourg|Montpellier|Bordeaux|Lille|Rennes|Reims|Le Havre|Saint-Étienne|Toulon|Grenoble|Dijon|Angers|Nîmes|Villeurbanne|Saint-Denis|Le Mans|Aix-en-Provence|Clermont-Ferrand|Brest|Limoges|Tours|Amiens|Perpignan)\b/i,
    'MY': /\b(Malaysia|Kuala Lumpur|George Town|Ipoh|Shah Alam|Petaling Jaya|Johor Bahru|Malacca|Alor Setar|Seremban|Kuala Terengganu|Kota Kinabalu|Kuching|Penang)\b/i,
    'VN': /\b(Vietnam|Ho Chi Minh|Hanoi|Haiphong|Da Nang|Bien Hoa|Hue|Nha Trang|Can Tho|Rach Gia|Qui Nhon|Vung Tau)\b/i,
    'FJ': /\b(Fiji|Suva|Nadi|Lautoka|Labasa|Ba)\b/i,
  };
  
  for (const [code, pattern] of Object.entries(patterns)) {
    if (pattern.test(text)) {
      return code;
    }
  }
  
  return null;
};

/** Extracts numeric AQI from description. Never shown to users. */
export const parseAqiValueFromDescription = (
  description: string,
): number | null => {
  const match = /AQI:\s*(\d+)/.exec(description);
  if (!match || match[1] === undefined) return null;
  const value = parseInt(match[1], 10);
  return Number.isFinite(value) ? value : null;
};

/** Extracts station name from description. */
export const parseStationNameFromDescription = (
  description: string,
  fallbackTitle: string,
): string => {
  const match = /Station:\s*(.+)/.exec(description);
  const name = match?.[1]?.trim();
  return name && name.length > 0 ? name : fallbackTitle;
};

/**
 * Gets the appropriate air quality rating string, using country-specific
 * official terminology where applicable.
 */
const getRatingForCountry = (
  aqiValue: number | null,
  countryCode: string | null,
  severityBand: HazardSeverityBand,
  ratingLine?: string
): string => {
  // Use rating from description if available
  if (ratingLine) return ratingLine.toLowerCase();
  
  // Use AQI value with country-specific mapping
  if (aqiValue !== null) {
    if (countryCode === 'AU') {
      return getAustralianAirQualityRating(aqiValue);
    }
    // All other countries use WAQI's US EPA terminology
    const usEpaRating = waqiRatingFor(aqiValue);
    return usEpaRating ? usEpaRating.toLowerCase() : RATING_BY_BAND_US_EPA[severityBand];
  }
  
  // Fallback to band-based rating
  return countryCode === 'AU' 
    ? RATING_BY_BAND_AUSTRALIAN[severityBand]
    : RATING_BY_BAND_US_EPA[severityBand];
};

/**
 * Builds deterministic AQI card with country-aligned terminology and
 * suggestive wording. Australian stations use Australian official categories;
 * all other stations use WAQI's US EPA terminology.
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
  
  // Detect country and get config
  const countryCode = detectCountryFromStation(title, description);
  const config = countryCode && COUNTRY_CONFIGS[countryCode] 
    ? COUNTRY_CONFIGS[countryCode] 
    : DEFAULT_CONFIG;
  
  // Get rating with country-specific terminology
  const rating = getRatingForCountry(aqiValue, countryCode, severityBand, ratingLine);
  
  // Get pollutant context if available
  const pollutantContext = getPollutantContext(description, config);
  
  return {
    title,
    summary: summaryFor({ stationName, rating, pollutantContext }),
    callsToAction: getCallsToAction(severityBand, config),
    confidence: "high",
  };
};
