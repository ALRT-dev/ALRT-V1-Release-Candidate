/**
 * Ask ALRT — admin-editable system prompt override.
 *
 * The bundled system prompt (systemPrompt.ts) remains the permanent
 * fallback. This lets Sarah override it from the Firebase Console WITHOUT
 * an app/function release, mirroring the same seed-plus-Firestore-override
 * pattern already used for the answer library (entriesLoader.ts). Ported
 * from backendV2's admin-editable-AI-prompt idea (V1_RECONCILIATION_REPORT
 * S13) - reimplemented here using this service's own Firestore pattern
 * rather than backendV2's Postgres/admin-console one, so it needs no new
 * cross-service dependency.
 *
 * Firestore doc: askAlrtConfig/systemPrompt, field `text` (string).
 * An empty/missing doc, or any read error, falls back to the bundled
 * ASK_ALRT_SYSTEM_PROMPT.
 */
import * as admin from "firebase-admin";
import { logger } from "firebase-functions/v2";
import { ASK_ALRT_SYSTEM_PROMPT } from "./systemPrompt";

const CACHE_TTL_MS = 5 * 60 * 1000;
let cache: { at: number; prompt: string } | null = null;

/** Pure: pick the effective prompt given a raw Firestore doc value. */
export function resolveSystemPrompt(raw: unknown): string {
  if (typeof raw === "object" && raw !== null) {
    const text = (raw as { text?: unknown }).text;
    if (typeof text === "string" && text.trim() !== "") return text;
  }
  return ASK_ALRT_SYSTEM_PROMPT;
}

/** Current system prompt: Firestore override if set, else the bundled
 *  default. Cached for 5 minutes, same as the answer library. */
export async function loadSystemPrompt(): Promise<string> {
  const now = Date.now();
  if (cache && now - cache.at < CACHE_TTL_MS) return cache.prompt;

  try {
    const snap = await admin.firestore().collection("askAlrtConfig").doc("systemPrompt").get();
    const prompt = resolveSystemPrompt(snap.exists ? snap.data() : undefined);
    cache = { at: now, prompt };
    return prompt;
  } catch (err) {
    logger.warn("askAlrtConfig/systemPrompt load failed; using bundled prompt", {
      error: (err as Error).message,
    });
    return ASK_ALRT_SYSTEM_PROMPT;
  }
}
