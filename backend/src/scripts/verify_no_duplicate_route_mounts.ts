/**
 * Regression check for accidental duplicate `router.use(path, subRouter)`
 * mounts - a real bug class in this codebase already (see the header
 * comment in src/index.ts: the RevenueCat webhook was once mounted twice
 * under two casings of the same import, and the earlier mount silently
 * absorbed every request ahead of the general rate limiter). This script
 * caught the equivalent still-outstanding bug in adminRouter (/stats
 * mounted twice) and now guards both against ever recurring.
 *
 * Pure structural check - no HTTP server, no database. Every admin
 * sub-router is imported once and checked against adminRouter's own
 * middleware stack by identity, so a second `.use()` call mounting the
 * same router instance under any path is caught even if the path string
 * itself were changed.
 *
 * Run with:
 *   NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/verify_no_duplicate_route_mounts.ts
 */

import assert from "node:assert/strict";
import type { Router } from "express";
import adminRouter from "../routes/admin/index.js";
import adminAuthRouter from "../routes/admin/auth.route.js";
import adminHazardCategoryRouter from "../routes/admin/hazard_category.route.js";
import adminHazardRouter from "../routes/admin/hazard.route.js";
import adminHazardSourceRouter from "../routes/admin/hazard_source.route.js";
import adminUserRouter from "../routes/admin/user.route.js";
import adminAIPromptRouter from "../routes/admin/ai-prompt.route.js";
import adminConfigurationRouter from "../routes/admin/configuration.route.js";
import adminWebhookApiKeyRouter from "../routes/admin/webhook_api_key.route.js";
import adminStatsRouter from "../routes/admin/stats.route.js";
import adminAskAlrtRouter from "../routes/admin/ask_alrt.route.js";

let passed = 0;
const check = (label: string, fn: () => void) => {
  fn();
  passed += 1;
  console.log(`  ok - ${label}`);
};

/** Counts how many layers in [router]'s own stack mount [target] by identity. */
const mountCount = (router: Router, target: Router): number =>
  (router as unknown as { stack: { handle: unknown }[] }).stack.filter(
    (layer) => layer.handle === target,
  ).length;

console.log("Route mount duplication check (structural, no HTTP/DB)");
console.log();

for (const [name, subRouter] of [
  ["adminAuthRouter", adminAuthRouter],
  ["adminAskAlrtRouter", adminAskAlrtRouter],
  ["adminStatsRouter", adminStatsRouter],
  ["adminUserRouter", adminUserRouter],
  ["adminHazardCategoryRouter", adminHazardCategoryRouter],
  ["adminHazardRouter", adminHazardRouter],
  ["adminHazardSourceRouter", adminHazardSourceRouter],
  ["adminAIPromptRouter", adminAIPromptRouter],
  ["adminConfigurationRouter", adminConfigurationRouter],
  ["adminWebhookApiKeyRouter", adminWebhookApiKeyRouter],
] as const) {
  check(`${name} is mounted on adminRouter exactly once`, () => {
    assert.equal(mountCount(adminRouter, subRouter), 1);
  });
}

console.log();
console.log(
  `${passed} checks passed. (The RevenueCat double-mount this same bug ` +
    "class produced is separately covered live, end-to-end, by " +
    "verify_stage8_release_audit.ts - S25.15.)",
);
