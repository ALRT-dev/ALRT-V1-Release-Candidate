import { useState } from "react";
import { useApiQuery } from "../hooks/useApiQuery";
import { useAuth } from "../auth/AuthContext";
import { useToast } from "../components/ToastContext";
import { LoadingState, EmptyState, ErrorState } from "../components/AsyncState";
import { acknowledgeAssurance, listAssurance, runAssurance } from "../api/safetyIntelligence";

/**
 * Daily assurance (owner decision D3, 16 Nov 2026). n8n runs the checks every
 * morning at 6am Perth time and emails only when something fails. The checks
 * read; they never change an alert, a source or a record.
 */
const BADGE = { pass: "badge-success", warn: "badge-warning", fail: "badge-danger" } as const;

export const AssurancePage = () => {
  const { hasRole } = useAuth();
  const canRun = hasRole("superAdmin", "admin");
  const { notifySuccess, notifyError } = useToast();
  const { data, error, loading, refetch } = useApiQuery(listAssurance, []);
  const [busy, setBusy] = useState(false);
  const act = async (fn: () => Promise<unknown>, msg: string) => {
    setBusy(true);
    try { await fn(); notifySuccess(msg); refetch(); } catch (e) { notifyError(e instanceof Error ? e.message : String(e)); } finally { setBusy(false); }
  };
  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Daily Assurance</h1>
          <p>Sources, licences, review dates, movement words, display rules, coverage, AI use and Ask ALRT places, checked every day.</p>
        </div>
        {canRun && <button type="button" className="btn btn-primary" disabled={busy} onClick={() => act(runAssurance, "Checks run.")}>Run checks now</button>}
      </div>
      {loading && <LoadingState label="Loading reports..." />}
      {!loading && Boolean(error) && <ErrorState error={error} onRetry={refetch} />}
      {!loading && !error && data && data.length === 0 && <EmptyState label="No reports yet. Run the checks, or set up the n8n workflow (Webhook API Keys page)." />}
      {!loading && !error && data && data.map((r, i) => (
        <details key={r.id} className="card" style={{ marginBottom: 12 }} open={i === 0}>
          <summary style={{ cursor: "pointer" }}>
            <strong>{new Date(r.runAt).toLocaleString("en-AU", { timeZone: "Australia/Perth" })}</strong>{" "}
            <span className="badge badge-danger">{r.failures} failed</span> <span className="badge badge-warning">{r.warnings} warnings</span>{" "}
            <span className="badge badge-success">{r.passed} passed</span>{" "}
            {r.acknowledgedAt ? <span style={{ fontSize: 12 }}>acknowledged</span> : canRun && (
              <button type="button" className="btn btn-sm" disabled={busy} onClick={(e) => { e.preventDefault(); void act(() => acknowledgeAssurance(r.id), "Acknowledged."); }}>Acknowledge</button>
            )}
          </summary>
          <table className="data-table" style={{ marginTop: 8 }}>
            <tbody>
              {r.checks.map((c) => (
                <tr key={c.id}>
                  <td style={{ width: 70 }}><span className={`badge ${BADGE[c.status]}`}>{c.status}</span></td>
                  <td style={{ width: 220 }}><strong>{c.name}</strong></td>
                  <td>{c.detail}{c.items.length > 0 && <ul style={{ margin: "4px 0 0", fontSize: 12 }}>{c.items.map((x) => <li key={x}>{x}</li>)}</ul>}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </details>
      ))}
    </div>
  );
};
