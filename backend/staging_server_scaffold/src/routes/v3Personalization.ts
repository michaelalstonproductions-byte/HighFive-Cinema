import type { JsonObject } from "../contracts.js";
import { aiDiscoveryHome, aiDiscoveryMood } from "./aiDiscovery.js";
import { requireIdentitySession, type IdentitySession } from "./identity.js";

type WeightedItem = {
  genre?: string;
  creator_id?: string;
  creator_name?: string;
  mood?: string;
  weight: number;
};

type Recommendation = {
  movie_id: string;
  title: string;
  score: number;
  reason: string;
  mood: string;
  creator_affinity: number;
  genre_prediction: string[];
};

type ContinueWatchingItem = {
  movie_id: string;
  title: string;
  resume_percent: number;
  next_best_action: string;
  reason: string;
};

type PersonalizationBase = {
  taste_profile: {
    profile_id: string;
    top_genres: WeightedItem[];
    creator_affinity: WeightedItem[];
    mood_vector: WeightedItem[];
    signals: Record<string, number>;
  };
  recommendations: Recommendation[];
  continue_watching_intelligence: ContinueWatchingItem[];
};

export function v3PersonalizationReadinessSummary(): JsonObject {
  return {
    v3_personalization_enabled: true,
    personalized_home: true,
    taste_graph: true,
    mood_engine: true,
    behavior_learning: true,
    smart_continue_watching: true,
    dynamic_collections: true,
    adaptive_discovery: true,
    external_ai_calls: false
  };
}

export function v3PersonalizedHome(authorizationHeader: string | undefined): JsonObject {
  const session = requireV3PersonalizationSession(authorizationHeader);
  const base = personalizationBase(authorizationHeader);
  const tasteGraph = buildTasteGraph(base);
  const moodEngine = buildMoodEngine(base, authorizationHeader);
  return {
    status: "ready",
    engine: "local_v3_personalization_platform",
    user_id: session.user_id,
    external_ai_calls: false,
    personalized_home: {
      hero_title: heroTitle(base),
      top_signal: topSignal(base),
      rails: buildDynamicCollections(base),
      primary_recommendations: base.recommendations.slice(0, 8)
    },
    taste_graph: tasteGraph,
    mood_engine: moodEngine,
    behavior_learning: buildBehaviorLearning(base),
    smart_continue_watching: buildSmartContinueWatching(base),
    dynamic_collections: buildDynamicCollections(base),
    adaptive_discovery: buildAdaptiveDiscovery(base),
    generated_at: nowISO()
  };
}

export function v3TasteGraph(authorizationHeader: string | undefined): JsonObject {
  requireV3PersonalizationSession(authorizationHeader);
  const base = personalizationBase(authorizationHeader);
  return {
    status: "ready",
    engine: "local_v3_personalization_platform",
    taste_graph: buildTasteGraph(base),
    behavior_learning: buildBehaviorLearning(base),
    generated_at: nowISO()
  };
}

export function v3MoodEngine(authorizationHeader: string | undefined): JsonObject {
  requireV3PersonalizationSession(authorizationHeader);
  const base = personalizationBase(authorizationHeader);
  return {
    status: "ready",
    engine: "local_v3_personalization_platform",
    mood_engine: buildMoodEngine(base, authorizationHeader),
    generated_at: nowISO()
  };
}

export function v3AdaptiveDiscovery(authorizationHeader: string | undefined): JsonObject {
  requireV3PersonalizationSession(authorizationHeader);
  const base = personalizationBase(authorizationHeader);
  return {
    status: "ready",
    engine: "local_v3_personalization_platform",
    adaptive_discovery: buildAdaptiveDiscovery(base),
    dynamic_collections: buildDynamicCollections(base),
    generated_at: nowISO()
  };
}

function requireV3PersonalizationSession(authorizationHeader: string | undefined): IdentitySession {
  return requireIdentitySession(authorizationHeader);
}

function personalizationBase(authorizationHeader: string | undefined): PersonalizationBase {
  return aiDiscoveryHome(authorizationHeader) as PersonalizationBase;
}

function buildTasteGraph(base: PersonalizationBase): JsonObject {
  const topGenres = base.taste_profile.top_genres.slice(0, 6);
  const creators = base.taste_profile.creator_affinity.slice(0, 6);
  const moods = base.taste_profile.mood_vector.slice(0, 5);
  const topTitles = base.recommendations.slice(0, 8);
  const nodes = [
    ...topGenres.map((item) => ({ id: `genre:${item.genre}`, type: "genre", label: item.genre, weight: item.weight })),
    ...creators.map((item) => ({ id: `creator:${item.creator_id}`, type: "creator", label: item.creator_name, weight: item.weight })),
    ...moods.map((item) => ({ id: `mood:${item.mood}`, type: "mood", label: item.mood, weight: item.weight })),
    ...topTitles.map((item) => ({ id: `title:${item.movie_id}`, type: "title", label: item.title, weight: item.score }))
  ];
  const edges = topTitles.flatMap((title) => [
    ...title.genre_prediction.slice(0, 2).map((genre) => ({ from: `genre:${genre}`, to: `title:${title.movie_id}`, reason: "genre_prediction" })),
    { from: `mood:${title.mood}`, to: `title:${title.movie_id}`, reason: "mood_match" }
  ]);
  return {
    profile_id: base.taste_profile.profile_id,
    nodes,
    edges,
    graph_density: nodes.length > 0 ? round(edges.length / nodes.length) : 0,
    explanation: "Local taste graph built from viewer library, progress, genre, creator, mood, and recommendation signals."
  };
}

function buildMoodEngine(base: PersonalizationBase, authorizationHeader: string | undefined): JsonObject {
  const moodVector = base.taste_profile.mood_vector.slice(0, 5);
  return {
    active_mood: moodVector[0]?.mood ?? "cinematic",
    mood_vector: moodVector,
    mood_rails: moodVector.map((item) => {
      const mood = String(item.mood ?? "cinematic");
      const moodResponse = aiDiscoveryMood(`/v2/discovery/mood?mood=${encodeURIComponent(mood)}`, authorizationHeader) as { recommendations: Recommendation[] };
      return {
        id: `mood-${mood}`,
        mood,
        weight: item.weight,
        titles: moodResponse.recommendations.slice(0, 4)
      };
    }),
    explanation: "Mood engine is deterministic and derived from local watch, save, completion, creator, and genre signals."
  };
}

function buildBehaviorLearning(base: PersonalizationBase): JsonObject {
  const signals = base.taste_profile.signals;
  const totalSignals = Object.values(signals).reduce((total, value) => total + Number(value), 0);
  return {
    model_version: "v3-local-behavior-1",
    total_signals: totalSignals,
    signals,
    learned_weights: {
      saved_titles: round((signals.saved_count ?? 0) * 1.4),
      progress_titles: round((signals.progress_count ?? 0) * 1.1),
      completed_titles: round((signals.completed_count ?? 0) * 1.7),
      offline_titles: round((signals.offline_count ?? 0) * 0.8)
    },
    cold_start: totalSignals === 0,
    explanation: totalSignals > 0 ? "Behavior learning is active from local user activity." : "Cold-start uses catalog quality, originals, and collection structure."
  };
}

function buildSmartContinueWatching(base: PersonalizationBase): JsonObject[] {
  const source = base.continue_watching_intelligence.length > 0
    ? base.continue_watching_intelligence
    : base.recommendations.slice(0, 3).map((item) => ({
      movie_id: item.movie_id,
      title: item.title,
      resume_percent: 0,
      next_best_action: "start feature",
      reason: item.reason
    }));
  return source.map((item, index) => ({
    ...item,
    priority: index + 1,
    resume_band: resumeBand(item.resume_percent),
    next_action_label: item.resume_percent > 0 ? "Resume" : "Start",
    adaptive_reason: item.resume_percent > 50 ? "High intent resume candidate" : item.reason
  }));
}

function buildDynamicCollections(base: PersonalizationBase): JsonObject[] {
  const genreCollections = base.taste_profile.top_genres.slice(0, 3).map((item) => ({
    id: `dynamic-genre-${slug(item.genre ?? "cinema")}`,
    title: `${item.genre} For You`,
    source: "taste_graph",
    weight: item.weight,
    titles: base.recommendations.filter((movie) => movie.genre_prediction.includes(String(item.genre))).slice(0, 6)
  }));
  const creatorCollections = base.taste_profile.creator_affinity.slice(0, 2).map((item) => ({
    id: `dynamic-creator-${item.creator_id}`,
    title: `From creators like ${item.creator_name}`,
    source: "creator_affinity",
    weight: item.weight,
    titles: base.recommendations.filter((movie) => movie.creator_affinity > 0).slice(0, 6)
  }));
  const moodCollections = base.taste_profile.mood_vector.slice(0, 2).map((item) => ({
    id: `dynamic-mood-${item.mood}`,
    title: `${capitalize(String(item.mood ?? "cinematic"))} Mood`,
    source: "mood_engine",
    weight: item.weight,
    titles: base.recommendations.filter((movie) => movie.mood === item.mood).slice(0, 6)
  }));
  return [...genreCollections, ...creatorCollections, ...moodCollections].filter((collection) => collection.titles.length > 0);
}

function buildAdaptiveDiscovery(base: PersonalizationBase): JsonObject {
  const rails = buildDynamicCollections(base);
  return {
    layout_strategy: base.taste_profile.signals.progress_count > 0 ? "resume_first" : "discovery_first",
    slot_order: [
      base.continue_watching_intelligence.length > 0 ? "smart_continue_watching" : "personalized_hero",
      "dynamic_collections",
      "mood_engine",
      "creator_affinity",
      "new_to_you"
    ],
    collection_count: rails.length,
    fallback_strategy: "catalog_quality_plus_highfive_originals",
    recommendation_refresh_policy: "recompute_on_library_progress_or_save_change",
    top_titles: base.recommendations.slice(0, 6)
  };
}

function heroTitle(base: PersonalizationBase): string {
  const genre = base.taste_profile.top_genres[0]?.genre;
  const mood = base.taste_profile.mood_vector[0]?.mood;
  if (genre && mood) return `${capitalize(String(mood))} ${genre} Picks`;
  if (genre) return `${genre} Picks For You`;
  return "HighFive Picks For You";
}

function topSignal(base: PersonalizationBase): string {
  const creator = base.taste_profile.creator_affinity[0]?.creator_name;
  if (creator) return `Creator affinity: ${creator}`;
  const genre = base.taste_profile.top_genres[0]?.genre;
  return genre ? `Genre signal: ${genre}` : "Local catalog signal";
}

function resumeBand(percent: number): string {
  if (percent >= 75) return "finish_next";
  if (percent >= 35) return "resume_midpoint";
  if (percent > 0) return "early_resume";
  return "new_start";
}

function slug(value: string): string {
  return value.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
}

function capitalize(value: string): string {
  return value.length > 0 ? value[0].toUpperCase() + value.slice(1) : value;
}

function round(value: number): number {
  return Math.round(value * 100) / 100;
}

function nowISO(): string {
  return new Date().toISOString();
}
