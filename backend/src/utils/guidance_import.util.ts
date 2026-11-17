import forYou from "../data/for_you_rows.json" with { type: "json" };
import { EMERGENCY_NUMBER_DEFAULTS } from "../constants/emergency_number_defaults.js";
import { guides } from "../services/guide_seed.service.js";
import { BUILT_IN_ENTRIES } from "./ask_alrt_content.util.js";
import { SAFETY_GROUPS, hazardSafetyLibrary } from "./hazard_safety_library.util.js";
import { buildKey, type GuidanceInput } from "./guidance_library.util.js";
import { COUNTRY_WARNING_ANSWERS, DRAFT_GUIDES, DRAFT_PROFILE_LINES, GUIDE_ANSWERS, NATIONAL_GUIDES } from "../data/guidance_drafts_20261116.js";

/**
 * One-off import of the five existing guidance stores into the shared
 * library. Everything imported was already approved by the owner, so it
 * lands approved, version 1, with the source it already names. Records with
 * no page-level source are flagged by the coverage grid and the daily
 * assurance check rather than blocked.
 */

/** For you bucket -> alert template categories (for sending to Alert Templates). */
export const FOR_YOU_BUCKET_CATEGORIES: Record<string, string[]> = {
  bushfire: [...SAFETY_GROUPS.bushfire],
  flood: [...SAFETY_GROUPS.flood],
  cyclone: ["cyclone"],
  smoke: ["smoke", "smokePlume", "ashfall"],
  chemical: [...SAFETY_GROUPS.hazmat],
  severe_weather: ["storm", "damagingWinds", "strongWinds", "largeHail", "hailStorm", "treeDown"],
  air_quality: ["airQualityAlert"],
  public_health: [...SAFETY_GROUPS.publicHealth],
  civil_unrest: ["protest"],
  structure_fire: ["structuralFire"],
  utility_outage: ["powerOutage", "powerInterruption", "lossOfPower", "brownout"],
  dust_storm: ["dustStorm"],
  pollen: ["asthmaAlert"],
  water_quality: ["boilWaterNotice", "boilWaterAlert", "waterIssue", "algaeBloom"],
  evac_centre: ["evacuationCenter"],
  heatwave: [...SAFETY_GROUPS.heat],
  cold_snap: ["snow"],
  rough_surf: ["hazardousSurf", "coastalHazard"],
  earthquake: ["earthquake"],
  tsunami: ["tsunami"],
  snakes: ["snakeSighting"],
  shark: ["sharkSighting"],
  landslide: ["landslide", "landSlip"],
  // Matched by alert title only in the app, so not sent to templates:
  grass_fire: [], haze: [], wildlife: [], health_capacity: [], school_holidays: [],
  fuel_supply: [], crocodile: [], tornado: [],
};

/** Library hazard key -> alert template category ids. */
export const categoryIdsForHazard = (hazard: string): string[] =>
  (SAFETY_GROUPS as Record<string, readonly string[]>)[hazard]
    ? [...(SAFETY_GROUPS as Record<string, readonly string[]>)[hazard]!]
    : FOR_YOU_BUCKET_CATEGORIES[hazard] ?? [];

const FIRST_URL = /https?:\/\/[^\s);,]+|(?:[a-z0-9-]+\.)+(?:gov\.au|org\.au|com\.au|gov|org)(?:\/[^\s);,]*)?/i;

const splitReference = (reference: string): { agency: string; url: string } => {
  const body = reference.replace(/^Drafted for owner review from:\s*/i, "");
  const m = body.match(FIRST_URL);
  const url = m ? (m[0].startsWith("http") ? m[0] : `https://${m[0]}`).replace(/^http:/, "https:") : "";
  const agency = body.split(/[,(;]/)[0]!.trim() || "ALRT reviewed library";
  return { agency, url };
};

export type ImportRecord = GuidanceInput & { key: string; reviewedAt: string; changeNote: string };

export const buildImportRecords = (): ImportRecord[] => {
  const out: ImportRecord[] = [];

  // 1. Alert advice library (approved 13 Nov 2026).
  const groupOf = (categoryIds: readonly string[]): string =>
    Object.entries(SAFETY_GROUPS).find(([, ids]) => (ids as readonly string[]).includes(categoryIds[0] ?? ""))?.[0] ?? "general";
  for (const e of hazardSafetyLibrary()) {
    const { agency, url } = splitReference(e.reference);
    const hazard = groupOf(e.categoryIds);
    out.push({
      key: `advice:${hazard}:-:-:${e.countries[0] ?? "AU"}:${e.id.replace(/^safety-/, "")}`,
      kind: "advice", hazard, jurisdiction: e.countries[0] ?? "AU", text: e.text,
      sourceAgency: agency, sourceUrl: url, bands: [...e.bands],
      reviewedAt: e.reviewedAt ?? "2026-11-13", changeNote: `Imported from the alert advice library (${e.id}).`,
    });
  }

  // 2. Safety Profile lines (owner-reviewed Aug 2026, revised to 16 Nov 2026).
  const rows = (forYou as { rows: Record<string, Record<string, string>>; globalRows: Record<string, string> });
  for (const [bucket, byCohort] of Object.entries(rows.rows)) {
    for (const [cohort, text] of Object.entries(byCohort)) {
      out.push({
        key: buildKey({ kind: "profile", hazard: bucket, cohort, jurisdiction: "AU" }, "line"),
        kind: "profile", hazard: bucket, cohort, jurisdiction: "AU", text,
        sourceAgency: "ALRT reviewed Safety Profile library", sourceUrl: "",
        reviewedAt: "2026-11-16", changeNote: "Imported from the app's Safety Profile library. Add the official source for each line.",
      });
    }
  }
  for (const [cohort, text] of Object.entries(rows.globalRows)) {
    out.push({
      key: buildKey({ kind: "profile", hazard: "overseas_event", cohort, jurisdiction: "*" }, "line"),
      kind: "profile", hazard: "overseas_event", cohort, jurisdiction: "*", text,
      sourceAgency: "ALRT reviewed Safety Profile library", sourceUrl: "",
      reviewedAt: "2026-11-16", changeNote: "Imported: shown for events outside Australia.",
    });
  }

  // 3. Learn guides: one record per section.
  for (const g of guides) {
    for (const stage of ["before", "during", "after"] as const) {
      const sections = (g.sections as Record<string, { title: string; body: string }[] | undefined>)[stage] ?? [];
      sections.forEach((s, i) => {
        out.push({
          key: `guide_section:${g.slug}:-:${stage}:AU:${i + 1}`,
          kind: "guide_section", hazard: g.slug, stage, jurisdiction: "AU",
          title: s.title, text: s.body.slice(0, 600),
          sourceAgency: g.sourceName, sourceUrl: g.sourceUrl.replace(/^http:/, "https:"),
          reviewedAt: "2026-11-16", changeNote: `Imported from guide "${g.title}".`,
        });
      });
    }
  }

  // 4. Ask ALRT built-in answers.
  for (const e of BUILT_IN_ENTRIES) {
    out.push({
      key: `answer:-:-:-:*:${e.id}`,
      kind: "answer", jurisdiction: "*", title: e.id, text: e.answer,
      triggers: [...e.triggers, ...e.keywords].slice(0, 40),
      sourceAgency: "ALRT Ask ALRT library", sourceUrl: "",
      reviewedAt: "2026-11-16", changeNote: "Imported from Ask ALRT's built-in answers.",
    });
  }
  return out;
};

/** Country register starting rows, from the list the app and Ask ALRT already share. */
export const buildCountryImport = () =>
  EMERGENCY_NUMBER_DEFAULTS.map((d) => ({
    code: d.iso,
    name: d.name,
    aliases: [] as string[],
    emergencyNumber: d.number,
    sourceUrl: "",
    notes: "Imported from the shared emergency number list. Add the official source.",
  }));

/** The guides drafted on 16 Nov 2026: imported IN REVIEW for the owner to approve. */
export const buildDraftGuideRecords = (): (GuidanceInput & { key: string; changeNote: string })[] => [
  ...DRAFT_PROFILE_LINES.map((l) => ({
    key: buildKey({ kind: "profile", hazard: l.hazard, cohort: l.cohort, jurisdiction: "AU" }, "line"),
    kind: "profile" as const, hazard: l.hazard, cohort: l.cohort, jurisdiction: "AU", text: l.text,
    sourceAgency: l.sourceAgency, sourceUrl: l.sourceUrl,
    changeNote: "Drafted 16 Nov 2026 for a new Safety Profile group (D8). Needs owner approval.",
  })),
  ...GUIDE_ANSWERS.map((a) => ({
    key: `answer:-:-:-:AU:guide-${a.id}`,
    kind: "answer" as const, jurisdiction: "AU", title: a.id, text: a.text, triggers: a.triggers,
    sourceAgency: a.sourceAgency, sourceUrl: a.sourceUrl,
    changeNote: "Ask ALRT answer drafted 17 Nov 2026 from the same sources as the Learn guides. Needs owner approval.",
  })),
  ...COUNTRY_WARNING_ANSWERS.map((a) => ({
    key: `answer:-:-:-:${a.jurisdiction}:warning-levels`,
    kind: "answer" as const, jurisdiction: a.jurisdiction, title: `warning-levels-${a.jurisdiction}`, text: a.text,
    triggers: ["what do the warning levels mean", "weather warning levels", "what does a red warning mean", "warning colours", "watch vs warning"],
    sourceAgency: a.sourceAgency, sourceUrl: a.sourceUrl,
    changeNote: "Country warning levels researched 17 Nov 2026. Needs owner approval.",
  })),
  ...[...DRAFT_GUIDES, ...NATIONAL_GUIDES].flatMap((g) => {
    const counts: Record<string, number> = {};
    return g.sections.map((s) => {
      counts[s.stage] = (counts[s.stage] ?? 0) + 1;
      return {
        key: `guide_section:${g.slug}:-:${s.stage}:${g.jurisdiction}:${NATIONAL_GUIDES.includes(g) ? "L" : ""}${counts[s.stage]}`,
        kind: "guide_section" as const, hazard: g.slug, stage: s.stage, jurisdiction: g.jurisdiction,
        title: s.title, text: s.body, sourceAgency: s.sourceAgency, sourceUrl: s.sourceUrl,
        changeNote: `Drafted ${NATIONAL_GUIDES.includes(g) ? "17" : "16"} Nov 2026 for "${g.title}"${g.replaces ? `, replacing the content of "${g.replaces}"` : ""}. Needs owner approval.`,
      };
    });
  }),
];
