import { XMLParser, XMLValidator } from "fast-xml-parser";
import { z } from "zod";

/**
 * Generic feed adapters (owner request, 16 Nov 2026): a new source is added
 * by registering it in admin with an adapter and a field mapping, not by
 * writing a parser. n8n fetches the feed and posts the raw body to
 * POST /api/webhook/feeds/:sourceId; these adapters turn it into the same
 * hazard objects the webhook already accepts, so every alert still goes
 * through the same validation, templates, guidance and display.
 *
 * Supported: CAP-AU (Atom feed of CAP alerts, or one CAP alert), GeoJSON
 * FeatureCollection, ArcGIS FeatureServer query JSON.
 * Agency text is copied, never rewritten here.
 */

export const ADAPTERS = ["cap_au", "geojson", "arcgis"] as const;
export type AdapterKey = (typeof ADAPTERS)[number];

/** Per-source field mapping for GeoJSON and ArcGIS feeds. Dotted paths allowed. */
export const adapterConfigSchema = z.object({
  idField: z.string().min(1).max(100),
  titleField: z.string().max(100).optional(),
  titlePrefix: z.string().max(80).optional(),
  descriptionFields: z.array(z.string().max(100)).min(1).max(10),
  levelField: z.string().max(100).optional(),
  /** Feed value -> agency level text, when the feed uses codes. */
  levelMap: z.record(z.string(), z.string().max(150)).optional(),
  instructionFields: z.array(z.string().max(100)).max(10).optional(),
  locationField: z.string().max(100).optional(),
  linkField: z.string().max(100).optional(),
  timeField: z.string().max(100).optional(),
  expiresField: z.string().max(100).optional(),
  /** Hours to keep an item when the feed gives no expiry. */
  defaultHours: z.number().int().min(1).max(720).optional(),
  categoryId: z.string().max(50).optional(),
  categoryField: z.string().max(100).optional(),
  categoryMap: z.record(z.string(), z.string().max(50)).optional(),
  /** Skip items whose value at [field] is in [values] (e.g. resolved). */
  exclude: z.object({ field: z.string().max(100), values: z.array(z.string().max(100)).max(50) }).optional(),
  /** Keep only CAP alerts from these senders (shared multi-agency feeds). */
  senders: z.array(z.string().max(200)).max(20).optional(),
  jurisdictionCountry: z.string().regex(/^[A-Z]{2}$/).optional(),
  minMagnitude: z.number().min(0).max(10).optional(),
  magnitudeField: z.string().max(100).optional(),
}).strict();
export type AdapterConfig = z.infer<typeof adapterConfigSchema>;

export interface FeedHazard {
  id: string;
  sourceId: string;
  title?: string;
  description: string;
  nativeWarningLevel?: string;
  sourceInstructions?: string[];
  latitude?: number;
  longitude?: number;
  locationName?: string;
  northeastLat?: number;
  northeastLng?: number;
  southwestLat?: number;
  southwestLng?: number;
  categoryId?: string;
  link?: string;
  occurredAt?: string;
  expiresAt?: string;
  jurisdictionCountry?: string;
}

export interface AdapterResult {
  hazards: FeedHazard[];
  skipped: { id: string; reason: string }[];
  cancelledIds: string[];
}

const list = <T>(v: T | T[] | undefined | null): T[] => (v == null ? [] : Array.isArray(v) ? v : [v]);
const str = (v: unknown): string => (typeof v === "string" ? v.trim() : typeof v === "number" ? String(v) : "");
const get = (obj: unknown, path?: string): unknown =>
  !path ? undefined : path.split(".").reduce<unknown>((o, k) => (o && typeof o === "object" ? (o as Record<string, unknown>)[k] : undefined), obj);
const iso = (v: unknown): string | undefined => {
  if (v == null || v === "") return undefined;
  const d = typeof v === "number" ? new Date(v > 1e12 ? v : v * 1000) : new Date(str(v));
  return Number.isFinite(d.getTime()) ? d.toISOString() : undefined;
};
const clip = (s: string, n: number) => (s.length > n ? `${s.slice(0, n - 1)}…` : s);
const safeId = (s: string) => s.replace(/[^A-Za-z0-9_.:-]+/g, "-").slice(0, 100);
const httpsLink = (v: unknown): string | undefined => {
  const s = str(v);
  try {
    const u = new URL(s);
    return u.protocol === "https:" || u.protocol === "http:" ? u.toString() : undefined;
  } catch {
    return undefined;
  }
};

/** Bounding box and centre from lon/lat pairs. */
const boxOf = (points: [number, number][]) => {
  const ok = points.filter(([lon, lat]) => Number.isFinite(lat) && Number.isFinite(lon) && Math.abs(lat) <= 90 && Math.abs(lon) <= 180);
  if (!ok.length) return {};
  const lats = ok.map((p) => p[1]), lons = ok.map((p) => p[0]);
  const n = Math.max(...lats), s = Math.min(...lats), e = Math.max(...lons), w = Math.min(...lons);
  return {
    latitude: (n + s) / 2, longitude: (e + w) / 2,
    ...(ok.length > 1 && { northeastLat: n, northeastLng: e, southwestLat: s, southwestLng: w }),
  };
};

const flattenCoords = (c: unknown, out: [number, number][] = []): [number, number][] => {
  if (Array.isArray(c) && typeof c[0] === "number" && typeof c[1] === "number") out.push([c[0], c[1]]);
  else if (Array.isArray(c)) for (const x of c) flattenCoords(x, out);
  return out;
};

// --- CAP-AU -----------------------------------------------------------------

const capParams = (info: any): Record<string, string> =>
  Object.fromEntries(list<any>(info?.parameter).map((p) => [str(p.valueName), str(p.value)]));

const capPoints = (area: any): [number, number][] => {
  const pts: [number, number][] = [];
  for (const poly of list<string>(area?.polygon)) {
    for (const pair of str(poly).split(/\s+/)) {
      const [lat, lon] = pair.split(",").map(Number);
      if (Number.isFinite(lat) && Number.isFinite(lon)) pts.push([lon!, lat!]);
    }
  }
  for (const circle of list<string>(area?.circle)) {
    const [centre] = str(circle).split(/\s+/);
    const [lat, lon] = (centre ?? "").split(",").map(Number);
    if (Number.isFinite(lat) && Number.isFinite(lon)) pts.push([lon!, lat!]);
  }
  return pts;
};

const LEVEL_KEYS = ["AustralianWarningSystem:WarningLevel", "WarningLevel", "warningLevel", "AWS_Level"];

export const capAuToHazards = (xml: string, sourceId: string, config: Partial<AdapterConfig> = {}): AdapterResult => {
  if (xml.length > 5_000_000 || /<!DOCTYPE|<!ENTITY/i.test(xml) || XMLValidator.validate(xml) !== true)
    throw new Error("The feed is not valid XML.");
  const parsed = new XMLParser({ ignoreAttributes: false, attributeNamePrefix: "@", removeNSPrefix: true, parseTagValue: false, trimValues: true }).parse(xml);
  const alerts: any[] = parsed.alert
    ? [parsed.alert]
    : list<any>(parsed.feed?.entry).map((e) => e?.content?.alert ?? e?.alert).filter(Boolean);
  if (!parsed.alert && !parsed.feed) throw new Error("The feed is not a CAP alert or an Atom feed of CAP alerts.");
  const out: AdapterResult = { hazards: [], skipped: [], cancelledIds: [] };
  for (const a of alerts) {
    const id = safeId(str(a.identifier));
    if (!id) continue;
    if (str(a.status) !== "Actual" || str(a.scope) !== "Public") {
      out.skipped.push({ id, reason: `Not a public, actual alert (${str(a.status)}, ${str(a.scope)}).` });
      continue;
    }
    if (config.senders?.length && !config.senders.includes(str(a.sender))) {
      out.skipped.push({ id, reason: `Sender ${str(a.sender)} is not this source.` });
      continue;
    }
    if (str(a.msgType) === "Cancel") {
      out.cancelledIds.push(...str(a.references).split(/\s+/).map((r) => safeId(r.split(",")[1] ?? "")).filter(Boolean), id);
      continue;
    }
    const info = list<any>(a.info).find((i) => /^en/i.test(str(i.language) || "en-AU")) ?? list<any>(a.info)[0];
    if (!info) {
      out.skipped.push({ id, reason: "No alert details." });
      continue;
    }
    const params = capParams(info);
    const level = LEVEL_KEYS.map((k) => params[k]).find(Boolean) ?? "";
    const areas = list<any>(info.area);
    const where = areas.map((x) => str(x.areaDesc)).filter(Boolean).join("; ");
    const description = [str(info.headline), str(info.description), level ? `Warning level: ${level}` : ""].filter(Boolean).join("\n\n");
    if (!description) {
      out.skipped.push({ id, reason: "No text." });
      continue;
    }
    const instructions = str(info.instruction);
    out.hazards.push({
      id, sourceId,
      title: clip(str(info.headline) || str(info.event) || "Alert", 200),
      description: clip(description, 50000),
      ...(level && { nativeWarningLevel: clip(level, 150) }),
      ...(instructions && { sourceInstructions: [clip(instructions, 50000)] }),
      ...boxOf(areas.flatMap(capPoints)),
      ...(where && { locationName: clip(where, 200) }),
      ...(httpsLink(info.web) && { link: httpsLink(info.web)! }),
      ...(iso(info.onset ?? info.effective ?? a.sent) && { occurredAt: iso(info.onset ?? info.effective ?? a.sent)! }),
      ...(iso(info.expires) && { expiresAt: iso(info.expires)! }),
      ...(config.categoryId && { categoryId: config.categoryId }),
      ...(config.jurisdictionCountry && { jurisdictionCountry: config.jurisdictionCountry }),
    });
  }
  return out;
};

// --- GeoJSON and ArcGIS -------------------------------------------------------

const mapped = (props: unknown, geometryPoints: [number, number][], sourceId: string, c: AdapterConfig, now: Date): FeedHazard | { skip: string; id: string } => {
  const rawId = str(get(props, c.idField));
  const id = safeId(rawId);
  if (!id) return { skip: "No id.", id: "?" };
  if (c.exclude && c.exclude.values.map((v) => v.toLowerCase()).includes(str(get(props, c.exclude.field)).toLowerCase()))
    return { skip: `Excluded (${c.exclude.field}).`, id };
  if (c.minMagnitude !== undefined) {
    const m = Number(get(props, c.magnitudeField ?? "magnitude"));
    if (!Number.isFinite(m) || m < c.minMagnitude) return { skip: `Below magnitude ${c.minMagnitude}.`, id };
  }
  const description = c.descriptionFields.map((f) => str(get(props, f))).filter(Boolean).join("\n\n");
  if (!description) return { skip: "No text.", id };
  const rawLevel = str(get(props, c.levelField));
  const level = rawLevel ? (c.levelMap?.[rawLevel] ?? rawLevel) : "";
  const descWithLevel = level && !description.toLowerCase().includes(level.toLowerCase()) ? `${description}\n\nWarning level: ${level}` : description;
  const title = [c.titlePrefix, str(get(props, c.titleField))].filter(Boolean).join(" ") || clip(description, 120);
  const occurred = iso(get(props, c.timeField));
  const expires = iso(get(props, c.expiresField)) ??
    (c.defaultHours ? new Date((occurred ? Date.parse(occurred) : now.getTime()) + c.defaultHours * 3_600_000).toISOString() : undefined);
  const rawCategory = str(get(props, c.categoryField));
  const categoryId = (rawCategory && c.categoryMap?.[rawCategory]) || c.categoryId;
  const instructions = (c.instructionFields ?? []).map((f) => str(get(props, f))).filter(Boolean);
  return {
    id, sourceId,
    title: clip(title, 200),
    description: clip(descWithLevel, 50000),
    ...(level && { nativeWarningLevel: clip(level, 150) }),
    ...(instructions.length && { sourceInstructions: instructions.map((x) => clip(x, 50000)) }),
    ...boxOf(geometryPoints),
    ...(str(get(props, c.locationField)) && { locationName: clip(str(get(props, c.locationField)), 200) }),
    ...(httpsLink(get(props, c.linkField)) && { link: httpsLink(get(props, c.linkField))! }),
    ...(occurred && { occurredAt: occurred }),
    ...(expires && { expiresAt: expires }),
    ...(categoryId && { categoryId }),
    ...(c.jurisdictionCountry && { jurisdictionCountry: c.jurisdictionCountry }),
  };
};

const collect = (items: { props: unknown; points: [number, number][] }[], sourceId: string, c: AdapterConfig, now: Date): AdapterResult => {
  const out: AdapterResult = { hazards: [], skipped: [], cancelledIds: [] };
  for (const it of items.slice(0, 2000)) {
    const r = mapped(it.props, it.points, sourceId, c, now);
    if ("skip" in r) out.skipped.push({ id: r.id, reason: r.skip });
    else out.hazards.push(r);
  }
  return out;
};

export const geojsonToHazards = (json: unknown, sourceId: string, c: AdapterConfig, now = new Date()): AdapterResult => {
  const fc = json as { type?: string; features?: unknown[] };
  if (fc?.type !== "FeatureCollection" || !Array.isArray(fc.features)) throw new Error("The feed is not a GeoJSON FeatureCollection.");
  return collect(
    fc.features.map((f: any) => ({ props: { ...(f?.properties ?? {}), id: f?.id ?? f?.properties?.id }, points: flattenCoords(f?.geometry?.coordinates) })),
    sourceId, c, now,
  );
};

export const arcgisToHazards = (json: unknown, sourceId: string, c: AdapterConfig, now = new Date()): AdapterResult => {
  const fs = json as { features?: unknown[]; error?: { message?: string } };
  if (fs?.error) throw new Error(`ArcGIS error: ${fs.error.message ?? "unknown"}`);
  if (!Array.isArray(fs?.features)) throw new Error("The feed is not an ArcGIS query result.");
  return collect(
    fs.features.map((f: any) => {
      const g = f?.geometry ?? {};
      const pts: [number, number][] = typeof g.x === "number" && typeof g.y === "number" ? [[g.x, g.y]] : flattenCoords(g.rings ?? g.paths ?? []);
      return { props: f?.attributes ?? {}, points: pts };
    }),
    sourceId, c, now,
  );
};

/** Runs the adapter a source is registered with. */
export const runAdapter = (adapter: string, raw: string, sourceId: string, config: unknown, now = new Date()): AdapterResult => {
  if (adapter === "cap_au") return capAuToHazards(raw, sourceId, (config ?? {}) as Partial<AdapterConfig>);
  if (!(ADAPTERS as readonly string[]).includes(adapter))
    throw new Error(`Unknown adapter "${adapter}". Use one of: ${ADAPTERS.join(", ")}.`);
  const c = adapterConfigSchema.parse(config);
  let json: unknown;
  try {
    json = JSON.parse(raw);
  } catch {
    throw new Error("The feed is not valid JSON.");
  }
  if (adapter === "geojson") return geojsonToHazards(json, sourceId, c, now);
  if (adapter === "arcgis") return arcgisToHazards(json, sourceId, c, now);
  throw new Error(`Unknown adapter "${adapter}". Use one of: ${ADAPTERS.join(", ")}.`);
};
