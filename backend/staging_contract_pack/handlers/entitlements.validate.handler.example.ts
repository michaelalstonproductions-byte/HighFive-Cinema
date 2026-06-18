type EntitlementStatus = "entitlement_approved" | "entitlement_denied" | "entitlement_pending";
type AccessDecision = EntitlementStatus | "local_preview_fallback";

type EntitlementValidateRequest = {
  user_id: string | null;
  anonymous_session_id: string | null;
  movie_id: string;
  storekit_product_id: string;
  entitlement_context: Record<string, unknown>;
  playback_provider: string;
  device_context: Record<string, unknown>;
};

type EntitlementValidateResponse = {
  entitlement_status: EntitlementStatus;
  access_decision: AccessDecision;
  denial_reason: string | null;
  audit_id: string;
  expires_at: string | null;
  refresh_after: string | null;
};

const requiredServerEnvironment = [
  "HIGHFIVE_BACKEND_ENV",
  "HIGHFIVE_APP_STORE_BUNDLE_ID",
  "HIGHFIVE_APP_STORE_ISSUER_ID",
  "HIGHFIVE_APP_STORE_KEY_ID",
  "HIGHFIVE_APP_STORE_PRIVATE_KEY",
  "HIGHFIVE_REVENUECAT_SECRET_KEY",
  "HIGHFIVE_DATABASE_URL",
  "HIGHFIVE_AUDIT_LOG_SINK"
] as const;

export async function handleEntitlementsValidate(
  request: EntitlementValidateRequest
): Promise<EntitlementValidateResponse> {
  assertEntitlementRequest(request);

  // Create an audit record before external validation.
  const auditId = await createAuditRecord("entitlement_validation_requested", request);

  // Server-side StoreKit or RevenueCat validation belongs here.
  // The backend must verify product mapping and never trust app-provided entitlement state alone.
  const validation = await validateServerEntitlement(request);

  if (validation.status !== "approved") {
    return {
      entitlement_status: "entitlement_denied",
      access_decision: "entitlement_denied",
      denial_reason: validation.reason ?? "entitlement_not_found",
      audit_id: auditId,
      expires_at: null,
      refresh_after: null
    };
  }

  const expiresAt = new Date(Date.now() + 30 * 60 * 1000).toISOString();
  const refreshAfter = new Date(Date.now() + 20 * 60 * 1000).toISOString();

  return {
    entitlement_status: "entitlement_approved",
    access_decision: "entitlement_approved",
    denial_reason: null,
    audit_id: auditId,
    expires_at: expiresAt,
    refresh_after: refreshAfter
  };
}

function assertEntitlementRequest(request: EntitlementValidateRequest): void {
  if (!request.movie_id || !request.storekit_product_id || !request.playback_provider) {
    throw new Error("invalid_entitlement_validation_request");
  }
  if (!request.user_id && !request.anonymous_session_id) {
    throw new Error("identity_context_required");
  }
}

async function validateServerEntitlement(
  _request: EntitlementValidateRequest
): Promise<{ status: "approved" | "denied" | "pending"; reason?: string }> {
  // Placeholder only. Wire this to server-owned StoreKit or RevenueCat validation.
  return { status: "pending", reason: "validation_provider_not_configured" };
}

async function createAuditRecord(
  _eventName: string,
  _request: EntitlementValidateRequest
): Promise<string> {
  // Placeholder only. Store request metadata without sensitive playback material.
  return "audit-placeholder";
}

export { requiredServerEnvironment };
