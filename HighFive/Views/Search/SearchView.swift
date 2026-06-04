import SwiftUI

enum HFSearchHubMode: String, Hashable {
    case search = "Search"
    case discover = "Discover"
}

struct SearchView: View {
    @EnvironmentObject private var streamingStore: HFStreamingStore
    @Binding var mode: HFSearchHubMode
    @State private var query = ""
    @State private var selectedFilter = "All"

    private let filters = ["All", "Movies", "Series", "Originals", "Downloaded"]
    private let columns = [
        GridItem(.adaptive(minimum: HFSpacing.posterGridWidth), spacing: HFSpacing.md)
    ]

    private var filteredMovies: [Movie] {
        let base: [Movie]
        switch selectedFilter {
        case "Movies":
            base = HFMockData.movies.filter { !$0.duration.localizedCaseInsensitiveContains("episode") }
        case "Series":
            base = HFMockData.movies.filter { $0.duration.localizedCaseInsensitiveContains("episode") || $0.genres.contains("Series") }
        case "Originals":
            base = HFMockData.movies.filter(\.isOriginal)
        case "Downloaded":
            base = HFMockData.movies.filter { streamingStore.isDownloaded($0) }
        default:
            base = HFMockData.movies
        }

        let searchTerm = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !searchTerm.isEmpty else {
            return Array(base.prefix(8))
        }

        return base.filter {
            $0.title.localizedCaseInsensitiveContains(searchTerm) ||
            $0.subtitle.localizedCaseInsensitiveContains(searchTerm) ||
            $0.genres.joined(separator: " ").localizedCaseInsensitiveContains(searchTerm)
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                header
                HFSegmentedControl(
                    items: [
                        (.search, "Search"),
                        (.discover, "Discover")
                    ],
                    selection: $mode
                )
                .padding(.horizontal, HFSpacing.screenHorizontal)

                if mode == .search {
                    searchContent
                } else {
                    DiscoverView(movies: HFMockData.movies, showsHeader: false)
                }
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            Text(mode == .search ? "Search" : "Discover")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
            if mode == .search {
                HFSearchBar(text: $query, placeholder: "Search movies, genres, creators")
                    .onSubmit {
                        streamingStore.addRecentSearch(query)
                    }
            } else {
                Text("Browse the HighFive slate by genre, originals, and saved recommendations.")
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textSecondary)
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var searchContent: some View {
        VStack(alignment: .leading, spacing: HFSpacing.lg) {
            filterChips

            if query.isEmpty {
                recentSearches
            }

            resultsGrid
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HFSpacing.xs) {
                ForEach(filters, id: \.self) { filter in
                    HFFilterChip(title: filter, isSelected: selectedFilter == filter) {
                        selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
            .padding(.trailing, HFSpacing.screenHorizontal)
        }
    }

    private var recentSearches: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Recent Searches", actionTitle: nil)

            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                ForEach(streamingStore.recentSearches, id: \.self) { suggestion in
                    Button {
                        query = suggestion
                        streamingStore.addRecentSearch(suggestion)
                    } label: {
                        HStack(spacing: HFSpacing.sm) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(HFColors.gold)
                            Text(suggestion)
                                .font(HFTypography.body)
                                .foregroundStyle(HFColors.textSecondary)
                            Spacer()
                        }
                        .padding(.vertical, HFSpacing.xs)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    @ViewBuilder
    private var resultsGrid: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Results", actionTitle: nil)

            if filteredMovies.isEmpty {
                HFEmptyState(
                    title: "No results found",
                    message: "Try a title, genre, or creator from the HighFive slate.",
                    systemImage: "magnifyingglass"
                )
                    .padding(.horizontal, HFSpacing.screenHorizontal)
            } else {
                LazyVGrid(columns: columns, alignment: .leading, spacing: HFSpacing.lg) {
                    ForEach(filteredMovies) { movie in
                        NavigationLink(value: movie) {
                            HFPosterCard(movie: movie, width: HFSpacing.posterGridWidth, showMetadata: true, showProgress: movie.progress != nil)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
    }
}
