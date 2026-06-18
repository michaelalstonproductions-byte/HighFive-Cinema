import { writeFileSync } from "node:fs";
import { createStagingHttpTarget } from "./httpTarget.js";
import { readRuntimeConfig } from "./runtimeConfig.js";

const config = readRuntimeConfig(process.env);
const server = createStagingHttpTarget(config);

server.listen(config.port, config.host, () => {
  const address = server.address();
  const port = typeof address === "object" && address ? address.port : config.port;
  const readyBody = JSON.stringify({
    status: "ready",
    host: config.host,
    port,
    environment: config.backendEnv,
    provider_mode: config.providerMode,
    deployment_status: config.deploymentStatus
  });

  const readyFile = process.env.HIGHFIVE_READY_FILE;
  if (readyFile) {
    writeFileSync(readyFile, `${readyBody}\n`);
  }
  process.stdout.write(`highfive staging http ready ${config.host}:${port}\n`);
});

function shutdown(): void {
  server.close(() => {
    process.stdout.write("highfive staging http stopped\n");
  });
}

process.on("SIGTERM", shutdown);
process.on("SIGINT", shutdown);
