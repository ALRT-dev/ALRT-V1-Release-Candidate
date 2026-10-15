import { apiGet, apiPut, apiPost } from "./client";
export const BANDS = ["info", "monitor", "action", "critical"] as const;
export type Band = (typeof BANDS)[number];
export type TemplateSettings = {
  language: string;
  promptId: string | null;
  additionalInstructions: string;
  bandColors: Record<Band, string>;
  nativeLevelMappings: { level: string; band: Band }[];
  severityPhrases?: {phrase: string; band: Band}[];
  iconCategoryId: string | null;
  allowAgencyNumbers: boolean;
};
export type TemplateOverride = {
  id: string;
  name: string;
  country: string | null;
  sourceId: string | null;
  settings: Partial<TemplateSettings>;
};
export type GuidanceEntry = {
  id: string;
  text: string;
  categoryIds: string[];
  countries: string[];
  bands: Band[];
  profileTags: string[];
  approved: boolean;
  reference: string;
  reviewedAt: string | null;
};
export type TemplatePack = {
  defaults: TemplateSettings;
  overrides: TemplateOverride[];
  library: GuidanceEntry[];
};
export type TemplateRelease = {
  version: number;
  publishedAt: string;
  reason: string;
  pack: TemplatePack;
};
export type TemplateRegistry = {
  revision: number;
  draft: TemplatePack;
  published: TemplateRelease | null;
  history: TemplateRelease[];
};
export type TemplateSource = {
  id: string;
  name: string;
  country: string | null;
  sourceType: string | null;
  severitySystem: string | null;
};
export type AlertContent = {
  schemaVersion: number;
  templateVersion: number;
  facts: string[];
  affectedAreas: string[];
  nativeLevel: string | null;
  officialActions: string[];
  alrtSuggestions: string[];
  profileGuidance: {
    id: string;
    text: string;
    profileTags: string[];
    reference: string;
    reviewedAt: string | null;
  }[];
  presentation?: {
    band: string;
    bandColor: string;
    iconCategoryId: string;
    agencyArtwork: boolean;
  };
};
export type TemplatePreview = {
  previewOnly: true;
  suppressed: boolean;
  band: Band;
  reason: string;
  applied: string[];
  isAws: boolean;
  settings: TemplateSettings;
  output: {
    title: string;
    summary: string;
    callsToAction: string[];
    confidence: string;
    extractionFallback?: boolean;
    contentDetails?: AlertContent;
  } | null;
};
export const getAlertTemplates = () =>
  apiGet<{ state: TemplateRegistry; sources: TemplateSource[] }>(
    "/api/admin/alert-templates",
  );
export const saveAlertTemplates = (data: {
  revision: number;
  action: "draft" | "publish" | "restore";
  pack?: TemplatePack;
  version?: number;
  reason: string;
}) => apiPut<TemplateRegistry>("/api/admin/alert-templates", data);
export const previewAlertTemplate = (data: {
  pack: TemplatePack;
  sourceId: string;
  categoryId: string;
  title: string;
  description: string;
  nativeWarningLevel: string | null;
  jurisdictionCountry?:string|null;
  extract: boolean;
  sourceInstructions?: string[];
}) => apiPost<TemplatePreview>("/api/admin/alert-templates/preview", data);
