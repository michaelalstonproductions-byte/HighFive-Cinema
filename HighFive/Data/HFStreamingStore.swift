import Foundation
import Combine

struct HFLocalViewingProfile: Identifiable, Codable, Equatable {
    let id: String
    var displayName: String
    var role: String
    var avatarSymbol: String
    var accentName: String
}

final class HFStreamingStore: ObservableObject {
    @Published private(set) var savedMovieIDs: Set<String>
    @Published private(set) var downloadedMovieIDs: Set<String>
    @Published private(set) var recentSearches: [String]
    @Published var localConnectUpdateDraft: String
    @Published private(set) var localConnectUpdates: [String]
    @Published private(set) var launchChecklistStates: [Bool]
    @Published private(set) var generatedDeliverySummary: String
    @Published private(set) var localProfiles: [HFLocalViewingProfile]
    @Published private(set) var activeProfileID: String

    private let savedKey = "hf.savedMovieIDs"
    private let downloadsKey = "hf.downloadedMovieIDs"
    private let recentSearchesKey = "hf.recentSearches"
    private let connectUpdatesKey = "hf.localConnectUpdates"
    private let launchChecklistKey = "hf.launchChecklistStates"
    private let activeProfileKey = "hf.localProfile.activeID"
    private let profileDisplayNamePrefix = "hf.localProfile.displayName."

    let launchChecklistItems = [
        "Campaign headline reviewed",
        "Premiere copy reviewed",
        "Audience prompt prepared",
        "Media kit checked",
        "Release calendar reviewed"
    ]

    init(defaultSavedIDs: Set<String> = ["friendly", "paranormall-s1"]) {
        let defaults = UserDefaults.standard
        let profiles = Self.makeLocalProfiles(defaults: defaults)
        let storedActiveProfileID = defaults.string(forKey: activeProfileKey)
        let resolvedActiveProfileID = profiles.contains { $0.id == storedActiveProfileID } ? storedActiveProfileID ?? profiles[0].id : profiles[0].id
        localProfiles = profiles
        activeProfileID = resolvedActiveProfileID
        savedMovieIDs = Self.loadProfileIDs(
            defaults: defaults,
            scopedKey: Self.scopedKey(savedKey, resolvedActiveProfileID),
            fallbackKey: savedKey,
            fallbackIDs: defaultSavedIDs
        )
        downloadedMovieIDs = Self.loadProfileIDs(
            defaults: defaults,
            scopedKey: Self.scopedKey(downloadsKey, resolvedActiveProfileID),
            fallbackKey: downloadsKey,
            fallbackIDs: Set(HFMockData.movies.filter(\.isDownloaded).map(\.id))
        )
        recentSearches = defaults.stringArray(forKey: recentSearchesKey) ?? HFMockData.searchSuggestions.prefix(3).map(\.title)
        localConnectUpdateDraft = "The Friendly watch-night prompt is ready for local review."
        localConnectUpdates = defaults.stringArray(forKey: connectUpdatesKey) ?? [
            "Draft: Invite viewers to choose who they would watch The Friendly with.",
            "Preview: Share a behind-the-scenes note before premiere week."
        ]
        let savedLaunchStates = defaults.array(forKey: launchChecklistKey) as? [Bool]
        launchChecklistStates = savedLaunchStates?.count == launchChecklistItems.count ? savedLaunchStates ?? [] : Array(repeating: false, count: launchChecklistItems.count)
        generatedDeliverySummary = ""
    }

    // hf.services.accountProfile
    // hf.services.localProfileStore
    // hf.services.activeViewingProfile
    var activeViewingProfile: HFLocalViewingProfile {
        localProfiles.first { $0.id == activeProfileID } ?? localProfiles[0]
    }

    var profileInitials: String {
        let parts = activeViewingProfile.displayName
            .split(separator: " ")
            .prefix(2)
            .compactMap(\.first)
        let initials = String(parts).uppercased()
        return initials.isEmpty ? "HF" : initials
    }

    var accountMode: String {
        "Local Profile Active"
    }

    var cloudAccountStatus: String {
        "Cloud Account Not Connected Yet"
    }

    // hf.services.profilePrivacyState
    var profilePrivacyState: String {
        "Privacy Ready"
    }

    func updateDisplayName(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let index = localProfiles.firstIndex(where: { $0.id == activeProfileID }) else { return }
        localProfiles[index].displayName = trimmed
        UserDefaults.standard.set(trimmed, forKey: profileDisplayNamePrefix + activeProfileID)
    }

    func selectProfile(_ profile: HFLocalViewingProfile) {
        guard localProfiles.contains(where: { $0.id == profile.id }) else { return }
        persist(savedMovieIDs, key: scopedSavedKey)
        persist(downloadedMovieIDs, key: scopedDownloadsKey)
        activeProfileID = profile.id
        UserDefaults.standard.set(activeProfileID, forKey: activeProfileKey)
        savedMovieIDs = Self.loadProfileIDs(
            defaults: .standard,
            scopedKey: scopedSavedKey,
            fallbackKey: savedKey,
            fallbackIDs: Set(["friendly", "paranormall-s1"])
        )
        downloadedMovieIDs = Self.loadProfileIDs(
            defaults: .standard,
            scopedKey: scopedDownloadsKey,
            fallbackKey: downloadsKey,
            fallbackIDs: Set(HFMockData.movies.filter(\.isDownloaded).map(\.id))
        )
    }

    // hf.services.unifiedStore
    // hf.services.movieCatalog
    var featuredMovie: Movie {
        movie(for: "friendly") ?? HFMockData.movies[0]
    }

    var continueWatchingMovie: Movie {
        HFMockData.movies.first { $0.progress != nil } ?? featuredMovie
    }

    var savedMovies: [Movie] {
        HFMockData.movies.filter { isSaved($0) }
    }

    // hf.services.downloadState
    var downloadedMovies: [Movie] {
        HFMockData.movies.filter { isDownloaded($0) }
    }

    // hf.services.libraryState
    func movie(for id: String) -> Movie? {
        HFMockData.movie(id)
    }

    func relatedMovies(for movie: Movie) -> [Movie] {
        HFMockData.relatedTitles(for: movie)
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
        persist(savedMovieIDs, key: scopedSavedKey)
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
        persist(downloadedMovieIDs, key: scopedDownloadsKey)
    }

    func removeAllDownloads() {
        downloadedMovieIDs.removeAll()
        persist(downloadedMovieIDs, key: scopedDownloadsKey)
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

    // hf.services.connectUpdates
    func addLocalConnectUpdate(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        localConnectUpdates.insert("Local update: \(trimmed)", at: 0)
        localConnectUpdateDraft = ""
        UserDefaults.standard.set(localConnectUpdates, forKey: connectUpdatesKey)
    }

    // hf.services.launchChecklist
    var launchChecklistProgress: Int {
        launchChecklistStates.filter { $0 }.count
    }

    func toggleLaunchChecklistItem(_ index: Int, isComplete: Bool) {
        guard launchChecklistStates.indices.contains(index) else { return }
        launchChecklistStates[index] = isComplete
        UserDefaults.standard.set(launchChecklistStates, forKey: launchChecklistKey)
    }

    // hf.services.exportSummary
    func generateDeliverySummary(for movie: Movie? = nil) {
        let selectedMovie = movie ?? featuredMovie
        generatedDeliverySummary = """
        HighFive Cinema Delivery Summary
        Title: \(selectedMovie.title)
        Watch surface: Movie Detail, Watch Now path, related titles, and My List route.
        Launch handoff: Campaign headline, premiere copy, audience prompt, media kit, and release calendar reviewed locally.
        Export package: Deliverables, media kit, festival materials, platform checklist, and distribution handoff are ready for text review.
        Status: Local summary only.
        """
    }

    var currentFunctionalProofRows: [String] {
        [
            "\(savedMovies.count) saved titles",
            "\(downloadedMovies.count) offline-ready titles",
            "Active local profile: \(activeViewingProfile.displayName)",
            "\(localConnectUpdates.count) local updates",
            "\(launchChecklistProgress)/\(launchChecklistItems.count) launch items reviewed",
            generatedDeliverySummary.isEmpty ? "Delivery summary ready to generate" : "Delivery summary generated"
        ]
    }

    private var scopedSavedKey: String {
        Self.scopedKey(savedKey, activeProfileID)
    }

    private var scopedDownloadsKey: String {
        Self.scopedKey(downloadsKey, activeProfileID)
    }

    private func persist(_ ids: Set<String>, key: String) {
        UserDefaults.standard.set(Array(ids).sorted(), forKey: key)
    }

    private static func scopedKey(_ base: String, _ profileID: String) -> String {
        "\(base).\(profileID)"
    }

    private static func loadProfileIDs(defaults: UserDefaults, scopedKey: String, fallbackKey: String, fallbackIDs: Set<String>) -> Set<String> {
        if let scoped = defaults.stringArray(forKey: scopedKey) {
            return Set(scoped)
        }
        if let fallback = defaults.stringArray(forKey: fallbackKey) {
            return Set(fallback)
        }
        return fallbackIDs
    }

    private static func makeLocalProfiles(defaults: UserDefaults) -> [HFLocalViewingProfile] {
        [
            HFLocalViewingProfile(
                id: "profile-michael",
                displayName: defaults.string(forKey: "hf.localProfile.displayName.profile-michael") ?? "Michael",
                role: "Viewer",
                avatarSymbol: "person.crop.circle.fill",
                accentName: "Gold"
            ),
            HFLocalViewingProfile(
                id: "profile-family",
                displayName: defaults.string(forKey: "hf.localProfile.displayName.profile-family") ?? "Family",
                role: "Family",
                avatarSymbol: "person.2.circle.fill",
                accentName: "Orange"
            ),
            HFLocalViewingProfile(
                id: "profile-creator",
                displayName: defaults.string(forKey: "hf.localProfile.displayName.profile-creator") ?? "Creator",
                role: "Creator",
                avatarSymbol: "video.circle.fill",
                accentName: "Cyan"
            )
        ]
    }
}
