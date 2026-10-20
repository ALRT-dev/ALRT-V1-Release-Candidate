import { useCallback, useState } from "react";
import { useApiQuery } from "../hooks/useApiQuery";
import { createConfiguration, listConfigurations, updateConfiguration } from "../api/resources";
import { useAuth } from "../auth/AuthContext";
import { useToast } from "../components/ToastContext";
import { LoadingState, ErrorState } from "../components/AsyncState";
import { ApiError } from "../api/client";

const DEFAULTS = {
  emergency: "Emergency Warning",
  watchAndAct: "Watch and Act",
  advice: "Advice",
  default: "Alert",
};

const FIELD_LABELS: Record<keyof typeof DEFAULTS, string> = {
  emergency: "Emergency Warning (Critical band)",
  watchAndAct: "Watch and Act (Action band)",
  advice: "Advice (Monitor band)",
  default: "Alert (Info band)",
};

export const SeverityLabelsPage = () => {
  const { hasRole } = useAuth();
  const { notifySuccess, notifyError } = useToast();
  const canWrite = hasRole("superAdmin", "admin");

  const [draft, setDraft] = useState<Record<string, string> | null>(null);
  const [saving, setSaving] = useState(false);

  const fetcher = useCallback(() => listConfigurations(), []);
  const { data, error, loading, refetch } = useApiQuery(fetcher, []);

  // Find the severityLabels config row
  const row = data?.find((c) => c.key === "severityLabels");
  const currentLabels: Record<string, string> = row?.value
    ? { ...DEFAULTS, ...(row.value as Record<string, string>) }
    : DEFAULTS;

  // Draft starts from current values when first opened
  const labels = draft ?? currentLabels;

  const save = async () => {
    if (!canWrite) return;
    setSaving(true);
    try {
      if (row) {
        await updateConfiguration(row.id, { value: draft ?? currentLabels });
      } else {
        await createConfiguration({
          key: "severityLabels",
          value: draft ?? currentLabels,
          title: "Severity Labels",
          description:
            "Words shown next to each severity band. Edit here — no app rebuild needed.",
        });
      }
      notifySuccess("Severity labels saved.");
      setDraft(null);
      refetch();
    } catch (err) {
      notifyError(err instanceof ApiError ? err.message : "Save failed.");
    } finally {
      setSaving(false);
    }
  };

  const reset = () => setDraft(null);

  const isDirty =
    draft !== null &&
    Object.keys(DEFAULTS).some((k) => draft[k] !== currentLabels[k]);

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Severity Labels</h1>
          <p>
            The words displayed next to each alert severity band in the app.
            Changes take effect on the next app data fetch — no rebuild needed.
          </p>
        </div>
      </div>

      {loading && <LoadingState label="Loading severity labels…" />}
      {!loading && Boolean(error) && (
        <ErrorState error={error} onRetry={refetch} />
      )}

      {!loading && !error && (
        <div className="card" style={{ maxWidth: 520 }}>
          <table style={{ width: "100%", borderCollapse: "collapse" }}>
            <thead>
              <tr>
                <th
                  style={{
                    textAlign: "left",
                    paddingBottom: 8,
                    fontWeight: 600,
                    fontSize: 13,
                    color: "#555",
                  }}
                >
                  Band
                </th>
                <th
                  style={{
                    textAlign: "left",
                    paddingBottom: 8,
                    fontWeight: 600,
                    fontSize: 13,
                    color: "#555",
                  }}
                >
                  Label shown in app
                </th>
              </tr>
            </thead>
            <tbody>
              {(Object.keys(DEFAULTS) as (keyof typeof DEFAULTS)[]).map(
                (key) => (
                  <tr key={key}>
                    <td
                      style={{
                        paddingBottom: 12,
                        paddingRight: 16,
                        fontSize: 13,
                        whiteSpace: "nowrap",
                        color: "#333",
                        verticalAlign: "middle",
                      }}
                    >
                      {FIELD_LABELS[key]}
                    </td>
                    <td style={{ paddingBottom: 12, width: "100%" }}>
                      <input
                        type="text"
                        value={labels[key] ?? DEFAULTS[key]}
                        disabled={!canWrite || saving}
                        onChange={(e) =>
                          setDraft((prev) => ({
                            ...(prev ?? currentLabels),
                            [key]: e.target.value,
                          }))
                        }
                        style={{ width: "100%", boxSizing: "border-box" }}
                      />
                    </td>
                  </tr>
                ),
              )}
            </tbody>
          </table>

          {canWrite && (
            <div style={{ display: "flex", gap: 8, marginTop: 8 }}>
              <button
                className="btn btn-primary"
                onClick={save}
                disabled={saving || !isDirty}
              >
                {saving ? "Saving…" : "Save labels"}
              </button>
              {isDirty && (
                <button
                  className="btn btn-secondary"
                  onClick={reset}
                  disabled={saving}
                >
                  Reset
                </button>
              )}
            </div>
          )}

          {!canWrite && (
            <p style={{ fontSize: 12, color: "#888", marginTop: 8 }}>
              You need admin or super-admin role to edit severity labels.
            </p>
          )}
        </div>
      )}
    </div>
  );
};
