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
    @State private var selectedMood = "Drama"

    private let filters = ["All", "Movies", "Series", "Originals", "Downloaded"]
    private let moodFilters = ["Drama", "Family", "Thriller", "Originals", "New", "Saved"]
    private var suggestedMovies: [Movie] {
        Array(streamingStore.allCatalogMovies.filter { $0.isOriginal || $0.progress != nil }.prefix(5))
    }

    private let columns = [
        GridItem(.adaptive(minimum: HFSpacing.posterGridWidth), spacing: HFSpacing.md)
    ]

    private var filteredMovies: [Movie] {
        streamingStore.searchMovies(query: query, filter: selectedFilter)
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

                genreMoodFilters

                if mode == .search {
                    searchContent
                } else {
                    UnifiedDiscoveryView()
                }

                modeContextPanel
                discoveryStudioPanel
                catalogSearchSection
                discoveryMomentumSection
            }
            .padding(.top, HFSpacing.xxl)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .accessibilityIdentifier("hf.consumer.search.root")
        .accessibilityIdentifier("hf.search.screen")
        .safeAreaInset(edge: .top) {
            Color.clear
                .frame(height: 4)
                .accessibilityIdentifier("hf.safeArea.topProtected")
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear
                .frame(height: 4)
                .accessibilityIdentifier("hf.safeArea.bottomProtected")
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            Text(mode == .search ? "Search" : "Discover")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
            if mode == .search {
                HFSearchBar(text: $query, placeholder: "Search movies, genres, titles")
                    .onSubmit {
                        streamingStore.addRecentSearch(query)
                    }
                    .accessibilityIdentifier("hf.consumer.search.field")
            } else {
                Text("Browse movies, originals, saved titles, and upcoming premieres.")
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textSecondary)
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var modeContextPanel: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.28)) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: mode == .search ? "magnifyingglass.circle.fill" : "sparkles.tv.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 48, height: 48)
                    .background(HFColors.gold.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text(mode == .search ? "Find a title fast" : "Browse the premium slate")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    Text(mode == .search ? "Local results, clear filters, and one-tap title paths." : "Originals, saved picks, and continue-watching paths.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.86)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: HFSpacing.xs) {
                        HFSearchSignalChip(title: "\(streamingStore.allCatalogMovies.count) titles")
                        HFSearchSignalChip(title: "\(streamingStore.originalsCatalog.count) originals")
                        HFSearchSignalChip(title: "\(streamingStore.allCatalogMovies.filter { $0.isComingSoon }.count) upcoming")
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(HFSpacing.md)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(mode == .search ? "Search context panel" : "Discover context panel")
    }

    private var searchContent: some View {
        VStack(alignment: .leading, spacing: HFSpacing.lg) {
            filterChips

            if query.isEmpty {
                popularSearches
                recentSearches
                suggestedForYou
            }

            resultsGrid
        }
        .accessibilityIdentifier("hf.consumer.discovery.rails")
    }

    private var catalogSearchSection: some View {
        HFInsightCard(
            title: "Catalog Search",
            message: "Search and Discover use the shared movie catalog.",
            systemImage: "magnifyingglass.circle.fill"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Catalog Search, Search and Discover use the shared movie catalog")
        .accessibilityIdentifier("hf.catalog.search.connected")
        .accessibilityIdentifier("hf.catalog.discover.connected")
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
        .accessibilityIdentifier("hf.consumer.search.genreFilters")
    }

    private var discoveryStudioPanel: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Discovery Studio", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        Image(systemName: "sparkles.tv.fill")
                            .font(.system(size: 22, weight: .black))
                            .foregroundStyle(HFColors.gold)
                            .frame(width: 48, height: 48)
                            .background(HFColors.gold.opacity(0.13))
                            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            Text("Find something great to watch.")
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("Move from trending titles to originals, hidden gems, and coming-soon premieres without leaving the local slate.")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: 0)
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 128), spacing: HFSpacing.xs)], alignment: .leading, spacing: HFSpacing.xs) {
                        HFDiscoveryStudioCard(title: "Trending Now", systemImage: "flame.fill", isActive: true)
                        HFDiscoveryStudioCard(title: "HighFive Picks", systemImage: "sparkles")
                        HFDiscoveryStudioCard(title: "Originals", systemImage: "star.fill")
                        HFDiscoveryStudioCard(title: "Recently Added", systemImage: "clock.fill")
                        HFDiscoveryStudioCard(title: "Hidden Gems", systemImage: "diamond.fill")
                        HFDiscoveryStudioCard(title: "Coming Soon", systemImage: "calendar")
                    }
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Discovery Studio, local content discovery panel")
        .accessibilityIdentifier("hf.consumer.search.discoveryStudio")
    }

    private var genreMoodFilters: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Browse by mood")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .padding(.horizontal, HFSpacing.screenHorizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HFSpacing.xs) {
                    ForEach(moodFilters, id: \.self) { filter in
                        HFFilterChip(title: filter, isSelected: selectedMood == filter) {
                            selectedMood = filter
                            if mode == .discover {
                                mode = .search
                            }
                            selectedFilter = filter == "Saved" ? "All" : filter
                        }
                        .accessibilityLabel("Select \(filter) mood filter")
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Genre and mood filters")
        .accessibilityIdentifier("hf.consumer.search.genreFilters")
    }

    private var discoveryMomentumSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Discovery Momentum", actionTitle: nil)

            VStack(spacing: HFSpacing.xs) {
                HFConsumerMomentumRow(title: "Picks ready", detail: "Editorial lanes start with trending titles.", status: "Ready", systemImage: "sparkles")
                HFConsumerMomentumRow(title: "Originals active", detail: "HighFive Originals stay one filter away.", status: "Active", systemImage: "star.fill")
                HFConsumerMomentumRow(title: "Coming soon shelf", detail: "Premieres remain visible before release.", status: "Preview", systemImage: "calendar")
                HFConsumerMomentumRow(title: "Saved matches", detail: "Saved titles can guide the next watch.", status: "Local", systemImage: "bookmark.fill")
                HFConsumerMomentumRow(title: "Search local preview", detail: "Results are drawn from the local streaming slate.", status: "Local", systemImage: "magnifyingglass")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Discovery momentum, picks, originals, coming soon, saved matches, and local search")
        .accessibilityIdentifier("hf.consumer.search.discoveryMomentum")
    }

    private var popularSearches: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Popular Searches", actionTitle: "Discover") {
                mode = .discover
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    ForEach(streamingStore.catalogRails().first { $0.id == "trending" }?.movies.prefix(6) ?? streamingStore.allCatalogMovies.prefix(6)) { movie in
                        NavigationLink(value: movie) {
                            VStack(spacing: HFSpacing.xs) {
                                HFPosterCard(movie: movie, width: 124, showTitle: false, posterOnly: true)
                                Circle()
                                    .fill(HFColors.goldGradient)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Image(systemName: "flame.fill")
                                            .font(.system(size: 11, weight: .black))
                                            .foregroundStyle(.black)
                                    )
                                    .offset(y: -18)
                            }
                            .frame(height: 202)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("hf.route.searchToMovieDetail")
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
                .padding(.top, HFSpacing.xs)
            }
            .background(
                LinearGradient(
                    colors: [HFColors.warmGlow.opacity(0.20), Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .scrollClipDisabled()
        }
    }

    private var recentSearches: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Recent Searches", actionTitle: nil)

            if streamingStore.recentSearches.isEmpty {
                HFInsightCard(
                    title: "No recent searches",
                    message: "Search by title or genre and your terms will appear here.",
                    systemImage: "magnifyingglass"
                )
                .padding(.horizontal, HFSpacing.screenHorizontal)
            } else {
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

                    Button {
                        streamingStore.clearRecentSearches()
                    } label: {
                        HFRouteChip(title: "Clear Recent Searches", systemImage: "xmark.circle.fill")
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear recent searches")
                    .padding(.top, HFSpacing.xs)
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
    }

    private var suggestedForYou: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Suggested for You", actionTitle: nil)

            Text("Picks based on originals, downloads, and titles already in progress.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .padding(.horizontal, HFSpacing.screenHorizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    ForEach(suggestedMovies) { movie in
                        NavigationLink(value: movie) {
                            HFPosterCard(movie: movie, width: HFSpacing.posterRailWidth, showMetadata: true, showProgress: movie.progress != nil)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Open \(movie.title)")
                        .accessibilityIdentifier("hf.route.searchToMovieDetail")
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
            .scrollClipDisabled()
        }
    }

    @ViewBuilder
    private var resultsGrid: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Results", actionTitle: nil)

            if filteredMovies.isEmpty {
                HFEmptyState(
                    title: "No results found",
                    message: "No matches for this query and filter. Try a title, genre, or switch to Discover.",
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
                        .accessibilityLabel("Open \(movie.title)")
                        .accessibilityIdentifier("hf.route.searchToMovieDetail")
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
    }
}

private struct HFDiscoveryStudioCard: View {
    let title: String
    let systemImage: String
    var isActive = false

    var body: some View {
        HStack(spacing: HFSpacing.xs) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .black))
            Text(title)
                .font(HFTypography.micro)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .foregroundStyle(isActive ? .black : HFColors.textPrimary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 34)
        .padding(.horizontal, HFSpacing.sm)
        .background(isActive ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(Color.white.opacity(0.07)))
        .overlay(Capsule().stroke(isActive ? Color.clear : HFColors.glassStroke, lineWidth: 1))
        .clipShape(Capsule())
    }
}

private struct HFSearchSignalChip: View {
    let title: String

    var body: some View {
        Text(title)
            .font(HFTypography.micro)
            .foregroundStyle(HFColors.gold)
            .lineLimit(1)
            .minimumScaleFactor(0.74)
            .padding(.horizontal, HFSpacing.xs)
            .frame(height: 24)
            .background(HFColors.gold.opacity(0.10))
            .overlay(Capsule().stroke(HFColors.gold.opacity(0.22), lineWidth: 1))
            .clipShape(Capsule())
    }
}
