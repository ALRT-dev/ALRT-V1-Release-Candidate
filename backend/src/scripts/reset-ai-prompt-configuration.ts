/**
 * Repoints Configuration.aiPrompts's five default prompt groups
 * (official AWS/non-AWS summarization, community-report review, air
 * quality, Smartraveller) and extractLocationPromptId at the
 * bracket-named prompts in ai-prompt.util.ts / DefaultAIPromptNames —
 * the sole authoritative alert-generation prompt system for V1 (see
 * backend/CLAUDE.md).
 *
 * Run this once against any deployment whose database previously had
 * `npm run seed:prompts` run against it (that script, and the
 * repo-versioned alert_summarization_prompts.ts prompt set it seeded,
 * have been removed from this V1 candidate — see
 * V1_RECONCILIATION_REPORT.md). Deleting that script's source file does
 * not undo the Configuration row it already wrote to the database, so a
 * previously-seeded deployment needs this explicit repoint. Safe to run
 * on a fresh deployment too — it converges to the same values the normal
 * boot-time initialization already writes there, so it is a no-op.
 *
 * Any admin-added per-source or per-category prompt override (a
 * `${id}SourcePromptId` or `${id}CategoryPromptId` key) is preserved —
 * only the five default groups are repointed.
 *
 * Usage: npx tsx src/scripts/reset-ai-prompt-configuration.ts
 *   (needs DATABASE_URL, like any Prisma script)
 */
import prisma from "../utils/prisma_client.util.js";
import { resetAIPromptConfigurationToBracketDefaults } from "../services/configuration.service.js";

const main = async () => {
  const { adminId, config } =
    await resetAIPromptConfigurationToBracketDefaults();

  const missing = Object.entries(config)
    .flatMap(([group, value]) =>
      typeof value === "string"
        ? value === ""
          ? [group]
          : []
        : Object.entries(value as Record<string, string>)
            .filter(([, id]) => id === "")
            .map(([band]) => `${group}.${band}`),
    );

  console.log(`Configuration.aiPrompts repointed (attributed to admin ${adminId}).`);
  if (missing.length > 0) {
    console.warn(
      `WARNING: ${missing.length} prompt slot(s) resolved to an empty ID — the bracket-named prompt row for these is missing from AIPrompt. This means initializeAIPrompts() has not (successfully) run on this database yet. Slots: ${missing.join(", ")}`,
    );
    process.exitCode = 1;
  } else {
    console.log("All prompt slots resolved to a real AIPrompt row.");
  }
};

main()
  .catch((error) => {
    console.error("reset-ai-prompt-configuration failed:", error);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
