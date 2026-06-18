import type { EntitlementValidationRequest } from "../contracts.js";
import type { EntitlementProvider, EntitlementProviderResult } from "../providers/providerInterfaces.js";

export class MockEntitlementProvider implements EntitlementProvider {
  constructor(private readonly mode: "approved" | "denied" | "pending" = "pending") {}

  async validate(_request: EntitlementValidationRequest): Promise<EntitlementProviderResult> {
    if (this.mode === "approved") {
      return { status: "entitlement_approved", denial_reason: null };
    }
    if (this.mode === "denied") {
      return { status: "entitlement_denied", denial_reason: "mock_entitlement_denied" };
    }
    return { status: "entitlement_pending", denial_reason: "mock_entitlement_pending" };
  }
}
