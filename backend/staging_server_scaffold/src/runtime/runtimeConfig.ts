export type ProviderMode = "mock";
export type MockEntitlementMode = "approved" | "denied" | "pending";
export type MockDescriptorMode = "ready" | "unavailable";
export type BackendEnv = "local_smoke" | "production";
export type ServerHost = "127.0.0.1" | "0.0.0.0";
export type DeploymentStatus = "not_deployed" | "production_infrastructure_ready";

export type RuntimeConfig = {
  host: ServerHost;
  port: number;
  backendEnv: BackendEnv;
  providerMode: ProviderMode;
  mockEntitlementMode: MockEntitlementMode;
  mockDescriptorMode: MockDescriptorMode;
  deploymentStatus: DeploymentStatus;
  bodyLimitBytes: number;
  uploadBodyLimitBytes: number;
  rateLimitRequests: number;
  rateLimitWindowMs: number;
};

const defaultBodyLimitBytes = 64 * 1024;
const defaultUploadBodyLimitBytes = 10 * 1024 * 1024;
const defaultRateLimitRequests = 240;
const defaultRateLimitWindowMs = 60 * 1000;

export function readRuntimeConfig(source: Record<string, string | undefined>): RuntimeConfig {
  return {
    host: readHost(source.HIGHFIVE_SERVER_HOST),
    port: readPort(source.HIGHFIVE_SERVER_PORT),
    backendEnv: readLocalSmoke(source.HIGHFIVE_BACKEND_ENV),
    providerMode: readProviderMode(source.HIGHFIVE_PROVIDER_MODE),
    mockEntitlementMode: readEntitlementMode(source.HIGHFIVE_MOCK_ENTITLEMENT_MODE),
    mockDescriptorMode: readDescriptorMode(source.HIGHFIVE_MOCK_DESCRIPTOR_MODE),
    deploymentStatus: readDeploymentStatus(source.HIGHFIVE_DEPLOYMENT_STATUS),
    bodyLimitBytes: defaultBodyLimitBytes,
    uploadBodyLimitBytes: readPositiveInteger(source.HIGHFIVE_UPLOAD_BODY_LIMIT_BYTES, defaultUploadBodyLimitBytes),
    rateLimitRequests: readPositiveInteger(source.HIGHFIVE_RATE_LIMIT_REQUESTS, defaultRateLimitRequests),
    rateLimitWindowMs: readPositiveInteger(source.HIGHFIVE_RATE_LIMIT_WINDOW_MS, defaultRateLimitWindowMs)
  };
}

function readHost(value: string | undefined): ServerHost {
  if (!value || value === "127.0.0.1") return "127.0.0.1";
  if (value === "0.0.0.0") return "0.0.0.0";
  return "127.0.0.1";
}

function readPort(value: string | undefined): number {
  if (!value) return 0;
  const parsed = Number(value);
  if (!Number.isInteger(parsed) || parsed < 0 || parsed > 65535) return 0;
  return parsed;
}

function readLocalSmoke(value: string | undefined): BackendEnv {
  if (!value || value === "local_smoke") return "local_smoke";
  if (value === "production") return "production";
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

function readDeploymentStatus(value: string | undefined): DeploymentStatus {
  if (value === "production_infrastructure_ready") return "production_infrastructure_ready";
  return "not_deployed";
}

function readPositiveInteger(value: string | undefined, fallback: number): number {
  if (!value) return fallback;
  const parsed = Number(value);
  if (!Number.isInteger(parsed) || parsed <= 0) return fallback;
  return parsed;
}
