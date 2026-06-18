type DescriptorStatus =
  | "descriptor_ready"
  | "descriptor_unavailable"
  | "descriptor_expired"
  | "descriptor_refresh_required"
  | "local_preview_fallback";

type PlaybackDescriptorRequest = {
  user_id: string | null;
  anonymous_session_id: string | null;
  movie_id: string;
  storekit_product_id: string;
  entitlement_context: Record<string, unknown>;
  playback_provider: string;
  device_context: Record<string, unknown>;
  audit_id: string;
};

type PlaybackDescriptorResponse = {
  playback_descriptor_status: DescriptorStatus;
  playback_url_or_token_reference: string | null;
  expires_at: string | null;
  refresh_after: string | null;
  denial_reason: string | null;
  audit_id: string;
};

const requiredDescriptorEnvironment = [
  "HIGHFIVE_BACKEND_ENV",
  "HIGHFIVE_CLOUDFLARE_ACCOUNT_ID",
  "HIGHFIVE_CLOUDFLARE_STREAM_API_TOKEN",
  "HIGHFIVE_ALLOWED_PLAYBACK_TTL_SECONDS",
  "HIGHFIVE_DATABASE_URL",
  "HIGHFIVE_AUDIT_LOG_SINK"
] as const;

export async function handlePlaybackDescriptor(
  request: PlaybackDescriptorRequest
): Promise<PlaybackDescriptorResponse> {
  assertPlaybackDescriptorRequest(request);

  // Confirm entitlement audit approval before descriptor work begins.
  const entitlementAudit = await loadEntitlementAudit(request.audit_id);
  if (entitlementAudit.status !== "entitlement_approved") {
    return descriptorUnavailable(request.audit_id, "entitlement_not_approved");
  }

  // Server-side Cloudflare signing belongs here.
  // Do not return provider credentials to the app. Return a short-lived descriptor reference only.
  const descriptorReference = await createServerSideDescriptorReference(request);
  if (!descriptorReference) {
    return descriptorUnavailable(request.audit_id, "descriptor_provider_not_configured");
  }

  await createDescriptorAuditRecord("playback_descriptor_issued", request.audit_id);

  const expiresAt = new Date(Date.now() + 10 * 60 * 1000).toISOString();
  const refreshAfter = new Date(Date.now() + 8 * 60 * 1000).toISOString();

  return {
    playback_descriptor_status: "descriptor_ready",
    playback_url_or_token_reference: descriptorReference,
    expires_at: expiresAt,
    refresh_after: refreshAfter,
    denial_reason: null,
    audit_id: request.audit_id
  };
}

function descriptorUnavailable(
  auditId: string,
  reason: string
): PlaybackDescriptorResponse {
  return {
    playback_descriptor_status: "descriptor_unavailable",
    playback_url_or_token_reference: null,
    expires_at: null,
    refresh_after: null,
    denial_reason: reason,
    audit_id: auditId
  };
}

function assertPlaybackDescriptorRequest(request: PlaybackDescriptorRequest): void {
  if (!request.movie_id || !request.storekit_product_id || !request.playback_provider || !request.audit_id) {
    throw new Error("invalid_playback_descriptor_request");
  }
  if (!request.user_id && !request.anonymous_session_id) {
    throw new Error("identity_context_required");
  }
}

async function loadEntitlementAudit(
  _auditId: string
): Promise<{ status: "entitlement_approved" | "entitlement_denied" | "entitlement_pending" }> {
  // Placeholder only. Read the server-side entitlement audit record here.
  return { status: "entitlement_pending" };
}

async function createServerSideDescriptorReference(
  _request: PlaybackDescriptorRequest
): Promise<string | null> {
  // Placeholder only. Generate Cloudflare playback material server-side and return a reference.
  return null;
}

async function createDescriptorAuditRecord(
  _eventName: string,
  _auditId: string
): Promise<void> {
  // Placeholder only. Never log playback_url_or_token_reference.
}

export { requiredDescriptorEnvironment };
