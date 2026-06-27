import { catalogSeed } from "../catalog/catalogSeed.js";
import type { JsonObject } from "../contracts.js";
import { ContractError } from "../errors.js";
import { aiDiscoveryReadinessSummary } from "./aiDiscovery.js";
import { v3AIOperationsReadinessSummary } from "./v3AIOperations.js";
import { v3EnterpriseStudiosReadinessSummary } from "./v3EnterpriseStudios.js";
import { v3GlobalDistributionReadinessSummary } from "./v3GlobalDistribution.js";
import { v3MarketplaceReadinessSummary } from "./v3Marketplace.js";
import { v3PersonalizationReadinessSummary } from "./v3Personalization.js";
import { v3SearchReadinessSummary } from "./v3Search.js";
import { requireIdentitySession, type IdentitySession } from "./identity.js";

type EnterpriseSignal = "global_creator" | "enterprise_studio" | "ai_streaming" | "launch";
type EnterpriseState = "ready" | "review";

type GlobalCreatorPlatformRecord = {
  id: string;
  creator_id: string;
  creator_name: string;
  title_count: number;
  territories: string[];
  marketplace_channels: string[];
  localization_state: EnterpriseState;
  distribution_state: EnterpriseState;
  created_at: string;
  updated_at: string;
};

type EnterpriseStudioPlatformRecord = {
  id: string;
  organization_id: string;
  organization_name: string;
  workspace_count: number;
  departments: string[];
  permission_model: "role_based";
  shared_library_state: EnterpriseState;
  operations_state: EnterpriseState;
  created_at: string;
  updated_at: string;
};

type AIStreamingPlatformRecord = {
  id: string;
  title_id: string;
  title: string;
  personalization_state: EnterpriseState;
  search_state: EnterpriseState;
  operations_state: EnterpriseState;
  external_ai_calls: false;
  quality_score: number;
  created_at: string;
  updated_at: string;
};

type EnterpriseLaunchReadinessRecord = {
  id: string;
  signal: EnterpriseSignal;
  gate: string;
  state: EnterpriseState;
  score: number;
  blocker_count: number;
  recommendation: string;
  created_at: string;
  updated_at: string;
};

const globalCreatorRecords: GlobalCreatorPlatformRecord[] = [];
const studioPlatformRecords: EnterpriseStudioPlatformRecord[] = [];
const aiStreamingRecords: AIStreamingPlatformRecord[] = [];
const launchReadinessRecords: EnterpriseLaunchReadinessRecord[] = [];

let globalCreatorCounter = 1;
let studioPlatformCounter = 1;
let aiStreamingCounter = 1;
let readinessCounter = 1;

seedHighFiveEnterprise();

export function v3HighFiveEnterpriseReadinessSummary(): JsonObject {
  const aiOperations = v3AIOperationsReadinessSummary();
  const enterpriseStudios = v3EnterpriseStudiosReadinessSummary();
  const marketplace = v3MarketplaceReadinessSummary();
  const globalDistribution = v3GlobalDistributionReadinessSummary();
  const personalization = v3PersonalizationReadinessSummary();
  const search = v3SearchReadinessSummary();
  return {
    v3_highfive_enterprise_enabled: true,
    global_creator_platform: true,
    enterprise_studio_platform: true,
    ai_powered_streaming_platform: true,
    enterprise_launch_readiness: true,
    external_ai_calls: false,
    external_enterprise_services: false,
    global_creator_records: globalCreatorRecords.length,
    studio_platform_records: studioPlatformRecords.length,
    ai_streaming_records: aiStreamingRecords.length,
    launch_readiness_records: launchReadinessRecords.length,
    upstream_enterprise_studios_enabled: Boolean(enterpriseStudios.v3_enterprise_studios_enabled),
    upstream_marketplace_enabled: Boolean(marketplace.v3_marketplace_enabled),
    upstream_global_distribution_enabled: Boolean(globalDistribution.v3_global_distribution_enabled),
    upstream_personalization_enabled: Boolean(personalization.v3_personalization_enabled),
    upstream_search_enabled: Boolean(search.v3_ai_search_enabled),
    upstream_ai_operations_enabled: Boolean(aiOperations.v3_ai_operations_enabled)
  };
}

export function v3HighFiveEnterpriseSummary(authorizationHeader: string | undefined): JsonObject {
  const session = requireEnterpriseAdminSession(authorizationHeader);
  return {
    status: "ready",
    highfive_enterprise: "local_v3_highfive_enterprise",
    user_id: session.user_id,
    external_services: false,
    external_ai_calls: false,
    global_creator_platform: globalCreatorRecords,
    enterprise_studio_platform: studioPlatformRecords,
    ai_powered_streaming_platform: aiStreamingRecords,
    launch_readiness: launchReadinessRecords,
    dashboard: enterpriseDashboard(),
    readiness: v3HighFiveEnterpriseReadinessSummary(),
    generated_at: nowISO()
  };
}

export function createGlobalCreatorPlatformRecord(authorizationHeader: string | undefined, body: unknown): JsonObject {
  requireEnterpriseAdminSession(authorizationHeader);
  const creator = creatorForBody(body);
  const record: GlobalCreatorPlatformRecord = {
    id: `highfive-enterprise-global-creator-${globalCreatorCounter++}`,
    creator_id: creator.id,
    creator_name: creator.name,
    title_count: positiveInteger(body, "title_count", titlesForCreator(creator.id).length || 1),
    territories: stringArray(body, "territories", ["US", "CA", "GB"]),
    marketplace_channels: stringArray(body, "marketplace_channels", ["license_marketplace", "distribution_marketplace"]),
    localization_state: enterpriseState(optionalString(body, "localization_state")),
    distribution_state: enterpriseState(optionalString(body, "distribution_state")),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  globalCreatorRecords.push(record);
  return { status: "created", global_creator_platform: record };
}

export function createEnterpriseStudioPlatformRecord(authorizationHeader: string | undefined, body: unknown): JsonObject {
  requireEnterpriseAdminSession(authorizationHeader);
  const record: EnterpriseStudioPlatformRecord = {
    id: `highfive-enterprise-studio-platform-${studioPlatformCounter++}`,
    organization_id: trimmed(optionalString(body, "organization_id") ?? "enterprise-organization-seed-1", 120),
    organization_name: trimmed(optionalString(body, "organization_name") ?? "HighFive Enterprise Studio", 160),
    workspace_count: positiveInteger(body, "workspace_count", 4),
    departments: stringArray(body, "departments", ["production", "distribution", "analytics", "operations"]),
    permission_model: "role_based",
    shared_library_state: enterpriseState(optionalString(body, "shared_library_state")),
    operations_state: enterpriseState(optionalString(body, "operations_state")),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  studioPlatformRecords.push(record);
  return { status: "created", enterprise_studio_platform: record };
}

export function createAIStreamingPlatformRecord(authorizationHeader: string | undefined, body: unknown): JsonObject {
  requireEnterpriseAdminSession(authorizationHeader);
  const movie = movieForBody(body);
  const score = boundedScore(body, "quality_score", 94);
  const record: AIStreamingPlatformRecord = {
    id: `highfive-enterprise-ai-streaming-${aiStreamingCounter++}`,
    title_id: movie.id,
    title: movie.title,
    personalization_state: enterpriseState(optionalString(body, "personalization_state")),
    search_state: enterpriseState(optionalString(body, "search_state")),
    operations_state: enterpriseState(optionalString(body, "operations_state")),
    external_ai_calls: false,
    quality_score: score,
    created_at: nowISO(),
    updated_at: nowISO()
  };
  aiStreamingRecords.push(record);
  return { status: "created", ai_powered_streaming_platform: record };
}

export function createEnterpriseLaunchReadinessRecord(authorizationHeader: string | undefined, body: unknown): JsonObject {
  requireEnterpriseAdminSession(authorizationHeader);
  const record: EnterpriseLaunchReadinessRecord = {
    id: `highfive-enterprise-launch-readiness-${readinessCounter++}`,
    signal: enterpriseSignal(optionalString(body, "signal")),
    gate: trimmed(optionalString(body, "gate") ?? "Enterprise launch gate", 160),
    state: enterpriseState(optionalString(body, "state")),
    score: boundedScore(body, "score", 91),
    blocker_count: positiveInteger(body, "blocker_count", 0),
    recommendation: trimmed(optionalString(body, "recommendation") ?? "Continue enterprise release validation with local deterministic checks.", 240),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  launchReadinessRecords.push(record);
  return { status: "created", launch_readiness: record };
}

function seedHighFiveEnterprise(): void {
  if (globalCreatorRecords.length > 0) return;
  globalCreatorRecords.push({
    id: "highfive-enterprise-global-creator-seed-1",
    creator_id: "maya-hart",
    creator_name: "Maya Hart",
    title_count: titlesForCreator("maya-hart").length || 2,
    territories: ["US", "CA", "GB"],
    marketplace_channels: ["license_marketplace", "distribution_marketplace"],
    localization_state: "ready",
    distribution_state: "ready",
    created_at: nowISO(),
    updated_at: nowISO()
  });
  studioPlatformRecords.push({
    id: "highfive-enterprise-studio-platform-seed-1",
    organization_id: "enterprise-organization-seed-1",
    organization_name: "HighFive Enterprise Studio",
    workspace_count: 4,
    departments: ["production", "distribution", "analytics", "operations"],
    permission_model: "role_based",
    shared_library_state: "ready",
    operations_state: "ready",
    created_at: nowISO(),
    updated_at: nowISO()
  });
  aiStreamingRecords.push({
    id: "highfive-enterprise-ai-streaming-seed-1",
    title_id: "friendly",
    title: "The Friendly",
    personalization_state: "ready",
    search_state: "ready",
    operations_state: "ready",
    external_ai_calls: false,
    quality_score: 94,
    created_at: nowISO(),
    updated_at: nowISO()
  });
  launchReadinessRecords.push(
    {
      id: "highfive-enterprise-launch-readiness-seed-creator",
      signal: "global_creator",
      gate: "Global creator platform",
      state: "ready",
      score: 92,
      blocker_count: 0,
      recommendation: "Creator, marketplace, and distribution surfaces are aligned for enterprise review.",
      created_at: nowISO(),
      updated_at: nowISO()
    },
    {
      id: "highfive-enterprise-launch-readiness-seed-streaming",
      signal: "ai_streaming",
      gate: "AI-powered streaming platform",
      state: "ready",
      score: 94,
      blocker_count: 0,
      recommendation: "Personalization, search, and operations checks are available without external AI calls.",
      created_at: nowISO(),
      updated_at: nowISO()
    }
  );
}

function requireEnterpriseAdminSession(authorizationHeader: string | undefined): IdentitySession {
  const session = requireIdentitySession(authorizationHeader);
  if (session.role !== "admin") {
    throw new ContractError("highfive_enterprise_admin_required", "HighFive Enterprise requires an admin session.", 403);
  }
  return session;
}

function enterpriseDashboard(): JsonObject {
  const gates = launchReadinessRecords;
  const totalScore = gates.reduce((total, record) => total + record.score, 0);
  return {
    platform_status: gates.every((record) => record.state === "ready" && record.blocker_count === 0) ? "enterprise_ready" : "review_required",
    global_creator_platforms: globalCreatorRecords.length,
    enterprise_studio_platforms: studioPlatformRecords.length,
    ai_streaming_platforms: aiStreamingRecords.length,
    readiness_gates: gates.length,
    average_readiness_score: gates.length > 0 ? round(totalScore / gates.length) : 0,
    blocker_count: gates.reduce((total, record) => total + record.blocker_count, 0),
    deterministic_local_intelligence: true,
    external_ai_calls: false,
    external_enterprise_services: false
  };
}

function creatorForBody(body: unknown): { id: string; name: string } {
  const requested = optionalString(body, "creator_id");
  return catalogSeed.creators.find((creator) => creator.id === requested)
    ?? catalogSeed.creators[0]
    ?? { id: "local-creator", name: "Local Creator" };
}

function movieForBody(body: unknown): { id: string; title: string } {
  const requested = optionalString(body, "title_id") ?? optionalString(body, "content_id");
  return catalogSeed.movies.find((movie) => movie.id === requested)
    ?? catalogSeed.movies[0]
    ?? { id: "local-title", title: "Local Title" };
}

function titlesForCreator(creatorID: string): Array<{ id: string }> {
  return catalogSeed.movies.filter((movie) => movie.creator_id === creatorID);
}

function optionalString(body: unknown, key: string): string | null {
  if (!isRecord(body)) return null;
  const value = body[key];
  return typeof value === "string" && value.trim().length > 0 ? value.trim() : null;
}

function stringArray(body: unknown, key: string, fallback: string[]): string[] {
  if (!isRecord(body) || !Array.isArray(body[key])) return fallback;
  const result = body[key]
    .filter((value): value is string => typeof value === "string")
    .map((value) => value.trim())
    .filter((value) => value.length > 0)
    .slice(0, 12);
  return result.length > 0 ? result : fallback;
}

function enterpriseState(value: string | null): EnterpriseState {
  return value === "review" ? "review" : "ready";
}

function enterpriseSignal(value: string | null): EnterpriseSignal {
  if (value === "enterprise_studio" || value === "ai_streaming" || value === "launch") return value;
  return "global_creator";
}

function positiveInteger(body: unknown, key: string, fallback: number): number {
  if (!isRecord(body)) return fallback;
  const value = body[key];
  if (typeof value !== "number" || !Number.isFinite(value)) return fallback;
  return Math.max(0, Math.round(value));
}

function boundedScore(body: unknown, key: string, fallback: number): number {
  if (!isRecord(body)) return fallback;
  const value = body[key];
  if (typeof value !== "number" || !Number.isFinite(value)) return fallback;
  return Math.max(0, Math.min(100, Math.round(value)));
}

function trimmed(value: string, maxLength: number): string {
  const clean = value.trim();
  return clean.length > maxLength ? clean.slice(0, maxLength) : clean;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

function round(value: number): number {
  return Math.round(value * 100) / 100;
}

function nowISO(): string {
  return new Date().toISOString();
}
