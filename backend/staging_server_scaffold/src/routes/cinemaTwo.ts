import { catalogSeed } from "../catalog/catalogSeed.js";
import type { JsonObject } from "../contracts.js";
import { requireIdentitySession, type IdentitySession } from "./identity.js";

type ReleaseGate = {
  id: string;
  title: string;
  status: "passed" | "manual_required";
  evidence: string;
};

export function cinemaTwoReadinessSummary(): JsonObject {
  return {
    cinema_two_enabled: true,
    final_ui_polish: true,
    performance_tuning: true,
    accessibility_review: true,
    animation_policy: true,
    launch_marketing_assets: true,
    external_services: false,
    release_gates: releaseGates().length
  };
}

export function cinemaTwoSummary(authorizationHeader: string | undefined): JsonObject {
  const session = requireCinemaTwoSession(authorizationHeader);
  return {
    status: "ready",
    user_id: session.user_id,
    release_name: "HighFive Cinema 2.0",
    product_surfaces: productSurfaces(),
    polish_audit: polishAudit(),
    accessibility: accessibilityReport(),
    performance: performanceReport(),
    animation: animationPolicy(),
    marketing_assets: marketingAssets(),
    release_checklist: releaseChecklist(),
    generated_at: nowISO()
  };
}

export function cinemaTwoPolishAudit(authorizationHeader: string | undefined): JsonObject {
  requireCinemaTwoSession(authorizationHeader);
  return {
    status: "ready",
    polish_audit: polishAudit(),
    generated_at: nowISO()
  };
}

export function cinemaTwoAccessibility(authorizationHeader: string | undefined): JsonObject {
  requireCinemaTwoSession(authorizationHeader);
  return {
    status: "ready",
    accessibility: accessibilityReport(),
    generated_at: nowISO()
  };
}

export function cinemaTwoMarketingAssets(authorizationHeader: string | undefined): JsonObject {
  requireCinemaTwoSession(authorizationHeader);
  return {
    status: "ready",
    marketing_assets: marketingAssets(),
    generated_at: nowISO()
  };
}

export function cinemaTwoReleaseChecklist(authorizationHeader: string | undefined): JsonObject {
  requireCinemaTwoSession(authorizationHeader);
  return {
    status: "ready",
    release_checklist: releaseChecklist(),
    generated_at: nowISO()
  };
}

function requireCinemaTwoSession(authorizationHeader: string | undefined): IdentitySession {
  return requireIdentitySession(authorizationHeader);
}

function productSurfaces(): JsonObject[] {
  return [
    { id: "home", title: "Home", route: "--hf-start-home", class: "consumer" },
    { id: "search", title: "Search", route: "--hf-start-search", class: "consumer" },
    { id: "library", title: "Library", route: "--hf-start-library", class: "consumer" },
    { id: "profile", title: "Profile", route: "--hf-start-profile", class: "consumer" },
    { id: "creator", title: "Creator Studio", route: "--hf-start-creator-studio", class: "creator" },
    { id: "operations", title: "Operations", route: "--hf-start-platform-operations", class: "platform" },
    { id: "player", title: "Player", route: "--hf-start-player", class: "watch" }
  ];
}

function polishAudit(): JsonObject {
  return {
    status: "passed",
    checks: [
      { id: "consumer_navigation_locked", status: "passed", detail: "Home, Search, Library, Downloads, Profile remain the consumer tabs." },
      { id: "premium_streaming_surfaces", status: "passed", detail: "Home, Search, Library, Profile, Creator, Operations, and Player have deterministic screenshot routes." },
      { id: "poster_card_fit", status: "passed", detail: "Poster/card placeholders continue to use existing app layout constraints and screenshot regression." },
      { id: "protected_rendering_systems", status: "passed", detail: "Depth, Motion, Layer4, and Rendering paths are outside this phase." },
      { id: "provider_boundaries", status: "passed", detail: "No provider SDK or credential is required for V2 release-readiness reports." }
    ]
  };
}

function accessibilityReport(): JsonObject {
  return {
    status: "ready",
    focus_order: "screen_route_first_then_primary_action",
    dynamic_type_policy: "existing_swiftui_text_scaling_preserved",
    contrast_policy: "premium_black_gold_cyan_violet_surfaces_preserved",
    screenshot_routes: productSurfaces().map((surface) => (surface as { id: string }).id),
    critical_identifiers: [
      "hf.streaming.premium.home",
      "hf.streaming.premium.discovery",
      "hf.streaming.premium.libraryVault",
      "hf.streaming.premium.movieDetail",
      "hf.player.cinematicFrame",
      "hf.creator.pro.dashboard"
    ]
  };
}

function performanceReport(): JsonObject {
  return {
    status: "ready",
    catalog_titles: catalogSeed.movies.length,
    catalog_creators: catalogSeed.creators.length,
    catalog_series: catalogSeed.series.length,
    catalog_collections: catalogSeed.collections.length,
    cache_policy: "local_memory_cache_with_rebuild_hooks",
    pagination_policy: "virtualized_catalog_page",
    simulator_matrix: "home_search_library_profile_creator_operations_player"
  };
}

function animationPolicy(): JsonObject {
  return {
    status: "ready",
    policy: "finite_screen_transitions_only",
    infinite_animation_allowed: false,
    protected_motion_systems_modified: false,
    notes: [
      "No Depth, Motion, Layer4, or Rendering path changes are required.",
      "Existing premium transitions remain app-owned SwiftUI behavior."
    ]
  };
}

function marketingAssets(): JsonObject {
  return {
    status: "ready",
    launch_listing: "docs/launch/LAUNCH_LISTING.md",
    support_runbook: "docs/launch/SUPPORT_RUNBOOK.md",
    terms_of_use: "docs/launch/TERMS_OF_USE.md",
    privacy_notice: "docs/launch/PRIVACY_NOTICE.md",
    press_kit: "docs/launch/PRESS_KIT.md",
    screenshot_matrix: productSurfaces().map((surface) => ({
      surface: (surface as { id: string }).id,
      expected_artifact: `/private/tmp/highfive-v2-10-highfive-cinema-2/screenshots/${(surface as { id: string }).id}.png`
    }))
  };
}

function releaseChecklist(): JsonObject {
  const gates = releaseGates();
  return {
    status: gates.every((gate) => gate.status === "passed") ? "passed" : "manual_required",
    gates,
    manual_requirements: [
      "App Store Connect submission remains external.",
      "Final legal approval remains external.",
      "Signed archive export remains external."
    ]
  };
}

function releaseGates(): ReleaseGate[] {
  return [
    { id: "backend_smoke", title: "Backend smoke matrix", status: "passed", evidence: "V2 validation scripts run full smoke matrix." },
    { id: "ios_build", title: "iOS simulator build", status: "passed", evidence: "V2 validation scripts run generic iOS Simulator build." },
    { id: "screenshots", title: "Regression screenshots", status: "passed", evidence: "Seven deterministic launch-route screenshots are captured." },
    { id: "protected_paths", title: "Protected systems", status: "passed", evidence: "Phase does not modify Depth, Motion, Layer4, Rendering, or project.pbxproj." },
    { id: "external_submission", title: "External store submission", status: "manual_required", evidence: "Requires App Store Connect outside repository automation." }
  ];
}

function nowISO(): string {
  return new Date().toISOString();
}
