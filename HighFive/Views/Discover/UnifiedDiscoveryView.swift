import SwiftUI

struct UnifiedDiscoveryView: View {
    @State private var selectedFilter = "All"

    private var showMovies: Bool {
        selectedFilter == "All" || selectedFilter == "Movies"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xl) {
            header
            discoveryFilters

            ForEach(streamingDiscoveryRails) { category in
                movieRail(category)
            }
        }
    }

    private var streamingDiscoveryRails: [Category] {
        let rails = [
            HFMockData.categories.first { $0.id == "trending" },
            HFMockData.categories.first { $0.id == "originals" },
            HFMockData.categories.first { $0.id == "fresh-finds" },
            HFMockData.categories.first { $0.id == "coming-soon" },
            HFMockData.categories.first { $0.id == "my-movies" }
        ].compactMap { $0 }

        switch selectedFilter {
        case "Originals":
            return rails.filter { $0.id == "originals" }
        case "Drama", "Thriller", "Mystery", "Documentary":
            let movies = HFMockData.movies.filter { $0.genres.contains(selectedFilter) }
            return [Category(id: selectedFilter.lowercased(), title: "\(selectedFilter) Picks", subtitle: nil, movies: movies)]
        case "Coming Soon":
            return rails.filter { $0.id == "coming-soon" }
        default:
            return rails
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Discover")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .minimumScaleFactor(0.78)

            Text("Browse cinematic rails, saved titles, originals, and coming soon previews.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var discoveryFilters: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HFSpacing.xs) {
                    ForEach(HFMockData.discoveryGenres, id: \.self) { filter in
                        HFFilterChip(title: filter, isSelected: selectedFilter == filter) {
                            selectedFilter = filter
                        }
                        .accessibilityLabel("Select \(filter) discovery filter")
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
    }

    private func movieRail(_ category: Category) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: category.title, actionTitle: nil)

            if let subtitle = category.subtitle {
                Text(subtitle)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .padding(.horizontal, HFSpacing.screenHorizontal)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    ForEach(category.movies) { movie in
                        NavigationLink(value: movie) {
                            HFPosterCard(movie: movie, width: 140, showMetadata: false, showProgress: movie.progress != nil)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Open \(movie.title)")
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
            .scrollClipDisabled()
        }
    }
}
