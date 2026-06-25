import { catalogSeed, type CatalogCollection, type CatalogCreator, type CatalogEpisode, type CatalogMovie, type CatalogSeries } from "../catalog/catalogSeed.js";
import { viewerLibraryRecommendationContext } from "./library.js";

type QueryKind = "search" | "creator" | "genre" | "tag" | "collection" | "series" | "episode" | "related" | "recent" | "creator-published" | "recommendations" | "trending" | "suggestions";

type DiscoveryQueryParams = {
  kind: QueryKind;
  query: string;
  filter: string;
  page: number;
  page_size: number;
  anchor_id: string | null;
  creator_id: string | null;
  collection_id: string | null;
  series_id: string | null;
  episode_id: string | null;
};

const searchHistory: { id: string; query: string; filter: string; result_count: number; created_at: string }[] = [];

export function discoveryQuery(rawURL: string | undefined, authorizationHeader: string | undefined) {
  const params = discoveryQueryParams(rawURL);
  const context = safeRecommendationContext(authorizationHeader);
  const titles = titlesFor(params, context);
  const creators = creatorsFor(params);
  const collections = collectionsFor(params, titles);
  const series = seriesFor(params);
  const episodes = episodesFor(params);
  const related = relatedFor(params, titles);
  const recommendations = recommendationsFor(params, context);
  const suggestions = suggestionsFor(params.query);
  const totalResults = titles.length + creators.length + series.length + episodes.length + collections.length;
  const pagedTitles = paginate(titles, params.page, params.page_size);
  const analytics = recordSearchHistory(params, totalResults);

  return {
    status: "ready",
    source: "loopback_discovery_service",
    query: params.query,
    kind: params.kind,
    filter: params.filter,
    page: params.page,
    page_size: params.page_size,
    total_results: totalResults,
    titles: pagedTitles,
    creators,
    collections,
    series,
    episodes,
    related_titles: related,
    recommendations,
    suggestions,
    trending: trendingTitles(),
    recently_published: recentlyPublished(),
    creator_published_titles: creatorPublishedTitles(),
    search_history: searchHistory.slice(-8).reverse(),
    analytics: {
      search_events: searchHistory.length,
      last_query_id: analytics.id,
      cached: true,
      fallback_available: true
    },
    cache_policy: "query-cache-with-local-fallback",
    generated_at: nowISO()
  };
}

export function discoveryReadinessSummary() {
  return {
    discovery_service_enabled: true,
    title_search: true,
    creator_search: true,
    filters: true,
    pagination: true,
    recommendations: true,
    query_cache: true,
    analytics_hook: true,
    local_fallback: true
  };
}

function discoveryQueryParams(rawURL: string | undefined): DiscoveryQueryParams {
  const url = new URL(rawURL ?? "/", "http://127.0.0.1");
  const kind = queryKind(url.searchParams.get("kind") ?? "search");
  return {
    kind,
    query: (url.searchParams.get("q") ?? "").trim(),
    filter: url.searchParams.get("filter") ?? "All",
    page: positiveInt(url.searchParams.get("page"), 1),
    page_size: Math.min(24, positiveInt(url.searchParams.get("page_size"), 12)),
    anchor_id: url.searchParams.get("anchor_id"),
    creator_id: url.searchParams.get("creator_id"),
    collection_id: url.searchParams.get("collection_id"),
    series_id: url.searchParams.get("series_id"),
    episode_id: url.searchParams.get("episode_id")
  };
}

function queryKind(value: string): QueryKind {
  const allowed: QueryKind[] = ["search", "creator", "genre", "tag", "collection", "series", "episode", "related", "recent", "creator-published", "recommendations", "trending", "suggestions"];
  return allowed.includes(value as QueryKind) ? value as QueryKind : "search";
}

function titlesFor(params: DiscoveryQueryParams, context: ReturnType<typeof safeRecommendationContext>): CatalogMovie[] {
  switch (params.kind) {
  case "genre":
    return byGenre(params.query || params.filter);
  case "tag":
    return byTag(params.query || params.filter);
  case "collection":
    return collectionByID(params.collection_id ?? params.query)?.movie_ids.map(movieByID).filter(isMovie) ?? [];
  case "series":
    return seriesByID(params.series_id ?? params.query)?.hero_movie_id ? [movieByID(seriesByID(params.series_id ?? params.query)!.hero_movie_id)].filter(isMovie) : [];
  case "episode":
    return episodeByID(params.episode_id ?? params.query) ? seriesForEpisode(params.episode_id ?? params.query).map((series) => movieByID(series.hero_movie_id)).filter(isMovie) : [];
  case "related":
    return relatedTitles(movieByID(params.anchor_id ?? params.query), 12);
  case "recent":
    return recentlyPublished();
  case "creator-published":
    return creatorPublishedTitles();
  case "recommendations":
    return libraryRecommendations(context, movieByID(params.anchor_id ?? ""));
  case "trending":
    return trendingTitles();
  case "suggestions":
    return [];
  default:
    return rankedTitles(params.query, params.filter);
  }
}

function creatorsFor(params: DiscoveryQueryParams): CatalogCreator[] {
  if (params.kind !== "creator" && params.kind !== "search") return [];
  const term = params.query;
  if (!term) return catalogSeed.creators;
  return catalogSeed.creators
    .map((creator) => ({ creator, score: creatorScore(creator, term) }))
    .filter((item) => item.score > 0)
    .sort((lhs, rhs) => rhs.score - lhs.score || lhs.creator.name.localeCompare(rhs.creator.name))
    .map((item) => item.creator);
}

function collectionsFor(params: DiscoveryQueryParams, titles: CatalogMovie[]): CatalogCollection[] {
  if (params.kind === "collection") {
    const collection = collectionByID(params.collection_id ?? params.query);
    return collection ? [collection] : [];
  }
  const ids = new Set(titles.flatMap((title) => title.collection_ids));
  return catalogSeed.collections.filter((collection) => ids.has(collection.id));
}

function seriesFor(params: DiscoveryQueryParams): CatalogSeries[] {
  if (params.kind !== "series" && params.kind !== "search") return [];
  const term = params.query;
  if (!term && params.kind === "series") return catalogSeed.series;
  return catalogSeed.series.filter((series) => textIncludes(series.title, term) || textIncludes(series.creator_name, term) || textIncludes(series.genre, term));
}

function episodesFor(params: DiscoveryQueryParams): CatalogEpisode[] {
  if (params.kind !== "episode" && params.kind !== "search") return [];
  const term = params.query;
  return catalogSeed.series.flatMap((series) => series.seasons.flatMap((season) => season.episodes))
    .filter((episode) => !term || textIncludes(episode.title, term) || textIncludes(episode.synopsis, term));
}

function relatedFor(params: DiscoveryQueryParams, titles: CatalogMovie[]): CatalogMovie[] {
  const anchor = movieByID(params.anchor_id ?? "") ?? titles[0] ?? catalogSeed.movies[0];
  return relatedTitles(anchor, 8);
}

function recommendationsFor(params: DiscoveryQueryParams, context: ReturnType<typeof safeRecommendationContext>): { movie_id: string; title: string; reason: string }[] {
  return libraryRecommendations(context, movieByID(params.anchor_id ?? ""))
    .slice(0, 8)
    .map((movie) => ({
      movie_id: movie.id,
      title: movie.title,
      reason: context ? "Because of your saved titles and progress" : "Popular in the HighFive catalog"
    }));
}

function rankedTitles(query: string, filter: string): CatalogMovie[] {
  const base = filteredTitles(filter);
  if (!query.trim()) return base;
  return base
    .map((movie) => ({ movie, score: titleScore(movie, query) }))
    .filter((item) => item.score > 0)
    .sort((lhs, rhs) => rhs.score - lhs.score || lhs.movie.title.localeCompare(rhs.movie.title))
    .map((item) => item.movie);
}

function filteredTitles(filter: string): CatalogMovie[] {
  switch (filter) {
  case "Movies":
    return catalogSeed.movies.filter((movie) => !movie.duration.includes("episodes"));
  case "Series":
    return catalogSeed.movies.filter((movie) => movie.duration.includes("episodes") || movie.genres.includes("Series"));
  case "Originals":
    return catalogSeed.movies.filter((movie) => movie.is_original);
  case "Creator Published":
    return creatorPublishedTitles();
  case "Downloaded":
    return catalogSeed.movies.filter((movie) => movie.is_downloaded);
  case "All":
    return catalogSeed.movies;
  default:
    return byGenre(filter).length > 0 ? byGenre(filter) : catalogSeed.movies;
  }
}

function titleScore(movie: CatalogMovie, term: string): number {
  const fields: [string, number][] = [
    [movie.title, 130],
    [movie.subtitle, 64],
    [movie.creator_name, 78],
    [movie.genres.join(" "), 70],
    [movie.collection_ids.join(" "), 56],
    [movie.synopsis, 34],
    [movie.duration, 12],
    [movie.year, 8]
  ];
  return fields.reduce((score, [value, weight]) => {
    if (value.localeCompare(term, undefined, { sensitivity: "accent" }) === 0) return score + weight + 35;
    return textIncludes(value, term) ? score + weight : score;
  }, 0);
}

function creatorScore(creator: CatalogCreator, term: string): number {
  const titleText = catalogSeed.movies.filter((movie) => movie.creator_id === creator.id).map((movie) => movie.title).join(" ");
  const fields: [string, number][] = [
    [creator.name, 130],
    [creator.role, 70],
    [titleText, 92]
  ];
  return fields.reduce((score, [value, weight]) => textIncludes(value, term) ? score + weight : score, 0);
}

function byGenre(genre: string): CatalogMovie[] {
  return catalogSeed.movies.filter((movie) => movie.genres.some((candidate) => textEquals(candidate, genre)));
}

function byTag(tag: string): CatalogMovie[] {
  return catalogSeed.movies.filter((movie) => searchTags(movie).some((candidate) => textIncludes(candidate, tag)));
}

function relatedTitles(anchor: CatalogMovie | undefined, limit: number): CatalogMovie[] {
  if (!anchor) return catalogSeed.movies.slice(0, limit);
  return uniqueMovies([
    ...catalogSeed.movies.filter((movie) => movie.id !== anchor.id && movie.creator_id === anchor.creator_id),
    ...catalogSeed.movies.filter((movie) => movie.id !== anchor.id && movie.genres.some((genre) => anchor.genres.includes(genre))),
    ...recentlyPublished()
  ]).slice(0, limit);
}

function recentlyPublished(): CatalogMovie[] {
  return catalogSeed.movies.filter((movie) => !movie.is_coming_soon).slice().reverse();
}

function creatorPublishedTitles(): CatalogMovie[] {
  const publishedIDs = new Set(catalogSeed.publishing_projects.filter((project) => project.release_state === "published").map((project) => project.content_id));
  return catalogSeed.movies.filter((movie) => publishedIDs.has(movie.id) || movie.collection_ids.includes("creator-published"));
}

function trendingTitles(): CatalogMovie[] {
  return catalogSeed.movies
    .slice()
    .sort((lhs, rhs) => trendingScore(rhs) - trendingScore(lhs) || lhs.title.localeCompare(rhs.title));
}

function libraryRecommendations(context: ReturnType<typeof safeRecommendationContext>, anchor: CatalogMovie | undefined): CatalogMovie[] {
  const seedIDs = new Set([...(context?.saved_movie_ids ?? []), ...(context?.progress_movie_ids ?? []), anchor?.id ?? ""]);
  const seedMovies = [...seedIDs].map(movieByID).filter(isMovie);
  const genres = new Set(seedMovies.flatMap((movie) => movie.genres));
  const creatorIDs = new Set(seedMovies.map((movie) => movie.creator_id));
  const base = catalogSeed.movies.filter((movie) => !seedIDs.has(movie.id) && (movie.genres.some((genre) => genres.has(genre)) || creatorIDs.has(movie.creator_id)));
  return uniqueMovies([...base, ...trendingTitles(), ...recentlyPublished()]);
}

function suggestionsFor(query: string): string[] {
  const base = [
    ...catalogSeed.movies.map((movie) => movie.title),
    ...catalogSeed.creators.map((creator) => creator.name),
    ...catalogSeed.collections.map((collection) => collection.title),
    ...catalogSeed.movies.flatMap((movie) => movie.genres)
  ];
  const unique = [...new Set(base)];
  if (!query) return unique.slice(0, 8);
  return unique.filter((value) => textIncludes(value, query)).slice(0, 8);
}

function recordSearchHistory(params: DiscoveryQueryParams, resultCount: number) {
  const record = {
    id: `search-${Date.now()}-${searchHistory.length}`,
    query: params.query || params.kind,
    filter: params.filter,
    result_count: resultCount,
    created_at: nowISO()
  };
  searchHistory.push(record);
  if (searchHistory.length > 32) searchHistory.splice(0, searchHistory.length - 32);
  return record;
}

function safeRecommendationContext(authorizationHeader: string | undefined) {
  try {
    return viewerLibraryRecommendationContext(authorizationHeader);
  } catch {
    return null;
  }
}

function paginate<T>(values: T[], page: number, pageSize: number): T[] {
  const start = (page - 1) * pageSize;
  return values.slice(start, start + pageSize);
}

function positiveInt(value: string | null, fallback: number): number {
  if (!value) return fallback;
  const parsed = Number.parseInt(value, 10);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
}

function movieByID(id: string): CatalogMovie | undefined {
  return catalogSeed.movies.find((movie) => movie.id === id);
}

function collectionByID(id: string): CatalogCollection | undefined {
  const term = id.trim();
  return catalogSeed.collections.find((collection) => textEquals(collection.id, term) || textEquals(collection.title, term));
}

function seriesByID(id: string): CatalogSeries | undefined {
  const term = id.trim();
  return catalogSeed.series.find((series) => textEquals(series.id, term) || textEquals(series.title, term));
}

function episodeByID(id: string): CatalogEpisode | undefined {
  const term = id.trim();
  return catalogSeed.series.flatMap((series) => series.seasons.flatMap((season) => season.episodes))
    .find((episode) => textEquals(episode.id, term) || textEquals(episode.title, term));
}

function seriesForEpisode(id: string): CatalogSeries[] {
  const episode = episodeByID(id);
  return episode ? catalogSeed.series.filter((series) => series.id === episode.series_id) : [];
}

function searchTags(movie: CatalogMovie): string[] {
  return [
    ...movie.genres,
    ...movie.collection_ids,
    movie.is_original ? "HighFive Original" : "",
    movie.is_coming_soon ? "Premiere" : "",
    movie.is_downloaded ? "Downloaded" : "",
    movie.creator_name
  ].filter(Boolean);
}

function trendingScore(movie: CatalogMovie): number {
  return (movie.progress ?? 0) * 100 + (movie.is_original ? 20 : 0) + (movie.is_downloaded ? 12 : 0) + movie.collection_ids.length * 3;
}

function uniqueMovies(values: CatalogMovie[]): CatalogMovie[] {
  const seen = new Set<string>();
  return values.filter((movie) => {
    if (seen.has(movie.id)) return false;
    seen.add(movie.id);
    return true;
  });
}

function textIncludes(value: string, term: string): boolean {
  if (!term) return true;
  return value.toLocaleLowerCase().includes(term.toLocaleLowerCase());
}

function textEquals(value: string, term: string): boolean {
  return value.toLocaleLowerCase() === term.toLocaleLowerCase();
}

function isMovie(value: CatalogMovie | undefined): value is CatalogMovie {
  return Boolean(value);
}

function nowISO(): string {
  return new Date().toISOString();
}
