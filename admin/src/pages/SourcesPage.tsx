import { useCallback, useState } from "react";
import { useApiQuery } from "../hooks/useApiQuery";
import { listHazardSources, updateHazardSource } from "../api/resources";
import { useAuth } from "../auth/AuthContext";
import { useToast } from "../components/ToastContext";
import { LoadingState, EmptyState, ErrorState } from "../components/AsyncState";
import { ApiError } from "../api/client";
import type { AdminHazardSource } from "../api/types";

export const SourcesPage = () => {
  const { hasRole } = useAuth();
  const { notifySuccess, notifyError } = useToast();
  const canWrite = hasRole("superAdmin", "admin");

  const [search, setSearch] = useState("");
  const [editing, setEditing] = useState<AdminHazardSource | null>(null);
  const [advisoryDraft, setAdvisoryDraft] = useState("");
  const [saving, setSaving] = useState(false);

  const fetcher = useCallback(
    () => listHazardSources({ searchString: search || undefined, pageSize: 100 }),
    [search],
  );
  const { data, error, loading, refetch } = useApiQuery(fetcher, [search]);

  const startEdit = (source: AdminHazardSource) => {
    setEditing(source);
    setAdvisoryDraft(source.advisoryText ?? "");
  };

  const saveEdit = async () => {
    if (!editing) return;
    setSaving(true);
    try {
      await updateHazardSource(editing.id, { advisoryText: advisoryDraft });
      notifySuccess(`Updated "${editing.name}".`);
      setEditing(null);
      refetch();
    } catch (err) {
      notifyError(err instanceof ApiError ? err.message : "Update failed.");
    } finally {
      setSaving(false);
    }
  };

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Sources</h1>
          <p>
            Official alert sources feeding the app. Sources cannot be
            impersonated - alert attribution is always tied to a real
            HazardSource row, never editable freeform text.
          </p>
        </div>
      </div>

      <div className="card" style={{ marginBottom: 16, fontSize: 13 }}>
        {/* HazardSource has no enabled/disabled flag and no fetch-health
            tracking in the current schema (backend/prisma/schema.prisma) -
            do not invent either, per instruction. */}
        Enable/disable state and source-health metrics (last successful
        fetch, last alert seen) are not currently tracked by the backend -
        omitted here rather than faked. See V1_RECONCILIATION_REPORT.md §24.
      </div>

      <div className="toolbar">
        <input
          type="search"
          placeholder="Search sources..."
          value={search}
          onChange={(event) => setSearch(event.target.value)}
        />
      </div>

      {loading && <LoadingState label="Loading sources..." />}
      {!loading && Boolean(error) && <ErrorState error={error} onRetry={refetch} />}
      {!loading && !error && data && data.length === 0 && (
        <EmptyState label="No sources match this search." />
      )}
      {!loading && !error && data && data.length > 0 && (
        <table className="data-table">
          <thead>
            <tr>
              <th>Name</th>
              <th>URL</th>
              <th>License</th>
              <th>Active hazards</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {data.map((source) => (
              <tr key={source.id}>
                <td>{source.name}</td>
                <td>
                  <a href={source.url} target="_blank" rel="noreferrer noopener">
                    {source.url}
                  </a>
                </td>
                <td>{source.license?.badgeText ?? "-"}</td>
                <td>{source.hazardsCount}</td>
                <td>
                  {canWrite && (
                    <button
                      type="button"
                      className="btn btn-sm"
                      onClick={() => startEdit(source)}
                    >
                      Edit advisory text
                    </button>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      {editing && (
        <div className="modal-backdrop" onClick={() => setEditing(null)}>
          <div className="modal" onClick={(event) => event.stopPropagation()}>
            <h2>Edit {editing.name}</h2>
            <div className="field">
              <label htmlFor="advisory-text">Advisory text</label>
              <textarea
                id="advisory-text"
                value={advisoryDraft}
                onChange={(event) => setAdvisoryDraft(event.target.value)}
              />
            </div>
            <div className="modal-actions">
              <button type="button" className="btn" onClick={() => setEditing(null)}>
                Cancel
              </button>
              <button
                type="button"
                className="btn btn-primary"
                disabled={saving}
                onClick={() => void saveEdit()}
              >
                Save
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
