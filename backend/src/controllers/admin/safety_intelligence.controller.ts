import type { NextFunction, Request, Response } from "express";
import z from "zod";
import prisma from "../../utils/prisma_client.util.js";
import { costFor } from "../../utils/ai_usage.util.js";
import * as library from "../../services/guidance_library.service.js";
import { runAssurance, acknowledgeReport } from "../../services/assurance.service.js";
import { recordAdminAuditEntry } from "../../services/admin_audit_log.service.js";
import { HttpError } from "../../models/http_error.js";

type AdminReq = Request & { admin?: { id: string; role: string } };
const adminId = (req: AdminReq): string => {
  if (!req.admin) throw new HttpError(401, "Admin authentication required");
  return req.admin.id;
};
const wrap = (fn: (req: AdminReq, res: Response) => Promise<unknown>) =>
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const out = await fn(req as AdminReq, res);
      if (!res.headersSent) res.status(200).json(out);
    } catch (e) {
      next(e instanceof z.ZodError ? new HttpError(400, e.issues.map((i) => i.message).join(" ")) : e);
    }
  };

const kinds = ["advice", "profile", "guide_section", "answer", "country_fact"] as const;
const guidanceBody = z.object({
  key: z.string().max(200).optional(),
  kind: z.enum(kinds),
  hazard: z.string().max(60).nullish(),
  cohort: z.string().max(30).nullish(),
  stage: z.enum(["before", "during", "after"]).nullish(),
  jurisdiction: z.string().max(10).optional(),
  title: z.string().max(200).nullish(),
  text: z.string().min(1).max(2000),
  longText: z.string().max(8000).nullish(),
  triggers: z.array(z.string().max(200)).max(60).optional(),
  sourceAgency: z.string().min(1).max(200),
  sourceUrl: z.string().max(1000).default(""),
  licence: z.string().max(300).nullish(),
  changeNote: z.string().max(500).optional(),
}).strict();
const reasonBody = z.object({ reason: z.string().max(500).optional() });

// --- Guidance library ------------------------------------------------------
export const listGuidance = wrap((req) =>
  library.listGuidance(z.object({
    kind: z.enum(kinds).optional(), hazard: z.string().optional(), cohort: z.string().optional(),
    jurisdiction: z.string().optional(), status: z.enum(["draft", "in_review", "approved", "retired"]).optional(),
    q: z.string().max(100).optional(), page: z.coerce.number().int().min(1).optional(), pageSize: z.coerce.number().int().min(1).max(200).optional(),
  }).parse(req.query)),
);
export const guidanceHistory = wrap((req) => library.guidanceHistory(String(req.params.key)));
export const createGuidance = wrap(async (req) => { const r = await library.createDraft(guidanceBody.parse(req.body) as any, adminId(req)); library.clearGuidanceCache(); return r; });
export const updateGuidance = wrap(async (req) => { const r = await library.updateDraft(String(req.params.id), guidanceBody.parse(req.body) as any, adminId(req)); library.clearGuidanceCache(); return r; });
export const submitGuidance = wrap((req) => library.submitForReview(String(req.params.id), adminId(req)));
export const approveGuidance = wrap(async (req) => { const r = await library.approve(String(req.params.id), adminId(req), reasonBody.parse(req.body ?? {}).reason); library.clearGuidanceCache(); return r; });
export const retireGuidance = wrap(async (req) => { const r = await library.retire(String(req.params.id), adminId(req), reasonBody.parse(req.body ?? {}).reason); library.clearGuidanceCache(); return r; });
export const importGuidance = wrap(async (req) => { const r = await library.importExisting(adminId(req)); library.clearGuidanceCache(); return r; });
export const sendGuidanceToTemplates = wrap((req) => library.sendToAlertTemplates(adminId(req)));
export const guidanceCoverage = wrap((req) => {
  const q = z.object({ kind: z.enum(kinds).default("profile"), axis: z.enum(["cohort", "jurisdiction"]).default("cohort") }).parse(req.query);
  return library.coverage(q.kind, q.axis);
});

// --- Country register ------------------------------------------------------
export const listCountries = wrap(() => library.listCountries());
export const saveCountry = wrap((req) => library.saveCountry(String(req.params.code), req.body ?? {}, adminId(req)));

// --- AI usage --------------------------------------------------------------
export const aiUsage = wrap(async (req) => {
  const { days, inputPrice, outputPrice } = z.object({
    days: z.coerce.number().int().min(1).max(90).default(14),
    // US$ per million tokens, entered in admin from the AWS price list.
    inputPrice: z.coerce.number().min(0).max(1000).optional(),
    outputPrice: z.coerce.number().min(0).max(1000).optional(),
  }).parse(req.query);
  const since = new Date(Date.now() - days * 86_400_000);
  const rows: { day: Date; purpose: string; sourceId: string | null; calls: bigint; failed: bigint; input: bigint; output: bigint }[] =
    await prisma.$queryRaw`
      SELECT date_trunc('day', "createdAt") AS day, "purpose", "sourceId",
             count(*) AS calls, count(*) FILTER (WHERE NOT "ok") AS failed,
             coalesce(sum("inputTokens"),0) AS input, coalesce(sum("outputTokens"),0) AS output
      FROM "AiUsageEvent" WHERE "createdAt" >= ${since}
      GROUP BY 1, 2, 3 ORDER BY 1 DESC`;
  const alerts: { day: Date; sourceId: string | null; method: string | null; n: bigint }[] = await prisma.$queryRaw`
      SELECT date_trunc('day', "createdAt") AS day, "sourceId", "extractionMethod" AS method, count(*) AS n
      FROM "Hazard" WHERE "createdAt" >= ${since} AND "sourceId" IS NOT NULL
      GROUP BY 1, 2, 3`;
  const price = inputPrice !== undefined && outputPrice !== undefined ? { input: inputPrice, output: outputPrice } : null;
  const num = (b: bigint) => Number(b);
  return {
    days,
    priced: Boolean(price),
    usage: rows.map((r) => ({
      day: r.day.toISOString().slice(0, 10), purpose: r.purpose, sourceId: r.sourceId,
      calls: num(r.calls), failed: num(r.failed), inputTokens: num(r.input), outputTokens: num(r.output),
      ...(price && { costUsd: Number(costFor({ inputTokens: num(r.input), outputTokens: num(r.output) }, price).toFixed(4)) }),
    })),
    alertsByMethod: alerts.map((a) => ({ day: a.day.toISOString().slice(0, 10), sourceId: a.sourceId, method: a.method ?? "not recorded", alerts: num(a.n) })),
  };
});

// --- Prompt versions -------------------------------------------------------
export const promptVersions = wrap(async (req) =>
  (prisma as any).aIPromptVersion.findMany({ where: { promptId: String(req.params.id) }, orderBy: { version: "desc" } }));

// --- Source licence gate ---------------------------------------------------
export const confirmSourceLicence = wrap(async (req) => {
  const { notes } = z.object({ notes: z.string().min(10, "Say where the licence is recorded (at least 10 characters).").max(2000) }).parse(req.body ?? {});
  const id = String(req.params.id);
  const before = await prisma.hazardSource.findUnique({ where: { id } });
  if (!before) throw new HttpError(404, "Source not found.");
  const row = await prisma.hazardSource.update({
    where: { id },
    data: { licensingNotes: notes, licenceConfirmedAt: new Date(), licenceConfirmedById: adminId(req) } as any,
  });
  await recordAdminAuditEntry({ adminId: adminId(req), action: "source.licence_confirmed", targetType: "HazardSource", targetId: id, before: { licensingNotes: before.licensingNotes }, after: { licensingNotes: notes } });
  return row;
});

// --- Daily assurance -------------------------------------------------------
export const runAssuranceNow = wrap(() => runAssurance({ trigger: "admin" }));
export const listAssurance = wrap(async () =>
  (prisma as any).assuranceReport.findMany({ orderBy: { runAt: "desc" }, take: 30 }));
export const acknowledgeAssurance = wrap((req) => acknowledgeReport(String(req.params.id), adminId(req)));

// --- Learn guides from the library ------------------------------------------
export const listLibraryGuides = wrap(() => library.listLibraryGuides());
export const publishGuide = wrap((req) => {
  const { jurisdiction } = z.object({ jurisdiction: z.string().max(10).default("AU-WA") }).parse(req.body ?? {});
  return library.publishGuide(String(req.params.slug), jurisdiction, adminId(req));
});

// --- New sources: adapter mapping and preview ----------------------------------
const previewBody = z.object({
  adapterKey: z.enum(["cap_au", "geojson", "arcgis"]).optional(),
  adapterConfig: z.unknown().optional(),
  sample: z.string().max(5_000_000).optional(),
  url: z.string().url().max(2000).optional(),
});

/**
 * Dry run: parse a pasted sample, or fetch the feed URL from the server, with
 * the adapter and mapping given (or saved). Shows what ALRT would create.
 * Saves nothing and creates no alert.
 */
export const previewSource = wrap(async (req) => {
  const body = previewBody.parse(req.body ?? {});
  const source = await prisma.hazardSource.findUnique({ where: { id: String(req.params.id) } });
  if (!source) throw new HttpError(404, "Source not found.");
  const adapter = body.adapterKey ?? (source as any).adapterKey;
  if (!adapter) throw new HttpError(400, "Choose an adapter: cap_au, geojson or arcgis.");
  let raw = body.sample;
  const url = body.url ?? source.feedUrl ?? undefined;
  if (!raw) {
    if (!url) throw new HttpError(400, "Paste a sample or add the feed URL.");
    if (!/^https:\/\//.test(url)) throw new HttpError(400, "Feed URL must start with https://.");
    const ctrl = new AbortController();
    const t = setTimeout(() => ctrl.abort(), 15_000);
    try {
      const r = await fetch(url, { signal: ctrl.signal, headers: { accept: "application/json, application/xml, text/xml, */*" } });
      if (!r.ok) throw new HttpError(502, `The feed answered ${r.status}.`);
      raw = (await r.text()).slice(0, 5_000_000);
    } catch (e) {
      if (e instanceof HttpError) throw e;
      throw new HttpError(502, `Could not fetch the feed: ${(e as Error).message}`);
    } finally {
      clearTimeout(t);
    }
  }
  const { runAdapter } = await import("../../utils/feed_adapters.util.js");
  let parsed;
  try {
    parsed = runAdapter(adapter, raw, source.id, body.adapterConfig ?? (source as any).adapterConfig ?? {});
  } catch (e) {
    throw new HttpError(422, (e as Error).message);
  }
  // First keys of the first item help write the field mapping.
  let fields: string[] = [];
  try {
    const j = JSON.parse(raw);
    const first = j?.features?.[0];
    fields = Object.keys(first?.properties ?? first?.attributes ?? {}).slice(0, 60);
  } catch { /* XML */ }
  return { adapter, items: parsed.hazards.slice(0, 20), total: parsed.hazards.length, skipped: parsed.skipped.slice(0, 20), cancelled: parsed.cancelledIds.length, fields };
});

export const saveSourceAdapter = wrap(async (req) => {
  const body = z.object({
    adapterKey: z.enum(["cap_au", "geojson", "arcgis"]),
    adapterConfig: z.unknown().optional(),
    feedUrl: z.string().url().max(2000).nullish(),
  }).parse(req.body ?? {});
  const { adapterConfigSchema } = await import("../../utils/feed_adapters.util.js");
  const config = body.adapterKey === "cap_au" ? (body.adapterConfig ?? {}) : adapterConfigSchema.parse(body.adapterConfig);
  const id = String(req.params.id);
  const before = await prisma.hazardSource.findUnique({ where: { id } });
  if (!before) throw new HttpError(404, "Source not found.");
  const row = await prisma.hazardSource.update({
    where: { id },
    data: { adapterKey: body.adapterKey, adapterConfig: config as any, ...(body.feedUrl !== undefined && { feedUrl: body.feedUrl }) } as any,
  });
  await recordAdminAuditEntry({ adminId: adminId(req), action: "source.adapter_saved", targetType: "HazardSource", targetId: id, before: { adapterKey: (before as any).adapterKey, adapterConfig: (before as any).adapterConfig }, after: { adapterKey: body.adapterKey, adapterConfig: config } });
  return row;
});
