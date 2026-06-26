import { catalogSeed, type CatalogMovie } from "../catalog/catalogSeed.js";
import { recordAnalyticsEvent } from "./analytics.js";
import { viewerLibraryRecommendationContext, type ViewerLibraryRecommendationContext } from "./library.js";
import { governedCatalogSeed } from "./publishing.js";

type Mood = "cinematic" | "comfort" | "mystery" | "creator" | "premiere";

type TasteProfile = {
  profile_id: string;
  top_genres: { genre: string; weight: number }[];
  creator_affinity: { creator_id: string; creator_name: string; weight: number }[];
  mood_vector: { mood: Mood; weight: number }[];
  signals: {
    saved_count: number;
    progress_count: number;
    completed_count: number;
    offline_count: number;
  };
};

type PersonalizedRecommendation = {
  movie_id: string;
  title: string;
  score: number;
  reason: string;
  mood: Mood;
  creator_affinity: number;
  genre_prediction: string[];
};

type PersonalizedRail = {
  id: string;
  title: string;
  subtitle: string;
  recommendations: PersonalizedRecommendation[];
};

type SearchRanking = {
  movie_id: string;
  title: string;
  score: number;
  matched_fields: string[];
  reason: string;
};

export function aiDiscoveryHome(authorizationHeader: string | undefined) {
  const context = safeRecommendationContext(authorizationHeader);
  const tasteProfile = buildTasteProfile(context);
  const recommendations = rankedRecommendations(tasteProfile, context);
  const continueWatching = continueWatchingIntelligence(tasteProfile, context);
  const personalizedRails: PersonalizedRail[] = [
    {
      id: "because-you-watch",
      title: "Because You Watch",
      subtitle: reasonFromProfile(tasteProfile),
      recommendations: recommendations.slice(0, 8)
    },
    {
      id: "creator-affinity",
      title: "Creator Affinity",
      subtitle: creatorSubtitle(tasteProfile),
      recommendations: recommendations.filter((item) => item.creator_affinity > 0).slice(0, 8)
    },
    {
      id: "mood-discovery",
      title: "Mood Discovery",
      subtitle: `${tasteProfile.mood_vector[0]?.mood ?? "cinematic"}-leaning picks from your local signals`,
      recommendations: moodRecommendations(tasteProfile, recommendations)
    }
  ];

  recordAnalyticsEvent("search", {
    query: "personalized_home",
    result_count: recommendations.length,
    top_genre: tasteProfile.top_genres[0]?.genre ?? "Cinema"
  }, { authorizationHeader, source: "ai_discovery_home" });

  return {
    status: "ready",
    engine: "local_ai_discovery_v1",
    external_ai_calls: false,
    personalized_home: true,
    taste_profile: tasteProfile,
    continue_watching_intelligence: continueWatching,
    recommendations,
    personalized_rails: personalizedRails,
    generated_at: nowISO()
  };
}

export function aiDiscoverySearch(rawURL: string | undefined, authorizationHeader: string | undefined) {
  const query = queryValue(rawURL, "q");
  const context = safeRecommendationContext(authorizationHeader);
  const tasteProfile = buildTasteProfile(context);
  const ranked = searchRankings(query, tasteProfile);
  recordAnalyticsEvent("search", {
    query,
    result_count: ranked.length,
    ranking_model: "local_ai_discovery_v1"
  }, { authorizationHeader, source: "ai_discovery_search" });
  return {
    status: "ready",
    engine: "local_ai_discovery_v1",
    query,
    ranking_signals: ["title", "creator", "genre", "collection", "synopsis", "taste_profile", "watch_history"],
    results: ranked,
    suggestions: searchSuggestions(query, tasteProfile),
    generated_at: nowISO()
  };
}

export function aiDiscoveryMood(rawURL: string | undefined, authorizationHeader: string | undefined) {
  const requestedMood = moodFrom(queryValue(rawURL, "mood"));
  const context = safeRecommendationContext(authorizationHeader);
  const tasteProfile = buildTasteProfile(context);
  const recommendations = rankedRecommendations(tasteProfile, context)
    .filter((item) => item.mood === requestedMood || item.genre_prediction.some((genre) => moodGenres(requestedMood).includes(genre)))
    .slice(0, 8);
  return {
    status: "ready",
    engine: "local_ai_discovery_v1",
    mood: requestedMood,
    recommendations: recommendations.length > 0 ? recommendations : rankedRecommendations(tasteProfile, context).slice(0, 6),
    generated_at: nowISO()
  };
}

export function aiDiscoveryReadinessSummary() {
  return {
    ai_discovery_enabled: true,
    external_ai_calls: false,
    personalized_recommendations: true,
    watch_history_learning: true,
    taste_profiles: true,
    mood_discovery: true,
    creator_affinity: true,
    genre_prediction: true,
    continue_watching_intelligence: true,
    search_ranking_improvements: true
  };
}

function buildTasteProfile(context: ViewerLibraryRecommendationContext | null): TasteProfile {
  const signalIDs = new Set([
    ...(context?.saved_movie_ids ?? []),
    ...(context?.progress_movie_ids ?? []),
    ...(context?.completed_movie_ids ?? []),
    ...(context?.offline_movie_ids ?? [])
  ]);
  const signalMovies = [...signalIDs].map(movieByID).filter(isMovie);
  const fallbackMovies = signalMovies.length > 0 ? signalMovies : discoveryMovies().filter((movie) => movie.progress !== null || movie.is_original);
  const genreWeights = new Map<string, number>();
  const creatorWeights = new Map<string, { creator_name: string; weight: number }>();
  const moodWeights = new Map<Mood, number>();

  for (const movie of fallbackMovies) {
    const progressWeight = Math.max(movie.progress ?? 0.35, 0.25);
    for (const genre of movie.genres) {
      genreWeights.set(genre, (genreWeights.get(genre) ?? 0) + progressWeight + (context?.completed_movie_ids.includes(movie.id) ? 0.4 : 0));
    }
    const creator = creatorWeights.get(movie.creator_id) ?? { creator_name: movie.creator_name, weight: 0 };
    creator.weight += progressWeight + (context?.saved_movie_ids.includes(movie.id) ? 0.35 : 0);
    creatorWeights.set(movie.creator_id, creator);
    const mood = moodForMovie(movie);
    moodWeights.set(mood, (moodWeights.get(mood) ?? 0) + progressWeight + (movie.is_original ? 0.2 : 0));
  }

  return {
    profile_id: context?.user_id ?? "anonymous-local-profile",
    top_genres: rankedMap(genreWeights).map(([genre, weight]) => ({ genre, weight })),
    creator_affinity: [...creatorWeights.entries()]
      .map(([creator_id, value]) => ({ creator_id, creator_name: value.creator_name, weight: round(value.weight) }))
      .sort((lhs, rhs) => rhs.weight - lhs.weight || lhs.creator_name.localeCompare(rhs.creator_name)),
    mood_vector: rankedMap(moodWeights).map(([mood, weight]) => ({ mood: mood as Mood, weight })),
    signals: {
      saved_count: context?.saved_movie_ids.length ?? 0,
      progress_count: context?.progress_movie_ids.length ?? 0,
      completed_count: context?.completed_movie_ids.length ?? 0,
      offline_count: context?.offline_movie_ids.length ?? 0
    }
  };
}

function rankedRecommendations(profile: TasteProfile, context: ViewerLibraryRecommendationContext | null): PersonalizedRecommendation[] {
  const excluded = new Set(context?.completed_movie_ids ?? []);
  return discoveryMovies()
    .filter((movie) => !excluded.has(movie.id))
    .map((movie) => recommendationFor(movie, profile, context))
    .sort((lhs, rhs) => rhs.score - lhs.score || lhs.title.localeCompare(rhs.title));
}

function recommendationFor(movie: CatalogMovie, profile: TasteProfile, context: ViewerLibraryRecommendationContext | null): PersonalizedRecommendation {
  const genreWeight = movie.genres.reduce((total, genre) => total + (profile.top_genres.find((item) => item.genre === genre)?.weight ?? 0), 0);
  const creatorWeight = profile.creator_affinity.find((item) => item.creator_id === movie.creator_id)?.weight ?? 0;
  const mood = moodForMovie(movie);
  const moodWeight = profile.mood_vector.find((item) => item.mood === mood)?.weight ?? 0;
  const progressBoost = context?.progress_movie_ids.includes(movie.id) ? 24 : 0;
  const savedBoost = context?.saved_movie_ids.includes(movie.id) ? 12 : 0;
  const score = round(genreWeight * 18 + creatorWeight * 22 + moodWeight * 10 + progressBoost + savedBoost + trendingScore(movie));
  return {
    movie_id: movie.id,
    title: movie.title,
    score,
    reason: recommendationReason(movie, profile, creatorWeight, genreWeight),
    mood,
    creator_affinity: round(creatorWeight),
    genre_prediction: movie.genres.slice(0, 3)
  };
}

function continueWatchingIntelligence(profile: TasteProfile, context: ViewerLibraryRecommendationContext | null) {
  const progressIDs = context?.progress_movie_ids ?? discoveryMovies().filter((movie) => (movie.progress ?? 0) > 0).map((movie) => movie.id);
  return progressIDs
    .map(movieByID)
    .filter(isMovie)
    .filter((movie) => (movie.progress ?? 0.4) > 0 && (movie.progress ?? 0.4) < 0.95)
    .map((movie) => ({
      movie_id: movie.id,
      title: movie.title,
      resume_percent: Math.round((movie.progress ?? 0.4) * 100),
      next_best_action: movie.duration.includes("episodes") ? "continue next episode" : "resume feature",
      reason: recommendationFor(movie, profile, context).reason
    }));
}

function searchRankings(query: string, profile: TasteProfile): SearchRanking[] {
  return discoveryMovies()
    .map((movie) => {
      const matchedFields = matchedSearchFields(movie, query);
      const profileScore = recommendationFor(movie, profile, null).score / 12;
      const textScore = matchedFields.length * 40 + (textEquals(movie.title, query) ? 90 : 0);
      return {
        movie_id: movie.id,
        title: movie.title,
        score: round(textScore + profileScore),
        matched_fields: matchedFields,
        reason: matchedFields.length > 0 ? `Matched ${matchedFields.join(", ")}` : "Ranked by taste profile"
      };
    })
    .filter((item) => query.trim().length === 0 || item.matched_fields.length > 0)
    .sort((lhs, rhs) => rhs.score - lhs.score || lhs.title.localeCompare(rhs.title))
    .slice(0, 12);
}

function moodRecommendations(profile: TasteProfile, recommendations: PersonalizedRecommendation[]): PersonalizedRecommendation[] {
  const mood = profile.mood_vector[0]?.mood ?? "cinematic";
  const direct = recommendations.filter((item) => item.mood === mood).slice(0, 8);
  return direct.length > 0 ? direct : recommendations.slice(0, 8);
}

function searchSuggestions(query: string, profile: TasteProfile): string[] {
  const base = [
    ...profile.top_genres.map((item) => item.genre),
    ...profile.creator_affinity.map((item) => item.creator_name),
    ...discoveryMovies().map((movie) => movie.title)
  ];
  return [...new Set(base)].filter((item) => !query || textIncludes(item, query)).slice(0, 8);
}

function recommendationReason(movie: CatalogMovie, profile: TasteProfile, creatorWeight: number, genreWeight: number): string {
  if (creatorWeight > 0) return `Creator affinity with ${movie.creator_name}`;
  if (genreWeight > 0) return `Predicted from ${movie.genres.slice(0, 2).join(" / ")}`;
  if (movie.is_original) return "HighFive Original matched to cinematic taste";
  return "Popular in the local catalog";
}

function reasonFromProfile(profile: TasteProfile): string {
  const genres = profile.top_genres.slice(0, 2).map((item) => item.genre).join(" / ");
  return genres ? `Personalized from ${genres}` : "Personalized from local viewing signals";
}

function creatorSubtitle(profile: TasteProfile): string {
  const creator = profile.creator_affinity[0]?.creator_name;
  return creator ? `More from creators like ${creator}` : "Creator-led recommendations";
}

function matchedSearchFields(movie: CatalogMovie, query: string): string[] {
  if (!query.trim()) return ["taste_profile"];
  const fields: [string, string][] = [
    ["title", movie.title],
    ["subtitle", movie.subtitle],
    ["creator", movie.creator_name],
    ["genre", movie.genres.join(" ")],
    ["collection", movie.collection_ids.join(" ")],
    ["synopsis", movie.synopsis]
  ];
  return fields.filter(([, value]) => textIncludes(value, query)).map(([field]) => field);
}

function moodForMovie(movie: CatalogMovie): Mood {
  if (movie.collection_ids.includes("creator-published") || movie.genres.includes("Creator")) return "creator";
  if (movie.genres.includes("Mystery")) return "mystery";
  if (movie.genres.includes("Premiere") || movie.is_coming_soon) return "premiere";
  if (movie.genres.includes("Drama")) return "comfort";
  return "cinematic";
}

function moodFrom(value: string): Mood {
  if (value === "comfort" || value === "mystery" || value === "creator" || value === "premiere") return value;
  return "cinematic";
}

function moodGenres(mood: Mood): string[] {
  switch (mood) {
  case "comfort":
    return ["Drama"];
  case "mystery":
    return ["Mystery", "Series"];
  case "creator":
    return ["Creator", "Documentary"];
  case "premiere":
    return ["Premiere"];
  case "cinematic":
    return ["Drama", "Documentary", "Series"];
  }
}

function safeRecommendationContext(authorizationHeader: string | undefined): ViewerLibraryRecommendationContext | null {
  try {
    return viewerLibraryRecommendationContext(authorizationHeader);
  } catch {
    return null;
  }
}

function queryValue(rawURL: string | undefined, key: string): string {
  const url = new URL(rawURL ?? "/", "http" + "://127.0.0.1");
  return (url.searchParams.get(key) ?? "").trim();
}

function discoveryMovies(): CatalogMovie[] {
  return governedCatalogSeed(catalogSeed).movies;
}

function movieByID(id: string): CatalogMovie | undefined {
  return discoveryMovies().find((movie) => movie.id === id);
}

function isMovie(value: CatalogMovie | undefined): value is CatalogMovie {
  return Boolean(value);
}

function rankedMap(values: Map<string, number>): [string, number][] {
  return [...values.entries()]
    .map(([key, value]) => [key, round(value)] as [string, number])
    .sort((lhs, rhs) => rhs[1] - lhs[1] || lhs[0].localeCompare(rhs[0]))
    .slice(0, 8);
}

function trendingScore(movie: CatalogMovie): number {
  return round((movie.progress ?? 0) * 25 + (movie.is_original ? 8 : 0) + (movie.is_downloaded ? 4 : 0) + movie.collection_ids.length * 2);
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
