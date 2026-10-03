/**
 * Ask ALRT — library-first assistant (minimise AI).
 *
 * Answer order:
 *   1. Pre-written library (matching.ts + entries.ts) — ZERO AI, unlimited.
 *   2. Emergency-number lookup from the resolved table — ZERO AI, unlimited.
 *   3. AI fallback (claude-haiku-4-5) — only for the long tail, and rate limited
 *      to 5/day (free) or 30/day (ALRT+) per the V1 product rules. This is the
 *      only path that spends money or the daily quota.
 *
 * Locked-rule enforcement carried over: App Check required, refusal handling,
 * no transcript logging (content-free counts only, §18), the assistant cannot
 * see the live feed (alert facts must be passed in as `context`/`nearbyAlerts`).
 * Also gated on the `agent_enabled` Remote Config kill switch (previously
 * declared but never enforced server-side, see remoteConfigGate.ts), and
 * grounds AI answers with citable, structured alert ids (see citations.ts)
 * rather than an opaque free-text blob.
 */
import * as admin from "firebase-admin";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import { logger } from "firebase-functions/v2";
import Anthropic from "@anthropic-ai/sdk";
import { loadSystemPrompt } from "./promptOverride";
import { loadEntries } from "./entriesLoader";
import { bestMatch, detectEmergencyLookup } from "./matching";
import { aliasesFromNames, loadEmergencyConfig } from "./emergencyOverrides";
import { isAgentEnabled } from "./remoteConfigGate";
import { extractUsedAlertIds } from "./citations";

const ANTHROPIC_API_KEY = defineSecret("ANTHROPIC_API_KEY");
const db = () => admin.firestore();

/** Cheapest model — the library handles the common questions; AI is the tail. */
const MODEL = "claude-haiku-4-5";
const MAX_TOKENS = 1000;

/**
 * Daily AI-question caps (master spec 28 Sep 2026, §14): ALRT Free 3,
 * ALRT + Individual (or its trial) 10, per LOCAL calendar day, once per
 * account. Group sponsorship never raises it, for members or the payer.
 * Supersedes the earlier 5/30 and 3/20 values.
 *
 * Counting unit (open decision R03, unchanged here): one unit per AI
 * fallback attempt that reaches the model call. Library and
 * emergency-number answers never count. Until R03 is decided, copy must
 * describe this honestly (it is not "successful answers").
 */
export const AI_DAILY_LIMIT = { free: 3, individual: 10 } as const;

/** A time zone may change at most once per this window (travel, DST-safe). */
const TZ_CHANGE_MIN_MS = 24 * 60 * 60 * 1000;

const MAX_QUESTION_CHARS = 2000;
const MAX_HISTORY_TURNS = 10;

/** Display names for the zero-AI emergency lookup. */
const ISO_NAMES: Record<string, string> = {
  AU: "Australia",
  NZ: "New Zealand",
  GB: "the United Kingdom",
  US: "the United States",
  CA: "Canada",
  IE: "Ireland",
  FR: "France",
  DE: "Germany",
};

/** One nearby alert the client is grounding this question in. `id` must be
 *  the app's stable alert id — it is echoed back in `referencedAlertIds`
 *  when the model cites it, never re-derived or trusted from model output. */
interface NearbyAlert {
  id: string;
  title: string;
  category?: string;
  severity?: string;
  source?: string;
}

interface AskRequest {
  question: string;
  history?: { role: "user" | "assistant"; content: string }[];
  emergencyNumber?: string;
  /** Structured grounding alerts (preferred - enables citations). */
  nearbyAlerts?: NearbyAlert[];
  /** Legacy free-text grounding, used only when `nearbyAlerts` is absent. */
  context?: string;
  language?: string;
  /** IANA time zone of the device, e.g. "Australia/Perth" (local day). */
  timeZone?: string;
  /** Fallback when the app can't name its zone: minutes east of UTC now. */
  utcOffsetMinutes?: number;
}

type Plan = "free" | "individual";
type Source = "library" | "emergency_lookup" | "ai";

/** True for a time zone Intl accepts (rejects junk and offsets). */
export function isValidTimeZone(tz: unknown): tz is string {
  if (typeof tz !== "string" || tz.length === 0 || tz.length > 64) return false;
  try {
    new Intl.DateTimeFormat("en-US", { timeZone: tz });
    return true;
  } catch {
    return false;
  }
}

/**
 * A zone the day can be counted in: a valid IANA name, or "offset:<min>"
 * built from the app's current UTC offset (-720..+840 minutes).
 */
export function zoneFromRequest(timeZone: unknown, utcOffsetMinutes: unknown): string | null {
  if (isValidTimeZone(timeZone)) return timeZone;
  if (
    typeof utcOffsetMinutes === "number" &&
    Number.isInteger(utcOffsetMinutes) &&
    utcOffsetMinutes >= -720 &&
    utcOffsetMinutes <= 840
  ) {
    return `offset:${utcOffsetMinutes}`;
  }
  return null;
}

/** YYYYMMDD of [d] in [timeZone] (server clock, never the device's). */
export function localDayKey(d: Date, timeZone: string): string {
  if (timeZone.startsWith("offset:")) {
    const shifted = new Date(d.getTime() + Number(timeZone.slice(7)) * 60_000);
    return `${shifted.getUTCFullYear()}${String(shifted.getUTCMonth() + 1).padStart(2, "0")}${String(
      shifted.getUTCDate()
    ).padStart(2, "0")}`;
  }
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(d);
  const get = (t: string) => parts.find((p) => p.type === t)?.value ?? "00";
  return `${get("year")}${get("month")}${get("day")}`;
}

/**
 * Personal plan from the backend-written mirror entitlements/{uid}
 * ({ individual, individualExpiresAt, version }). The backend is the only
 * writer and the only place that interprets store events; this function
 * never re-derives cancellation or expiry from RevenueCat. The legacy
 * `plan: "plus"` field is honoured only when the new fields are absent.
 */
async function planFor(uid: string): Promise<Plan> {
  const data = (await db().collection("entitlements").doc(uid).get()).data();
  if (!data) return "free";
  if (typeof data.individual === "boolean") {
    if (!data.individual) return "free";
    const exp = data.individualExpiresAt as number | null | undefined;
    return exp == null || exp > Date.now() ? "individual" : "free";
  }
  return data.plan === "plus" ? "individual" : "free";
}

/**
 * The time zone this account's day is counted in. A device may report a
 * new zone (travel), but the stored zone changes at most once per 24
 * hours, so hopping zones can't open extra "days".
 */
async function effectiveTimeZone(uid: string, reported: string | null): Promise<string> {
  const ref = db().collection("agentUsage").doc(uid);
  const usable = (z: string | undefined): z is string =>
    !!z && (z.startsWith("offset:") || isValidTimeZone(z));
  return db().runTransaction(async (txn) => {
    const snap = await txn.get(ref);
    const stored = snap.data()?.timeZone as string | undefined;
    const setAt = (snap.data()?.timeZoneSetAt as number | undefined) ?? 0;
    const now = Date.now();
    if (reported && reported !== stored) {
      if (!usable(stored) || now - setAt >= TZ_CHANGE_MIN_MS) {
        txn.set(ref, { timeZone: reported, timeZoneSetAt: now }, { merge: true });
        return reported;
      }
    }
    return usable(stored) ? stored : "UTC";
  });
}

/** Atomic AI-quota check + increment. Throws resource-exhausted at the cap. */
async function consumeAiQuota(uid: string, plan: Plan, timeZone: string): Promise<void> {
  const limit = AI_DAILY_LIMIT[plan];
  const ref = db()
    .collection("agentUsage")
    .doc(uid)
    .collection("days")
    .doc(localDayKey(new Date(), timeZone));
  await db().runTransaction(async (txn) => {
    const snap = await txn.get(ref);
    const count = (snap.data()?.aiCount as number | undefined) ?? 0;
    if (count >= limit) {
      throw new HttpsError(
        "resource-exhausted",
        plan === "individual"
          ? `You've used today's ${AI_DAILY_LIMIT.individual} Ask ALRT questions. They reset tomorrow.`
          : `You've used today's ${AI_DAILY_LIMIT.free} Ask ALRT questions. They reset tomorrow, or ALRT + Individual gives you ${AI_DAILY_LIMIT.individual} a day.`
      );
    }
    txn.set(
      ref,
      { aiCount: count + 1, timeZone, updatedAt: admin.firestore.FieldValue.serverTimestamp() },
      { merge: true }
    );
  });
}

function emergencyAnswer(
  iso: string,
  table: Readonly<Record<string, string>>,
  names: Readonly<Record<string, string>> = {}
): string | null {
  const number = table[iso];
  if (!number) return null;
  const name = names[iso] ?? ISO_NAMES[iso] ?? iso;
  return `In ${name}, the emergency number is ${number}. If you are in danger, call it now. ALRT is a helper, it does not contact emergency services for you.`;
}

function nearbyAlertsLine(alert: NearbyAlert): string {
  const parts = [alert.title, alert.category, alert.severity, alert.source].filter(
    (p): p is string => typeof p === "string" && p.trim() !== ""
  );
  return `  [${alert.id}] ${parts.join(" — ")}`;
}

/** Builds the per-request system context, and returns the ids of whatever
 *  structured alerts were actually included so the response can validate
 *  citations against them (an id the model invents is never trusted). */
function contextBlock(data: AskRequest): { text: string; sentAlertIds: string[] } {
  const validAlerts = (data.nearbyAlerts ?? []).filter(
    (a): a is NearbyAlert => typeof a?.id === "string" && a.id.trim() !== "" && typeof a?.title === "string"
  );

  const lines = ["Context for this question (not shown to the user):"];
  lines.push(
    data.emergencyNumber
      ? `- Resolved local emergency number: ${data.emergencyNumber}. Use this exact number when directing the user to emergency services.`
      : "- No emergency number was resolved for this user. Direct them to their local emergency number by region."
  );

  if (validAlerts.length > 0) {
    lines.push("- Nearby alerts the app is showing (id first, for citation only):");
    for (const alert of validAlerts) lines.push(nearbyAlertsLine(alert));
    lines.push(
      "- If your answer relies on one or more of the alerts above, end your reply " +
        "with a new final line formatted exactly as `USED_ALERT_IDS: id1,id2` using " +
        "only the ids given above, comma-separated, no other text on that line. " +
        "Omit this line entirely if you did not rely on any of them. Never invent " +
        "an id that was not given to you."
    );
  } else if (data.context && data.context.trim()) {
    // Legacy free-text grounding: no ids to cite against.
    lines.push(`- Nearby alerts the app is showing: ${data.context.trim()}`);
  } else {
    lines.push(
      "- No live alert context was provided. Do not state whether any area is affected; send the user to their in-app alerts and the live map."
    );
  }

  if (data.language) lines.push(`- Answer in this language: ${data.language}.`);
  return { text: lines.join("\n"), sentAlertIds: validAlerts.map((a) => a.id) };
}

export const askAlrt = onCall(
  { secrets: [ANTHROPIC_API_KEY], enforceAppCheck: true },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError("unauthenticated", "Sign in to use Ask ALRT.");

    const data = request.data as AskRequest;
    const question = (data?.question ?? "").trim();
    if (!question) throw new HttpsError("invalid-argument", "A question is required.");
    if (question.length > MAX_QUESTION_CHARS) throw new HttpsError("invalid-argument", "Question is too long.");

    // 1. Pre-written library (no AI, no quota). Seed + Firestore overrides.
    const entries = await loadEntries();
    const match = bestMatch(question, entries);
    if (match) {
      logger.info("ask_alrt_answered", { uid, source: "library" as Source, entry: match.entry.id });
      return { answer: match.entry.answer, source: "library" as Source, usedAI: false };
    }

    // 2. Emergency-number lookup from the resolved table (no AI, no quota).
    const emergency = await loadEmergencyConfig();
    const lookup = detectEmergencyLookup(question, aliasesFromNames(emergency.names));
    if (lookup) {
      const answer = emergencyAnswer(lookup.iso, emergency.table, emergency.names);
      if (answer) {
        logger.info("ask_alrt_answered", { uid, source: "emergency_lookup" as Source, iso: lookup.iso });
        return { answer, source: "emergency_lookup" as Source, usedAI: false };
      }
    }

    // 3. AI fallback — the only path that costs money or the daily quota.
    //    Gated on the `agent_enabled` Remote Config kill switch: the two
    //    zero-AI paths above (library, emergency lookup) stay up even when
    //    the AI fallback is switched off centrally.
    if (!(await isAgentEnabled())) {
      throw new HttpsError(
        "unavailable",
        "Ask ALRT's AI assistant is temporarily unavailable. Please try again soon."
      );
    }

    const plan = await planFor(uid);
    const timeZone = await effectiveTimeZone(
      uid,
      zoneFromRequest(data.timeZone, data.utcOffsetMinutes)
    );
    await consumeAiQuota(uid, plan, timeZone);

    const history = (data.history ?? [])
      .filter((m) => (m.role === "user" || m.role === "assistant") && typeof m.content === "string")
      .slice(-MAX_HISTORY_TURNS);

    const client = new Anthropic({ apiKey: ANTHROPIC_API_KEY.value() });
    const systemPrompt = await loadSystemPrompt();
    const { text: contextText, sentAlertIds } = contextBlock(data);

    let response;
    try {
      response = await client.messages.create({
        model: MODEL,
        max_tokens: MAX_TOKENS,
        system: [
          { type: "text", text: systemPrompt, cache_control: { type: "ephemeral" } },
          { type: "text", text: contextText },
        ],
        messages: [...history, { role: "user", content: question }],
      });
    } catch (err) {
      logger.error("Ask ALRT model call failed", { uid, error: (err as Error).message });
      throw new HttpsError("internal", "Ask ALRT is unavailable right now. Please try again.");
    }

    if (response.stop_reason === "refusal") {
      const category =
        (response as { stop_details?: { category?: string | null } }).stop_details?.category ?? null;
      logger.info("ask_alrt_refusal", { uid, category });
      return {
        answer:
          "I can't help with that one. If you're in danger, call your local emergency services now. For anything else about using ALRT, email contact@safetyalrt.com.",
        source: "ai" as Source,
        usedAI: true,
        refused: true,
      };
    }

    const rawAnswer = response.content
      .filter((b): b is Anthropic.TextBlock => b.type === "text")
      .map((b) => b.text)
      .join("")
      .trim();
    const { answer, usedAlertIds } = extractUsedAlertIds(rawAnswer, sentAlertIds);

    logger.info("ask_alrt_answered", {
      uid,
      source: "ai" as Source,
      plan,
      referencedAlertCount: usedAlertIds.length,
    });
    return {
      answer,
      source: "ai" as Source,
      usedAI: true,
      refused: false,
      referencedAlertIds: usedAlertIds,
    };
  }
);
