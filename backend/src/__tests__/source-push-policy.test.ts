import { describe, expect, it, vi } from "vitest";

vi.mock("@prisma/client", () => ({
  HazardSourceShape: {
    triangle: "triangle",
    diamond: "diamond",
    circle: "circle",
    square: "square",
    shield: "shield",
  },
  HazardSeveritySystem: {
    awsLevel: "awsLevel",
    band: "band",
    category: "category",
    gdacsColour: "gdacsColour",
    advisory: "advisory",
  },
  SeverityLevelHandling: {
    verbatim: "verbatim",
    bandColourOnly: "bandColourOnly",
    categoryColour: "categoryColour",
    levelExempt: "levelExempt",
  },
  HazardSeverityBand: {
    info: "info",
    monitor: "monitor",
    action: "action",
    critical: "critical",
  },
  SourcePushPolicy: {
    everyLevel: "everyLevel",
    bandThreshold: "bandThreshold",
    afterConfirmation: "afterConfirmation",
    greenExempt: "greenExempt",
    advisoryOnly: "advisoryOnly",
  },
}));

import { decideSourcePush } from "../utils/source_registry.util.js";

describe("source push policy", () => {
  it("allows AWS notifications at every band but marks only Critical urgent", () => {
    expect(decideSourcePush({ policy: "everyLevel" as any, severityBand: "info" as any }))
      .toEqual({ send: true, urgent: false });
    expect(decideSourcePush({ policy: "everyLevel" as any, severityBand: "critical" as any }))
      .toEqual({ send: true, urgent: true });
  });

  it("keeps official non-AWS notification floor at Action and Critical", () => {
    expect(decideSourcePush({ policy: "bandThreshold" as any, severityBand: "monitor" as any }).send)
      .toBe(false);
    expect(decideSourcePush({ policy: "bandThreshold" as any, severityBand: "action" as any }).send)
      .toBe(true);
  });

  it("does not notify for a community report before three independent confirmations", () => {
    expect(decideSourcePush({
      policy: "afterConfirmation" as any,
      severityBand: "action" as any,
      reportedById: "reporter-1",
      corroborationCount: 2,
    }).send).toBe(false);
    expect(decideSourcePush({
      policy: "afterConfirmation" as any,
      severityBand: "action" as any,
      reportedById: "reporter-1",
      corroborationCount: 3,
    }).send).toBe(true);
  });

  it("suppresses GDACS Green and sends ALRT Intel as non-urgent", () => {
    expect(decideSourcePush({
      policy: "greenExempt" as any,
      severityBand: "info" as any,
      severitySystem: "gdacsColour" as any,
      title: "GDACS Green alert",
    }).send).toBe(false);
    expect(decideSourcePush({
      policy: "greenExempt" as any,
      severityBand: "info" as any,
      severitySystem: "gdacsColour" as any,
      title: "Flooding near Green Valley",
    }).send).toBe(true);
    expect(decideSourcePush({
      policy: "advisoryOnly" as any,
      severityBand: "critical" as any,
    })).toEqual({ send: true, urgent: false });
  });
});
