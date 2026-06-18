export const movieProductMapping: Record<string, string> = {
  friendly: "com.highfive.movie.thefriendly",
  "paranormall-s1": "com.highfive.series.paranormall.season1",
  paranormall_s1_e1: "com.highfive.episode.paranormall.e1",
  paranormall_s1_e2: "com.highfive.episode.paranormall.e2",
  paranormall_s1_e3: "com.highfive.episode.paranormall.e3",
  paranormall_s1_e4: "com.highfive.episode.paranormall.e4",
  paranormall_s1_e5: "com.highfive.episode.paranormall.e5",
  paranormall_s1_e6: "com.highfive.episode.paranormall.e6",
  paranormall_s1_e7: "com.highfive.episode.paranormall.e7"
};

export function expectedProductIDForMovie(movieID: string): string | undefined {
  return movieProductMapping[movieID];
}

export function productMatchesMovie(movieID: string, productID: string): boolean {
  return expectedProductIDForMovie(movieID) === productID;
}
