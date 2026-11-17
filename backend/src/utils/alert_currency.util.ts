/**
 * Alert currency (owner, 17 November 2026): ALRT never shows an official
 * alert that is old and outdated, with the wrong time, or with the wrong
 * icon. A DBCA park closure issued on 30 March 2026 was still showing in
 * November as a Cyclone alert "posted about a month ago", because:
 *   - its clock started when ALRT read the feed, not when the agency issued
 *     it, and the feed republishes old items with a fresh date;
 *   - every republish counted as new, so its expiry kept moving forward;
 *   - its category came from a hazard named in its body text.
 *
 * The rules here apply to every official source:
 *   1. The clock is the agency's own time: the issue time it states in its
 *      text, or the time ALRT saw the agency's words actually change. A
 *      republish with the same words never restarts it.
 *   2. An alert the agency has not changed for three days is removed (the
 *      owner's ruling T10, 16 October 2026: "may be removed after 3 days
 *      with no update"). An earlier expiry from the source or the severity
 *      window still applies.
 *   3. The time shown is the agency's stated issue time when it gives one.
 *   4. A closure or other non-warning never takes a hazard category from
 *      words in its body (see guardNonWarningCategory).
 */

export const OFFICIAL_SILENCE_MS = 3 * 24 * 60 * 60 * 1000;

const MONTHS: Record<string, number> = {
  jan: 0, feb: 1, mar: 2, apr: 3, may: 4, jun: 5,
  jul: 6, aug: 7, sep: 8, oct: 9, nov: 10, dec: 11,
};

/** Local offset for times an agency writes without a zone. WA agencies
 * publish in AWST; elsewhere the eastern-states offset is used. An error of a
 * few hours does not matter against a three-day window. */
const offsetHoursFor = (sourceId?: string | null): number =>
  sourceId && /^wa/i.test(sourceId) ? 8 : 10;

function toDate(dayText: string, monthText: string, yearText: string, timeText: string | undefined, offset: number): Date | null {
  const month = MONTHS[monthText.slice(0, 3).toLowerCase()];
  const day = Number(dayText), year = Number(yearText);
  if (month === undefined || !day || !year) return null;
  let hours = 0, minutes = 0;
  const time = timeText ? /^(\d{1,2})[:.](\d{2})\s*(am|pm)?$/i.exec(timeText.trim()) : null;
  if (time) {
    hours = Number(time[1]); minutes = Number(time[2]);
    const half = time[3]?.toLowerCase();
    if (half === "pm" && hours < 12) hours += 12;
    if (half === "am" && hours === 12) hours = 0;
  }
  const value = new Date(Date.UTC(year, month, day, hours - offset, minutes));
  return Number.isNaN(value.getTime()) ? null : value;
}

/**
 * The latest issue or update time an agency states in its own text, for
 * example "Date of issue: 30 Mar 2026 / Time of issue: 01:39 PM", "Issued
 * 3:10pm Monday 16 November 2026" or "At 5:15am on Tuesday 17 November 2026,
 * the Bureau ...". Null when the text states none. A time in the future
 * (beyond an hour of clock skew) is ignored.
 */
export function statedIssueTime(text: string, now: Date, sourceId?: string | null): Date | null {
  const offset = offsetHoursFor(sourceId);
  const found: Date[] = [];
  const DATE = String.raw`(\d{1,2})(?:st|nd|rd|th)?\s+([A-Za-z]{3,9})\s+(\d{4})`;
  const TIME = String.raw`(\d{1,2}[:.]\d{2}\s*(?:[ap]m)?)`;

  const issueDate = new RegExp(String.raw`date of issue\s*:?\s*` + DATE, "i").exec(text);
  if (issueDate) {
    const issueTime = new RegExp(String.raw`time of issue\s*:?\s*` + TIME, "i").exec(text);
    const value = toDate(issueDate[1]!, issueDate[2]!, issueDate[3]!, issueTime?.[1], offset);
    if (value) found.push(value);
  }
  const issued = new RegExp(String.raw`\b(?:issued|updated|last updated)\b(?:\s+at)?\s*:?\s*(?:` + TIME + String.raw`\s*(?:on\s+)?)?(?:[A-Za-z]+day,?\s+)?` + DATE, "gi");
  for (const m of text.matchAll(issued)) {
    const value = toDate(m[2]!, m[3]!, m[4]!, m[1], offset);
    if (value) found.push(value);
  }
  const at = new RegExp(String.raw`\bat\s+` + TIME + String.raw`\s+on\s+(?:[A-Za-z]+day,?\s+)?` + DATE, "gi");
  for (const m of text.matchAll(at)) {
    const value = toDate(m[2]!, m[3]!, m[4]!, m[1], offset);
    if (value) found.push(value);
  }
  const usable = found.filter(d => d.getTime() <= now.getTime() + 60 * 60 * 1000);
  if (!usable.length) return null;
  return new Date(Math.max(...usable.map(d => d.getTime())));
}

const normal = (s: string | null | undefined) => (s ?? "").replace(/\s+/g, " ").trim().toLowerCase();

export interface CurrencyInput {
  title: string;
  description: string;
  nativeLevel: string | null;
  sourceId?: string | null;
  occurredAt?: Date | null;
  /** The stored record for this alert, when there is one. */
  existing?: {
    title: string | null;
    description: string | null;
    nativeWarningLevel: string | null;
    createdAt: Date;
    contentDetails: unknown;
  } | null;
  now: Date;
}

export interface Currency {
  /** When the agency's words last changed (or when it says it issued them). */
  changedAt: Date;
  /** The time to show as "posted" or "issued". */
  shownAt: Date;
  /** After this, the alert is not shown unless the agency changes it. */
  staleAt: Date;
  /** The agency's own stated time, when it gives one. */
  statedAt: Date | null;
}

/** The agency clock for one official alert. Pure: no database, no network. */
export function alertCurrency(input: CurrencyInput): Currency {
  const { now, existing } = input;
  const statedAt = statedIssueTime(`${input.title}\n${input.description}`, now, input.sourceId);
  const priorDetails = existing?.contentDetails && typeof existing.contentDetails === "object"
    ? existing.contentDetails as Record<string, unknown> : null;
  const priorChanged = typeof priorDetails?.sourceChangedAt === "string" ? new Date(priorDetails.sourceChangedAt) : null;
  const wordsChanged = existing
    ? normal(existing.title) !== normal(input.title) ||
      normal(existing.description) !== normal(input.description) ||
      normal(existing.nativeWarningLevel) !== normal(input.nativeLevel)
    : false;

  let changedAt: Date;
  if (existing && wordsChanged) {
    changedAt = now;
  } else if (existing && priorChanged && !Number.isNaN(priorChanged.getTime())) {
    changedAt = priorChanged;
  } else if (existing) {
    // Stored before this rule: ALRT has had these exact words since it first
    // saw them, so the clock is the agency's stated time or first sighting.
    changedAt = statedAt ?? existing.createdAt;
  } else {
    // New to ALRT: the agency's stated time, else the feed's own date when it
    // is in the past, else now.
    const feed = input.occurredAt && input.occurredAt.getTime() <= now.getTime() ? input.occurredAt : null;
    changedAt = statedAt ?? feed ?? now;
  }
  // A stated time later than our record (an agency update we missed) wins.
  if (statedAt && statedAt.getTime() > changedAt.getTime()) changedAt = statedAt;

  const shownAt = statedAt ?? (input.occurredAt && input.occurredAt.getTime() <= now.getTime() ? input.occurredAt : changedAt);
  return { changedAt, shownAt, staleAt: new Date(changedAt.getTime() + OFFICIAL_SILENCE_MS), statedAt };
}

/** The earlier of the alert's own expiry and its staleness time. */
export function boundedExpiry(expiresAt: Date | null | undefined, currency: Currency): Date {
  if (!expiresAt || Number.isNaN(expiresAt.getTime())) return currency.staleAt;
  return expiresAt.getTime() < currency.staleAt.getTime() ? expiresAt : currency.staleAt;
}

/** Words that mark an alert as a closure or notice rather than a hazard
 * warning. */
const NON_WARNING = /\b(?:closure|closed|reopen(?:ed|ing)?|re-open(?:ed|ing)?)\b/i;

/**
 * A closure or notice (not an Australian Warning System warning) keeps a
 * hazard category only when its own headline names that hazard. A cyclone
 * mentioned in a park closure's body does not make it a Cyclone alert.
 * Returns the category to use: the given one, or the fallback (Other).
 */
export function guardNonWarningCategory<C extends { id: string }>(input: {
  title: string;
  category: C;
  isAwsCompliant: boolean;
  /** Categories the guard applies to; every category when omitted. */
  hazardCategoryIds?: readonly string[];
  headlineNamesCategory: (category: C, title: string) => boolean;
  fallback: C | null;
}): C {
  const { title, category, fallback } = input;
  if (input.isAwsCompliant || !fallback) return category;
  if (!NON_WARNING.test(title)) return category;
  if (category.id === fallback.id) return category;
  if (input.hazardCategoryIds && !input.hazardCategoryIds.includes(category.id)) return category;
  return input.headlineNamesCategory(category, title) ? category : fallback;
}
