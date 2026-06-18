import type { IncomingMessage } from "node:http";
import { MockCloudflareSigner } from "../mocks/mockCloudflareSigner.js";
import { MockEntitlementProvider } from "../mocks/mockEntitlementProvider.js";
import type { EntitlementProvider, PlaybackDescriptorSigner } from "../providers/providerInterfaces.js";
import type { MockDescriptorMode, MockEntitlementMode, RuntimeConfig } from "./runtimeConfig.js";

export function entitlementProviderForRequest(
  request: IncomingMessage,
  config: RuntimeConfig
): EntitlementProvider {
  return new MockEntitlementProvider(readEntitlementModeHeader(request, config.mockEntitlementMode));
}

export function descriptorSignerForRequest(
  request: IncomingMessage,
  config: RuntimeConfig
): PlaybackDescriptorSigner {
  return new MockCloudflareSigner(readDescriptorModeHeader(request, config.mockDescriptorMode));
}

function readEntitlementModeHeader(request: IncomingMessage, fallback: MockEntitlementMode): MockEntitlementMode {
  const value = singleHeader(request.headers["x-highfive-smoke-entitlement-mode"]);
  if (value === "approved" || value === "denied" || value === "pending") return value;
  return fallback;
}

function readDescriptorModeHeader(request: IncomingMessage, fallback: MockDescriptorMode): MockDescriptorMode {
  const value = singleHeader(request.headers["x-highfive-smoke-descriptor-mode"]);
  if (value === "ready" || value === "unavailable") return value;
  return fallback;
}

function singleHeader(value: string | string[] | undefined): string | undefined {
  if (Array.isArray(value)) return value[0];
  return value;
}
