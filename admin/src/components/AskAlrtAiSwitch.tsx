import { useCallback, useState } from "react";
import { useApiQuery } from "../hooks/useApiQuery";
import { getAskAlrtConfig, setAskAlrtEnabled } from "../api/resources";
import { ApiError } from "../api/client";
import { useAuth } from "../auth/AuthContext";
import { useToast } from "./ToastContext";
import { ConfirmDialog } from "./ConfirmDialog";
import { ErrorState, LoadingState } from "./AsyncState";

/** The Ask ALRT AI on/off switch (GET/PUT /api/admin/ask-alrt/config).
 * Off only stops the AI call: answer-library and emergency-number answers
 * keep working. Admin and super admin can change it; moderators see the
 * state read-only. When the server's environment config forces AI off,
 * the stored switch has no effect, so it is shown disabled. */
export const AskAlrtAiSwitch = () => {
  const { hasRole } = useAuth();
  const { notifySuccess, notifyError } = useToast();
  const canWrite = hasRole("superAdmin", "admin");

  const fetcher = useCallback(() => getAskAlrtConfig(), []);
  const { data, error, loading, refetch } = useApiQuery(fetcher, []);
  const [pending, setPending] = useState<boolean | null>(null);
  const [saving, setSaving] = useState(false);

  const apply = async () => {
    if (pending === null) return;
    const next = pending;
    setSaving(true);
    try {
      await setAskAlrtEnabled(next);
      notifySuccess(next ? "AI answers turned on." : "AI answers turned off.");
      refetch();
    } catch (err) {
      notifyError(err instanceof ApiError ? err.message : "Could not change the AI switch.");
    } finally {
      setSaving(false);
      setPending(null);
    }
  };

  if (loading) return <LoadingState label="Loading AI switch..." />;
  if (error || !data) return <ErrorState error={error} onRetry={refetch} />;

  const forcedOff = data.forcedOffByEnv;
  const effectiveOn = data.enabled && !forcedOff;
  const disabled = forcedOff || !canWrite || saving;

  return (
    <section className="card" aria-label="AI answers switch" style={{ marginBottom: 16 }}>
      <label className="toolbar__check" style={{ fontWeight: 600 }}>
        <input
          type="checkbox"
          role="switch"
          aria-checked={effectiveOn}
          checked={effectiveOn}
          disabled={disabled}
          onChange={() => setPending(!data.enabled)}
        />
        AI answers are {effectiveOn ? "on" : "off"}
      </label>
      <p style={{ fontSize: 13, margin: "8px 0 0" }}>
        {forcedOff
          ? "AI answers are turned off by this server's environment settings, so this switch cannot turn them on. Library and emergency-number answers still work."
          : effectiveOn
            ? "Questions with no library answer are sent to the AI."
            : "Questions with no library answer are not sent to the AI. Library and emergency-number answers still work."}
      </p>
      {!canWrite && !forcedOff && (
        <p style={{ fontSize: 12, color: "var(--color-text-muted)", margin: "6px 0 0" }}>
          Only an admin or super admin can change this.
        </p>
      )}

      {pending !== null && (
        <ConfirmDialog
          title={pending ? "Turn on AI answers?" : "Turn off AI answers?"}
          description={
            pending
              ? "Questions with no library answer will be sent to the AI again."
              : "Library and emergency-number answers keep working."
          }
          confirmLabel={pending ? "Turn on" : "Turn off"}
          danger={!pending}
          onConfirm={() => void apply()}
          onCancel={() => setPending(null)}
        />
      )}
    </section>
  );
};
