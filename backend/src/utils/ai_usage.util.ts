import { AsyncLocalStorage } from "node:async_hooks";

const tracker = new AsyncLocalStorage<{ calls: number; purposes: string[] }>();

/** Runs [fn] and reports how many AI calls it made (for per-alert traceability). */
export const withAiTracking = async <T>(fn: () => Promise<T>): Promise<{ result: T; aiCalls: number; purposes: string[] }> => {
  const store = { calls: 0, purposes: [] as string[] };
  const result = await tracker.run(store, fn);
  return { result, aiCalls: store.calls, purposes: store.purposes };
};

/**
 * AI usage log (P0, owner 16 Nov 2026). One row per AI call: what it was for
 * and how many tokens it used. Never the prompt or the answer. Logging must
 * never break or slow an alert, so it is fire-and-forget and swallows errors.
 */
export type AiPurpose =
  | "alert_summary"
  | "category"
  | "locations"
  | "report_review"
  | "si_extraction"
  | "ask_alrt"
  | "assurance"
  | "model_check"
  | "unspecified";

export interface AiUsageTag {
  purpose?: AiPurpose;
  sourceId?: string | null;
}

export interface AiUsageRecord extends AiUsageTag {
  provider: "bedrock" | "openai";
  model: string;
  inputTokens?: number | undefined;
  outputTokens?: number | undefined;
  cacheReadTokens?: number | undefined;
  durationMs: number;
  ok: boolean;
}

const toInt = (n: unknown): number =>
  typeof n === "number" && Number.isFinite(n) && n > 0 ? Math.round(n) : 0;

export const buildAiUsageRow = (r: AiUsageRecord) => ({
  purpose: r.purpose ?? "unspecified",
  provider: r.provider,
  model: r.model.slice(0, 200),
  sourceId: r.sourceId ?? null,
  inputTokens: toInt(r.inputTokens),
  outputTokens: toInt(r.outputTokens),
  cacheReadTokens: toInt(r.cacheReadTokens),
  durationMs: toInt(r.durationMs),
  ok: r.ok,
});

export const recordAiUsage = (r: AiUsageRecord): void => {
  const store = tracker.getStore();
  if (store) {
    store.calls += 1;
    store.purposes.push(r.purpose ?? "unspecified");
  }
  // Loaded lazily so the AI services stay importable without a database.
  void import("./prisma_client.util.js")
    .then(({ default: prisma }) => (prisma as any).aiUsageEvent?.create({ data: buildAiUsageRow(r) }))
    .catch((err: unknown) => console.warn("ai_usage: could not record", (err as Error)?.message));
};

/** Cost from tokens and the admin-entered price per million tokens. */
export const costFor = (
  tokens: { inputTokens: number; outputTokens: number },
  pricePerMillion: { input: number; output: number },
): number =>
  (tokens.inputTokens * pricePerMillion.input + tokens.outputTokens * pricePerMillion.output) / 1_000_000;

/**
 * How an alert's words were produced, stored on the alert so any line can be
 * traced back to a template or a prompt version.
 */
export const describeExtraction = ({
  aiCalls,
  sourceId,
  templateVersion,
  templateFirstSourceIds,
  fixedTemplateSourceIds,
  failed = false,
}: {
  aiCalls: number;
  sourceId?: string | null;
  templateVersion?: number | null;
  templateFirstSourceIds: ReadonlySet<string> | readonly string[];
  fixedTemplateSourceIds: ReadonlySet<string> | readonly string[];
  failed?: boolean;
}): { extractionMethod: string; extractionRef: string } => {
  const v = `templates@v${templateVersion ?? 0}`;
  const has = (list: ReadonlySet<string> | readonly string[], id: string) =>
    list instanceof Set ? list.has(id) : (list as readonly string[]).includes(id);
  if (failed) return { extractionMethod: "fallback", extractionRef: v };
  if (aiCalls > 0) return { extractionMethod: "ai", extractionRef: `prompt:summarize+${v}` };
  if (sourceId && has(fixedTemplateSourceIds, sourceId)) return { extractionMethod: "template", extractionRef: `${sourceId}_template+${v}` };
  if (sourceId && has(templateFirstSourceIds, sourceId)) return { extractionMethod: "template_first", extractionRef: `template_first+${v}` };
  return { extractionMethod: "template", extractionRef: v };
};

/** Sources whose alerts are written by a fixed template, never AI. */
export const FIXED_TEMPLATE_SOURCE_IDS = ["waDfes", "rfs", "nswSes", "waqi", "openMeteo", "gdacsGlobal", "earthquakeUsgs", "actEs", "nswTransport"] as const;
