import SwiftUI

struct SearchView: View {
    @State private var query = ""
    @State private var selectedFilter = "All"

    private let filters = ["All", "Recommended", "Originals", "Movies", "Series", "Coming Soon", "Downloaded"]

    private var filteredMovies: [Movie] {
        let base: [Movie]
        switch selectedFilter {
        case "Recommended":
            base = HFMockData.recommended.movies
        case "Originals":
            base = HFMockData.movies.filter(\.isOriginal)
        case "Series":
            base = HFMockData.movies.filter { $0.duration.localizedCaseInsensitiveContains("episode") || $0.genres.contains("Series") }
        case "Coming Soon":
            base = HFMockData.movies.filter(\.isComingSoon)
        case "Downloaded":
            base = HFMockData.movies.filter(\.isDownloaded)
        case "Movies":
            base = HFMockData.movies.filter { !$0.duration.localizedCaseInsensitiveContains("episode") }
        default:
            base = HFMockData.movies
        }

        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return base
        }

        return base.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.subtitle.localizedCaseInsensitiveContains(query) ||
            $0.genres.joined(separator: " ").localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Search")
                        .font(HFTypography.display)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("Browse HighFive originals, local downloads, and coming-soon titles.")
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textSecondary)
                    HFSearchBar(text: $query)
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
                .padding(.top, HFSpacing.lg)

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

                if query.isEmpty {
                    suggestions
                }

                DiscoverView(movies: filteredMovies)
            }
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
    }

    private var suggestions: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Suggested Searches", actionTitle: nil)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HFSpacing.sm) {
                    ForEach(HFMockData.searchSuggestions) { suggestion in
                        Button {
                            query = suggestion.title
                        } label: {
                            HFGlassPanel(cornerRadius: 18) {
                                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                                    Text(suggestion.title)
                                        .font(HFTypography.cardTitle)
                                        .foregroundStyle(HFColors.textPrimary)
                                    Text(suggestion.subtitle)
                                        .font(HFTypography.caption)
                                        .foregroundStyle(HFColors.textSecondary)
                                        .lineLimit(2)
                                }
                                .frame(width: 178, alignment: .leading)
                                .padding(HFSpacing.md)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
    }
}
