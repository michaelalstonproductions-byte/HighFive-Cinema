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

    private let filters = ["All", "Movies", "Series", "Originals", "Downloaded", "Coming Soon"]
    private let columns = [
        GridItem(.adaptive(minimum: HFSpacing.posterGridWidth), spacing: HFSpacing.md)
    ]

    private var results: [Movie] {
        streamingStore.searchMovies(query: query, filter: selectedFilter)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                header
                HFSegmentedControl(items: [(.search, "Search"), (.discover, "Discover")], selection: $mode)
                    .padding(.horizontal, HFSpacing.screenHorizontal)

                if mode == .search {
                    filterChips
                    searchSuggestions
                    resultsGrid(title: query.isEmpty ? "Popular on HighFive" : "Results")
                } else {
                    DiscoverView(movies: streamingStore.allCatalogMovies, showsHeader: false)
                }
            }
            .padding(.top, HFSpacing.xxl)
            .padding(.bottom, HFSpacing.floatingTabClearance + HFSpacing.tabBarHeight)
        }
        .accessibilityIdentifier("hf.consumer.search.root")
        .accessibilityIdentifier("hf.search.screen")
        .background(HFColors.screenBackground.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            Text(mode == .search ? "Search" : "Discover")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            HFSearchBar(text: $query, placeholder: "Search movies, genres, creators")
                .onSubmit {
                    streamingStore.addRecentSearch(query)
                }
                .accessibilityIdentifier("hf.consumer.search.field")
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.search.curatedDiscovery")
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
        }
        .accessibilityIdentifier("hf.consumer.search.genreFilters")
        .accessibilityIdentifier("hf.search.moodChips")
    }

    @ViewBuilder
    private var searchSuggestions: some View {
        if query.isEmpty {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                HFSectionHeader(title: "Quick Searches", actionTitle: nil)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: HFSpacing.xs) {
                        ForEach(HFMockData.searchSuggestions.prefix(6)) { suggestion in
                            Button {
                                query = suggestion.title
                                streamingStore.addRecentSearch(suggestion.title)
                            } label: {
                                HStack(spacing: HFSpacing.xs) {
                                    Image(systemName: suggestion.movie == nil ? "magnifyingglass" : "play.rectangle.fill")
                                    Text(suggestion.title)
                                }
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textPrimary)
                                .padding(.horizontal, HFSpacing.sm)
                                .frame(height: 34)
                                .background(Color.white.opacity(0.10))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(HFColors.glassStroke, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, HFSpacing.screenHorizontal)
                }
            }
        }
    }

    private func resultsGrid(title: String) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: title, actionTitle: "\(results.count) titles")
            LazyVGrid(columns: columns, alignment: .leading, spacing: HFSpacing.lg) {
                ForEach(results) { movie in
                    NavigationLink(value: movie) {
                        HFPosterCard(movie: movie, width: HFSpacing.posterGridWidth, showMetadata: true, showProgress: movie.progress != nil)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityIdentifier("hf.consumer.search.results")
        .accessibilityIdentifier("hf.search.resultCards")
    }
}
