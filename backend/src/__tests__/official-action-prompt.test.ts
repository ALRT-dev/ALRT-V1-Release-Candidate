import { expect, it } from "vitest";
import { getOfficialAlertReviewAndSummarizationPrompt } from "../utils/ai-prompt.util.js";
it("does not trade conditional agency wording for a short action target", () => {
  const prompt = getOfficialAlertReviewAndSummarizationPrompt();
  expect(prompt).not.toContain("Target 15 words");
  expect(prompt).not.toContain("drop qualifying");
  expect(prompt).not.toContain("up to 3 dot points");
  expect(prompt).toContain("Never reorder or shorten a conditional instruction");
  expect(prompt).toContain("Length targets never justify removing source wording");
});
