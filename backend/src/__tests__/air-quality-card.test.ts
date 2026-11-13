import { describe, expect, it, vi } from "vitest";
vi.hoisted(() => {
  for (const key of ["ADMIN_JWT_ACCESS_EXP_M", "ADMIN_JWT_ACCESS_SECRET", "ADMIN_JWT_REFRESH_EXP_D", "ADMIN_JWT_REFRESH_SECRET", "APPLE_OAUTH_AUDIENCE", "AWS_BEDROCK_REGION", "AWS_S3_BUCKET_NAME", "AWS_S3_REGION", "DATABASE_URL", "EMAIL_FROM_ADDRESS", "EMAIL_SUPPORT_ADDRESS", "GOOGLE_MAPS_API_KEY", "GOOGLE_OAUTH_CLIENT_ID_ANDROID", "GOOGLE_OAUTH_CLIENT_ID_IOS", "GOOGLE_OAUTH_CLIENT_ID_WEB", "JWT_ACCESS_EXP_M", "JWT_ACCESS_SECRET", "JWT_REFRESH_EXP_D", "JWT_REFRESH_SECRET", "NSW_TRANSPORT_API_KEY", "OPENAI_API_KEY", "SIGHTENGINE_API_SECRET", "SIGHTENGINE_API_USER", "SIGHTENGINE_WORKFLOW_ID", "SMTP_HOST", "SMTP_PASSWORD", "SMTP_PORT", "SMTP_USER", "SUPER_ADMIN_EMAIL", "SUPER_ADMIN_NAME", "SUPER_ADMIN_PASSWORD", "WAQI_API_TOKEN"]) process.env[key] ??= "1";
});
vi.mock("@prisma/client", () => ({
  Prisma: { DbNull: null },
  HazardReviewStatus: { accepted: "accepted", rejected: "rejected", pending: "pending" },
  HazardSeverity: { unknown: "unknown", low: "low", medium: "medium", high: "high", extreme: "extreme" },
  HazardSeverityBand: { info: "info", monitor: "monitor", action: "action", critical: "critical" },
  FireStatus: { active: "active", beingControlled: "beingControlled", underControl: "underControl", closed: "closed" },
  CategoryImageType: {}, XpEventType: {}, SourcePushPolicy: {}, SeverityLevelHandling: {}, HazardSeveritySystem: {}, HazardSourceShape: {}, ExternalSourceIdValue: {},
}));
vi.mock("../utils/prisma_client.util.js", () => ({ default: {} }));
vi.mock("../utils/firebase_admin_client.util.js", () => ({ default: {} }));
import { summarizeHazard } from "../services/hazard.service.js";
import { defaultTemplatePack } from "../utils/alert_templates.util.js";
import { hazardSafetyLibrary } from "../utils/hazard_safety_library.util.js";

const release = { version: 4, publishedAt: "", reason: "", pack: { ...defaultTemplatePack(), library: hazardSafetyLibrary() }, prompts: {}, routes: {} } as any;

describe("air quality card (owner review, 13 November 2026)", () => {
  it("has two facts and keeps the reviewed air quality advice", async () => {
    const value: any = await summarizeHazard({
      title: "Air quality alert - Duncraig",
      description: "Station: Duncraig, Perth, Australia\nAir quality: poor (World Air Quality Index rating)\nAQI: 162",
      locationName: "Duncraig",
      category: { id: "airQualityAlert", parentId: "healthAndAir", name: "Air Quality Alert" } as any,
      source: { id: "waqi", name: "World Air Quality Index", country: "AU" } as any,
      isAwsCompliant: false, severityBand: "action" as any, templateRelease: release, jurisdictionCountry: "AU",
    });
    const d = value.contentDetails;
    expect(d.facts).toHaveLength(2);
    expect(d.facts[1]).toMatch(/^Air pollution at this level/);
    expect(d.alrtSuggestions.length).toBeGreaterThanOrEqual(2);
    expect(d.alrtSuggestions.join(" ")).not.toMatch(/smoke/i);
    expect(d.alrtSuggestions.join(" ")).not.toMatch(/Air pollution at this level/);
  });
});

describe("GDACS card (owner review, 13 November 2026)", () => {
  it("has two facts and puts the reviewed hazard advice first", async () => {
    const value: any = await summarizeHazard({
      title: "Orange earthquake alert in Vanuatu",
      description: "On 13 November 2026 an earthquake of magnitude 6.8 occurred near Port Vila, Vanuatu. Alert level: Orange.",
      locationName: "Port Vila, Vanuatu",
      category: { id: "earthquake", parentId: "weatherAndEnvironment", name: "Earthquake" } as any,
      source: { id: "gdacsGlobal", name: "GDACS", country: null } as any,
      isAwsCompliant: false, severityBand: "action" as any, templateRelease: release, jurisdictionCountry: "VU",
    });
    const d = value.contentDetails;
    expect(d.facts).toHaveLength(2);
    expect(d.facts[1]).toMatch(/magnitude 6\.8 occurred near Port Vila/);
    expect(d.nativeLevel).toBe("GDACS Orange");
    expect(value.title).toBe("Earthquake near Port Vila, Vanuatu");
    expect(d.facts[0]).toMatch(/^GDACS expects medium humanitarian impact from this earthquake near Port Vila, Vanuatu \(Orange alert\)\./);
    expect(d.alrtSuggestions[0]).toMatch(/Drop, Cover and Hold On/);
    expect(d.alrtSuggestions.length).toBeLessThanOrEqual(4);
  });
});
