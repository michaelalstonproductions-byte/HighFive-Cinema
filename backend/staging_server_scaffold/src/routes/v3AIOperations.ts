import { catalogSeed } from "../catalog/catalogSeed.js";
import type { JsonObject } from "../contracts.js";
import { ContractError } from "../errors.js";
import { requireIdentitySession, type IdentitySession } from "./identity.js";

type OperationPriority = "low" | "medium" | "high";
type OperationStatus = "open" | "review" | "resolved";

type ModerationRecommendationRecord = {
  id: string;
  content_id: string;
  title: string;
  signal: "policy" | "metadata" | "audience" | "rights";
  priority: OperationPriority;
  recommendation: string;
  status: OperationStatus;
  created_at: string;
  updated_at: string;
};

type QualityControlRecord = {
  id: string;
  content_id: string;
  title: string;
  quality_area: "metadata" | "artwork" | "playback" | "subtitles";
  score: number;
  blocking: boolean;
  recommendation: string;
  created_at: string;
  updated_at: string;
};

type CatalogOptimizationRecord = {
  id: string;
  collection_id: string;
  recommendation_type: "rail_order" | "collection_depth" | "creator_balance" | "genre_gap";
  priority: OperationPriority;
  summary: string;
  expected_lift: number;
  created_at: string;
  updated_at: string;
};

type RightsValidationRecord = {
  id: string;
  content_id: string;
  title: string;
  territory: string;
  validation_state: "clear" | "review";
  issue_count: number;
  recommendation: string;
  created_at: string;
  updated_at: string;
};

type ReleaseOptimizationRecord = {
  id: string;
  content_id: string;
  title: string;
  release_window: string;
  optimization_type: "timing" | "audience" | "collection" | "premiere";
  confidence: number;
  recommendation: string;
  created_at: string;
  updated_at: string;
};

const moderationRecommendations: ModerationRecommendationRecord[] = [];
const qualityControlChecks: QualityControlRecord[] = [];
const catalogOptimizations: CatalogOptimizationRecord[] = [];
const rightsValidations: RightsValidationRecord[] = [];
const releaseOptimizations: ReleaseOptimizationRecord[] = [];

let moderationCounter = 1;
let qualityCounter = 1;
let catalogCounter = 1;
let rightsCounter = 1;
let releaseCounter = 1;

seedAIOperations();

export function v3AIOperationsReadinessSummary(): JsonObject {
  return {
    v3_ai_operations_enabled: true,
    automated_moderation: true,
    quality_control: true,
    catalog_optimization: true,
    rights_validation: true,
    release_optimization: true,
    external_ai_calls: false,
    moderation_records: moderationRecommendations.length,
    quality_records: qualityControlChecks.length,
    optimization_records: catalogOptimizations.length + rightsValidations.length + releaseOptimizations.length
  };
}

export function v3AIOperationsSummary(authorizationHeader: string | undefined): JsonObject {
  const session = requireAIOperationsSession(authorizationHeader);
  return {
    status: "ready",
    ai_operations: "local_v3_ai_operations",
    external_ai_calls: false,
    user_id: session.user_id,
    moderation_recommendations: moderationRecommendations,
    quality_control: qualityControlChecks,
    catalog_optimization: catalogOptimizations,
    rights_validation: rightsValidations,
    release_optimization: releaseOptimizations,
    dashboard: operationsDashboard(),
    generated_at: nowISO()
  };
}

export function createAIModerationRecommendation(authorizationHeader: string | undefined, body: unknown): JsonObject {
  requireAIOperationsSession(authorizationHeader);
  const movie = movieForBody(body);
  const record: ModerationRecommendationRecord = {
    id: `ai-operations-moderation-${moderationCounter++}`,
    content_id: movie.id,
    title: movie.title,
    signal: moderationSignal(optionalString(body, "signal")),
    priority: priority(optionalString(body, "priority")),
    recommendation: trimmed(optionalString(body, "recommendation") ?? "Review metadata and policy context before publication.", 220),
    status: operationStatus(optionalString(body, "status")),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  moderationRecommendations.push(record);
  return { status: "created", moderation_recommendation: record };
}

export function createAIQualityControl(authorizationHeader: string | undefined, body: unknown): JsonObject {
  requireAIOperationsSession(authorizationHeader);
  const movie = movieForBody(body);
  const score = scoreValue(body, "score", 88);
  const record: QualityControlRecord = {
    id: `ai-operations-quality-${qualityCounter++}`,
    content_id: movie.id,
    title: movie.title,
    quality_area: qualityArea(optionalString(body, "quality_area")),
    score,
    blocking: score < 70,
    recommendation: trimmed(optionalString(body, "recommendation") ?? "Improve local quality metadata before wide release.", 220),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  qualityControlChecks.push(record);
  return { status: "created", quality_control: record };
}

export function createAICatalogOptimization(authorizationHeader: string | undefined, body: unknown): JsonObject {
  requireAIOperationsSession(authorizationHeader);
  const collection = catalogSeed.collections.find((candidate) => candidate.id === optionalString(body, "collection_id")) ?? catalogSeed.collections[0];
  const record: CatalogOptimizationRecord = {
    id: `ai-operations-catalog-${catalogCounter++}`,
    collection_id: collection?.id ?? "featured",
    recommendation_type: catalogRecommendationType(optionalString(body, "recommendation_type")),
    priority: priority(optionalString(body, "priority")),
    summary: trimmed(optionalString(body, "summary") ?? "Rebalance local rails around creator performance and recent viewing.", 220),
    expected_lift: liftValue(body, "expected_lift", 1.12),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  catalogOptimizations.push(record);
  return { status: "created", catalog_optimization: record };
}

export function createAIRightsValidation(authorizationHeader: string | undefined, body: unknown): JsonObject {
  requireAIOperationsSession(authorizationHeader);
  const movie = movieForBody(body);
  const record: RightsValidationRecord = {
    id: `ai-operations-rights-${rightsCounter++}`,
    content_id: movie.id,
    title: movie.title,
    territory: trimmed(optionalString(body, "territory") ?? "US", 40),
    validation_state: rightsState(optionalString(body, "validation_state")),
    issue_count: issueCount(body, "issue_count", 0),
    recommendation: trimmed(optionalString(body, "recommendation") ?? "Validate territory and window metadata before publishing.", 220),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  rightsValidations.push(record);
  return { status: "created", rights_validation: record };
}

export function createAIReleaseOptimization(authorizationHeader: string | undefined, body: unknown): JsonObject {
  requireAIOperationsSession(authorizationHeader);
  const movie = movieForBody(body);
  const record: ReleaseOptimizationRecord = {
    id: `ai-operations-release-${releaseCounter++}`,
    content_id: movie.id,
    title: movie.title,
    release_window: trimmed(optionalString(body, "release_window") ?? "Weekend premiere window", 120),
    optimization_type: releaseOptimizationType(optionalString(body, "optimization_type")),
    confidence: scoreValue(body, "confidence", 91),
    recommendation: trimmed(optionalString(body, "recommendation") ?? "Pair premiere placement with creator-profile and collection rail promotion.", 240),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  releaseOptimizations.push(record);
  return { status: "created", release_optimization: record };
}

function seedAIOperations(): void {
  if (moderationRecommendations.length > 0) return;
  moderationRecommendations.push({
    id: "ai-operations-moderation-seed-1",
    content_id: "friendly",
    title: "The Friendly",
    signal: "metadata",
    priority: "medium",
    recommendation: "Review synopsis tone and rating alignment before global expansion.",
    status: "open",
    created_at: nowISO(),
    updated_at: nowISO()
  });
  qualityControlChecks.push({
    id: "ai-operations-quality-seed-1",
    content_id: "friendly",
    title: "The Friendly",
    quality_area: "metadata",
    score: 92,
    blocking: false,
    recommendation: "Metadata is release-ready; refresh collection copy during final review.",
    created_at: nowISO(),
    updated_at: nowISO()
  });
  catalogOptimizations.push({
    id: "ai-operations-catalog-seed-1",
    collection_id: catalogSeed.collections[0]?.id ?? "featured",
    recommendation_type: "rail_order",
    priority: "high",
    summary: "Move HighFive Originals ahead of general trending for returning creator-affinity viewers.",
    expected_lift: 1.18,
    created_at: nowISO(),
    updated_at: nowISO()
  });
  rightsValidations.push({
    id: "ai-operations-rights-seed-1",
    content_id: "friendly",
    title: "The Friendly",
    territory: "US",
    validation_state: "clear",
    issue_count: 0,
    recommendation: "Rights window is clear for local preview distribution.",
    created_at: nowISO(),
    updated_at: nowISO()
  });
  releaseOptimizations.push({
    id: "ai-operations-release-seed-1",
    content_id: "friendly",
    title: "The Friendly",
    release_window: "Friday premiere window",
    optimization_type: "premiere",
    confidence: 94,
    recommendation: "Launch with creator Q&A and premiere rail placement.",
    created_at: nowISO(),
    updated_at: nowISO()
  });
}

function requireAIOperationsSession(authorizationHeader: string | undefined): IdentitySession {
  const session = requireIdentitySession(authorizationHeader);
  if (session.role !== "admin") {
    throw new ContractError("ai_operations_role_required", "AI operations require an admin session", 403);
  }
  return session;
}

function operationsDashboard(): JsonObject {
  return {
    open_moderation_recommendations: moderationRecommendations.filter((record) => record.status !== "resolved").length,
    blocking_quality_checks: qualityControlChecks.filter((record) => record.blocking).length,
    high_priority_catalog_items: catalogOptimizations.filter((record) => record.priority === "high").length,
    rights_items_in_review: rightsValidations.filter((record) => record.validation_state === "review").length,
    release_optimizations: releaseOptimizations.length,
    deterministic_local_rules: true
  };
}

function movieForBody(body: unknown): { id: string; title: string } {
  return catalogSeed.movies.find((candidate) => candidate.id === optionalString(body, "content_id")) ?? catalogSeed.movies[0] ?? {
    id: "friendly",
    title: "The Friendly"
  };
}

function optionalString(body: unknown, key: string): string | null {
  if (!isRecord(body)) return null;
  return typeof body[key] === "string" && body[key].trim().length > 0 ? body[key].trim() : null;
}

function scoreValue(body: unknown, key: string, fallback: number): number {
  if (!isRecord(body) || typeof body[key] !== "number" || !Number.isFinite(body[key])) return fallback;
  return Math.max(0, Math.min(100, Math.round(body[key])));
}

function liftValue(body: unknown, key: string, fallback: number): number {
  if (!isRecord(body) || typeof body[key] !== "number" || !Number.isFinite(body[key])) return fallback;
  return Math.max(0, Math.round(body[key] * 100) / 100);
}

function issueCount(body: unknown, key: string, fallback: number): number {
  if (!isRecord(body) || typeof body[key] !== "number" || !Number.isFinite(body[key])) return fallback;
  return Math.max(0, Math.floor(body[key]));
}

function moderationSignal(value: string | null): ModerationRecommendationRecord["signal"] {
  if (value === "policy" || value === "audience" || value === "rights") return value;
  return "metadata";
}

function priority(value: string | null): OperationPriority {
  if (value === "low" || value === "high") return value;
  return "medium";
}

function operationStatus(value: string | null): OperationStatus {
  if (value === "review" || value === "resolved") return value;
  return "open";
}

function qualityArea(value: string | null): QualityControlRecord["quality_area"] {
  if (value === "artwork" || value === "playback" || value === "subtitles") return value;
  return "metadata";
}

function catalogRecommendationType(value: string | null): CatalogOptimizationRecord["recommendation_type"] {
  if (value === "collection_depth" || value === "creator_balance" || value === "genre_gap") return value;
  return "rail_order";
}

function rightsState(value: string | null): RightsValidationRecord["validation_state"] {
  return value === "review" ? "review" : "clear";
}

function releaseOptimizationType(value: string | null): ReleaseOptimizationRecord["optimization_type"] {
  if (value === "timing" || value === "audience" || value === "collection") return value;
  return "premiere";
}

function trimmed(value: string, limit: number): string {
  const clean = value.trim();
  return clean.length <= limit ? clean : clean.slice(0, limit).trim();
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function nowISO(): string {
  return new Date().toISOString();
}
