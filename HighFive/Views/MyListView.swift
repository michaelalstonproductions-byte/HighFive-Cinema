import SwiftUI

struct MyListView: View {
    @EnvironmentObject private var streamingStore: HFStreamingStore
    var onBrowseDiscover: (() -> Void)?
    @State private var selectedFilter = "Saved"

    private let filters = ["Saved", "Continue Watching", "Downloads"]
    private let columns = [
        GridItem(.adaptive(minimum: HFSpacing.posterGridWidth), spacing: HFSpacing.md)
    ]

    private var savedMovies: [Movie] {
        switch selectedFilter {
        case "Continue Watching":
            return HFMockData.movies.filter { streamingStore.isSaved($0) && $0.progress != nil }
        case "Downloads":
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
                        title: "Your shelf is waiting",
                        message: "Save titles from Home, Search, Discover, or Movie Detail and they will appear here.",
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
        .accessibilityIdentifier("hf.consumer.library.root")
        .background(HFColors.screenBackground.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Text("Your Library")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
            Text("Saved titles, offline-ready picks, and what you are watching next.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
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
        .accessibilityIdentifier("hf.consumer.library.filters")
    }

    private var savedGrid: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: selectedFilter == "Saved" ? "Saved For Later" : selectedFilter, actionTitle: nil)

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
        .accessibilityIdentifier("hf.consumer.library.savedShelf")
    }

    private var savedSummary: some View {
        HFInsightCard(
            title: selectedFilter == "Saved" ? "\(savedMovies.count) saved titles" : "\(savedMovies.count) titles ready",
            message: selectedFilter == "Saved" ? "Your saved slate is available across Home, Search, and Movie Detail." : "This filter reflects your saved and downloaded titles.",
            systemImage: "bookmark.fill"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}
