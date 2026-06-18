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
};

export const entitlementValidationPath = "/entitlements/validate";
export const playbackDescriptorPath = "/playback/descriptor";

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
