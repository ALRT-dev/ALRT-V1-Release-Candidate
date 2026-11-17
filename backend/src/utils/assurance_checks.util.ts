import { MOVEMENT_WORD } from "./agency_extraction.util.js";

/**
 * Daily assurance checks (owner decision D3, 16 Nov 2026). Plain rules, no
 * AI: each takes data the service has already read and says pass, warn or
 * fail with the items behind it. Nothing here changes anything.
 */
export type CheckStatus = "pass" | "warn" | "fail";
export interface CheckResult {
  id: string;
  name: string;
  status: CheckStatus;
  detail: string;
  items: string[];
}

const result = (id: string, name: string, items: string[], level: CheckStatus, ok: string, bad: (n: number) => string): CheckResult => ({
  id, name, status: items.length ? level : "pass", detail: items.length ? bad(items.length) : ok, items: items.slice(0, 25),
});

export interface SourceHealthInput {
  id: string;
  name: string;
  lifecycleStatus: string;
  scheduleMinutes?: number | null;
  lastSuccessfulFetch?: Date | null;
  lastAlertSeen?: Date | null;
  healthStatus?: string | null;
  licenceConfirmedAt?: Date | null;
}

/** 1. Every active polled source fetched within two cycles (at least an hour). */
export const checkSourceHealth = (sources: readonly SourceHealthInput[], now: Date): CheckResult => {
  const items: string[] = [];
  for (const s of sources) {
    if (s.lifecycleStatus !== "active") continue;
    if (s.healthStatus === "failing" || s.healthStatus === "down") {
      items.push(`${s.name}: health ${s.healthStatus}`);
      continue;
    }
    if (!s.scheduleMinutes) continue; // webhook sources have no poll schedule
    const allowed = Math.max(2 * s.scheduleMinutes, 60) * 60_000;
    if (!s.lastSuccessfulFetch) items.push(`${s.name}: no successful fetch recorded`);
    else if (now.getTime() - s.lastSuccessfulFetch.getTime() > allowed)
      items.push(`${s.name}: no good fetch since ${s.lastSuccessfulFetch.toISOString().slice(0, 16).replace("T", " ")} UTC`);
  }
  return result("source_health", "Source health", items, "fail", "Every active source fetched on time.", (n) => `${n} source${n > 1 ? "s" : ""} behind or failing.`);
};

/** 2. Every active source has a confirmed licence. */
export const checkLicences = (sources: readonly SourceHealthInput[]): CheckResult =>
  result(
    "licences", "Licence and attribution",
    sources.filter((s) => s.lifecycleStatus === "active" && !s.licenceConfirmedAt).map((s) => s.name),
    "fail", "Every active source has a confirmed licence.", (n) => `${n} active source${n > 1 ? "s" : ""} without a confirmed licence.`,
  );

/** 3. Approved guidance past its review date (fail once a month overdue). */
export const checkReviewDates = (overdue: readonly { key: string; nextReviewAt?: Date | string | null }[], now: Date): CheckResult => {
  const items = overdue.map((r) => `${r.key} (due ${r.nextReviewAt ? new Date(r.nextReviewAt).toISOString().slice(0, 10) : "?"})`);
  const late = overdue.some((r) => r.nextReviewAt && now.getTime() - new Date(r.nextReviewAt).getTime() > 30 * 86_400_000);
  return result("review_dates", "Review dates", items, late ? "fail" : "warn", "All approved guidance is within its review date.", (n) => `${n} record${n > 1 ? "s" : ""} past review.`);
};

/** 4. ALRT's own words on live alerts never direct movement. */
export const checkMovementWords = (lines: readonly { where: string; text: string }[]): CheckResult => {
  const items = lines
    .filter((l) => MOVEMENT_WORD.test(l.text.replace(/\b(?:never|don't|do not|avoid)\s+(?:go|going|head|move)\s+to\b/gi, "")))
    .map((l) => `${l.where}: "${l.text.slice(0, 80)}"`);
  return result("movement_words", "Movement and number words", items, "fail", "No ALRT line tells people to leave, shelter, stay or return.", (n) => `${n} line${n > 1 ? "s" : ""} give a movement direction.`);
};

/** 5. Display rules on alerts from the last day. */
export const checkDisplay = (alerts: readonly { id: string; title: string; facts: number; method?: string | null }[]): CheckResult => {
  const items = alerts
    .filter((a) => a.facts === 0 || a.method === "fallback")
    .map((a) => `${a.title.slice(0, 60)} (${a.facts === 0 ? "no agency lines" : "AI failed, raw text shown"})`);
  return result("display", "Display rules", items, "warn", "Every alert shows agency lines.", (n) => `${n} alert${n > 1 ? "s" : ""} shown without agency lines or after an AI failure.`);
};

/** 6. Hazards seen in the last day with no approved advice for them. */
export const checkCoverage = (gaps: readonly string[]): CheckResult =>
  result("coverage", "Coverage", [...new Set(gaps)], "warn", "Every hazard seen today had approved advice.", (n) => `${n} hazard type${n > 1 ? "s" : ""} seen with no approved advice.`);

/** 7. AI share and failures. */
export const checkAiUse = (input: { alerts: number; aiAlerts: number; calls: number; failed: number; maxShare: number }): CheckResult => {
  const items: string[] = [];
  const share = input.alerts ? input.aiAlerts / input.alerts : 0;
  if (share > input.maxShare) items.push(`${Math.round(share * 100)}% of alerts needed AI (limit ${Math.round(input.maxShare * 100)}%)`);
  const failRate = input.calls ? input.failed / input.calls : 0;
  if (failRate > 0.1) items.push(`${input.failed} of ${input.calls} AI calls failed`);
  return {
    id: "ai_use", name: "AI use and cost",
    status: failRate > 0.1 ? "fail" : items.length ? "warn" : "pass",
    detail: items.length ? items.join("; ") : `${input.calls} AI calls; ${input.aiAlerts} of ${input.alerts} alerts used AI.`,
    items,
  };
};

/** 9. Ask ALRT place resolution against the fixed test questions. */
export const checkAskAlrtPlaces = (cases: readonly { question: string; expected: string | null; got: string | null }[]): CheckResult =>
  result(
    "ask_alrt_places", "Ask ALRT places",
    cases.filter((c) => c.expected !== c.got).map((c) => `"${c.question}": expected ${c.expected ?? "ask"}, got ${c.got ?? "ask"}`),
    "fail", `All ${cases.length} test questions resolved to the right place.`, (n) => `${n} test question${n > 1 ? "s" : ""} resolved to the wrong place.`,
  );

export const summarise = (checks: readonly CheckResult[]) => ({
  passed: checks.filter((c) => c.status === "pass").length,
  warnings: checks.filter((c) => c.status === "warn").length,
  failures: checks.filter((c) => c.status === "fail").length,
});

/** The plain-text report emailed or posted by n8n. */
export const formatReport = (checks: readonly CheckResult[], runAt: Date): string => {
  const s = summarise(checks);
  const perth = new Date(runAt.getTime() + 8 * 3_600_000).toISOString().slice(0, 16).replace("T", " ");
  const lines = [
    `ALRT daily assurance, ${perth} AWST`,
    `Result: ${s.failures} failure${s.failures === 1 ? "" : "s"}, ${s.warnings} warning${s.warnings === 1 ? "" : "s"}, ${s.passed} passed`,
    "",
  ];
  for (const c of checks.filter((x) => x.status !== "pass")) {
    lines.push(`${c.status.toUpperCase()}  ${c.name}: ${c.detail}`);
    for (const i of c.items.slice(0, 5)) lines.push(`      ${i}`);
  }
  const passed = checks.filter((x) => x.status === "pass").map((x) => x.name);
  if (passed.length) lines.push(`PASS  ${passed.join(", ")}`);
  lines.push("", "Acknowledge in admin: Daily assurance");
  return lines.join("\n");
};
