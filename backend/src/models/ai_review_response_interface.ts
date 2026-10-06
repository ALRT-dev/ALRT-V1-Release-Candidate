export interface AIReviewResponse {
  reviewStatus: "accepted" | "rejected" | "pending";
  reviewFeedback?: string;
  title: string;
  /** Cleaned-up description (no addresses, names, profanity or alarmist wording). */
  description?: string;
  summary: string;
  callsToAction: string[];
  confidence: "high" | "medium" | "low";
}
