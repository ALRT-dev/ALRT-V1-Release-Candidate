import { MOVEMENT_WORD } from "./agency_extraction.util.js";
import type { GuidanceEntry } from "./alert_templates.util.js";

/**
 * The one approved guidance library (owner decisions D2, D4, D5,
 * 16 November 2026). Alerts, Safety Profile, Learn and Ask ALRT all read
 * approved records from here. Every record names its source, jurisdiction
 * and version, so any line on any screen can be traced and corrected once.
 *
 * Pure rules only: validation, jurisdiction fallback, picking a record and
 * turning advice and profile records into Alert Templates library entries.
 */

export type GuidanceKind = "advice" | "profile" | "guide_section" | "answer" | "country_fact";
export type GuidanceStatus = "draft" | "in_review" | "approved" | "retired";

export interface GuidanceInput {
  key?: string;
  kind: GuidanceKind;
  hazard?: string | null;
  cohort?: string | null;
  stage?: string | null;
  jurisdiction?: string;
  title?: string | null;
  text: string;
  longText?: string | null;
  triggers?: string[];
  sourceAgency: string;
  sourceUrl: string;
  licence?: string | null;
  bands?: string[];
}

export interface GuidanceRow extends GuidanceInput {
  id: string;
  key: string;
  jurisdiction: string;
  version: number;
  status: GuidanceStatus;
  reviewedAt?: Date | string | null;
  nextReviewAt?: Date | string | null;
  authorId?: string | null;
  reviewerId?: string | null;
}

/** Safety Profile groups. powered and assistance added 16 Nov 2026 (decision D8). */
export const COHORTS = ["older", "kids", "mobility", "medical", "deaf", "vision", "visitor", "worker", "pets", "powered", "assistance"] as const;
export const STAGES = ["before", "during", "after"] as const;
const JURISDICTION_RE = /^(\*|[A-Z]{2}(-[A-Z]{2,3})?)$/;
const PHONE_RE = /(?:\+?\d[\d\s-]{5,}\d)/;
/** Emergency numbers may appear; nothing else that looks like a phone number. */
const EMERGENCY_ONLY = new Set(["000", "112", "911", "999", "111", "110", "119", "100", "101", "102"]);
const MAX_TEXT: Record<GuidanceKind, number> = {
  advice: 160,
  profile: 260,
  guide_section: 600,
  answer: 480, // about 70 words (Ask ALRT answer length, 16 Nov 2026)
  country_fact: 400,
};

/** Months until a record must be reviewed again. */
export const REVIEW_MONTHS = 12;

export const nextReviewFrom = (from: Date, months = REVIEW_MONTHS): Date => {
  const d = new Date(from);
  d.setMonth(d.getMonth() + months);
  return d;
};

export const normaliseJurisdiction = (value?: string | null): string => {
  const v = (value ?? "AU").trim().toUpperCase().replace("_", "-");
  return v || "AU";
};

/** "AU-WA" -> ["AU-WA", "AU", "*"]: the most specific record wins. */
export const jurisdictionChain = (value?: string | null): string[] => {
  const j = normaliseJurisdiction(value);
  if (j === "*") return ["*"];
  const country = j.slice(0, 2);
  return j.includes("-") ? [j, country, "*"] : [country, "*"];
};

export const buildKey = (r: Pick<GuidanceInput, "kind" | "hazard" | "cohort" | "stage" | "jurisdiction" | "title">, slug?: string): string =>
  [
    r.kind,
    r.hazard || "-",
    r.cohort || "-",
    r.stage || "-",
    normaliseJurisdiction(r.jurisdiction),
    (slug || r.title || "x").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "").slice(0, 60) || "x",
  ].join(":");

export interface GuidanceCheck {
  errors: string[];
  warnings: string[];
}

/**
 * The rules every record must pass before it can be approved. Errors block
 * approval; warnings show in admin and in the daily assurance report.
 */
export const checkGuidance = (r: GuidanceInput, opts: { forApproval?: boolean } = {}): GuidanceCheck => {
  const errors: string[] = [];
  const warnings: string[] = [];
  const text = (r.text ?? "").trim();
  if (!text) errors.push("Text is required.");
  // Same wording rule Alert Templates enforces, caught here before approval.
  if ((r.kind === "advice" || r.kind === "profile") && /\byou must\b|\byou are required to\b/i.test(text))
    errors.push('Use suggestive wording, such as "consider" or "may help", not "you must".');
  if (text.length > MAX_TEXT[r.kind]) errors.push(`Keep it under ${MAX_TEXT[r.kind]} characters.`);
  if (r.kind === "profile" && (!r.cohort || !(COHORTS as readonly string[]).includes(r.cohort)))
    errors.push("A Safety Profile line needs one group.");
  if ((r.kind === "advice" || r.kind === "profile") && !r.hazard) errors.push("Choose the hazard this applies to.");
  if (r.stage && !(STAGES as readonly string[]).includes(r.stage)) errors.push("Stage must be before, during or after.");
  if (!JURISDICTION_RE.test(normaliseJurisdiction(r.jurisdiction)))
    errors.push("Jurisdiction must be a country code (AU) or country and state (AU-WA).");
  if (r.kind === "answer" && !(r.triggers ?? []).some((t) => t.trim()))
    errors.push("An Ask ALRT answer needs at least one question it answers.");

  // Traceability (D4): source agency and a page link.
  if (!r.sourceAgency?.trim()) errors.push("Name the official source.");
  const url = (r.sourceUrl ?? "").trim();
  if (!url) (opts.forApproval ? errors : warnings).push("Add the source page link.");
  else if (!/^https:\/\/[^\s]+\.[^\s]+/.test(url)) errors.push("The source link must start with https://.");
  else if (/^https:\/\/[^/]+\/?$/.test(url)) warnings.push("Link to the exact page, not the home page.");

  // ALRT's own words never direct movement and never give non-emergency numbers.
  const own = r.kind === "advice" || r.kind === "profile" || r.kind === "answer";
  const all = [text, r.longText ?? ""].join(" ");
  // "Never go to the beach to watch" is a warning, not a direction.
  const directive = all.replace(/\b(?:never|don't|do not|avoid)\s+(?:go|going|head|heading|move|moving)\s+to\b/gi, "");
  if (MOVEMENT_WORD.test(directive))
    (own ? errors : warnings).push(
      own
        ? "ALRT never tells people to leave, evacuate, shelter, stay or return. Only the agency gives those directions."
        : "Mentions leaving, sheltering or returning: check it is clearly the agency's advice.",
    );
  for (const m of all.match(new RegExp(PHONE_RE, "g")) ?? []) {
    const digits = m.replace(/\D/g, "");
    if (!EMERGENCY_ONLY.has(digits)) {
      (r.kind === "country_fact" ? warnings : errors).push("Only emergency numbers may appear.");
      break;
    }
  }
  if (r.kind === "profile" && !/may help\.?$/i.test(text)) warnings.push('Safety Profile lines end on what "may help".');
  if (/\bsafest\b/i.test(all)) errors.push('Do not use "safest".');
  return { errors, warnings };
};

const asTime = (d?: Date | string | null): number => (d ? new Date(d).getTime() : 0);

/**
 * The approved record that applies: same kind, hazard, cohort and stage,
 * the most specific jurisdiction first, newest version within it.
 */
export const pickApproved = <T extends GuidanceRow>(
  rows: readonly T[],
  q: { kind: GuidanceKind; hazard?: string | null; cohort?: string | null; stage?: string | null; jurisdiction?: string | null },
): T[] => {
  const chain = jurisdictionChain(q.jurisdiction);
  const matching = rows.filter(
    (r) =>
      r.status === "approved" &&
      r.kind === q.kind &&
      (q.hazard === undefined || (r.hazard ?? null) === (q.hazard ?? null)) &&
      (q.cohort === undefined || (r.cohort ?? null) === (q.cohort ?? null)) &&
      (q.stage === undefined || !r.stage || r.stage === q.stage),
  );
  for (const j of chain) {
    const hit = matching.filter((r) => normaliseJurisdiction(r.jurisdiction) === j);
    if (hit.length) {
      // One row per key: the highest version.
      const byKey = new Map<string, T>();
      for (const r of hit) if (!byKey.has(r.key) || byKey.get(r.key)!.version < r.version) byKey.set(r.key, r);
      return [...byKey.values()];
    }
  }
  return [];
};

/** Records past their review date (assurance check 3). */
export const overdue = <T extends GuidanceRow>(rows: readonly T[], now = new Date()): T[] =>
  rows.filter((r) => r.status === "approved" && r.nextReviewAt && asTime(r.nextReviewAt) < now.getTime());

/** Reference text carried into the Alert Templates library: source, place, version. */
export const referenceFor = (r: GuidanceRow): string =>
  `${r.sourceAgency}${r.sourceUrl ? ` (${r.sourceUrl})` : ""}; ${normaliseJurisdiction(r.jurisdiction)}; library ${r.key} v${r.version}`;

/**
 * Turns approved advice and profile records into Alert Templates library
 * entries, so they go live through the existing draft and publish flow.
 * [categoryIdsFor] maps a library hazard key to template category ids.
 */
export const toTemplateEntries = (
  rows: readonly GuidanceRow[],
  categoryIdsFor: (hazard: string) => string[],
): { entries: GuidanceEntry[]; skipped: { key: string; reason: string }[] } => {
  const entries: GuidanceEntry[] = [];
  const skipped: { key: string; reason: string }[] = [];
  const latest = new Map<string, GuidanceRow>();
  for (const r of rows) {
    if (r.status !== "approved" || (r.kind !== "advice" && r.kind !== "profile")) continue;
    if (!latest.has(r.key) || latest.get(r.key)!.version < r.version) latest.set(r.key, r);
  }
  for (const r of latest.values()) {
    const categoryIds = categoryIdsFor(r.hazard ?? "");
    if (!categoryIds.length) {
      skipped.push({ key: r.key, reason: `No alert categories mapped for hazard "${r.hazard}".` });
      continue;
    }
    const j = normaliseJurisdiction(r.jurisdiction);
    const reviewed = r.reviewedAt ? new Date(r.reviewedAt).toISOString().slice(0, 10) : null;
    if (!reviewed) {
      skipped.push({ key: r.key, reason: "Approved without a review date." });
      continue;
    }
    entries.push({
      id: `lib-${r.key}`.replace(/[^a-zA-Z0-9_-]+/g, "-").slice(0, 100),
      text: r.text,
      categoryIds: categoryIds.slice(0, 30),
      countries: j === "*" ? [] : [j],
      bands: (r.bands ?? []) as GuidanceEntry["bands"],
      profileTags: r.kind === "profile" && r.cohort ? [r.cohort as GuidanceEntry["profileTags"][number]] : [],
      approved: true,
      reference: referenceFor(r).slice(0, 1000),
      reviewedAt: reviewed,
    });
  }
  return { entries, skipped };
};

/** Coverage grid: hazard x group (or jurisdiction) -> approved, draft, overdue, empty. */
export type CoverageCell = "approved" | "draft" | "overdue" | "no_source" | "empty";

export const coverageGrid = (
  rows: readonly GuidanceRow[],
  hazards: readonly string[],
  columns: readonly string[],
  axis: "cohort" | "jurisdiction",
  kind: GuidanceKind,
  now = new Date(),
): Record<string, Record<string, CoverageCell>> => {
  const grid: Record<string, Record<string, CoverageCell>> = {};
  for (const h of hazards) {
    grid[h] = {};
    for (const c of columns) {
      const cell = rows.filter(
        (r) => r.kind === kind && r.hazard === h && (axis === "cohort" ? r.cohort === c : normaliseJurisdiction(r.jurisdiction) === c),
      );
      const approved = cell.filter((r) => r.status === "approved");
      grid[h]![c] = approved.length
        ? overdue(approved, now).length === approved.length
          ? "overdue"
          : approved.some((r) => !r.sourceUrl)
            ? "no_source"
            : "approved"
        : cell.some((r) => r.status === "draft" || r.status === "in_review")
          ? "draft"
          : "empty";
    }
  }
  return grid;
};
