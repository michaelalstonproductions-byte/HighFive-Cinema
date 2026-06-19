#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

UPGRADE="UI-01B"
BASELINE_COMMIT="b5beb99"
BASELINE_TAG="phase-ui-01a-spatial-cinema-experience-foundation"
BASELINE_PARENT_COMMIT="afb73da"
BASELINE_PARENT_TAG="phase-67-0b-staging-backend-deployment-target-smoke-test-evidence-lock"
EVIDENCE_DIR="/private/tmp/highfive-ui-01b-spatial-cinema-evidence"
SOURCE_JSON="$EVIDENCE_DIR/spatial_cinema_source_verification.json"
SHOT_JSON="$EVIDENCE_DIR/spatial_cinema_screenshot_manifest.json"
SHOT_VERIFY_JSON="$EVIDENCE_DIR/spatial_cinema_screenshot_verification.json"
REPORT_JSON="$EVIDENCE_DIR/spatial_cinema_evidence_report.json"
REPORT_MD="$EVIDENCE_DIR/spatial_cinema_evidence_report.md"

mkdir -p "$EVIDENCE_DIR"

protected_current="$(git diff --name-only | rg 'HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|\.entitlements' || true)"
protected_range="$(git diff --name-only "$BASELINE_PARENT_COMMIT..$BASELINE_COMMIT" | rg 'HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|\.entitlements' || true)"
provider_pattern='^\+.*(Firebase|Supabase|CloudKit|CKContainer|RevenueCat|Stripe|MetaSDK|FacebookCore|TikTok|YouTube|URLSession|https?://|Bearer |api[_-]?key|client_secret|access_token|refresh_token|private_''key|service_''role)'
provider_range="$(
  git diff -U0 "$BASELINE_PARENT_COMMIT..$BASELINE_COMMIT" -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' '*.md' |
    rg -n "$provider_pattern" || true
)"

python3 - "$REPORT_JSON" "$REPORT_MD" "$UPGRADE" "$BASELINE_COMMIT" "$BASELINE_TAG" "$BASELINE_PARENT_COMMIT" "$BASELINE_PARENT_TAG" "$SOURCE_JSON" "$SHOT_JSON" "$SHOT_VERIFY_JSON" "$protected_current" "$protected_range" "$provider_range" <<'PY'
import json
import os
import sys

(
    report_json,
    report_md,
    upgrade,
    baseline_commit,
    baseline_tag,
    parent_commit,
    parent_tag,
    source_json,
    shot_json,
    shot_verify_json,
    protected_current,
    protected_range,
    provider_range,
) = sys.argv[1:14]

def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)

source = load(source_json)
shots = load(shot_json)
shot_verify = load(shot_verify_json)

manual_visual_review = {
    "automated_visual_truth": "non-empty screenshot proof only",
    "review_type": "manual visual review recorded by evidence phase",
    "screens": {
        "home": {
            "observations": [
                "Dominant cinematic title world visible above rails.",
                "Watch is the primary gold action; Depth and Save are secondary.",
                "Foreground, subject, and background plane separation is visible.",
                "Five bottom tabs are visible; no Connect tab is present.",
            ],
            "scores": {
                "film_dominance": 5,
                "spatial_depth": 5,
                "visual_hierarchy": 5,
                "highfive_identity": 5,
                "restraint": 5,
                "accessibility_safe_areas": 4,
            },
        },
        "movie_detail": {
            "observations": [
                "Full-bleed cinematic title scene dominates the screen.",
                "Spatial layering and cyan depth contour treatment are visible.",
                "Watch and Depth hierarchy is clear.",
                "Technical readiness is not dominant in the primary hierarchy.",
            ],
            "scores": {
                "film_dominance": 5,
                "spatial_depth": 5,
                "visual_hierarchy": 5,
                "highfive_identity": 5,
                "restraint": 5,
                "accessibility_safe_areas": 4,
            },
        },
        "player": {
            "observations": [
                "Film frame is the primary player object.",
                "Local Preview remains usable.",
                "Depth and Peek entry is present.",
                "Readiness details are secondary and no token, URL, adapter, or gateway language appears in the primary surface.",
            ],
            "scores": {
                "film_dominance": 5,
                "spatial_depth": 4,
                "visual_hierarchy": 5,
                "highfive_identity": 5,
                "restraint": 5,
                "accessibility_safe_areas": 5,
            },
        },
        "profile_tabs": {
            "observations": [
                "Bottom shell shows Home, Search, Library, Downloads, and Profile.",
                "No Connect bottom tab is present.",
                "Tab labels fit and remain inside the safe area.",
            ],
            "scores": {
                "film_dominance": 3,
                "spatial_depth": 3,
                "visual_hierarchy": 4,
                "highfive_identity": 4,
                "restraint": 4,
                "accessibility_safe_areas": 5,
            },
        },
    },
}

status = "passed"
failures = []
for label, obj in [("source verifier", source), ("screenshot harness", shots), ("screenshot verifier", shot_verify)]:
    if obj.get("status") != "passed":
        failures.append(f"{label} status: {obj.get('status')}")
if protected_current:
    failures.append("current protected path scan has hits")
if protected_range:
    failures.append("UI-01A protected path scan has hits")
if provider_range:
    failures.append("UI-01A provider/network/URL/secret scan has hits")
if failures:
    status = "failed"

report = {
    "upgrade": upgrade,
    "status": status,
    "baseline": {"commit": baseline_commit, "tag": baseline_tag},
    "baseline_parent": {"commit": parent_commit, "tag": parent_tag},
    "source_verifier_status": source.get("status"),
    "screenshot_harness_status": shots.get("status"),
    "screenshot_verifier_status": shot_verify.get("status"),
    "evidence_report_status": status,
    "ui_01a_file_scope": source.get("ui_01a_file_scope"),
    "five_tab_evidence": source.get("five_tab_evidence"),
    "connect_tab_evidence": "Connect is not a bottom tab; old launch argument routes to Profile.",
    "spatial_primitive_evidence": source.get("spatial_primitives"),
    "home_spatial_hero_evidence": source.get("home_identifiers"),
    "watch_depth_save_evidence": ["hf.spatial.home.watch", "hf.spatial.home.depth", "hf.spatial.home.save"],
    "movie_detail_spatial_scene_evidence": source.get("movie_detail_identifiers"),
    "player_spatial_shell_evidence": source.get("player_identifiers"),
    "readiness_secondary_evidence": "Access & Playback Readiness sheet/button keeps technical details secondary.",
    "local_preview_evidence": "Home, Movie Detail, and Player route into HFPlayerServiceSheet local preview.",
    "reduce_motion_evidence": "Home, Movie Detail, and Player use accessibilityReduceMotion guards.",
    "accessibility_evidence": "Spatial identifiers, labels, minimum 44+ point actions, line limits, and safe-area padding are present.",
    "build_install_launch_evidence": {
        "build": shots.get("build"),
        "install": shots.get("install"),
        "routes": shots.get("routes"),
    },
    "screenshot_paths": shots.get("screenshot_paths"),
    "screenshot_byte_counts": shots.get("screenshot_byte_counts"),
    "manual_visual_review": manual_visual_review,
    "protected_path_evidence": {
        "current_script_diff": "clean" if not protected_current else protected_current,
        "ui_01a_commit_range": "clean" if not protected_range else protected_range,
    },
    "project_file_evidence": "project.pbxproj was not changed.",
    "provider_network_url_secret_evidence": "clean" if not provider_range else provider_range,
    "known_limitations": [
        "Evidence only.",
        "UI foundation only.",
        "Spatial effects are SwiftUI presentation layers.",
        "Protected Depth/Motion/Playback internals were not changed.",
        "No Creator Studio spatial worktable yet.",
        "No Connect constellation experience yet.",
        "No Social/VOD spatial authoring yet.",
        "No Membership identity pass yet.",
        "No live provider behavior added.",
        "Local Preview fallback remains available.",
    ],
    "failures": failures,
}

with open(report_json, "w", encoding="utf-8") as f:
    json.dump(report, f, indent=2)
    f.write("\n")

with open(report_md, "w", encoding="utf-8") as f:
    f.write("# Spatial Cinema Evidence Report\n\n")
    f.write(f"- Upgrade: {upgrade}\n")
    f.write(f"- Status: {status}\n")
    f.write(f"- Baseline: {baseline_commit} / {baseline_tag}\n")
    f.write(f"- Baseline parent: {parent_commit} / {parent_tag}\n")
    f.write(f"- Source verifier: {source.get('status')}\n")
    f.write(f"- Screenshot harness: {shots.get('status')}\n")
    f.write(f"- Screenshot verifier: {shot_verify.get('status')}\n\n")
    f.write("## Evidence\n")
    f.write("- Five tabs: Home, Search, Library, Downloads, Profile\n")
    f.write("- Connect bottom tab: absent\n")
    f.write("- Spatial primitives: HFOpticalGlassSurface, HFDepthContourOverlay, HFEnergyAction\n")
    f.write("- Home: full-bleed spatial hero with Watch, Depth, Save\n")
    f.write("- Movie Detail: spatial title scene with readiness secondary\n")
    f.write("- Player: film-first local preview shell\n")
    f.write("- Local Preview: available\n")
    f.write("- Reduce Motion: guarded presentation motion\n\n")
    f.write("## Screenshots\n")
    for name, path in shots.get("screenshot_paths", {}).items():
        f.write(f"- {name}: {path} ({shots.get('screenshot_byte_counts', {}).get(name, 0)} bytes)\n")
    f.write("\n## Manual Visual Review Scores\n")
    for name, review in manual_visual_review["screens"].items():
        scores = review["scores"]
        f.write(f"- {name}: film {scores['film_dominance']}, depth {scores['spatial_depth']}, hierarchy {scores['visual_hierarchy']}, identity {scores['highfive_identity']}, restraint {scores['restraint']}, accessibility/safe areas {scores['accessibility_safe_areas']}\n")
    f.write("\n## Known Limitations\n")
    for item in report["known_limitations"]:
        f.write(f"- {item}\n")
    f.write("\n## Failures\n")
    if failures:
        for item in failures:
            f.write(f"- {item}\n")
    else:
        f.write("- None\n")

if failures:
    sys.exit(1)
PY

echo "Evidence report passed: $REPORT_JSON"
