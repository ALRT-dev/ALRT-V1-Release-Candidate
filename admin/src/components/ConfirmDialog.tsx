import { useState } from "react";
import type { FormEvent } from "react";

interface ConfirmDialogProps {
  title: string;
  description: string;
  confirmLabel?: string;
  danger?: boolean;
  /** When set, the dialog collects free text (e.g. a rejection reason)
   * and requires it to be non-empty before confirming. */
  requireReason?: boolean;
  reasonLabel?: string;
  onConfirm: (reason?: string) => void;
  onCancel: () => void;
}

/** A blocking confirmation modal for any safety-critical or destructive
 * action (moderation reject, hazard delete, admin deactivate, etc). Every
 * such action in this app goes through this component rather than firing
 * on a single click. */
export const ConfirmDialog = ({
  title,
  description,
  confirmLabel = "Confirm",
  danger = false,
  requireReason = false,
  reasonLabel = "Reason",
  onConfirm,
  onCancel,
}: ConfirmDialogProps) => {
  const [reason, setReason] = useState("");
  const reasonMissing = requireReason && reason.trim().length === 0;

  const handleSubmit = (event: FormEvent) => {
    event.preventDefault();
    if (reasonMissing) return;
    onConfirm(requireReason ? reason.trim() : undefined);
  };

  return (
    <div className="modal-backdrop" onClick={onCancel}>
      <form
        className="modal"
        onClick={(event) => event.stopPropagation()}
        onSubmit={handleSubmit}
      >
        <h2>{title}</h2>
        <p>{description}</p>
        {requireReason && (
          <div className="field">
            <label htmlFor="confirm-reason">{reasonLabel}</label>
            <textarea
              id="confirm-reason"
              value={reason}
              onChange={(event) => setReason(event.target.value)}
              autoFocus
              required
            />
          </div>
        )}
        <div className="modal-actions">
          <button type="button" className="btn" onClick={onCancel}>
            Cancel
          </button>
          <button
            type="submit"
            className={danger ? "btn btn-danger" : "btn btn-primary"}
            disabled={reasonMissing}
          >
            {confirmLabel}
          </button>
        </div>
      </form>
    </div>
  );
};
