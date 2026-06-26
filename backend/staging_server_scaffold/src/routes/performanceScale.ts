import { catalogSeed, type CatalogMovie } from "../catalog/catalogSeed.js";
import type { JsonObject } from "../contracts.js";
import { ContractError } from "../errors.js";
import { recordAnalyticsEvent } from "./analytics.js";
import { requireIdentitySession, type IdentitySession } from "./identity.js";

type CacheRecord = {
  key: string;
  entity_count: number;
  warmed_at: string;
};

type SyncTuningRecord = {
  id: string;
  actor_user_id: string;
  batch_size: number;
  stale_while_revalidate_seconds: number;
  background_refresh_interval_seconds: number;
  max_delta_pages: number;
  created_at: string;
};

const cache = new Map<string, CacheRecord>();
const syncTuningRecords: SyncTuningRecord[] = [];
let syncTuningCounter = 1;

export function performanceScaleReadinessSummary(): JsonObject {
  return {
    performance_scale_enabled: true,
    large_catalog_pagination: true,
    search_index_diagnostics: true,
    catalog_cache_warming: true,
    background_sync_tuning: true,
    database_index_plan: true,
    external_scale_services: false,
    cache_entries: cache.size,
    sync_tuning_records: syncTuningRecords.length
  };
}

export function performanceScaleSummary(authorizationHeader: string | undefined): JsonObject {
  const session = requirePerformanceSession(authorizationHeader);
  return {
    status: "ready",
    user_id: session.user_id,
    catalog: catalogScaleSummary(),
    cache: cacheSummary(),
    search_index: searchIndexDiagnostics(),
    sync_tuning: syncTuningRecords.slice(-10),
    generated_at: nowISO()
  };
}

export function warmPerformanceCache(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requirePerformanceSession(authorizationHeader);
  const scopes = stringArrayFromBody(body, "scopes");
  const requestedScopes = scopes.length > 0 ? scopes : ["catalog", "search", "collections", "series"];
  const warmed = requestedScopes.map((scope) => warmScope(scope));
  recordAnalyticsEvent("search", {
    query: "performance-cache-warm",
    warmed_scopes: warmed.map((record) => record.key).join(","),
    cache_entries: cache.size
  }, {
    authorizationHeader,
    identitySession: session,
    source: "performance_scale_cache_warm"
  });
  return {
    status: "warmed",
    warmed,
    cache: cacheSummary()
  };
}

export function largeCatalogPage(rawURL: string | undefined, authorizationHeader: string | undefined): JsonObject {
  requirePerformanceSession(authorizationHeader);
  const url = new URL(rawURL ?? "/", "http://127.0.0.1");
  const page = positiveInt(url.searchParams.get("page"), 1);
  const pageSize = Math.min(50, positiveInt(url.searchParams.get("page_size"), 24));
  const multiplier = Math.min(200, positiveInt(url.searchParams.get("multiplier"), 25));
  const total = catalogSeed.movies.length * multiplier;
  const start = (page - 1) * pageSize;
  const end = Math.min(start + pageSize, total);
  const items = Array.from({ length: Math.max(0, end - start) }, (_, offset) => virtualMovie(start + offset));
  return {
    status: "ready",
    page,
    page_size: pageSize,
    total_results: total,
    total_pages: Math.ceil(total / pageSize),
    has_next_page: end < total,
    items,
    strategy: "virtualized_catalog_page",
    generated_at: nowISO()
  };
}

export function searchIndexReport(authorizationHeader: string | undefined): JsonObject {
  requirePerformanceSession(authorizationHeader);
  return {
    status: "ready",
    search_index: searchIndexDiagnostics(),
    generated_at: nowISO()
  };
}

export function recordSyncTuning(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requirePerformanceSession(authorizationHeader);
  const record: SyncTuningRecord = {
    id: `sync-tuning-${syncTuningCounter++}`,
    actor_user_id: session.user_id,
    batch_size: Math.min(500, positiveNumberFromBody(body, "batch_size", 100)),
    stale_while_revalidate_seconds: Math.min(86_400, positiveNumberFromBody(body, "stale_while_revalidate_seconds", 900)),
    background_refresh_interval_seconds: Math.min(86_400, positiveNumberFromBody(body, "background_refresh_interval_seconds", 1800)),
    max_delta_pages: Math.min(100, positiveNumberFromBody(body, "max_delta_pages", 8)),
    created_at: nowISO()
  };
  syncTuningRecords.push(record);
  return {
    status: "recorded",
    sync_tuning: record,
    effective_policy: {
      cache_strategy: "stale_while_revalidate",
      delta_sync: true,
      duplicate_protection: true,
      offline_fallback: true
    }
  };
}

function requirePerformanceSession(authorizationHeader: string | undefined): IdentitySession {
  return requireIdentitySession(authorizationHeader);
}

function catalogScaleSummary(): JsonObject {
  return {
    base_titles: catalogSeed.movies.length,
    base_creators: catalogSeed.creators.length,
    base_series: catalogSeed.series.length,
    base_collections: catalogSeed.collections.length,
    virtual_large_catalog_titles: catalogSeed.movies.length * 25,
    default_page_size: 24,
    max_page_size: 50,
    pagination_strategy: "cursor_ready_page_window"
  };
}

function cacheSummary(): JsonObject {
  return {
    entries: Array.from(cache.values()),
    entry_count: cache.size,
    warmed_scopes: Array.from(cache.keys()),
    policy: "local_memory_cache_with_rebuild_hooks"
  };
}

function warmScope(scope: string): CacheRecord {
  const normalized = normalizedScope(scope);
  const record: CacheRecord = {
    key: normalized,
    entity_count: entityCountForScope(normalized),
    warmed_at: nowISO()
  };
  cache.set(normalized, record);
  return record;
}

function normalizedScope(scope: string): string {
  const normalized = scope.trim().toLowerCase().replace(/[^a-z0-9_-]+/g, "-").replace(/^-+|-+$/g, "");
  return normalized || "catalog";
}

function entityCountForScope(scope: string): number {
  switch (scope) {
  case "catalog":
    return catalogSeed.movies.length;
  case "search":
    return searchIndexDiagnostics().indexed_documents as number;
  case "collections":
    return catalogSeed.collections.length;
  case "series":
    return catalogSeed.series.length;
  case "creators":
    return catalogSeed.creators.length;
  default:
    return catalogSeed.movies.length + catalogSeed.creators.length + catalogSeed.collections.length;
  }
}

function searchIndexDiagnostics(): JsonObject {
  const genreTokens = new Set(catalogSeed.movies.flatMap((movie) => movie.genres.map((genre) => genre.toLowerCase())));
  const creatorTokens = new Set(catalogSeed.creators.map((creator) => creator.name.toLowerCase()));
  const titleTokens = new Set(catalogSeed.movies.flatMap((movie) => tokens(movie.title)));
  const synopsisTokens = new Set(catalogSeed.movies.flatMap((movie) => tokens(movie.synopsis)));
  return {
    indexed_documents: catalogSeed.movies.length + catalogSeed.creators.length + catalogSeed.series.length + catalogSeed.collections.length,
    title_tokens: titleTokens.size,
    synopsis_tokens: synopsisTokens.size,
    genre_tokens: genreTokens.size,
    creator_tokens: creatorTokens.size,
    fields: ["title", "subtitle", "creator", "genre", "collection", "synopsis", "series", "episode"],
    ranking_strategy: "weighted_field_index",
    cache_ready: cache.has("search")
  };
}

function virtualMovie(index: number): JsonObject {
  const source = catalogSeed.movies[index % catalogSeed.movies.length] as CatalogMovie;
  const shard = Math.floor(index / catalogSeed.movies.length) + 1;
  return {
    id: `${source.id}-scale-${shard}`,
    source_id: source.id,
    title: `${source.title} Scale ${shard}`,
    creator_id: source.creator_id,
    genres: source.genres,
    collection_ids: source.collection_ids,
    shard,
    sort_key: index
  };
}

function tokens(value: string): string[] {
  return value.toLowerCase().split(/[^a-z0-9]+/).filter((token) => token.length > 1);
}

function stringArrayFromBody(body: unknown, key: string): string[] {
  if (!isRecord(body) || !Array.isArray(body[key])) return [];
  return body[key]
    .filter((value): value is string => typeof value === "string" && value.trim().length > 0)
    .map((value) => value.trim());
}

function positiveInt(value: string | null, fallback: number): number {
  const parsed = Number.parseInt(value ?? "", 10);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
}

function positiveNumberFromBody(body: unknown, key: string, fallback: number): number {
  if (!isRecord(body) || typeof body[key] !== "number" || !Number.isFinite(body[key]) || body[key] <= 0) return fallback;
  return Math.round(body[key]);
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function nowISO(): string {
  return new Date().toISOString();
}
