import { catalogSeed } from "../catalog/catalogSeed.js";
import type { JsonObject } from "../contracts.js";
import { ContractError } from "../errors.js";
import { requireIdentitySession, type IdentitySession } from "./identity.js";

type DistributionState = "planned" | "ready" | "review";

type LocalizationRecord = {
  id: string;
  creator_id: string | null;
  content_id: string;
  locale: string;
  title: string;
  synopsis_status: DistributionState;
  metadata_status: DistributionState;
  created_at: string;
  updated_at: string;
};

type SubtitleRecord = {
  id: string;
  creator_id: string | null;
  content_id: string;
  language: string;
  format: "srt" | "vtt" | "itt";
  status: DistributionState;
  cue_count: number;
  created_at: string;
  updated_at: string;
};

type RegionalPublishingRecord = {
  id: string;
  creator_id: string | null;
  content_id: string;
  region: string;
  release_window: string;
  status: DistributionState;
  collection_id: string | null;
  created_at: string;
  updated_at: string;
};

type TerritoryRecord = {
  id: string;
  creator_id: string | null;
  territory: string;
  availability: "available" | "blocked" | "review";
  rights_state: "clear" | "review";
  title_ids: string[];
  created_at: string;
  updated_at: string;
};

type LanguageRecord = {
  id: string;
  creator_id: string | null;
  language: string;
  locale: string;
  dubbing_status: DistributionState;
  subtitle_status: DistributionState;
  title_count: number;
  created_at: string;
  updated_at: string;
};

const localizations: LocalizationRecord[] = [];
const subtitles: SubtitleRecord[] = [];
const regionalPublishing: RegionalPublishingRecord[] = [];
const territories: TerritoryRecord[] = [];
const languages: LanguageRecord[] = [];

let localizationCounter = 1;
let subtitleCounter = 1;
let regionalCounter = 1;
let territoryCounter = 1;
let languageCounter = 1;

seedGlobalDistribution();

export function v3GlobalDistributionReadinessSummary(): JsonObject {
  return {
    v3_global_distribution_enabled: true,
    localization: true,
    subtitles: true,
    regional_publishing: true,
    territories: true,
    languages: true,
    external_distribution_services: false,
    localization_records: localizations.length,
    subtitle_records: subtitles.length,
    territory_records: territories.length
  };
}

export function v3GlobalDistributionSummary(authorizationHeader: string | undefined): JsonObject {
  const session = requireGlobalDistributionSession(authorizationHeader);
  return {
    status: "ready",
    global_distribution: "local_v3_global_distribution",
    external_services: false,
    user_id: session.user_id,
    creator_id: session.creator_id,
    localization: visibleTo(session, localizations),
    subtitles: visibleTo(session, subtitles),
    regional_publishing: visibleTo(session, regionalPublishing),
    territories: visibleTo(session, territories),
    languages: visibleTo(session, languages),
    dashboard: globalDistributionDashboard(session),
    generated_at: nowISO()
  };
}

export function createGlobalLocalization(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireGlobalDistributionSession(authorizationHeader);
  const movie = movieForBody(body);
  const record: LocalizationRecord = {
    id: `global-localization-${localizationCounter++}`,
    creator_id: session.creator_id,
    content_id: movie.id,
    locale: trimmed(optionalString(body, "locale") ?? "es-MX", 20),
    title: trimmed(optionalString(body, "title") ?? `${movie.title} Localized`, 160),
    synopsis_status: distributionState(optionalString(body, "synopsis_status")),
    metadata_status: distributionState(optionalString(body, "metadata_status")),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  localizations.push(record);
  return { status: "created", localization: record };
}

export function createGlobalSubtitle(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireGlobalDistributionSession(authorizationHeader);
  const movie = movieForBody(body);
  const record: SubtitleRecord = {
    id: `global-subtitle-${subtitleCounter++}`,
    creator_id: session.creator_id,
    content_id: movie.id,
    language: trimmed(optionalString(body, "language") ?? "Spanish", 80),
    format: subtitleFormat(optionalString(body, "format")),
    status: distributionState(optionalString(body, "status")),
    cue_count: positiveInteger(body, "cue_count", 420),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  subtitles.push(record);
  return { status: "created", subtitle: record };
}

export function createRegionalPublishing(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireGlobalDistributionSession(authorizationHeader);
  const movie = movieForBody(body);
  const record: RegionalPublishingRecord = {
    id: `global-regional-publishing-${regionalCounter++}`,
    creator_id: session.creator_id,
    content_id: movie.id,
    region: trimmed(optionalString(body, "region") ?? "LATAM", 80),
    release_window: trimmed(optionalString(body, "release_window") ?? "Preview quarter", 120),
    status: distributionState(optionalString(body, "status")),
    collection_id: optionalString(body, "collection_id") ?? catalogSeed.collections[0]?.id ?? null,
    created_at: nowISO(),
    updated_at: nowISO()
  };
  regionalPublishing.push(record);
  return { status: "created", regional_publishing: record };
}

export function createGlobalTerritory(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireGlobalDistributionSession(authorizationHeader);
  const record: TerritoryRecord = {
    id: `global-territory-${territoryCounter++}`,
    creator_id: session.creator_id,
    territory: trimmed(optionalString(body, "territory") ?? "MX", 40),
    availability: territoryAvailability(optionalString(body, "availability")),
    rights_state: rightsState(optionalString(body, "rights_state")),
    title_ids: stringArray(body, "title_ids", catalogSeed.movies.slice(0, 3).map((movie) => movie.id)),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  territories.push(record);
  return { status: "created", territory: record };
}

export function createGlobalLanguage(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireGlobalDistributionSession(authorizationHeader);
  const record: LanguageRecord = {
    id: `global-language-${languageCounter++}`,
    creator_id: session.creator_id,
    language: trimmed(optionalString(body, "language") ?? "Spanish", 80),
    locale: trimmed(optionalString(body, "locale") ?? "es-MX", 20),
    dubbing_status: distributionState(optionalString(body, "dubbing_status")),
    subtitle_status: distributionState(optionalString(body, "subtitle_status")),
    title_count: positiveInteger(body, "title_count", 3),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  languages.push(record);
  return { status: "created", language: record };
}

function seedGlobalDistribution(): void {
  if (localizations.length > 0) return;
  const creatorID = "maya-hart";
  localizations.push({
    id: "global-localization-seed-1",
    creator_id: creatorID,
    content_id: "friendly",
    locale: "es-MX",
    title: "The Friendly Localized",
    synopsis_status: "ready",
    metadata_status: "ready",
    created_at: nowISO(),
    updated_at: nowISO()
  });
  subtitles.push({
    id: "global-subtitle-seed-1",
    creator_id: creatorID,
    content_id: "friendly",
    language: "Spanish",
    format: "vtt",
    status: "ready",
    cue_count: 520,
    created_at: nowISO(),
    updated_at: nowISO()
  });
  regionalPublishing.push({
    id: "global-regional-publishing-seed-1",
    creator_id: creatorID,
    content_id: "friendly",
    region: "LATAM",
    release_window: "Festival preview quarter",
    status: "planned",
    collection_id: catalogSeed.collections[0]?.id ?? null,
    created_at: nowISO(),
    updated_at: nowISO()
  });
  territories.push({
    id: "global-territory-seed-1",
    creator_id: creatorID,
    territory: "MX",
    availability: "available",
    rights_state: "clear",
    title_ids: ["friendly", "behind-the-vision"],
    created_at: nowISO(),
    updated_at: nowISO()
  });
  languages.push({
    id: "global-language-seed-1",
    creator_id: creatorID,
    language: "Spanish",
    locale: "es-MX",
    dubbing_status: "planned",
    subtitle_status: "ready",
    title_count: 2,
    created_at: nowISO(),
    updated_at: nowISO()
  });
}

function requireGlobalDistributionSession(authorizationHeader: string | undefined): IdentitySession {
  const session = requireIdentitySession(authorizationHeader);
  if (session.role !== "creator" && session.role !== "admin") {
    throw new ContractError("global_distribution_role_required", "Global distribution operations require a creator or admin session", 403);
  }
  return session;
}

function visibleTo<T extends { creator_id: string | null }>(session: IdentitySession, records: T[]): T[] {
  if (session.role === "admin") return records;
  return records.filter((record) => record.creator_id === session.creator_id);
}

function globalDistributionDashboard(session: IdentitySession): JsonObject {
  const localizationRecords = visibleTo(session, localizations);
  const subtitleRecords = visibleTo(session, subtitles);
  const territoryRecords = visibleTo(session, territories);
  const languageRecords = visibleTo(session, languages);
  return {
    localized_titles: localizationRecords.length,
    subtitle_tracks: subtitleRecords.length,
    active_territories: territoryRecords.filter((record) => record.availability === "available").length,
    languages: languageRecords.length,
    regional_release_plans: visibleTo(session, regionalPublishing).length,
    ready_records: [
      ...localizationRecords.map((record) => record.metadata_status),
      ...subtitleRecords.map((record) => record.status),
      ...languageRecords.map((record) => record.subtitle_status)
    ].filter((status) => status === "ready").length
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

function stringArray(body: unknown, key: string, fallback: string[]): string[] {
  if (!isRecord(body) || !Array.isArray(body[key])) return fallback;
  const values = body[key].filter((value): value is string => typeof value === "string" && value.trim().length > 0);
  return values.length > 0 ? values.map((value) => value.trim()) : fallback;
}

function positiveInteger(body: unknown, key: string, fallback: number): number {
  if (!isRecord(body) || typeof body[key] !== "number" || !Number.isFinite(body[key])) return fallback;
  return Math.max(1, Math.floor(body[key]));
}

function distributionState(value: string | null): DistributionState {
  if (value === "ready" || value === "review") return value;
  return "planned";
}

function subtitleFormat(value: string | null): SubtitleRecord["format"] {
  if (value === "srt" || value === "itt") return value;
  return "vtt";
}

function territoryAvailability(value: string | null): TerritoryRecord["availability"] {
  if (value === "blocked" || value === "review") return value;
  return "available";
}

function rightsState(value: string | null): TerritoryRecord["rights_state"] {
  return value === "review" ? "review" : "clear";
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
