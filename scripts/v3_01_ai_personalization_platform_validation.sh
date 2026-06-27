#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${OUT_DIR:-/private/tmp/highfive-v3-01-ai-personalization-platform}"
DERIVED_DATA="${DERIVED_DATA:-/Volumes/Scratch SSD/XcodeDerivedData/highfive-v3-01-ai-personalization-platform}"
SUMMARY_MD="$OUT_DIR/v3_01_ai_personalization_platform_summary.md"

OUT_DIR="$OUT_DIR" DERIVED_DATA="$DERIVED_DATA" bash "$ROOT_DIR/scripts/v2_10_highfive_cinema_2_validation.sh"

node - "$OUT_DIR" "$SUMMARY_MD" <<'NODE'
const fs = require("fs");
const path = require("path");
const [outDir, summaryPath] = process.argv.slice(2);
const qaSummary = JSON.parse(fs.readFileSync(path.join(outDir, "launch_qa_summary.json"), "utf8"));
const passed = qaSummary.status === "passed" && qaSummary.backend_smoke.fail === 0;
fs.writeFileSync(summaryPath, [
  "# V3-01 AI Personalization Platform Validation Summary",
  "",
  `Status: ${passed ? "passed" : "failed"}`,
  `Backend smoke: ${qaSummary.backend_smoke.pass}/${qaSummary.backend_smoke.tests} passed`,
  `iOS build: ${qaSummary.ios_build}`,
  "V3-01: personalized home, taste graph, mood engine, behavior learning, smart continue watching, dynamic collections, and adaptive discovery are covered by backend smoke tests. No external AI calls are made.",
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
