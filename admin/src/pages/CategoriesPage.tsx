import { useCallback, useState } from "react";
import { useApiQuery } from "../hooks/useApiQuery";
import { listCategories, updateCategory, updateCategoryWithImages } from "../api/resources";
import { useAuth } from "../auth/AuthContext";
import { useToast } from "../components/ToastContext";
import { LoadingState, EmptyState, ErrorState } from "../components/AsyncState";
import { ApiError } from "../api/client";
import type { HazardCategory, HazardCategoryImage } from "../api/types";
import { ICON_KEYS, effectiveIconKey } from "../data/iconKeys";

interface EditDraft {
  name: string;
  description: string;
  color: string;
  keywords: string;
  iconKey: string | null;
}

const iconSrc = (key: string) => `${import.meta.env.BASE_URL}icons/${key}.png`;
const CATEGORY_IMAGE_SLOTS = [
  { field: "infoImage", imageType: "info", label: "Info" },
  { field: "monitorImage", imageType: "monitor", label: "Monitor" },
  { field: "actionImage", imageType: "action", label: "Action" },
  { field: "criticalImage", imageType: "critical", label: "Critical" },
  { field: "adviceImage", imageType: "advice", label: "Advice" },
  { field: "watchAndActImage", imageType: "watchAndAct", label: "Watch and Act" },
  { field: "emergencyImage", imageType: "emergency", label: "Emergency" },
  { field: "userImage", imageType: "user", label: "Community" },
  { field: "fireActiveImage", imageType: "fireActive", label: "Fire active" },
  { field: "fireBeingControlledImage", imageType: "fireBeingControlled", label: "Fire being controlled" },
  { field: "fireUnderControlImage", imageType: "fireUnderControl", label: "Fire under control" },
  { field: "fireClosedImage", imageType: "fireClosed", label: "Fire closed" },
] as const;

const imageByType = (images: HazardCategoryImage[] | undefined, imageType: string) =>
  images?.find((image) => image.imageType === imageType) ?? null;


const CategoryIcon = ({ category }: { category: HazardCategory }) => {
  const key = effectiveIconKey(category);
  return (
    <img
      src={iconSrc(key)}
      alt=""
      width={32}
      height={32}
      title={category.iconKey ? `Icon: ${key} (chosen)` : `Icon: ${key} (default)`}
      style={{ objectFit: "contain" }}
    />
  );
};

const CategoryRow = ({
  category,
  depth,
  canWrite,
  onEdit,
}: {
  category: HazardCategory;
  depth: number;
  canWrite: boolean;
  onEdit: (category: HazardCategory) => void;
}) => (
  <>
    <tr>
      <td style={{ paddingLeft: 10 + depth * 20 }}>
        <span style={{ display: "inline-flex", alignItems: "center", gap: 8 }}>
          <CategoryIcon category={category} />
          {category.name}
        </span>
      </td>
      <td>{category.isFireRelated ? "Fire" : "General"}</td>
      <td>{category.hazardsCount ?? "-"}</td>
      <td>{category.description ?? "-"}</td>
      <td>
        {canWrite && (
          <button type="button" className="btn btn-sm" onClick={() => onEdit(category)}>
            Edit
          </button>
        )}
      </td>
    </tr>
    {(category.subCategories ?? []).map((sub) => (
      <CategoryRow
        key={sub.id}
        category={sub}
        depth={depth + 1}
        canWrite={canWrite}
        onEdit={onEdit}
      />
    ))}
  </>
);

export const CategoriesPage = () => {
  const { hasRole } = useAuth();
  const { notifySuccess, notifyError } = useToast();
  const canWrite = hasRole("superAdmin", "admin");

  const [editing, setEditing] = useState<HazardCategory | null>(null);
  const [draft, setDraft] = useState<EditDraft>({ name: "", description: "", color: "", keywords: "", iconKey: null });
  const [saving, setSaving] = useState(false);
  const [imageFiles, setImageFiles] = useState<Record<string, File>>({});

  const fetcher = useCallback(() => listCategories(), []);
  const { data, error, loading, refetch } = useApiQuery(fetcher, []);

  const startEdit = (category: HazardCategory) => {
    setEditing(category);
    setDraft({
      name: category.name,
      description: category.description ?? "",
      color: category.color ?? "",
      keywords: (category.keywords ?? []).join(", "),
      iconKey: category.iconKey ?? null,
    });
    setImageFiles({});
  };

  const saveEdit = async () => {
    if (!editing) return;
    setSaving(true);
    try {
      const patch = {
        name: draft.name,
        description: draft.description,
        color: draft.color || undefined,
        keywords: draft.keywords.split(",").map((x) => x.trim()).filter(Boolean),
        iconKey: draft.iconKey,
      };
      if (Object.keys(imageFiles).length > 0) {
        await updateCategoryWithImages(editing.id, patch, imageFiles);
      } else {
        await updateCategory(editing.id, patch);
      }
      notifySuccess(`Updated "${editing.name}".`);
      setEditing(null);
      setImageFiles({});
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
          <h1>Categories / Icons</h1>
          <p>
            Hazard categories, icon sets and matching keywords. Each category shows the map icon it
            uses now. Press Edit to change the icon set, colour, description, or category matching keywords;
            the app picks it up the next time it loads categories.
          </p>
        </div>
      </div>

      {loading && <LoadingState label="Loading categories..." />}
      {!loading && Boolean(error) && <ErrorState error={error} onRetry={refetch} />}
      {!loading && !error && data && data.length === 0 && (
        <EmptyState label="No categories configured." />
      )}
      {!loading && !error && data && data.length > 0 && (
        <table className="data-table">
          <thead>
            <tr>
              <th>Category</th>
              <th>Type</th>
              <th>Active hazards</th>
              <th>Description</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {data.map((category) => (
              <CategoryRow
                key={category.id}
                category={category}
                depth={0}
                canWrite={canWrite}
                onEdit={startEdit}
              />
            ))}
          </tbody>
        </table>
      )}

      {editing && (
        <div className="modal-backdrop" onClick={() => setEditing(null)}>
          <div className="modal" onClick={(event) => event.stopPropagation()}>
            <h2>Edit {editing.name}</h2>
            <div className="field">
              <label htmlFor="cat-name">Name</label>
              <input
                id="cat-name"
                value={draft.name}
                onChange={(event) => setDraft({ ...draft, name: event.target.value })}
              />
            </div>
            <div className="field">
              <label htmlFor="cat-desc">Description</label>
              <textarea
                id="cat-desc"
                value={draft.description}
                onChange={(event) =>
                  setDraft({ ...draft, description: event.target.value })
                }
              />
            </div>
            <div className="field">
              <label>Map icon</label>
              <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 8 }}>
                <img
                  src={iconSrc(effectiveIconKey({ ...editing, iconKey: draft.iconKey }))}
                  alt=""
                  width={48}
                  height={48}
                />
                <span>
                  {draft.iconKey
                    ? `Chosen: ${draft.iconKey}`
                    : `Default: ${effectiveIconKey({ ...editing, iconKey: null })}`}
                </span>
                {draft.iconKey && (
                  <button type="button" className="btn btn-sm" onClick={() => setDraft({ ...draft, iconKey: null })}>
                    Use default
                  </button>
                )}
              </div>
              <div
                style={{
                  display: "grid",
                  gridTemplateColumns: "repeat(auto-fill, minmax(64px, 1fr))",
                  gap: 6,
                  maxHeight: 220,
                  overflowY: "auto",
                  padding: 4,
                  border: "1px solid #ddd",
                  borderRadius: 6,
                }}
              >
                {ICON_KEYS.map((icon) => (
                  <button
                    key={icon.key}
                    type="button"
                    title={icon.label}
                    onClick={() => setDraft({ ...draft, iconKey: icon.key })}
                    style={{
                      padding: 4,
                      borderRadius: 6,
                      cursor: "pointer",
                      background: "transparent",
                      border: draft.iconKey === icon.key ? "2px solid #E8622A" : "1px solid transparent",
                    }}
                  >
                    <img src={iconSrc(icon.key)} alt={icon.label} width={48} height={48} />
                  </button>
                ))}
              </div>
            </div>
            <div className="field">
              <label htmlFor="cat-color">Colour (hex)</label>
              <input
                id="cat-color"
                value={draft.color}
                placeholder="#RRGGBB"
                onChange={(event) => setDraft({ ...draft, color: event.target.value })}
              />
            </div>
            <div className="field">
              <label htmlFor="cat-keywords">Keywords</label>
              <textarea
                id="cat-keywords"
                value={draft.keywords}
                placeholder="Comma-separated keywords used for category matching"
                onChange={(event) => setDraft({ ...draft, keywords: event.target.value })}
              />
            </div>
            <div className="field">
              <label>Uploaded category images</label>
              <p style={{ marginTop: 0, color: "#666" }}>
                Upload replacement artwork for any severity/community slot. This goes through the existing backend upload path.
              </p>
              <div
                style={{
                  display: "grid",
                  gridTemplateColumns: "repeat(auto-fill, minmax(180px, 1fr))",
                  gap: 12,
                }}
              >
                {CATEGORY_IMAGE_SLOTS.map((slot) => {
                  const current = imageByType(editing.images, slot.imageType);
                  const selected = imageFiles[slot.field];
                  return (
                    <div
                      key={slot.field}
                      style={{
                        border: "1px solid #ddd",
                        borderRadius: 8,
                        padding: 10,
                        display: "flex",
                        flexDirection: "column",
                        gap: 8,
                      }}
                    >
                      <strong>{slot.label}</strong>
                      {current?.presignedUrl ? (
                        <img
                          src={current.presignedUrl}
                          alt={slot.label}
                          style={{ width: 56, height: 56, objectFit: "contain" }}
                        />
                      ) : (
                        <span style={{ color: "#666" }}>No uploaded image</span>
                      )}
                      <input
                        type="file"
                        accept="image/*"
                        onChange={(event) => {
                          const file = event.target.files?.[0];
                          setImageFiles((prev) => {
                            if (!file) {
                              const next = { ...prev };
                              delete next[slot.field];
                              return next;
                            }
                            return { ...prev, [slot.field]: file };
                          });
                        }}
                      />
                      <span style={{ color: "#666", fontSize: 12 }}>
                        {selected ? `Ready: ${selected.name}` : "Leave blank to keep current image."}
                      </span>
                    </div>
                  );
                })}
              </div>
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
