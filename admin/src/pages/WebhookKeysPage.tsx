import { useCallback, useEffect, useState } from "react";
import type { FormEvent } from "react";
import { useApiQuery } from "../hooks/useApiQuery";
import {
  createWebhookApiKey,
  deleteWebhookApiKey,
  listWebhookApiKeys,
  setWebhookApiKeyActive,
} from "../api/resources";
import { useAuth } from "../auth/AuthContext";
import { useToast } from "../components/ToastContext";
import { LoadingState, EmptyState, ErrorState } from "../components/AsyncState";
import { BooleanBadge } from "../components/StatusBadge";
import { ConfirmDialog } from "../components/ConfirmDialog";
import { ApiError, getBackendOrigin } from "../api/client";
import type { WebhookApiKeyListItem } from "../api/types";
import {
  WEBHOOK_HEADER_NAME,
  WEBHOOK_PATH,
  buildN8nTestWorkflow,
  webhookUrl,
} from "../lib/n8nWorkflow";
import { TEST_SOURCE_ID, ensureTestSource } from "../lib/testSource";

export const WebhookKeysPage = () => {
  const { hasRole } = useAuth();
  const { notifySuccess, notifyError } = useToast();
  const canWrite = hasRole("superAdmin", "admin");

  const [showCreate, setShowCreate] = useState(false);
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [formError, setFormError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);
  // Held only in memory, only immediately after creation, cleared as soon
  // as the dialog closes - never written to localStorage, never logged.
  const [justCreatedKey, setJustCreatedKey] = useState<string | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<WebhookApiKeyListItem | null>(null);

  const fetcher = useCallback(() => listWebhookApiKeys(), []);
  const { data, error, loading, refetch } = useApiQuery(fetcher, []);

  const handleCreate = async (event: FormEvent) => {
    event.preventDefault();
    setFormError(null);
    setSubmitting(true);
    try {
      const result = await createWebhookApiKey({
        name,
        description: description || undefined,
      });
      setJustCreatedKey(result.apiKey);
      setShowCreate(false);
      setName("");
      setDescription("");
      refetch();
    } catch (err) {
      setFormError(err instanceof ApiError ? err.message : "Could not create key.");
    } finally {
      setSubmitting(false);
    }
  };

  const toggleActive = async (key: WebhookApiKeyListItem) => {
    try {
      await setWebhookApiKeyActive(key.id, !key.isActive);
      notifySuccess(`${key.isActive ? "Disabled" : "Enabled"} "${key.name}".`);
      refetch();
    } catch (err) {
      notifyError(err instanceof ApiError ? err.message : "Update failed.");
    }
  };

  // The backend this portal really talks to (through the Pages relay when
  // on *.pages.dev), not just the build's VITE_API_BASE_URL.
  const [apiBase, setApiBase] = useState<string | null>(null);
  useEffect(() => {
    let cancelled = false;
    getBackendOrigin()
      .then((origin) => {
        if (!cancelled) setApiBase(origin);
      })
      .catch(() => {
        if (!cancelled) setApiBase(null);
      });
    return () => {
      cancelled = true;
    };
  }, []);

  const downloadN8nWorkflow = async () => {
    // The webhook only accepts a sourceId that exists, so make sure the
    // disposable test source is there before handing out a workflow that
    // uses it. Moderators cannot create sources; for them the download
    // still works once an admin has created it.
    if (canWrite) {
      try {
        await ensureTestSource();
      } catch (err) {
        notifyError(err instanceof ApiError ? err.message : "Could not create the test source.");
        return;
      }
    }
    let origin: string;
    try {
      origin = await getBackendOrigin();
    } catch {
      notifyError("Could not work out which backend this portal uses.");
      return;
    }
    const blob = new Blob([JSON.stringify(buildN8nTestWorkflow(origin), null, 2)], {
      type: "application/json",
    });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = "alrt-n8n-test-workflow.json";
    link.click();
    URL.revokeObjectURL(url);
  };

  const handleDelete = async () => {
    if (!deleteTarget) return;
    try {
      await deleteWebhookApiKey(deleteTarget.id);
      notifySuccess(`Deleted "${deleteTarget.name}".`);
      setDeleteTarget(null);
      refetch();
    } catch (err) {
      notifyError(err instanceof ApiError ? err.message : "Delete failed.");
      setDeleteTarget(null);
    }
  };

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Webhook API Keys</h1>
          <p>
            Keys that let an external system push hazard alerts via
            POST /api/webhook/hazards. Only key metadata (name, rate
            limits, usage) is ever shown here - the key itself is never
            retrievable again after creation.
          </p>
        </div>
        {canWrite && (
          <button type="button" className="btn btn-primary" onClick={() => setShowCreate(true)}>
            New key
          </button>
        )}
      </div>

      <section className="state-block" aria-label="Connect n8n">
        <strong>Connect n8n to this environment</strong>
        <ol>
          <li>
            Create a key here with "New key" and copy it (it is shown once).
          </li>
          <li>
            In n8n, add a "Header Auth" credential: name{" "}
            <code>{WEBHOOK_HEADER_NAME}</code>, value = the key.
          </li>
          <li>
            Import the test workflow below, choose that credential on the HTTP
            Request node, then run it. It posts one test alert to{" "}
            <code>{apiBase ? webhookUrl(apiBase) : WEBHOOK_PATH}</code> on the test source{" "}
            <code>{TEST_SOURCE_ID}</code>, never a real agency's source.
            {canWrite
              ? " Downloading the workflow creates that source if it does not exist yet."
              : " An admin must create that source first (downloading the workflow as an admin does it)."}
          </li>
          <li>
            Check the Alerts page for "n8n test alert", and this table for the
            key's request count.
          </li>
        </ol>
        <button type="button" className="btn btn-sm" onClick={() => void downloadN8nWorkflow()}>
          Download n8n test workflow
        </button>
      </section>

      {loading && <LoadingState label="Loading keys..." />}
      {!loading && Boolean(error) && <ErrorState error={error} onRetry={refetch} />}
      {!loading && !error && data && data.length === 0 && (
        <EmptyState label="No webhook API keys exist." />
      )}
      {!loading && !error && data && data.length > 0 && (
        <table className="data-table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Status</th>
              <th>Rate limit (per min/hr/day)</th>
              <th>Total requests</th>
              <th>Last used</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {data.map((key) => (
              <tr key={key.id}>
                <td>{key.name}</td>
                <td>
                  <BooleanBadge value={key.isActive} trueLabel="Active" falseLabel="Disabled" />
                </td>
                <td>
                  {key.maxRequestsPerMinute}/{key.maxRequestsPerHour}/{key.maxRequestsPerDay}
                </td>
                <td>{key.totalRequests}</td>
                <td>{key.lastUsedAt ? new Date(key.lastUsedAt).toLocaleString() : "Never"}</td>
                <td style={{ display: "flex", gap: 6 }}>
                  {canWrite && (
                    <>
                      <button
                        type="button"
                        className="btn btn-sm"
                        onClick={() => void toggleActive(key)}
                      >
                        {key.isActive ? "Disable" : "Enable"}
                      </button>
                      <button
                        type="button"
                        className="btn btn-sm btn-danger"
                        onClick={() => setDeleteTarget(key)}
                      >
                        Delete
                      </button>
                    </>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      {showCreate && (
        <div className="modal-backdrop" onClick={() => setShowCreate(false)}>
          <form
            className="modal"
            onClick={(event) => event.stopPropagation()}
            onSubmit={(event) => void handleCreate(event)}
          >
            <h2>New webhook API key</h2>
            {formError && (
              <div className="form-error" role="alert">
                {formError}
              </div>
            )}
            <div className="field">
              <label htmlFor="key-name">Name</label>
              <input
                id="key-name"
                required
                value={name}
                onChange={(event) => setName(event.target.value)}
              />
            </div>
            <div className="field">
              <label htmlFor="key-description">Description</label>
              <textarea
                id="key-description"
                value={description}
                onChange={(event) => setDescription(event.target.value)}
              />
            </div>
            <div className="modal-actions">
              <button type="button" className="btn" onClick={() => setShowCreate(false)}>
                Cancel
              </button>
              <button type="submit" className="btn btn-primary" disabled={submitting}>
                Create
              </button>
            </div>
          </form>
        </div>
      )}

      {justCreatedKey && (
        <div className="modal-backdrop">
          <div className="modal">
            <h2>Key created</h2>
            <p>
              <strong>This is the only time this key will ever be shown.</strong>{" "}
              Copy it now and store it securely - it cannot be retrieved
              again, only revoked.
            </p>
            <div className="field">
              <label htmlFor="created-key">API key</label>
              <input id="created-key" readOnly value={justCreatedKey} onFocus={(e) => e.target.select()} />
            </div>
            <div className="modal-actions">
              <button
                type="button"
                className="btn btn-primary"
                onClick={() => setJustCreatedKey(null)}
              >
                I've saved it - close
              </button>
            </div>
          </div>
        </div>
      )}

      {deleteTarget && (
        <ConfirmDialog
          title="Delete webhook API key"
          description={`Permanently delete "${deleteTarget.name}"? Any system still using it will immediately lose access.`}
          confirmLabel="Delete"
          danger
          onConfirm={() => void handleDelete()}
          onCancel={() => setDeleteTarget(null)}
        />
      )}
    </div>
  );
};
