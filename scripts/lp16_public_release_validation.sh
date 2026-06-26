#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${OUT_DIR:-/private/tmp/highfive-lp16-public-release}"
DERIVED_DATA="${DERIVED_DATA:-/Volumes/Scratch SSD/XcodeDerivedData/highfive-lp16-public-release}"
SUMMARY_MD="$OUT_DIR/public_release_validation_summary.md"

OUT_DIR="$OUT_DIR" DERIVED_DATA="$DERIVED_DATA" bash "$ROOT_DIR/scripts/lp15_launch_validation.sh"

node - "$ROOT_DIR" "$OUT_DIR" "$SUMMARY_MD" <<'NODE'
const fs = require("fs");
const path = require("path");
const [rootDir, outDir, summaryPath] = process.argv.slice(2);
const qaSummary = JSON.parse(fs.readFileSync(path.join(outDir, "launch_qa_summary.json"), "utf8"));
const runbookPath = path.join(rootDir, "docs/launch/PUBLIC_RELEASE_RUNBOOK.md");
const runbookPresent = fs.existsSync(runbookPath) && fs.statSync(runbookPath).size > 0;
const passed = qaSummary.status === "passed" && runbookPresent;
fs.writeFileSync(summaryPath, [
  "# LP16 Public Release Validation Summary",
  "",
  `Status: ${passed ? "passed" : "failed"}`,
  `Backend smoke: ${qaSummary.backend_smoke.pass}/${qaSummary.backend_smoke.tests} passed`,
  `iOS build: ${qaSummary.ios_build}`,
  `Public release runbook: ${runbookPresent ? "present" : "missing"}`,
  "Public release operations: submit, cutover, monitor, hotfix, analytics, creator onboarding, and audit are covered by backend smoke tests.",
  "",
  "Screenshots:",
  ...qaSummary.screenshots.map((shot) => `- ${shot.path} (${shot.bytes} bytes)`),
  "",
  "Manual public release requirements:",
  "- App Store Connect submission",
  "- App Store release cutover",
  "- Hosted production monitoring",
  "- Final legal and privacy approval",
  ""
].join("\n"));
console.log(fs.readFileSync(summaryPath, "utf8"));
if (!passed) {
  process.exit(1);
}
NODE
