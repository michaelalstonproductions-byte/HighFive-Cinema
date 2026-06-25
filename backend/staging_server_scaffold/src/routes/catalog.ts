import { catalogSeed, type CatalogCollection, type CatalogMovie, type CatalogSeed } from "../catalog/catalogSeed.js";
import { ContractError } from "../errors.js";

export function catalogSummary(seed: CatalogSeed = catalogSeed) {
  return {
    generated_at: seed.generated_at,
    source: "local_seed",
    total_titles: seed.movies.length,
    total_creators: seed.creators.length,
    total_series: seed.series.length,
    total_collections: seed.collections.length,
    movies: seed.movies,
    creators: seed.creators,
    series: seed.series,
    collections: seed.collections
  };
}

export function catalogSync(cursor: string | null, seed: CatalogSeed = catalogSeed) {
  const syncedSeed = syncedCatalogSeed(seed);
  return {
    ...catalogSummary(syncedSeed),
    source: "local_seed_sync",
    catalog_version: 31,
    previous_cursor: cursor,
    sync_cursor: "catalog-v31-full",
    full_sync: true,
    tombstones: [
      {
        id: "tombstone-archived-cloud-title",
        entity_type: "movie",
        entity_id: "archived-cloud-title",
        deleted_at: syncedSeed.generated_at,
        reason: "Archived title removed from cloud catalog"
      }
    ]
  };
}

export function catalogDelta(cursor: string | null, seed: CatalogSeed = catalogSeed) {
  const generatedAt = new Date("2026-06-24T12:00:00.000Z").toISOString();
  const movie: CatalogMovie = {
    id: "cloud-director-cut",
    title: "Director Cut Signal",
    subtitle: "Cloud Catalog Delta",
    synopsis: "A delta-sync title used to verify catalog updates, cursor advancement, and local cache invalidation.",
    year: "2026",
    rating: "NR",
    duration: "44m",
    genres: ["Documentary", "Premiere"],
    poster_asset_name: null,
    backdrop_asset_name: null,
    creator_id: "maya-hart",
    creator_name: "Maya Hart",
    is_original: true,
    is_coming_soon: false,
    is_downloaded: false,
    progress: null,
    collection_ids: ["featured", "creator-published"]
  };
  return {
    generated_at: generatedAt,
    source: "local_seed_delta",
    catalog_version: 32,
    previous_cursor: cursor,
    sync_cursor: "catalog-v32-delta",
    full_sync: false,
    movies: [movie],
    creators: [],
    series: [],
    collections: [
      {
        id: "creator-published",
        title: "Creator Published",
        subtitle: "Published creator projects",
        movie_ids: ["behind-the-vision", "cloud-director-cut"]
      }
    ],
    tombstones: [
      {
        id: "tombstone-cloud-festival-premiere",
        entity_type: "movie",
        entity_id: "cloud-festival-premiere",
        deleted_at: generatedAt,
        reason: "Festival premiere preview was removed from the cloud catalog"
      }
    ]
  };
}

export function contentDetail(id: string, seed: CatalogSeed = catalogSeed): CatalogMovie {
  const movie = seed.movies.find((candidate) => candidate.id === id);
  if (!movie) {
    throw new ContractError("content_not_found", "Catalog content was not found", 404);
  }
  return movie;
}

export function creatorDetail(id: string, seed: CatalogSeed = catalogSeed): CatalogSeed["creators"][number] & { titles: CatalogMovie[] } {
  const creator = seed.creators.find((candidate) => candidate.id === id);
  if (!creator) {
    throw new ContractError("creator_not_found", "Catalog creator was not found", 404);
  }
  return {
    ...creator,
    titles: seed.movies.filter((movie) => movie.creator_id === id)
  };
}

export function collectionDetail(id: string, seed: CatalogSeed = catalogSeed): CatalogCollection & { titles: CatalogMovie[] } {
  const collection = seed.collections.find((candidate) => candidate.id === id);
  if (!collection) {
    throw new ContractError("collection_not_found", "Catalog collection was not found", 404);
  }
  return {
    ...collection,
    titles: collection.movie_ids
      .map((movieID) => seed.movies.find((movie) => movie.id === movieID))
      .filter((movie): movie is CatalogMovie => Boolean(movie))
  };
}

function syncedCatalogSeed(seed: CatalogSeed): CatalogSeed {
  const cloudMovie: CatalogMovie = {
    id: "cloud-festival-premiere",
    title: "Festival Premiere Window",
    subtitle: "Cloud Catalog",
    synopsis: "A remote catalog title used to verify initial full sync, local caching, and stale-while-revalidate behavior.",
    year: "2026",
    rating: "PG",
    duration: "51m",
    genres: ["Premiere", "Documentary"],
    poster_asset_name: null,
    backdrop_asset_name: null,
    creator_id: "maya-hart",
    creator_name: "Maya Hart",
    is_original: true,
    is_coming_soon: true,
    is_downloaded: false,
    progress: null,
    collection_ids: ["featured", "premieres"]
  };
  const collections = seed.collections.map((collection) => {
    if (collection.id === "featured") {
      return { ...collection, movie_ids: unique([...collection.movie_ids, cloudMovie.id]) };
    }
    return collection;
  });
  if (!collections.some((collection) => collection.id === "premieres")) {
    collections.push({
      id: "premieres",
      title: "Premieres",
      subtitle: "Cloud-synced premiere titles",
      movie_ids: [cloudMovie.id]
    });
  }
  return {
    ...seed,
    generated_at: new Date("2026-06-24T11:00:00.000Z").toISOString(),
    movies: uniqueByID([...seed.movies, cloudMovie]),
    collections
  };
}

function unique(values: string[]): string[] {
  return [...new Set(values)];
}

function uniqueByID<T extends { id: string }>(values: T[]): T[] {
  const seen = new Set<string>();
  return values.filter((value) => {
    if (seen.has(value.id)) return false;
    seen.add(value.id);
    return true;
  });
}
