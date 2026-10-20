/**
 * WAQI's own rating words and what each one means for people. Kept free
 * of every other import so both the WAQI parser (ingestion.util.ts) and
 * the deterministic air quality card template
 * (air_quality_template.util.ts) can share one set of thresholds without
 * pulling in the ingestion dependency chain.
 */

/**
 * WAQI's own category names for its (US EPA based) index, as published on
 * aqicn.org. Passed through attributed to WAQI, never as ALRT's rating and
 * never mapped onto an Australian state index.
 */
export const waqiRatingFor = (aqi: number): string | null => {
  if (!Number.isFinite(aqi) || aqi < 0) return null;
  if (aqi <= 50) return "Good";
  if (aqi <= 100) return "Moderate";
  if (aqi <= 150) return "Unhealthy for sensitive groups";
  if (aqi <= 200) return "Unhealthy";
  if (aqi <= 300) return "Very unhealthy";
  return "Hazardous";
};

/**
 * What each WAQI rating means for people, in plain words, from the US EPA
 * AQI category descriptions WAQI publishes. Attributed as the rating's
 * meaning, never as agency advice; it says who may notice effects, not
 * what to do.
 */
export const waqiRatingMeaning = (aqi: number): string | null => {
  if (!Number.isFinite(aqi) || aqi < 0) return null;
  // Who may notice effects, only. Never a reassurance such as "most
  // people are unlikely to be affected" unless an agency said it
  // (product owner, 16 Oct 2026).
  if (aqi <= 50) return null;
  if (aqi <= 100) {
    return "People who are unusually sensitive to air pollution may notice effects.";
  }
  if (aqi <= 150) {
    return "People with heart or lung conditions, older adults, children and people active outdoors may notice effects.";
  }
  if (aqi <= 200) {
    return "Anyone may begin to notice health effects. People with heart or lung conditions, older adults and children may notice more serious effects.";
  }
  if (aqi <= 300) {
    return "A health alert level. Everyone may notice health effects, and sensitive groups may notice more serious effects.";
  }
  return "Emergency conditions. The whole population is more likely to be affected.";
};
