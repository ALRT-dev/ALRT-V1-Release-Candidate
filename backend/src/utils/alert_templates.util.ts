import { z } from "zod";
import { isInfoOverride } from "./ingestion.severity.util.js";
import { initialGuidance } from "./alert_template_seed.util.js";

export const bands = ["info", "monitor", "action", "critical"] as const;
const bandSchema = z.enum(bands);
const colour = z.string().regex(/^#[0-9a-fA-F]{6}$/);
const id = z.string().trim().min(1).max(120);
export const settingsSchema = z
  .object({
    language: z.string().trim().min(2).max(40),
    promptId: id.nullable(),
    additionalInstructions: z.string().max(12000),
    bandColors: z
      .object({
        info: colour,
        monitor: colour,
        action: colour,
        critical: colour,
      })
      .strict(),
    nativeLevelMappings: z
      .array(
        z
          .object({
            level: z.string().trim().min(1).max(120),
            band: bandSchema,
          })
          .strict(),
      )
      .max(50),
    severityPhrases: z.array(z.object({phrase: z.string().trim().min(3).max(120), band: bandSchema}).strict()).max(150).optional(),
    iconCategoryId: id.nullable(),
    allowAgencyNumbers: z.boolean(),
  })
  .strict();
const overrideSchema = z
  .object({
    id,
    name: z.string().trim().min(1).max(120),
    country: z
      .string()
      .regex(/^[A-Z]{2}$/)
      .nullable(),
    sourceId: id.nullable(),
    settings: settingsSchema.partial(),
  })
  .strict();
export const libraryEntrySchema = z
  .object({
    id,
    text: z.string().trim().min(1).max(500),
    categoryIds: z.array(id).max(30),
    countries: z.array(z.string().regex(/^[A-Z]{2}$/)).max(50),
    bands: z.array(bandSchema).max(4),
    profileTags: z.array(z.enum(["older", "kids", "mobility", "medical", "deaf", "vision", "visitor", "worker", "pets"])).max(9),
    approved: z.boolean(),
    reference: z.string().trim().max(1000),
    reviewedAt: z
      .string()
      .regex(/^\d{4}-\d{2}-\d{2}$/)
      .nullable(),
  })
  .strict()
  .superRefine((entry, ctx) => {
    if (entry.approved && !entry.categoryIds.length)
      ctx.addIssue({ code: "custom", message: "Approved guidance needs at least one matching category." });
    if (entry.approved && (!entry.reference || !entry.reviewedAt))
      ctx.addIssue({
        code: "custom",
        message: "Approved guidance needs a reference and review date.",
      });
    if (entry.approved && /\byou must\b|\byou are required to\b/i.test(entry.text))
      ctx.addIssue({
        code: "custom",
        message:
          "Use suggestive wording for ALRT guidance, such as consider or may help.",
      });
    if (entry.approved && /[\u2013\u2014]/.test(entry.text))
      ctx.addIssue({ code: "custom", message: "Use plain hyphens." });
  });
export const templatePackSchema = z
  .object({
    defaults: settingsSchema,
    overrides: z.array(overrideSchema).max(200),
    library: z.array(libraryEntrySchema).max(400),
  })
  .strict()
  .superRefine((pack, ctx) => {
    if (
      pack.defaults.allowAgencyNumbers ||
      pack.overrides.some((x) => x.settings.allowAgencyNumbers && !x.sourceId)
    )
      ctx.addIssue({
        code: "custom",
        message:
          "An emergency-number exception must be attached to a specific verified emergency-service source.",
      });
    const scopes = new Set<string>(),
      ids = new Set<string>();
    for (const item of pack.overrides) {
      const key = `${item.country || "*"}:${item.sourceId || "*"}`;
      if (!item.country && !item.sourceId)
        ctx.addIssue({
          code: "custom",
          message: "An override needs a country or source.",
        });
      if (scopes.has(key) || ids.has(item.id))
        ctx.addIssue({
          code: "custom",
          message: "Each override needs a unique scope and ID.",
        });
      scopes.add(key);
      ids.add(item.id);
    }
    if (new Set(pack.library.map((x) => x.id)).size !== pack.library.length)
      ctx.addIssue({ code: "custom", message: "Guidance IDs must be unique." });
    for (const setting of [
      pack.defaults,
      ...pack.overrides.map((x) => x.settings),
    ]) {
      const levels =
        setting.nativeLevelMappings?.map((x) => x.level.toLowerCase()) || [];
      if (new Set(levels).size !== levels.length)
        ctx.addIssue({
          code: "custom",
          message: "Native warning labels must be unique in each mapping.",
        });
    }
  });
export type TemplatePack = z.infer<typeof templatePackSchema>;
export type TemplateSettings = z.infer<typeof settingsSchema>;
export type GuidanceEntry = z.infer<typeof libraryEntrySchema>;
export type TemplateBand = (typeof bands)[number];
export const defaultTemplatePack = (): TemplatePack => ({
  defaults: {
    language: "en-AU",
    promptId: null,
    additionalInstructions:
      "Extract 2-3 concise facts supported by the agency source. Retain the affected area, original warning level and all essential official instructions. Do not invent missing facts. ALRT suggestions and For You guidance come from the approved library.",
    bandColors: {
      info: "#8A93A0",
      monitor: "#FBE032",
      action: "#F07E1B",
      critical: "#DA1F2D",
    },
    nativeLevelMappings: [],
    severityPhrases: [],
    iconCategoryId: null,
    allowAgencyNumbers: false,
  },
  overrides: [],
  library: initialGuidance(),
});
export function normaliseCountry(value?: string | null): string | null {
  const name = value?.trim().toUpperCase();
  const aliases: Record<string, string> = {
    AUSTRALIA: "AU",
    "NEW ZEALAND": "NZ",
    "UNITED KINGDOM": "GB",
    "UNITED STATES": "US",
    "SAUDI ARABIA": "SA",
  };
  return name ? aliases[name] || (/^[A-Z]{2}$/.test(name) ? name : countryNames.get(name) ?? null) : null;
}
// Current ISO 3166-1 alpha-2 territories only. ICU also accepts obsolete aliases
// (FX/SU/TP/ZR); those must not overwrite FR/RU/TL/CD when reversing names.
const countryNames = new Map<string, string>();
const regionNames = new Intl.DisplayNames(["en"], {type: "region", fallback: "none"});
const isoCountries = "AD AE AF AG AI AL AM AO AQ AR AS AT AU AW AX AZ BA BB BD BE BF BG BH BI BJ BL BM BN BO BQ BR BS BT BV BW BY BZ CA CC CD CF CG CH CI CK CL CM CN CO CR CU CV CW CX CY CZ DE DJ DK DM DO DZ EC EE EG EH ER ES ET FI FJ FK FM FO FR GA GB GD GE GF GG GH GI GL GM GN GP GQ GR GS GT GU GW GY HK HM HN HR HT HU ID IE IL IM IN IO IQ IR IS IT JE JM JO JP KE KG KH KI KM KN KP KR KW KY KZ LA LB LC LI LK LR LS LT LU LV LY MA MC MD ME MF MG MH MK ML MM MN MO MP MQ MR MS MT MU MV MW MX MY MZ NA NC NE NF NG NI NL NO NP NR NU NZ OM PA PE PF PG PH PK PL PM PN PR PS PT PW PY QA RE RO RS RU RW SA SB SC SD SE SG SH SI SJ SK SL SM SN SO SR SS ST SV SX SY SZ TC TD TF TG TH TJ TK TL TM TN TO TR TT TV TW TZ UA UG UM US UY UZ VA VC VE VG VI VN VU WF WS YE YT ZA ZM ZW".split(" ");
for (const code of isoCountries) {
  const name = regionNames.of(code);
  if (name && name !== code) countryNames.set(name.toUpperCase(), code);
}
export function templateCountry(jurisdiction: string | null | undefined, source: {id: string; country?: string | null}): string | null {
  if (jurisdiction) return normaliseCountry(jurisdiction);
  if (["smartraveller", "canadaGovTra", "earthquakeUsgs", "gdacsGlobal", "waqi"].includes(source.id)) return null;
  return normaliseCountry(source.country);
}
export function resolveTemplate(
  pack: TemplatePack,
  context: { country?: string | null; sourceId?: string | null },
) {
  let settings = { ...pack.defaults };
  const applied = ["Shared default"];
  const country = normaliseCountry(context.country);
  const matches = pack.overrides
    .filter(
      (x) =>
        (!x.country || x.country === country) &&
        (!x.sourceId || x.sourceId === context.sourceId),
    )
    .sort(
      (a, b) =>
        Number(Boolean(a.sourceId)) * 2 +
        Number(Boolean(a.country)) -
        (Number(Boolean(b.sourceId)) * 2 + Number(Boolean(b.country))),
    );
  for (const item of matches) {
    settings = {
      ...settings,
      ...Object.fromEntries(
        Object.entries(item.settings).filter(
          ([, value]) => value !== undefined,
        ),
      ),
    };
    applied.push(item.name);
  }
  return { settings, applied };
}
export function chooseTemplateBand(
  settings: TemplateSettings,
  input: {
    isAws: boolean;
    severity?: string | null;
    nativeLevel?: string | null;
    description: string;
    fallback: TemplateBand;
  },
) {
  if (isInfoOverride(input.description))
    return {
      band: "info" as TemplateBand,
      reason: "Source text marks a test, drill or resolved incident.",
    };
  const aws: Record<string, TemplateBand> = {
    advice: "monitor",
    watchAndAct: "action",
    emergency: "critical",
  };
  if (input.severity && aws[input.severity])
    return {
      band: aws[input.severity]!,
      reason: "Preserved official warning level independently of icon shape.",
    };
  const label = input.nativeLevel?.trim().toLowerCase();
  const match = label
    ? settings.nativeLevelMappings.find((x) => x.level.toLowerCase() === label)
    : undefined;
  if (label) {
    const band = match && bands.indexOf(match.band) > bands.indexOf(input.fallback) ? match.band : input.fallback;
    return {band, reason: match ? `Configured native level: ${match.level}; existing agency baseline retained.` : "Preserved source-native warning baseline."};
  }
  const haystack = input.description.normalize("NFKC").toLowerCase().replace(/[^\p{L}\p{N}]+/gu, " ");
  const phrases = (settings.severityPhrases ?? []).filter(x => {
    const needle = x.phrase.normalize("NFKC").toLowerCase().replace(/[^\p{L}\p{N}]+/gu, " ").trim();
    return needle && ` ${haystack} `.includes(` ${needle} `);
  }).sort((a,b) => bands.indexOf(b.band)-bands.indexOf(a.band));
  if (phrases[0]) return {band: phrases[0].band, reason: `Configured ALRT phrase: ${phrases[0].phrase}`};
  return {
        band: input.fallback,
        reason: "Existing deterministic source classification.",
      };
}
export function selectLibraryGuidance(
  pack: TemplatePack,
  input: {
    categoryId: string;
    parentCategoryId?: string | null;
    country?: string | null;
    band: TemplateBand;
  },
) {
  const country = normaliseCountry(input.country);
  const entries = pack.library.filter(
    (x) =>
      x.approved &&
      x.reviewedAt &&
      x.reference &&
      (x.categoryIds.includes(input.categoryId) ||
        Boolean(
          input.parentCategoryId &&
            x.categoryIds.includes(input.parentCategoryId),
        )) &&
      (!x.countries.length ||
        Boolean(country && x.countries.includes(country))) &&
      (!x.bands.length || x.bands.includes(input.band)),
  );
  return {
    alrtSuggestions: entries
      .filter((x) => !x.profileTags.length)
      .map((x) => x.text)
      .slice(0, 3),
    profileGuidance: entries
      .filter((x) => x.profileTags.length)
      .map((x) => ({
        id: x.id,
        text: x.text,
        profileTags: x.profileTags,
        reference: x.reference,
        reviewedAt: x.reviewedAt,
      })),
  };
}
