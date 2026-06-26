import { writeFileSync } from "node:fs";
import { readRuntimeConfig } from "./runtimeConfig.js";

const config = readRuntimeConfig(process.env);
const readyBody = JSON.stringify({
  status: "ready",
  role: "media-processing-worker",
  environment: config.backendEnv,
  provider_mode: config.providerMode,
  deployment_status: config.deploymentStatus,
  queue: process.env.HIGHFIVE_MEDIA_QUEUE_NAME ?? "highfive-media-processing",
  object_store: process.env.HIGHFIVE_OBJECT_STORAGE_MODE ?? "s3_compatible",
  ffmpeg_contract: true,
  ffprobe_contract: true,
  hls_output_contract: true
});

const readyFile = process.env.HIGHFIVE_READY_FILE;
if (readyFile) {
  writeFileSync(readyFile, `${readyBody}\n`);
}

process.stdout.write(`highfive media worker ready ${readyBody}\n`);

const heartbeat = setInterval(() => {
  process.stdout.write("highfive media worker heartbeat\n");
}, 60_000);

function shutdown(): void {
  clearInterval(heartbeat);
  process.stdout.write("highfive media worker stopped\n");
  process.exitCode = 0;
}

process.on("SIGTERM", shutdown);
process.on("SIGINT", shutdown);
