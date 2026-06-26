#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${OUT_DIR:-/private/tmp/highfive-lp15-launch}"
DERIVED_DATA="${DERIVED_DATA:-/Volumes/Scratch SSD/XcodeDerivedData/highfive-lp15-launch}"
MANIFEST="$ROOT_DIR/docs/launch/LAUNCH_ASSET_MANIFEST.json"
SUMMARY_MD="$OUT_DIR/launch_validation_summary.md"

OUT_DIR="$OUT_DIR" DERIVED_DATA="$DERIVED_DATA" bash "$ROOT_DIR/scripts/lp14_beta_validation.sh"

node - "$ROOT_DIR" "$OUT_DIR" "$MANIFEST" "$SUMMARY_MD" <<'NODE'
const fs = require("fs");
const path = require("path");
const [rootDir, outDir, manifestPath, summaryPath] = process.argv.slice(2);
const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
const qaSummary = JSON.parse(fs.readFileSync(path.join(outDir, "launch_qa_summary.json"), "utf8"));
const missingDocs = manifest.required_documents.filter((doc) => !fs.existsSync(path.join(rootDir, doc)));
const missingShots = manifest.required_screenshots.filter((shot) => {
  const screenshotPath = path.join(outDir, "screenshots", shot);
  return !fs.existsSync(screenshotPath) || fs.statSync(screenshotPath).size <= 0;
});
const docSizes = manifest.required_documents.map((doc) => ({
  path: doc,
  bytes: fs.statSync(path.join(rootDir, doc)).size
}));
const launchReady = qaSummary.status === "passed" && missingDocs.length === 0 && missingShots.length === 0;
fs.writeFileSync(summaryPath, [
  "# LP15 Launch Validation Summary",
  "",
  `Status: ${launchReady ? "passed" : "failed"}`,
  `Backend smoke: ${qaSummary.backend_smoke.pass}/${qaSummary.backend_smoke.tests} passed`,
  `iOS build: ${qaSummary.ios_build}`,
  `Required documents: ${docSizes.length}/${manifest.required_documents.length} present`,
  `Required screenshots: ${manifest.required_screenshots.length - missingShots.length}/${manifest.required_screenshots.length} present`,
  "",
  "Launch documents:",
  ...docSizes.map((item) => `- ${item.path} (${item.bytes} bytes)`),
  "",
  "Screenshots:",
  ...qaSummary.screenshots.map((shot) => `- ${shot.path} (${shot.bytes} bytes)`),
  "",
  "Manual public-launch requirements:",
  ...manifest.manual_review_required.map((item) => `- ${item}`),
  ""
].join("\n"));
console.log(fs.readFileSync(summaryPath, "utf8"));
if (!launchReady) {
  process.exit(1);
}
NODE
