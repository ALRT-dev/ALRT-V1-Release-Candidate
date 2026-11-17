-- Retire Smartraveller (product owner, 16 November 2026: "I want the
-- Smartraveller taken out"; ALRT does not use Smartraveller content).
-- Nothing is deleted from alert history: live Smartraveller alerts are
-- expired so no feed shows them, the two learn guides copied from
-- Smartraveller are unpublished, and its four unused AI prompts are removed.

UPDATE "Hazard"
SET "expiresAt" = NOW()
WHERE "sourceId" = 'smartraveller'
  AND ("expiresAt" IS NULL OR "expiresAt" > NOW());

UPDATE "SafetyGuide"
SET "isPublished" = false
WHERE "slug" IN ('travel-advisories', 'natural-disasters-overseas');

DELETE FROM "AIPrompt"
WHERE "name" IN (
  '[INFO] Smartraveller Source Alert Summarization',
  '[MONITOR] Smartraveller Source Alert Summarization',
  '[ACTION] Smartraveller Source Alert Summarization',
  '[CRITICAL] Smartraveller Source Alert Summarization'
);

DELETE FROM "AIPromptGroup"
WHERE "name" = 'Smartraveller Alerts'
  AND NOT EXISTS (
    SELECT 1 FROM "AIPrompt" p WHERE p."groupId" = "AIPromptGroup"."id"
  );

UPDATE "HazardSource"
SET "lifecycleStatus" = 'retired'
WHERE "id" = 'smartraveller';
