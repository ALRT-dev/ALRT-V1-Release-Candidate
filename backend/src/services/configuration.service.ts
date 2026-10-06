import prisma from "../utils/prisma_client.util.js";
import { HttpError } from "../models/http_error.js";
import { ConfigurationKey, type Configuration } from "@prisma/client";
import type { AIPromptConfiguration } from "../models/ai_prompt_configuration_interface.js";
import { DefaultAIPromptNames } from "./ai-prompt.service.js";

// Cache for configurations to avoid database calls
const configCache = new Map<string, Configuration>();
const CACHE_TTL = 5 * 60 * 1000; // 5 minutes
const cacheTimestamps = new Map<string, number>();

/**
 * Interface for creating configurations
 */
export interface CreateConfigurationData {
  key: ConfigurationKey;
  value: any;
  title: string;
  description?: string;
}

/**
 * Interface for updating configurations
 */
export interface UpdateConfigurationData {
  value?: any;
  title?: string;
  description?: string;
}

/**
 * Clear cache for a specific configuration key or all configs
 */
const clearCache = (key?: string): void => {
  if (key) {
    configCache.delete(key);
    cacheTimestamps.delete(key);
  } else {
    configCache.clear();
    cacheTimestamps.clear();
  }
};

/**
 * Check if cache entry is expired
 */
const isCacheExpired = (key: string): boolean => {
  const timestamp = cacheTimestamps.get(key);
  if (!timestamp) return true;
  return Date.now() - timestamp > CACHE_TTL;
};

/**
 * Get configuration by key with caching
 */
export const getConfigurationByKey = async (
  key: ConfigurationKey
): Promise<Configuration | null> => {
  try {
    // Check cache first
    const cacheKey = key.toString();
    if (configCache.has(cacheKey) && !isCacheExpired(cacheKey)) {
      const cached = configCache.get(cacheKey);
      return cached || null;
    }

    // Fetch from database
    const config = await prisma.configuration.findUnique({
      where: { key },
      include: {
        updatedBy: {
          select: {
            id: true,
            email: true,
            name: true,
          },
        },
      },
    });

    if (!config) return null;

    // Update cache
    configCache.set(cacheKey, config as Configuration);
    cacheTimestamps.set(cacheKey, Date.now());

    return config;
  } catch (error) {
    console.error(`Error getting configuration ${key}:`, error);
    throw new HttpError(500, `Failed to get configuration: ${key}`);
  }
};

/**
 * Get all configurations with pagination
 */
export const getAllConfigurations = async (): Promise<Configuration[]> => {
  const configurations = await prisma.configuration.findMany({
    include: {
      updatedBy: {
        select: {
          id: true,
          email: true,
          name: true,
        },
      },
    },
    orderBy: [{ title: "asc" }],
  });
  return configurations;
};

/**
 * Get configuration by ID
 */
export const getConfigurationById = async (
  id: string
): Promise<Configuration | null> => {
  const config = await prisma.configuration.findUnique({
    where: { id },
    include: {
      updatedBy: {
        select: {
          id: true,
          email: true,
          name: true,
        },
      },
    },
  });

  return config;
};

/**
 * Create a new configuration
 */
export const createConfiguration = async (
  data: CreateConfigurationData,
  adminId: string
): Promise<Configuration> => {
  // Check if configuration with this key already exists
  const existingConfig = await prisma.configuration.findUnique({
    where: { key: data.key },
  });

  if (existingConfig) {
    throw new HttpError(
      400,
      `Configuration with key '${data.key}' already exists`
    );
  }

  // Validate JSON value
  if (typeof data.value !== "object" && data.value !== null) {
    try {
      JSON.parse(JSON.stringify(data.value));
    } catch {
      throw new HttpError(400, "Invalid JSON value provided");
    }
  }

  const config = await prisma.configuration.create({
    data: {
      key: data.key,
      value: data.value,
      title: data.title,
      ...(data.description && { description: data.description }),
      updatedById: adminId,
    },
    include: {
      updatedBy: {
        select: {
          id: true,
          email: true,
          name: true,
        },
      },
    },
  });

  // Clear cache
  clearCache(data.key.toString());

  return config;
};

/**
 * Update an existing configuration
 */
export const updateConfiguration = async (
  id: string,
  data: UpdateConfigurationData,
  adminId: string
): Promise<Configuration> => {
  // Check if configuration exists
  const existingConfig = await prisma.configuration.findUnique({
    where: { id },
  });

  if (!existingConfig) {
    throw new HttpError(404, "Configuration not found");
  }

  // Validate JSON value if provided
  if (data.value !== undefined) {
    if (typeof data.value !== "object" && data.value !== null) {
      try {
        JSON.parse(JSON.stringify(data.value));
      } catch {
        throw new HttpError(400, "Invalid JSON value provided");
      }
    }
  }

  const config = await prisma.configuration.update({
    where: { id },
    data: {
      ...(data.value !== undefined && { value: data.value }),
      ...(data.title && { title: data.title }),
      ...(data.description !== undefined && {
        description: data.description,
      }),
      updatedById: adminId,
    },
    include: {
      updatedBy: {
        select: {
          id: true,
          email: true,
          name: true,
        },
      },
    },
  });

  // Clear cache
  clearCache(existingConfig.key.toString());

  return config;
};

/**
 * Upsert configuration
 */
export const upsertConfiguration = async (
  data: CreateConfigurationData,
  adminId: string
): Promise<Configuration> => {
  const existingConfig = await prisma.configuration.findUnique({
    where: { key: data.key },
  });

  if (existingConfig) {
    return updateConfiguration(existingConfig.id, data, adminId);
  } else {
    return createConfiguration(data, adminId);
  }
};

/**
 * Delete a configuration
 */
export const deleteConfiguration = async (id: string): Promise<void> => {
  const existingConfig = await prisma.configuration.findUnique({
    where: { id },
  });

  if (!existingConfig) {
    throw new HttpError(404, "Configuration not found");
  }

  await prisma.configuration.delete({
    where: { id },
  });

  // Clear cache
  clearCache(existingConfig.key.toString());
};

/**
 * Validate configuration value
 */
export const validateConfigurationValue = async (
  value: any
): Promise<boolean> => {
  try {
    // Basic JSON validation
    JSON.parse(JSON.stringify(value));
    return true;
  } catch (error) {
    return false;
  }
};

/**
 * Get AI Prompts Configuration
 */
export const getAIPromptConfiguration =
  async (): Promise<AIPromptConfiguration> => {
    const config = await getConfigurationByKey(ConfigurationKey.aiPrompts);
    if (!config) {
      throw new HttpError(500, "AI Prompt configuration not found");
    }

    try {
      return config.value as unknown as AIPromptConfiguration;
    } catch (error) {
      throw new HttpError(500, "Invalid AI Prompt configuration format");
    }
  };

/**
 * Builds the AIPromptConfiguration pointing at the bracket-named default
 * prompts (DefaultAIPromptNames / ai-prompt.util.ts) — the sole
 * authoritative prompt system for V1 (see backend/CLAUDE.md). Shared by
 * initializeDefaultConfigurations (fresh-boot seeding) and
 * resetAIPromptConfigurationToBracketDefaults (the one-time convergence
 * script for a deployment whose Configuration.aiPrompts may point
 * elsewhere, e.g. from the retired alert_summarization_prompts.ts system).
 */
const buildDefaultAIPromptConfiguration =
  async (): Promise<AIPromptConfiguration> => {
    // Fetch AI prompts by their default names
    const prompts = await prisma.aIPrompt.findMany({
      where: {
        name: {
          in: Object.values(DefaultAIPromptNames),
        },
      },
      select: {
        id: true,
        name: true,
      },
    });
    const promptMap: Record<string, string | null> = {};
    for (const prompt of prompts) {
      promptMap[prompt.name] = prompt.id;
    }

    return {
      userReportedAlertReviewAndSummarizePromptId: {
        infoPromptId:
          promptMap[
            DefaultAIPromptNames.userReportedAlertReviewAndSummarizationInfo
          ] || "",
        monitorPromptId:
          promptMap[
            DefaultAIPromptNames.userReportedAlertReviewAndSummarizationMonitor
          ] || "",
        actionPromptId:
          promptMap[
            DefaultAIPromptNames.userReportedAlertReviewAndSummarizationAction
          ] || "",
        criticalPromptId:
          promptMap[
            DefaultAIPromptNames.userReportedAlertReviewAndSummarizationCritical
          ] || "",
      },
      officialAlertSummarizationPromptId: {
        infoPromptId:
          promptMap[DefaultAIPromptNames.officialAlertSummarizationInfo] || "",
        monitorPromptId:
          promptMap[DefaultAIPromptNames.officialAlertSummarizationMonitor] ||
          "",
        actionPromptId:
          promptMap[DefaultAIPromptNames.officialAlertSummarizationAction] ||
          "",
        criticalPromptId:
          promptMap[DefaultAIPromptNames.officialAlertSummarizationCritical] ||
          "",
      },
      officialAwsAlertSummarizationPromptId: {
        infoPromptId:
          promptMap[DefaultAIPromptNames.officialAwsAlertSummarizationInfo] ||
          "",
        monitorPromptId:
          promptMap[
            DefaultAIPromptNames.officialAwsAlertSummarizationMonitor
          ] || "",
        actionPromptId:
          promptMap[DefaultAIPromptNames.officialAwsAlertSummarizationAction] ||
          "",
        criticalPromptId:
          promptMap[
            DefaultAIPromptNames.officialAwsAlertSummarizationCritical
          ] || "",
      },
      airQualityAlertCategoryPromptId: {
        infoPromptId:
          promptMap[DefaultAIPromptNames.airQualityAlertCategoryInfo] || "",
        monitorPromptId:
          promptMap[DefaultAIPromptNames.airQualityAlertCategoryMonitor] || "",
        actionPromptId:
          promptMap[DefaultAIPromptNames.airQualityAlertCategoryAction] || "",
        criticalPromptId:
          promptMap[DefaultAIPromptNames.airQualityAlertCategoryCritical] || "",
      },
      smartravellerSourcePromptId: {
        infoPromptId:
          promptMap[DefaultAIPromptNames.smartravellerSourceInfo] || "",
        monitorPromptId:
          promptMap[DefaultAIPromptNames.smartravellerSourceMonitor] || "",
        actionPromptId:
          promptMap[DefaultAIPromptNames.smartravellerSourceAction] || "",
        criticalPromptId:
          promptMap[DefaultAIPromptNames.smartravellerSourceCritical] || "",
      },
      extractLocationPromptId:
        promptMap[DefaultAIPromptNames.extractLocationPrompt] || "",
    };
  };

const AI_PROMPT_CONFIGURATION_DESCRIPTION =
  "Configuration for AI prompts used in hazard processing. It includes prompt IDs for various AI tasks. 3 keys are required for basic functionality: userReportedAlertReviewAndSummarizePromptId, officialAlertSummarizationPromptId, severityAndCallToActionPromptId";

/**
 * Initialize default configurations if they don't exist
 */
export const initializeDefaultConfigurations = async (): Promise<void> => {
  try {
    const count = await prisma.configuration.count();
    if (count > 0) {
      return;
    }

    // Find the super admin to use as creator
    const superAdmin = await prisma.admin.findFirst({
      orderBy: { createdAt: "asc" }, // Get the first admin (likely super admin)
    });

    if (!superAdmin) {
      console.log("No admin found, skipping configuration initialization");
      return;
    }

    const aiPromptConfig = await buildDefaultAIPromptConfiguration();

    await upsertConfiguration(
      {
        key: ConfigurationKey.aiPrompts,
        value: aiPromptConfig,
        title: "AI Prompts Configuration",
        description: AI_PROMPT_CONFIGURATION_DESCRIPTION,
      },
      superAdmin.id,
    );

    console.log(
      "---------------------------------------> Default configurations initialized successfully"
    );
  } catch (error) {
    console.error("Error initializing default configurations:", error);
  }
};

/**
 * Repoints Configuration.aiPrompts's five default groups
 * (userReportedAlertReviewAndSummarizePromptId, officialAlertSummarizationPromptId,
 * officialAwsAlertSummarizationPromptId, airQualityAlertCategoryPromptId,
 * smartravellerSourcePromptId) and extractLocationPromptId at the
 * bracket-named prompts (ai-prompt.util.ts / DefaultAIPromptNames) — the
 * sole authoritative alert-generation prompt system for V1.
 *
 * Unlike initializeDefaultConfigurations, this runs unconditionally
 * (no "only if the Configuration table is empty" guard) and merges onto
 * whatever Configuration.aiPrompts already holds, so any admin-added
 * per-source or per-category prompt override (a `${id}SourcePromptId` or
 * `${id}CategoryPromptId` key) is preserved untouched — only the five
 * default groups are repointed. Safe to run on a fresh deployment (a
 * no-op there — it converges to the same values initializeDefaultConfigurations
 * already wrote) or on a deployment that previously ran the now-removed
 * `npm run seed:prompts` script (where it repoints those groups back to
 * the bracket-named prompts, since deleting that script's source file does
 * not by itself undo a Configuration row it already wrote to the database).
 *
 * Invoked by src/scripts/reset-ai-prompt-configuration.ts.
 */
export const resetAIPromptConfigurationToBracketDefaults = async (): Promise<{
  adminId: string;
  config: AIPromptConfiguration;
}> => {
  const superAdmin = await prisma.admin.findFirst({
    orderBy: { createdAt: "asc" },
  });
  if (!superAdmin) {
    throw new HttpError(
      500,
      "No admin found — cannot attribute the configuration update.",
    );
  }

  const defaults = await buildDefaultAIPromptConfiguration();
  const existing = await prisma.configuration.findUnique({
    where: { key: ConfigurationKey.aiPrompts },
  });
  const merged: AIPromptConfiguration = {
    ...((existing?.value as Partial<AIPromptConfiguration> | null) ?? {}),
    ...defaults,
  } as AIPromptConfiguration;

  await upsertConfiguration(
    {
      key: ConfigurationKey.aiPrompts,
      value: merged,
      title: "AI Prompts Configuration",
      description: AI_PROMPT_CONFIGURATION_DESCRIPTION,
    },
    superAdmin.id,
  );

  return { adminId: superAdmin.id, config: merged };
};
