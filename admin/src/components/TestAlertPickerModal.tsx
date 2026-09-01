import { TEST_ALERT_PRESETS } from "../data/testAlertPresets";
import type { TestAlertPreset } from "../data/testAlertPresets";

interface TestAlertPickerModalProps {
  creatingId: string | null;
  onSelect: (preset: TestAlertPreset) => void;
  onCancel: () => void;
}

/** TEST-only preset picker for AlertsPage.tsx's "Create Test Alert" button -
 * no free-text fields, so there's nothing for an admin to mistype or point
 * at a real category/coordinates/AI path. Every preset is fixed; picking
 * one fires the same admin-create call the old single dummy-alert button
 * used. */
export const TestAlertPickerModal = ({
  creatingId,
  onSelect,
  onCancel,
}: TestAlertPickerModalProps) => {
  const busy = creatingId !== null;

  return (
    <div className="modal-backdrop" onClick={onCancel}>
      <div className="modal" onClick={(event) => event.stopPropagation()}>
        <h2>Create Test Alert</h2>
        <p>
          Pick a preset. Each creates a fixed, clearly-labelled TEST alert at
          Scarborough, WA through the same admin path a real alert uses -
          accepted immediately, no media, no AI, no push notifications.
        </p>
        <div className="test-alert-preset-list">
          {TEST_ALERT_PRESETS.map((preset) => (
            <button
              key={preset.id}
              type="button"
              className="btn btn-sm"
              disabled={busy}
              onClick={() => onSelect(preset)}
            >
              {creatingId === preset.id ? "Creating..." : preset.label}
            </button>
          ))}
        </div>
        <div className="modal-actions">
          <button type="button" className="btn" disabled={busy} onClick={onCancel}>
            Cancel
          </button>
        </div>
      </div>
    </div>
  );
};
