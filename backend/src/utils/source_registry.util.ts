import {
  HazardSourceShape,
  HazardSeveritySystem,
  SeverityLevelHandling,
  HazardSeverityBand,
  SourcePushPolicy,
} from "@prisma/client";

/**
 * Source registry — the "five-system One Glance" contract (V3 checklist §1).
 *
 * Shape encodes the source system, colour encodes urgency, glyph encodes the
 * hazard. This module is the single backend source of truth for how alerts from
 * a given source are rendered and pushed. The `HazardSource` row stores these
 * fields; this util provides the seed defaults, the shape-resolution rule, and
 * the internal-band cap so seed scripts and the render/push path never drift.
 */

/** The five source systems in the One Glance model. */
export type SourceSystemKey =
  | "aws"
  | "official"
  | "community"
  | "gdacs"
  | "alrtIntel";

/** The registry fields that describe a source's render + push behaviour. */
export interface SourceRegistryProfile {
  shape: HazardSourceShape;
  severitySystem: HazardSeveritySystem;
  levelHandling: SeverityLevelHandling | null;
  /** Ceiling on the internal band, or null for no cap. */
  maxInternalBand: HazardSeverityBand | null;
  pushPolicy: SourcePushPolicy;
}

/**
 * The §1 seed contract, verbatim:
 *
 * - AWS → triangle · writes level text verbatim · pushes at every level.
 * - Official agencies → diamond · band colour only, band word never rendered.
 * - Community → circle · category colour (never severity) · caps at `action` ·
 *   pushes only after the nearby-confirmation threshold, never on submission.
 * - GDACS → square · level-exempt · "GDACS {colour}" verbatim · Green = no push.
 * - ALRT Intel → shield · advisory push at most.
 */
export const SOURCE_REGISTRY_DEFAULTS: Record<
  SourceSystemKey,
  SourceRegistryProfile
> = {
  aws: {
    shape: HazardSourceShape.triangle,
    severitySystem: HazardSeveritySystem.awsLevel,
    levelHandling: SeverityLevelHandling.verbatim,
    maxInternalBand: null,
    pushPolicy: SourcePushPolicy.everyLevel,
  },
  official: {
    shape: HazardSourceShape.diamond,
    severitySystem: HazardSeveritySystem.band,
    levelHandling: SeverityLevelHandling.bandColourOnly,
    maxInternalBand: null,
    pushPolicy: SourcePushPolicy.bandThreshold,
  },
  community: {
    shape: HazardSourceShape.circle,
    severitySystem: HazardSeveritySystem.category,
    levelHandling: SeverityLevelHandling.categoryColour,
    maxInternalBand: HazardSeverityBand.action,
    pushPolicy: SourcePushPolicy.afterConfirmation,
  },
  gdacs: {
    shape: HazardSourceShape.square,
    severitySystem: HazardSeveritySystem.gdacsColour,
    levelHandling: SeverityLevelHandling.levelExempt,
    maxInternalBand: null,
    pushPolicy: SourcePushPolicy.greenExempt,
  },
  alrtIntel: {
    shape: HazardSourceShape.shield,
    severitySystem: HazardSeveritySystem.advisory,
    levelHandling: null,
    maxInternalBand: null,
    pushPolicy: SourcePushPolicy.advisoryOnly,
  },
};

/** The render default when a source carries no explicit shape. */
export const DEFAULT_SHAPE = HazardSourceShape.diamond;

/**
 * Resolves the marker shape for a single hazard, per §1:
 * `reportedById → circle, else source.shape ?? diamond`.
 *
 * User reports are always circles regardless of the source's configured shape,
 * so community content can never borrow an official system's shape.
 */
export const resolveHazardShape = (params: {
  reportedById?: string | null;
  sourceShape?: HazardSourceShape | null;
}): HazardSourceShape => {
  if (params.reportedById) return HazardSourceShape.circle;
  return params.sourceShape ?? DEFAULT_SHAPE;
};

const BAND_ORDER: HazardSeverityBand[] = [
  HazardSeverityBand.info,
  HazardSeverityBand.monitor,
  HazardSeverityBand.action,
  HazardSeverityBand.critical,
];

/**
 * Caps an internal band at the source's ceiling (e.g. community never exceeds
 * `action`). Returns `band` unchanged when the source has no cap.
 */
export const capInternalBand = (
  band: HazardSeverityBand,
  maxInternalBand: HazardSeverityBand | null | undefined
): HazardSeverityBand => {
  if (!maxInternalBand) return band;
  const current = BAND_ORDER.indexOf(band);
  const ceiling = BAND_ORDER.indexOf(maxInternalBand);
  if (current < 0 || ceiling < 0) return band;
  return current > ceiling ? maxInternalBand : band;
};

/** Result of applying the source registry's push policy to one alert event. */
export interface SourcePushDecision {
  send: boolean;
  /** Critical/urgent delivery is reserved for genuinely critical events. */
  urgent: boolean;
}

/**
 * Enforces the notification floor from the classification standard:
 * official non-AWS sources push only Action/Critical; community reports wait
 * for three independent nearby confirmations; GDACS Green is suppressed; and
 * ALRT Intel advisories are quiet (non-urgent). AWS sources may notify at all
 * levels because their native warning level is authoritative.
 */
export const decideSourcePush = (params: {
  policy: SourcePushPolicy;
  severityBand: HazardSeverityBand;
  reportedById?: string | null;
  corroborationCount?: number;
  severitySystem?: HazardSeveritySystem | null;
  title?: string | null;
}): SourcePushDecision => {
  switch (params.policy) {
    case SourcePushPolicy.everyLevel:
      return {
        send: true,
        urgent: params.severityBand === HazardSeverityBand.critical,
      };
    case SourcePushPolicy.bandThreshold:
      return {
        send:
          params.severityBand === HazardSeverityBand.action ||
          params.severityBand === HazardSeverityBand.critical,
        urgent: params.severityBand === HazardSeverityBand.critical,
      };
    case SourcePushPolicy.afterConfirmation:
      return {
        send:
          Boolean(params.reportedById) &&
          (params.corroborationCount ?? 0) >= 3,
        urgent: false,
      };
    case SourcePushPolicy.greenExempt:
      return {
        send: !(
          params.severitySystem === HazardSeveritySystem.gdacsColour &&
          /^\s*GDACS\s+Green\b/i.test(params.title ?? "")
        ),
        urgent: false,
      };
    case SourcePushPolicy.advisoryOnly:
      return { send: true, urgent: false };
    default:
      return { send: false, urgent: false };
  }
};
