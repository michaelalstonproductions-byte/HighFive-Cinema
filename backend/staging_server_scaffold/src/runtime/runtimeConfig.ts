export type ProviderMode = "mock";
export type MockEntitlementMode = "approved" | "denied" | "pending";
export type MockDescriptorMode = "ready" | "unavailable";

export type RuntimeConfig = {
  host: "127.0.0.1";
  port: number;
  backendEnv: "local_smoke";
  providerMode: ProviderMode;
  mockEntitlementMode: MockEntitlementMode;
  mockDescriptorMode: MockDescriptorMode;
  deploymentStatus: "not_deployed";
  bodyLimitBytes: number;
  uploadBodyLimitBytes: number;
};

const defaultBodyLimitBytes = 64 * 1024;
const defaultUploadBodyLimitBytes = 10 * 1024 * 1024;

export function readRuntimeConfig(source: Record<string, string | undefined>): RuntimeConfig {
  return {
    host: readHost(source.HIGHFIVE_SERVER_HOST),
    port: readPort(source.HIGHFIVE_SERVER_PORT),
    backendEnv: readLocalSmoke(source.HIGHFIVE_BACKEND_ENV),
    providerMode: readProviderMode(source.HIGHFIVE_PROVIDER_MODE),
    mockEntitlementMode: readEntitlementMode(source.HIGHFIVE_MOCK_ENTITLEMENT_MODE),
    mockDescriptorMode: readDescriptorMode(source.HIGHFIVE_MOCK_DESCRIPTOR_MODE),
    deploymentStatus: "not_deployed",
    bodyLimitBytes: defaultBodyLimitBytes,
    uploadBodyLimitBytes: readPositiveInteger(source.HIGHFIVE_UPLOAD_BODY_LIMIT_BYTES, defaultUploadBodyLimitBytes)
  };
}

function readHost(value: string | undefined): "127.0.0.1" {
  if (!value || value === "127.0.0.1") return "127.0.0.1";
  return "127.0.0.1";
}

function readPort(value: string | undefined): number {
  if (!value) return 0;
  const parsed = Number(value);
  if (!Number.isInteger(parsed) || parsed < 0 || parsed > 65535) return 0;
  return parsed;
}

function readLocalSmoke(value: string | undefined): "local_smoke" {
  if (!value || value === "local_smoke") return "local_smoke";
  return "local_smoke";
}

function readProviderMode(value: string | undefined): ProviderMode {
  if (!value || value === "mock") return "mock";
  return "mock";
}

function readEntitlementMode(value: string | undefined): MockEntitlementMode {
  if (value === "approved" || value === "denied" || value === "pending") return value;
  return "pending";
}

function readDescriptorMode(value: string | undefined): MockDescriptorMode {
  if (value === "ready" || value === "unavailable") return value;
  return "unavailable";
}

function readPositiveInteger(value: string | undefined, fallback: number): number {
  if (!value) return fallback;
  const parsed = Number(value);
  if (!Number.isInteger(parsed) || parsed <= 0) return fallback;
  return parsed;
}
