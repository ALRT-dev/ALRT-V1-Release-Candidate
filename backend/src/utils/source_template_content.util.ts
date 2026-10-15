import type { HazardSeverityBand } from "@prisma/client";
import type { AISummaryResponse } from "../models/ai_summary_response_interface.js";
import type { TemplateRelease } from "../services/alert_templates.service.js";
import { getDeterministicAirQualityContent } from "./air_quality_template.util.js";
import { getDeterministicDfesContent, parseDfesWarning } from "./dfes_template.util.js";
import { getDeterministicGdacsContent, parseGdacsLevel } from "./gdacs_template.util.js";
import { resolveTemplate, selectLibraryGuidance } from "./alert_templates.util.js";
import { removeUnattributedNumbers } from "./agency_extraction.util.js";

/** Publishing settings changes presentation, not the reviewed source adapter. */
export function getSourceTemplateContent(input: {
  title: string; description: string; sourceId: string; sourceName: string;
  categoryId: string; parentCategoryId?: string | null; country?: string | null;
  severityBand: HazardSeverityBand; isAwsCompliant: boolean;
  locationName?: string | null; nativeWarningLevel?: string | null;
  sourceActions?: string[]; release?: TemplateRelease | null;
}): AISummaryResponse | null {
  let value: AISummaryResponse | null = null;
  let facts: string[] = [];
  let nativeLevel = input.nativeWarningLevel ?? null;
  const isDfes = input.sourceId === "waDfes";
  if (input.sourceId === "waqi" && input.categoryId === "airQualityAlert") {
    value = getDeterministicAirQualityContent(input);
  } else if (isDfes) {
    value = getDeterministicDfesContent(input);
    facts = parseDfesWarning(input.description)?.facts ?? [];
    nativeLevel ??= /^\s*Warning Type:\s*(.+)$/im.exec(input.description)?.[1]?.trim() ?? null;
  } else if (input.sourceId === "gdacsGlobal") {
    value = getDeterministicGdacsContent(input);
    nativeLevel ??= parseGdacsLevel(`${input.title}\n${input.description}`);
  }
  if (!value) return null;
  const settings = input.release ? resolveTemplate(input.release.pack, { country: input.country ?? null, sourceId: input.sourceId }).settings : null;
  const clean = (s: string) => {
    const text = s.replace(/[\u2013\u2014]/g, "-").trim();
    return settings?.allowAgencyNumbers ? text : removeUnattributedNumbers(text);
  };
  value = { ...value, title: clean(value.title), summary: clean(value.summary), callsToAction: [...new Set([...value.callsToAction, ...(isDfes ? input.sourceActions ?? [] : [])])].map(clean) };
  if (!input.release || !settings) return value;
  const guidance = selectLibraryGuidance(input.release.pack, { categoryId: input.categoryId, parentCategoryId: input.parentCategoryId ?? null, country: input.country ?? null, band: input.severityBand });
  return {
    ...value,
    contentDetails: {
      schemaVersion: 1, templateVersion: input.release.version,
      facts: facts.length ? facts.map(clean) : [value.summary],
      affectedAreas: input.locationName ? [input.locationName] : [],
      nativeLevel: nativeLevel ? clean(nativeLevel) : null,
      officialActions: isDfes ? value.callsToAction : [],
      // Reviewed standing lines are ALRT wording, not instructions from WAQI/GDACS.
      alrtSuggestions: isDfes ? [] : value.callsToAction,
      profileGuidance: guidance.profileGuidance,
      evidence: isDfes ? facts : [],
      presentation: { band: input.severityBand, bandColor: settings.bandColors[input.severityBand], iconCategoryId: input.isAwsCompliant ? input.categoryId : settings.iconCategoryId ?? input.categoryId, agencyArtwork: input.isAwsCompliant },
    },
  };
}
