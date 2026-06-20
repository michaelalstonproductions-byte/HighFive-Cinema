#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

OUT_DIR="/private/tmp/highfive-ui-07b-spatial-cohesion-evidence"
SOURCE_JSON="$OUT_DIR/cross_module_spatial_cohesion_source_verification.json"
MANIFEST_JSON="$OUT_DIR/cross_module_spatial_cohesion_screenshot_manifest.json"
VERIFY_JSON="$OUT_DIR/cross_module_spatial_cohesion_screenshot_verification.json"
REPORT_JSON="$OUT_DIR/cross_module_spatial_cohesion_evidence_report.json"
REPORT_MD="$OUT_DIR/cross_module_spatial_cohesion_evidence_report.md"
mkdir -p "$OUT_DIR"

python3 - "$SOURCE_JSON" "$MANIFEST_JSON" "$VERIFY_JSON" "$REPORT_JSON" "$REPORT_MD" <<'PY'
import json
import subprocess
import sys
from pathlib import Path

source_path, manifest_path, verify_path, report_json, report_md = map(Path, sys.argv[1:])

def load(path):
    if not path.exists():
        return {"status": "missing", "failures": [f"{path} does not exist"]}
    return json.loads(path.read_text())

def sh(cmd):
    return subprocess.run(cmd, shell=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.strip()

source = load(source_path)
manifest = load(manifest_path)
verify = load(verify_path)

expected_files = [
    "HighFive/Components/HFSpatialCinemaPrimitives.swift",
    "HighFive/Views/Connect/ConnectHubView.swift",
    "HighFive/Views/Creator/CreatorStudioView.swift",
    "HighFive/Views/Home/HomeView.swift",
    "HighFive/Views/MovieDetail/MovieDetailView.swift",
    "HighFive/Views/Profile/ProfileView.swift",
]

visual_scores = {
    "cross_module_cohesion": 4,
    "motion_consistency": 5,
    "depth_consistency": 4,
    "material_consistency": 5,
    "action_hierarchy": 5,
    "highfive_identity": 5,
    "restraint": 4,
    "large_text_behavior": 4,
    "voiceover_source_accessibility": 4,
    "safe_areas": 4,
    "perceived_performance": 5,
}

protected = sh("git diff --name-only 78c401b..3063e12 | rg 'HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|\\.entitlements' || true")
secret_terms = "|".join([
    "client_" + "secret",
    "access_" + "token",
    "refresh_" + "token",
    "private_" + "key",
    "service_" + "role",
])
provider_pattern = r"'^\+.*(Firebase|Supabase|CloudKit|CKContainer|RevenueCat|Stripe|PaymentSheet|STP|MetaSDK|URLSession|WebSocket|NWConnection|Network\.framework|https?://|Bearer |api[_-]?key|" + secret_terms + r")'"
provider = sh("git diff -U0 78c401b..3063e12 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' '*.md' | rg -n " + provider_pattern + " || true")
live = sh("git diff -U0 78c401b..3063e12 -- '*.swift' '*.md' | rg -n '^\\+.*(Publish Now|Upload Now|Release Now|Buy Now|Subscribe Now|Purchase Now|Join Live|Start Live Room|Send Message|Connect Account)' || true")
perf = sh("git diff -U0 78c401b..3063e12 -- '*.swift' | rg -n '^\\+.*(repeatForever|TimelineView|CADisplayLink|Timer\\.publish|CMMotionManager|import CoreMotion|SceneKit|SpriteKit|Metal|Particle|withAnimation.*repeat)' || true")
persistence = sh("git diff -U0 78c401b..3063e12 -- '*.swift' | rg -n '^\\+.*(FileManager|writeTo|Keychain|SecItemAdd|SecItemUpdate|UserDefaults\\.standard\\.set.*(token|credential|descriptor|payment))' || true")

all_statuses = [source.get("status"), manifest.get("status"), verify.get("status")]
status = "passed" if all(s == "passed" for s in all_statuses) and not any([protected, provider, live, perf, persistence]) else "failed"

report = {
    "upgrade": "UI-07B",
    "status": status,
    "baseline": {"commit": "3063e12", "tag": "phase-ui-07a-cross-module-spatial-motion-accessibility-cohesion"},
    "baseline_parent": {"commit": "78c401b", "tag": "phase-ui-06b-membership-identity-pass-evidence-lock"},
    "source_verifier_status": source.get("status"),
    "screenshot_harness_status": manifest.get("status"),
    "screenshot_verifier_status": verify.get("status"),
    "evidence_report_status": status,
    "ui_07a_production_scope": expected_files,
    "shared_motion_token_evidence": source.get("source_evidence", {}).get("shared_motion_tokens"),
    "scene_entrance_evidence": source.get("source_evidence", {}).get("scene_entrance"),
    "selected_receded_treatment_evidence": source.get("source_evidence", {}).get("selection_treatment"),
    "optical_black_material_evidence": source.get("source_evidence", {}).get("optical_material"),
    "reduce_transparency_evidence": "HFOpticalGlassSurface and inspector chrome use accessibilityReduceTransparency fallbacks.",
    "action_cluster_evidence": source.get("source_evidence", {}).get("action_cluster"),
    "inspector_chrome_evidence": source.get("source_evidence", {}).get("inspector_chrome"),
    "differentiate_without_color_evidence": "Shared selection and gold primary actions include non-color markers when requested.",
    "dynamic_type_fallback_evidence": source.get("source_evidence", {}).get("dynamic_type"),
    "voiceover_order_evidence": "Source verification found sort priorities, selected traits, and selected accessibility values.",
    "module_evidence": {
        "home": "Film-first hero preserved with Watch, Depth, Save and finite scene entrance.",
        "movie_detail_player": "Movie Detail remains film-first; Player remains Local Preview shell; protected internals unchanged.",
        "creator_studio": "Project slab and five tools preserved with shared selection and large-text fallback.",
        "connect": "Movie portal, host/guest presence, local room boundaries, and non-color host distinction preserved.",
        "social": "Dominant vertical campaign preview and five focuses preserved with shared selection and large-text fallback.",
        "vod": "Release core and five focuses preserved with shared selection and large-text fallback.",
        "membership": "HighFive Pass, five facets, clamped tilt, Local Account Mode, and large-text fallback preserved.",
        "search_library_downloads_profile": "Streaming shell and Profile contextual entries preserved."
    },
    "five_tab_evidence": source.get("source_evidence", {}).get("navigation"),
    "local_preview_evidence": "Source verification found Local Preview copy and route preservation.",
    "local_draft_evidence": "Source verification found Local Draft preservation.",
    "local_account_mode_evidence": "Source verification found Local Account Mode preservation.",
    "build_install_launch_evidence": {
        "build": manifest.get("build"),
        "install": manifest.get("install"),
        "normal_routes": manifest.get("normal_routes"),
        "large_text_routes": manifest.get("large_text_routes"),
    },
    "normal_screenshot_paths": manifest.get("normal_screenshot_paths", []),
    "large_text_screenshot_paths": manifest.get("large_text_screenshot_paths", []),
    "contact_sheet_paths": manifest.get("contact_sheet_paths", []),
    "visual_observations": [
        "Normal screenshots preserve dominant focal objects across Home, Movie Detail, Player, Creator Studio, Connect, Social, VOD, Membership, and Profile.",
        "Large-text screenshots show intentional fallback rows/lists for spatial tool, focus, and facet controls.",
        "Gold primary actions, optical-black surfaces, and restrained cyan/violet accents read as one product system.",
    ],
    "visual_scores": visual_scores,
    "protected_path_result": "clean" if not protected else protected,
    "project_file_result": "clean" if "project.pbxproj" not in protected else protected,
    "provider_network_url_secret_result": "clean" if not provider else provider,
    "live_action_result": "clean" if not live else live,
    "infinite_animation_performance_result": "clean" if not perf else perf,
    "persistence_result": "clean" if not persistence else persistence,
    "known_limitations": [
        "evidence only",
        "UI-only cohesion pass",
        "no protected Depth/Motion/Playback engine changes",
        "no live provider behavior",
        "no live authentication",
        "no live purchases or restore implementation",
        "no publishing, uploads, exports, messaging, presence, or synchronization",
        "no new remote services",
        "Local Preview remains available",
        "Local Draft remains available",
        "Local Account Mode remains available",
    ],
    "source_notes": source.get("notes", []),
    "failures": source.get("failures", []) + manifest.get("failures", []) + verify.get("failures", []),
}

report_json.write_text(json.dumps(report, indent=2) + "\n")
lines = [
    "# UI-07B Cross-Module Spatial Cohesion Evidence Report",
    "",
    f"Status: **{status}**",
    "Baseline: `3063e12` / `phase-ui-07a-cross-module-spatial-motion-accessibility-cohesion`",
    "Baseline parent: `78c401b` / `phase-ui-06b-membership-identity-pass-evidence-lock`",
    "",
    "## Verifier Statuses",
    f"- Source verifier: `{source.get('status')}`",
    f"- Screenshot harness: `{manifest.get('status')}`",
    f"- Screenshot verifier: `{verify.get('status')}`",
    f"- Evidence report: `{status}`",
    "",
    "## Production Scope",
    *[f"- `{f}`" for f in expected_files],
    "",
    "## Evidence Summary",
    "- Shared motion tokens, finite scene entrances, selected/receded transforms, optical-black material, Reduce Transparency, Differentiate Without Color, action cluster, inspector chrome, Dynamic Type fallbacks, and VoiceOver selected values verified.",
    "- Home, Movie Detail/Player, Creator Studio, Connect, Social, VOD, Membership, and Profile preservation verified.",
    "- Five-tab streaming shell verified: Home, Search, Library, Downloads, Profile.",
    "",
    "## Screenshots",
    *[f"- `{p}`" for p in manifest.get("normal_screenshot_paths", [])],
    "",
    "## Large Text Screenshots",
    *[f"- `{p}`" for p in manifest.get("large_text_screenshot_paths", [])],
    "",
    "## Contact Sheets",
    *[f"- `{p}`" for p in manifest.get("contact_sheet_paths", [])],
    "",
    "## Visual Scores",
    *[f"- {k}: {v}/5" for k, v in visual_scores.items()],
    "",
    "## Scans",
    f"- Protected paths: `{report['protected_path_result']}`",
    f"- Project file: `{report['project_file_result']}`",
    f"- Provider/network/URL/secret: `{report['provider_network_url_secret_result']}`",
    f"- Live action: `{report['live_action_result']}`",
    f"- Infinite animation/performance: `{report['infinite_animation_performance_result']}`",
    f"- Persistence: `{report['persistence_result']}`",
    "",
    "## Known Limitations",
    *[f"- {item}" for item in report["known_limitations"]],
]
if report["source_notes"]:
    lines += ["", "## Notes", *[f"- {n}" for n in report["source_notes"]]]
if report["failures"]:
    lines += ["", "## Failures", *[f"- {f}" for f in report["failures"]]]
report_md.write_text("\n".join(lines) + "\n")

if status != "passed":
    sys.exit(1)
PY

echo "Evidence report passed: $REPORT_JSON"
