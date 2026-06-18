import { createServer, type IncomingMessage, type ServerResponse } from "node:http";
import { entitlementValidationPath, playbackDescriptorPath } from "./contracts.js";
import { errorBody } from "./errors.js";
import { MockCloudflareSigner } from "./mocks/mockCloudflareSigner.js";
import { MockEntitlementProvider } from "./mocks/mockEntitlementProvider.js";
import { createEntitlementRoute } from "./routes/entitlements.js";
import { createPlaybackRoute } from "./routes/playback.js";

const entitlementRoute = createEntitlementRoute(new MockEntitlementProvider("pending"));
const playbackRoute = createPlaybackRoute(new MockCloudflareSigner("unavailable"));

export function createStagingServer() {
  return createServer(async (request, response) => {
    try {
      if (request.method !== "POST") {
        writeJson(response, 405, { error: "method_not_allowed" });
        return;
      }

      const body = await readJsonBody(request);
      if (request.url === entitlementValidationPath) {
        writeJson(response, 200, await entitlementRoute(body));
        return;
      }

      if (request.url === playbackDescriptorPath) {
        writeJson(response, 200, await playbackRoute(body));
        return;
      }

      writeJson(response, 404, { error: "route_not_found" });
    } catch (error) {
      writeJson(response, 400, errorBody(error));
    }
  });
}

async function readJsonBody(request: IncomingMessage): Promise<unknown> {
  const chunks: Buffer[] = [];
  for await (const chunk of request) {
    chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk));
  }
  if (chunks.length === 0) {
    return {};
  }
  return JSON.parse(Buffer.concat(chunks).toString("utf8"));
}

function writeJson(response: ServerResponse, statusCode: number, body: unknown): void {
  response.writeHead(statusCode, {
    "Content-Type": "application/json",
    "Cache-Control": "no-store"
  });
  response.end(JSON.stringify(body));
}

if (process.env.HIGHFIVE_BACKEND_ENV === "local_scaffold") {
  const port = Number(process.env.PORT ?? "8787");
  createStagingServer().listen(port);
}
