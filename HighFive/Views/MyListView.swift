import SwiftUI

struct MyListView: View {
    @State private var selectedFilter = "Saved"

    private let filters = ["Saved", "In Progress", "Downloaded"]
    private let columns = [
        GridItem(.adaptive(minimum: HFSpacing.posterGridWidth), spacing: HFSpacing.md)
    ]

    private var savedMovies: [Movie] {
        switch selectedFilter {
        case "In Progress":
            return HFMockData.movies.filter { $0.progress != nil }
        case "Downloaded":
            return HFMockData.movies.filter(\.isDownloaded)
        default:
            return HFMockData.movies.filter { $0.isDownloaded || $0.progress != nil || $0.isOriginal }
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                header
                filterChips

                if savedMovies.isEmpty {
                    emptyState
                        .padding(.horizontal, HFSpacing.screenHorizontal)
                } else {
                    savedGrid
                }
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.xxl)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Text("My List")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
            Text("Saved titles, downloads, and everything you are watching next.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
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

    private var savedGrid: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Saved Movies", actionTitle: nil)

            LazyVGrid(columns: columns, alignment: .leading, spacing: HFSpacing.lg) {
                ForEach(savedMovies) { movie in
                    NavigationLink(value: movie) {
                        HFPosterCard(movie: movie, width: HFSpacing.posterGridWidth, showMetadata: true, showProgress: movie.progress != nil)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var emptyState: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Text("Empty state")
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                Text("When no saved titles exist, suggest browsing Discover.")
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(HFSpacing.lg)
        }
    }
}
