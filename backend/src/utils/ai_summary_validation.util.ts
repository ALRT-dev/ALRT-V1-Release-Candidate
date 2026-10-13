import type { AISummaryResponse } from "../models/ai_summary_response_interface.js";

/** Limits for AI-written alert content (classification standard §9). */
export const AI_SUMMARY_MAX_WORDS = 25;
export const AI_CALLS_TO_ACTION_MAX = 4;

const wordCount = (text: string): number =>
  text.trim().split(/\s+/).filter(Boolean).length;

/**
 * True when the text contains a phone-like digit run. ALRT never writes a
 * phone number (emergency numbers are deterministic, zero AI, standard §12),
 * so any model output carrying one is rejected.
 */
export const hasPhoneLikeDigits = (text: string): boolean => {
  // Dates are not phone numbers.
  const cleaned = text
    .replace(/\b\d{4}-\d{2}-\d{2}\b/g, " ")
    .replace(/\b\d{1,2}[/.]\d{1,2}[/.]\d{2,4}\b/g, " ");
  return (
    /(?:\+?\d[\s().-]?){8,}/.test(cleaned) ||
    /\b1[38]00[\s-]?\d{3}[\s-]?\d{3}\b/.test(cleaned) ||
    /\b13[\s-]?\d{2}[\s-]?\d{2}\b/.test(cleaned) ||
    /(?<![\d,.])000(?![\d,])/.test(cleaned)
  );
};

export type AISummaryValidation =
  | { ok: true; value: AISummaryResponse }
  | { ok: false; reason: string };

const CONFIDENCE = ["high", "medium", "low"];

/**
 * Validates an untrusted AI summary object. Returns a sanitised copy
 * (trimmed strings) or the first reason it is unusable.
 */
export const validateAISummary = (input: unknown): AISummaryValidation => {
  if (!input || typeof input !== "object" || Array.isArray(input)) {
    return { ok: false, reason: "not an object" };
  }
  const o = input as Record<string, unknown>;

  if (typeof o.title !== "string" || o.title.trim() === "") {
    return { ok: false, reason: "title is not a non-empty string" };
  }
  if (typeof o.summary !== "string" || o.summary.trim() === "") {
    return { ok: false, reason: "summary is not a non-empty string" };
  }
  if (wordCount(o.summary) > AI_SUMMARY_MAX_WORDS) {
    return { ok: false, reason: `summary exceeds ${AI_SUMMARY_MAX_WORDS} words` };
  }
  if (hasPhoneLikeDigits(o.summary)) {
    return { ok: false, reason: "summary contains a phone-like number" };
  }

  if (!Array.isArray(o.callsToAction)) {
    return { ok: false, reason: "callsToAction is not an array" };
  }
  if (o.callsToAction.length > AI_CALLS_TO_ACTION_MAX) {
    return {
      ok: false,
      reason: `callsToAction has more than ${AI_CALLS_TO_ACTION_MAX} items`,
    };
  }
  const calls: string[] = [];
  for (const c of o.callsToAction) {
    if (typeof c !== "string" || c.trim() === "") {
      return { ok: false, reason: "callsToAction item is not a non-empty string" };
    }
    if (wordCount(c) > AI_SUMMARY_MAX_WORDS) {
      return {
        ok: false,
        reason: `callsToAction item exceeds ${AI_SUMMARY_MAX_WORDS} words`,
      };
    }
    if (hasPhoneLikeDigits(c)) {
      return { ok: false, reason: "callsToAction item contains a phone-like number" };
    }
    calls.push(c.trim());
  }

  if (typeof o.confidence !== "string" || !CONFIDENCE.includes(o.confidence)) {
    return { ok: false, reason: "confidence is not high, medium or low" };
  }

  return {
    ok: true,
    value: {
      title: o.title.trim(),
      summary: o.summary.trim(),
      callsToAction: calls,
      confidence: o.confidence as AISummaryResponse["confidence"],
    },
  };
};
