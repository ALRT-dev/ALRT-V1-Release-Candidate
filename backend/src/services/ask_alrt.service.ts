import { Prisma } from "@prisma/client";
import prisma from "../utils/prisma_client.util.js";
import { HttpError } from "../models/http_error.js";
import { getPersonalAccess } from "./entitlement.service.js";
import { executeChat } from "./bedrock.service.js";
import { bestMatch, detectEmergencyLookup, type KnowledgeEntry } from "./ask_alrt/matching.js";
import {
  aliasesFromNames,
  contextBlock,
  emergencyAnswer,
  mergeEntries,
  readSavedEmergency,
  resolveEmergency,
  type AskRequest,
} from "./ask_alrt/rules.js";
import { extractUsedAlertIds } from "./ask_alrt/citations.js";
import { ASK_ALRT_SYSTEM_PROMPT } from "./ask_alrt/system_prompt.js";
import {
  AI_DAILY_LIMIT,
  TZ_CHANGE_MIN_MS,
  isUsableZone,
  limitMessage,
  localDayKey,
  zoneFromRequest,
  type AskPlan,
} from "./ask_alrt/quota.js";

export type { AskRequest, NearbyAlert } from "./ask_alrt/rules.js";

/**
 * Ask ALRT, inside the backend.
 *
 * Answer order (same as the retired Firebase function):
 *   1. Pre-written library, zero AI.
 *   2. Emergency-number lookup, zero AI.
 *   3. AI fallback (Claude Haiku on Bedrock), the only path that spends money.
 * Every answer counts as one question against the person's daily allowance.
 * Nothing the person types is stored: only a count per day.
 */

const MAX_QUESTION_CHARS = 2000;
const MAX_HISTORY_TURNS = 10;

export type AskSource = "library" | "emergency_lookup" | "ai";

export interface AskResponse {
  answer: string;
  source: AskSource;
  usedAI: boolean;
  refused?: boolean;
  referencedAlertIds?: string[];
  remainingToday?: number;
}

// --- Cached settings (5 minutes, cleared on every admin save) ---------------

const CACHE_TTL_MS = 5 * 60 * 1000;
interface Cached<T> {
  at: number;
  value: T;
}
let entriesCache: Cached<KnowledgeEntry[]> | null = null;
let emergencyCache: Cached<{ table: Record<string, string>; names: Record<string, string> }> | null = null;
let promptCache: Cached<string> | null = null;
let agentCache: Cached<boolean> | null = null;

export const clearAskAlrtCache = (): void => {
  entriesCache = null;
  emergencyCache = null;
  promptCache = null;
  agentCache = null;
};

const fresh = <T>(c: Cached<T> | null): c is Cached<T> => !!c && Date.now() - c.at < CACHE_TTL_MS;

const loadEntries = async (): Promise<KnowledgeEntry[]> => {
  if (fresh(entriesCache)) return entriesCache.value;
  try {
    const rows = await prisma.askAlrtEntry.findMany();
    const value = mergeEntries(rows);
    entriesCache = { at: Date.now(), value };
    return value;
  } catch (error) {
    console.warn(`[ask-alrt] answer library load failed, using built-in answers: ${(error as Error).message}`);
    return mergeEntries([]);
  }
};

const loadEmergency = async () => {
  if (fresh(emergencyCache)) return emergencyCache.value;
  try {
    const row = await prisma.askAlrtConfig.findUnique({ where: { key: "emergencyNumbers" } });
    const value = resolveEmergency(readSavedEmergency(row?.value));
    emergencyCache = { at: Date.now(), value };
    return value;
  } catch (error) {
    console.warn(`[ask-alrt] emergency numbers load failed, using starting list: ${(error as Error).message}`);
    return resolveEmergency({ numbers: {}, names: {} });
  }
};

const loadSystemPrompt = async (): Promise<string> => {
  if (fresh(promptCache)) return promptCache.value;
  try {
    const row = await prisma.askAlrtConfig.findUnique({ where: { key: "systemPrompt" } });
    const text = (row?.value as { text?: unknown } | null)?.text;
    const value = typeof text === "string" && text.trim() ? text : ASK_ALRT_SYSTEM_PROMPT;
    promptCache = { at: Date.now(), value };
    return value;
  } catch {
    return ASK_ALRT_SYSTEM_PROMPT;
  }
};

/** AI kill switch: env ASK_ALRT_AI_ENABLED=false, or the saved "agent" setting. Fails open. */
export const isAiEnabled = async (): Promise<boolean> => {
  if ((process.env.ASK_ALRT_AI_ENABLED ?? "").trim().toLowerCase() === "false") return false;
  if (fresh(agentCache)) return agentCache.value;
  try {
    const row = await prisma.askAlrtConfig.findUnique({ where: { key: "agent" } });
    const enabled = (row?.value as { enabled?: unknown } | null)?.enabled !== false;
    agentCache = { at: Date.now(), value: enabled };
    return enabled;
  } catch {
    return true;
  }
};

// --- Allowance --------------------------------------------------------------

const planFor = async (userId: string): Promise<AskPlan> =>
  (await getPersonalAccess(userId)).plan === "individual" ? "individual" : "free";

/** The zone a person's day is counted in; it may change once per 24 hours. */
const effectiveTimeZone = async (userId: string, reported: string | null): Promise<string> => {
  const row = await prisma.askAlrtZone.findUnique({ where: { userId } });
  const stored = row?.timeZone;
  const now = Date.now();
  if (reported && reported !== stored) {
    if (!isUsableZone(stored) || !row || now - row.setAt.getTime() >= TZ_CHANGE_MIN_MS) {
      await prisma.askAlrtZone.upsert({
        where: { userId },
        create: { userId, timeZone: reported, setAt: new Date(now) },
        update: { timeZone: reported, setAt: new Date(now) },
      });
      return reported;
    }
  }
  return isUsableZone(stored) ? stored : "UTC";
};

/** Atomic check-and-add. Returns the new count, or null when already at the cap. */
const consumeQuota = async (userId: string, plan: AskPlan, timeZone: string): Promise<number | null> => {
  const limit = AI_DAILY_LIMIT[plan];
  const dayKey = localDayKey(new Date(), timeZone);
  const rows = await prisma.$queryRaw<{ aiCount: number }[]>(Prisma.sql`
    INSERT INTO "AskAlrtUsage" ("userId", "dayKey", "aiCount", "updatedAt")
    VALUES (${userId}, ${dayKey}, 1, NOW())
    ON CONFLICT ("userId", "dayKey") DO UPDATE
      SET "aiCount" = "AskAlrtUsage"."aiCount" + 1, "updatedAt" = NOW()
      WHERE "AskAlrtUsage"."aiCount" < ${limit}
    RETURNING "aiCount"
  `);
  return rows[0]?.aiCount ?? null;
};

const requireQuota = async (userId: string, plan: AskPlan, timeZone: string): Promise<number> => {
  const count = await consumeQuota(userId, plan, timeZone);
  if (count === null) throw new HttpError(429, limitMessage(plan));
  return count;
};

const atDailyCap = async (userId: string, plan: AskPlan, timeZone: string): Promise<boolean> => {
  const row = await prisma.askAlrtUsage.findUnique({
    where: { userId_dayKey: { userId, dayKey: localDayKey(new Date(), timeZone) } },
  });
  return (row?.aiCount ?? 0) >= AI_DAILY_LIMIT[plan];
};

const refundQuota = async (userId: string, timeZone: string): Promise<void> => {
  await prisma.$executeRaw(Prisma.sql`
    UPDATE "AskAlrtUsage" SET "aiCount" = GREATEST("aiCount" - 1, 0), "updatedAt" = NOW()
    WHERE "userId" = ${userId} AND "dayKey" = ${localDayKey(new Date(), timeZone)}
  `);
};

/** How many questions are left today (for the app's counter). */
export const getAskAlrtAllowance = async (
  userId: string,
  reportedZone: string | null,
): Promise<{ limit: number; used: number; remaining: number }> => {
  const plan = await planFor(userId);
  const timeZone = await effectiveTimeZone(userId, reportedZone);
  const row = await prisma.askAlrtUsage.findUnique({
    where: { userId_dayKey: { userId, dayKey: localDayKey(new Date(), timeZone) } },
  });
  const limit = AI_DAILY_LIMIT[plan];
  const used = Math.min(row?.aiCount ?? 0, limit);
  return { limit, used, remaining: limit - used };
};

// --- Answering --------------------------------------------------------------

const REFUSAL_ANSWER =
  "I can't help with that one. If you're in danger, call your local emergency services now. For anything else about using ALRT, email contact@safetyalrt.com.";

/**
 * Answers one question for [userId]. The Admin Portal test page passes null
 * so it never touches a person's allowance.
 */
export const askAlrt = async (
  userId: string | null,
  data: AskRequest,
): Promise<AskResponse> => {
  const question = (data?.question ?? "").trim();
  if (!question) throw new HttpError(400, "A question is required.");
  if (question.length > MAX_QUESTION_CHARS) throw new HttpError(400, "Question is too long.");

  // Admin test asks (userId null) are unlimited and counted nowhere.
  const plan: AskPlan = userId ? await planFor(userId) : "individual";
  const timeZone = userId
    ? await effectiveTimeZone(userId, zoneFromRequest(data.timeZone, data.utcOffsetMinutes))
    : "UTC";
  const count = async (): Promise<number | undefined> =>
    userId ? AI_DAILY_LIMIT[plan] - (await requireQuota(userId, plan, timeZone)) : undefined;

  // 1. Library
  const match = bestMatch(question, await loadEntries());
  if (match) {
    const remainingToday = await count();
    console.log(JSON.stringify({ event: "ask_alrt_answered", source: "library", entry: match.entry.id }));
    return { answer: match.entry.answer, source: "library", usedAI: false, ...(remainingToday !== undefined && { remainingToday }) };
  }

  // 2. Emergency number lookup. At the cap the number is still shown, uncounted.
  const emergency = await loadEmergency();
  const lookup = detectEmergencyLookup(question, aliasesFromNames(emergency.names));
  if (lookup) {
    const answer = emergencyAnswer(lookup.iso, emergency.table, emergency.names);
    if (answer) {
      let remainingToday: number | undefined;
      if (userId) {
        if (await atDailyCap(userId, plan, timeZone)) {
          remainingToday = 0;
        } else {
          const used = await consumeQuota(userId, plan, timeZone);
          remainingToday = used === null ? 0 : AI_DAILY_LIMIT[plan] - used;
        }
      }
      console.log(JSON.stringify({ event: "ask_alrt_answered", source: "emergency_lookup", iso: lookup.iso }));
      return { answer, source: "emergency_lookup", usedAI: false, ...(remainingToday !== undefined && { remainingToday }) };
    }
  }

  // 3. AI fallback
  if (!(await isAiEnabled())) {
    throw new HttpError(503, "Ask ALRT's AI assistant is temporarily unavailable. Please try again soon.");
  }
  const remainingToday = await count();

  const history = (data.history ?? [])
    .filter((m) => (m?.role === "user" || m?.role === "assistant") && typeof m.content === "string")
    .slice(-MAX_HISTORY_TURNS);
  const { text: contextText, sentAlertIds } = contextBlock(data);

  let result;
  try {
    result = await executeChat({
      systemBlocks: [await loadSystemPrompt(), contextText],
      turns: [...history, { role: "user", content: question }],
    });
  } catch (error) {
    if (userId) await refundQuota(userId, timeZone).catch(() => undefined);
    console.error(`[ask-alrt] model call failed: ${(error as Error).message}`);
    throw new HttpError(502, "Ask ALRT is unavailable right now. Please try again.");
  }

  if (result.refused) {
    console.log(JSON.stringify({ event: "ask_alrt_refusal" }));
    return { answer: REFUSAL_ANSWER, source: "ai", usedAI: true, refused: true, ...(remainingToday !== undefined && { remainingToday }) };
  }

  const { answer, usedAlertIds } = extractUsedAlertIds(result.text, sentAlertIds);
  console.log(JSON.stringify({ event: "ask_alrt_answered", source: "ai", plan, referencedAlertCount: usedAlertIds.length }));
  return {
    answer,
    source: "ai",
    usedAI: true,
    refused: false,
    referencedAlertIds: usedAlertIds,
    ...(remainingToday !== undefined && { remainingToday }),
  };
};
