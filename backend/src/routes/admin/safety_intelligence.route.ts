import { Router } from "express";
import * as c from "../../controllers/admin/safety_intelligence.controller.js";
import { requireAdminAuth, requireAdminOrAbove, requireAnyAdmin, requireReviewerOrAbove } from "../../middlewares/auth.admin.middleware.js";

/**
 * Safety intelligence admin API (owner decisions D1 to D8, 16 Nov 2026):
 * guidance library, coverage, country register, AI usage, prompt versions,
 * source licence confirmation and the daily assurance report.
 * Reviewers draft and review; only admins approve, publish or import.
 */
const router = Router();
router.use(requireAdminAuth);

router.get("/guidance", requireAnyAdmin, c.listGuidance);
router.get("/guidance/coverage", requireAnyAdmin, c.guidanceCoverage);
router.get("/guidance/history/:key", requireAnyAdmin, c.guidanceHistory);
router.post("/guidance", requireReviewerOrAbove, c.createGuidance);
router.put("/guidance/:id", requireReviewerOrAbove, c.updateGuidance);
router.post("/guidance/:id/submit", requireReviewerOrAbove, c.submitGuidance);
router.post("/guidance/:id/approve", requireAdminOrAbove, c.approveGuidance);
router.post("/guidance/:id/retire", requireAdminOrAbove, c.retireGuidance);
router.post("/guidance/import", requireAdminOrAbove, c.importGuidance);
router.post("/guidance/send-to-templates", requireAdminOrAbove, c.sendGuidanceToTemplates);

router.get("/guides", requireAnyAdmin, c.listLibraryGuides);
router.post("/guides/:slug/publish", requireAdminOrAbove, c.publishGuide);

router.get("/countries", requireAnyAdmin, c.listCountries);
router.put("/countries/:code", requireAdminOrAbove, c.saveCountry);

router.get("/ai-usage", requireAdminOrAbove, c.aiUsage);
router.get("/prompt-versions/:id", requireAnyAdmin, c.promptVersions);
router.post("/sources/:id/confirm-licence", requireAdminOrAbove, c.confirmSourceLicence);
router.post("/sources/:id/preview", requireAdminOrAbove, c.previewSource);
router.put("/sources/:id/adapter", requireAdminOrAbove, c.saveSourceAdapter);

router.get("/assurance", requireAnyAdmin, c.listAssurance);
router.post("/assurance/run", requireAdminOrAbove, c.runAssuranceNow);
router.post("/assurance/:id/acknowledge", requireAdminOrAbove, c.acknowledgeAssurance);

export default router;
