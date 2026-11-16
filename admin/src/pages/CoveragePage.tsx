import { useCallback, useState } from "react";
import { useApiQuery } from "../hooks/useApiQuery";
import { useAuth } from "../auth/AuthContext";
import { useToast } from "../components/ToastContext";
import { LoadingState, ErrorState } from "../components/AsyncState";
import { guidanceCoverage, listLibraryGuides, publishGuide, type CoverageCell, type GuidanceKind } from "../api/safetyIntelligence";

/** Where the library has approved lines and where it has gaps (audit, 16 Nov 2026). */
const CELL: Record<CoverageCell, { label: string; bg: string; fg: string }> = {
  approved: { label: "Approved", bg: "var(--color-success-bg)", fg: "var(--color-success)" },
  draft: { label: "Draft", bg: "var(--color-warning-bg)", fg: "var(--color-warning)" },
  overdue: { label: "Review due", bg: "var(--color-danger-bg)", fg: "var(--color-danger)" },
  no_source: { label: "No source", bg: "var(--color-warning-bg)", fg: "var(--color-warning)" },
  empty: { label: "Empty", bg: "var(--color-pending-bg)", fg: "var(--color-text-muted)" },
};
const VIEWS: { label: string; kind: GuidanceKind; axis: "cohort" | "jurisdiction" }[] = [
  { label: "Safety Profile: hazards by group", kind: "profile", axis: "cohort" },
  { label: "Alert advice: hazards by place", kind: "advice", axis: "jurisdiction" },
  { label: "Learn guides: guides by place", kind: "guide_section", axis: "jurisdiction" },
  { label: "Ask ALRT answers by place", kind: "answer", axis: "jurisdiction" },
];

export const CoveragePage = () => {
  const [view, setView] = useState(0);
  const v = VIEWS[view]!;
  const fetcher = useCallback(() => guidanceCoverage(v.kind, v.axis), [v.kind, v.axis]);
  const { data, error, loading, refetch } = useApiQuery(fetcher, [view]);
  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Coverage</h1>
          <p>Which hazards have approved, sourced guidance for each group or place, and where the gaps are.</p>
        </div>
      </div>
      <div className="toolbar">
        <select aria-label="View" value={view} onChange={(e) => setView(Number(e.target.value))}>
          {VIEWS.map((x, i) => <option key={x.label} value={i}>{x.label}</option>)}
        </select>
        {Object.entries(CELL).map(([k, c]) => <span key={k} className="badge" style={{ background: c.bg, color: c.fg }}>{c.label}</span>)}
      </div>
      {loading && <LoadingState label="Loading coverage..." />}
      {!loading && Boolean(error) && <ErrorState error={error} onRetry={refetch} />}
      {!loading && !error && data && (
        <div style={{ overflowX: "auto" }}>
          <table className="data-table">
            <thead><tr><th>Hazard</th>{data.columns.map((c) => <th key={c}>{c}</th>)}</tr></thead>
            <tbody>
              {data.hazards.map((h) => (
                <tr key={h}>
                  <td><strong>{h}</strong></td>
                  {data.columns.map((c) => {
                    const cell = CELL[data.grid[h]?.[c] ?? "empty"];
                    return <td key={c} title={cell.label} style={{ background: cell.bg, color: cell.fg, fontSize: 11, textAlign: "center" }}>{cell.label}</td>;
                  })}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};

/** Learn guides built from approved library sections, published here. */
export const GuidesPage = () => {
  const { hasRole } = useAuth();
  const canPublish = hasRole("superAdmin", "admin");
  const { notifySuccess, notifyError } = useToast();
  const { data, error, loading, refetch } = useApiQuery(listLibraryGuides, []);
  const [place, setPlace] = useState("AU-WA");
  const publish = async (slug: string) => {
    try {
      const r = await publishGuide(slug, place);
      notifySuccess(`Published "${slug}" from ${r.sections} approved sections (${r.jurisdiction}, v${r.version}).`);
      refetch();
    } catch (e) {
      notifyError(e instanceof Error ? e.message : String(e));
    }
  };
  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Learn Guides</h1>
          <p>
            Guides are built from approved sections in the Guidance Library, with every source named. Publishing a
            replacement guide hides the guide it replaces. Guides published here are never overwritten by the app's seed.
          </p>
        </div>
      </div>
      <div className="toolbar">
        <label htmlFor="guide-place">Publish for</label>
        <input id="guide-place" value={place} onChange={(e) => setPlace(e.target.value.toUpperCase())} style={{ width: 90 }} />
        <span style={{ fontSize: 12 }}>The most specific approved sections win (AU-WA, then AU).</span>
      </div>
      {loading && <LoadingState label="Loading guides..." />}
      {!loading && Boolean(error) && <ErrorState error={error} onRetry={refetch} />}
      {!loading && !error && data && (
        <table className="data-table">
          <thead><tr><th>Guide</th><th>Sections</th><th>Places</th><th>Status</th><th /></tr></thead>
          <tbody>
            {data.map((g) => (
              <tr key={g.slug}>
                <td><strong>{g.title}</strong><div style={{ fontSize: 11 }}>{g.slug}</div></td>
                <td>{g.approvedSections} approved{g.pendingSections ? `, ${g.pendingSections} waiting` : ""}</td>
                <td>{g.jurisdictions.join(", ")}</td>
                <td>
                  <span className={`badge ${g.isPublished ? "badge-success" : "badge-pending"}`}>{g.isPublished ? "Live" : "Not live"}</span>
                  {g.fromLibrary && <span className="badge badge-success" style={{ marginLeft: 4 }}>from library</span>}
                </td>
                <td>{canPublish && <button type="button" className="btn btn-sm btn-primary" disabled={!g.approvedSections} onClick={() => publish(g.slug)}>Publish</button>}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
};
