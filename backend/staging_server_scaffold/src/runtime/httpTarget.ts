import { createServer, type Server } from "node:http";
import {
  catalogPath,
  catalogDeltaPath,
  catalogSyncPath,
  collectionDetailPath,
  contentDetailPath,
  creatorDraftDetailPath,
  creatorDraftsPath,
  creatorDraftSyncQueuePath,
  creatorWorkspacePath,
  creatorDetailPath,
  creatorUploadAssetsPath,
  creatorUploadDetailPath,
  creatorUploadSessionsPath,
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
import {
  archiveCreatorDraftRemote,
  createCreatorDraftRemote,
  creatorDraftRevisionHistory,
  creatorDraftSyncQueue,
  getCreatorDraft,
  listCreatorDrafts,
  publishingReadinessSummary,
  restoreCreatorDraftRemote,
  updateCreatorDraftRemote
} from "../routes/publishing.js";
import { createEntitlementRoute } from "../routes/entitlements.js";
import { createPlaybackRoute } from "../routes/playback.js";
import { descriptorSignerForRequest, entitlementProviderForRequest } from "./providerFactory.js";
import {
  errorResponse,
  methodNotAllowed,
  readBoundedJsonBody,
  readBoundedBinaryBody,
  routeNotFound,
  writeJson
} from "./httpResponse.js";
import {
  cancelCreatorUploadSession,
  createCreatorUploadSession,
  listCreatorUploadedAssets,
  putCreatorUploadBlob,
  uploadReadinessSummary
} from "../routes/uploads.js";
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

      if (path === creatorDraftsPath) {
        if (request.method === "GET") {
          writeJson(response, 200, listCreatorDrafts(authHeader(request.headers.authorization)));
          return;
        }
        if (request.method === "POST") {
          const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
          writeJson(response, 201, createCreatorDraftRemote(authHeader(request.headers.authorization), body));
          return;
        }
        const result = methodNotAllowed();
        writeJson(response, result.statusCode, result.body);
        return;
      }

      if (path === creatorDraftSyncQueuePath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, creatorDraftSyncQueue(authHeader(request.headers.authorization)));
        return;
      }

      if (path === creatorUploadSessionsPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 201, createCreatorUploadSession(authHeader(request.headers.authorization), body, originFor(request, config)));
        return;
      }

      if (path === creatorUploadAssetsPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, listCreatorUploadedAssets(authHeader(request.headers.authorization)));
        return;
      }

      if (path.startsWith(creatorUploadDetailPath)) {
        const uploadRoute = creatorUploadRoute(path);
        if (uploadRoute.action === "blob") {
          if (request.method !== "PUT") {
            const result = methodNotAllowed();
            writeJson(response, result.statusCode, result.body);
            return;
          }
          const data = await readBoundedBinaryBody(request, config.uploadBodyLimitBytes);
          writeJson(response, 200, await putCreatorUploadBlob(authHeader(request.headers.authorization), uploadRoute.id, data));
          return;
        }
        if (uploadRoute.action === "cancel") {
          if (request.method !== "POST") {
            const result = methodNotAllowed();
            writeJson(response, result.statusCode, result.body);
            return;
          }
          writeJson(response, 200, await cancelCreatorUploadSession(authHeader(request.headers.authorization), uploadRoute.id));
          return;
        }
        const result = routeNotFound();
        writeJson(response, result.statusCode, result.body);
        return;
      }

      if (path.startsWith(creatorDraftDetailPath)) {
        const draftRoute = creatorDraftRoute(path);
        if (draftRoute.action === "archive") {
          if (request.method !== "POST") {
            const result = methodNotAllowed();
            writeJson(response, result.statusCode, result.body);
            return;
          }
          const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
          writeJson(response, 200, archiveCreatorDraftRemote(authHeader(request.headers.authorization), draftRoute.id, body));
          return;
        }
        if (draftRoute.action === "restore") {
          if (request.method !== "POST") {
            const result = methodNotAllowed();
            writeJson(response, result.statusCode, result.body);
            return;
          }
          const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
          writeJson(response, 200, restoreCreatorDraftRemote(authHeader(request.headers.authorization), draftRoute.id, body));
          return;
        }
        if (draftRoute.action === "revisions") {
          if (request.method !== "GET") {
            const result = methodNotAllowed();
            writeJson(response, result.statusCode, result.body);
            return;
          }
          writeJson(response, 200, creatorDraftRevisionHistory(authHeader(request.headers.authorization), draftRoute.id));
          return;
        }
        if (request.method === "GET") {
          writeJson(response, 200, getCreatorDraft(authHeader(request.headers.authorization), draftRoute.id));
          return;
        }
        if (request.method === "PATCH") {
          const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
          writeJson(response, 200, updateCreatorDraftRemote(authHeader(request.headers.authorization), draftRoute.id, body));
          return;
        }
        const result = methodNotAllowed();
        writeJson(response, result.statusCode, result.body);
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
    creator_upload_sessions_path: creatorUploadSessionsPath,
    creator_upload_assets_path: creatorUploadAssetsPath,
    credentials_required: false,
    external_network_allowed: false,
    local_preview_fallback_preserved: true
  };
}

function readinessBody(config: RuntimeConfig): Record<string, string | number | boolean> {
  const summary = catalogSummary();
  const identity = identityReadinessSummary();
  const publishing = publishingReadinessSummary();
  const uploads = uploadReadinessSummary();
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
    uploads_enabled: true,
    signed_upload_sessions: Boolean(uploads.signed_upload_sessions),
    local_object_storage: Boolean(uploads.local_object_storage),
    upload_checksum_validation: Boolean(uploads.checksum_validation),
    uploaded_asset_records: Number(uploads.uploaded_assets),
    auth_enabled: Boolean(identity.auth_enabled),
    sign_in_with_apple_contract: Boolean(identity.sign_in_with_apple_contract),
    development_identity_mode: Boolean(identity.development_identity_mode),
    role_authorization: Boolean(identity.role_authorization),
    creator_draft_sync_enabled: Boolean(publishing.creator_draft_sync_enabled),
    optimistic_concurrency: Boolean(publishing.optimistic_concurrency),
    draft_role_enforcement: Boolean(publishing.role_enforcement),
    payments_enabled: false
  };
}

function creatorDraftRoute(path: string): { id: string; action: string | null } {
  const suffix = path.slice(creatorDraftDetailPath.length);
  const parts = suffix.split("/").filter(Boolean).map(decodeURIComponent);
  return {
    id: parts[0] ?? "",
    action: parts[1] ?? null
  };
}

function creatorUploadRoute(path: string): { id: string; action: string | null } {
  const suffix = path.slice(creatorUploadDetailPath.length);
  const parts = suffix.split("/").filter(Boolean).map(decodeURIComponent);
  return {
    id: parts[0] ?? "",
    action: parts[1] ?? null
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

function originFor(request: { headers: { host?: string | string[] | undefined } }, config: RuntimeConfig): string {
  const host = authHeader(request.headers.host) ?? `${config.host}:${config.port}`;
  return `http://${host}`;
}
