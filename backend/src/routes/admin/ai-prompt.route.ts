import { Router } from "express";
import {
  getAllAIPrompts,
  getAIPromptById,
  createAIPrompt,
  updateAIPrompt,
  deleteAIPrompt,
  getGroupedAIPrompts,
  createAIPromptGroup,
  updateAIPromptGroup,
  deleteAIPromptGroup,
} from "../../controllers/admin/ai-prompt.controller.js";
import {
  requireAdminAuth,
  requireAnyAdmin,
  requireAdminOrAbove,
} from "../../middlewares/auth.admin.middleware.js";
import { validate } from "../../middlewares/validation.middleware.js";
import {
  createAIPromptGroupForAdminBodySchema,
  updateAIPromptGroupForAdminBodySchema,
  deleteAIPromptGroupForAdminParamsSchema,
} from "../../validators/admin/ai-prompt-group.validator.js";
import {
  getAIPromptByIdParamsSchema,
  createAIPromptBodySchema,
  updateAIPromptParamsSchema,
  updateAIPromptBodySchema,
  deleteAIPromptParamsSchema,
} from "../../validators/admin/ai-prompt.validator.js";

const adminAIPromptRouter = Router();

adminAIPromptRouter.use(requireAdminAuth);

// Read operations - any admin role. Writes below are gated
// requireAdminOrAbove: these prompts are the sole authoritative
// alert-generation content (backend/CLAUDE.md), so a moderator may view
// but not edit them - see V1_RECONCILIATION_REPORT.md §22.
adminAIPromptRouter.get("/", requireAnyAdmin, getAllAIPrompts);
adminAIPromptRouter.get("/grouped", requireAnyAdmin, getGroupedAIPrompts);
adminAIPromptRouter.get(
  "/:id",
  requireAnyAdmin,
  validate(getAIPromptByIdParamsSchema, "params"),
  getAIPromptById
);
adminAIPromptRouter.post(
  "/",
  requireAdminOrAbove,
  validate(createAIPromptBodySchema),
  createAIPrompt
);
adminAIPromptRouter.put(
  "/:id",
  requireAdminOrAbove,
  validate(updateAIPromptParamsSchema, "params"),
  validate(updateAIPromptBodySchema),
  updateAIPrompt
);
adminAIPromptRouter.delete(
  "/:id",
  requireAdminOrAbove,
  validate(deleteAIPromptParamsSchema, "params"),
  deleteAIPrompt
);

// Prompt group routes - same read/write split as prompts above.
adminAIPromptRouter.post(
  "/groups",
  requireAdminOrAbove,
  validate(createAIPromptGroupForAdminBodySchema),
  createAIPromptGroup
);
adminAIPromptRouter.put(
  "/groups/:id",
  requireAdminOrAbove,
  validate(updateAIPromptGroupForAdminBodySchema),
  updateAIPromptGroup
);
adminAIPromptRouter.delete(
  "/groups/:id",
  requireAdminOrAbove,
  validate(deleteAIPromptGroupForAdminParamsSchema, "params"),
  deleteAIPromptGroup
);

export default adminAIPromptRouter;
