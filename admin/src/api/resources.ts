// Thin, typed wrappers around the actual Admin API routes
// (backend/src/routes/admin/*.ts). One function per endpoint - no
// generic "call anything" helper here, so every request this app can
// make is visible by reading this one file.
import { apiDelete, apiGet, apiPatch, apiPost, apiPut } from "./client";
import type {
  AdminAccountListItem,
  AdminAppUser,
  AdminConfiguration,
  AdminHazard,
  AdminHazardSource,
  AdminProfile,
  AdminStats,
  AIPrompt,
  AIPromptGroup,
  AppUserListResponse,
  DashboardStats,
  HazardCategory,
  HazardReviewStatus,
  HazardSeverity,
  HazardSeverityBand,
  LoginResponse,
  WebhookApiKeyCreatedResponse,
  WebhookApiKeyListItem,
} from "./types";

// --- Auth --------------------------------------------------------------

export const login = (email: string, password: string) =>
  apiPost<LoginResponse>("/api/admin/auth/login", { email, password });

export const logout = () => apiPost<{ success: boolean }>("/api/admin/auth/logout");

export const getMyProfile = () => apiGet<AdminProfile>("/api/admin/users/me");

export const changePassword = (
  currentPassword: string,
  newPassword: string,
  confirmPassword: string,
) =>
  apiPost<{ success: boolean }>("/api/admin/auth/change-password", {
    currentPassword,
    newPassword,
    confirmPassword,
  });

// --- Stats / Dashboard ---------------------------------------------

export const getAdminStats = () => apiGet<AdminStats>("/api/admin/stats");
export const getDashboardStats = () => apiGet<DashboardStats>("/api/admin/stats/dashboard");

// --- Hazards / Alerts / Moderation --------------------------------

export interface ListHazardsParams {
  searchString?: string;
  reviewStatus?: HazardReviewStatus;
  userReported?: boolean;
  page?: number;
  pageSize?: number;
}

const buildQuery = (params: object): string => {
  const search = new URLSearchParams();
  for (const [key, value] of Object.entries(params as Record<string, unknown>)) {
    if (value === undefined || value === null || value === "") continue;
    search.set(key, String(value));
  }
  const qs = search.toString();
  return qs ? `?${qs}` : "";
};

export const listHazards = (params: ListHazardsParams = {}) =>
  apiGet<AdminHazard[]>(`/api/admin/hazards${buildQuery(params)}`);

export const reviewHazard = (
  hazardId: string,
  reviewStatus: "accepted" | "rejected",
  reviewFeedback?: string,
) =>
  apiPatch<AdminHazard>(`/api/admin/hazards/${hazardId}/review`, {
    reviewStatus,
    ...(reviewFeedback ? { reviewFeedback } : {}),
  });

export const deleteHazard = (hazardId: string) =>
  apiDelete<{ message: string }>(`/api/admin/hazards/${hazardId}`);

// Used only by the TEST-only "Create Test Alert" picker (AlertsPage.tsx,
// gated on VITE_ENABLE_DUMMY_ALERTS). reviewStatus is hardcoded to
// "accepted" by this endpoint regardless of caller. useDummyAi, when true,
// skips the AI summarization call entirely (summarizeHazard's pre-existing
// useDummy passthrough mode) - every preset except Air Quality sets this,
// since Air Quality's categoryId ("airQualityAlert") already routes through
// its own deterministic template instead of AI, with or without this flag.
export const createHazard = (data: {
  title: string;
  description: string;
  sourceId: string;
  categoryId: string;
  latitude: number;
  longitude: number;
  severity?: HazardSeverity;
  severityBand?: HazardSeverityBand;
  expiresAt?: string;
  useDummyAi?: boolean;
}) => apiPost<AdminHazard>("/api/admin/hazards", data);

// --- Hazard sources ----------------------------------------------------

export const listHazardSources = (params: { page?: number; pageSize?: number; searchString?: string } = {}) =>
  apiGet<AdminHazardSource[]>(`/api/admin/hazard-sources${buildQuery(params)}`);

// Used only by the TEST-only "Create Dummy Alert" button, to lazily
// create the disposable "test-dummy" source it attaches every dummy
// alert to. A plain POST, same as any real admin creating a real source.
export const createHazardSource = (data: { id: string; name: string; url: string }) =>
  apiPost<AdminHazardSource>("/api/admin/hazard-sources", data);

export const updateHazardSource = (
  sourceId: string,
  patch: Partial<Pick<AdminHazardSource, "name" | "url" | "advisoryText">>,
) => apiPut<AdminHazardSource>(`/api/admin/hazard-sources/${sourceId}`, patch);

// --- Categories ----------------------------------------------------

export const listCategories = () => apiGet<HazardCategory[]>("/api/admin/categories");

export const updateCategory = (
  categoryId: string,
  patch: { name?: string; description?: string; color?: string; isFireRelated?: boolean },
) => apiPut<HazardCategory>(`/api/admin/categories/${categoryId}`, patch);

// --- App users -------------------------------------------------------

export const listAppUsers = (params: { search?: string; page?: number; pageSize?: number } = {}) =>
  apiGet<AppUserListResponse>(`/api/admin/users/app-users${buildQuery(params)}`);

export const getAppUser = (userId: string) =>
  apiGet<AdminAppUser>(`/api/admin/users/app-users/${userId}`);

export const requestAppUserDeletion = (userId: string) =>
  apiDelete<{ success: boolean; message: string; data: AdminAppUser }>(
    `/api/admin/users/app-users/${userId}`,
  );

export const restoreAppUser = (userId: string) =>
  apiPost<{ success: boolean; message: string; data: AdminAppUser }>(
    `/api/admin/users/app-users/${userId}/restore`,
  );

// --- Admin accounts --------------------------------------------------

export const listAdminAccounts = () => apiGet<AdminAccountListItem[]>("/api/admin/users/admins");

export const createAdminAccount = (input: {
  email: string;
  password: string;
  name?: string;
  role: "superAdmin" | "admin" | "moderator";
}) => apiPost<{ success: boolean; data: AdminAccountListItem; message: string }>(
  "/api/admin/users/create",
  input,
);

export const setAdminAccountActive = (adminId: string, isActive: boolean) =>
  apiPatch<{ success: boolean; data: AdminAccountListItem }>(
    `/api/admin/users/admins/${adminId}/active`,
    { isActive },
  );

// --- AI Prompts --------------------------------------------------------

export const listAIPromptGroups = () => apiGet<AIPromptGroup[]>("/api/admin/ai-prompts/grouped");
export const listAIPrompts = () => apiGet<AIPrompt[]>("/api/admin/ai-prompts");

export const updateAIPrompt = (
  id: string,
  patch: Partial<Pick<AIPrompt, "content" | "description">>,
) => apiPut<AIPrompt>(`/api/admin/ai-prompts/${id}`, patch);

// --- Configuration -------------------------------------------------

export const listConfigurations = () => apiGet<AdminConfiguration[]>("/api/admin/configurations");

export const updateConfiguration = (
  id: string,
  patch: { value?: unknown; title?: string; description?: string },
) => apiPut<AdminConfiguration>(`/api/admin/configurations/${id}`, patch);

// --- Webhook API keys --------------------------------------------------

export const listWebhookApiKeys = () => apiGet<WebhookApiKeyListItem[]>("/api/admin/webhook-api-keys");

export const createWebhookApiKey = (input: { name: string; description?: string }) =>
  apiPost<WebhookApiKeyCreatedResponse>("/api/admin/webhook-api-keys", input);

export const setWebhookApiKeyActive = (keyId: string, isActive: boolean) =>
  apiPatch<WebhookApiKeyListItem>(`/api/admin/webhook-api-keys/${keyId}`, { isActive });

export const deleteWebhookApiKey = (keyId: string) =>
  apiDelete<{ message: string }>(`/api/admin/webhook-api-keys/${keyId}`);
