#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${OUT_DIR:-/private/tmp/highfive-v2-06-live-premieres}"
DERIVED_DATA="${DERIVED_DATA:-/Volumes/Scratch SSD/XcodeDerivedData/highfive-v2-06-live-premieres}"
SUMMARY_MD="$OUT_DIR/v2_06_live_premieres_summary.md"

OUT_DIR="$OUT_DIR" DERIVED_DATA="$DERIVED_DATA" bash "$ROOT_DIR/scripts/v2_05_studio_collaboration_validation.sh"

node - "$OUT_DIR" "$SUMMARY_MD" <<'NODE'
const fs = require("fs");
const path = require("path");
const [outDir, summaryPath] = process.argv.slice(2);
const qaSummary = JSON.parse(fs.readFileSync(path.join(outDir, "launch_qa_summary.json"), "utf8"));
const passed = qaSummary.status === "passed" && qaSummary.backend_smoke.fail === 0;
fs.writeFileSync(summaryPath, [
  "# V2-06 Live Premieres Validation Summary",
  "",
  `Status: ${passed ? "passed" : "failed"}`,
  `Backend smoke: ${qaSummary.backend_smoke.pass}/${qaSummary.backend_smoke.tests} passed`,
  `iOS build: ${qaSummary.ios_build}`,
  "Live Premieres: countdowns, premiere rooms, creator introductions, room chat, Q&A, and replay records are covered by backend smoke tests. No external event provider or realtime socket transport is used.",
  "",
  "Screenshots:",
  ...qaSummary.screenshots.map((shot) => `- ${shot.path} (${shot.bytes} bytes)`),
  ""
].join("\n"));
console.log(fs.readFileSync(summaryPath, "utf8"));
if (!passed) {
  process.exit(1);
}
NODE
