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
                libraryShelfHero
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

    private var libraryShelfHero: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.36)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous)
                            .fill(HFColors.gold.opacity(0.14))
                        Image(systemName: "bookmark.rectangle.stack.fill")
                            .font(.system(size: 24, weight: .black))
                            .foregroundStyle(HFColors.gold)
                    }
                    .frame(width: 52, height: 52)

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Your watch shelf")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Saved titles, in-progress films, and offline-ready picks stay organized here.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                HStack(spacing: HFSpacing.sm) {
                    HFLibraryCountTile(value: "\(HFMockData.movies.filter { streamingStore.isSaved($0) }.count)", label: "Saved")
                    HFLibraryCountTile(value: "\(HFMockData.movies.filter { streamingStore.isSaved($0) && $0.progress != nil }.count)", label: "Resume")
                    HFLibraryCountTile(value: "\(HFMockData.movies.filter { streamingStore.isSaved($0) && streamingStore.isDownloaded($0) }.count)", label: "Offline")
                }
            }
            .padding(HFSpacing.lg)
            .background(
                LinearGradient(
                    colors: [HFColors.warmGlow.opacity(0.26), Color.clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Library shelf summary")
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

private struct HFLibraryCountTile: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: HFSpacing.xxs) {
            Text(value)
                .font(.system(size: 22, weight: .black, design: .default))
                .foregroundStyle(HFColors.textPrimary)
            Text(label)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.gold)
                .lineLimit(1)
                .minimumScaleFactor(0.76)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 62)
        .background(Color.white.opacity(0.07))
        .overlay(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous).stroke(HFColors.gold.opacity(0.18), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
    }
}
