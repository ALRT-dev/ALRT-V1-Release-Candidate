// Shapes mirror the actual backend responses as of Stage 7B
// (backend/src/controllers/admin/*, backend/src/services/*) - re-verified
// against the live route/controller/service code for Stage 7C, not
// against the older §22 audit. Fields the backend doesn't return are
// simply not declared here, rather than guessed.

export type AdminRole = "superAdmin" | "admin" | "moderator";

export interface AdminProfile {
  id: string;
  email: string;
  name: string | null;
  role: AdminRole;
  isActive: boolean;
  lastLoginAt: string | null;
  mustChangePassword: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface AdminAccountListItem {
  id: string;
  email: string;
  name: string | null;
  role: AdminRole;
  isActive: boolean;
  mustChangePassword: boolean;
  lastLoginAt: string | null;
  lockedUntil: string | null;
  createdAt: string;
}

export interface LoginResponse {
  accessToken: string;
  refreshToken: string;
  mustChangePassword: boolean;
}

// --- Stats -----------------------------------------------------------

export interface AdminStats {
  users: { total: number; newToday: number; pendingDeletion: number };
  hazards: { total: number; newToday: number };
  dayBoundary: { timezone: string; dayStartedAt: string };
}

export interface NamedCount {
  name: string;
  count: number;
}

export interface DashboardStats {
  generatedAt: string;
  users: {
    total: number;
    newToday: number;
    newLast7Days: number;
    dailyActive: number;
    weeklyActive: number;
    pendingDeletion: number;
  };
  hazards: {
    active: number;
    pendingReview: number;
    createdToday: number;
    bySeverity: NamedCount[];
    topCities: NamedCount[];
    bySource: NamedCount[];
  };
  platforms: { ios: number; android: number; other: number; raw: NamedCount[] };
  geography: { topUserCities: NamedCount[] };
  catalogue: { categories: number; sources: number };
}

// --- Hazards / Alerts --------------------------------------------------

export type HazardReviewStatus = "pending" | "accepted" | "rejected";
export type HazardSeverity =
  | "unknown"
  | "info"
  | "advice"
  | "watchAndAct"
  | "emergency";
export type HazardSeverityBand = "info" | "monitor" | "action" | "critical";

export interface HazardMedia {
  id: string;
  url: string;
  thumbnailUrl: string | null;
  type: string;
  isPrimary: boolean;
}

// These three are nested objects in the real response (confirmed against
// getHazardsApplyingFiltersRaw's return shape in backend/src/services/
// hazard.service.ts, Stage 8 audit) - AdminHazard used to declare them as
// flat categoryName/sourceName/reportedByName/etc fields, which are never
// actually present on the wire and silently rendered every user of them
// as a fallback "-"/"Unknown" on every hazard, official or community.
export interface AdminHazardCategoryRef {
  id: string;
  name: string | null;
  description: string | null;
  color: string | null;
  parentId: string | null;
  parent: { id: string; name: string | null; description: string | null; color: string | null } | null;
}

export interface AdminHazardSourceRef {
  id: string;
  name: string | null;
  url: string | null;
  shape: string | null;
  advisoryText: string | null;
  copyrightText: string | null;
  copyrightLink: string | null;
  license: {
    id: string;
    badgeText: string | null;
    licenseText: string | null;
    description: string | null;
    link: string | null;
    foregroundColor: string | null;
    backgroundColor: string | null;
  } | null;
}

export interface AdminHazardReporterRef {
  id: string;
  name: string | null;
  xpPoints: number;
  reliabilityScore: number;
  reportsStatus: string;
}

export interface AdminHazard {
  id: string;
  title: string;
  description: string;
  aiSummary: string | null;
  severity: HazardSeverity;
  severityBand: HazardSeverityBand;
  callsToAction: string[];
  latitude: number | null;
  longitude: number | null;
  locationName: string | null;
  categoryId: string;
  category: AdminHazardCategoryRef | null;
  sourceId: string | null;
  source: AdminHazardSourceRef | null;
  reportedById: string | null;
  reportedBy: AdminHazardReporterRef | null;
  isAwsCompliant: boolean;
  reviewStatus: HazardReviewStatus;
  reviewFeedback: string | null;
  reviewedAt: string | null;
  reviewedById: string | null;
  confidenceScore: number;
  corroborationCount: number;
  medias: HazardMedia[];
  occurredAt: string;
  createdAt: string;
  updatedAt: string;
  expiresAt: string | null;
}

export interface HazardCategoryOption {
  id: string;
  name: string;
}

// --- Sources -------------------------------------------------------

export interface HazardSourceLicense {
  id: string;
  badgeText: string;
  licenseText: string;
}

export interface AdminHazardSource {
  id: string;
  name: string;
  url: string;
  imageUrl: string | null;
  advisoryText: string | null;
  copyrightText: string | null;
  copyrightLink: string | null;
  license: HazardSourceLicense | null;
  hazardsCount: number;
  createdAt: string;
  updatedAt: string;
}

// --- Categories ------------------------------------------------------

export interface HazardCategoryImage {
  id: string;
  imageType: string;
  presignedUrl: string | null;
}

export interface HazardCategory {
  id: string;
  name: string;
  description: string | null;
  color: string | null;
  isFireRelated: boolean;
  parentId: string | null;
  images: HazardCategoryImage[];
  subCategories: HazardCategory[];
  // GET /api/admin/categories (hazard_category.controller.ts) only nests
  // `subCategories` one level deep - a subcategory entry inside
  // `subCategories` has no `subCategories` of its own, hence the `?? []`
  // guards at every recursive render site in CategoriesPage.tsx. Optional
  // here since it's only present in the API response, never on a bare
  // Prisma HazardCategory.
  hazardsCount?: number;
}

// --- App users -------------------------------------------------------

export interface AdminAppUser {
  id: string;
  email: string;
  name: string | null;
  locationName: string | null;
  xpPoints: number;
  reliabilityScore: number;
  streakDays: number;
  isOnboardingCompleted: boolean;
  lastActivityDate: string | null;
  deletionRequestedAt: string | null;
  scheduledDeletionAt: string | null;
  createdAt: string;
  updatedAt: string;
  _count: { hazardsReported: number; devices: number };
}

export interface AppUserListResponse {
  total: number;
  page: number;
  pageSize: number;
  users: AdminAppUser[];
}

// --- AI Prompts --------------------------------------------------------

export interface AIPromptGroup {
  id: string;
  name: string;
  description: string | null;
}

export interface AIPrompt {
  id: string;
  name: string;
  description: string | null;
  content: string;
  variables: string[];
  model: string;
  groupId: string | null;
  group?: AIPromptGroup | null;
  createdBy?: { id: string; name: string | null; email: string } | null;
  updatedBy?: { id: string; name: string | null; email: string } | null;
  createdAt: string;
  updatedAt: string;
}

// --- Configuration -------------------------------------------------

export type ConfigurationKey = "aiPrompts";

export interface AdminConfiguration {
  id: string;
  key: ConfigurationKey;
  value: unknown;
  title: string;
  description: string | null;
  updatedBy?: { id: string; name: string | null; email: string } | null;
  createdAt: string;
  updatedAt: string;
}

// --- Webhook API keys ------------------------------------------------

export interface WebhookApiKeyListItem {
  id: string;
  name: string;
  description: string | null;
  isActive: boolean;
  maxRequestsPerMinute: number;
  maxRequestsPerHour: number;
  maxRequestsPerDay: number;
  totalRequests: number;
  lastUsedAt: string | null;
  lastUsedIp: string | null;
  createdAt: string;
  expiresAt: string | null;
  createdBy?: { id: string; name: string | null; email: string } | null;
}

export interface WebhookApiKeyCreatedResponse extends WebhookApiKeyListItem {
  apiKey: string;
  message: string;
}
