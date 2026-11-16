import { useCallback, useState } from "react";
import { useApiQuery } from "../hooks/useApiQuery";
import { useAuth } from "../auth/AuthContext";
import { useToast } from "../components/ToastContext";
import { LoadingState, EmptyState, ErrorState } from "../components/AsyncState";
import {
  approveGuidance, createGuidance, importGuidance, listGuidance, retireGuidance, sendGuidanceToTemplates, submitGuidance,
  updateGuidance, type GuidanceInput, type GuidanceKind, type GuidanceRecord,
} from "../api/safetyIntelligence";

/**
 * The one approved guidance library (owner decisions D2, D4, D5, 16 Nov
 * 2026). Alerts, Safety Profile, Learn and Ask ALRT all read approved
 * records from here. Every record names its source, place and version.
 * Reviewers draft and send for review; admins approve. Approving a new
 * version retires the one it replaces.
 */
const KINDS: { value: GuidanceKind | ""; label: string }[] = [
  { value: "", label: "All kinds" },
  { value: "advice", label: "Alert advice" },
  { value: "profile", label: "Safety Profile line" },
  { value: "guide_section", label: "Learn guide section" },
  { value: "answer", label: "Ask ALRT answer" },
  { value: "country_fact", label: "Country fact" },
];
const KIND_LABEL = Object.fromEntries(KINDS.map((k) => [k.value, k.label]));
const STATUSES = ["", "draft", "in_review", "approved", "retired"];
const STATUS_BADGE: Record<string, string> = { approved: "badge-success", draft: "badge-pending", in_review: "badge-warning", retired: "badge-danger" };
const COHORTS = ["older", "kids", "mobility", "medical", "deaf", "vision", "visitor", "worker", "pets"];

const blank = (): GuidanceInput => ({ kind: "advice", jurisdiction: "AU", text: "", sourceAgency: "", sourceUrl: "" });

export const GuidanceLibraryPage = () => {
  const { hasRole } = useAuth();
  const canApprove = hasRole("superAdmin", "admin");
  const canDraft = hasRole("superAdmin", "admin", "reviewer");
  const { notifySuccess, notifyError } = useToast();
  const [filters, setFilters] = useState({ kind: "", status: "", hazard: "", jurisdiction: "", q: "" });
  const [page, setPage] = useState(1);
  const [editing, setEditing] = useState<{ id?: string; form: GuidanceInput } | null>(null);
  const [busy, setBusy] = useState(false);

  const fetcher = useCallback(() => listGuidance({ ...filters, page }), [filters, page]);
  const { data, error, loading, refetch } = useApiQuery(fetcher, [filters, page]);
  const set = (k: keyof typeof filters, v: string) => { setFilters((f) => ({ ...f, [k]: v })); setPage(1); };

  const act = async (label: string, fn: () => Promise<unknown>) => {
    setBusy(true);
    try {
      const out = await fn();
      notifySuccess(typeof out === "string" ? out : label);
      refetch();
    } catch (e) {
      notifyError(e instanceof Error ? e.message : String(e));
    } finally {
      setBusy(false);
    }
  };

  const edit = (r: GuidanceRecord) =>
    setEditing({
      id: r.status === "draft" || r.status === "in_review" ? r.id : undefined,
      form: {
        key: r.key, kind: r.kind, hazard: r.hazard, cohort: r.cohort, stage: r.stage, jurisdiction: r.jurisdiction, title: r.title,
        text: r.text, longText: r.longText, triggers: r.triggers, sourceAgency: r.sourceAgency, sourceUrl: r.sourceUrl, licence: r.licence,
        changeNote: "",
      },
    });

  const save = () =>
    editing &&
    act(editing.id ? "Draft saved." : "New draft version created.", async () => {
      await (editing.id ? updateGuidance(editing.id, editing.form) : createGuidance(editing.form));
      setEditing(null);
    });

  const f = editing?.form;
  const setForm = (patch: Partial<GuidanceInput>) => setEditing((e) => (e ? { ...e, form: { ...e.form, ...patch } } : e));

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Guidance Library</h1>
          <p>
            One approved library for alert advice, Safety Profile lines, Learn guides and Ask ALRT answers. Every line
            names its official source, the place it applies to and its version. ALRT's own lines never tell people to
            leave, evacuate, shelter, stay or return.
          </p>
        </div>
        <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
          {canDraft && <button type="button" className="btn btn-primary" onClick={() => setEditing({ form: blank() })}>New record</button>}
          {canApprove && (
            <button type="button" className="btn" disabled={busy} onClick={() => act("Imported.", async () => {
              const r = await importGuidance();
              return `Imported ${r.added} records (${r.skipped} already there), ${r.draftsForReview} drafted guide sections for review, ${r.countriesAdded} countries.`;
            })}>Import existing content</button>
          )}
          {canApprove && (
            <button type="button" className="btn" disabled={busy} onClick={() => act("Sent.", async () => {
              const r = await sendGuidanceToTemplates();
              return `${r.sent} approved lines are in the Alert Templates draft (${r.skipped.length} not mapped to alert categories). Publish Alert Templates to put them live.`;
            })}>Send approved lines to Alert Templates</button>
          )}
        </div>
      </div>

      <div className="card" style={{ marginBottom: 16, fontSize: 13 }}>
        <strong>How it goes live.</strong> Alert advice and Safety Profile lines: approve here, then <em>Send approved lines to
        Alert Templates</em>, then publish on the Alert Templates page (one publish button and one rollback for everything alerts
        show). Learn guides: approve the sections, then publish the guide on the Guides page. Ask ALRT answers and country facts are
        used as soon as they are approved.
      </div>

      <div className="toolbar">
        <select aria-label="Kind" value={filters.kind} onChange={(e) => set("kind", e.target.value)}>
          {KINDS.map((k) => <option key={k.value} value={k.value}>{k.label}</option>)}
        </select>
        <select aria-label="Status" value={filters.status} onChange={(e) => set("status", e.target.value)}>
          {STATUSES.map((s) => <option key={s} value={s}>{s ? s.replace("_", " ") : "Not retired"}</option>)}
        </select>
        <input type="search" placeholder="Hazard (e.g. bushfire)" value={filters.hazard} onChange={(e) => set("hazard", e.target.value)} />
        <input type="search" placeholder="Place (AU, AU-WA, ID)" value={filters.jurisdiction} onChange={(e) => set("jurisdiction", e.target.value)} />
        <input type="search" placeholder="Search text" value={filters.q} onChange={(e) => set("q", e.target.value)} />
      </div>

      {editing && f && (
        <div className="card" style={{ marginBottom: 16 }}>
          <h2 style={{ marginTop: 0 }}>{editing.id ? "Edit draft" : f.key ? `New version of ${f.key}` : "New record"}</h2>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))", gap: 12 }}>
            <label>Kind
              <select value={f.kind} disabled={Boolean(f.key)} onChange={(e) => setForm({ kind: e.target.value as GuidanceKind })}>
                {KINDS.filter((k) => k.value).map((k) => <option key={k.value} value={k.value}>{k.label}</option>)}
              </select>
            </label>
            <label>Hazard<input value={f.hazard ?? ""} onChange={(e) => setForm({ hazard: e.target.value })} placeholder="bushfire, flood, smoke-air-quality" /></label>
            {f.kind === "profile" && (
              <label>Group
                <select value={f.cohort ?? ""} onChange={(e) => setForm({ cohort: e.target.value })}>
                  <option value="">Choose</option>
                  {COHORTS.map((c) => <option key={c} value={c}>{c}</option>)}
                </select>
              </label>
            )}
            <label>Stage
              <select value={f.stage ?? ""} onChange={(e) => setForm({ stage: e.target.value || null })}>
                <option value="">Any</option><option value="before">Before</option><option value="during">During</option><option value="after">After</option>
              </select>
            </label>
            <label>Place<input value={f.jurisdiction ?? "AU"} onChange={(e) => setForm({ jurisdiction: e.target.value.toUpperCase() })} placeholder="AU, AU-WA, ID, *" /></label>
            <label>Title<input value={f.title ?? ""} onChange={(e) => setForm({ title: e.target.value })} /></label>
          </div>
          <label style={{ display: "block", marginTop: 12 }}>Text
            <textarea rows={4} style={{ width: "100%" }} value={f.text} onChange={(e) => setForm({ text: e.target.value })} />
          </label>
          {f.kind === "answer" && (
            <label style={{ display: "block", marginTop: 12 }}>Questions it answers (one per line)
              <textarea rows={3} style={{ width: "100%" }} value={(f.triggers ?? []).join("\n")} onChange={(e) => setForm({ triggers: e.target.value.split("\n") })} />
            </label>
          )}
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(260px, 1fr))", gap: 12, marginTop: 12 }}>
            <label>Official source<input value={f.sourceAgency} onChange={(e) => setForm({ sourceAgency: e.target.value })} placeholder="DFES" /></label>
            <label>Source page (https://, the exact page)<input value={f.sourceUrl} onChange={(e) => setForm({ sourceUrl: e.target.value })} /></label>
            <label>Licence<input value={f.licence ?? ""} onChange={(e) => setForm({ licence: e.target.value })} placeholder="CC BY 4.0" /></label>
            <label>What changed and why<input value={f.changeNote ?? ""} onChange={(e) => setForm({ changeNote: e.target.value })} /></label>
          </div>
          <div style={{ display: "flex", gap: 8, marginTop: 12 }}>
            <button type="button" className="btn btn-primary" disabled={busy} onClick={save}>Save draft</button>
            <button type="button" className="btn" onClick={() => setEditing(null)}>Cancel</button>
          </div>
        </div>
      )}

      {loading && <LoadingState label="Loading library..." />}
      {!loading && Boolean(error) && <ErrorState error={error} onRetry={refetch} />}
      {!loading && !error && data && data.items.length === 0 && (
        <EmptyState label="Nothing here yet. Use Import existing content to bring in today's advice, profile lines, guides and answers." />
      )}
      {!loading && !error && data && data.items.length > 0 && (
        <>
          <table className="data-table">
            <thead>
              <tr><th>What</th><th>Text</th><th>Source</th><th>Version</th><th>Checks</th><th /></tr>
            </thead>
            <tbody>
              {data.items.map((r) => (
                <tr key={r.id}>
                  <td style={{ fontSize: 12 }}>
                    <div><strong>{KIND_LABEL[r.kind]}</strong></div>
                    <div>{[r.hazard, r.cohort, r.stage].filter(Boolean).join(" · ")}</div>
                    <div>{r.jurisdiction}</div>
                  </td>
                  <td style={{ maxWidth: 420 }}>{r.title && <div><strong>{r.title}</strong></div>}{r.text}</td>
                  <td style={{ fontSize: 12 }}>
                    {r.sourceUrl ? <a href={r.sourceUrl} target="_blank" rel="noreferrer">{r.sourceAgency}</a> : <>{r.sourceAgency}<div className="badge badge-warning">no page link</div></>}
                  </td>
                  <td style={{ fontSize: 12 }}>
                    v{r.version} <span className={`badge ${STATUS_BADGE[r.status]}`}>{r.status.replace("_", " ")}</span>
                    {r.nextReviewAt && <div>review by {r.nextReviewAt.slice(0, 10)}</div>}
                  </td>
                  <td style={{ fontSize: 12, maxWidth: 220 }}>
                    {r.check.errors.map((e) => <div key={e} style={{ color: "var(--color-danger)" }}>{e}</div>)}
                    {r.check.warnings.map((w) => <div key={w} style={{ color: "var(--color-warning)" }}>{w}</div>)}
                    {!r.check.errors.length && !r.check.warnings.length && "OK"}
                  </td>
                  <td style={{ whiteSpace: "nowrap" }}>
                    {canDraft && r.status !== "retired" && <button type="button" className="btn btn-sm" onClick={() => edit(r)}>{r.status === "approved" ? "New version" : "Edit"}</button>}
                    {canDraft && r.status === "draft" && <button type="button" className="btn btn-sm" disabled={busy} onClick={() => act("Sent for review.", () => submitGuidance(r.id))}>Send for review</button>}
                    {canApprove && (r.status === "draft" || r.status === "in_review") && (
                      <button type="button" className="btn btn-sm btn-primary" disabled={busy || r.check.errors.length > 0} onClick={() => act("Approved.", () => approveGuidance(r.id))}>Approve</button>
                    )}
                    {canApprove && r.status === "approved" && (
                      <button type="button" className="btn btn-sm btn-danger" disabled={busy} onClick={() => {
                        const reason = window.prompt("Why retire this line?") ?? undefined;
                        if (reason !== undefined) void act("Retired.", () => retireGuidance(r.id, reason));
                      }}>Retire</button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          <div className="toolbar">
            <button type="button" className="btn btn-sm" disabled={page <= 1} onClick={() => setPage(page - 1)}>Previous</button>
            <span>Page {data.page} of {Math.max(1, Math.ceil(data.total / data.pageSize))} ({data.total} records)</span>
            <button type="button" className="btn btn-sm" disabled={page * data.pageSize >= data.total} onClick={() => setPage(page + 1)}>Next</button>
          </div>
        </>
      )}
    </div>
  );
};
