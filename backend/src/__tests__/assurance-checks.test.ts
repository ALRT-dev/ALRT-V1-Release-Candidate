import { describe, expect, it } from "vitest";
import {
  checkAiUse, checkDisplay, checkLicences, checkMovementWords, checkReviewDates, checkSourceHealth, formatReport,
} from "../utils/assurance_checks.util.js";

const now = new Date("2026-11-16T22:00:00Z");
const src = (p: object) => ({ id: "s", name: "QLD Fire", lifecycleStatus: "active", scheduleMinutes: 15, healthStatus: "healthy", ...p });

describe("daily assurance checks (D3)", () => {
  it("fails a polled source with no good fetch for two cycles, ignores webhook and draft sources", () => {
    const r = checkSourceHealth([
      src({ lastSuccessfulFetch: new Date("2026-11-16T20:00:00Z") }),
      src({ name: "Fresh", lastSuccessfulFetch: new Date("2026-11-16T21:50:00Z") }),
      src({ name: "Webhook", scheduleMinutes: null }),
      src({ name: "Draft", lifecycleStatus: "draft" }),
    ], now);
    expect(r.status).toBe("fail");
    expect(r.items).toEqual(["QLD Fire: no good fetch since 2026-11-16 20:00 UTC"]);
  });

  it("lists active sources without a confirmed licence", () => {
    expect(checkLicences([src({}), src({ name: "BoM", licenceConfirmedAt: now })]).items).toEqual(["QLD Fire"]);
  });

  it("warns on overdue records and fails once a month late", () => {
    expect(checkReviewDates([{ key: "a", nextReviewAt: "2026-11-10" }], now).status).toBe("warn");
    expect(checkReviewDates([{ key: "a", nextReviewAt: "2026-09-01" }], now).status).toBe("fail");
  });

  it("catches movement directions but not warnings against going somewhere", () => {
    const r = checkMovementWords([
      { where: "Flood", text: "Leave now if you can." },
      { where: "Tsunami", text: "Never go to the beach to watch a tsunami." },
    ]);
    expect(r.items).toEqual(['Flood: "Leave now if you can."']);
  });

  it("flags alerts with no agency lines or a failed AI step", () => {
    expect(checkDisplay([{ id: "1", title: "A", facts: 0 }, { id: "2", title: "B", facts: 2, method: "fallback" }, { id: "3", title: "C", facts: 2 }]).items).toHaveLength(2);
  });

  it("warns on high AI share and fails on many AI errors", () => {
    expect(checkAiUse({ alerts: 10, aiAlerts: 5, calls: 5, failed: 0, maxShare: 0.3 }).status).toBe("warn");
    expect(checkAiUse({ alerts: 10, aiAlerts: 1, calls: 10, failed: 3, maxShare: 0.3 }).status).toBe("fail");
    expect(checkAiUse({ alerts: 10, aiAlerts: 1, calls: 1, failed: 0, maxShare: 0.3 }).status).toBe("pass");
  });

  it("writes a short report in Perth time", () => {
    const text = formatReport([
      checkLicences([src({})]),
      checkAiUse({ alerts: 1, aiAlerts: 0, calls: 0, failed: 0, maxShare: 0.3 }),
    ], now);
    expect(text).toContain("ALRT daily assurance, 2026-11-17 06:00 AWST");
    expect(text).toContain("Result: 1 failure, 0 warnings, 1 passed");
    expect(text).toContain("FAIL  Licence and attribution");
    expect(text).toContain("PASS  AI use and cost");
  });
});
