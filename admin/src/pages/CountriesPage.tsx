import { useState } from "react";
import { useApiQuery } from "../hooks/useApiQuery";
import { useAuth } from "../auth/AuthContext";
import { useToast } from "../components/ToastContext";
import { LoadingState, EmptyState, ErrorState } from "../components/AsyncState";
import { listCountries, saveCountry, type CountryProfile } from "../api/safetyIntelligence";

/**
 * One country register (D2, 16 Nov 2026), replacing the three emergency
 * number copies. Ask ALRT reads approved records. Approving needs the
 * official source page.
 */
export const CountriesPage = () => {
  const { hasRole } = useAuth();
  const canEdit = hasRole("superAdmin", "admin");
  const { notifySuccess, notifyError } = useToast();
  const { data, error, loading, refetch } = useApiQuery(listCountries, []);
  const [editing, setEditing] = useState<Partial<CountryProfile> & { code: string } | null>(null);
  const save = async (status: "draft" | "approved") => {
    if (!editing) return;
    try {
      await saveCountry(editing.code, { ...editing, status });
      notifySuccess(`${editing.name ?? editing.code} saved as ${status}.`);
      setEditing(null);
      refetch();
    } catch (e) {
      notifyError(e instanceof Error ? e.message : String(e));
    }
  };
  const field = (k: keyof CountryProfile, label: string, ph = "") => (
    <label>{label}<input value={String(editing?.[k] ?? "")} placeholder={ph} onChange={(e) => setEditing((c) => (c ? { ...c, [k]: e.target.value } : c))} /></label>
  );
  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Countries</h1>
          <p>One record per country (and Australian state), with the official source. Ask ALRT uses approved numbers.</p>
        </div>
        {canEdit && <button type="button" className="btn btn-primary" onClick={() => setEditing({ code: "", status: "draft" })}>Add country</button>}
      </div>
      {editing && (
        <div className="card" style={{ marginBottom: 16 }}>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))", gap: 12 }}>
            {field("code", "Code", "ID or AU-WA")}
            {field("name", "Name")}
            {field("emergencyNumber", "Emergency number")}
            {field("policeNumber", "Police")}
            {field("ambulanceNumber", "Ambulance")}
            {field("fireNumber", "Fire")}
            {field("drivingSide", "Driving side", "left / right")}
            {field("sourceUrl", "Official source page", "https://")}
          </div>
          <label style={{ display: "block", marginTop: 12 }}>Notes<textarea rows={2} style={{ width: "100%" }} value={editing.notes ?? ""} onChange={(e) => setEditing({ ...editing, notes: e.target.value })} /></label>
          <div style={{ display: "flex", gap: 8, marginTop: 12 }}>
            <button type="button" className="btn" onClick={() => save("draft")}>Save draft</button>
            <button type="button" className="btn btn-primary" onClick={() => save("approved")}>Approve</button>
            <button type="button" className="btn" onClick={() => setEditing(null)}>Cancel</button>
          </div>
        </div>
      )}
      {loading && <LoadingState label="Loading countries..." />}
      {!loading && Boolean(error) && <ErrorState error={error} onRetry={refetch} />}
      {!loading && !error && data && data.length === 0 && <EmptyState label="Empty. Use Import existing content on the Guidance Library page." />}
      {!loading && !error && data && data.length > 0 && (
        <table className="data-table">
          <thead><tr><th>Country</th><th>Emergency</th><th>Source</th><th>Status</th><th /></tr></thead>
          <tbody>
            {data.map((c) => (
              <tr key={c.code}>
                <td><strong>{c.name}</strong> <span style={{ fontSize: 11 }}>{c.code}</span></td>
                <td>{c.emergencyNumber}{c.policeNumber ? ` (police ${c.policeNumber})` : ""}</td>
                <td style={{ fontSize: 12 }}>{c.sourceUrl ? <a href={c.sourceUrl} target="_blank" rel="noreferrer">source</a> : <span className="badge badge-warning">add source</span>}</td>
                <td><span className={`badge ${c.status === "approved" ? "badge-success" : "badge-pending"}`}>{c.status}</span>{c.nextReviewAt && <div style={{ fontSize: 11 }}>review by {c.nextReviewAt.slice(0, 10)}</div>}</td>
                <td>{canEdit && <button type="button" className="btn btn-sm" onClick={() => setEditing({ ...c })}>Edit</button>}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
};
