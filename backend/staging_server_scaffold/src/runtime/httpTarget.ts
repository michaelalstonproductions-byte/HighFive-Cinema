import { createServer, type Server } from "node:http";
import {
  catalogPath,
  catalogDeltaPath,
  catalogSyncPath,
  collectionDetailPath,
  contentDetailPath,
  creatorWorkspacePath,
  creatorDetailPath,
  entitlementValidationPath,
  identityAppleExchangePath,
  identityAuditPath,
  identityDeleteRequestPath,
  identityDevSignInPath,
  identityMePath,
  identityRefreshPath,
  identitySignOutPath,
  openAPIPath,
  playbackDescriptorPath,
  readinessPath
} from "../contracts.js";
import { openAPISpec } from "../catalog/openapi.js";
import { catalogDelta, catalogSummary, catalogSync, collectionDetail, contentDetail, creatorDetail } from "../routes/catalog.js";
import {
  createDevelopmentIdentitySession,
  creatorWorkspaceMutation,
  currentIdentitySession,
  exchangeAppleIdentity,
  identityAuditTrail,
  identityReadinessSummary,
  refreshIdentitySession,
  requestAccountDeletion,
  signOutIdentitySession
} from "../routes/identity.js";
import { createEntitlementRoute } from "../routes/entitlements.js";
import { createPlaybackRoute } from "../routes/playback.js";
import { descriptorSignerForRequest, entitlementProviderForRequest } from "./providerFactory.js";
import {
  errorResponse,
  methodNotAllowed,
  readBoundedJsonBody,
  routeNotFound,
  writeJson
} from "./httpResponse.js";
import type { RuntimeConfig } from "./runtimeConfig.js";

export function createStagingHttpTarget(config: RuntimeConfig): Server {
  return createServer(async (request, response) => {
    try {
      const path = request.url?.split("?")[0] ?? "/";

      if (path === "/health") {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, healthBody(config));
        return;
      }

      if (path === readinessPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, readinessBody(config));
        return;
      }

      if (path === openAPIPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, openAPISpec());
        return;
      }

      if (path === catalogPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, catalogSummary());
        return;
      }

      if (path === catalogSyncPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, catalogSync(queryValue(request.url, "cursor")));
        return;
      }

      if (path === catalogDeltaPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, catalogDelta(queryValue(request.url, "cursor")));
        return;
      }

      if (path === identityDevSignInPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 200, createDevelopmentIdentitySession(body));
        return;
      }

      if (path === identityAppleExchangePath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 200, exchangeAppleIdentity(body));
        return;
      }

      if (path === identityRefreshPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, refreshIdentitySession(authHeader(request.headers.authorization)));
        return;
      }

      if (path === identitySignOutPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, signOutIdentitySession(authHeader(request.headers.authorization)));
        return;
      }

      if (path === identityMePath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, currentIdentitySession(authHeader(request.headers.authorization)));
        return;
      }

      if (path === identityDeleteRequestPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, requestAccountDeletion(authHeader(request.headers.authorization)));
        return;
      }

      if (path === identityAuditPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, identityAuditTrail());
        return;
      }

      if (path === creatorWorkspacePath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, creatorWorkspaceMutation(authHeader(request.headers.authorization)));
        return;
      }

      if (path.startsWith(contentDetailPath)) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, contentDetail(routeID(path, contentDetailPath)));
        return;
      }

      if (path.startsWith(creatorDetailPath)) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, creatorDetail(routeID(path, creatorDetailPath)));
        return;
      }

      if (path.startsWith(collectionDetailPath)) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, collectionDetail(routeID(path, collectionDetailPath)));
        return;
      }

      if (path === entitlementValidationPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        const route = createEntitlementRoute(entitlementProviderForRequest(request, config));
        writeJson(response, 200, await route(body));
        return;
      }

      if (path === playbackDescriptorPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        const route = createPlaybackRoute(descriptorSignerForRequest(request, config));
        writeJson(response, 200, await route(body));
        return;
      }

      const result = routeNotFound();
      writeJson(response, result.statusCode, result.body);
    } catch (error) {
      const result = errorResponse(error);
      writeJson(response, result.statusCode, result.body);
    }
  });
}

function healthBody(config: RuntimeConfig): Record<string, string | boolean> {
  return {
    status: "ok",
    environment: config.backendEnv,
    provider_mode: config.providerMode,
    deployment_status: config.deploymentStatus,
    target_name: "highfive-staging-node-http",
    health_path: "/health",
    entitlement_path: entitlementValidationPath,
    descriptor_path: playbackDescriptorPath,
    readiness_path: readinessPath,
    catalog_path: catalogPath,
    catalog_sync_path: catalogSyncPath,
    catalog_delta_path: catalogDeltaPath,
    credentials_required: false,
    external_network_allowed: false,
    local_preview_fallback_preserved: true
  };
}

function readinessBody(config: RuntimeConfig): Record<string, string | number | boolean> {
  const summary = catalogSummary();
  const identity = identityReadinessSummary();
  return {
    status: "ready",
    environment: config.backendEnv,
    database_schema: "postgresql_compatible_v1",
    migrations_required: true,
    seed_data_loaded: true,
    catalog_titles: summary.total_titles,
    catalog_creators: summary.total_creators,
    catalog_collections: summary.total_collections,
    catalog_sync_enabled: true,
    delta_sync_enabled: true,
    uploads_enabled: false,
    auth_enabled: Boolean(identity.auth_enabled),
    sign_in_with_apple_contract: Boolean(identity.sign_in_with_apple_contract),
    development_identity_mode: Boolean(identity.development_identity_mode),
    role_authorization: Boolean(identity.role_authorization),
    payments_enabled: false
  };
}

function routeID(path: string, prefix: string): string {
  return decodeURIComponent(path.slice(prefix.length));
}

function authHeader(value: string | string[] | undefined): string | undefined {
  return Array.isArray(value) ? value[0] : value;
}

function queryValue(rawURL: string | undefined, name: string): string | null {
  if (!rawURL) return null;
  const url = new URL(rawURL, "http://127.0.0.1");
  return url.searchParams.get(name);
}
