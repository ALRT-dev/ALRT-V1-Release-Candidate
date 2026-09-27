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
  const [configDraft, setConfigDraft] = useState<Partial<AdminHazardSource>>({});
  const [saving, setSaving] = useState(false);

  const fetcher = useCallback(
    () => listHazardSources({ searchString: search || undefined, pageSize: 100 }),
    [search],
  );
  const { data, error, loading, refetch } = useApiQuery(fetcher, [search]);

  const startEdit = (source: AdminHazardSource) => {
    setEditing(source);
    setAdvisoryDraft(source.advisoryText ?? "");
    setConfigDraft({
      country: source.country,
      region: source.region,
      coverage: source.coverage,
      sourceType: source.sourceType,
      authorityLevel: source.authorityLevel,
      feedUrl: source.feedUrl,
      format: source.format,
      accessMethod: source.accessMethod,
      adapterKey: source.adapterKey,
      scheduleMinutes: source.scheduleMinutes,
      secretRef: source.secretRef,
      lifecycleStatus: source.lifecycleStatus,
      warningTypes: source.warningTypes,
    });
  };

  const saveEdit = async () => {
    if (!editing) return;
    setSaving(true);
    try {
      await updateHazardSource(editing.id, {
        advisoryText: advisoryDraft,
        ...configDraft,
      });
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
        Source lifecycle, adapter, schedule, access reference and health fields
        are now stored on each source for TEST configuration. Secret values are
        never entered here; use a secret reference only.
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
              <th>Status</th>
              <th>Health</th>
              <th>Adapter</th>
              <th>Schedule</th>
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
                <td>{source.lifecycleStatus}</td>
                <td>{source.healthStatus}</td>
                <td>{source.adapterKey ?? "-"}</td>
                <td>{source.scheduleMinutes ? `${source.scheduleMinutes} min` : "-"}</td>
                <td>{source.hazardsCount}</td>
                <td>
                  {canWrite && (
                    <button
                      type="button"
                      className="btn btn-sm"
                      onClick={() => startEdit(source)}
                    >
                        Configure source
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
            <h2>Configure {editing.name}</h2>
            <div className="field-grid">
              {([
                ["country", "Country"],
                ["region", "Region"],
                ["coverage", "Coverage"],
                ["sourceType", "Source type"],
                ["authorityLevel", "Authority level"],
                ["format", "Format"],
                ["accessMethod", "Access method"],
                ["adapterKey", "Adapter key"],
                ["secretRef", "Secret reference"],
              ] as const).map(([key, label]) => (
                <div className="field" key={key}>
                  <label htmlFor={`source-${key}`}>{label}</label>
                  <input
                    id={`source-${key}`}
                    value={String(configDraft[key] ?? "")}
                    onChange={(event) =>
                      setConfigDraft((current) => ({ ...current, [key]: event.target.value || null }))
                    }
                  />
                </div>
              ))}
              <div className="field">
                <label htmlFor="source-feed-url">Feed URL</label>
                <input
                  id="source-feed-url"
                  type="url"
                  value={configDraft.feedUrl ?? ""}
                  onChange={(event) => setConfigDraft((current) => ({ ...current, feedUrl: event.target.value || null }))}
                />
              </div>
              <div className="field">
                <label htmlFor="source-schedule">Schedule (minutes)</label>
                <input
                  id="source-schedule"
                  type="number"
                  min="1"
                  value={configDraft.scheduleMinutes ?? ""}
                  onChange={(event) => setConfigDraft((current) => ({ ...current, scheduleMinutes: event.target.value ? Number(event.target.value) : null }))}
                />
              </div>
              <div className="field">
                <label htmlFor="source-status">Lifecycle status</label>
                <select
                  id="source-status"
                  value={configDraft.lifecycleStatus ?? "active"}
                  onChange={(event) => setConfigDraft((current) => ({ ...current, lifecycleStatus: event.target.value as AdminHazardSource["lifecycleStatus"] }))}
                >
                  {(["active", "monitoring", "degraded", "suspended", "retired"] as const).map((status) => (
                    <option key={status} value={status}>{status}</option>
                  ))}
                </select>
              </div>
            </div>
            <div className="field">
              <label htmlFor="source-warning-types">Warning types (comma-separated)</label>
              <input
                id="source-warning-types"
                value={(configDraft.warningTypes ?? []).join(", ")}
                onChange={(event) => setConfigDraft((current) => ({
                  ...current,
                  warningTypes: event.target.value.split(",").map((value) => value.trim()).filter(Boolean),
                }))}
              />
            </div>
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
