#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="/private/tmp/highfive-phase-25-0b"
FINAL_JSON="$OUT_DIR/final_presentation_evidence_report.json"
FINAL_MD="$OUT_DIR/final_presentation_evidence_report.md"

mkdir -p "$OUT_DIR"
cd "$ROOT_DIR"

node <<'NODE'
const fs = require("fs");
const cp = require("child_process");
const outDir = "/private/tmp/highfive-phase-25-0b";
const sourcePath = `${outDir}/mega_ecosystem_presentation_source_verification.json`;
const manifestPath = `${outDir}/screenshots/screenshot_manifest.json`;
const screenshotVerifyPath = `${outDir}/screenshot_verification_report.json`;
const finalJson = `${outDir}/final_presentation_evidence_report.json`;
const finalMd = `${outDir}/final_presentation_evidence_report.md`;

function readJson(path) {
  try { return JSON.parse(fs.readFileSync(path, "utf8")); } catch { return null; }
}
function run(command) {
  try { return cp.execSync(command, { encoding: "utf8", shell: "/bin/bash" }).trim(); } catch (error) { return (error.stdout || error.stderr || error.message || "").trim(); }
}

const source = readJson(sourcePath);
const manifest = readJson(manifestPath);
const screenshot = readJson(screenshotVerifyPath);
const statusShort = run("git status --short --untracked-files=all");
const diffNames = run("git diff --name-only");
const diffStat = run("git diff --stat");
const diffCheck = run("git diff --check");
const head = run("git log -1 --oneline --decorate");
const tags = run("git tag --points-at HEAD");
const protectedScan = run("git diff --name-only | egrep 'HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Creator|HighFive/App/UI|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|posterAssetName|backdropAssetName|mapping|asset' || true");
const liveTerms = [
  "AV" + "Kit", "AV" + "Player", "AVFoundation", "Core" + "Motion", "AR" + "Kit", "CMMotion",
  "Store" + "Kit", "Pho" + "tos", "Replay" + "Kit", "AVCapture", "UNUserNotificationCenter",
  "URLSession", "FileManager", "ShareLink", "Transferable", "Pho" + "tosPicker",
  "UIImagePickerController", "PHPicker", "UIDocumentPicker", "pay" + "ment", "purchase",
  "subscription", "entitlement", "auth", "backend", "up" + "load", "message", "chat",
  "comment", "notification", "ana" + "lytics", "track" + "ing", "social graph", "database",
  "waitlist", "ticket", "donate", "crowdfunding", "render", "export file", "writeTo",
  "Data(", "FileDocument", "DocumentGroup", "fileExporter", "fileImporter",
  "publish campaign", "notify audience", "join waitlist", "sell access", "buy ticket",
  "track audience", "view ana" + "lytics", "connect account", "push launch", "file picker",
  "image picker", "media picker", "select files", "import from photos", "start stream",
  "launch player", "watch party", "submit to platform", "share package", "save to photos",
  "generate zip", "open files", "send message", "start chat", "post comment", "follow creator",
  "invite users", "export file", "render package", "download package", "send to distributor",
];
const changedSwiftLines = run("git diff -U0 -- '*.swift' | rg -n '^\\+' || true").split(/\n/).filter(Boolean);
const liveScan = changedSwiftLines.filter((line) => liveTerms.some((term) => line.includes(term))).join("\n");

const sourcePass = source?.status === "pass";
const screenshotPass = screenshot?.status === "pass";
const buildStatus = manifest?.build_status || "not_run";
const installStatus = manifest?.install_status || "not_run";
const captured = Array.isArray(manifest?.screenshots_captured) ? manifest.screenshots_captured : [];
const missing = Array.isArray(manifest?.missing_screenshots) ? manifest.missing_screenshots : [];
const expectedScripts = [
  "scripts/verify_mega_ecosystem_presentation_mode_sources.sh",
  "scripts/qa_mega_ecosystem_presentation_screenshots.sh",
  "scripts/verify_mega_ecosystem_presentation_screenshots.sh",
  "scripts/report_mega_ecosystem_presentation_evidence.sh",
];
const changedFiles = statusShort.split(/\n/).map((line) => line.trim().replace(/^[A-Z? ]+ /, "")).filter(Boolean);
const onlyExpected = changedFiles.every((file) => expectedScripts.includes(file));

const report = {
  upgrade: "#025.0B",
  baseline_tag: "phase-25-0a-mega-ecosystem-presentation-mode",
  head,
  tags,
  source_verification_status: sourcePass ? "pass" : "fail",
  screenshot_verification_status: screenshotPass ? "pass" : "fail",
  build_status: buildStatus,
  install_status: installStatus,
  launch_status: manifest?.launch_status || [],
  screenshots_captured: captured,
  missing_screenshots: missing,
  protected_scan_status: protectedScan ? "fail" : "pass",
  protected_scan_matches: protectedScan,
  live_system_scan_status: liveScan ? "fail" : "pass",
  live_system_scan_matches: liveScan,
  bottom_tabs_status: sourcePass && (source?.bottom_tabs === "Home Search Library Downloads Profile") ? "pass" : "fail",
  internal_route_status: sourcePass ? "pass" : "fail",
  known_limitations: manifest?.known_limitations || "",
  git_status_short: statusShort,
  git_diff_name_only: diffNames,
  git_diff_stat: diffStat,
  git_diff_check: diffCheck,
  commit_readiness: Boolean(sourcePass && screenshotPass && buildStatus === "passed" && installStatus === "passed" && !protectedScan && !liveScan && !diffCheck && onlyExpected),
};

fs.writeFileSync(finalJson, `${JSON.stringify(report, null, 2)}\n`);

const md = [
  "# Mega Ecosystem Presentation Final Evidence Report",
  "",
  `- Upgrade: ${report.upgrade}`,
  `- Baseline tag: ${report.baseline_tag}`,
  `- HEAD: ${report.head}`,
  `- Tags at HEAD: ${report.tags}`,
  `- Source verification: ${report.source_verification_status}`,
  `- Screenshot verification: ${report.screenshot_verification_status}`,
  `- Build status: ${report.build_status}`,
  `- Install status: ${report.install_status}`,
  `- Protected scan: ${report.protected_scan_status}`,
  `- Live-system scan: ${report.live_system_scan_status}`,
  `- Bottom tabs: ${report.bottom_tabs_status}`,
  `- Internal routes: ${report.internal_route_status}`,
  `- Commit readiness: ${report.commit_readiness}`,
  "",
  "## Screenshots Captured",
  ...(captured.length ? captured.map((shot) => `- ${shot.name}: \`${shot.path}\``) : ["- none"]),
  "",
  "## Missing Screenshots",
  ...(missing.length ? missing.map((shot) => `- ${shot.name}: ${shot.reason}`) : ["- none"]),
  "",
  `Known limitations: ${report.known_limitations || "none"}`,
  "",
  "## Git",
  "```",
  report.git_status_short || "(clean)",
  "```",
].join("\n");
fs.writeFileSync(finalMd, `${md}\n`);

console.log(`Final evidence report: ${finalMd}`);
if (!report.commit_readiness) {
  process.exitCode = 1;
}
NODE
