import SwiftUI

struct SearchView: View {
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
            base = HFMockData.movies.filter(\.isDownloaded)
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
                filterChips

                if query.isEmpty {
                    recentSearches
                }

                resultsGrid
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.xxl)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            Text("Search")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
            HFSearchBar(text: $query, placeholder: "Search movies, genres, creators")
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
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
    }

    private var recentSearches: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Recent Searches", actionTitle: nil)

            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                ForEach(HFMockData.searchSuggestions.prefix(3)) { suggestion in
                    Button {
                        query = suggestion.title
                    } label: {
                        HStack(spacing: HFSpacing.sm) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(HFColors.gold)
                            Text(suggestion.title)
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
                emptyState
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

    private var emptyState: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius) {
            HStack(spacing: HFSpacing.md) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    Text("No results yet")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("Try a title, genre, or creator from the HighFive slate.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                }
                Spacer(minLength: 0)
            }
            .padding(HFSpacing.md)
        }
    }
}
