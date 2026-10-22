import { useCallback, useEffect, useState } from "react";
import { Link } from "react-router-dom";
import {
  getAlertTemplates,
  saveAlertTemplates,
  previewAlertTemplate,
  BANDS,
  type Band,
  type TemplatePack,
  type TemplateSettings,
  type TemplateRegistry,
  type TemplateSource,
  type TemplatePreview,
  type GuidanceEntry,
} from "../api/alertTemplates";
import { listAIPrompts, listCategories } from "../api/resources";
import type { AIPrompt, HazardCategory } from "../api/types";
import { useAuth } from "../auth/AuthContext";
import { AlertContentSections } from "../components/AlertContentSections";
import { editorSettings } from '../lib/alertTemplateEditor';
import {profileLabels as labels} from '../lib/profileLabels';
import "./AlertTemplatesPage.css";

const COHORTS = [
  "older",
  "kids",
  "mobility",
  "medical",
  "deaf",
  "vision",
  "visitor",
  "worker",
  "pets",
];
const list = (value: string) =>
  value
    .split(",")
    .map((x) => x.trim())
    .filter(Boolean);
export function AlertTemplatesPage() {
  const { hasRole } = useAuth();
  const canWrite = hasRole("superAdmin", "admin");
  const [state, setState] = useState<TemplateRegistry | null>(null),
    [pack, setPack] = useState<TemplatePack | null>(null);
  const [sources, setSources] = useState<TemplateSource[]>([]),
    [categories, setCategories] = useState<HazardCategory[]>([]),
    [prompts, setPrompts] = useState<AIPrompt[]>([]);
  const [scope, setScope] = useState("default"),
    [tab, setTab] = useState("settings"),
    [busy, setBusy] = useState(false),
    [error, setError] = useState(""),
    [message, setMessage] = useState(""),
    [dirty, setDirty] = useState(false);
  const [reason, setReason] = useState(""),
    [confirm, setConfirm] = useState<{
      action: "publish" | "restore";
      version?: number;
    } | null>(null);
  const [sourceId, setSourceId] = useState(""),
    [categoryId, setCategoryId] = useState(""),
    [title, setTitle] = useState("Example warning"),
    [description, setDescription] = useState(
      "Watch and Act for Example Town. Smoke affects Example Road. Prepare to leave if you are in Example Town.",
    ),
    [nativeLevel, setNativeLevel] = useState("Watch and Act");
  const [preview, setPreview] = useState<TemplatePreview | null>(null),
    [selectedProfiles, setSelectedProfiles] = useState<string[]>([]);
  const [entry, setEntry] = useState<GuidanceEntry | null>(null);
  const [librarySearch, setLibrarySearch] = useState("");
  const [jurisdictionCountry,setJurisdictionCountry]=useState('');
  const [sourceInstructions,setSourceInstructions]=useState('');
  const load = useCallback(async () => {
    setBusy(true);
    setError("");
    try {
      const [data, cats, ps] = await Promise.all([
        getAlertTemplates(),
        listCategories(),
        listAIPrompts(),
      ]);
      setState(data.state);
      setPack(data.state.draft);
      setSources(data.sources);
      setCategories(
        cats
          .flatMap((c) => [c, ...(c.subCategories ?? [])])
          .filter((c, i, all) => all.findIndex((x) => x.id === c.id) === i),
      );
      setPrompts(ps);
      setDirty(false);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Could not load templates.");
    } finally {
      setBusy(false);
    }
  }, []);
  useEffect(() => {
    void load();
  }, [load]);
  useEffect(() => {
    if (!dirty) return;
    const warn = (event: BeforeUnloadEvent) => {
      event.preventDefault();
      event.returnValue = "";
    };
    window.addEventListener("beforeunload", warn);
    const followLink = (event: MouseEvent) => {
      const anchor = (event.target as Element | null)?.closest('a[href]');
      if (anchor && !window.confirm("Leave without saving your template changes?")) {
        event.preventDefault();
        event.stopImmediatePropagation();
      }
    };
    document.addEventListener("click", followLink, true);
    return () => { window.removeEventListener("beforeunload", warn); document.removeEventListener("click", followLink, true); };
  }, [dirty]);
  if (!pack || !state)
    return (
      <div>
        <h1>Alert templates</h1>
        <p>{error || "Loading templates..."}</p>
        {error && <button onClick={() => void load()}>Try again</button>}
      </div>
    );
  const active = pack.overrides.find((x) => x.id === scope);
  const settings = editorSettings(pack,active,sources);
  const previewCategory=categories.find(x=>x.id===categoryId);
  const previewIconCategory=categories.find(x=>x.id===(preview?.isAws?categoryId:preview?.settings.iconCategoryId??categoryId));
  const previewIconType=preview?.isAws?({info:'advice',monitor:'advice',action:'watchAndAct',critical:'emergency'}[preview.band]):preview?.band;
  const previewIcon=previewIconCategory?.images?.find(x=>x.imageType===previewIconType)?.presignedUrl;
  const update = (next: TemplatePack) => {
    setPack(next);
    setDirty(true);
    setPreview(null);
    setMessage("");
  };
  const setSetting = <K extends keyof TemplateSettings>(
    key: K,
    value: TemplateSettings[K],
  ) =>
    update(
      active
        ? {
            ...pack,
            overrides: pack.overrides.map((x) =>
              x.id === scope
                ? { ...x, settings: { ...x.settings, [key]: value } }
                : x,
            ),
          }
        : { ...pack, defaults: { ...pack.defaults, [key]: value } },
    );
  const inherit = (key: keyof TemplateSettings) => {
    if (!active) return;
    const next = { ...active.settings };
    delete next[key];
    update({
      ...pack,
      overrides: pack.overrides.map((x) =>
        x.id === scope ? { ...x, settings: next } : x,
      ),
    });
  };
  const fieldLabel = (text: string, key: keyof TemplateSettings) => (
    <div className="template-field-label">
      <strong>{text}</strong>
      {active && (
        <button
          type="button"
          className="btn btn-sm"
          disabled={!canWrite || !(key in active.settings)}
          onClick={() => inherit(key)}
        >
          {key in active.settings ? "Use inherited value" : "Inherited"}
        </button>
      )}
    </div>
  );
  const save = async (
    action: "draft" | "publish" | "restore",
    version?: number,
  ) => {
    setBusy(true);
    setError("");
    try {
      const next = await saveAlertTemplates({
        revision: state.revision,
        action,
        ...(action === "restore" ? { version } : { pack }),
        reason: reason.trim() || "Saved template draft",
      });
      setState(next);
      setPack(next.draft);
      setDirty(false);
      setConfirm(null);
      setMessage(
        action === "draft"
          ? "Draft saved. Future alerts still use the published version."
          : `Version ${next.published?.version} published for future alerts.`,
      );
    } catch (e) {
      setError(e instanceof Error ? e.message : "Save failed.");
    } finally {
      setBusy(false);
    }
  };
  const runPreview = async (extract: boolean) => {
    setBusy(true);
    setError("");
    setPreview(null);
    try {
      setPreview(
        await previewAlertTemplate({
          pack,
          sourceId,
          categoryId,
          title,
          description,
          nativeWarningLevel: nativeLevel.trim() || null,
          jurisdictionCountry:jurisdictionCountry.trim()||null,
          sourceInstructions: sourceInstructions.trim() ? [sourceInstructions.trim()] : [],
          extract,
        }),
      );
    } catch (e) {
      setError(e instanceof Error ? e.message : "Preview failed.");
    } finally {
      setBusy(false);
    }
  };
  const newEntry = () =>
    setEntry({
      id: crypto.randomUUID(),
      text: "",
      categoryIds: [],
      countries: [],
      bands: [],
      profileTags: [],
      approved: false,
      reference: "",
      reviewedAt: null,
    });
  return (
    <div className="templates-page">
      <div className="page-header">
        <div>
          <h1>Alert templates</h1>
          <p>
            One shared template, with country and source changes where needed. This is also where For You / safety-profile guidance is managed.
          </p>
        </div>
        <span className="template-version">
          {state.published
            ? `Published v${state.published.version}`
            : "No template published"}
          {dirty ? " • Unsaved changes" : ""}
        </span>
      </div>
      <div className="template-notice">
        AI extracts facts. Code assigns severity. Official warning levels and
        required AWS artwork stay protected. Category pill colours are edited in{" "}
        <Link to="/categories">Categories / Icons</Link>.
      </div>
      {error && (
        <p role="alert" className="template-error">
          {error}
        </p>
      )}
      {message && (
        <p role="status" className="template-success">
          {message}
        </p>
      )}
      <nav className="template-tabs" aria-label="Template sections">
        {[
          ["settings", "Template settings"],
          ["library", "Suggested actions / For You / Safety profiles"],
          ["history", "Version history"],
        ].map(([key, label]) => (
          <button
            key={key}
            className={`btn ${tab === key ? "btn-primary" : ""}`}
            onClick={() => setTab(key!)}
          >
            {label}
          </button>
        ))}
      </nav>
      {tab === "settings" && (
        <div className="template-columns">
          <section className="card">
            <label>
              Editing
              <select value={scope} onChange={(e) => setScope(e.target.value)}>
                <option value="default">Shared default</option>
                {pack.overrides.map((x) => (
                  <option key={x.id} value={x.id}>
                    {x.name}
                  </option>
                ))}
              </select>
            </label>
            {canWrite && (
              <button
                className="btn btn-sm"
                onClick={() => {
                  const id = crypto.randomUUID();
                  update({
                    ...pack,
                    overrides: [
                      ...pack.overrides,
                      {
                        id,
                        name: "New country or source template",
                        country: "AU",
                        sourceId: null,
                        settings: {},
                      },
                    ],
                  });
                  setScope(id);
                }}
              >
                Add country / source template
              </button>
            )}
            <fieldset disabled={!canWrite || busy}>
              {active && (
                <div className="template-scope">
                  <label>
                    Name
                    <input
                      value={active.name}
                      onChange={(e) =>
                        update({
                          ...pack,
                          overrides: pack.overrides.map((x) =>
                            x.id === scope ? { ...x, name: e.target.value } : x,
                          ),
                        })
                      }
                    />
                  </label>
                  <label>
                    Country code (blank = all countries)
                    <input
                      value={active.country ?? ""}
                      placeholder="AU, NZ, SA"
                      maxLength={2}
                      onChange={(e) =>
                        update({
                          ...pack,
                          overrides: pack.overrides.map((x) =>
                            x.id === scope
                              ? {
                                  ...x,
                                  country: e.target.value.toUpperCase() || null,
                                }
                              : x,
                          ),
                        })
                      }
                    />
                  </label>
                  <label>
                    Source
                    <select
                      value={active.sourceId ?? ""}
                      onChange={(e) =>
                        update({
                          ...pack,
                          overrides: pack.overrides.map((x) =>
                            x.id === scope
                              ? { ...x, sourceId: e.target.value || null }
                              : x,
                          ),
                        })
                      }
                    >
                      <option value="">All sources in this country</option>
                      {sources.map((x) => (
                        <option key={x.id} value={x.id}>
                          {x.name}
                        </option>
                      ))}
                    </select>
                  </label>
                  <button
                    className="btn btn-sm"
                    onClick={() => {
                      update({
                        ...pack,
                        overrides: pack.overrides.filter((x) => x.id !== scope),
                      });
                      setScope("default");
                    }}
                  >
                    Remove this override from draft
                  </button>
                </div>
              )}
              <label>
                {fieldLabel("Template locale", "language")}
                <input
                  value={settings.language}
                  onChange={(e) => setSetting("language", e.target.value)}
                />
                <small>Source facts and agency instructions retain their original wording and language.</small>
              </label>
              <label>
                {fieldLabel("Extraction prompt", "promptId")}
                <select
                  value={settings.promptId ?? ""}
                  onChange={(e) =>
                    setSetting("promptId", e.target.value || null)
                  }
                >
                  <option value="">
                    Existing source / category prompt selection
                  </option>
                  {prompts.map((x) => (
                    <option key={x.id} value={x.id}>
                      {x.name}
                    </option>
                  ))}
                </select>
              </label>
              <p className="muted">
                Edit wording in <Link to="/ai-prompts">AI Prompts</Link>, then
                publish here to include it. Published versions keep a copy for
                restore.
              </p>
              <label>
                {fieldLabel(
                  "Extra extraction instructions",
                  "additionalInstructions",
                )}
                <textarea
                  rows={6}
                  value={settings.additionalInstructions}
                  onChange={(e) =>
                    setSetting("additionalInstructions", e.target.value)
                  }
                />
              </label>
              <div>
                {fieldLabel("ALRT severity colours", "bandColors")}
                <div className="template-colours">
                  {BANDS.map((b) => (
                    <label key={b}>
                      {b}
                      <input
                        aria-label={`${b} colour`}
                        type="color"
                        value={settings.bandColors[b]}
                        onChange={(e) =>
                          setSetting("bandColors", {
                            ...settings.bandColors,
                            [b]: e.target.value,
                          })
                        }
                      />
                      <small>{settings.bandColors[b]}</small>
                    </label>
                  ))}
                </div>
                <p className="muted">
                  These colours describe ALRT severity. Agency icon artwork
                  keeps its approved colours and outline.
                </p>
              </div>
              <label>
                {fieldLabel("Existing icon family", "iconCategoryId")}
                <select
                  value={settings.iconCategoryId ?? ""}
                  onChange={(e) =>
                    setSetting("iconCategoryId", e.target.value || null)
                  }
                >
                  <option value="">Use the alert's category icons</option>
                  {categories.map((x) => (
                    <option key={x.id} value={x.id}>
                      {x.name}
                    </option>
                  ))}
                </select>
              </label>
              <p className="muted">
                Uses existing images. AWS alerts retain their category's
                required agency artwork. No square icon is added.
              </p>
              <div>
                {fieldLabel(
                  "Original warning label to ALRT severity",
                  "nativeLevelMappings",
                )}
                <p className="muted">
                  Exact source labels only. AWS levels, drills and resolved
                  incidents keep their protected rules. The AI cannot set the
                  band.
                </p>
                {settings.nativeLevelMappings.map((mapping, index) => (
                  <div className="template-map-row" key={index}>
                    <input
                      aria-label={`Agency label ${index + 1}`}
                      placeholder="e.g. Road closed"
                      value={mapping.level}
                      onChange={(e) =>
                        setSetting(
                          "nativeLevelMappings",
                          settings.nativeLevelMappings.map((x, i) =>
                            i === index ? { ...x, level: e.target.value } : x,
                          ),
                        )
                      }
                    />
                    <select
                      aria-label={`Band ${index + 1}`}
                      value={mapping.band}
                      onChange={(e) =>
                        setSetting(
                          "nativeLevelMappings",
                          settings.nativeLevelMappings.map((x, i) =>
                            i === index
                              ? { ...x, band: e.target.value as Band }
                              : x,
                          ),
                        )
                      }
                    >
                      {BANDS.map((b) => (
                        <option key={b}>{b}</option>
                      ))}
                    </select>
                    <button
                      className="btn btn-sm"
                      aria-label={`Remove mapping ${index + 1}`}
                      onClick={() =>
                        setSetting(
                          "nativeLevelMappings",
                          settings.nativeLevelMappings.filter(
                            (_, i) => i !== index,
                          ),
                        )
                      }
                    >
                      Remove
                    </button>
                  </div>
                ))}
                <button
                  className="btn btn-sm"
                  onClick={() =>
                    setSetting("nativeLevelMappings", [
                      ...settings.nativeLevelMappings,
                      { level: "", band: "monitor" },
                    ])
                  }
                >
                  Add warning label
                </button>
              </div>
              {active?.sourceId && (
                <p className="muted">Source settings are shared across destinations unless you also choose a country.</p>
              )}
              <div>
                {fieldLabel("ALRT severity wordbank", "severityPhrases")}
                <p className="muted">Use whole phrases for alerts without a protected agency level. The strongest matching phrase wins. Tests and resolved incidents remain Info.</p>
                {(settings.severityPhrases ?? []).map((rule,index)=><div className="template-map-row" key={index}>
                  <input aria-label={`Severity phrase ${index+1}`} placeholder="e.g. road closed" value={rule.phrase} onChange={e=>setSetting("severityPhrases",(settings.severityPhrases??[]).map((x,i)=>i===index?{...x,phrase:e.target.value}:x))}/>
                  <select aria-label={`Phrase band ${index+1}`} value={rule.band} onChange={e=>setSetting("severityPhrases",(settings.severityPhrases??[]).map((x,i)=>i===index?{...x,band:e.target.value as Band}:x))}>{BANDS.map(b=><option key={b}>{b}</option>)}</select>
                  <button className="btn btn-sm" aria-label={`Remove phrase ${index+1}`} onClick={()=>setSetting("severityPhrases",(settings.severityPhrases??[]).filter((_,i)=>i!==index))}>Remove</button>
                </div>)}
                <button className="btn btn-sm" onClick={()=>setSetting("severityPhrases",[...(settings.severityPhrases??[]),{phrase:"",band:"monitor"}])}>Add severity phrase</button>
              </div>
              {active?.sourceId && (
                <label className="template-check">
                  <input
                    type="checkbox"
                    checked={settings.allowAgencyNumbers}
                    onChange={(e) =>
                      setSetting("allowAgencyNumbers", e.target.checked)
                    }
                  />
                  This is a verified emergency service. Retain a number only
                  when it appears in its exact instruction.
                </label>
              )}
            </fieldset>
          </section>
          <section className="card template-preview">
            <h2>Try a source item</h2>
            <label>Affected country code (optional)<input maxLength={2} placeholder="e.g. SA for a Saudi Arabia travel alert" value={jurisdictionCountry} onChange={e=>{setJurisdictionCountry(e.target.value.toUpperCase());setPreview(null);}}/></label>
            <p>
              Paste the original source text. This preview creates no alert and
              sends no notification.
            </p>
            <label>
              Source
              <select
                value={sourceId}
                onChange={(e) => {
                  setSourceId(e.target.value);
                  setPreview(null);
                }}
              >
                <option value="">Choose a source</option>
                {sources.map((x) => (
                  <option key={x.id} value={x.id}>
                    {x.name}
                    {x.country ? ` (${x.country})` : ""}
                  </option>
                ))}
              </select>
            </label>
            <label>
              Category
              <select
                value={categoryId}
                onChange={(e) => {
                  setCategoryId(e.target.value);
                  setPreview(null);
                }}
              >
                <option value="">Choose a category</option>
                {categories.map((x) => (
                  <option key={x.id} value={x.id}>
                    {x.name}
                  </option>
                ))}
              </select>
            </label>
            <label>
              Source title
              <input
                value={title}
                onChange={(e) => {
                  setTitle(e.target.value);
                  setPreview(null);
                }}
              />
            </label>
            <label>
              Original warning label, if supplied
              <input
                value={nativeLevel}
                onChange={(e) => {
                  setNativeLevel(e.target.value);
                  setPreview(null);
                }}
              />
            </label>
            <label>
              Source text
              <textarea
                rows={8}
                value={description}
                onChange={(e) => {
                  setDescription(e.target.value);
                  setPreview(null);
                }}
              />
            </label>
            <label>Separate agency instruction field (optional)
              <textarea rows={4} value={sourceInstructions} onChange={e=>{setSourceInstructions(e.target.value);setPreview(null);}} placeholder="Paste the complete original instruction field, including conditions." />
            </label>
            <div className="template-actions">
              <button
                className="btn"
                disabled={busy || !canWrite || !sourceId || !categoryId}
                onClick={() => void runPreview(false)}
              >
                Check mapping
              </button>
              <button
                className="btn btn-primary"
                disabled={busy || !canWrite || !sourceId || !categoryId}
                onClick={() => void runPreview(true)}
              >
                Preview extracted alert
              </button>
            </div>
            <details>
              <summary>Preview safety profiles</summary>
              <p className="muted">
                These checkboxes only filter this preview. No personal profile
                choices are sent to the server.
              </p>
              <div className="template-cohorts">
                {COHORTS.map((tag) => (
                  <label key={tag}>
                    <input
                      type="checkbox"
                      checked={selectedProfiles.includes(tag)}
                      onChange={(e) =>
                        setSelectedProfiles(
                          e.target.checked
                            ? [...selectedProfiles, tag]
                            : selectedProfiles.filter((x) => x !== tag),
                        )
                      }
                    />
                    {labels[tag]}
                  </label>
                ))}
              </div>
            </details>
            {preview && (
              <div
                className="template-result"
                style={{
                  borderTopColor: preview.settings.bandColors[preview.band],
                }}
              >
                {!preview.suppressed&&previewIcon&&<img src={previewIcon} alt={`${previewIconCategory?.name} approved icon`} width={64} height={64} style={{objectFit:'contain',display:'block',marginBottom:10}}/>}
                {!preview.suppressed&&previewCategory&&<span style={{display:'inline-block',border:`1px solid ${previewCategory.color??'#333'}`,color:previewCategory.color??'#333',padding:'3px 9px',borderRadius:20,marginBottom:10}}>{previewCategory.name}</span>}
                <strong>
                  {preview.suppressed
                    ? "No warning card"
                    : `${preview.band.toUpperCase()}${preview.isAws ? " • AWS" : ""}`}
                </strong>
                <p>{preview.reason}</p>
                <p className="muted">Template: {preview.applied.join(" → ")}</p>
                {preview.output && (
                  <>
                    <h2>{preview.output.title}</h2>
                    {preview.output.contentDetails ? (
                      <AlertContentSections
                        content={preview.output.contentDetails}
                        profileTags={selectedProfiles}
                      />
                    ) : (
                      <>
                        <p>{preview.output.summary}</p>
                        <ul>
                          {preview.output.callsToAction.map((x, i) => (
                            <li key={i}>{x}</li>
                          ))}
                        </ul>
                      </>
                    )}
                  </>
                )}
              </div>
            )}
          </section>
        </div>
      )}
      {tab === "library" && (
        <section className="card">
          <h2>Reviewed guidance library</h2>
          <p>
            General suggestions fill a gap when an agency gives no actions. For
            You rows match a category and selected profile. Unapproved rows stay
            out of alerts.
          </p>
          <p>Imported Standing For You rows retain their original wording as drafts. Review their wording, choose the exact categories and confirm the country and warning bands before approving.</p>
          <label>Find guidance
            <input value={librarySearch} onChange={e => setLibrarySearch(e.target.value)} placeholder="Hazard, profile or wording" />
          </label>
          <button className="btn" disabled={!canWrite} onClick={newEntry}>
            Add guidance
          </button>
          {pack.library.length === 0 && (
            <p>No guidance has been added to this draft.</p>
          )}
          <div className="template-library">
            {pack.library.filter(x => [x.text, x.reference, ...x.categoryIds, ...x.profileTags.map(t => labels[t] ?? t)].join(" ").toLowerCase().includes(librarySearch.toLowerCase())).map((x) => (
              <article key={x.id}>
                <strong>
                  {x.approved ? "Approved" : "Draft"} •{" "}
                  {x.profileTags.length
                    ? x.profileTags.map((t) => labels[t] ?? t).join(", ")
                    : "General suggestions"}
                </strong>
                <p>{x.text}</p>
                <small>
                  {x.categoryIds.join(", ") || "Category review needed"} ·{" "}
                  {x.countries.join(", ") || "All countries"} ·{" "}
                  {x.bands.join(", ") || "All bands"}
                </small>
                <p><small>{x.reference}</small></p>
                <p>
                  <button
                    className="btn btn-sm"
                    disabled={!canWrite}
                    onClick={() => setEntry(structuredClone(x))}
                  >
                    Edit
                  </button>
                </p>
              </article>
            ))}
          </div>
        </section>
      )}
      {tab === "history" && (
        <section className="card">
          <h2>Published versions</h2>
          <p>
            Restore includes settings, guidance, routing and the prompt wording
            saved with that version. It creates a new version. It applies to
            future ingested alerts.
          </p>
          {[
            ...(state.published ? [state.published] : []),
            ...state.history,
          ].map((x) => (
            <article className="template-history" key={x.version}>
              <strong>Version {x.version}</strong>
              <span>{new Date(x.publishedAt).toLocaleString()}</span>
              <p>{x.reason}</p>
              {x.version !== state.published?.version && (
                <button
                  disabled={!canWrite || busy}
                  className="btn"
                  onClick={() =>
                    setConfirm({ action: "restore", version: x.version })
                  }
                >
                  Restore version {x.version}
                </button>
              )}
            </article>
          ))}
        </section>
      )}
      <div className="card template-save">
        <label>
          Change note
          <input
            value={reason}
            onChange={(e) => setReason(e.target.value)}
            placeholder="What changed and why"
          />
        </label>
        <div className="template-actions">
          <button
            className="btn"
            disabled={!canWrite || busy}
            onClick={() => void save("draft")}
          >
            Save draft
          </button>
          <button
            className="btn btn-primary"
            disabled={!canWrite || busy || reason.trim().length < 3}
            onClick={() => setConfirm({ action: "publish" })}
          >
            Publish for future alerts
          </button>
        </div>
        <small>
          Saving a draft does not change ingestion. Publishing includes current
          AI Prompts. Existing alert text is retained until its source is
          processed again.
        </small>
      </div>
      {confirm && (
        <div className="modal-backdrop">
          <div
            className="modal"
            role="dialog"
            aria-modal="true"
            aria-label="Publish template"
          >
            <h2>
              {confirm.action === "restore"
                ? `Restore version ${confirm.version}?`
                : "Publish this template?"}
            </h2>
            <p>
              Future alerts on this portal's connected backend will use this
              version. Check the preview and source settings first.
            </p>
            <label>
              Change note
              <input
                value={reason}
                onChange={(e) => setReason(e.target.value)}
              />
            </label>
            <div className="template-actions">
              <button
                className="btn"
                disabled={busy}
                onClick={() => setConfirm(null)}
              >
                Cancel
              </button>
              <button
                className="btn btn-primary"
                disabled={busy || reason.trim().length < 3}
                onClick={() => void save(confirm.action, confirm.version)}
              >
                {busy ? "Saving..." : "Confirm publish"}
              </button>
            </div>
          </div>
        </div>
      )}
      {entry && (
        <div className="modal-backdrop">
          <div
            className="modal template-guidance-modal"
            role="dialog"
            aria-modal="true"
            aria-label="Edit guidance"
          >
            <h2>Edit guidance</h2>
            <label>
              Suggested wording
              <textarea
                rows={4}
                value={entry.text}
                onChange={(e) => setEntry({ ...entry, text: e.target.value })}
              />
            </label>
            <label>
              Categories
              <select
                multiple
                value={entry.categoryIds}
                onChange={(e) =>
                  setEntry({
                    ...entry,
                    categoryIds: Array.from(
                      e.target.selectedOptions,
                      (x) => x.value,
                    ),
                  })
                }
              >
                {categories.map((x) => (
                  <option key={x.id} value={x.id}>
                    {x.name}
                  </option>
                ))}
              </select>
            </label>
            <label>
              Countries (comma separated, blank = all)
              <input
                defaultValue={entry.countries.join(",")}
                onBlur={(e) =>
                  setEntry({
                    ...entry,
                    countries: list(e.target.value.toUpperCase()),
                  })
                }
              />
            </label>
            <label>
              Bands (none selected = all)
              <select
                multiple
                value={entry.bands}
                onChange={(e) =>
                  setEntry({
                    ...entry,
                    bands: Array.from(
                      e.target.selectedOptions,
                      (x) => x.value as Band,
                    ),
                  })
                }
              >
                {BANDS.map((b) => (
                  <option key={b}>{b}</option>
                ))}
              </select>
            </label>
            <div className="template-cohorts">
              {COHORTS.map((tag) => (
                <label key={tag}>
                  <input
                    type="checkbox"
                    checked={entry.profileTags.includes(tag)}
                    onChange={(e) =>
                      setEntry({
                        ...entry,
                        profileTags: e.target.checked
                          ? [...entry.profileTags, tag]
                          : entry.profileTags.filter((x) => x !== tag),
                      })
                    }
                  />
                  {labels[tag]}
                </label>
              ))}
            </div>
            <label>
              Reference / review evidence
              <input
                value={entry.reference}
                onChange={(e) =>
                  setEntry({ ...entry, reference: e.target.value })
                }
              />
            </label>
            <label>
              Review date
              <input
                type="date"
                value={entry.reviewedAt ?? ""}
                onChange={(e) =>
                  setEntry({ ...entry, reviewedAt: e.target.value || null })
                }
              />
            </label>
            <label className="template-check">
              <input
                type="checkbox"
                checked={entry.approved}
                onChange={(e) =>
                  setEntry({ ...entry, approved: e.target.checked })
                }
              />
              Reviewed and approved for these categories, countries and bands
            </label>
            <div className="template-actions">
              <button className="btn" onClick={() => setEntry(null)}>
                Cancel
              </button>
              <button
                className="btn"
                onClick={() => {
                  update({
                    ...pack,
                    library: pack.library.filter((x) => x.id !== entry.id),
                  });
                  setEntry(null);
                }}
              >
                Remove from draft
              </button>
              <button
                className="btn btn-primary"
                disabled={
                  !entry.text.trim() ||
                  !entry.categoryIds.length ||
                  (entry.approved && (!entry.reference || !entry.reviewedAt))
                }
                onClick={() => {
                  update({
                    ...pack,
                    library: [
                      ...pack.library.filter((x) => x.id !== entry.id),
                      entry,
                    ],
                  });
                  setEntry(null);
                }}
              >
                Keep in draft
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
