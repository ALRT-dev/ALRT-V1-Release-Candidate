import { useState } from "react";
import { useApiQuery } from "../hooks/useApiQuery";
import { useToast } from "../components/ToastContext";
import { LoadingState, ErrorState } from "../components/AsyncState";
import { getBackendOrigin } from "../api/client";
import { listHazardSources, updateHazardSource } from "../api/resources";
import { confirmSourceLicence, previewSource, saveSourceAdapter } from "../api/safetyIntelligence";
import { buildN8nAssuranceWorkflow, buildN8nFeedWorkflow } from "../lib/n8nWorkflow";
import type { AdminHazardSource } from "../api/types";

/**
 * Add a source without writing a parser (owner request, 16 Nov 2026).
 * 1. Confirm the licence. 2. Choose the adapter (CAP-AU, GeoJSON, ArcGIS) and
 * map its fields. 3. Preview what ALRT would create (nothing is saved).
 * 4. Download the n8n workflow. 5. Switch the source on.
 * A source cannot be switched on before its licence is confirmed.
 */
const MAPPING_EXAMPLE = JSON.stringify(
  { idField: "id", titleField: "title", descriptionFields: ["description"], levelField: "warning_level", timeField: "issued", expiresField: "expires", linkField: "url", categoryId: "flood", jurisdictionCountry: "AU" },
  null, 2,
);

const download = (name: string, data: unknown) => {
  const url = URL.createObjectURL(new Blob([JSON.stringify(data, null, 2)], { type: "application/json" }));
  const a = document.createElement("a");
  a.href = url;
  a.download = name;
  a.click();
  URL.revokeObjectURL(url);
};

export const SourceFeedsPage = () => {
  const { notifySuccess, notifyError } = useToast();
  const { data, error, loading, refetch } = useApiQuery(() => listHazardSources({ pageSize: 200 }), []);
  const [open, setOpen] = useState<AdminHazardSource | null>(null);
  const [form, setForm] = useState({ adapterKey: "cap_au", feedUrl: "", mapping: "", sample: "" });
  const [preview, setPreview] = useState<Awaited<ReturnType<typeof previewSource>> | null>(null);
  const [busy, setBusy] = useState(false);

  const run = async (fn: () => Promise<unknown>, ok?: string) => {
    setBusy(true);
    try {
      await fn();
      if (ok) notifySuccess(ok);
      refetch();
    } catch (e) {
      notifyError(e instanceof Error ? e.message : String(e));
    } finally {
      setBusy(false);
    }
  };

  const openSource = (s: AdminHazardSource) => {
    setOpen(s);
    setPreview(null);
    setForm({
      adapterKey: s.adapterKey ?? "cap_au",
      feedUrl: s.feedUrl ?? "",
      mapping: s.adapterConfig ? JSON.stringify(s.adapterConfig, null, 2) : "",
      sample: "",
    });
  };
  const mapping = () => (form.mapping.trim() ? JSON.parse(form.mapping) : form.adapterKey === "cap_au" ? {} : undefined);

  const sources = (data ?? []).slice().sort((a, b) => Number(a.lifecycleStatus !== "draft") - Number(b.lifecycleStatus !== "draft") || a.name.localeCompare(b.name));

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Source Feeds</h1>
          <p>
            Connect a new source with a standard adapter instead of new code. Draft sources ingest nothing. A source can be
            switched on only after its licence is confirmed. Every alert still goes through the same checks, templates and display.
          </p>
        </div>
        <button type="button" className="btn" onClick={async () => download("alrt-daily-assurance.n8n.json", buildN8nAssuranceWorkflow(await getBackendOrigin()))}>
          Download daily assurance workflow (n8n)
        </button>
      </div>

      {loading && <LoadingState label="Loading sources..." />}
      {!loading && Boolean(error) && <ErrorState error={error} onRetry={refetch} />}
      {!loading && !error && (
        <table className="data-table">
          <thead><tr><th>Source</th><th>Status</th><th>Licence</th><th>Adapter</th><th>Last good fetch</th><th /></tr></thead>
          <tbody>
            {sources.map((s) => (
              <tr key={s.id}>
                <td><strong>{s.name}</strong><div style={{ fontSize: 11 }}>{s.id}{s.region ? ` · ${s.region}` : ""}</div></td>
                <td><span className={`badge ${s.lifecycleStatus === "active" ? "badge-success" : s.lifecycleStatus === "draft" ? "badge-warning" : "badge-pending"}`}>{s.lifecycleStatus}</span></td>
                <td style={{ fontSize: 12 }}>
                  {s.licenceConfirmedAt ? <span className="badge badge-success">confirmed {s.licenceConfirmedAt.slice(0, 10)}</span> : <span className="badge badge-danger">not confirmed</span>}
                </td>
                <td style={{ fontSize: 12 }}>{s.adapterKey ?? "-"}</td>
                <td style={{ fontSize: 12 }}>{s.lastSuccessfulFetch ? String(s.lastSuccessfulFetch).slice(0, 16).replace("T", " ") : "-"}</td>
                <td style={{ whiteSpace: "nowrap" }}>
                  <button type="button" className="btn btn-sm" onClick={() => openSource(s)}>Set up</button>
                  {!s.licenceConfirmedAt && (
                    <button type="button" className="btn btn-sm" disabled={busy} onClick={() => {
                      const notes = window.prompt(`Where is ${s.name}'s licence recorded? (licence name, link, date)`, s.licensingNotes ?? "");
                      if (notes) void run(() => confirmSourceLicence(s.id, notes), "Licence confirmed.");
                    }}>Confirm licence</button>
                  )}
                  {s.lifecycleStatus === "draft" && s.licenceConfirmedAt && (
                    <button type="button" className="btn btn-sm btn-primary" disabled={busy} onClick={() => run(() => updateHazardSource(s.id, { lifecycleStatus: "active" }), `${s.name} switched on.`)}>Switch on</button>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      {open && (
        <div className="card" style={{ marginTop: 16 }}>
          <h2 style={{ marginTop: 0 }}>{open.name}</h2>
          {open.licensingNotes && <p style={{ fontSize: 13 }}><strong>Licence notes:</strong> {open.licensingNotes}</p>}
          <div style={{ display: "grid", gridTemplateColumns: "180px 1fr", gap: 12, alignItems: "center" }}>
            <label htmlFor="feed-adapter">Adapter</label>
            <select id="feed-adapter" value={form.adapterKey} onChange={(e) => setForm({ ...form, adapterKey: e.target.value })}>
              <option value="cap_au">CAP-AU (Australian warning standard, XML)</option>
              <option value="geojson">GeoJSON</option>
              <option value="arcgis">ArcGIS FeatureServer query</option>
            </select>
            <label htmlFor="feed-url">Feed URL</label>
            <input id="feed-url" value={form.feedUrl} onChange={(e) => setForm({ ...form, feedUrl: e.target.value })} placeholder="https://" />
          </div>
          <label style={{ display: "block", marginTop: 12 }}>
            Field mapping (JSON){form.adapterKey === "cap_au" ? " - optional for CAP-AU, e.g. {\"senders\":[\"...\"]}" : ""}
            <textarea rows={8} style={{ width: "100%", fontFamily: "monospace", fontSize: 12 }} value={form.mapping} placeholder={form.adapterKey === "cap_au" ? '{"jurisdictionCountry":"AU"}' : MAPPING_EXAMPLE} onChange={(e) => setForm({ ...form, mapping: e.target.value })} />
          </label>
          <label style={{ display: "block", marginTop: 12 }}>
            Sample (optional: paste a copy of the feed to test without fetching)
            <textarea rows={4} style={{ width: "100%", fontFamily: "monospace", fontSize: 12 }} value={form.sample} onChange={(e) => setForm({ ...form, sample: e.target.value })} />
          </label>
          <div style={{ display: "flex", gap: 8, marginTop: 12, flexWrap: "wrap" }}>
            <button type="button" className="btn" disabled={busy} onClick={() => run(async () => {
              setPreview(await previewSource(open.id, { adapterKey: form.adapterKey, adapterConfig: mapping(), ...(form.sample ? { sample: form.sample } : form.feedUrl ? { url: form.feedUrl } : {}) }));
            })}>Preview (saves nothing)</button>
            <button type="button" className="btn btn-primary" disabled={busy} onClick={() => run(() => saveSourceAdapter(open.id, { adapterKey: form.adapterKey, adapterConfig: mapping(), feedUrl: form.feedUrl || null }), "Adapter saved.")}>Save adapter</button>
            <button type="button" className="btn" disabled={!form.feedUrl} onClick={async () => download(`alrt-feed-${open.id}.n8n.json`, buildN8nFeedWorkflow(await getBackendOrigin(), { id: open.id, name: open.name, feedUrl: form.feedUrl, scheduleMinutes: open.scheduleMinutes }))}>
              Download n8n workflow
            </button>
            <button type="button" className="btn" onClick={() => setOpen(null)}>Close</button>
          </div>
          {preview && (
            <div style={{ marginTop: 16 }}>
              <p><strong>{preview.total}</strong> alerts would be created or updated; {preview.skipped.length} skipped; {preview.cancelled} cancellations.</p>
              {preview.fields.length > 0 && <p style={{ fontSize: 12 }}>Fields in the feed: {preview.fields.join(", ")}</p>}
              <table className="data-table">
                <thead><tr><th>Title</th><th>Level</th><th>Where</th><th>Expires</th><th>Agency text</th></tr></thead>
                <tbody>
                  {preview.items.map((h) => (
                    <tr key={String(h.id)}>
                      <td>{String(h.title ?? "")}</td>
                      <td>{String(h.nativeWarningLevel ?? "-")}</td>
                      <td style={{ fontSize: 12 }}>{String(h.locationName ?? (h.latitude !== undefined ? `${h.latitude}, ${h.longitude}` : "-"))}</td>
                      <td style={{ fontSize: 12 }}>{String(h.expiresAt ?? "-").slice(0, 16)}</td>
                      <td style={{ fontSize: 12, maxWidth: 380 }}>{String(h.description ?? "").slice(0, 240)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
              {preview.skipped.length > 0 && <details><summary>Skipped</summary><ul>{preview.skipped.map((s) => <li key={s.id}>{s.id}: {s.reason}</li>)}</ul></details>}
            </div>
          )}
        </div>
      )}
    </div>
  );
};
