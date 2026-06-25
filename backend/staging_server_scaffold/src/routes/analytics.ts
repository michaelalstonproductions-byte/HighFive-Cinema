import { randomUUID } from "node:crypto";
import type { JsonObject } from "../contracts.js";
import { ContractError } from "../errors.js";
import { requireIdentitySession, type IdentitySession } from "./identity.js";

type AnalyticsEventName =
  | "playback_start"
  | "playback_progress"
  | "playback_pause"
  | "playback_complete"
  | "search"
  | "search_result_click"
  | "save"
  | "favorite"
  | "collection_open"
  | "creator_profile_open"
  | "upload"
  | "processing_complete"
  | "publishing_state_change";

type AnalyticsEventRecord = {
  id: string;
  schema_version: "analytics.v1";
  event_name: AnalyticsEventName;
  actor_type: "anonymous" | "viewer" | "creator" | "admin";
  user_id: string | null;
  anonymous_id: string | null;
  content_id: string | null;
  creator_id: string | null;
  collection_id: string | null;
  project_id: string | null;
  source: string;
  properties: JsonObject;
  received_at: string;
};

type AnalyticsIngestStats = {
  accepted: number;
  deduplicated: number;
  rejected: number;
  errors: JsonObject[];
};

const allowedEventNames: AnalyticsEventName[] = [
  "playback_start",
  "playback_progress",
  "playback_pause",
  "playback_complete",
  "search",
  "search_result_click",
  "save",
  "favorite",
  "collection_open",
  "creator_profile_open",
  "upload",
  "processing_complete",
  "publishing_state_change"
];

const events = new Map<string, AnalyticsEventRecord>();
const deliveryLedger = new Map<string, string>();
let anonymousCounter = 1;

export function analyticsReadinessSummary(): JsonObject {
  return {
    event_ingestion: true,
    schema_version: "analytics.v1",
    batching: true,
    idempotency: true,
    privacy_sanitization: true,
    authenticated_and_anonymous_ids: true,
    aggregations: true,
    offline_retry_contract: true,
    event_count: events.size
  };
}

export function ingestAnalyticsEvents(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = optionalIdentitySession(authorizationHeader);
  const batch = parseBatch(body);
  const stats: AnalyticsIngestStats = { accepted: 0, deduplicated: 0, rejected: 0, errors: [] };
  const accepted: AnalyticsEventRecord[] = [];

  for (const item of batch) {
    try {
      const record = normalizeEvent(item, session);
      const idempotencyKey = stringField(item, "idempotency_key") ?? record.id;
      if (deliveryLedger.has(idempotencyKey) || events.has(record.id)) {
        stats.deduplicated += 1;
        continue;
      }
      events.set(record.id, record);
      deliveryLedger.set(idempotencyKey, record.id);
      accepted.push(record);
      stats.accepted += 1;
    } catch (error) {
      stats.rejected += 1;
      stats.errors.push({
        error: error instanceof ContractError ? error.code : "invalid_event",
        detail: error instanceof Error ? error.message : "Event rejected"
      });
    }
  }

  return {
    status: stats.rejected > 0 ? "partial" : "accepted",
    schema_version: "analytics.v1",
    accepted_count: stats.accepted,
    deduplicated_count: stats.deduplicated,
    rejected_count: stats.rejected,
    errors: stats.errors,
    accepted_event_ids: accepted.map((record) => record.id),
    aggregations: analyticsAggregations(),
    privacy: {
      sanitized: true,
      private_payload_fields_removed: true,
      credentials_allowed: false
    }
  };
}

export function analyticsDashboard(authorizationHeader: string | undefined): JsonObject {
  optionalIdentitySession(authorizationHeader);
  return {
    status: "ready",
    schema_version: "analytics.v1",
    event_count: events.size,
    aggregations: analyticsAggregations(),
    recent_events: Array.from(events.values()).slice(-20).reverse(),
    privacy: {
      anonymous_ids_supported: true,
      authenticated_ids_supported: true,
      private_payload_fields_removed: true
    }
  };
}

export function recordAnalyticsEvent(
  eventName: AnalyticsEventName,
  properties: JsonObject = {},
  context: {
    authorizationHeader?: string | undefined;
    identitySession?: IdentitySession | null;
    contentID?: string | null;
    creatorID?: string | null;
    collectionID?: string | null;
    projectID?: string | null;
    source?: string;
  } = {}
): void {
  const session = context.identitySession ?? optionalIdentitySession(context.authorizationHeader);
  const record: AnalyticsEventRecord = {
    id: `evt-${randomUUID()}`,
    schema_version: "analytics.v1",
    event_name: eventName,
    actor_type: session?.role ?? "anonymous",
    user_id: session?.user_id ?? null,
    anonymous_id: session ? null : `anon-${anonymousCounter++}`,
    content_id: context.contentID ?? stringField(properties, "movie_id") ?? stringField(properties, "content_id"),
    creator_id: context.creatorID ?? stringField(properties, "creator_id"),
    collection_id: context.collectionID ?? stringField(properties, "collection_id"),
    project_id: context.projectID ?? stringField(properties, "project_id"),
    source: context.source ?? "server_route",
    properties: sanitizeProperties(properties),
    received_at: nowISO()
  };
  events.set(record.id, record);
  deliveryLedger.set(record.id, record.id);
}

function parseBatch(body: unknown): JsonObject[] {
  if (!isRecord(body)) {
    throw new ContractError("invalid_analytics_request", "Analytics request requires a JSON object.", 400);
  }
  const rawEvents = Array.isArray(body.events) ? body.events : null;
  if (!rawEvents || rawEvents.length === 0) {
    throw new ContractError("invalid_analytics_batch", "Analytics request requires at least one event.", 400);
  }
  if (rawEvents.length > 50) {
    throw new ContractError("analytics_batch_too_large", "Analytics batches are limited to 50 events.", 413);
  }
  return rawEvents.filter(isRecord);
}

function normalizeEvent(input: JsonObject, session: IdentitySession | null): AnalyticsEventRecord {
  const eventName = eventNameFrom(input.event_name);
  const properties = isRecord(input.properties) ? sanitizeProperties(input.properties) : {};
  return {
    id: stringField(input, "event_id") ?? `evt-${randomUUID()}`,
    schema_version: "analytics.v1",
    event_name: eventName,
    actor_type: session?.role ?? "anonymous",
    user_id: session?.user_id ?? null,
    anonymous_id: session ? null : stringField(input, "anonymous_id") ?? `anon-${anonymousCounter++}`,
    content_id: stringField(input, "content_id") ?? stringField(properties, "movie_id"),
    creator_id: stringField(input, "creator_id"),
    collection_id: stringField(input, "collection_id"),
    project_id: stringField(input, "project_id"),
    source: stringField(input, "source") ?? "ios_client",
    properties,
    received_at: nowISO()
  };
}

function analyticsAggregations(): JsonObject {
  const records = Array.from(events.values());
  const byName = countBy(records, (record) => record.event_name);
  const byContent = countBy(records.filter((record) => record.content_id), (record) => record.content_id ?? "unknown");
  const byCreator = countBy(records.filter((record) => record.creator_id), (record) => record.creator_id ?? "unknown");
  const playback = records.filter((record) => record.event_name.startsWith("playback_"));
  const discovery = records.filter((record) => ["search", "search_result_click", "collection_open", "creator_profile_open"].includes(record.event_name));
  return {
    total_events: records.length,
    playback_events: playback.length,
    discovery_events: discovery.length,
    creator_events: records.filter((record) => record.actor_type === "creator" || record.actor_type === "admin").length,
    viewer_events: records.filter((record) => record.actor_type === "viewer" || record.actor_type === "anonymous").length,
    saves: byName.save ?? 0,
    favorites: byName.favorite ?? 0,
    searches: byName.search ?? 0,
    uploads: byName.upload ?? 0,
    processing_completions: byName.processing_complete ?? 0,
    publishing_state_changes: byName.publishing_state_change ?? 0,
    top_content: topCounts(byContent),
    top_creators: topCounts(byCreator),
    completion_rate: completionRate(records)
  };
}

function completionRate(records: AnalyticsEventRecord[]): number {
  const starts = records.filter((record) => record.event_name === "playback_start").length;
  const completes = records.filter((record) => record.event_name === "playback_complete").length;
  if (starts === 0) return 0;
  return Math.round((completes / starts) * 100);
}

function countBy<T>(records: T[], keyFor: (record: T) => string): Record<string, number> {
  return records.reduce<Record<string, number>>((counts, record) => {
    const key = keyFor(record);
    counts[key] = (counts[key] ?? 0) + 1;
    return counts;
  }, {});
}

function topCounts(counts: Record<string, number>): JsonObject[] {
  return Object.entries(counts)
    .sort((lhs, rhs) => rhs[1] - lhs[1] || lhs[0].localeCompare(rhs[0]))
    .slice(0, 8)
    .map(([id, count]) => ({ id, count }));
}

function sanitizeProperties(input: JsonObject): JsonObject {
  return Object.fromEntries(
    Object.entries(input)
      .filter(([key, value]) => !privateKeyPattern.test(key) && isSafeValue(value))
      .map(([key, value]) => [key, sanitizeValue(value)])
  );
}

function sanitizeValue(value: unknown): unknown {
  if (Array.isArray(value)) return value.filter(isSafeValue).slice(0, 20);
  if (isRecord(value)) return sanitizeProperties(value);
  return value;
}

function eventNameFrom(value: unknown): AnalyticsEventName {
  if (typeof value === "string" && allowedEventNames.includes(value as AnalyticsEventName)) return value as AnalyticsEventName;
  throw new ContractError("analytics_event_not_allowed", "Analytics event name is not allowlisted.", 422);
}

function optionalIdentitySession(authorizationHeader: string | undefined): IdentitySession | null {
  if (!authorizationHeader) return null;
  try {
    return requireIdentitySession(authorizationHeader);
  } catch {
    return null;
  }
}

function stringField(input: unknown, key: string): string | null {
  if (!isRecord(input)) return null;
  return typeof input[key] === "string" ? input[key] : null;
}

function isSafeValue(value: unknown): boolean {
  if (typeof value === "string") return !privateValuePattern.test(value);
  return value === null || ["number", "boolean", "object"].includes(typeof value);
}

function isRecord(value: unknown): value is JsonObject {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function nowISO(): string {
  return new Date().toISOString();
}

const privateKeyPattern = /(email|token|secret|api[_-]?key|authorization|password|credential|private)/i;
const privateValuePattern = /(Bearer\s+[A-Za-z0-9]|-----BEGIN|client_secret|access_token|refresh_token)/i;
