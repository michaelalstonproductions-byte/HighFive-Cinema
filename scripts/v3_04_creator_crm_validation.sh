#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${OUT_DIR:-/private/tmp/highfive-v3-04-creator-crm}"
DERIVED_DATA="${DERIVED_DATA:-/Volumes/Scratch SSD/XcodeDerivedData/highfive-v3-04-creator-crm}"
SUMMARY_MD="$OUT_DIR/v3_04_creator_crm_summary.md"

OUT_DIR="$OUT_DIR" DERIVED_DATA="$DERIVED_DATA" bash "$ROOT_DIR/scripts/v3_03_ai_creator_copilot_validation.sh"

node - "$OUT_DIR" "$SUMMARY_MD" <<'NODE'
const fs = require("fs");
const path = require("path");
const [outDir, summaryPath] = process.argv.slice(2);
const qaSummary = JSON.parse(fs.readFileSync(path.join(outDir, "launch_qa_summary.json"), "utf8"));
const passed = qaSummary.status === "passed" && qaSummary.backend_smoke.fail === 0;
fs.writeFileSync(summaryPath, [
  "# V3-04 Creator CRM Validation Summary",
  "",
  `Status: ${passed ? "passed" : "failed"}`,
  `Backend smoke: ${qaSummary.backend_smoke.pass}/${qaSummary.backend_smoke.tests} passed`,
  `iOS build: ${qaSummary.ios_build}`,
  "V3-04: creator inbox, contracts, tasks, milestones, teams, and deliverables are covered by backend smoke tests. All CRM behavior remains local.",
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
