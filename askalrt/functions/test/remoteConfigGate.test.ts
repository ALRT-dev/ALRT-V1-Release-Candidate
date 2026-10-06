import { parseAgentEnabled } from "../src/askalrt/remoteConfigGate";

describe("parseAgentEnabled", () => {
  it("is enabled when the parameter is missing entirely", () => {
    expect(parseAgentEnabled(undefined)).toBe(true);
    expect(parseAgentEnabled({})).toBe(true);
  });
  it("is enabled when the declared default is true", () => {
    expect(parseAgentEnabled({ agent_enabled: { defaultValue: { value: "true" } } })).toBe(true);
  });
  it("is disabled only on an explicit 'false'", () => {
    expect(parseAgentEnabled({ agent_enabled: { defaultValue: { value: "false" } } })).toBe(false);
    expect(parseAgentEnabled({ agent_enabled: { defaultValue: { value: "FALSE" } } })).toBe(false);
    expect(parseAgentEnabled({ agent_enabled: { defaultValue: { value: " false " } } })).toBe(false);
  });
  it("fails open on a malformed value", () => {
    expect(parseAgentEnabled({ agent_enabled: { defaultValue: { value: 0 as unknown as string } } })).toBe(
      true
    );
    expect(parseAgentEnabled({ agent_enabled: {} })).toBe(true);
  });
});
