export interface AIReviewResponse {
  reviewStatus: "accepted" | "rejected" | "pending";
  reviewFeedback?: string;
  title: string;
  summary: string;
  callsToAction: string[];
  confidence: "high" | "medium" | "low";
}
