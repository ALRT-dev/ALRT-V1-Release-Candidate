import {
  HazardSourceHealthStatus,
  HazardSourceLifecycleStatus,
  HazardSourceShape,
  HazardSeveritySystem,
  SeverityLevelHandling,
  SourcePushPolicy,
} from "@prisma/client";
import prisma from "../utils/prisma_client.util.js";

type SourceConfig = {
  id: string;
  name: string;
  url: string;
  feedUrl: string;
  country: string;
  region: string;
  coverage: string;
  sourceType: string;
  authorityLevel: string;
  format: string;
  accessMethod: string;
  adapterKey: string;
  warningTypes: string[];
  lifecycleStatus: HazardSourceLifecycleStatus;
  copyrightText: string;
  advisoryText?: string;
  shape: HazardSourceShape;
  severitySystem: HazardSeveritySystem;
  levelHandling: SeverityLevelHandling;
  pushPolicy: SourcePushPolicy;
};

const sources: SourceConfig[] = [
  {
    id: "rfs",
    name: "NSW Rural Fire Service",
    url: "https://www.rfs.nsw.gov.au",
    feedUrl: "https://www.rfs.nsw.gov.au/feeds/majorIncidents.json",
    country: "Australia",
    region: "New South Wales",
    coverage: "NSW major incidents",
    sourceType: "emergency management",
    authorityLevel: "official government",
    format: "GeoJSON",
    accessMethod: "public feed",
    adapterKey: "rfs",
    warningTypes: ["bushfire", "hazard reduction burn", "emergency incident"],
    lifecycleStatus: HazardSourceLifecycleStatus.active,
    copyrightText: "Source: NSW Rural Fire Service. Retain the original source link and applicable NSW attribution.",
    shape: HazardSourceShape.triangle,
    severitySystem: HazardSeveritySystem.awsLevel,
    levelHandling: SeverityLevelHandling.verbatim,
    pushPolicy: SourcePushPolicy.everyLevel,
  },
  {
    id: "nswTransport",
    name: "Live Traffic NSW",
    url: "https://www.transport.nsw.gov.au",
    feedUrl: "https://api.transport.nsw.gov.au/v1/live/hazards/incident/open",
    country: "Australia",
    region: "New South Wales",
    coverage: "NSW transport incidents and major events",
    sourceType: "transport",
    authorityLevel: "official government",
    format: "GeoJSON",
    accessMethod: "API key",
    adapterKey: "nswTransport",
    warningTypes: ["road closure", "traffic incident", "major event"],
    lifecycleStatus: HazardSourceLifecycleStatus.active,
    copyrightText: "Source: Transport for NSW. Retain the original source link and applicable NSW attribution.",
    shape: HazardSourceShape.diamond,
    severitySystem: HazardSeveritySystem.band,
    levelHandling: SeverityLevelHandling.bandColourOnly,
    pushPolicy: SourcePushPolicy.bandThreshold,
  },
  {
    id: "viceFire",
    name: "VicEmergency",
    url: "https://www.emergency.vic.gov.au",
    feedUrl: "https://data.emergency.vic.gov.au/Show?pageId=getIncidentRSS",
    country: "Australia",
    region: "Victoria",
    coverage: "Victoria emergency incidents",
    sourceType: "emergency management",
    authorityLevel: "official government",
    format: "RSS",
    accessMethod: "public feed",
    adapterKey: "viceFire",
    warningTypes: ["bushfire", "storm", "flood", "emergency incident"],
    lifecycleStatus: HazardSourceLifecycleStatus.active,
    copyrightText: "Source: VicEmergency. Retain the original source link and applicable Victorian attribution.",
    shape: HazardSourceShape.triangle,
    severitySystem: HazardSeveritySystem.awsLevel,
    levelHandling: SeverityLevelHandling.verbatim,
    pushPolicy: SourcePushPolicy.everyLevel,
  },
  {
    id: "qldFire",
    name: "Queensland Fire Department",
    url: "https://www.qfes.qld.gov.au",
    feedUrl: "https://publiccontent.gis.psba.qld.gov.au/content/Feeds/BushfireCurrentIncidents/bushfireAlert.xml",
    country: "Australia",
    region: "Queensland",
    coverage: "Queensland bushfire incidents",
    sourceType: "emergency management",
    authorityLevel: "official government",
    format: "RSS",
    accessMethod: "public feed",
    adapterKey: "qldFire",
    warningTypes: ["bushfire", "emergency incident"],
    lifecycleStatus: HazardSourceLifecycleStatus.active,
    copyrightText: "Source: Queensland Fire Department. Retain the original source link and applicable Queensland attribution.",
    shape: HazardSourceShape.triangle,
    severitySystem: HazardSeveritySystem.awsLevel,
    levelHandling: SeverityLevelHandling.verbatim,
    pushPolicy: SourcePushPolicy.everyLevel,
  },
  {
    id: "waDfes",
    name: "Department of Fire and Emergency Services WA",
    url: "https://www.emergency.wa.gov.au",
    feedUrl: "https://api.emergency.wa.gov.au/v1/rss/warnings",
    country: "Australia",
    region: "Western Australia",
    coverage: "WA warnings and incidents",
    sourceType: "emergency management",
    authorityLevel: "official government",
    format: "RSS",
    accessMethod: "public feed",
    adapterKey: "waDfes",
    warningTypes: ["bushfire", "storm", "flood", "emergency warning"],
    lifecycleStatus: HazardSourceLifecycleStatus.active,
    copyrightText: "Source: Department of Fire and Emergency Services WA. Retain the original source link and applicable WA attribution.",
    shape: HazardSourceShape.triangle,
    severitySystem: HazardSeveritySystem.awsLevel,
    levelHandling: SeverityLevelHandling.verbatim,
    pushPolicy: SourcePushPolicy.everyLevel,
  },
  {
    id: "nswSes",
    name: "NSW State Emergency Service",
    url: "https://www.ses.nsw.gov.au",
    feedUrl: "https://hazardwatch.gov.au/feed/v1/nswses-cap-au-active-warnings.atom.xml",
    country: "Australia",
    region: "New South Wales",
    coverage: "NSW active warnings",
    sourceType: "emergency management",
    authorityLevel: "official government",
    format: "CAP/Atom",
    accessMethod: "public feed",
    adapterKey: "nswSes",
    warningTypes: ["flood", "storm", "emergency warning"],
    lifecycleStatus: HazardSourceLifecycleStatus.active,
    copyrightText: "Source: NSW State Emergency Service. Retain the original source link and applicable NSW attribution.",
    shape: HazardSourceShape.triangle,
    severitySystem: HazardSeveritySystem.awsLevel,
    levelHandling: SeverityLevelHandling.verbatim,
    pushPolicy: SourcePushPolicy.everyLevel,
  },
  {
    id: "waqi",
    name: "World Air Quality Index",
    url: "https://www.waqi.info",
    feedUrl: "https://api.waqi.info/map/bounds/",
    country: "Global",
    region: "Australia",
    coverage: "Australian air-quality stations",
    sourceType: "health/environment",
    authorityLevel: "trusted data service",
    format: "JSON",
    accessMethod: "API token",
    adapterKey: "waqi",
    warningTypes: ["air quality"],
    lifecycleStatus: HazardSourceLifecycleStatus.active,
    copyrightText: "Source: World Air Quality Index. Retain the original source link and follow the provider's attribution terms.",
    advisoryText: "For official health advice, consult the relevant state EPA or health authority.",
    shape: HazardSourceShape.diamond,
    severitySystem: HazardSeveritySystem.band,
    levelHandling: SeverityLevelHandling.bandColourOnly,
    pushPolicy: SourcePushPolicy.bandThreshold,
  },
  {
    id: "openMeteo",
    name: "Open-Meteo",
    url: "https://open-meteo.com",
    feedUrl: "https://air-quality-api.open-meteo.com/v1/air-quality",
    country: "Global",
    region: "Australia",
    coverage: "Australian UV and pollen indicators",
    sourceType: "weather/environment",
    authorityLevel: "data service",
    format: "JSON",
    accessMethod: "public API",
    adapterKey: "openMeteo",
    warningTypes: ["UV", "pollen"],
    lifecycleStatus: HazardSourceLifecycleStatus.active,
    copyrightText: "Source: Open-Meteo. Include Open-Meteo attribution and the underlying weather-data provider attribution required by its terms.",
    shape: HazardSourceShape.diamond,
    severitySystem: HazardSeveritySystem.band,
    levelHandling: SeverityLevelHandling.bandColourOnly,
    pushPolicy: SourcePushPolicy.bandThreshold,
  },
  {
    id: "earthquakeUsgs",
    name: "USGS Earthquake Hazards Program",
    url: "https://earthquake.usgs.gov",
    feedUrl: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.geojson",
    country: "Global",
    region: "Global",
    coverage: "Global earthquakes",
    sourceType: "geophysical hazard",
    authorityLevel: "official scientific agency",
    format: "GeoJSON",
    accessMethod: "public feed",
    adapterKey: "earthquakeUsgs",
    warningTypes: ["earthquake"],
    lifecycleStatus: HazardSourceLifecycleStatus.active,
    copyrightText: "Source: USGS Earthquake Hazards Program. Retain the original source link and USGS attribution.",
    shape: HazardSourceShape.diamond,
    severitySystem: HazardSeveritySystem.band,
    levelHandling: SeverityLevelHandling.bandColourOnly,
    pushPolicy: SourcePushPolicy.bandThreshold,
  },
  {
    id: "gdacsGlobal",
    name: "Global Disaster Alert and Coordination System",
    url: "https://www.gdacs.org",
    feedUrl: "https://www.gdacs.org",
    country: "Global",
    region: "Global",
    coverage: "International humanitarian disaster alerts",
    sourceType: "international humanitarian",
    authorityLevel: "international monitoring system",
    format: "To be verified",
    accessMethod: "To be verified",
    adapterKey: "gdacsGlobal",
    warningTypes: ["earthquake", "tsunami", "tropical cyclone", "flood", "volcano"],
    lifecycleStatus: HazardSourceLifecycleStatus.monitoring,
    copyrightText: "GDACS attribution and reuse terms must be confirmed before activation or AI processing.",
    shape: HazardSourceShape.square,
    severitySystem: HazardSeveritySystem.gdacsColour,
    levelHandling: SeverityLevelHandling.levelExempt,
    pushPolicy: SourcePushPolicy.greenExempt,
  },
];

const run = async () => {
  for (const source of sources) {
    await prisma.hazardSource.upsert({
      where: { id: source.id },
      create: {
        ...source,
        healthStatus: HazardSourceHealthStatus.unknown,
        warningTypes: source.warningTypes,
      },
      update: {
        ...source,
        healthStatus: HazardSourceHealthStatus.unknown,
        warningTypes: source.warningTypes,
      },
    });
  }

  await prisma.hazardSource.updateMany({
    where: { id: { in: ["bom", "smartraveller"] } },
    data: { lifecycleStatus: HazardSourceLifecycleStatus.retired },
  });

  console.log(`Configured ${sources.length} TEST global source records.`);
};

run()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => prisma.$disconnect());