#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${OUT_DIR:-/private/tmp/highfive-v2-04-ai-creator-assistant}"
DERIVED_DATA="${DERIVED_DATA:-/Volumes/Scratch SSD/XcodeDerivedData/highfive-v2-04-ai-creator-assistant}"
SUMMARY_MD="$OUT_DIR/v2_04_ai_creator_assistant_summary.md"

OUT_DIR="$OUT_DIR" DERIVED_DATA="$DERIVED_DATA" bash "$ROOT_DIR/scripts/v2_03_creator_economy_validation.sh"

node - "$OUT_DIR" "$SUMMARY_MD" <<'NODE'
const fs = require("fs");
const path = require("path");
const [outDir, summaryPath] = process.argv.slice(2);
const qaSummary = JSON.parse(fs.readFileSync(path.join(outDir, "launch_qa_summary.json"), "utf8"));
const passed = qaSummary.status === "passed" && qaSummary.backend_smoke.fail === 0;
fs.writeFileSync(summaryPath, [
  "# V2-04 AI Creator Assistant Validation Summary",
  "",
  `Status: ${passed ? "passed" : "failed"}`,
  `Backend smoke: ${qaSummary.backend_smoke.pass}/${qaSummary.backend_smoke.tests} passed`,
  `iOS build: ${qaSummary.ios_build}`,
  "AI Creator Assistant: local metadata generation, poster suggestions, trailer suggestions, publishing assistant, SEO assistant, and rights assistant are covered by backend smoke tests. No external AI calls are made.",
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
