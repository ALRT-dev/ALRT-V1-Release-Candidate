/**
 * Which safety guide goes with which hazard category (owner review,
 * 13 November 2026): "the correct categories need to be linked".
 *
 * Guides used to be linked by substring keywords at seed time, so "fire"
 * put bushfire guides on Vehicle Fire and Structural Fire, "weather" put the
 * storm guide on Fire Weather, and subcategories such as Power Outage got no
 * guide at all because only their parent matched. This table names each
 * category exactly. A category that is not listed gets no guide: no guide is
 * better than the wrong one.
 *
 * Where a hazard has before/during/after guides, the alert's level picks the
 * stage: an active warning gets the "during" guide, an advice the "before"
 * guide, and a cancelled or resolved alert the "after" guide.
 */

export type GuideStage = "before" | "during" | "after";

type StagedSlugs = { before: string; during?: string; after?: string };

const BUSHFIRE: StagedSlugs = {
  before: "bushfire-being-prepared",
  during: "bushfire-during",
  after: "bushfire-after",
};
const FLOOD: StagedSlugs = {
  before: "flood-being-prepared",
  during: "flash-flooding",
};
const one = (slug: string): StagedSlugs => ({ before: slug });

/** Lower-case category name -> guide(s). */
const CATEGORY_GUIDES: Record<string, StagedSlugs> = {
  // Fire. Only bushfire and fire weather get bushfire guides.
  bushfire: BUSHFIRE,
  "grass fire": BUSHFIRE,
  "scrub fire": BUSHFIRE,
  "fire weather": one("bushfire-being-prepared"),

  // Flood and water.
  flood: FLOOD,
  "river rise": FLOOD,
  "dam safety": FLOOD,
  "dam spill": FLOOD,
  "dam overflow": FLOOD,
  "dam discharge": FLOOD,
  "heavy rain": one("flash-flooding"),
  "water over road": one("driving-near-floodwater"),

  // Storm and wind.
  storm: one("severe-storm"),
  "damaging winds": one("severe-storm"),
  "strong winds": one("severe-storm"),
  "large hail": one("severe-storm"),
  "hail storm": one("severe-storm"),
  "tree down": one("severe-storm"),
  cyclone: one("cyclone"),

  // Heat.
  "extreme heat": one("heatwave"),
  "heat health alert": one("heatwave"),
  "heat stress": one("heatwave"),

  // Earth and sea.
  earthquake: one("earthquake"),
  tsunami: one("tsunami-warning"),

  // Safety and crowds.
  crime: one("home-security"),
  terror: one("crowded-events-civil-unrest"),
  protest: one("crowded-events-civil-unrest"),
  "concert/festival": one("crowded-events-civil-unrest"),
  "large sporting event": one("crowded-events-civil-unrest"),
  "venue evacuation": one("crowded-events-civil-unrest"),
  "public transport crowding": one("crowded-events-civil-unrest"),

  // Utilities.
  "power outage": one("power-outage"),
  "power interruption": one("power-outage"),
  "loss of power": one("power-outage"),
  brownout: one("power-outage"),
  "gas leak": one("gas-leak"),
  "gas incident": one("gas-leak"),
  "water issue": one("water-contamination"),
  "water supply interruption": one("water-contamination"),
  "boil water notice": one("water-contamination"),
  "boil water alert": one("water-contamination"),
};

const RESOLVED =
  /\b(?:no longer|all clear|safe to return|cancel(?:l?ed|lation)?|ended|over|resolved|contained|under control|controlled|closed|lifted|downgraded|stood down)\b/i;
const ACTIVE =
  /\b(?:emergency warning|watch and act|act now|take action|leave now|evacuat\w*|shelter|critical|action|red|orange|severe|extreme)\b/i;

/** The guide stage an alert level calls for. */
export const guideStageForLevel = (level?: string | null): GuideStage => {
  const value = level?.trim() ?? "";
  if (!value) return "before";
  if (RESOLVED.test(value)) return "after";
  if (ACTIVE.test(value)) return "during";
  return "before";
};

/**
 * The guide slug for a category and level, trying the category's own name
 * and then its parent's. Null when neither is listed.
 */
export const guideSlugForCategory = (options: {
  name?: string | null;
  parentName?: string | null;
  level?: string | null;
}): string | null => {
  const entry =
    CATEGORY_GUIDES[options.name?.trim().toLowerCase() ?? ""] ??
    CATEGORY_GUIDES[options.parentName?.trim().toLowerCase() ?? ""];
  if (!entry) return null;
  const stage = guideStageForLevel(options.level);
  if (stage === "during") return entry.during ?? entry.before;
  if (stage === "after") return entry.after ?? entry.before;
  return entry.before;
};

/** Every slug the table can return, for tests and the admin. */
export const linkedGuideSlugs = (): string[] => [
  ...new Set(
    Object.values(CATEGORY_GUIDES).flatMap((entry) =>
      [entry.before, entry.during, entry.after].filter(
        (slug): slug is string => Boolean(slug),
      ),
    ),
  ),
];
