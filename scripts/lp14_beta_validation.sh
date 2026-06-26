#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${OUT_DIR:-/private/tmp/highfive-lp14-beta}"
DERIVED_DATA="${DERIVED_DATA:-/Volumes/Scratch SSD/XcodeDerivedData/highfive-lp14-beta}"

OUT_DIR="$OUT_DIR" DERIVED_DATA="$DERIVED_DATA" bash "$ROOT_DIR/scripts/lp13_launch_qa.sh"

node - "$OUT_DIR/launch_qa_summary.json" "$OUT_DIR/beta_validation_summary.md" <<'NODE'
const fs = require("fs");
const [summaryPath, betaPath] = process.argv.slice(2);
const summary = JSON.parse(fs.readFileSync(summaryPath, "utf8"));
fs.writeFileSync(betaPath, [
  "# LP14 Beta Validation Summary",
  "",
  `Status: ${summary.status}`,
  `Backend smoke: ${summary.backend_smoke.pass}/${summary.backend_smoke.tests} passed`,
  `iOS build: ${summary.ios_build}`,
  "Beta operations: enrollments, feedback intake, crash intake, resolution workflow, audit trail, and stability gate covered by backend smoke tests.",
  "",
  "Screenshots:",
  ...summary.screenshots.map((shot) => `- ${shot.path} (${shot.bytes} bytes)`),
  ""
].join("\n"));
console.log(fs.readFileSync(betaPath, "utf8"));
NODE
