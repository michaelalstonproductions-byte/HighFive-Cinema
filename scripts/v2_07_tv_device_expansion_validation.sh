#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${OUT_DIR:-/private/tmp/highfive-v2-07-tv-device-expansion}"
DERIVED_DATA="${DERIVED_DATA:-/Volumes/Scratch SSD/XcodeDerivedData/highfive-v2-07-tv-device-expansion}"
SUMMARY_MD="$OUT_DIR/v2_07_tv_device_expansion_summary.md"

OUT_DIR="$OUT_DIR" DERIVED_DATA="$DERIVED_DATA" bash "$ROOT_DIR/scripts/v2_06_live_premieres_validation.sh"

node - "$OUT_DIR" "$SUMMARY_MD" <<'NODE'
const fs = require("fs");
const path = require("path");
const [outDir, summaryPath] = process.argv.slice(2);
const qaSummary = JSON.parse(fs.readFileSync(path.join(outDir, "launch_qa_summary.json"), "utf8"));
const passed = qaSummary.status === "passed" && qaSummary.backend_smoke.fail === 0;
fs.writeFileSync(summaryPath, [
  "# V2-07 TV & Device Expansion Validation Summary",
  "",
  `Status: ${passed ? "passed" : "failed"}`,
  `Backend smoke: ${qaSummary.backend_smoke.pass}/${qaSummary.backend_smoke.tests} passed`,
  `iOS build: ${qaSummary.ios_build}`,
  "TV & Device Expansion: iPhone, iPad, Apple TV, Mac, CarPlay-safe consideration profiles, local AirPlay session planning, and cross-device handoff records are covered by backend smoke tests.",
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
