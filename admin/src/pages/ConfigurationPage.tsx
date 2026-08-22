import { useCallback, useState } from "react";
import { useApiQuery } from "../hooks/useApiQuery";
import { listConfigurations, updateConfiguration } from "../api/resources";
import { useAuth } from "../auth/AuthContext";
import { useToast } from "../components/ToastContext";
import { LoadingState, EmptyState, ErrorState } from "../components/AsyncState";
import { ApiError } from "../api/client";
import type { AdminConfiguration } from "../api/types";

export const ConfigurationPage = () => {
  const { hasRole } = useAuth();
  const { notifySuccess, notifyError } = useToast();
  const canWrite = hasRole("superAdmin", "admin");

  const [editing, setEditing] = useState<AdminConfiguration | null>(null);
  const [titleDraft, setTitleDraft] = useState("");
  const [descriptionDraft, setDescriptionDraft] = useState("");
  const [saving, setSaving] = useState(false);

  const fetcher = useCallback(() => listConfigurations(), []);
  const { data, error, loading, refetch } = useApiQuery(fetcher, []);

  const startEdit = (config: AdminConfiguration) => {
    setEditing(config);
    setTitleDraft(config.title);
    setDescriptionDraft(config.description ?? "");
  };

  const save = async () => {
    if (!editing) return;
    setSaving(true);
    try {
      await updateConfiguration(editing.id, {
        title: titleDraft,
        description: descriptionDraft,
      });
      notifySuccess(`Updated "${editing.title}".`);
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
          <h1>Configuration</h1>
          <p>
            Operational configuration rows. The Configuration.key column is
            structurally restricted by the backend to a fixed enum (today,
            only "aiPrompts") - this screen can never hold an arbitrary
            key/secret.
          </p>
        </div>
      </div>

      <div className="card" style={{ marginBottom: 16, fontSize: 13 }}>
        {/* Configuration.value is an unvalidated JSON blob that could hold
            a pasted secret (Stage 7A/7B finding) - editing it via a raw
            textarea in V1 is deliberately not exposed, to avoid the portal
            becoming the easiest place to accidentally leak or corrupt the
            live AI-prompt wiring. Title/description metadata edits are
            safe and exposed below. See V1_RECONCILIATION_REPORT.md §24. */}
        Editing the underlying configuration value (a JSON blob wiring the
        AI prompt system) is not exposed in this V1 - a malformed edit here
        would break alert generation with no undo, and it's the one place
        in the Admin API an operator could accidentally paste a secret.
        Only the title/description metadata are editable below; the active
        value is shown read-only for reference.
      </div>

      {loading && <LoadingState label="Loading configuration..." />}
      {!loading && Boolean(error) && <ErrorState error={error} onRetry={refetch} />}
      {!loading && !error && data && data.length === 0 && (
        <EmptyState label="No configuration rows exist." />
      )}
      {!loading && !error && data && data.length > 0 && (
        <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
          {data.map((config) => (
            <div key={config.id} className="card">
              <div style={{ display: "flex", justifyContent: "space-between" }}>
                <div>
                  <strong>{config.title}</strong>
                  <div style={{ fontSize: 12, color: "var(--color-text-muted)" }}>
                    key: {config.key} · updated{" "}
                    {new Date(config.updatedAt).toLocaleString()}
                    {config.updatedBy ? ` by ${config.updatedBy.email}` : ""}
                  </div>
                </div>
                {canWrite && (
                  <button
                    type="button"
                    className="btn btn-sm"
                    onClick={() => startEdit(config)}
                  >
                    Edit metadata
                  </button>
                )}
              </div>
              {config.description && <p>{config.description}</p>}
              <details>
                <summary style={{ cursor: "pointer", fontSize: 12 }}>
                  Current active value (read-only)
                </summary>
                <pre
                  style={{
                    whiteSpace: "pre-wrap",
                    fontSize: 11,
                    maxHeight: 240,
                    overflowY: "auto",
                    background: "var(--color-bg)",
                    padding: 8,
                    borderRadius: 4,
                  }}
                >
                  {JSON.stringify(config.value, null, 2)}
                </pre>
              </details>
            </div>
          ))}
        </div>
      )}

      {editing && (
        <div className="modal-backdrop" onClick={() => setEditing(null)}>
          <div className="modal" onClick={(event) => event.stopPropagation()}>
            <h2>Edit {editing.title}</h2>
            <div className="field">
              <label htmlFor="config-title">Title</label>
              <input
                id="config-title"
                value={titleDraft}
                onChange={(event) => setTitleDraft(event.target.value)}
              />
            </div>
            <div className="field">
              <label htmlFor="config-description">Description</label>
              <textarea
                id="config-description"
                value={descriptionDraft}
                onChange={(event) => setDescriptionDraft(event.target.value)}
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
                onClick={() => void save()}
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
