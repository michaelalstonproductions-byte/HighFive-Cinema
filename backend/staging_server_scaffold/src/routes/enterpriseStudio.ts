import { catalogSeed } from "../catalog/catalogSeed.js";
import type { JsonObject } from "../contracts.js";
import { ContractError } from "../errors.js";
import { recordAnalyticsEvent } from "./analytics.js";
import { requireIdentitySession, type IdentitySession } from "./identity.js";

type BulkPublishingStatus = "queued" | "validated" | "needs_review";

type BulkPublishingBatchRecord = {
  id: string;
  actor_user_id: string;
  creator_id: string | null;
  title_count: number;
  requested_title_ids: string[];
  valid_title_ids: string[];
  invalid_title_ids: string[];
  status: BulkPublishingStatus;
  created_at: string;
};

type StudioAnalyticsReport = {
  portfolio_score: number;
  total_titles: number;
  total_series: number;
  total_creators: number;
  top_titles: JsonObject[];
  creator_performance: JsonObject[];
  growth_segments: JsonObject[];
};

type RightsReport = {
  total_windows: number;
  clear_windows: number;
  review_windows: number;
  territories: string[];
  windows: JsonObject[];
};

type DistributionTarget = {
  id: string;
  name: string;
  state: "ready" | "review";
  title_count: number;
};

type DistributionReport = {
  targets: DistributionTarget[];
  ready_targets: number;
  review_targets: number;
  package_count: number;
  bulk_batch_count: number;
};

const bulkBatches: BulkPublishingBatchRecord[] = [];
let bulkBatchCounter = 1;

export function enterpriseStudioReadinessSummary(): JsonObject {
  return {
    enterprise_studio_enabled: true,
    studio_analytics: true,
    bulk_publishing: true,
    rights_management_reporting: true,
    distribution_reporting: true,
    enterprise_dashboards: true,
    external_enterprise_services: false,
    bulk_batches: bulkBatches.length
  };
}

export function enterpriseStudioSummary(authorizationHeader: string | undefined): JsonObject {
  const session = requireEnterpriseSession(authorizationHeader);
  return {
    status: "ready",
    user_id: session.user_id,
    dashboard: enterpriseDashboard(),
    analytics: studioAnalytics(),
    rights_report: rightsReport(),
    distribution_report: distributionReport(),
    bulk_publishing_batches: visibleBatches(session),
    generated_at: nowISO()
  };
}

export function enterpriseStudioAnalytics(authorizationHeader: string | undefined): JsonObject {
  requireEnterpriseSession(authorizationHeader);
  return {
    status: "ready",
    analytics: studioAnalytics(),
    generated_at: nowISO()
  };
}

export function createBulkPublishingBatch(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireEnterpriseSession(authorizationHeader);
  const requested = stringArrayFromBody(body, "title_ids");
  const fallbackIDs = catalogSeed.movies.slice(0, 4).map((movie) => movie.id);
  const requestedTitleIDs = requested.length > 0 ? requested : fallbackIDs;
  const catalogIDs = new Set(catalogSeed.movies.map((movie) => movie.id));
  const validTitleIDs = requestedTitleIDs.filter((id) => catalogIDs.has(id));
  const invalidTitleIDs = requestedTitleIDs.filter((id) => !catalogIDs.has(id));
  const batch: BulkPublishingBatchRecord = {
    id: `enterprise-bulk-publishing-${bulkBatchCounter++}`,
    actor_user_id: session.user_id,
    creator_id: session.creator_id ?? null,
    title_count: validTitleIDs.length,
    requested_title_ids: requestedTitleIDs,
    valid_title_ids: validTitleIDs,
    invalid_title_ids: invalidTitleIDs,
    status: invalidTitleIDs.length > 0 ? "needs_review" : "validated",
    created_at: nowISO()
  };
  bulkBatches.push(batch);
  recordAnalyticsEvent("publishing_state_change", {
    enterprise_bulk_batch_id: batch.id,
    requested_count: requestedTitleIDs.length,
    valid_count: validTitleIDs.length,
    invalid_count: invalidTitleIDs.length
  }, {
    authorizationHeader,
    identitySession: session,
    source: "enterprise_bulk_publishing"
  });
  return {
    status: "queued",
    batch,
    validation: {
      all_titles_valid: invalidTitleIDs.length === 0,
      invalid_title_ids: invalidTitleIDs
    }
  };
}

export function enterpriseRightsReport(authorizationHeader: string | undefined): JsonObject {
  requireEnterpriseSession(authorizationHeader);
  return {
    status: "ready",
    rights_report: rightsReport(),
    generated_at: nowISO()
  };
}

export function enterpriseDistributionReport(authorizationHeader: string | undefined): JsonObject {
  requireEnterpriseSession(authorizationHeader);
  return {
    status: "ready",
    distribution_report: distributionReport(),
    generated_at: nowISO()
  };
}

function requireEnterpriseSession(authorizationHeader: string | undefined): IdentitySession {
  const session = requireIdentitySession(authorizationHeader);
  if (session.role !== "creator" && session.role !== "admin") {
    throw new ContractError("enterprise_role_required", "Enterprise studio tools require a creator or admin session", 403);
  }
  return session;
}

function enterpriseDashboard(): JsonObject {
  const analytics = studioAnalytics();
  const rights = rightsReport();
  const distribution = distributionReport();
  return {
    studio_health: "ready",
    catalog_titles: catalogSeed.movies.length,
    series_count: catalogSeed.series.length,
    creators: catalogSeed.creators.length,
    rights_windows: rights.total_windows,
    distribution_targets: distribution.targets.length,
    bulk_batches: bulkBatches.length,
    top_title: analytics.top_titles[0] ?? null
  };
}

function studioAnalytics(): StudioAnalyticsReport {
  const topTitles = catalogSeed.movies.slice(0, 6).map((movie, index) => ({
    movie_id: movie.id,
    title: movie.title,
    studio_score: 98 - index * 4,
    estimated_watch_hours: 1800 - index * 120,
    completion_rate: Number((0.91 - index * 0.035).toFixed(3)),
    distribution_lift: Number((1.28 - index * 0.04).toFixed(2))
  }));
  const creatorPerformance = catalogSeed.creators.map((creator, index) => ({
    creator_id: creator.id,
    name: creator.name,
    published_titles: catalogSeed.movies.filter((movie) => movie.creator_id === creator.id).length,
    portfolio_score: 92 - index * 5
  }));
  return {
    portfolio_score: 94,
    total_titles: catalogSeed.movies.length,
    total_series: catalogSeed.series.length,
    total_creators: catalogSeed.creators.length,
    top_titles: topTitles,
    creator_performance: creatorPerformance,
    growth_segments: [
      { segment: "Premium premieres", lift: 1.34 },
      { segment: "Creator collections", lift: 1.21 },
      { segment: "Series continuity", lift: 1.18 }
    ]
  };
}

function rightsReport(): RightsReport {
  const territories = ["US", "CA", "GB", "AU"];
  const windows = catalogSeed.movies.slice(0, 8).map((movie, index) => ({
    movie_id: movie.id,
    title: movie.title,
    territory: territories[index % territories.length],
    window_state: index % 5 === 0 ? "review" : "clear",
    starts_at: "2026-01-01T00:00:00.000Z",
    ends_at: "2027-01-01T00:00:00.000Z"
  }));
  return {
    total_windows: windows.length,
    clear_windows: windows.filter((window) => window.window_state === "clear").length,
    review_windows: windows.filter((window) => window.window_state === "review").length,
    territories,
    windows
  };
}

function distributionReport(): DistributionReport {
  const targets: DistributionTarget[] = [
    { id: "highfive-home", name: "HighFive Home", state: "ready", title_count: catalogSeed.movies.length },
    { id: "creator-profiles", name: "Creator Profiles", state: "ready", title_count: catalogSeed.creators.length },
    { id: "premiere-rail", name: "Premiere Rail", state: "ready", title_count: Math.min(4, catalogSeed.movies.length) },
    { id: "series-shelf", name: "Series Shelf", state: "ready", title_count: catalogSeed.series.length },
    { id: "collection-worlds", name: "Collection Worlds", state: "review", title_count: catalogSeed.collections.length }
  ];
  return {
    targets,
    ready_targets: targets.filter((target) => target.state === "ready").length,
    review_targets: targets.filter((target) => target.state === "review").length,
    package_count: catalogSeed.publishing_projects.length,
    bulk_batch_count: bulkBatches.length
  };
}

function visibleBatches(session: IdentitySession): BulkPublishingBatchRecord[] {
  if (session.role === "admin") return bulkBatches;
  return bulkBatches.filter((batch) => batch.actor_user_id === session.user_id || batch.creator_id === session.creator_id);
}

function stringArrayFromBody(body: unknown, key: string): string[] {
  if (!isRecord(body) || !Array.isArray(body[key])) return [];
  return body[key]
    .filter((value): value is string => typeof value === "string" && value.trim().length > 0)
    .map((value) => value.trim());
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function nowISO(): string {
  return new Date().toISOString();
}
