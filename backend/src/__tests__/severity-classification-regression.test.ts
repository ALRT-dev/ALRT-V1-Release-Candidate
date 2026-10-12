import { describe, expect, it, vi } from "vitest";

vi.mock("@prisma/client", () => ({
  HazardSeverity: {
    unknown: "unknown",
    info: "info",
    advice: "advice",
    watchAndAct: "watchAndAct",
    emergency: "emergency",
  },
  HazardSeverityBand: {
    info: "info",
    monitor: "monitor",
    action: "action",
    critical: "critical",
  },
}));

import {
  getSeverityBandFromDescription,
  isInfoOverride,
} from "../utils/ingestion.severity.util.js";

describe("severity classification regression tests", () => {
  it("does not treat 'latest' as a test/drill override", () => {
    const text =
      "Latest update: fire is burning out of control. Leave immediately.";
    expect(isInfoOverride(text)).toBe(false);
    expect(getSeverityBandFromDescription(text)).toBe("critical");
  });

  it("does not treat 'protest' as a test/drill override", () => {
    expect(isInfoOverride("Police monitoring a protest in the city.")).toBe(false);
  });

  it("does not treat 'exercise caution' as a planned exercise", () => {
    expect(isInfoOverride("Please exercise caution near the flooded road.")).toBe(false);
  });

  it("does not treat 'cleared land' as a resolved incident", () => {
    expect(isInfoOverride("Fire crews are working near recently cleared land.")).toBe(false);
  });

  it("recognises an explicitly planned emergency exercise", () => {
    expect(isInfoOverride("A planned emergency exercise will be held today.")).toBe(true);
    expect(
      getSeverityBandFromDescription(
        "A planned emergency exercise will be held today. Leave immediately.",
      ),
    ).toBe("info");
  });

  it("does not downgrade a real incident that says it is not a drill", () => {
    const text = "This is not a drill. Evacuate immediately due to a life-threatening fire.";
    expect(isInfoOverride(text)).toBe(false);
    expect(getSeverityBandFromDescription(text)).toBe("critical");
  });

  it("recognises resolved incidents by phrase", () => {
    expect(isInfoOverride("The incident has now been cleared.")).toBe(true);
  });
});
