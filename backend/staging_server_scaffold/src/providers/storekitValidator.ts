import type { EntitlementValidationRequest } from "../contracts.js";
import type { EntitlementProvider, EntitlementProviderResult } from "./providerInterfaces.js";

export class StoreKitValidatorPlaceholder implements EntitlementProvider {
  async validate(_request: EntitlementValidationRequest): Promise<EntitlementProviderResult> {
    return {
      status: "entitlement_pending",
      denial_reason: "storekit_validation_not_configured"
    };
  }
}
