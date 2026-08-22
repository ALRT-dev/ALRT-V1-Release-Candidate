import { resolveSystemPrompt } from "../src/askalrt/promptOverride";
import { ASK_ALRT_SYSTEM_PROMPT } from "../src/askalrt/systemPrompt";

describe("resolveSystemPrompt", () => {
  it("falls back to the bundled prompt when there is no override doc", () => {
    expect(resolveSystemPrompt(undefined)).toBe(ASK_ALRT_SYSTEM_PROMPT);
  });
  it("falls back when the doc has no usable text field", () => {
    expect(resolveSystemPrompt({})).toBe(ASK_ALRT_SYSTEM_PROMPT);
    expect(resolveSystemPrompt({ text: "" })).toBe(ASK_ALRT_SYSTEM_PROMPT);
    expect(resolveSystemPrompt({ text: "   " })).toBe(ASK_ALRT_SYSTEM_PROMPT);
    expect(resolveSystemPrompt({ text: 42 })).toBe(ASK_ALRT_SYSTEM_PROMPT);
    expect(resolveSystemPrompt(null)).toBe(ASK_ALRT_SYSTEM_PROMPT);
  });
  it("uses the override text when present", () => {
    expect(resolveSystemPrompt({ text: "Custom prompt from Sarah" })).toBe(
      "Custom prompt from Sarah"
    );
  });
});
