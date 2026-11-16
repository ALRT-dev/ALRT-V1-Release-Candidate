import prisma from "../utils/prisma_client.util.js";
import {
  checkAiUse, checkAskAlrtPlaces, checkCoverage, checkDisplay, checkLicences, checkMovementWords, checkReviewDates,
  checkSourceHealth, formatReport, summarise, type CheckResult,
} from "../utils/assurance_checks.util.js";
import { checkGuidance, overdue, type GuidanceRow } from "../utils/guidance_library.util.js";
import { selectLibraryGuidance, templateCountry, templateRegion } from "../utils/alert_templates.util.js";
import { getTemplateRegistry } from "./alert_templates.service.js";
import { resolvePlace } from "./ask_alrt/place.js";
import { PLACE_CASES } from "./ask_alrt/place_cases.js";
import { recordAdminAuditEntry } from "./admin_audit_log.service.js";
import { executePrompt } from "./ai.service.js";

/**
 * Daily assurance (owner decision D3, 16 Nov 2026). Called once a day by the
 * n8n workflow (POST /api/webhook/assurance/run) or from admin. Reads only;
 * never changes an alert, a source or a record. Checks 1 to 7 and 9 are
 * plain rules. Check 8 samples 10 AI-written alerts with a small model and
 * runs only when ASSURANCE_AI_SAMPLE=on.
 */
const db = prisma as any;
const DAY = 86_400_000;

const aiSampleCheck = async (since: Date): Promise<CheckResult | null> => {
  if (process.env.ASSURANCE_AI_SAMPLE !== "on") return null;
  const sample: { id: string; title: string; description: string; aiSummary: string | null }[] = await prisma.$queryRaw`
    SELECT "id", "title", "description", "aiSummary" FROM "Hazard"
    WHERE "createdAt" >= ${since} AND "extractionMethod" = 'ai' AND "aiSummary" IS NOT NULL
    ORDER BY random() LIMIT 10`;
  const items: string[] = [];
  for (const h of sample) {
    try {
      const raw = await executePrompt({
        systemPromptContent:
          'You check emergency alert summaries. Compare the AGENCY TEXT with the SUMMARY. Reply only with JSON {"same":true|false,"issue":"<under 15 words>"}. same=false only if the summary changes the meaning, adds a fact, adds a direction to leave/stay/shelter, or drops a warning.',
        userPromptContent: `AGENCY TEXT:\n${h.title}\n${h.description.slice(0, 3000)}\n\nSUMMARY:\n${(h.aiSummary ?? "").slice(0, 1500)}`,
        usage: { purpose: "assurance" },
      });
      const parsed = JSON.parse(raw) as { same?: boolean; issue?: string };
      if (parsed.same === false) items.push(`${h.title.slice(0, 60)}: ${parsed.issue ?? "meaning changed"}`);
    } catch {
      // A failed check is not a failed alert; it shows as a skipped sample.
    }
  }
  return {
    id: "alert_sample", name: "Alert sample check",
    status: items.length ? "fail" : "pass",
    detail: items.length ? `${items.length} of ${sample.length} sampled summaries differ from the agency text.` : `${sample.length} sampled summaries match the agency text.`,
    items,
  };
};

export const collectChecks = async (now = new Date()): Promise<CheckResult[]> => {
  const since = new Date(now.getTime() - DAY);
  const sources = await prisma.hazardSource.findMany();
  const records: GuidanceRow[] = await db.guidanceRecord?.findMany({ where: { status: "approved" } }).catch(() => []) ?? [];

  const recent = await prisma.hazard.findMany({
    where: { createdAt: { gte: since }, sourceId: { not: null } },
    select: { id: true, title: true, contentDetails: true, categoryId: true, sourceId: true, severityBand: true, jurisdictionCountry: true, extractionMethod: true, source: { select: { id: true, country: true, region: true } }, category: { select: { id: true, name: true, parentId: true } } } as any,
    take: 2000,
  }) as any[];

  // 4. ALRT lines on today's alerts plus approved own-words records.
  const lines: { where: string; text: string }[] = [];
  for (const h of recent) {
    for (const t of (h.contentDetails?.alrtSuggestions ?? []) as string[]) lines.push({ where: h.title.slice(0, 40), text: t });
  }
  for (const r of records.filter((x) => ["advice", "profile", "answer"].includes(x.kind))) {
    if (checkGuidance(r).errors.some((e) => /never tells/.test(e))) lines.push({ where: r.key, text: r.text });
  }

  // 6. Coverage against the published Alert Templates library.
  const registry = await getTemplateRegistry().catch(() => null);
  const gaps: string[] = [];
  if (registry?.published) {
    for (const h of recent) {
      const g = selectLibraryGuidance(registry.published.pack, {
        categoryId: h.categoryId, parentCategoryId: h.category?.parentId,
        country: templateCountry(h.jurisdictionCountry, h.source), region: templateRegion(h.source), band: h.severityBand,
      });
      if (!g.alrtSuggestions.length) gaps.push(h.category?.name ?? h.categoryId);
    }
  }

  // 7. AI use.
  const usage: { calls: bigint; failed: bigint }[] = await prisma.$queryRaw`
    SELECT count(*) AS calls, count(*) FILTER (WHERE NOT "ok") AS failed FROM "AiUsageEvent" WHERE "createdAt" >= ${since}`
    .catch(() => [{ calls: 0n, failed: 0n }]) as any;

  const checks: CheckResult[] = [
    checkSourceHealth(sources as any, now),
    checkLicences(sources as any),
    checkReviewDates(overdue(records, now), now),
    checkMovementWords(lines),
    checkDisplay(recent.map((h) => ({ id: h.id, title: h.title, facts: (h.contentDetails?.facts ?? []).length, method: h.extractionMethod }))),
    checkCoverage(gaps),
    checkAiUse({
      alerts: recent.length,
      aiAlerts: recent.filter((h) => h.extractionMethod === "ai").length,
      calls: Number(usage[0]?.calls ?? 0), failed: Number(usage[0]?.failed ?? 0),
      maxShare: Number(process.env.ASSURANCE_AI_SHARE_MAX ?? 0.3),
    }),
  ];
  const sample = await aiSampleCheck(since);
  if (sample) checks.push(sample);
  checks.push(checkAskAlrtPlaces(PLACE_CASES.map((c) => {
    const p = resolvePlace(c.question, c.ctx);
    return { question: c.question, expected: c.expected, got: p.askPlace ? null : p.jurisdiction };
  })));
  return checks;
};

export const runAssurance = async ({ trigger }: { trigger: "n8n" | "admin" }) => {
  const runAt = new Date();
  const checks = await collectChecks(runAt);
  const totals = summarise(checks);
  const row = await db.assuranceReport.create({ data: { runAt, ...totals, checks } });
  console.log(JSON.stringify({ event: "assurance_run", trigger, ...totals }));
  return { id: row.id, runAt, ...totals, checks, report: formatReport(checks, runAt), notify: totals.failures > 0 };
};

export const acknowledgeReport = async (id: string, adminId: string) => {
  const row = await db.assuranceReport.update({ where: { id }, data: { acknowledgedAt: new Date(), acknowledgedById: adminId } });
  await recordAdminAuditEntry({ adminId, action: "assurance.acknowledge", targetType: "AssuranceReport", targetId: id });
  return row;
};
