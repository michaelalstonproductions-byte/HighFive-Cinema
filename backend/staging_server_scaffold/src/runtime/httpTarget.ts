import { createServer, type Server } from "node:http";
import { entitlementValidationPath, playbackDescriptorPath } from "../contracts.js";
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
    credentials_required: false,
    external_network_allowed: false,
    local_preview_fallback_preserved: true
  };
}
