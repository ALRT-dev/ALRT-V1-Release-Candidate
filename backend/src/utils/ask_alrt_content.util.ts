/**
 * Pure rules for the Ask ALRT content the Admin Portal edits: the pre-written
 * answer library and the emergency number list. No database, no Express, so
 * every rule here is unit-checked by src/scripts/verify_ask_alrt_admin_content.ts.
 *
 * The matching and merge behaviour these rows feed lives in
 * services/ask_alrt.service.ts (and services/ask_alrt/matching.ts).
 */
import seedEntries from "../constants/ask_alrt_seed_entries.json" with { type: "json" };

export interface AskAlrtEntryFields {
  triggers: string[];
  keywords: string[];
  answer: string;
  enabled: boolean;
}

export type AskAlrtEntryOrigin = "built_in" | "customised" | "custom";

export interface AskAlrtEntryRow extends AskAlrtEntryFields {
  id: string;
  origin: AskAlrtEntryOrigin;
  /** True when this row exists in the app's bundled library. */
  hasBuiltIn: boolean;
  updatedAt: string | null;
  updatedBy: string | null;
}

interface SeedEntry {
  id: string;
  triggers: string[];
  keywords: string[];
  answer: string;
}

export const BUILT_IN_ENTRIES: readonly SeedEntry[] = seedEntries as SeedEntry[];
export const BUILT_IN_IDS: ReadonlySet<string> = new Set(BUILT_IN_ENTRIES.map((e) => e.id));

export const ENTRY_ID_RE = /^[a-z0-9_]{2,60}$/;
export const MAX_ANSWER_CHARS = 1200;
export const MIN_ANSWER_CHARS = 20;
export const MAX_TRIGGERS = 20;
export const MAX_KEYWORDS = 30;

const EN_OR_EM_DASH = /[–—]/;
/** A run of 6+ digits (allowing spaces, dashes, dots) reads as a phone number. */
const PHONE_LIKE = /(?:\+?\d[\s().-]?){7,}/;

export interface ValidationResult<T> {
  ok: boolean;
  value?: T;
  errors: string[];
}

const cleanList = (items: unknown, label: string, max: number, maxLen: number, errors: string[]): string[] => {
  if (items === undefined) return [];
  if (!Array.isArray(items)) {
    errors.push(`${label} must be a list`);
    return [];
  }
  const out: string[] = [];
  for (const raw of items) {
    if (typeof raw !== "string") {
      errors.push(`${label} must contain only text`);
      continue;
    }
    const value = raw.trim().replace(/\s+/g, " ");
    if (value === "") continue;
    if (value.length > maxLen) {
      errors.push(`${label}: "${value.slice(0, 20)}..." is longer than ${maxLen} characters`);
      continue;
    }
    if (!out.includes(value)) out.push(value);
  }
  if (out.length > max) errors.push(`${label}: at most ${max} allowed`);
  return out;
};

/**
 * Validate the editable fields of one answer. Locked copy rules from the
 * answer library header are enforced here: no phone numbers (the app quotes the
 * local emergency number itself) and no en or em dashes.
 */
export function validateEntryFields(input: {
  triggers?: unknown;
  keywords?: unknown;
  answer?: unknown;
  enabled?: unknown;
}): ValidationResult<AskAlrtEntryFields> {
  const errors: string[] = [];
  const triggers = cleanList(input.triggers, "Trigger phrases", MAX_TRIGGERS, 120, errors);
  const keywords = cleanList(input.keywords, "Keywords", MAX_KEYWORDS, 40, errors);
  if (triggers.length === 0 && keywords.length === 0) {
    errors.push("Add at least one trigger phrase or keyword so this answer can be matched");
  }

  let answer = "";
  if (typeof input.answer !== "string") {
    errors.push("Answer is required");
  } else {
    answer = input.answer.trim();
    if (answer.length < MIN_ANSWER_CHARS) errors.push(`Answer must be at least ${MIN_ANSWER_CHARS} characters`);
    if (answer.length > MAX_ANSWER_CHARS) errors.push(`Answer must be at most ${MAX_ANSWER_CHARS} characters`);
    if (EN_OR_EM_DASH.test(answer)) errors.push("Answer must not contain en or em dashes; use a comma, colon or full stop");
    if (PHONE_LIKE.test(answer)) errors.push("Answer must not contain a phone number");
  }

  const enabled = input.enabled === undefined ? true : input.enabled;
  if (typeof enabled !== "boolean") errors.push("Enabled must be true or false");

  if (errors.length > 0) return { ok: false, errors };
  return { ok: true, errors: [], value: { triggers, keywords, answer, enabled: enabled as boolean } };
}

export interface SavedEntryDoc {
  id: string;
  data: {
    triggers?: unknown;
    keywords?: unknown;
    answer?: unknown;
    enabled?: unknown;
    updatedAt?: unknown;
    updatedBy?: unknown;
  };
}

const asStrings = (v: unknown): string[] =>
  Array.isArray(v) ? v.filter((x): x is string => typeof x === "string") : [];

/**
 * What the app currently shows for each id: built-in answers, with any
 * saved row replacing the built-in of the same id, plus saved-only ids.
 * A built-in row with no doc has origin "built_in" (not yet editable data).
 */
export function mergeEntryRows(docs: readonly SavedEntryDoc[]): AskAlrtEntryRow[] {
  const byId = new Map<string, SavedEntryDoc>(docs.map((d) => [d.id, d]));
  const rows: AskAlrtEntryRow[] = [];

  for (const seed of BUILT_IN_ENTRIES) {
    const doc = byId.get(seed.id);
    if (!doc) {
      rows.push({
        id: seed.id,
        triggers: [...seed.triggers],
        keywords: [...seed.keywords],
        answer: seed.answer,
        enabled: true,
        origin: "built_in",
        hasBuiltIn: true,
        updatedAt: null,
        updatedBy: null,
      });
      continue;
    }
    rows.push(rowFromDoc(doc, "customised", true));
    byId.delete(seed.id);
  }
  for (const doc of byId.values()) rows.push(rowFromDoc(doc, "custom", false));
  return rows.sort((a, b) => a.id.localeCompare(b.id));
}

function rowFromDoc(doc: SavedEntryDoc, origin: AskAlrtEntryOrigin, hasBuiltIn: boolean): AskAlrtEntryRow {
  const { data } = doc;
  return {
    id: doc.id,
    triggers: asStrings(data.triggers),
    keywords: asStrings(data.keywords),
    answer: typeof data.answer === "string" ? data.answer : "",
    enabled: data.enabled !== false,
    origin,
    hasBuiltIn,
    updatedAt: typeof data.updatedAt === "string" ? data.updatedAt : null,
    updatedBy: typeof data.updatedBy === "string" ? data.updatedBy : null,
  };
}

// --- Emergency numbers -------------------------------------------------

export const ISO_RE = /^[A-Z]{2}$/;
/** Digits only, 2 to 6 long: 000, 112, 911, 999, 1122. Same rule the assistant applies. */
export const EMERGENCY_NUMBER_RE = /^[0-9]{2,6}$/;

export interface EmergencyNumberInput {
  iso: string;
  number: string;
  name: string;
}

export function validateEmergencyNumber(input: {
  iso?: unknown;
  number?: unknown;
  name?: unknown;
}): ValidationResult<EmergencyNumberInput> {
  const errors: string[] = [];
  const iso = typeof input.iso === "string" ? input.iso.trim().toUpperCase() : "";
  if (!ISO_RE.test(iso)) errors.push("Country code must be two letters, for example AU");

  const number = typeof input.number === "string" ? input.number.trim() : "";
  if (!EMERGENCY_NUMBER_RE.test(number)) errors.push("Number must be 2 to 6 digits with no spaces or symbols");

  const name = typeof input.name === "string" ? input.name.trim() : "";
  if (name === "") errors.push("Country name is required");
  else if (name.length > 60) errors.push("Country name must be at most 60 characters");
  else if (EN_OR_EM_DASH.test(name)) errors.push("Country name must not contain en or em dashes");

  if (errors.length > 0) return { ok: false, errors };
  return { ok: true, errors: [], value: { iso, number, name } };
}

export interface EmergencyNumberRow extends EmergencyNumberInput {
  /** True when the number comes from the starting list rather than a saved edit. */
  isDefault: boolean;
  /** The starting-list number for this country, if it has one. */
  defaultNumber: string | null;
}

/** Turn a raw saved value into clean {ISO -> value} maps; bad rows are dropped. */
export function readEmergencyDoc(raw: unknown): { numbers: Record<string, string>; names: Record<string, string> } {
  const out = { numbers: {} as Record<string, string>, names: {} as Record<string, string> };
  if (typeof raw !== "object" || raw === null) return out;
  const { numbers, names } = raw as { numbers?: unknown; names?: unknown };
  if (typeof numbers === "object" && numbers !== null) {
    for (const [iso, value] of Object.entries(numbers as Record<string, unknown>)) {
      const key = iso.toUpperCase();
      if (ISO_RE.test(key) && typeof value === "string" && EMERGENCY_NUMBER_RE.test(value.trim())) {
        out.numbers[key] = value.trim();
      }
    }
  }
  if (typeof names === "object" && names !== null) {
    for (const [iso, value] of Object.entries(names as Record<string, unknown>)) {
      const key = iso.toUpperCase();
      if (ISO_RE.test(key) && typeof value === "string" && value.trim() !== "") out.names[key] = value.trim();
    }
  }
  return out;
}

export function buildEmergencyRows(
  defaults: readonly EmergencyNumberInput[],
  saved: { numbers: Record<string, string>; names: Record<string, string> },
): EmergencyNumberRow[] {
  const defaultByIso = new Map(defaults.map((d) => [d.iso, d]));
  const isos = new Set<string>([...defaultByIso.keys(), ...Object.keys(saved.numbers)]);
  const rows: EmergencyNumberRow[] = [];
  for (const iso of isos) {
    const def = defaultByIso.get(iso);
    const savedNumber = saved.numbers[iso];
    rows.push({
      iso,
      number: savedNumber ?? def?.number ?? "",
      name: saved.names[iso] ?? def?.name ?? iso,
      isDefault: savedNumber === undefined,
      defaultNumber: def?.number ?? null,
    });
  }
  return rows.sort((a, b) => a.name.localeCompare(b.name));
}
