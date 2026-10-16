export interface AISummaryResponse {
  title: string;
  summary: string;
  callsToAction: string[];
  confidence: "high" | "medium" | "low";
  contentDetails?: import('../utils/agency_extraction.util.js').AgencyExtractionResult['contentDetails'] & {
    presentation?: { band: string; bandColor: string; iconCategoryId: string; agencyArtwork: boolean };
  };
}
