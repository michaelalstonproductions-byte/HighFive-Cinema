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
