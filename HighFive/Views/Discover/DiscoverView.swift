import SwiftUI

struct DiscoverView: View {
    let movies: [Movie]
    var showsHeader: Bool
    @State private var selectedGenre = "All"

    init(movies: [Movie] = HFMockData.movies, showsHeader: Bool = true) {
        self.movies = movies
        self.showsHeader = showsHeader
    }

    private var browseMovies: [Movie] {
        switch selectedGenre {
        case "All":
            return movies
        case "Originals":
            return movies.filter(\.isOriginal)
        case "Coming Soon":
            return movies.filter(\.isComingSoon)
        default:
            return movies.filter { $0.genres.contains(selectedGenre) }
        }
    }

    private var spotlightMovie: Movie {
        browseMovies.first ?? HFMockData.movie("friendly") ?? HFMockData.movies[0]
    }

    private let columns = [
        GridItem(.adaptive(minimum: 142), spacing: HFSpacing.md)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.lg) {
            if showsHeader {
                HFSectionHeader(title: "Discover", actionTitle: nil)
            }

            spotlight
            genreFilters
            discoveryGrid
            recommendationRows
        }
    }

    private var discoveryGrid: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: selectedGenre == "All" ? "All Titles" : selectedGenre, actionTitle: nil)
            LazyVGrid(columns: columns, alignment: .leading, spacing: HFSpacing.lg) {
                ForEach(browseMovies.prefix(8)) { movie in
                    NavigationLink(value: movie) {
                        HFPosterCard(movie: movie, width: 142, showMetadata: true, showProgress: movie.progress != nil)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var recommendationRows: some View {
        VStack(alignment: .leading, spacing: HFSpacing.lg) {
            movieRail(HFMockData.recommended)
            movieRail(HFMockData.onlyOnHighFive)
        }
    }

    private var spotlight: some View {
        NavigationLink(value: spotlightMovie) {
            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                HStack(spacing: HFSpacing.md) {
                    HFPosterCard(movie: spotlightMovie, width: 92, showTitle: false, showProgress: spotlightMovie.progress != nil)

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("RECOMMENDED FOR YOU")
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.gold)
                            .kerning(1.2)
                        Text(spotlightMovie.title)
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(2)
                        Text(spotlightMovie.subtitle)
                            .font(HFTypography.body)
                            .foregroundStyle(HFColors.textSecondary)
                            .lineLimit(2)
                        Text(spotlightMovie.genres.prefix(3).joined(separator: "  |  "))
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textMuted)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .buttonStyle(.plain)
    }

    private var genreFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HFSpacing.xs) {
                ForEach(HFMockData.discoveryGenres, id: \.self) { genre in
                    HFFilterChip(title: genre, isSelected: selectedGenre == genre) {
                        selectedGenre = genre
                    }
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
            .padding(.trailing, HFSpacing.screenHorizontal)
        }
    }

    private func movieRail(_ category: Category) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: category.title, actionTitle: nil)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    ForEach(category.movies) { movie in
                        NavigationLink(value: movie) {
                            HFPosterCard(movie: movie, width: 132, showProgress: movie.progress != nil)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
    }
}
