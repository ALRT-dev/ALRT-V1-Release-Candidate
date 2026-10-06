/**
 * Ask ALRT daily allowance rules. Pure, no database, so they can be checked
 * with no server (see src/scripts/verify_ask_alrt_backend.ts).
 *
 * Daily AI-question caps (master spec 28 Sep 2026, section 14): ALRT Free 3,
 * ALRT + Individual (or its trial) 10, per LOCAL calendar day, once per
 * account. Group sponsorship never raises it.
 *
 * Counting unit (decided 3 Oct 2026): every question and answer counts as 1,
 * whether it is answered from the library, the emergency-number lookup or the
 * AI. At the cap the local emergency number is still shown (and not counted).
 * A request that fails (model error, assistant switched off) is not counted.
 */
export const AI_DAILY_LIMIT = { free: 3, individual: 10 } as const;

/** A time zone may change at most once per this window (travel, DST-safe). */
export const TZ_CHANGE_MIN_MS = 24 * 60 * 60 * 1000;

export type AskPlan = "free" | "individual";

/** True for a time zone Intl accepts (rejects junk and offsets). */
export function isValidTimeZone(tz: unknown): tz is string {
  if (typeof tz !== "string" || tz.length === 0 || tz.length > 64) return false;
  try {
    new Intl.DateTimeFormat("en-US", { timeZone: tz });
    return true;
  } catch {
    return false;
  }
}

/** A stored zone is usable if it is "offset:<min>" or a real IANA name. */
export function isUsableZone(z: string | null | undefined): z is string {
  return !!z && (z.startsWith("offset:") || isValidTimeZone(z));
}

/**
 * A zone the day can be counted in: a valid IANA name, or "offset:<min>"
 * built from the app's current UTC offset (-720..+840 minutes).
 */
export function zoneFromRequest(timeZone: unknown, utcOffsetMinutes: unknown): string | null {
  if (isValidTimeZone(timeZone)) return timeZone;
  if (
    typeof utcOffsetMinutes === "number" &&
    Number.isInteger(utcOffsetMinutes) &&
    utcOffsetMinutes >= -720 &&
    utcOffsetMinutes <= 840
  ) {
    return `offset:${utcOffsetMinutes}`;
  }
  return null;
}

/** YYYYMMDD of [d] in [timeZone] (server clock, never the device's). */
export function localDayKey(d: Date, timeZone: string): string {
  if (timeZone.startsWith("offset:")) {
    const shifted = new Date(d.getTime() + Number(timeZone.slice(7)) * 60_000);
    return `${shifted.getUTCFullYear()}${String(shifted.getUTCMonth() + 1).padStart(2, "0")}${String(
      shifted.getUTCDate(),
    ).padStart(2, "0")}`;
  }
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(d);
  const get = (t: string) => parts.find((p) => p.type === t)?.value ?? "00";
  return `${get("year")}${get("month")}${get("day")}`;
}

/** Message shown when the allowance is used up. */
export function limitMessage(plan: AskPlan): string {
  return plan === "individual"
    ? `You've used today's ${AI_DAILY_LIMIT.individual} Ask ALRT questions. They reset tomorrow.`
    : `You've used today's ${AI_DAILY_LIMIT.free} Ask ALRT questions. They reset tomorrow, or ALRT + Individual gives you ${AI_DAILY_LIMIT.individual} a day.`;
}
