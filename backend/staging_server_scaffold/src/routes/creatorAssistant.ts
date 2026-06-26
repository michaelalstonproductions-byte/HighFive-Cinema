import { catalogSeed, type CatalogMovie } from "../catalog/catalogSeed.js";
import type { JsonObject } from "../contracts.js";
import { ContractError } from "../errors.js";
import { recordAnalyticsEvent } from "./analytics.js";
import { requireCreatorIdentitySession, type IdentitySession } from "./identity.js";

type AssistantContext = {
  project_id: string;
  content_id: string;
  creator_id: string;
  title: string;
  description: string;
  genre: string;
  tags: string[];
  runtime: string;
  poster_status: string;
  trailer_status: string;
  metadata_status: string;
  artwork_status: string;
};

type AssistantSection =
  | "summary"
  | "metadata"
  | "poster"
  | "trailer"
  | "publishing"
  | "seo"
  | "rights";

export function creatorAssistantReadinessSummary(): JsonObject {
  return {
    creator_assistant_enabled: true,
    external_ai_calls: false,
    metadata_generation: true,
    poster_suggestions: true,
    trailer_suggestions: true,
    publishing_assistant: true,
    seo_assistant: true,
    rights_assistant: true,
    deterministic_local_rules: true
  };
}

export function creatorAssistantSummary(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const context = assistantContextFor(session, body);
  recordAssistantAnalytics(authorizationHeader, session, context, "summary");
  return {
    status: "ready",
    assistant: "local_creator_assistant_v1",
    external_ai_calls: false,
    context,
    metadata: metadataSuggestion(context),
    poster: posterSuggestion(context),
    trailer: trailerSuggestion(context),
    publishing: publishingSuggestion(context),
    seo: seoSuggestion(context),
    rights: rightsSuggestion(context),
    generated_at: nowISO()
  };
}

export function creatorAssistantMetadata(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const context = assistantContextFor(session, body);
  recordAssistantAnalytics(authorizationHeader, session, context, "metadata");
  return {
    status: "ready",
    assistant: "local_creator_assistant_v1",
    external_ai_calls: false,
    context,
    metadata: metadataSuggestion(context)
  };
}

export function creatorAssistantPoster(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const context = assistantContextFor(session, body);
  recordAssistantAnalytics(authorizationHeader, session, context, "poster");
  return {
    status: "ready",
    assistant: "local_creator_assistant_v1",
    external_ai_calls: false,
    context,
    poster: posterSuggestion(context)
  };
}

export function creatorAssistantTrailer(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const context = assistantContextFor(session, body);
  recordAssistantAnalytics(authorizationHeader, session, context, "trailer");
  return {
    status: "ready",
    assistant: "local_creator_assistant_v1",
    external_ai_calls: false,
    context,
    trailer: trailerSuggestion(context)
  };
}

export function creatorAssistantPublishing(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const context = assistantContextFor(session, body);
  recordAssistantAnalytics(authorizationHeader, session, context, "publishing");
  return {
    status: "ready",
    assistant: "local_creator_assistant_v1",
    external_ai_calls: false,
    context,
    publishing: publishingSuggestion(context)
  };
}

export function creatorAssistantSEO(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const context = assistantContextFor(session, body);
  recordAssistantAnalytics(authorizationHeader, session, context, "seo");
  return {
    status: "ready",
    assistant: "local_creator_assistant_v1",
    external_ai_calls: false,
    context,
    seo: seoSuggestion(context)
  };
}

export function creatorAssistantRights(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const context = assistantContextFor(session, body);
  recordAssistantAnalytics(authorizationHeader, session, context, "rights");
  return {
    status: "ready",
    assistant: "local_creator_assistant_v1",
    external_ai_calls: false,
    context,
    rights: rightsSuggestion(context)
  };
}

function assistantContextFor(session: IdentitySession, body: unknown): AssistantContext {
  const bodyRecord = isRecord(body) ? body : {};
  const requestedProjectID = stringField(bodyRecord, "project_id");
  const requestedContentID = stringField(bodyRecord, "content_id");
  const creatorID = stringField(bodyRecord, "creator_id") ?? session.creator_id ?? catalogSeed.creators[0]?.id ?? "maya-hart";
  if (session.role !== "admin" && session.creator_id && creatorID !== session.creator_id) {
    throw new ContractError("creator_context_denied", "Creator assistant can only inspect the authenticated creator workspace", 403);
  }

  const project = catalogSeed.publishing_projects.find((candidate) => candidate.id === requestedProjectID) ??
    catalogSeed.publishing_projects.find((candidate) => candidate.content_id === requestedContentID) ??
    catalogSeed.publishing_projects.find((candidate) => candidate.creator_id === creatorID) ??
    catalogSeed.publishing_projects[0];
  const movie = catalogSeed.movies.find((candidate) => candidate.id === requestedContentID) ??
    catalogSeed.movies.find((candidate) => candidate.id === project?.content_id) ??
    catalogSeed.movies.find((candidate) => candidate.creator_id === creatorID);
  const title = stringField(bodyRecord, "title") ?? movie?.title ?? project?.title ?? "Untitled HighFive Project";
  const description = stringField(bodyRecord, "description") ?? movie?.synopsis ?? "A creator project prepared for HighFive publishing.";
  const tags = stringArrayField(bodyRecord, "tags");
  const genres = stringArrayField(bodyRecord, "genres");

  return {
    project_id: project?.id ?? `project-${slug(title)}`,
    content_id: movie?.id ?? project?.content_id ?? `content-${slug(title)}`,
    creator_id: creatorID,
    title,
    description,
    genre: stringField(bodyRecord, "genre") ?? genres[0] ?? movie?.genres[0] ?? "Drama",
    tags: tags.length > 0 ? tags : unique([...(movie?.genres ?? []), "HighFive", "Creator"]),
    runtime: stringField(bodyRecord, "runtime") ?? movie?.duration ?? "45m",
    poster_status: project?.poster_status ?? "draft",
    trailer_status: project?.trailer_status ?? "draft",
    metadata_status: project?.metadata_status ?? "draft",
    artwork_status: project?.artwork_status ?? "draft"
  };
}

function metadataSuggestion(context: AssistantContext): JsonObject {
  const genre = context.genre;
  const hook = hookFor(context);
  return {
    title: context.title,
    logline: `${context.title} follows ${hook.toLowerCase()} through a ${genre.toLowerCase()} lens.`,
    short_synopsis: sentenceLimit(context.description, 150),
    long_synopsis: `${sentenceLimit(context.description, 260)} The recommended detail page should foreground creator intent, audience stakes, and why this title belongs in HighFive's ${genre} discovery path.`,
    genre,
    tags: unique([...context.tags, genre, "Creator Published"]).slice(0, 8),
    rating_note: "Confirm final rating before review submission.",
    runtime_label: context.runtime,
    metadata_status: context.metadata_status === "ready" ? "ready" : "needs_creator_review"
  };
}

function posterSuggestion(context: AssistantContext): JsonObject {
  const palette = paletteFor(context.genre);
  return {
    concept: `${context.title} key art should use one dominant subject, ${palette.accent} edge light, and enough negative space for mobile poster cropping.`,
    layouts: [
      "Primary portrait poster with title below eye line",
      "Collection thumbnail crop with centered subject",
      "Premiere banner crop with horizontal safe area"
    ],
    palette,
    typography: "Use a high-contrast title stack and keep secondary copy under two lines.",
    accessibility: "Maintain readable title contrast at poster-card size.",
    poster_status: context.poster_status === "ready" ? "ready" : "needs_artwork_review"
  };
}

function trailerSuggestion(context: AssistantContext): JsonObject {
  return {
    structure: [
      { beat: "Hook", target_time: "0:00-0:08", note: `Open with the strongest ${context.genre.toLowerCase()} image or line.` },
      { beat: "World", target_time: "0:08-0:22", note: "Clarify setting, protagonist, and emotional stakes." },
      { beat: "Turn", target_time: "0:22-0:42", note: "Reveal the pressure without resolving the story." },
      { beat: "Creator Stamp", target_time: "0:42-0:52", note: "Include a creator signature moment or commentary hook." },
      { beat: "Close", target_time: "0:52-1:00", note: "End on title, HighFive availability, and premiere context." }
    ],
    recommended_length_seconds: context.runtime.includes("episodes") ? 75 : 60,
    trailer_status: context.trailer_status === "ready" ? "ready" : "needs_trailer_review"
  };
}

function publishingSuggestion(context: AssistantContext): JsonObject {
  const rights = rightsSuggestion(context);
  const checklist = [
    readinessItem("Metadata", context.metadata_status),
    readinessItem("Poster", context.poster_status),
    readinessItem("Trailer", context.trailer_status),
    readinessItem("Artwork", context.artwork_status),
    { item: "Rights", status: rights.blocking_issues.length === 0 ? "ready" : "needs_review" }
  ];
  const readyCount = checklist.filter((item) => item.status === "ready").length;
  return {
    readiness_score: Math.round((readyCount / checklist.length) * 100),
    checklist,
    next_actions: checklist
      .filter((item) => item.status !== "ready")
      .map((item) => `Resolve ${item.item.toLowerCase()} before submitting for review.`),
    recommended_state: readyCount === checklist.length ? "submit_for_review" : "continue_draft"
  };
}

function seoSuggestion(context: AssistantContext): JsonObject {
  const baseKeywords = unique([
    context.title,
    context.genre,
    ...context.tags,
    "HighFive Original",
    "creator film",
    "premiere"
  ]);
  return {
    slug: slug(context.title),
    search_title: `${context.title} | ${context.genre} on HighFive`,
    meta_description: sentenceLimit(`${context.description} Watch ${context.title} from its creator profile, collections, and HighFive discovery rails.`, 155),
    keywords: baseKeywords.slice(0, 10),
    ranking_focus: ["title", "creator", "genre", "tags", "collections", "synopsis"],
    creator_profile_linking: true
  };
}

function rightsSuggestion(context: AssistantContext): {
  rights_readiness: string;
  clearance_checks: { item: string; status: string }[];
  territory_recommendation: string;
  blocking_issues: string[];
} {
  const blockingIssues = [];
  if (!context.tags.some((tag) => tag.toLowerCase().includes("creator"))) {
    blockingIssues.push("Confirm creator ownership metadata.");
  }
  if (context.trailer_status !== "ready") {
    blockingIssues.push("Confirm trailer music, footage, and talent clearance before publication.");
  }
  return {
    rights_readiness: blockingIssues.length === 0 ? "ready" : "needs_review",
    clearance_checks: [
      { item: "Creator ownership", status: context.creator_id ? "ready" : "needs_review" },
      { item: "Music cue sheet", status: context.trailer_status === "ready" ? "ready" : "needs_review" },
      { item: "Artwork license", status: context.artwork_status === "ready" ? "ready" : "needs_review" },
      { item: "Territory window", status: "ready" }
    ],
    territory_recommendation: "US preview window first, expand after review.",
    blocking_issues: blockingIssues
  };
}

function readinessItem(item: string, status: string): { item: string; status: string } {
  return { item, status: status === "ready" ? "ready" : "needs_review" };
}

function recordAssistantAnalytics(
  authorizationHeader: string | undefined,
  session: IdentitySession,
  context: AssistantContext,
  section: AssistantSection
): void {
  recordAnalyticsEvent("publishing_state_change", {
    project_id: context.project_id,
    content_id: context.content_id,
    creator_id: context.creator_id,
    assistant_section: section,
    external_ai_calls: false
  }, {
    authorizationHeader,
    identitySession: session,
    contentID: context.content_id,
    creatorID: context.creator_id,
    projectID: context.project_id,
    source: "creator_assistant"
  });
}

function hookFor(context: AssistantContext): string {
  if (context.tags.some((tag) => tag.toLowerCase().includes("mystery"))) return "a mystery that pulls viewers deeper scene by scene";
  if (context.tags.some((tag) => tag.toLowerCase().includes("documentary"))) return "a true-story perspective shaped by creator access";
  if (context.genre.toLowerCase().includes("premiere")) return "a premiere event built around audience anticipation";
  return "an emotional story with a clear creator point of view";
}

function paletteFor(genre: string): JsonObject {
  const normalized = genre.toLowerCase();
  if (normalized.includes("mystery")) return { base: "optical black", accent: "cyan", support: "violet" };
  if (normalized.includes("documentary")) return { base: "charcoal", accent: "gold", support: "warm white" };
  if (normalized.includes("premiere")) return { base: "black", accent: "gold", support: "cyan" };
  return { base: "cinematic black", accent: "gold", support: "violet" };
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

function sentenceLimit(value: string, limit: number): string {
  const trimmed = value.trim();
  return trimmed.length <= limit ? trimmed : `${trimmed.slice(0, Math.max(0, limit - 3)).trim()}...`;
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
