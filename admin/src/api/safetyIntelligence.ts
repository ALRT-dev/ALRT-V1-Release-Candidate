import { apiGet, apiPost, apiPut } from "./client";

/** Admin API for the safety intelligence work (owner decisions D1 to D8, 16 Nov 2026). */
const BASE = "/api/admin/safety-intelligence";
const q = (params: Record<string, unknown>) => {
  const s = new URLSearchParams();
  for (const [k, v] of Object.entries(params)) if (v !== undefined && v !== null && v !== "") s.set(k, String(v));
  const out = s.toString();
  return out ? `?${out}` : "";
};

export type GuidanceKind = "advice" | "profile" | "guide_section" | "answer" | "country_fact";
export type GuidanceStatus = "draft" | "in_review" | "approved" | "retired";

export interface GuidanceRecord {
  id: string;
  key: string;
  kind: GuidanceKind;
  hazard: string | null;
  cohort: string | null;
  stage: string | null;
  jurisdiction: string;
  title: string | null;
  text: string;
  longText: string | null;
  triggers: string[];
  sourceAgency: string;
  sourceUrl: string;
  licence: string | null;
  version: number;
  status: GuidanceStatus;
  reviewedAt: string | null;
  nextReviewAt: string | null;
  changeNote: string | null;
  check: { errors: string[]; warnings: string[] };
}

export type GuidanceInput = Partial<Pick<GuidanceRecord, "key" | "hazard" | "cohort" | "stage" | "title" | "longText" | "licence">> & {
  kind: GuidanceKind;
  jurisdiction?: string;
  text: string;
  triggers?: string[];
  sourceAgency: string;
  sourceUrl: string;
  changeNote?: string;
};

export const listGuidance = (p: { kind?: string; hazard?: string; cohort?: string; jurisdiction?: string; status?: string; q?: string; page?: number }) =>
  apiGet<{ items: GuidanceRecord[]; total: number; page: number; pageSize: number }>(`${BASE}/guidance${q(p)}`);
export const guidanceHistory = (key: string) => apiGet<GuidanceRecord[]>(`${BASE}/guidance/history/${encodeURIComponent(key)}`);
export const createGuidance = (body: GuidanceInput) => apiPost<GuidanceRecord>(`${BASE}/guidance`, body);
export const updateGuidance = (id: string, body: GuidanceInput) => apiPut<GuidanceRecord>(`${BASE}/guidance/${id}`, body);
export const submitGuidance = (id: string) => apiPost<GuidanceRecord>(`${BASE}/guidance/${id}/submit`, {});
export const approveGuidance = (id: string, reason?: string) => apiPost<GuidanceRecord>(`${BASE}/guidance/${id}/approve`, { reason });
export const retireGuidance = (id: string, reason?: string) => apiPost<GuidanceRecord>(`${BASE}/guidance/${id}/retire`, { reason });
export const importGuidance = () =>
  apiPost<{ added: number; skipped: number; draftsForReview: number; countriesAdded: number }>(`${BASE}/guidance/import`, {});
export const sendGuidanceToTemplates = () =>
  apiPost<{ sent: number; skipped: { key: string; reason: string }[]; replacedBuiltIn: number }>(`${BASE}/guidance/send-to-templates`, {});
export type CoverageCell = "approved" | "draft" | "overdue" | "no_source" | "empty";
export const guidanceCoverage = (kind: GuidanceKind, axis: "cohort" | "jurisdiction") =>
  apiGet<{ hazards: string[]; columns: string[]; grid: Record<string, Record<string, CoverageCell>> }>(`${BASE}/guidance/coverage${q({ kind, axis })}`);

export interface LibraryGuide { slug: string; title: string; approvedSections: number; pendingSections: number; jurisdictions: string[]; isPublished: boolean; fromLibrary: boolean }
export const listLibraryGuides = () => apiGet<LibraryGuide[]>(`${BASE}/guides`);
export const publishGuide = (slug: string, jurisdiction: string) =>
  apiPost<{ slug: string; jurisdiction: string; version: number; sections: number }>(`${BASE}/guides/${slug}/publish`, { jurisdiction });

export interface CountryProfile {
  code: string; name: string; aliases: string[]; emergencyNumber: string; policeNumber: string | null; ambulanceNumber: string | null;
  fireNumber: string | null; hazards: string[]; drivingSide: string | null; notes: string | null; sourceUrl: string;
  status: GuidanceStatus; reviewedAt: string | null; nextReviewAt: string | null;
}
export const listCountries = () => apiGet<CountryProfile[]>(`${BASE}/countries`);
export const saveCountry = (code: string, body: Partial<CountryProfile>) => apiPut<CountryProfile>(`${BASE}/countries/${code}`, body);

export interface AiUsageRow { day: string; purpose: string; sourceId: string | null; calls: number; failed: number; inputTokens: number; outputTokens: number; costUsd?: number }
export const aiUsage = (p: { days: number; inputPrice?: number; outputPrice?: number }) =>
  apiGet<{ days: number; priced: boolean; usage: AiUsageRow[]; alertsByMethod: { day: string; sourceId: string | null; method: string; alerts: number }[] }>(`${BASE}/ai-usage${q(p)}`);
export const promptVersions = (promptId: string) =>
  apiGet<{ id: string; version: number; content: string; model: string; createdAt: string }[]>(`${BASE}/prompt-versions/${promptId}`);

export const confirmSourceLicence = (id: string, notes: string) => apiPost(`${BASE}/sources/${id}/confirm-licence`, { notes });
export const previewSource = (id: string, body: { adapterKey?: string; adapterConfig?: unknown; sample?: string; url?: string }) =>
  apiPost<{ adapter: string; items: Record<string, unknown>[]; total: number; skipped: { id: string; reason: string }[]; cancelled: number; fields: string[] }>(`${BASE}/sources/${id}/preview`, body);
export const saveSourceAdapter = (id: string, body: { adapterKey: string; adapterConfig?: unknown; feedUrl?: string | null }) =>
  apiPut(`${BASE}/sources/${id}/adapter`, body);

export interface AssuranceCheck { id: string; name: string; status: "pass" | "warn" | "fail"; detail: string; items: string[] }
export interface AssuranceReport { id: string; runAt: string; passed: number; warnings: number; failures: number; checks: AssuranceCheck[]; acknowledgedAt: string | null; report?: string }
export const listAssurance = () => apiGet<AssuranceReport[]>(`${BASE}/assurance`);
export const runAssurance = () => apiPost<AssuranceReport>(`${BASE}/assurance/run`, {});
export const acknowledgeAssurance = (id: string) => apiPost(`${BASE}/assurance/${id}/acknowledge`, {});
