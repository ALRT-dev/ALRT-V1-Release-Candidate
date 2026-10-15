import { Router } from "express";
import { z } from "zod";
import rateLimit from "express-rate-limit";
import {
  requireAdminAuth,
  requireAnyAdmin,
  requireAdminOrAbove,
  type AdminRequest,
} from "../../middlewares/auth.admin.middleware.js";
import {
  getTemplateRegistry,
  saveTemplateRegistry,
  TEMPLATE_KEY,
  type TemplateRelease,
} from "../../services/alert_templates.service.js";
import {
  templatePackSchema,
  resolveTemplate,
  chooseTemplateBand,
  templateCountry,
  selectLibraryGuidance,
} from "../../utils/alert_templates.util.js";
import prisma from "../../utils/prisma_client.util.js";
import { HttpError } from "../../models/http_error.js";
import { getHazardAttributesFromDescription } from "../../utils/ingestion.util.js";
import { getSeverityBandFromAQI } from "../../utils/ingestion.severity.util.js";
import { parseAqiValueFromDescription } from "../../utils/air_quality_template.util.js";
import { summarizeHazard } from "../../services/hazard.service.js";
import { previewExtraction } from "../../utils/preview_extraction.util.js";

const router = Router();
router.use(requireAdminAuth);
router.get("/", requireAnyAdmin, async (_req, res, next) => {
  try {
    const [state, sources] = await Promise.all([
      getTemplateRegistry(),
      prisma.hazardSource.findMany({
        select: {
          id: true,
          name: true,
          country: true,
          sourceType: true,
          severitySystem: true,
        },
        orderBy: { name: "asc" },
      }),
    ]);
    res.json({ state, sources });
  } catch (e) {
    next(e);
  }
});
const saveSchema = z
  .object({
    revision: z.number().int().nonnegative(),
    action: z.enum(["draft", "publish", "restore"]),
    pack: templatePackSchema.optional(),
    version: z.number().int().positive().optional(),
    reason: z.string().trim().min(3).max(500),
  })
  .strict();
router.put("/", requireAdminOrAbove, async (req: AdminRequest, res, next) => {
  try {
    const parsed = saveSchema.safeParse(req.body);
    if (!parsed.success)
      throw new HttpError(
        400,
        parsed.error.issues.map((x) => x.message).join(" "),
      );
    res.json(
      await saveTemplateRegistry({ ...parsed.data, adminId: req.admin!.id }),
    );
  } catch (e) {
    next(e);
  }
});
const previewSchema = z
  .object({
    pack: templatePackSchema,
    sourceId: z.string().min(1),
    categoryId: z.string().min(1),
    title: z.string().min(1).max(200),
    description: z.string().min(1).max(50000),
    nativeWarningLevel: z.string().max(150).nullable().optional(),
    sourceLifecycle: z.enum(['active','test','resolved']).optional(),
    extract: z.boolean().default(false),
    jurisdictionCountry:z.string().regex(/^[A-Z]{2}$/).nullable().optional(),
    sourceInstructions: z.array(z.string().min(1).max(50000)).max(40).optional(),
  })
  .strict();
router.post(
  "/preview",
  requireAdminOrAbove,
  rateLimit({
    windowMs: 60_000,
    limit: 10,
    standardHeaders: true,
    legacyHeaders: false,
  }),
  async (req, res, next) => {
    try {
      const parsed = previewSchema.safeParse(req.body);
      if (!parsed.success)
        throw new HttpError(
          400,
          parsed.error.issues.map((x) => x.message).join(" "),
        );
      const input = parsed.data;
      const [source, categories, prompts, configuration] = await Promise.all([
        prisma.hazardSource.findUnique({ where: { id: input.sourceId } }),
        prisma.hazardCategory.findMany({ include: { parent: true } }),
        prisma.aIPrompt.findMany({
          select: {
            id: true,
            name: true,
            content: true,
            model: true,
            updatedAt: true,
          },
        }),
        prisma.configuration.findUnique({ where: { key: "aiPrompts" } }),
      ]);
      const category = categories.find((x) => x.id === input.categoryId);
      if (!source || !category)
        throw new HttpError(400, "Select an existing source and category.");
      if (
        input.nativeWarningLevel &&
        !input.description
          .toLowerCase()
          .includes(input.nativeWarningLevel.toLowerCase())
      )
        throw new HttpError(
          400,
          "Quote the original warning level in the source text.",
        );
      const attributes = getHazardAttributesFromDescription(
        input.description,
        categories,
        category.id,
        { category, severityText: input.nativeWarningLevel ?? input.description },
      );
      const resolved = resolveTemplate(input.pack, {
      country: templateCountry(input.jurisdictionCountry,source),
        sourceId: source.id,
      });
      let decision = chooseTemplateBand(resolved.settings, {
        categoryId: category.id,
        isAws: attributes.isAwsCompliant,
        severity: attributes.severity,
        nativeLevel: input.nativeWarningLevel ?? null,
        sourceLifecycle: input.sourceLifecycle,
        description: input.description,
        fallback: attributes.severityBand,
      });
      const aqi =
        category.id === "airQualityAlert" && source.id === "waqi"
          ? parseAqiValueFromDescription(input.description)
          : null;
      if (category.id === "airQualityAlert" && source.id === "waqi") {
        if (aqi === null)
          throw new HttpError(
            400,
            "Air quality preview needs the supplied reading in the form AQI: 125.",
          );
        decision = {
          band: getSeverityBandFromAQI(aqi),
          reason:
            "Numeric AQI rule. Good and moderate readings do not create warning cards.",
        };
      }
      const suppressed = aqi !== null && aqi <= 100;
      const routes = {
        ...((configuration?.value as Record<string, unknown>) ?? {}),
      };
      delete routes[TEMPLATE_KEY];
      const release: TemplateRelease = {
        version: 0,
        publishedAt: "draft",
        reason: "Preview only",
        pack: input.pack,
        routes,
        prompts: Object.fromEntries(
          prompts.map((x) => [
            x.id,
            { ...x, updatedAt: x.updatedAt.toISOString() },
          ]),
        ),
      };
      const output =
        input.extract && !suppressed
          ? await previewExtraction(() => summarizeHazard({
              title: input.title,
              description: input.description,
              category,
              source,
              isAwsCompliant: attributes.isAwsCompliant,
              severityBand: decision.band,
              templateRelease: release,
              preview: true,
            jurisdictionCountry:input.jurisdictionCountry,
            nativeWarningLevel:input.nativeWarningLevel,
            sourceActions: input.sourceInstructions ?? [],
            }), {
              sourceText: [input.title, input.description, ...(input.sourceInstructions ?? [])].join('\n\n'),
              sourceTitle: input.title, sourceDescription: input.description,
              sourceActions: input.sourceInstructions ?? [], nativeWarningLevel: input.nativeWarningLevel,
              agency: source.name, allowAgencyNumbers: resolved.settings.allowAgencyNumbers, templateVersion: 0,
              ...selectLibraryGuidance(input.pack, {categoryId: category.id, parentCategoryId: category.parentId,
                country: templateCountry(input.jurisdictionCountry, source), band: decision.band}),
            })
          : null;
      res.json({
        previewOnly: true,
        suppressed,
        band: decision.band,
        reason: decision.reason,
        applied: resolved.applied,
        settings: resolved.settings,
        isAws: attributes.isAwsCompliant,
        output,
      });
    } catch (e) {
      next(e);
    }
  },
);
export default router;
