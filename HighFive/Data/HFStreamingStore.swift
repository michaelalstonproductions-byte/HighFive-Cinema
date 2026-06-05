import Foundation
import Combine

final class HFStreamingStore: ObservableObject {
    @Published private(set) var savedMovieIDs: Set<String>
    @Published private(set) var downloadedMovieIDs: Set<String>
    @Published private(set) var recentSearches: [String]

    private let savedKey = "hf.savedMovieIDs"
    private let downloadsKey = "hf.downloadedMovieIDs"
    private let recentSearchesKey = "hf.recentSearches"

    init(defaultSavedIDs: Set<String> = ["friendly", "paranormall-s1"]) {
        let defaults = UserDefaults.standard
        savedMovieIDs = Set(defaults.stringArray(forKey: savedKey) ?? Array(defaultSavedIDs))
        downloadedMovieIDs = Set(defaults.stringArray(forKey: downloadsKey) ?? HFMockData.movies.filter(\.isDownloaded).map(\.id))
        recentSearches = defaults.stringArray(forKey: recentSearchesKey) ?? HFMockData.searchSuggestions.prefix(3).map(\.title)
    }

    func isSaved(_ movie: Movie) -> Bool {
        savedMovieIDs.contains(movie.id)
    }

    func toggleSaved(_ movie: Movie) {
        if savedMovieIDs.contains(movie.id) {
            savedMovieIDs.remove(movie.id)
        } else {
            savedMovieIDs.insert(movie.id)
        }
        persist(savedMovieIDs, key: savedKey)
    }

    func isDownloaded(_ movie: Movie) -> Bool {
        downloadedMovieIDs.contains(movie.id)
    }

    func toggleDownload(_ movie: Movie) {
        if downloadedMovieIDs.contains(movie.id) {
            downloadedMovieIDs.remove(movie.id)
        } else {
            downloadedMovieIDs.insert(movie.id)
        }
        persist(downloadedMovieIDs, key: downloadsKey)
    }

    func removeAllDownloads() {
        downloadedMovieIDs.removeAll()
        persist(downloadedMovieIDs, key: downloadsKey)
    }

    func addRecentSearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        recentSearches.removeAll { $0.localizedCaseInsensitiveCompare(trimmed) == .orderedSame }
        recentSearches.insert(trimmed, at: 0)
        recentSearches = Array(recentSearches.prefix(6))
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }

    func clearRecentSearches() {
        recentSearches.removeAll()
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }

    private func persist(_ ids: Set<String>, key: String) {
        UserDefaults.standard.set(Array(ids).sorted(), forKey: key)
    }
}
