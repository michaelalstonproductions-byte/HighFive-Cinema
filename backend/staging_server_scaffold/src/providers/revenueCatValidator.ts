import type { EntitlementValidationRequest } from "../contracts.js";
import type { EntitlementProvider, EntitlementProviderResult } from "./providerInterfaces.js";

export class RevenueCatValidatorPlaceholder implements EntitlementProvider {
  async validate(_request: EntitlementValidationRequest): Promise<EntitlementProviderResult> {
    return {
      status: "entitlement_pending",
      denial_reason: "revenuecat_validation_not_configured"
    };
  }
}
