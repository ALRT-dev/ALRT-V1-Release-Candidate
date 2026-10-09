/**
 * Ask ALRT pure rules (no database, no network): answer-library merge,
 * emergency-number resolution, the per-request context for the AI, and the
 * chat-turn clean-up Bedrock needs. Checked by
 * src/scripts/verify_ask_alrt_backend.ts with no server.
 */
import { EMERGENCY_NUMBER_DEFAULTS } from "../../constants/emergency_number_defaults.js";
import { BUILT_IN_ENTRIES, ISO_RE, EMERGENCY_NUMBER_RE } from "../../utils/ask_alrt_content.util.js";
import { normalize, type KnowledgeEntry } from "./matching.js";

export const ISO_NAMES: Record<string, string> = Object.fromEntries(
  EMERGENCY_NUMBER_DEFAULTS.map((d) => [d.iso, d.name]),
);

export interface NearbyAlert {
  id: string;
  title: string;
  category?: string;
  severity?: string;
  source?: string;
}

export interface AskRequest {
  question: string;
  history?: { role: "user" | "assistant"; content: string }[];
  emergencyNumber?: string;
  nearbyAlerts?: NearbyAlert[];
  context?: string;
  language?: string;
  timeZone?: string;
  utcOffsetMinutes?: number;
}

export const asStringArray = (v: unknown): string[] =>
  Array.isArray(v) ? v.filter((x): x is string => typeof x === "string" && x.trim() !== "") : [];

/** Saved answers merge OVER the built-in ones by id; enabled=false hides one. */
export const mergeEntries = (
  rows: readonly { id: string; triggers: string[]; keywords: string[]; answer: string; enabled: boolean }[],
): KnowledgeEntry[] => {
  const map = new Map<string, KnowledgeEntry>(
    BUILT_IN_ENTRIES.map((e) => [e.id, { id: e.id, triggers: e.triggers, keywords: e.keywords, answer: e.answer }]),
  );
  for (const row of rows) {
    if (!row.enabled) {
      map.delete(row.id);
      continue;
    }
    const answer = row.answer.trim();
    const triggers = asStringArray(row.triggers);
    const keywords = asStringArray(row.keywords);
    if (!answer || (triggers.length === 0 && keywords.length === 0)) continue;
    map.set(row.id, { id: row.id, triggers, keywords, answer });
  }
  return [...map.values()];
};

/** Saved numbers merge OVER the starting list; saved names add lookups. */
export const resolveEmergency = (
  saved: { numbers: Record<string, string>; names: Record<string, string> },
): { table: Record<string, string>; names: Record<string, string> } => {
  const table: Record<string, string> = {};
  const names: Record<string, string> = {};
  for (const d of EMERGENCY_NUMBER_DEFAULTS) {
    table[d.iso] = d.number;
    names[d.iso] = d.name;
  }
  for (const [iso, n] of Object.entries(saved.numbers)) {
    if (ISO_RE.test(iso) && EMERGENCY_NUMBER_RE.test(n)) table[iso] = n;
  }
  for (const [iso, name] of Object.entries(saved.names)) {
    if (ISO_RE.test(iso) && name.trim()) names[iso] = name.trim();
  }
  return { table, names };
};

export const readSavedEmergency = (raw: unknown): { numbers: Record<string, string>; names: Record<string, string> } => {
  const out = { numbers: {} as Record<string, string>, names: {} as Record<string, string> };
  if (typeof raw !== "object" || raw === null) return out;
  const { numbers, names } = raw as { numbers?: unknown; names?: unknown };
  if (typeof numbers === "object" && numbers !== null) {
    for (const [iso, v] of Object.entries(numbers as Record<string, unknown>)) {
      if (typeof v === "string" && EMERGENCY_NUMBER_RE.test(v.trim())) out.numbers[iso.toUpperCase()] = v.trim();
    }
  }
  if (typeof names === "object" && names !== null) {
    for (const [iso, v] of Object.entries(names as Record<string, unknown>)) {
      if (typeof v === "string" && v.trim()) out.names[iso.toUpperCase()] = v.trim();
    }
  }
  return out;
};

export const emergencyAnswer = (
  iso: string,
  table: Readonly<Record<string, string>>,
  names: Readonly<Record<string, string>>,
): string | null => {
  const number = table[iso];
  if (!number) return null;
  const name = names[iso] ?? ISO_NAMES[iso] ?? iso;
  return `In ${name}, the emergency number is ${number}. If you are in danger, call it now. ALRT is a helper, it does not contact emergency services for you.`;
};

export const aliasesFromNames = (names: Readonly<Record<string, string>>): Record<string, string> => {
  const out: Record<string, string> = {};
  for (const [iso, name] of Object.entries(names)) {
    const key = normalize(name);
    if (key) out[key] = iso;
  }
  return out;
};

export const nearbyAlertsLine = (alert: NearbyAlert): string => {
  const parts = [alert.title, alert.category, alert.severity, alert.source].filter(
    (p): p is string => typeof p === "string" && p.trim() !== "",
  );
  return `  [${alert.id}] ${parts.join(" - ")}`;
};

/** Per-request context, and the alert ids actually sent (citations are checked against them). */
export const contextBlock = (data: AskRequest): { text: string; sentAlertIds: string[] } => {
  const validAlerts = (data.nearbyAlerts ?? []).filter(
    (a): a is NearbyAlert => typeof a?.id === "string" && a.id.trim() !== "" && typeof a?.title === "string",
  );
  const lines = ["Context for this question (not shown to the user):"];
  lines.push(
    data.emergencyNumber && EMERGENCY_NUMBER_RE.test(data.emergencyNumber)
      ? `- Resolved local emergency number: ${data.emergencyNumber}. Use this exact number when directing the user to emergency services.`
      : "- No emergency number was resolved for this user. Direct them to their local emergency number by region.",
  );
  if (validAlerts.length > 0) {
    lines.push("- Nearby alerts the app is showing (id first, for citation only):");
    for (const alert of validAlerts) lines.push(nearbyAlertsLine(alert));
    lines.push(
      "- If your answer relies on one or more of the alerts above, end your reply " +
        "with a new final line formatted exactly as `USED_ALERT_IDS: id1,id2` using " +
        "only the ids given above, comma-separated, no other text on that line. " +
        "Omit this line entirely if you did not rely on any of them. Never invent " +
        "an id that was not given to you.",
    );
  } else if (data.context && data.context.trim()) {
    lines.push(`- Nearby alerts the app is showing: ${data.context.trim().slice(0, 2000)}`);
  } else {
    lines.push(
      "- No live alert context was provided. Do not state whether any area is affected; send the user to their in-app alerts and the live map.",
    );
  }
  if (data.language && /^[A-Za-z-]{2,20}$/.test(data.language)) {
    lines.push(`- Answer in this language: ${data.language}.`);
  }
  return { text: lines.join("\n"), sentAlertIds: validAlerts.map((a) => a.id) };
};

export interface ChatTurn {
  role: "user" | "assistant";
  content: string;
}

/**
 * Bedrock needs a conversation that starts with the user and alternates
 * roles. Drops a leading assistant turn and merges same-role neighbours.
 */
export const normaliseChatTurns = (turns: readonly ChatTurn[]): ChatTurn[] => {
  const out: ChatTurn[] = [];
  for (const turn of turns) {
    const text = turn.content.trim();
    if (!text) continue;
    const last = out[out.length - 1];
    if (last && last.role === turn.role) {
      last.content = `${last.content}\n\n${text}`;
    } else if (last || turn.role === "user") {
      out.push({ role: turn.role, content: text });
    }
  }
  return out;
};

