/**
 * Push payload helpers, pure (no Firebase / Prisma) so they can be verified
 * without a database or network.
 *
 * FCM and APNs cap a message at about 4 KB including the notification title
 * and body. data.payload is the JSON of the hazard, so a long description
 * (feeds can send 10,000 characters) made the send fail and nobody got the
 * alert. The app opens a hazard by id and refetches it (ViewHazardScreen
 * loads by id; the push inbox, the band-matched actions and the tap handler
 * read only id and severityBand), so a bounded payload loses nothing it uses.
 */

/** Serialized data.payload must stay under this many bytes (UTF-8). */
export const PUSH_PAYLOAD_MAX_BYTES = 3500;

/** Notification body cap (characters). The OS truncates the tray text anyway. */
export const PUSH_BODY_MAX_CHARS = 240;

/** Keys always kept, whatever the size pressure. */
const CORE_KEYS = new Set([
  "id",
  "title",
  "severity",
  "severityBand",
  "categoryId",
  "shape",
  "isAwsCompliant",
  "reportedById",
  "sourceId",
  "latitude",
  "longitude",
  "createdAt",
  "expiresAt",
  "notificationType",
]);

const TEXT_STEPS = [400, 200, 120, 60];

const jsonBytes = (v: unknown): number =>
  Buffer.byteLength(JSON.stringify(v), "utf8");

/** Truncates to at most `max` characters, never splitting a surrogate pair. */
export const truncateText = (text: string, max: number): string => {
  if (text.length <= max) return text;
  let cut = max - 1;
  const code = text.charCodeAt(cut - 1);
  if (code >= 0xd800 && code <= 0xdbff) cut -= 1;
  return `${text.slice(0, Math.max(cut, 0))}…`;
};

/** Rounds a coordinate to 2 decimals (about 1 km). */
export const roundCoordinate = (n: unknown): unknown =>
  typeof n === "number" && Number.isFinite(n) ? Math.round(n * 100) / 100 : n;

/**
 * Returns `data` with long strings shortened and, if still too large,
 * heavy non-core fields dropped, so JSON.stringify(result) is at most
 * `maxBytes` bytes. Under the limit it returns the input unchanged.
 */
export const boundPushPayload = <T extends Record<string, unknown>>(
  data: T,
  maxBytes: number = PUSH_PAYLOAD_MAX_BYTES,
): Record<string, unknown> => {
  if (jsonBytes(data) <= maxBytes) return data;

  const out: Record<string, unknown> = { ...data };
  for (const key of ["latitude", "longitude"]) {
    if (key in out) out[key] = roundCoordinate(out[key]);
  }

  // Shorten long text, then call-to-action lists, in steps until it fits.
  for (const limit of TEXT_STEPS) {
    for (const [k, v] of Object.entries(out)) {
      if (typeof v === "string" && k !== "id" && v.length > limit) {
        out[k] = truncateText(v, limit);
      } else if (Array.isArray(v)) {
        out[k] = v
          .slice(0, 3)
          .map((x) => (typeof x === "string" ? truncateText(x, limit) : x));
      }
    }
    if (jsonBytes(out) <= maxBytes) return out;
  }

  // Still too big: drop the largest non-core fields until it fits.
  const droppable = Object.keys(out)
    .filter((k) => !CORE_KEYS.has(k))
    .sort((a, b) => jsonBytes(out[b]) - jsonBytes(out[a]));
  for (const k of droppable) {
    delete out[k];
    if (jsonBytes(out) <= maxBytes) return out;
  }

  // Last resort: core keys only, titles shortened.
  for (const k of Object.keys(out)) {
    const v = out[k];
    if (typeof v === "string" && k !== "id") out[k] = truncateText(v, 120);
  }
  return out;
};

/**
 * The dedup key of one push EVENT about a hazard. The creation time alone
 * meant an escalation of the same hazard id (watchAndAct to emergency, band
 * action to critical) was treated as the same event and never pushed. The
 * level now rides in the key: an escalation or a de-escalation is a new
 * event, an identical re-ingest keeps the same key and stays deduplicated.
 */
export const hazardPushEventKey = (hazard: {
  createdAt?: Date | string | null;
  severity?: string | null;
  severityBand?: string | null;
  isAwsCompliant?: boolean | null;
}): string => {
  const at = hazard.createdAt ? new Date(hazard.createdAt) : null;
  const base =
    at && !isNaN(at.getTime()) ? `created:${at.toISOString()}` : "created";
  const level = [
    hazard.isAwsCompliant ? "aws" : "off",
    hazard.severity ?? "-",
    hazard.severityBand ?? "-",
  ].join("-");
  return `${base}:${level}`;
};
