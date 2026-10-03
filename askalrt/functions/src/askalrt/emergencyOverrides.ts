/**
 * Ask ALRT - admin-editable emergency numbers.
 *
 * The shipped defaults (lib/emergencyLogic.ts EMERGENCY_NUMBERS) remain the
 * permanent fallback. The Admin Portal writes overrides to the Firestore doc
 * `askAlrtConfig/emergencyNumbers` (server-only, see firestore.rules), using the
 * same seed-plus-override pattern as the answer library (entriesLoader.ts) and
 * the system prompt (promptOverride.ts):
 *
 *   { numbers: { "JP": "110", ... }, names: { "JP": "Japan", ... } }
 *
 * `numbers` merge OVER the shipped table. `names` give a display name for the
 * zero-AI lookup ("what is the emergency number in Japan") and let a question
 * naming that country resolve to its ISO code.
 *
 * The pure helpers (sanitizeEmergencyConfig, mergeEmergencyNumbers,
 * aliasesFromNames) are unit-tested; loadEmergencyConfig adds Firestore I/O and
 * a short in-memory cache on top.
 */
import * as admin from "firebase-admin";
import { logger } from "firebase-functions/v2";
import { EMERGENCY_NUMBERS } from "../lib/emergencyLogic";
import { normalize } from "./matching";

export interface EmergencyConfig {
  /** ISO 3166-1 alpha-2 (upper case) -> dialable number. */
  numbers: Record<string, string>;
  /** ISO 3166-1 alpha-2 (upper case) -> display name. */
  names: Record<string, string>;
}

const ISO_RE = /^[A-Z]{2}$/;
/** Digits only, 2 to 6 long: covers 000, 112, 911, 999, 1122 and similar. */
const NUMBER_RE = /^[0-9]{2,6}$/;

/** Validate an untrusted Firestore doc into a clean config. Bad rows are dropped. */
export function sanitizeEmergencyConfig(raw: unknown): EmergencyConfig {
  const out: EmergencyConfig = { numbers: {}, names: {} };
  if (typeof raw !== "object" || raw === null) return out;
  const { numbers, names } = raw as { numbers?: unknown; names?: unknown };

  if (typeof numbers === "object" && numbers !== null) {
    for (const [iso, value] of Object.entries(numbers as Record<string, unknown>)) {
      const key = iso.toUpperCase();
      if (!ISO_RE.test(key)) continue;
      if (typeof value !== "string" || !NUMBER_RE.test(value.trim())) continue;
      out.numbers[key] = value.trim();
    }
  }
  if (typeof names === "object" && names !== null) {
    for (const [iso, value] of Object.entries(names as Record<string, unknown>)) {
      const key = iso.toUpperCase();
      if (!ISO_RE.test(key)) continue;
      if (typeof value !== "string" || value.trim() === "" || value.length > 60) continue;
      out.names[key] = value.trim();
    }
  }
  return out;
}

/** Overrides win over the shipped defaults. Returns a new object. */
export function mergeEmergencyNumbers(
  defaults: Readonly<Record<string, string>>,
  overrides: Readonly<Record<string, string>>
): Record<string, string> {
  return { ...defaults, ...overrides };
}

/**
 * Lower-cased, normalised country name -> ISO, for countries that the bundled
 * COUNTRY_ALIASES list does not cover. Used by detectEmergencyLookup.
 */
export function aliasesFromNames(names: Readonly<Record<string, string>>): Record<string, string> {
  const out: Record<string, string> = {};
  for (const [iso, name] of Object.entries(names)) {
    const key = normalize(name);
    if (key) out[key] = iso;
  }
  return out;
}

export interface ResolvedEmergencyConfig {
  table: Record<string, string>;
  names: Record<string, string>;
}

const CACHE_TTL_MS = 5 * 60 * 1000;
let cache: { at: number; value: ResolvedEmergencyConfig } | null = null;

/**
 * Current emergency table: shipped defaults merged with Firestore overrides.
 * Falls back to the shipped defaults alone on any read error. Cached 5 minutes.
 */
export async function loadEmergencyConfig(): Promise<ResolvedEmergencyConfig> {
  const now = Date.now();
  if (cache && now - cache.at < CACHE_TTL_MS) return cache.value;

  try {
    const snap = await admin.firestore().collection("askAlrtConfig").doc("emergencyNumbers").get();
    const config = sanitizeEmergencyConfig(snap.exists ? snap.data() : undefined);
    const value = {
      table: mergeEmergencyNumbers(EMERGENCY_NUMBERS, config.numbers),
      names: config.names,
    };
    cache = { at: now, value };
    return value;
  } catch (err) {
    logger.warn("askAlrtConfig/emergencyNumbers load failed; using shipped defaults", {
      error: (err as Error).message,
    });
    return { table: { ...EMERGENCY_NUMBERS }, names: {} };
  }
}
