import { catalogSeed } from "../catalog/catalogSeed.js";
import type { JsonObject } from "../contracts.js";
import {
  creatorAssistantMetadata,
  creatorAssistantPoster,
  creatorAssistantPublishing,
  creatorAssistantSummary,
  creatorAssistantTrailer
} from "./creatorAssistant.js";
import { requireCreatorIdentitySession, type IdentitySession } from "./identity.js";
import { v3SearchQuery } from "./v3Search.js";

type CopilotContext = {
  project_id: string;
  content_id: string;
  creator_id: string;
  title: string;
  description: string;
  genre: string;
  tags: string[];
  runtime: string;
};

export function v3CreatorCopilotReadinessSummary(): JsonObject {
  return {
    v3_creator_copilot_enabled: true,
    poster_generation: true,
    metadata_writing: true,
    trailer_suggestions: true,
    publishing_recommendations: true,
    audience_targeting: true,
    release_timing: true,
    external_ai_calls: false
  };
}

export function v3CreatorCopilotSummary(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const context = copilotContextFor(session, body);
  const assistant = creatorAssistantSummary(authorizationHeader, context) as JsonObject;
  return {
    status: "ready",
    copilot: "local_v3_creator_copilot",
    external_ai_calls: false,
    context,
    generation_plan: generationPlan(authorizationHeader, context),
    metadata_writing: assistant.metadata,
    poster_generation: posterGeneration(authorizationHeader, context),
    trailer_suggestions: assistant.trailer,
    publishing_recommendations: publishingRecommendations(authorizationHeader, context),
    audience_targeting: audienceTargeting(authorizationHeader, context),
    release_timing: releaseTiming(authorizationHeader, context),
    generated_at: nowISO()
  };
}

export function v3CreatorCopilotGenerationPlan(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const context = copilotContextFor(session, body);
  return {
    status: "ready",
    copilot: "local_v3_creator_copilot",
    external_ai_calls: false,
    context,
    generation_plan: generationPlan(authorizationHeader, context),
    generated_at: nowISO()
  };
}

export function v3CreatorCopilotAudience(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const context = copilotContextFor(session, body);
  return {
    status: "ready",
    copilot: "local_v3_creator_copilot",
    external_ai_calls: false,
    context,
    audience_targeting: audienceTargeting(authorizationHeader, context),
    generated_at: nowISO()
  };
}

export function v3CreatorCopilotReleaseTiming(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const context = copilotContextFor(session, body);
  return {
    status: "ready",
    copilot: "local_v3_creator_copilot",
    external_ai_calls: false,
    context,
    release_timing: releaseTiming(authorizationHeader, context),
    generated_at: nowISO()
  };
}

export function v3CreatorCopilotPublishing(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const context = copilotContextFor(session, body);
  return {
    status: "ready",
    copilot: "local_v3_creator_copilot",
    external_ai_calls: false,
    context,
    publishing_recommendations: publishingRecommendations(authorizationHeader, context),
    generated_at: nowISO()
  };
}

function copilotContextFor(session: IdentitySession, body: unknown): CopilotContext {
  const bodyRecord = isRecord(body) ? body : {};
  const requestedProjectID = stringField(bodyRecord, "project_id");
  const requestedContentID = stringField(bodyRecord, "content_id");
  const creatorID = stringField(bodyRecord, "creator_id") ?? session.creator_id ?? catalogSeed.creators[0]?.id ?? "maya-hart";
  const project = catalogSeed.publishing_projects.find((candidate) => candidate.id === requestedProjectID) ??
    catalogSeed.publishing_projects.find((candidate) => candidate.content_id === requestedContentID) ??
    catalogSeed.publishing_projects.find((candidate) => candidate.creator_id === creatorID) ??
    catalogSeed.publishing_projects[0];
  const movie = catalogSeed.movies.find((candidate) => candidate.id === requestedContentID) ??
    catalogSeed.movies.find((candidate) => candidate.id === project?.content_id) ??
    catalogSeed.movies.find((candidate) => candidate.creator_id === creatorID);
  const title = stringField(bodyRecord, "title") ?? movie?.title ?? project?.title ?? "Untitled HighFive Project";
  const description = stringField(bodyRecord, "description") ?? movie?.synopsis ?? "A creator project prepared for HighFive release.";
  const tags = stringArrayField(bodyRecord, "tags");
  const genres = stringArrayField(bodyRecord, "genres");
  return {
    project_id: project?.id ?? `project-${slug(title)}`,
    content_id: movie?.id ?? project?.content_id ?? `content-${slug(title)}`,
    creator_id: creatorID,
    title,
    description,
    genre: stringField(bodyRecord, "genre") ?? genres[0] ?? movie?.genres[0] ?? "Drama",
    tags: tags.length > 0 ? tags : unique([...(movie?.genres ?? []), "Creator", "HighFive"]),
    runtime: stringField(bodyRecord, "runtime") ?? movie?.duration ?? "45m"
  };
}

function generationPlan(authorizationHeader: string | undefined, context: CopilotContext): JsonObject {
  const metadata = creatorAssistantMetadata(authorizationHeader, context) as { metadata: JsonObject };
  const poster = creatorAssistantPoster(authorizationHeader, context) as { poster: JsonObject };
  const trailer = creatorAssistantTrailer(authorizationHeader, context) as { trailer: JsonObject };
  return {
    priority_order: ["metadata", "poster", "trailer", "audience", "publishing"],
    metadata_brief: metadata.metadata,
    poster_brief: poster.poster,
    trailer_brief: trailer.trailer,
    quality_gates: [
      { gate: "metadata", status: "draft_ready", requirement: "Title, logline, synopsis, genre, tags, and runtime copy are available." },
      { gate: "poster", status: "draft_ready", requirement: "Poster direction includes palette, crop guidance, and mobile readability." },
      { gate: "trailer", status: "draft_ready", requirement: "Trailer beats include hook, world, turn, creator stamp, and close." }
    ],
    recommended_next_action: "review_generated_plan"
  };
}

function posterGeneration(authorizationHeader: string | undefined, context: CopilotContext): JsonObject {
  const poster = creatorAssistantPoster(authorizationHeader, context) as { poster: JsonObject };
  return {
    ...poster.poster,
    generated_variants: [
      { id: "hero-poster", purpose: "detail_page", crop: "2:3 portrait", confidence: posterConfidence(context) },
      { id: "rail-poster", purpose: "home_rail", crop: "poster_card", confidence: posterConfidence(context) - 4 },
      { id: "wide-premiere", purpose: "premiere_banner", crop: "16:9 wide", confidence: posterConfidence(context) - 8 }
    ],
    generation_source: "deterministic_local_rules"
  };
}

function publishingRecommendations(authorizationHeader: string | undefined, context: CopilotContext): JsonObject {
  const publishing = creatorAssistantPublishing(authorizationHeader, context) as { publishing: JsonObject };
  const score = Number(publishing.publishing.readiness_score ?? 0);
  return {
    ...publishing.publishing,
    recommendation: score >= 90 ? "prepare_review_submission" : "continue_asset_review",
    release_package_focus: score >= 90 ? "final_copy_and_rights_check" : "resolve_low_readiness_items",
    discovery_path: discoveryPath(context),
    copilot_note: "Recommendation is local and based on project readiness, metadata, audience fit, and release timing."
  };
}

function audienceTargeting(authorizationHeader: string | undefined, context: CopilotContext): JsonObject {
  const search = v3SearchQuery(`/v3/search/query?q=${encodeURIComponent(context.genre + " " + context.tags.join(" "))}`, authorizationHeader) as { results: { title: string; semantic_concepts: string[] }[] };
  const topRelated = search.results.slice(0, 4);
  return {
    primary_audience: `${context.genre} viewers`,
    affinity_segments: unique([
      ...context.tags.slice(0, 4),
      context.genre,
      context.runtime.toLowerCase().includes("episode") ? "Series Watchers" : "Feature Viewers"
    ]),
    related_titles: topRelated.map((item) => ({ title: item.title, concepts: item.semantic_concepts.slice(0, 4) })),
    targeting_reason: `Audience is derived from ${context.genre}, project tags, runtime, and local search similarity.`,
    channel_mix: [
      { channel: "Personalized Home", priority: "high" },
      { channel: "Creator Profile", priority: "high" },
      { channel: "Mood Discovery", priority: context.tags.some((tag) => tag.toLowerCase().includes("mystery")) ? "high" : "medium" },
      { channel: "Collections", priority: "medium" }
    ]
  };
}

function releaseTiming(authorizationHeader: string | undefined, context: CopilotContext): JsonObject {
  const audience = audienceTargeting(authorizationHeader, context) as { affinity_segments: string[] };
  const isPremiere = context.tags.some((tag) => tag.toLowerCase().includes("premiere")) || context.genre.toLowerCase().includes("premiere");
  const isSeries = context.runtime.toLowerCase().includes("episode") || context.tags.some((tag) => tag.toLowerCase().includes("series"));
  return {
    recommended_window: isPremiere ? "friday_evening_preview" : isSeries ? "sunday_series_slot" : "thursday_feature_preview",
    campaign_ramp_days: isPremiere ? 14 : 7,
    audience_segments: audience.affinity_segments,
    launch_beats: [
      { day_offset: -7, beat: "creator_profile_tease" },
      { day_offset: -3, beat: "poster_and_metadata_refresh" },
      { day_offset: -1, beat: "trailer_or_scene_prompt" },
      { day_offset: 0, beat: "personalized_home_feature" }
    ],
    reasoning: "Timing is calculated locally from genre, tags, runtime, and audience segment shape."
  };
}

function discoveryPath(context: CopilotContext): string[] {
  return [
    "Creator Profile",
    context.genre,
    ...context.tags.filter((tag) => tag !== context.genre).slice(0, 3),
    context.runtime.toLowerCase().includes("episode") ? "Series Shelf" : "Feature Rail"
  ];
}

function posterConfidence(context: CopilotContext): number {
  let score = 78;
  if (context.tags.length >= 3) score += 6;
  if (context.description.length >= 80) score += 6;
  if (context.genre.length > 0) score += 5;
  return Math.min(score, 98);
}

function stringField(body: Record<string, unknown>, key: string): string | null {
  return typeof body[key] === "string" && body[key].trim().length > 0 ? body[key].trim() : null;
}

function stringArrayField(body: Record<string, unknown>, key: string): string[] {
  if (!Array.isArray(body[key])) return [];
  return body[key]
    .filter((value): value is string => typeof value === "string" && value.trim().length > 0)
    .map((value) => value.trim());
}

function slug(value: string): string {
  return value.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "") || "untitled";
}

function unique(values: string[]): string[] {
  return [...new Set(values.filter((value) => value.trim().length > 0))];
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function nowISO(): string {
  return new Date().toISOString();
}
