import { extractUsedAlertIds } from "../src/askalrt/citations";

describe("extractUsedAlertIds", () => {
  it("returns the answer unchanged and no ids when there is no citation line", () => {
    expect(extractUsedAlertIds("Just a normal answer.", ["a1", "a2"])).toEqual({
      answer: "Just a normal answer.",
      usedAlertIds: [],
    });
  });

  it("strips the citation line and returns the cited ids", () => {
    const raw = "Here's what to do.\nUSED_ALERT_IDS: a1,a2";
    expect(extractUsedAlertIds(raw, ["a1", "a2", "a3"])).toEqual({
      answer: "Here's what to do.",
      usedAlertIds: ["a1", "a2"],
    });
  });

  it("drops ids that were never sent this turn (never trusts a model-invented id)", () => {
    const raw = "Answer.\nUSED_ALERT_IDS: a1,invented-id";
    expect(extractUsedAlertIds(raw, ["a1"])).toEqual({
      answer: "Answer.",
      usedAlertIds: ["a1"],
    });
  });

  it("returns no ids when the model cites nothing (line omitted)", () => {
    expect(extractUsedAlertIds("General advice, no specific alert.", ["a1"])).toEqual({
      answer: "General advice, no specific alert.",
      usedAlertIds: [],
    });
  });

  it("handles whitespace and case in the marker", () => {
    const raw = "Answer text.\nused_alert_ids:  a1 , a2 ";
    expect(extractUsedAlertIds(raw, ["a1", "a2"])).toEqual({
      answer: "Answer text.",
      usedAlertIds: ["a1", "a2"],
    });
  });

  it("is safe against an empty sent-ids list", () => {
    const raw = "Answer.\nUSED_ALERT_IDS: a1";
    expect(extractUsedAlertIds(raw, [])).toEqual({ answer: "Answer.", usedAlertIds: [] });
  });
});
