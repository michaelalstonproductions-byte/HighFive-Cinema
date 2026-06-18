export type ServerEnvironment = {
  HIGHFIVE_BACKEND_ENV: string;
  HIGHFIVE_BACKEND_PUBLIC_BASE_URL: string;
  HIGHFIVE_CLOUDFLARE_ACCOUNT_ID: string;
  HIGHFIVE_CLOUDFLARE_STREAM_API_TOKEN: string;
  HIGHFIVE_CLOUDFLARE_WEBHOOK_SECRET: string;
  HIGHFIVE_APP_STORE_BUNDLE_ID: string;
  HIGHFIVE_APP_STORE_ISSUER_ID: string;
  HIGHFIVE_APP_STORE_KEY_ID: string;
  HIGHFIVE_APP_STORE_PRIVATE_KEY: string;
  HIGHFIVE_REVENUECAT_SECRET_KEY: string;
  HIGHFIVE_DATABASE_URL: string;
  HIGHFIVE_AUDIT_LOG_SINK: string;
  HIGHFIVE_ALLOWED_PLAYBACK_TTL_SECONDS: string;
  HIGHFIVE_STOREKIT_PRODUCT_NAMESPACE: string;
};

export const requiredServerEnvNames = [
  "HIGHFIVE_BACKEND_ENV",
  "HIGHFIVE_BACKEND_PUBLIC_BASE_URL",
  "HIGHFIVE_CLOUDFLARE_ACCOUNT_ID",
  "HIGHFIVE_CLOUDFLARE_STREAM_API_TOKEN",
  "HIGHFIVE_CLOUDFLARE_WEBHOOK_SECRET",
  "HIGHFIVE_APP_STORE_BUNDLE_ID",
  "HIGHFIVE_APP_STORE_ISSUER_ID",
  "HIGHFIVE_APP_STORE_KEY_ID",
  "HIGHFIVE_APP_STORE_PRIVATE_KEY",
  "HIGHFIVE_REVENUECAT_SECRET_KEY",
  "HIGHFIVE_DATABASE_URL",
  "HIGHFIVE_AUDIT_LOG_SINK",
  "HIGHFIVE_ALLOWED_PLAYBACK_TTL_SECONDS",
  "HIGHFIVE_STOREKIT_PRODUCT_NAMESPACE"
] as const;

export function readEnvironment(source: Record<string, string | undefined>): Partial<ServerEnvironment> {
  const result: Partial<ServerEnvironment> = {};
  for (const name of requiredServerEnvNames) {
    const value = source[name];
    if (value) {
      result[name] = value;
    }
  }
  return result;
}

export function missingEnvironmentNames(env: Partial<ServerEnvironment>): string[] {
  return requiredServerEnvNames.filter((name) => !env[name]);
}
