import { useCallback, useState } from "react";
import { useApiQuery } from "../hooks/useApiQuery";
import { useDebouncedValue } from "../hooks/useDebouncedValue";
import { usePageForFilters } from "../hooks/usePageForFilters";
import { Pagination } from "../components/Pagination";
import { createHazardSource, listHazardSources, updateHazardSource } from "../api/resources";
import { useAuth } from "../auth/AuthContext";
import { useToast } from "../components/ToastContext";
import { LoadingState, EmptyState, ErrorState } from "../components/AsyncState";
import { ApiError } from "../api/client";
import type { AdminHazardSource } from "../api/types";

const PAGE_SIZE = 50;

const toDateInput = (iso: string | null | undefined) => (iso ? iso.slice(0, 10) : "");

const isReviewOverdue = (iso: string | null) =>
  iso !== null && new Date(iso).getTime() < Date.now();

export const SourcesPage = () => {
  const { hasRole } = useAuth();
  const { notifySuccess, notifyError } = useToast();
  const canWrite = hasRole("superAdmin", "admin");

  const [search, setSearch] = useState("");
  const debouncedSearch = useDebouncedValue(search.trim());
  const [page, setPage] = usePageForFilters([debouncedSearch]);
  const [editing, setEditing] = useState<AdminHazardSource | null>(null);
  const [advisoryDraft, setAdvisoryDraft] = useState("");
  const [configDraft, setConfigDraft] = useState<Partial<AdminHazardSource>>({});
  const [saving, setSaving] = useState(false);
  const [creatingSource, setCreatingSource] = useState(false);
  const [creatingSaving, setCreatingSaving] = useState(false);
  const [createDraft, setCreateDraft] = useState({
    id: "",
    name: "",
    url: "",
    feedUrl: "",
    adapterKey: "geojson",
    format: "GeoJSON",
    country: "Australia",
    region: "",
    sourceType: "official",
    authorityLevel: "official",
    accessMethod: "public-feed",
    scheduleMinutes: 15,
  });

  const fetcher = useCallback(
    () =>
      listHazardSources({ searchString: debouncedSearch || undefined, page, pageSize: PAGE_SIZE }),
    [debouncedSearch, page],
  );
  const { data, error, loading, refetch } = useApiQuery(fetcher, [debouncedSearch, page]);

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
      sourceNativeSeverity: source.sourceNativeSeverity,
      sourceNativeSymbol: source.sourceNativeSymbol,
      licensingNotes: source.licensingNotes,
      lastReviewedAt: source.lastReviewedAt,
      expiryReviewAt: source.expiryReviewAt,
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

  const saveNewSource = async () => {
    const draft = {
      id: createDraft.id.trim(),
      name: createDraft.name.trim(),
      url: createDraft.url.trim(),
      feedUrl: createDraft.feedUrl.trim(),
    };
    if (!draft.id || !draft.name || !draft.url || !draft.feedUrl) {
      notifyError("Enter a source ID, publisher name, publisher URL and feed URL.");
      return;
    }
    if (!/^[a-zA-Z0-9_-]+$/.test(draft.id)) {
      notifyError("Source ID can contain only letters, numbers, underscores and hyphens.");
      return;
    }
    setCreatingSaving(true);
    try {
      await createHazardSource({
        ...draft,
        adapterKey: createDraft.adapterKey,
        format: createDraft.format,
        country: createDraft.country.trim() || undefined,
        region: createDraft.region.trim() || undefined,
        sourceType: createDraft.sourceType,
        authorityLevel: createDraft.authorityLevel,
        accessMethod: createDraft.accessMethod,
        scheduleMinutes: createDraft.scheduleMinutes,
        lifecycleStatus: "monitoring",
      });
      notifySuccess("Source created in monitoring status. It will not be ingested until explicitly activated.");
      setCreatingSource(false);
      setCreateDraft({
        id: "",
        name: "",
        url: "",
        feedUrl: "",
        adapterKey: "geojson",
        format: "GeoJSON",
        country: "Australia",
        region: "",
        sourceType: "official",
        authorityLevel: "official",
        accessMethod: "public-feed",
        scheduleMinutes: 15,
      });
      refetch();
    } catch (err) {
      notifyError(err instanceof ApiError ? err.message : "Source creation failed.");
    } finally {
      setCreatingSaving(false);
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
        Source lifecycle, review dates, licensing terms and health are recorded
        on each source. Registry-backed ingestion currently supports GeoJSON and
        RSS adapters. New sources start in monitoring and do not publish until
        explicitly activated. Validate the feed, category mapping, attribution
        and licence in TEST before activation. Secret values are never entered
        here; use a secret reference only. Every change is recorded in the Audit Log.
      </div>

      <div className="toolbar">
        <input
          type="search"
          placeholder="Search sources..."
          value={search}
          onChange={(event) => setSearch(event.target.value)}
        />
        {canWrite && (
          <button type="button" className="btn btn-primary" onClick={() => setCreatingSource(true)}>
            Add source
          </button>
        )}
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
              <th>Last fetch</th>
              <th>Review due</th>
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
                <td title={source.lastHealthError ?? undefined}>{source.healthStatus}</td>
                <td>
                  {source.lastSuccessfulFetch
                    ? new Date(source.lastSuccessfulFetch).toLocaleString()
                    : "-"}
                </td>
                <td>
                  {source.expiryReviewAt
                    ? `${toDateInput(source.expiryReviewAt)}${isReviewOverdue(source.expiryReviewAt) ? " (overdue)" : ""}`
                    : "-"}
                </td>
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
      {!loading && !error && data && (
        <Pagination
          page={page}
          pageSize={PAGE_SIZE}
          itemsOnPage={data.length}
          onPageChange={setPage}
        />
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
                ["sourceNativeSeverity", "Source-native severity terms"],
                ["sourceNativeSymbol", "Source-native symbol"],
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
            <div className="field-grid">
              <div className="field">
                <label htmlFor="source-last-reviewed">Last reviewed</label>
                <input
                  id="source-last-reviewed"
                  type="date"
                  value={toDateInput(configDraft.lastReviewedAt)}
                  onChange={(event) => setConfigDraft((current) => ({ ...current, lastReviewedAt: event.target.value || null }))}
                />
              </div>
              <div className="field">
                <label htmlFor="source-expiry-review">Next review due</label>
                <input
                  id="source-expiry-review"
                  type="date"
                  value={toDateInput(configDraft.expiryReviewAt)}
                  onChange={(event) => setConfigDraft((current) => ({ ...current, expiryReviewAt: event.target.value || null }))}
                />
              </div>
            </div>
            <div className="field">
              <label htmlFor="source-licensing-notes">Licensing and access terms</label>
              <textarea
                id="source-licensing-notes"
                value={configDraft.licensingNotes ?? ""}
                onChange={(event) => setConfigDraft((current) => ({ ...current, licensingNotes: event.target.value || null }))}
              />
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

      {creatingSource && (
        <div className="modal-backdrop" onClick={() => setCreatingSource(false)}>
          <div className="modal" onClick={(event) => event.stopPropagation()}>
            <h2>Add an alert source</h2>
            <p>
              Supported generic adapters: GeoJSON FeatureCollection and RSS/Atom.
              The source starts in monitoring and is not ingested until an admin
              activates it after testing and licence review.
            </p>
            <div className="field-grid">
              <div className="field">
                <label htmlFor="new-source-id">Stable source ID</label>
                <input id="new-source-id" required value={createDraft.id}
                  placeholder="e.g. wa-flood-feed"
                  onChange={(event) => setCreateDraft((current) => ({ ...current, id: event.target.value }))} />
              </div>
              <div className="field">
                <label htmlFor="new-source-name">Publisher / source name</label>
                <input id="new-source-name" required value={createDraft.name}
                  onChange={(event) => setCreateDraft((current) => ({ ...current, name: event.target.value }))} />
              </div>
              <div className="field">
                <label htmlFor="new-source-url">Publisher website URL</label>
                <input id="new-source-url" type="url" required value={createDraft.url}
                  placeholder="https://agency.gov.au"
                  onChange={(event) => setCreateDraft((current) => ({ ...current, url: event.target.value }))} />
              </div>
              <div className="field">
                <label htmlFor="new-source-feed">Feed URL</label>
                <input id="new-source-feed" type="url" required value={createDraft.feedUrl}
                  placeholder="https://agency.gov.au/feed"
                  onChange={(event) => setCreateDraft((current) => ({ ...current, feedUrl: event.target.value }))} />
              </div>
              <div className="field">
                <label htmlFor="new-source-adapter">Feed format / adapter</label>
                <select id="new-source-adapter" value={createDraft.adapterKey}
                  onChange={(event) => setCreateDraft((current) => ({
                    ...current,
                    adapterKey: event.target.value,
                    format: event.target.value === "rss" ? "RSS/Atom" : "GeoJSON",
                  }))}>
                  <option value="geojson">GeoJSON FeatureCollection</option>
                  <option value="rss">RSS / Atom</option>
                </select>
              </div>
              <div className="field">
                <label htmlFor="new-source-country">Country</label>
                <input id="new-source-country" value={createDraft.country}
                  onChange={(event) => setCreateDraft((current) => ({ ...current, country: event.target.value }))} />
              </div>
              <div className="field">
                <label htmlFor="new-source-region">Region / jurisdiction</label>
                <input id="new-source-region" value={createDraft.region}
                  onChange={(event) => setCreateDraft((current) => ({ ...current, region: event.target.value }))} />
              </div>
              <div className="field">
                <label htmlFor="new-source-schedule">Fetch interval (minutes)</label>
                <input id="new-source-schedule" type="number" min="1" max="10080"
                  value={createDraft.scheduleMinutes}
                  onChange={(event) => setCreateDraft((current) => ({
                    ...current,
                    scheduleMinutes: Math.max(1, Math.min(10080, Number(event.target.value) || 15)),
                  }))} />
              </div>
            </div>
            <div className="modal-actions">
              <button type="button" className="btn" onClick={() => setCreatingSource(false)}>
                Cancel
              </button>
              <button type="button" className="btn btn-primary" disabled={creatingSaving}
                onClick={() => void saveNewSource()}>
                {creatingSaving ? "Creating..." : "Create in monitoring"}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
