import type { AISummaryResponse } from "../models/ai_summary_response_interface.js";
import { HttpError } from "../models/http_error.js";
import { agencyExtractionFallback } from "./agency_extraction.util.js";

/** The Admin preview uses the same source-only fallback as ingestion. A
 * configuration error still fails, so an absent prompt cannot look ready.
 */
export async function previewExtraction(
  extract: () => Promise<AISummaryResponse>,
  options: Parameters<typeof agencyExtractionFallback>[0],
): Promise<AISummaryResponse & { extractionFallback?: boolean }> {
  try {
    return await extract();
  } catch (error) {
    if (error instanceof HttpError && error.statusCode < 500) throw error;
    return { ...agencyExtractionFallback(options), extractionFallback: true };
  }
}
