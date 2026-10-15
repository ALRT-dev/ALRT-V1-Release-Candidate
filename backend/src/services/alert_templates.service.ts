import { ConfigurationKey, Prisma } from "@prisma/client";
import prisma from "../utils/prisma_client.util.js";
import { HttpError } from "../models/http_error.js";
import { clearCache } from "./configuration.service.js";
import {
  defaultTemplatePack,
  templatePackSchema,
  type TemplatePack,
} from "../utils/alert_templates.util.js";

export const TEMPLATE_KEY = "alertTemplatesV1";
export type PromptSnapshot = {
  id: string;
  name: string;
  content: string;
  model: string;
  updatedAt: string;
};
export type TemplateRelease = {
  version: number;
  publishedAt: string;
  reason: string;
  pack: TemplatePack;
  prompts: Record<string, PromptSnapshot>;
  routes: Record<string, unknown>;
};
export type TemplateRegistry = {
  revision: number;
  draft: TemplatePack;
  published: TemplateRelease | null;
  history: TemplateRelease[];
};
export const emptyRegistry = (): TemplateRegistry => ({
  revision: 0,
  draft: defaultTemplatePack(),
  published: null,
  history: [],
});

export function readRegistry(value: unknown): TemplateRegistry {
  const raw = (value as Record<string, unknown> | null)?.[TEMPLATE_KEY];
  if (!raw) return emptyRegistry();
  const state = raw as TemplateRegistry;
  templatePackSchema.parse(state.draft);
  if (state.published) templatePackSchema.parse(state.published.pack);
  if (!Number.isInteger(state.revision) || !Array.isArray(state.history))
    throw new Error("Invalid alert template registry.");
  return state;
}

// Read fresh: a published change must take effect across every API process.
export async function getTemplateRegistry(): Promise<TemplateRegistry> {
  return readRegistry(
    (
      await prisma.configuration.findUnique({
        where: { key: ConfigurationKey.aiPrompts },
      })
    )?.value,
  );
}

export async function saveTemplateRegistry(input: {
  revision: number;
  action: "draft" | "publish" | "restore";
  pack?: TemplatePack | undefined;
  version?: number | undefined;
  reason: string;
  adminId: string | null;
}) {
  const result = await prisma.$transaction(async (tx) => {
    // Serialize template writers before reading the revision. Timestamp-only
    // checks cannot distinguish two writes that happen in one millisecond.
    await tx.$queryRaw`SELECT "id" FROM "Configuration" WHERE "key" = 'aiPrompts' FOR UPDATE`;
    const row = await tx.configuration.findUnique({
      where: { key: ConfigurationKey.aiPrompts },
    });
    if (!row)
      throw new HttpError(
        409,
        "Set up AI prompt configuration before saving templates.",
      );
    const state = readRegistry(row.value);
    if (input.revision !== state.revision)
      throw new HttpError(
        409,
        "Someone else changed these templates. Reload before saving.",
      );
    let pack = templatePackSchema.parse(input.pack ?? state.draft);
    if (input.action === "restore") {
      const previous = [state.published, ...state.history].find(
        (x) => x?.version === input.version,
      );
      if (!previous)
        throw new HttpError(404, "That version is no longer in history.");
      pack = structuredClone(previous.pack);
      // Restore republishes the exact saved prompt contents as a new version.
    }
    const sourceIds = pack.overrides.flatMap((x) =>
      x.sourceId ? [x.sourceId] : [],
    );
    const settings = [pack.defaults, ...pack.overrides.map((x) => x.settings)];
    const iconIds = settings.flatMap((x) =>
      x.iconCategoryId ? [x.iconCategoryId] : [],
    );
    const prompts = await tx.aIPrompt.findMany({
      select: {
        id: true,
        name: true,
        content: true,
        model: true,
        updatedAt: true,
      },
    });
    const promptIds = new Set(prompts.map((x) => x.id));
    if (input.action!=='restore'&&settings.some((x) => x.promptId && !promptIds.has(x.promptId)))
      throw new HttpError(400, "A selected prompt no longer exists.");
    if (sourceIds.length) {
      const found = await tx.hazardSource.count({
        where: { id: { in: sourceIds } },
      });
      if (found !== new Set(sourceIds).size)
        throw new HttpError(400, "A selected source no longer exists.");
    }
    const categoryIds = [
      ...new Set([...iconIds, ...pack.library.flatMap((x) => x.categoryIds)]),
    ];
    if (categoryIds.length) {
      const found = await tx.hazardCategory.count({
        where: { id: { in: categoryIds } },
      });
      if (found !== categoryIds.length)
        throw new HttpError(400, "A selected category no longer exists.");
    }
    const next: TemplateRegistry = {
      ...state,
      revision: state.revision + 1,
      draft: pack,
    };
    if (input.action === "publish" || input.action === "restore") {
      const previous = [state.published, ...state.history].find(
        (x) => x?.version === input.version,
      );
      const snapshot =
        input.action === "restore" && previous
          ? previous.prompts
          : Object.fromEntries(
              prompts.map((x) => [
                x.id,
                { ...x, updatedAt: x.updatedAt.toISOString() },
              ]),
            );
      const routes = { ...(row.value as Record<string, unknown>) };
      delete routes[TEMPLATE_KEY];
      next.published = {
        version: (state.published?.version ?? 0) + 1,
        publishedAt: new Date().toISOString(),
        reason: input.reason,
        pack: structuredClone(pack),
        prompts: snapshot,
        routes:
          input.action === "restore" && previous ? previous.routes : routes,
      };
      next.history = [
        ...(state.published ? [state.published] : []),
        ...state.history,
      ].slice(0, 10);
    }
    const value = {
      ...(row.value as Record<string, Prisma.JsonValue>),
      [TEMPLATE_KEY]: JSON.parse(JSON.stringify(next)),
    };
    const changed = await tx.configuration.updateMany({
      where: { id: row.id, updatedAt: row.updatedAt },
      data: { value, updatedById: input.adminId },
    });
    if (changed.count !== 1)
      throw new HttpError(
        409,
        "Configuration changed while saving. Reload and try again.",
      );
    await tx.adminAuditLog.create({
      data: {
        adminId: input.adminId,
        action: `alertTemplates.${input.action}`,
        targetType: "alertTemplates",
        targetId: TEMPLATE_KEY,
        reason: input.reason,
        before: {
          revision: state.revision,
          version: state.published?.version ?? 0,
        },
        after: {
          revision: next.revision,
          version: next.published?.version ?? 0,
        },
      },
    });
    return next;
  });
  clearCache(ConfigurationKey.aiPrompts);
  return result;
}

export function getReleasePrompt(
  release: TemplateRelease,
  input: {
    promptId: string | null;
    sourceId: string;
    categoryId: string;
    isAws: boolean;
    band: string;
  },
) {
  let id = input.promptId;
  if (!id) {
    for (const key of [
      `${input.sourceId}SourcePromptId`,
      `${input.categoryId}CategoryPromptId`,
      input.isAws
        ? "officialAwsAlertSummarizationPromptId"
        : "officialAlertSummarizationPromptId",
    ]) {
      const route = release.routes[key] as Record<string, string> | undefined;
      const selected = route?.[`${input.band}PromptId`];
      if (selected && release.prompts[selected]) {
        id = selected;
        break;
      }
    }
  }
  if (!id || !release.prompts[id])
    throw new HttpError(
      409,
      "No published prompt matches this source and category. Select a prompt in Alert templates.",
    );
  return release.prompts[id]!;
}
