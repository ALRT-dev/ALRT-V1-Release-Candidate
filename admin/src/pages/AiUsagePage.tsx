import { useCallback, useMemo, useState } from "react";
import { useApiQuery } from "../hooks/useApiQuery";
import { LoadingState, EmptyState, ErrorState } from "../components/AsyncState";
import { listAIPrompts } from "../api/resources";
import { aiUsage, promptVersions } from "../api/safetyIntelligence";

/**
 * AI usage (P0, 16 Nov 2026). Every AI call is logged with its purpose and
 * tokens, never its text. Cost appears only when you enter today's price per
 * million tokens from the AWS price list: no figure is guessed.
 */
export const AiUsagePage = () => {
  const [days, setDays] = useState(14);
  const [price, setPrice] = useState({ input: "", output: "" });
  const fetcher = useCallback(
    () => aiUsage({ days, ...(price.input && price.output ? { inputPrice: Number(price.input), outputPrice: Number(price.output) } : {}) }),
    [days, price],
  );
  const { data, error, loading, refetch } = useApiQuery(fetcher, [days, price]);

  const byPurpose = useMemo(() => {
    const m = new Map<string, { calls: number; failed: number; inputTokens: number; outputTokens: number; costUsd: number }>();
    for (const r of data?.usage ?? []) {
      const x = m.get(r.purpose) ?? { calls: 0, failed: 0, inputTokens: 0, outputTokens: 0, costUsd: 0 };
      x.calls += r.calls; x.failed += r.failed; x.inputTokens += r.inputTokens; x.outputTokens += r.outputTokens; x.costUsd += r.costUsd ?? 0;
      m.set(r.purpose, x);
    }
    return [...m.entries()].sort((a, b) => b[1].calls - a[1].calls);
  }, [data]);

  const bySource = useMemo(() => {
    const m = new Map<string, Record<string, number>>();
    for (const a of data?.alertsByMethod ?? []) {
      const x = m.get(a.sourceId ?? "?") ?? {};
      x[a.method] = (x[a.method] ?? 0) + a.alerts;
      m.set(a.sourceId ?? "?", x);
    }
    return [...m.entries()];
  }, [data]);

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>AI Usage</h1>
          <p>What AI is used for, how many tokens it uses, and which sources still need it. The prompt and answer text are never stored.</p>
        </div>
      </div>
      <div className="toolbar">
        <label htmlFor="ai-days">Days</label>
        <select id="ai-days" value={days} onChange={(e) => setDays(Number(e.target.value))}>
          {[1, 7, 14, 30, 90].map((d) => <option key={d} value={d}>{d}</option>)}
        </select>
        <label htmlFor="ai-in">US$ per million input tokens</label>
        <input id="ai-in" style={{ width: 80 }} value={price.input} onChange={(e) => setPrice({ ...price, input: e.target.value })} />
        <label htmlFor="ai-out">output</label>
        <input id="ai-out" style={{ width: 80 }} value={price.output} onChange={(e) => setPrice({ ...price, output: e.target.value })} />
      </div>
      {loading && <LoadingState label="Loading usage..." />}
      {!loading && Boolean(error) && <ErrorState error={error} onRetry={refetch} />}
      {!loading && !error && data && byPurpose.length === 0 && <EmptyState label="No AI calls logged in this period." />}
      {!loading && !error && data && byPurpose.length > 0 && (
        <table className="data-table">
          <thead><tr><th>Purpose</th><th>Calls</th><th>Failed</th><th>Input tokens</th><th>Output tokens</th>{data.priced && <th>Cost (US$)</th>}</tr></thead>
          <tbody>
            {byPurpose.map(([p, x]) => (
              <tr key={p}><td>{p}</td><td>{x.calls}</td><td>{x.failed}</td><td>{x.inputTokens.toLocaleString()}</td><td>{x.outputTokens.toLocaleString()}</td>{data.priced && <td>{x.costUsd.toFixed(2)}</td>}</tr>
            ))}
          </tbody>
        </table>
      )}
      {!loading && !error && data && bySource.length > 0 && (
        <>
          <h2>How each source's alerts were written</h2>
          <table className="data-table">
            <thead><tr><th>Source</th><th>Template</th><th>Template first</th><th>AI</th><th>AI failed</th><th>Not recorded</th></tr></thead>
            <tbody>
              {bySource.map(([s, m]) => (
                <tr key={s}><td>{s}</td><td>{m.template ?? 0}</td><td>{m.template_first ?? 0}</td><td>{m.ai ?? 0}</td><td>{m.fallback ?? 0}</td><td>{m["not recorded"] ?? 0}</td></tr>
              ))}
            </tbody>
          </table>
        </>
      )}
      <PromptVersions />
    </div>
  );
};

const PromptVersions = () => {
  const prompts = useApiQuery(listAIPrompts, []);
  const [id, setId] = useState("");
  const fetcher = useCallback(() => (id ? promptVersions(id) : Promise.resolve([])), [id]);
  const versions = useApiQuery(fetcher, [id]);
  return (
    <div style={{ marginTop: 24 }}>
      <h2>Prompt versions</h2>
      <p style={{ fontSize: 13 }}>Every change to a prompt's words or model is a new version, so each alert can name the version that wrote it.</p>
      <select aria-label="Prompt" value={id} onChange={(e) => setId(e.target.value)}>
        <option value="">Choose a prompt</option>
        {(prompts.data ?? []).map((p) => <option key={p.id} value={p.id}>{p.name}</option>)}
      </select>
      {id && versions.data && (
        <table className="data-table" style={{ marginTop: 8 }}>
          <thead><tr><th>Version</th><th>Saved</th><th>Model</th><th>Words</th></tr></thead>
          <tbody>
            {versions.data.map((v) => (
              <tr key={v.id}><td>v{v.version}</td><td>{v.createdAt.slice(0, 16).replace("T", " ")}</td><td style={{ fontSize: 11 }}>{v.model || "default"}</td>
                <td><details><summary>{v.content.length} characters</summary><pre style={{ whiteSpace: "pre-wrap", fontSize: 11 }}>{v.content}</pre></details></td></tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
};
