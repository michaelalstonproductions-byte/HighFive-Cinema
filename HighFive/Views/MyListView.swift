import SwiftUI

struct MyListView: View {
    @EnvironmentObject private var streamingStore: HFStreamingStore
    var onBrowseDiscover: (() -> Void)?
    @State private var selectedFilter = "Saved"

    private let filters = ["Saved", "In Progress", "Downloaded"]
    private let columns = [
        GridItem(.adaptive(minimum: HFSpacing.posterGridWidth), spacing: HFSpacing.md)
    ]

    private var savedMovies: [Movie] {
        switch selectedFilter {
        case "In Progress":
            return HFMockData.movies.filter { streamingStore.isSaved($0) && $0.progress != nil }
        case "Downloaded":
            return HFMockData.movies.filter { streamingStore.isSaved($0) && streamingStore.isDownloaded($0) }
        default:
            return HFMockData.movies.filter { streamingStore.isSaved($0) }
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                header
                filterChips

                if savedMovies.isEmpty {
                    HFEmptyState(
                        title: "Your list is empty",
                        message: "Save titles from Home, Search, Discover, or Movie Detail and they will appear here for this local preview.",
                        systemImage: "bookmark",
                        actionTitle: "Browse Discover",
                        action: onBrowseDiscover
                    )
                        .padding(.horizontal, HFSpacing.screenHorizontal)
                } else {
                    savedSummary
                    savedGrid
                }
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
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
            HFSectionHeader(title: "\(selectedFilter) Titles", actionTitle: nil)

            LazyVGrid(columns: columns, alignment: .leading, spacing: HFSpacing.lg) {
                ForEach(savedMovies) { movie in
                    NavigationLink(value: movie) {
                        HFPosterCard(movie: movie, width: HFSpacing.posterGridWidth, showMetadata: true, showProgress: movie.progress != nil)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Open \(movie.title)")
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var savedSummary: some View {
        HFInsightCard(
            title: "\(savedMovies.count) local titles",
            message: selectedFilter == "Saved" ? "Your saved slate is synced across Home, Search, and Movie Detail." : "This filter is based on your local saved and download state.",
            systemImage: "bookmark.fill"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}
