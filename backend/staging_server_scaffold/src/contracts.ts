export type EntitlementStatus =
  | "entitlement_approved"
  | "entitlement_denied"
  | "entitlement_pending";

export type AccessDecision = EntitlementStatus | "local_preview_fallback";

export type PlaybackDescriptorStatus =
  | "descriptor_ready"
  | "descriptor_unavailable"
  | "descriptor_expired"
  | "descriptor_refresh_required"
  | "local_preview_fallback";

export type JsonObject = Record<string, unknown>;

export type EntitlementValidationRequest = {
  user_id: string | null;
  anonymous_session_id: string | null;
  movie_id: string;
  storekit_product_id: string;
  entitlement_context: JsonObject;
  playback_provider: string;
  device_context: JsonObject;
};

export type EntitlementValidationResponse = {
  entitlement_status: EntitlementStatus;
  access_decision: AccessDecision;
  denial_reason: string | null;
  audit_id: string;
  expires_at: string | null;
  refresh_after: string | null;
};

export type PlaybackDescriptorRequest = {
  user_id: string | null;
  anonymous_session_id: string | null;
  movie_id: string;
  storekit_product_id: string;
  entitlement_context: JsonObject;
  playback_provider: string;
  device_context: JsonObject;
  audit_id: string;
};

export type PlaybackDescriptorResponse = {
  playback_descriptor_status: PlaybackDescriptorStatus;
  playback_url_or_token_reference: string | null;
  expires_at: string | null;
  refresh_after: string | null;
  denial_reason: string | null;
  audit_id: string;
  playback_format?: string | null;
  playback_source?: string | null;
  processing_job_id?: string | null;
  hls_master_object_key?: string | null;
};

export const entitlementValidationPath = "/entitlements/validate";
export const playbackDescriptorPath = "/playback/descriptor";
export const playbackHLSPath = "/v1/playback/hls/";
export const readinessPath = "/ready";
export const openAPIPath = "/openapi.json";
export const catalogPath = "/v1/catalog";
export const catalogSyncPath = "/v1/catalog/sync";
export const catalogDeltaPath = "/v1/catalog/delta";
export const contentDetailPath = "/v1/content/";
export const creatorDetailPath = "/v1/creators/";
export const collectionDetailPath = "/v1/collections/";
export const discoveryQueryPath = "/v1/discovery/query";
export const identityDevSignInPath = "/v1/identity/dev/sign-in";
export const identityAppleExchangePath = "/v1/identity/apple/exchange";
export const identityRefreshPath = "/v1/identity/session/refresh";
export const identitySignOutPath = "/v1/identity/sign-out";
export const identityMePath = "/v1/identity/me";
export const identityDeleteRequestPath = "/v1/identity/delete-request";
export const identityAuditPath = "/v1/identity/audit";
export const creatorWorkspacePath = "/v1/creator/workspace";
export const creatorDraftsPath = "/v1/creator/drafts";
export const creatorDraftDetailPath = "/v1/creator/drafts/";
export const creatorDraftSyncQueuePath = "/v1/creator/draft-sync/queue";
export const adminReviewQueuePath = "/v1/admin/review/queue";
export const adminReviewDetailPath = "/v1/admin/review/";
export const adminReviewAuditPath = "/v1/admin/review/audit";
export const creatorUploadSessionsPath = "/v1/creator/uploads/sessions";
export const creatorUploadDetailPath = "/v1/creator/uploads/";
export const creatorUploadAssetsPath = "/v1/creator/uploads/assets";
export const creatorProcessingJobsPath = "/v1/creator/processing/jobs";
export const creatorProcessingJobDetailPath = "/v1/creator/processing/jobs/";
export const viewerLibraryPath = "/v1/viewer/library";
export const viewerLibrarySavePath = "/v1/viewer/library/save";
export const viewerLibraryProgressPath = "/v1/viewer/library/progress";
export const viewerLibraryOfflinePath = "/v1/viewer/library/offline";
export const analyticsEventsPath = "/v1/analytics/events";
export const analyticsDashboardPath = "/v1/analytics/dashboard";

export const contractStates = [
  "entitlement_approved",
  "entitlement_denied",
  "entitlement_pending",
  "descriptor_ready",
  "descriptor_unavailable",
  "descriptor_expired",
  "descriptor_refresh_required",
  "local_preview_fallback"
] as const;

export function isRecord(value: unknown): value is JsonObject {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

export function isEntitlementValidationRequest(value: unknown): value is EntitlementValidationRequest {
  if (!isRecord(value)) return false;
  return hasNullableString(value.user_id) &&
    hasNullableString(value.anonymous_session_id) &&
    typeof value.movie_id === "string" &&
    typeof value.storekit_product_id === "string" &&
    isRecord(value.entitlement_context) &&
    typeof value.playback_provider === "string" &&
    isRecord(value.device_context);
}

export function isPlaybackDescriptorRequest(value: unknown): value is PlaybackDescriptorRequest {
  if (!isRecord(value)) return false;
  return isEntitlementValidationRequest(value) && typeof (value as JsonObject).audit_id === "string";
}

function hasNullableString(value: unknown): value is string | null {
  return value === null || typeof value === "string";
}
