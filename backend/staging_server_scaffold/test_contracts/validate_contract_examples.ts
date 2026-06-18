import {
  contractStates,
  entitlementValidationPath,
  playbackDescriptorPath,
  type EntitlementValidationRequest,
  type EntitlementValidationResponse,
  type PlaybackDescriptorRequest,
  type PlaybackDescriptorResponse
} from "../src/contracts.js";

const entitlementRequestFields: Array<keyof EntitlementValidationRequest> = [
  "user_id",
  "anonymous_session_id",
  "movie_id",
  "storekit_product_id",
  "entitlement_context",
  "playback_provider",
  "device_context"
];

const entitlementResponseFields: Array<keyof EntitlementValidationResponse> = [
  "entitlement_status",
  "access_decision",
  "denial_reason",
  "audit_id",
  "expires_at",
  "refresh_after"
];

const playbackRequestFields: Array<keyof PlaybackDescriptorRequest> = [
  "user_id",
  "anonymous_session_id",
  "movie_id",
  "storekit_product_id",
  "entitlement_context",
  "playback_provider",
  "device_context",
  "audit_id"
];

const playbackResponseFields: Array<keyof PlaybackDescriptorResponse> = [
  "playback_descriptor_status",
  "playback_url_or_token_reference",
  "expires_at",
  "refresh_after",
  "denial_reason",
  "audit_id"
];

export const contractExampleCoverage = {
  endpointPaths: [entitlementValidationPath, playbackDescriptorPath],
  entitlementRequestFields,
  entitlementResponseFields,
  playbackRequestFields,
  playbackResponseFields,
  contractStates
};
