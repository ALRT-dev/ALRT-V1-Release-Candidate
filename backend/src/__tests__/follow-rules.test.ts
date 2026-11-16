import { describe, expect, it } from "vitest";
import { followEvent, isEnded, levelOf } from "../utils/follow_rules.util.js";

describe("server-side Follow (D7)", () => {
  const now = new Date("2026-11-16T10:00:00Z");
  it("pushes once when the agency level changes", () => {
    expect(followEvent("Advice", { title: "Bushfire, Gidgegannup", level: "Watch and Act", ended: false }))
      .toEqual({ kind: "level", title: "Alert updated", body: "Bushfire, Gidgegannup is now Watch and Act.", level: "Watch and Act" });
    expect(followEvent("Watch and Act", { title: "x", level: "watch and act", ended: false })).toEqual({ kind: "none" });
  });
  it("pushes when the alert ends, by expiry or the agency's own words", () => {
    expect(isEnded({ expiresAt: new Date("2026-11-16T09:00:00Z") }, now)).toBe(true);
    expect(isEnded({ nativeWarningLevel: "No longer a threat" }, now)).toBe(true);
    expect(isEnded({ nativeWarningLevel: "Emergency Warning", expiresAt: new Date("2026-11-17") }, now)).toBe(false);
    expect(followEvent("Advice", { title: "Flood", level: "Advice", ended: true }).kind).toBe("ended");
  });
  it("uses the agency level, or ALRT's band when the agency gives none", () => {
    expect(levelOf({ nativeWarningLevel: " Advice ", severityBand: "monitor" })).toBe("Advice");
    expect(levelOf({ nativeWarningLevel: null, severityBand: "monitor" })).toBe("monitor");
  });
});
