import {
  type EntitlementValidationRequest,
  type EntitlementValidationResponse,
  isEntitlementValidationRequest
} from "../contracts.js";
import { createAuditRecord } from "../audit.js";
import { ContractError } from "../errors.js";
import { productMatchesMovie } from "../productMapping.js";
import type { EntitlementProvider } from "../providers/providerInterfaces.js";

export async function validateEntitlement(
  body: unknown,
  provider: EntitlementProvider
): Promise<EntitlementValidationResponse> {
  if (!isEntitlementValidationRequest(body)) {
    throw new ContractError("invalid_entitlement_request", "Entitlement validation request shape is invalid");
  }

  const request: EntitlementValidationRequest = body;
  if (!request.user_id && !request.anonymous_session_id) {
    throw new ContractError("identity_required", "user_id or anonymous_session_id is required");
  }

  const requestedProductMatchesMovie = productMatchesMovie(request.movie_id, request.storekit_product_id);
  if (!requestedProductMatchesMovie) {
    const audit = await createAuditRecord({
      event_name: "entitlement_validation_denied",
      movie_id: request.movie_id,
      storekit_product_id: request.storekit_product_id,
      detail: "StoreKit product ID does not match movie ID"
    });
    return deniedResponse(audit.audit_id, "product_mapping_mismatch");
  }

  await createAuditRecord({
    event_name: "entitlement_validation_requested",
    movie_id: request.movie_id,
    storekit_product_id: request.storekit_product_id,
    detail: "Server-side entitlement validation requested"
  });

  const providerResult = await provider.validate(request);
  if (providerResult.status !== "entitlement_approved") {
    const audit = await createAuditRecord({
      event_name: "entitlement_validation_denied",
      movie_id: request.movie_id,
      storekit_product_id: request.storekit_product_id,
      detail: providerResult.denial_reason ?? "entitlement_not_approved"
    });
    return {
      entitlement_status: providerResult.status,
      access_decision: providerResult.status,
      denial_reason: providerResult.denial_reason ?? "entitlement_not_approved",
      audit_id: audit.audit_id,
      expires_at: null,
      refresh_after: null
    };
  }

  const audit = await createAuditRecord({
    event_name: "entitlement_validation_approved",
    movie_id: request.movie_id,
    storekit_product_id: request.storekit_product_id,
    detail: "Server-side entitlement validation approved"
  });

  return {
    entitlement_status: "entitlement_approved",
    access_decision: "entitlement_approved",
    denial_reason: null,
    audit_id: audit.audit_id,
    expires_at: new Date(Date.now() + 30 * 60 * 1000).toISOString(),
    refresh_after: new Date(Date.now() + 20 * 60 * 1000).toISOString()
  };
}

function deniedResponse(auditID: string, reason: string): EntitlementValidationResponse {
  return {
    entitlement_status: "entitlement_denied",
    access_decision: "entitlement_denied",
    denial_reason: reason,
    audit_id: auditID,
    expires_at: null,
    refresh_after: null
  };
}
