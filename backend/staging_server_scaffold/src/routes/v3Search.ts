import { catalogSeed, type CatalogCreator, type CatalogMovie } from "../catalog/catalogSeed.js";
import type { JsonObject } from "../contracts.js";
import { governedCatalogSeed } from "./publishing.js";
import { requireIdentitySession } from "./identity.js";
import { v3PersonalizedHome } from "./v3Personalization.js";

type SearchMode = "natural_language" | "semantic" | "visual_similarity" | "creator_similarity" | "voice" | "recommendation";

type SearchResult = {
  movie_id: string;
  title: string;
  creator_id: string;
  creator_name: string;
  score: number;
  matched_fields: string[];
  semantic_concepts: string[];
  reason: string;
};

type CreatorSimilarityResult = {
  creator_id: string;
  creator_name: string;
  source_creator_id: string | null;
  score: number;
  shared_genres: string[];
  featured_titles: { movie_id: string; title: string }[];
  reason: string;
};

export function v3SearchReadinessSummary(): JsonObject {
  return {
    v3_ai_search_enabled: true,
    natural_language_search: true,
    semantic_search: true,
    visual_similarity: true,
    creator_similarity: true,
    voice_search: true,
    recommendation_search: true,
    external_ai_calls: false
  };
}

export function v3SearchQuery(rawURL: string | undefined, authorizationHeader: string | undefined): JsonObject {
  requireIdentitySession(authorizationHeader);
  const query = queryValue(rawURL, "q");
  const intent = parseSearchIntent(query);
  const results = rankedSearch(query, intent, "natural_language", authorizationHeader);
  return {
    status: "ready",
    engine: "local_v3_ai_search",
    external_ai_calls: false,
    mode: "natural_language",
    query,
    interpreted_intent: intent,
    ranking_signals: rankingSignals(),
    results,
    suggestions: searchSuggestions(query, authorizationHeader),
    generated_at: nowISO()
  };
}

export function v3SemanticSearch(rawURL: string | undefined, authorizationHeader: string | undefined): JsonObject {
  requireIdentitySession(authorizationHeader);
  const query = queryValue(rawURL, "q");
  const intent = parseSearchIntent(query);
  return {
    status: "ready",
    engine: "local_v3_ai_search",
    external_ai_calls: false,
    mode: "semantic",
    query,
    semantic_vector: semanticConcepts(query),
    results: rankedSearch(query, intent, "semantic", authorizationHeader),
    generated_at: nowISO()
  };
}

export function v3VisualSimilarity(rawURL: string | undefined, authorizationHeader: string | undefined): JsonObject {
  requireIdentitySession(authorizationHeader);
  const movieID = queryValue(rawURL, "movie_id") || catalogMovies()[0]?.id || "";
  const source = movieByID(movieID) ?? catalogMovies()[0];
  const results = source ? catalogMovies()
    .filter((movie) => movie.id !== source.id)
    .map((movie) => visualSimilarityResult(source, movie))
    .sort((lhs, rhs) => rhs.score - lhs.score || lhs.title.localeCompare(rhs.title))
    .slice(0, 8) : [];
  return {
    status: "ready",
    engine: "local_v3_ai_search",
    external_ai_calls: false,
    mode: "visual_similarity",
    source_movie_id: source?.id ?? null,
    source_title: source?.title ?? null,
    visual_basis: ["genre_palette", "collection_world", "original_status", "premiere_state", "poster_backdrop_presence"],
    results,
    generated_at: nowISO()
  };
}

export function v3CreatorSimilarity(rawURL: string | undefined, authorizationHeader: string | undefined): JsonObject {
  requireIdentitySession(authorizationHeader);
  const creatorID = queryValue(rawURL, "creator_id") || catalogCreators()[0]?.id || "";
  const source = creatorByID(creatorID) ?? catalogCreators()[0];
  const sourceMovies = source ? moviesForCreator(source.id) : [];
  const results = catalogCreators()
    .filter((creator) => creator.id !== source?.id)
    .map((creator) => creatorSimilarityResult(source, sourceMovies, creator))
    .sort((lhs, rhs) => rhs.score - lhs.score || String(lhs.creator_name).localeCompare(String(rhs.creator_name)));
  return {
    status: "ready",
    engine: "local_v3_ai_search",
    external_ai_calls: false,
    mode: "creator_similarity",
    source_creator_id: source?.id ?? null,
    source_creator_name: source?.name ?? null,
    results,
    generated_at: nowISO()
  };
}

export function v3VoiceSearch(rawURL: string | undefined, authorizationHeader: string | undefined): JsonObject {
  requireIdentitySession(authorizationHeader);
  const transcript = queryValue(rawURL, "transcript") || queryValue(rawURL, "q");
  const normalized = normalizeVoiceTranscript(transcript);
  const intent = parseSearchIntent(normalized);
  return {
    status: "ready",
    engine: "local_v3_ai_search",
    external_ai_calls: false,
    mode: "voice",
    transcript,
    normalized_query: normalized,
    interpreted_intent: intent,
    results: rankedSearch(normalized, intent, "voice", authorizationHeader),
    generated_at: nowISO()
  };
}

export function v3RecommendationSearch(rawURL: string | undefined, authorizationHeader: string | undefined): JsonObject {
  requireIdentitySession(authorizationHeader);
  const query = queryValue(rawURL, "q");
  const personalized = v3PersonalizedHome(authorizationHeader) as { dynamic_collections?: JsonObject[]; smart_continue_watching?: JsonObject[]; personalized_home?: { primary_recommendations?: SearchResult[] } };
  const intent = parseSearchIntent(query);
  const results = rankedSearch(query, intent, "recommendation", authorizationHeader);
  return {
    status: "ready",
    engine: "local_v3_ai_search",
    external_ai_calls: false,
    mode: "recommendation",
    query,
    recommendation_context: {
      dynamic_collection_count: personalized.dynamic_collections?.length ?? 0,
      continue_watching_count: personalized.smart_continue_watching?.length ?? 0,
      personalized_recommendation_count: personalized.personalized_home?.primary_recommendations?.length ?? 0
    },
    results,
    generated_at: nowISO()
  };
}

function rankedSearch(query: string, intent: JsonObject, mode: SearchMode, authorizationHeader: string | undefined): SearchResult[] {
  const concepts = semanticConcepts(query);
  const personalized = v3PersonalizedHome(authorizationHeader) as { personalized_home?: { primary_recommendations?: SearchResult[] } };
  const personalizedIDs = new Set((personalized.personalized_home?.primary_recommendations ?? []).map((item) => item.movie_id));
  return catalogMovies()
    .map((movie) => {
      const matchedFields = matchedSearchFields(movie, query);
      const semanticMatches = movieConcepts(movie).filter((concept) => concepts.includes(concept));
      const textScore = matchedFields.length * 34 + (textEquals(movie.title, query) ? 90 : 0);
      const semanticScore = semanticMatches.length * 28;
      const intentScore = intentScoreFor(movie, intent);
      const personalScore = personalizedIDs.has(movie.id) ? 18 : 0;
      const modeScore = mode === "recommendation" ? personalScore * 1.4 : mode === "semantic" ? semanticScore * 0.4 : 0;
      return {
        movie_id: movie.id,
        title: movie.title,
        creator_id: movie.creator_id,
        creator_name: movie.creator_name,
        score: round(textScore + semanticScore + intentScore + personalScore + modeScore + baselineScore(movie)),
        matched_fields: matchedFields.length > 0 ? matchedFields : semanticMatches.map((item) => `semantic:${item}`),
        semantic_concepts: movieConcepts(movie).slice(0, 8),
        reason: searchReason(matchedFields, semanticMatches, personalizedIDs.has(movie.id), mode)
      };
    })
    .filter((item) => query.trim().length === 0 || item.matched_fields.length > 0 || item.score > 20)
    .sort((lhs, rhs) => rhs.score - lhs.score || lhs.title.localeCompare(rhs.title))
    .slice(0, 12);
}

function visualSimilarityResult(source: CatalogMovie, movie: CatalogMovie): SearchResult {
  const sharedGenres = intersection(source.genres, movie.genres);
  const sharedCollections = intersection(source.collection_ids, movie.collection_ids);
  const score = round(sharedGenres.length * 32
    + sharedCollections.length * 26
    + (source.is_original === movie.is_original ? 12 : 0)
    + (source.is_coming_soon === movie.is_coming_soon ? 8 : 0)
    + baselineScore(movie));
  return {
    movie_id: movie.id,
    title: movie.title,
    creator_id: movie.creator_id,
    creator_name: movie.creator_name,
    score,
    matched_fields: [...sharedGenres.map((genre) => `genre:${genre}`), ...sharedCollections.map((collection) => `collection:${collection}`)],
    semantic_concepts: movieConcepts(movie),
    reason: sharedGenres.length > 0 ? `Visual world match through ${sharedGenres.slice(0, 2).join(" / ")}` : "Closest local visual catalog match"
  };
}

function creatorSimilarityResult(source: CatalogCreator | undefined, sourceMovies: CatalogMovie[], creator: CatalogCreator): CreatorSimilarityResult {
  const targetMovies = moviesForCreator(creator.id);
  const sourceGenres = unique(sourceMovies.flatMap((movie) => movie.genres));
  const targetGenres = unique(targetMovies.flatMap((movie) => movie.genres));
  const sharedGenres = intersection(sourceGenres, targetGenres);
  const score = round(sharedGenres.length * 36 + targetMovies.length * 8 + creator.featured_movie_ids.length * 4);
  return {
    creator_id: creator.id,
    creator_name: creator.name,
    source_creator_id: source?.id ?? null,
    score,
    shared_genres: sharedGenres,
    featured_titles: targetMovies.map((movie) => ({ movie_id: movie.id, title: movie.title })),
    reason: sharedGenres.length > 0 ? `Shared ${sharedGenres.slice(0, 2).join(" / ")} audience` : "Adjacent creator catalog pattern"
  };
}

function parseSearchIntent(query: string): JsonObject {
  const words = tokenSet(query);
  return {
    wants_series: hasAny(words, ["series", "episode", "season", "episodes"]),
    wants_creator: hasAny(words, ["creator", "director", "showrunner", "filmmaker"]),
    wants_originals: hasAny(words, ["original", "highfive"]),
    wants_premiere: hasAny(words, ["premiere", "new", "upcoming", "soon"]),
    wants_mood: [...words].find((word) => ["mystery", "comfort", "cinematic", "creator"].includes(word)) ?? null
  };
}

function semanticConcepts(query: string): string[] {
  const words = tokenSet(query);
  const concepts = new Set<string>();
  for (const word of words) {
    concepts.add(word);
    for (const synonym of synonymsFor(word)) concepts.add(synonym);
  }
  return [...concepts];
}

function movieConcepts(movie: CatalogMovie): string[] {
  return unique([
    ...tokens(movie.title),
    ...tokens(movie.subtitle),
    ...tokens(movie.synopsis),
    ...movie.genres.map((genre) => genre.toLowerCase()),
    ...movie.collection_ids.map((collection) => collection.toLowerCase()),
    movie.creator_name.toLowerCase(),
    movie.is_original ? "original" : "catalog",
    movie.is_coming_soon ? "premiere" : "available"
  ]);
}

function matchedSearchFields(movie: CatalogMovie, query: string): string[] {
  if (!query.trim()) return ["personalized_default"];
  const fields: [string, string][] = [
    ["title", movie.title],
    ["subtitle", movie.subtitle],
    ["creator", movie.creator_name],
    ["genre", movie.genres.join(" ")],
    ["collection", movie.collection_ids.join(" ")],
    ["synopsis", movie.synopsis],
    ["semantic", movieConcepts(movie).join(" ")]
  ];
  return fields.filter(([, value]) => textIncludes(value, query)).map(([field]) => field);
}

function intentScoreFor(movie: CatalogMovie, intent: JsonObject): number {
  let score = 0;
  if (intent.wants_series && movie.duration.toLowerCase().includes("episode")) score += 26;
  if (intent.wants_creator && movie.genres.includes("Creator")) score += 24;
  if (intent.wants_originals && movie.is_original) score += 22;
  if (intent.wants_premiere && movie.is_coming_soon) score += 20;
  if (typeof intent.wants_mood === "string" && movieConcepts(movie).includes(intent.wants_mood)) score += 18;
  return score;
}

function searchSuggestions(query: string, authorizationHeader: string | undefined): string[] {
  const personalized = v3PersonalizedHome(authorizationHeader) as { taste_graph?: { nodes?: { label?: string }[] } };
  const graphLabels = personalized.taste_graph?.nodes?.map((node) => String(node.label ?? "")) ?? [];
  const base = [
    ...catalogMovies().map((movie) => movie.title),
    ...catalogMovies().flatMap((movie) => movie.genres),
    ...catalogCreators().map((creator) => creator.name),
    ...graphLabels
  ];
  return unique(base).filter((item) => !query || textIncludes(item, query)).slice(0, 10);
}

function searchReason(matchedFields: string[], semanticMatches: string[], personalized: boolean, mode: SearchMode): string {
  if (personalized && mode === "recommendation") return "Ranked from recommendation context";
  if (semanticMatches.length > 0) return `Semantic match on ${semanticMatches.slice(0, 3).join(", ")}`;
  if (matchedFields.length > 0) return `Matched ${matchedFields.slice(0, 3).join(", ")}`;
  return "Ranked from local catalog intelligence";
}

function normalizeVoiceTranscript(transcript: string): string {
  return transcript
    .toLowerCase()
    .replace(/\b(high five|highfive|hey highfive|find me|show me|search for|play)\b/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function synonymsFor(word: string): string[] {
  const map: Record<string, string[]> = {
    scary: ["mystery", "crime"],
    suspense: ["mystery", "crime"],
    cozy: ["comfort", "drama"],
    emotional: ["drama", "comfort"],
    filmmaker: ["creator", "director"],
    director: ["creator", "filmmaker"],
    episodes: ["series", "season"],
    new: ["premiere", "upcoming"],
    exclusive: ["original", "highfive"]
  };
  return map[word] ?? [];
}

function baselineScore(movie: CatalogMovie): number {
  return round((movie.progress ?? 0) * 14 + (movie.is_original ? 10 : 0) + movie.collection_ids.length * 3);
}

function rankingSignals(): string[] {
  return ["natural_language", "semantic_concepts", "visual_similarity", "creator_similarity", "voice_transcript", "taste_graph", "watch_history", "dynamic_collections"];
}

function queryValue(rawURL: string | undefined, key: string): string {
  const url = new URL(rawURL ?? "/", "http" + "://127.0.0.1");
  return (url.searchParams.get(key) ?? "").trim();
}

function catalogMovies(): CatalogMovie[] {
  return governedCatalogSeed(catalogSeed).movies;
}

function catalogCreators(): CatalogCreator[] {
  return governedCatalogSeed(catalogSeed).creators;
}

function moviesForCreator(creatorID: string): CatalogMovie[] {
  return catalogMovies().filter((movie) => movie.creator_id === creatorID);
}

function movieByID(id: string): CatalogMovie | undefined {
  return catalogMovies().find((movie) => movie.id === id);
}

function creatorByID(id: string): CatalogCreator | undefined {
  return catalogCreators().find((creator) => creator.id === id);
}

function tokens(value: string): string[] {
  return value.toLowerCase().split(/[^a-z0-9]+/).filter(Boolean);
}

function tokenSet(value: string): Set<string> {
  return new Set(tokens(value));
}

function hasAny(values: Set<string>, candidates: string[]): boolean {
  return candidates.some((candidate) => values.has(candidate));
}

function intersection(lhs: string[], rhs: string[]): string[] {
  const rhsSet = new Set(rhs.map((item) => item.toLowerCase()));
  return unique(lhs.filter((item) => rhsSet.has(item.toLowerCase())));
}

function unique(values: string[]): string[] {
  return [...new Set(values.filter((value) => value.length > 0))];
}

function textIncludes(value: string, term: string): boolean {
  return value.toLocaleLowerCase().includes(term.toLocaleLowerCase());
}

function textEquals(value: string, term: string): boolean {
  return value.localeCompare(term, undefined, { sensitivity: "accent" }) === 0;
}

function round(value: number): number {
  return Math.round(value * 100) / 100;
}

function nowISO(): string {
  return new Date().toISOString();
}
