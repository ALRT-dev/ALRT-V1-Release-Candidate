import { HttpError } from "../models/http_error.js";
import prisma from "../utils/prisma_client.util.js";
import {
  buildKey, checkGuidance, coverageGrid, COHORTS, nextReviewFrom, normaliseJurisdiction, overdue, toTemplateEntries,
  type GuidanceInput, type GuidanceKind, type GuidanceRow,
} from "../utils/guidance_library.util.js";
import { buildCountryImport, buildDraftGuideRecords, buildImportRecords, categoryIdsForHazard } from "../utils/guidance_import.util.js";
import { DRAFT_GUIDES, NATIONAL_GUIDES } from "../data/guidance_drafts_20261116.js";
import { jurisdictionChain } from "../utils/guidance_library.util.js";
import { approvedRecords, clearGuidanceCache } from "./guidance_read.service.js";
export { approvedRecords, clearGuidanceCache };
import { recordAdminAuditEntry } from "./admin_audit_log.service.js";
import { getTemplateRegistry, saveTemplateRegistry } from "./alert_templates.service.js";

/**
 * The shared guidance library (owner decisions D2, D4, D5, 16 Nov 2026).
 * Each row is one version of one record. Draft -> in review -> approved;
 * approving a version retires the version it replaces. Reviewers draft,
 * admins approve. Every step is in the audit log.
 */
const db = prisma as any;

export interface GuidanceFilters {
  kind?: GuidanceKind;
  hazard?: string;
  cohort?: string;
  jurisdiction?: string;
  status?: string;
  q?: string;
  page?: number;
  pageSize?: number;
}

export const listGuidance = async (f: GuidanceFilters) => {
  const where: Record<string, unknown> = {
    ...(f.kind && { kind: f.kind }),
    ...(f.hazard && { hazard: f.hazard }),
    ...(f.cohort && { cohort: f.cohort }),
    ...(f.jurisdiction && { jurisdiction: normaliseJurisdiction(f.jurisdiction) }),
    ...(f.status ? { status: f.status } : { status: { not: "retired" } }),
    ...(f.q && { OR: [{ text: { contains: f.q, mode: "insensitive" } }, { title: { contains: f.q, mode: "insensitive" } }, { key: { contains: f.q } }] }),
  };
  const pageSize = Math.min(f.pageSize ?? 50, 200);
  const page = Math.max(f.page ?? 1, 1);
  const [items, total] = await Promise.all([
    db.guidanceRecord.findMany({ where, orderBy: [{ kind: "asc" }, { hazard: "asc" }, { key: "asc" }, { version: "desc" }], skip: (page - 1) * pageSize, take: pageSize }),
    db.guidanceRecord.count({ where }),
  ]);
  return {
    items: items.map((r: GuidanceRow) => ({ ...r, check: checkGuidance(r, { forApproval: true }) })),
    total, page, pageSize,
  };
};

export const guidanceHistory = (key: string) =>
  db.guidanceRecord.findMany({ where: { key }, orderBy: { version: "desc" } });

const latestVersion = async (key: string): Promise<number> =>
  (await db.guidanceRecord.findFirst({ where: { key }, orderBy: { version: "desc" }, select: { version: true } }))?.version ?? 0;

const clean = (input: GuidanceInput) => ({
  kind: input.kind,
  hazard: input.hazard?.trim() || null,
  cohort: input.cohort?.trim() || null,
  stage: input.stage?.trim() || null,
  jurisdiction: normaliseJurisdiction(input.jurisdiction),
  title: input.title?.trim() || null,
  text: input.text.trim(),
  longText: input.longText?.trim() || null,
  triggers: (input.triggers ?? []).map((t) => t.trim()).filter(Boolean),
  sourceAgency: input.sourceAgency.trim(),
  sourceUrl: (input.sourceUrl ?? "").trim(),
  licence: input.licence?.trim() || null,
});

/** A new record, or a new draft version of an existing one (same key). */
export const createDraft = async (input: GuidanceInput & { changeNote?: string }, adminId: string) => {
  const check = checkGuidance(input);
  if (check.errors.length) throw new HttpError(400, check.errors.join(" "));
  const key = input.key?.trim() || buildKey(input);
  const pending = await db.guidanceRecord.findFirst({ where: { key, status: { in: ["draft", "in_review"] } } });
  if (pending) throw new HttpError(409, "This record already has a draft. Edit that draft instead.");
  const version = (await latestVersion(key)) + 1;
  const row = await db.guidanceRecord.create({
    data: { ...clean(input), key, version, status: "draft", authorId: adminId, changeNote: input.changeNote?.trim() || null },
  });
  await recordAdminAuditEntry({ adminId, action: "guidance.draft", targetType: "GuidanceRecord", targetId: row.id, after: { key, version } });
  return { ...row, check };
};

export const updateDraft = async (id: string, input: GuidanceInput & { changeNote?: string }, adminId: string) => {
  const existing = await db.guidanceRecord.findUnique({ where: { id } });
  if (!existing) throw new HttpError(404, "Record not found.");
  if (existing.status !== "draft" && existing.status !== "in_review")
    throw new HttpError(409, "Approved records are not edited. Create a new version instead.");
  const check = checkGuidance(input);
  if (check.errors.length) throw new HttpError(400, check.errors.join(" "));
  const row = await db.guidanceRecord.update({
    where: { id },
    data: { ...clean(input), kind: existing.kind, status: "draft", changeNote: input.changeNote?.trim() || existing.changeNote },
  });
  await recordAdminAuditEntry({ adminId, action: "guidance.edit", targetType: "GuidanceRecord", targetId: id, before: { text: existing.text }, after: { text: row.text } });
  return { ...row, check };
};

export const submitForReview = async (id: string, adminId: string) => {
  const existing = await db.guidanceRecord.findUnique({ where: { id } });
  if (!existing || existing.status !== "draft") throw new HttpError(409, "Only a draft can be sent for review.");
  const row = await db.guidanceRecord.update({ where: { id }, data: { status: "in_review" } });
  await recordAdminAuditEntry({ adminId, action: "guidance.submit", targetType: "GuidanceRecord", targetId: id });
  return row;
};

/** Approve and publish a version; the version it replaces is retired. */
export const approve = async (id: string, adminId: string, reason?: string) => {
  const existing = await db.guidanceRecord.findUnique({ where: { id } });
  if (!existing) throw new HttpError(404, "Record not found.");
  if (existing.status === "approved") return existing;
  if (existing.status === "retired") throw new HttpError(409, "A retired version cannot be approved. Create a new version.");
  const check = checkGuidance(existing, { forApproval: true });
  if (check.errors.length) throw new HttpError(400, check.errors.join(" "));
  const now = new Date();
  const [, row] = await prisma.$transaction([
    db.guidanceRecord.updateMany({ where: { key: existing.key, status: "approved", id: { not: id } }, data: { status: "retired" } }),
    db.guidanceRecord.update({
      where: { id },
      data: { status: "approved", reviewerId: adminId, reviewedAt: now, publishedAt: now, nextReviewAt: nextReviewFrom(now) },
    }),
  ]);
  await recordAdminAuditEntry({ adminId, action: "guidance.approve", targetType: "GuidanceRecord", targetId: id, reason: reason ?? null, after: { key: existing.key, version: existing.version } });
  return row;
};

export const retire = async (id: string, adminId: string, reason?: string) => {
  const row = await db.guidanceRecord.update({ where: { id }, data: { status: "retired" } });
  await recordAdminAuditEntry({ adminId, action: "guidance.retire", targetType: "GuidanceRecord", targetId: id, reason: reason ?? null });
  return row;
};

/** One-off import of the existing stores. Safe to run twice: existing keys are skipped. */
export const importExisting = async (adminId: string) => {
  const records = buildImportRecords();
  const existing = new Set<string>((await db.guidanceRecord.findMany({ select: { key: true } })).map((r: { key: string }) => r.key));
  const fresh = records.filter((r) => !existing.has(r.key));
  const now = new Date();
  if (fresh.length) {
    await db.guidanceRecord.createMany({
      data: fresh.map((r) => {
        const reviewed = new Date(r.reviewedAt);
        return {
          ...clean(r), key: r.key, version: 1, status: "approved", authorId: adminId, reviewerId: adminId,
          reviewedAt: reviewed, publishedAt: now, nextReviewAt: nextReviewFrom(reviewed), changeNote: r.changeNote,
        };
      }),
      skipDuplicates: true,
    });
  }
  // Drafted new guides go in for review, never approved automatically.
  const drafts = buildDraftGuideRecords().filter((r) => !existing.has(r.key));
  if (drafts.length) {
    await db.guidanceRecord.createMany({
      data: drafts.map((r) => ({ ...clean(r), key: r.key, version: 1, status: "in_review", authorId: adminId, changeNote: r.changeNote })),
      skipDuplicates: true,
    });
  }
  const countries = buildCountryImport();
  let countriesAdded = 0;
  for (const c of countries) {
    const found = await db.countryProfile.findUnique({ where: { code: c.code } });
    if (found) continue;
    await db.countryProfile.create({ data: { ...c, status: "approved", reviewedAt: now, nextReviewAt: nextReviewFrom(now) } });
    countriesAdded += 1;
  }
  await recordAdminAuditEntry({ adminId, action: "guidance.import", targetType: "GuidanceRecord", after: { added: fresh.length, skipped: records.length - fresh.length, draftsForReview: drafts.length, countriesAdded } });
  return { added: fresh.length, skipped: records.length - fresh.length, draftsForReview: drafts.length, countriesAdded };
};

const LIBRARY_PREFIX = "lib-";

/**
 * Puts the approved advice and Safety Profile lines into the Alert Templates
 * DRAFT. Nothing goes live until someone publishes Alert Templates, which
 * keeps one publish button and one rollback for everything alerts show.
 */
export const sendToAlertTemplates = async (adminId: string) => {
  const all: GuidanceRow[] = await db.guidanceRecord.findMany({ where: { status: "approved", kind: { in: ["advice", "profile"] } } });
  // Safety Profile lines the app already holds on the device (imported
  // unchanged) stay there; only new or edited lines go to Alert Templates,
  // where they replace the device row group by group.
  const onDevice = new Map(buildImportRecords().filter((r) => r.kind === "profile").map((r) => [r.key, r.text]));
  const rows = all.filter((r) => r.kind !== "profile" || onDevice.get(r.key) !== r.text);
  const knownCategories = new Set<string>((await prisma.hazardCategory.findMany({ select: { id: true } })).map((c) => c.id));
  const { entries, skipped } = toTemplateEntries(rows, (h) => categoryIdsForHazard(h).filter((id) => knownCategories.has(id)));
  // Library advice supersedes the built-in line it was imported from.
  const superseded = new Set(rows.filter((r) => r.kind === "advice").map((r) => `safety-${r.key.split(":").pop()}`));
  const registry = await getTemplateRegistry();
  const kept = registry.draft.library.filter((e) => !e.id.startsWith(LIBRARY_PREFIX) && !superseded.has(e.id));
  const pack = { ...registry.draft, library: [...kept, ...entries] };
  await saveTemplateRegistry({
    revision: registry.revision, action: "draft", pack,
    reason: `Guidance library: ${entries.length} approved lines sent to the draft`, adminId,
  });
  await recordAdminAuditEntry({ adminId, action: "guidance.send_to_templates", targetType: "Configuration", after: { sent: entries.length, skipped: skipped.length, replaced: registry.draft.library.length - kept.length } });
  return { sent: entries.length, skipped, replacedBuiltIn: registry.draft.library.length - kept.length - registry.draft.library.filter((e) => e.id.startsWith(LIBRARY_PREFIX)).length };
};

/** Coverage grid for admin: hazards x groups (profile) or hazards x places (advice, guides). */
export const coverage = async (kind: GuidanceKind, axis: "cohort" | "jurisdiction") => {
  const rows: GuidanceRow[] = await db.guidanceRecord.findMany({ where: { kind, status: { not: "retired" } } });
  const hazards = [...new Set(rows.map((r) => r.hazard).filter((h): h is string => Boolean(h)))].sort();
  const columns = axis === "cohort"
    ? [...COHORTS]
    : [...new Set(["AU", "AU-WA", "AU-NSW", "AU-VIC", "AU-QLD", "AU-SA", "AU-TAS", "AU-NT", "AU-ACT", ...rows.map((r) => normaliseJurisdiction(r.jurisdiction))])];
  return { hazards, columns, grid: coverageGrid(rows, hazards, columns, axis, kind) };
};

export const overdueRecords = async () => overdue(await approvedRecords());

// --- Country register ------------------------------------------------------

export const listCountries = () => db.countryProfile.findMany({ orderBy: { name: "asc" } });

export const saveCountry = async (code: string, input: Record<string, unknown>, adminId: string) => {
  const c = code.trim().toUpperCase();
  if (!/^[A-Z]{2}(-[A-Z]{2,3})?$/.test(c)) throw new HttpError(400, "Use a country code (ID) or country and state (AU-WA).");
  const number = String(input.emergencyNumber ?? "").trim();
  if (!/^[0-9]{2,6}$/.test(number)) throw new HttpError(400, "Emergency number must be 2 to 6 digits.");
  const sourceUrl = String(input.sourceUrl ?? "").trim();
  if (sourceUrl && !/^https:\/\//.test(sourceUrl)) throw new HttpError(400, "Source link must start with https://.");
  const str = (k: string) => (typeof input[k] === "string" && (input[k] as string).trim()) || null;
  const list = (k: string) => (Array.isArray(input[k]) ? (input[k] as unknown[]).map(String).map((s) => s.trim()).filter(Boolean) : []);
  const data = {
    name: String(input.name ?? c).trim(), aliases: list("aliases"), emergencyNumber: number,
    policeNumber: str("policeNumber"), ambulanceNumber: str("ambulanceNumber"), fireNumber: str("fireNumber"),
    hazards: list("hazards"), warningAgencies: Array.isArray(input.warningAgencies) ? input.warningAgencies : [],
    drivingSide: str("drivingSide"), notes: str("notes"), sourceUrl,
    status: input.status === "approved" ? "approved" : "draft",
    ...(input.status === "approved" && { reviewedAt: new Date(), nextReviewAt: nextReviewFrom(new Date()) }),
  };
  if (data.status === "approved" && !sourceUrl) throw new HttpError(400, "Add the official source before approving.");
  const before = await db.countryProfile.findUnique({ where: { code: c } });
  const row = await db.countryProfile.upsert({ where: { code: c }, create: { code: c, ...data }, update: data });
  await recordAdminAuditEntry({ adminId, action: "country.save", targetType: "CountryProfile", targetId: c, before: before ? { emergencyNumber: before.emergencyNumber } : null, after: { emergencyNumber: number, status: data.status } });
  return row;
};

// --- Learn guides from the library -----------------------------------------

/** Guides the library holds sections for, with how many are approved. */
export const listLibraryGuides = async () => {
  const rows: GuidanceRow[] = await db.guidanceRecord.findMany({ where: { kind: "guide_section", status: { not: "retired" } } });
  const published: { slug: string; title: string; isPublished: boolean; sourceNote: string | null }[] =
    await prisma.safetyGuide.findMany({ select: { slug: true, title: true, isPublished: true, sourceNote: true } });
  const bySlug = new Map<string, { approved: number; pending: number; jurisdictions: Set<string> }>();
  for (const r of rows) {
    const g = bySlug.get(r.hazard ?? "") ?? { approved: 0, pending: 0, jurisdictions: new Set<string>() };
    if (r.status === "approved") g.approved += 1; else g.pending += 1;
    g.jurisdictions.add(normaliseJurisdiction(r.jurisdiction));
    bySlug.set(r.hazard ?? "", g);
  }
  return [...bySlug.entries()].map(([slug, g]) => {
    const live = published.find((p) => p.slug === slug);
    const draft = [...DRAFT_GUIDES, ...NATIONAL_GUIDES].find((d) => d.slug === slug);
    return {
      slug, title: live?.title ?? draft?.title ?? slug, approvedSections: g.approved, pendingSections: g.pending,
      jurisdictions: [...g.jurisdictions], isPublished: live?.isPublished ?? false,
      fromLibrary: Boolean(live?.sourceNote?.includes("[library")),
    };
  }).sort((a, b) => a.title.localeCompare(b.title));
};

const DISCLAIMER =
  "ALRT shares safety information and does not issue emergency instructions. In a life-threatening emergency call your local emergency number.";

/**
 * Builds the Learn guide for [slug] from its APPROVED library sections for
 * [jurisdiction] (falling back to national) and publishes it. The guide
 * names every source it uses and the library version.
 */
export const publishGuide = async (slug: string, jurisdiction: string, adminId: string) => {
  const rows: GuidanceRow[] = await db.guidanceRecord.findMany({ where: { kind: "guide_section", hazard: slug, status: "approved" } });
  let chosen: GuidanceRow[] = [];
  let used = "";
  for (const j of jurisdictionChain(jurisdiction)) {
    chosen = rows.filter((r) => normaliseJurisdiction(r.jurisdiction) === j);
    if (chosen.length) { used = j; break; }
  }
  // Rewritten library sections (key ends ":L<n>") replace the older imported
  // text for the same guide and jurisdiction rather than mixing with it.
  const isLibrary = (r: GuidanceRow) => /^L\d+$/.test(r.key.split(":").pop() ?? "");
  if (chosen.some(isLibrary)) chosen = chosen.filter(isLibrary);
  if (!chosen.length) throw new HttpError(400, "This guide has no approved sections yet. Approve its sections first.");
  const order = (r: GuidanceRow) => Number((r.key.split(":").pop() ?? "").replace(/^L/, "")) || 0;
  const sections: Record<string, { title: string; body: string }[]> = { before: [], during: [], after: [] };
  for (const r of [...chosen].sort((a, b) => order(a) - order(b))) {
    (sections[r.stage ?? "before"] ??= []).push({ title: r.title ?? "", body: r.text });
  }
  const sources = [...new Map(chosen.map((r) => [r.sourceUrl || r.sourceAgency, r])).values()];
  const sourceName = [...new Set(sources.map((r) => r.sourceAgency))].join("; ");
  const sourceUrl = sources.find((r) => r.sourceUrl)?.sourceUrl ?? "";
  const version = Math.max(...chosen.map((r) => r.version));
  const sourceNote = `This guide summarises publicly available safety information from ${sources
    .map((r) => `${r.sourceAgency}${r.sourceUrl ? ` (${r.sourceUrl})` : ""}`)
    .join("; ")}. ${DISCLAIMER} [library ${slug} ${used} v${version}]`;

  const existing = await prisma.safetyGuide.findUnique({ where: { slug } });
  const draft = [...DRAFT_GUIDES, ...NATIONAL_GUIDES].find((d) => d.slug === slug);
  let topicId = existing?.topicId;
  if (!topicId && draft) topicId = (await prisma.safetyGuideTopic.findUnique({ where: { slug: draft.topicSlug } }))?.id;
  if (!topicId) throw new HttpError(400, "No Learn topic found for this guide.");
  let categoryIds = existing?.categoryIds ?? [];
  if (!existing && draft) {
    const cats = await prisma.hazardCategory.findMany({ select: { id: true, name: true } });
    categoryIds = cats.filter((c) => draft.categoryKeywords.some((k) => c.name.toLowerCase().includes(k))).map((c) => c.id);
  }
  const data = {
    topicId, title: existing?.title ?? draft?.title ?? slug, summary: existing?.summary ?? draft?.summary ?? "",
    sections: sections as any, sourceName, sourceUrl, sourceNote, categoryIds, isPublished: true,
  };
  await prisma.safetyGuide.upsert({ where: { slug }, update: data, create: { slug, xpReward: 10, sortOrder: 50, ...data } as any });
  // A replacement guide retires the old one it replaces.
  if (draft?.replaces && draft.replaces !== slug) {
    await prisma.safetyGuide.updateMany({ where: { slug: draft.replaces }, data: { isPublished: false } });
  }
  await recordAdminAuditEntry({ adminId, action: "guide.publish_from_library", targetType: "SafetyGuide", targetId: slug, after: { jurisdiction: used, version, sections: chosen.length } });
  return { slug, jurisdiction: used, version, sections: chosen.length };
};
