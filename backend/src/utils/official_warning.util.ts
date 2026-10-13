/**
 * Official warnings are always on (product owner rule).
 *
 * An official AWS Emergency Warning, and any other verified official alert
 * at the critical band, reaches the user whatever category filter or
 * notification toggle they have. Location / radius, block and privacy rules
 * still apply: this only lifts the category and the per-type toggles.
 *
 * Kept free of Prisma client and Firebase imports so the same predicate and
 * SQL fragments are used by the hazard list query, the map query, the push
 * recipient query and the verify script, with no database needed.
 */

export interface OfficialWarningFields {
  isAwsCompliant?: boolean | null | undefined;
  severity?: string | null | undefined;
  severityBand?: string | null | undefined;
  reportedById?: string | null | undefined;
}

/** AWS Emergency Warning: isAwsCompliant and severity emergency. */
export const isAwsEmergencyWarning = (h: OfficialWarningFields): boolean =>
  h.isAwsCompliant === true && h.severity === "emergency";

/** Official (not user-reported) alert at the critical band. */
export const isOfficialCritical = (h: OfficialWarningFields): boolean =>
  !h.reportedById && h.severityBand === "critical";

/** True when the hazard may never be hidden by a category filter or toggle. */
export const isAlwaysOnOfficialWarning = (h: OfficialWarningFields): boolean =>
  isAwsEmergencyWarning(h) || isOfficialCritical(h);

/** Prisma where input for the always-on set (hazard list queries). */
export const ALWAYS_ON_OFFICIAL_WHERE = {
  OR: [
    { AND: [{ isAwsCompliant: true }, { severity: "emergency" as const }] },
    { AND: [{ reportedById: null }, { severityBand: "critical" as const }] },
  ],
};

/** Raw SQL for the always-on set against the `h` hazard alias. No params. */
export const ALWAYS_ON_OFFICIAL_SQL =
  `((h."isAwsCompliant" = true AND h.severity = 'emergency'::"HazardSeverity")` +
  ` OR (h."reportedById" IS NULL AND h."severityBand" = 'critical'::"HazardSeverityBand"))`;

/**
 * Prisma version of the same rule: returns the conditions to AND into the
 * query, (all gated conditions) OR always-on when exempt.
 */
export const withAlwaysOnExemptionWhere = <T>(
  gated: T[],
  exempt: boolean,
): (T | { OR: unknown[] })[] => {
  if (!exempt || gated.length === 0) return gated;
  return [{ OR: [{ AND: gated }, ALWAYS_ON_OFFICIAL_WHERE] }];
};

/**
 * Combines the user-chosen category / toggle conditions with the always-on
 * set: (all gated conditions) OR always-on. Returns the conditions to AND
 * into the query. With no gated conditions there is nothing to exempt from.
 */
export const withAlwaysOnExemptionSql = (
  gated: string[],
  exempt: boolean,
): string[] => {
  if (!exempt || gated.length === 0) return gated;
  return [`((${gated.join(" AND ")}) OR ${ALWAYS_ON_OFFICIAL_SQL})`];
};

/**
 * AWS Emergency Warnings are always on: awsEmergency can never be stored as
 * false, whatever a client sends. Applied on every write and read path.
 */
export const withAwsEmergencyAlwaysOn = <T extends { awsEmergency?: boolean }>(
  settings: T,
): T => ({ ...settings, awsEmergency: true });

export type PushSettingKey =
  | "awsEmergency"
  | "awsWatchAndAct"
  | "awsAdvice"
  | "officialNonAws"
  | "userReported";

/** Which per-type notification switch governs this hazard. */
export const pushSettingKeyFor = (
  h: OfficialWarningFields,
): PushSettingKey => {
  if (h.reportedById) return "userReported";
  if (!h.isAwsCompliant) return "officialNonAws";
  if (h.severity === "emergency") return "awsEmergency";
  if (h.severity === "watchAndAct") return "awsWatchAndAct";
  // advice, and the AWS info / unknown levels, are filed under Advice
  return "awsAdvice";
};

/**
 * The `user` part of the push-recipient query that depends on the user's
 * notification settings. An always-on official warning ignores every
 * switch and the category list (it needs no settings row either); anything
 * else needs its switch on and the hazard's category subscribed.
 */
export const buildPushSettingsUserWhere = (
  h: OfficialWarningFields,
  categoryIdToCheck: string,
): Record<string, unknown> => {
  if (isAlwaysOnOfficialWarning(h)) return {};
  return {
    pushNotificationSettings: {
      some: {
        [pushSettingKeyFor(h)]: true,
        subscribedCategoryIds: { has: categoryIdToCheck },
      },
    },
  };
};
