/**
 * Templates first, AI only when a template would read badly (owner, 13
 * November 2026: "as many templates as possible so people are getting easy
 * to understand alerts ... not a burden of information").
 *
 * Two pieces:
 * - USGS earthquakes always arrive as the same few fields, so they get a
 *   fixed plain-language card and never a model call.
 * - Australian agency feeds that publish their own sentences and
 *   instructions are first built with the same code extraction NSW RFS and
 *   NSW SES use. The card is kept only if it passes isPlainTemplateCard;
 *   anything that reads like raw feed fields, shouting or a wall of text
 *   still goes to the model, so a template is never a worse alert.
 */
import { agencyExtractionFallback } from "./agency_extraction.util.js";

/** Sources tried with the code template before the model. */
export const TEMPLATE_FIRST_SOURCE_IDS: ReadonlySet<string> = new Set([
  "bom",
  "cfs",
  "viceFire",
  "qldFire",
  "ntFireAndRescue",
  "actEs",
  "nswTransport",
  "qldTraffic",
  "qldPark",
]);

const FIELD_LABEL = /^[A-Za-z][A-Za-z /&()'-]{1,30}:\s/;
const MIN_FACT = 15;
const MAX_FACT = 240;
const MAX_ACTION = 300;

const shouting = (text: string) => {
  const letters = text.replace(/[^A-Za-z]/g, "");
  if (letters.length < 12) return false;
  const upper = letters.replace(/[^A-Z]/g, "").length;
  return upper / letters.length > 0.4;
};

/**
 * True when a code-built card is as easy to read as the model's would be:
 * two to four short, plain facts, What to do with at least two points, and
 * no raw "Field: value" lines, shouting or long paragraphs.
 */
export const isPlainTemplateCard = (details: {
  facts?: string[] | null;
  officialActions?: string[] | null;
  alrtSuggestions?: string[] | null;
}): boolean => {
  const facts = details.facts ?? [];
  const actions = details.officialActions ?? [];
  const advice = details.alrtSuggestions ?? [];
  if (facts.length < 2 || facts.length > 4) return false;
  if (actions.length + advice.length < 2) return false;
  const factOk = (fact: string) =>
    fact.length >= MIN_FACT &&
    fact.length <= MAX_FACT &&
    !FIELD_LABEL.test(fact) &&
    !shouting(fact);
  if (!facts.every(factOk)) return false;
  return actions.every(
    (action) => action.length <= MAX_ACTION && !shouting(action),
  );
};

/** The template card for an agency feed, or null when the model should write it. */
export const templateFirstAgencyCard = (
  options: Parameters<typeof agencyExtractionFallback>[0],
) => {
  const value = agencyExtractionFallback(options);
  return isPlainTemplateCard(value.contentDetails) ? value : null;
};

const field = (description: string, label: string) =>
  description
    .split("\n")
    .map((line) => line.trim())
    .find((line) => line.toLowerCase().startsWith(`${label.toLowerCase()}:`))
    ?.slice(label.length + 1)
    .trim() || null;

/**
 * The plain card for a USGS earthquake. Facts come only from the feed's own
 * fields; What to do is the reviewed ALRT earthquake advice, because USGS
 * gives no instructions. Null when magnitude or place cannot be read.
 */
export const buildUsgsEarthquakeContent = (options: {
  title: string;
  description: string;
  alrtSuggestions: string[];
  profileGuidance: unknown[];
  templateVersion: number;
}) => {
  const place =
    field(options.description, "Location") ??
    options.title.replace(/^M\s*[\d.]+\s*-\s*/i, "").trim();
  const magnitudeText =
    field(options.description, "Magnitude") ??
    options.title.match(/^M\s*([\d.]+)/i)?.[1] ??
    null;
  const magnitude = magnitudeText ? Number.parseFloat(magnitudeText) : NaN;
  if (!place || !Number.isFinite(magnitude)) return null;

  const depthText = field(options.description, "Depth");
  const depth = depthText ? Number.parseFloat(depthText) : NaN;
  const status = field(options.description, "Status")?.toLowerCase() ?? null;

  const where = /^\d/.test(place) ? place : `near ${place}`;
  const facts = [
    `A magnitude ${magnitude.toFixed(1)} earthquake was recorded ${where}.`,
    ...(Number.isFinite(depth)
      ? [`It was about ${Math.max(1, Math.round(depth))} km below the surface.`]
      : []),
    ...(status === "automatic"
      ? ["This is an early automatic reading and may be revised."]
      : []),
  ].slice(0, 4);
  const alrtSuggestions = options.alrtSuggestions.slice(0, 4);

  return {
    title: options.title,
    summary: facts.map((fact) => `• ${fact}`).join("\n"),
    callsToAction: alrtSuggestions,
    confidence: "high" as const,
    contentDetails: {
      schemaVersion: 1,
      templateVersion: options.templateVersion,
      facts,
      affectedAreas: [place],
      nativeLevel: null,
      officialActions: [] as string[],
      alrtSuggestions,
      profileGuidance: options.profileGuidance,
      evidence: facts.map(() => options.description),
    },
  };
};
