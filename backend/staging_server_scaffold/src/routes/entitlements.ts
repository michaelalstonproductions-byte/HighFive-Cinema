import { validateEntitlement } from "../entitlements/validateEntitlement.js";
import type { EntitlementProvider } from "../providers/providerInterfaces.js";

export function createEntitlementRoute(provider: EntitlementProvider) {
  return async (body: unknown) => validateEntitlement(body, provider);
}
