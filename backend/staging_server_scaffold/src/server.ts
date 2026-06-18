import { createStagingHttpTarget } from "./runtime/httpTarget.js";
import { readRuntimeConfig } from "./runtime/runtimeConfig.js";

export function createStagingServer() {
  return createStagingHttpTarget(readRuntimeConfig(process.env));
}

if (process.env.HIGHFIVE_BACKEND_ENV === "local_smoke") {
  const config = readRuntimeConfig(process.env);
  createStagingServer().listen(config.port, config.host);
}
