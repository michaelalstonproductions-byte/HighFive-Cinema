import SwiftUI

struct MyListView: View {
    @EnvironmentObject private var streamingStore: HFStreamingStore
    var onBrowseDiscover: (() -> Void)?
    @State private var selectedFilter = "Saved"

    private let filters = ["Saved", "Continue Watching", "Downloads"]
    private let columns = [
        GridItem(.adaptive(minimum: HFSpacing.posterGridWidth), spacing: HFSpacing.md)
    ]

    private var visibleMovies: [Movie] {
        switch selectedFilter {
        case "Continue Watching":
            return streamingStore.savedMovies.filter { $0.progress != nil }
        case "Downloads":
            return streamingStore.savedMovies.filter { streamingStore.isDownloaded($0) }
        default:
            return streamingStore.savedMovies
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                shelfHero
                filterChips

                if visibleMovies.isEmpty {
                    HFEmptyState(
                        title: "Your shelf is waiting",
                        message: "Save titles from Home, Search, Discover, or Movie Detail and they will appear here.",
                        systemImage: "bookmark",
                        actionTitle: "Browse Discover",
                        action: onBrowseDiscover
                    )
                    .padding(.horizontal, HFSpacing.screenHorizontal)
                } else {
                    savedGrid
                }

                recommendedNext
            }
            .padding(.top, HFSpacing.xxl)
            .padding(.bottom, HFSpacing.floatingTabClearance + HFSpacing.tabBarHeight)
        }
        .accessibilityIdentifier("hf.consumer.library.root")
        .accessibilityIdentifier("hf.library.screen")
        .background(HFColors.screenBackground.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Text("My List")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
            Text("Saved titles, progress, and offline-ready picks.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.library.watchShelf")
    }

    private var shelfHero: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.38)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(spacing: HFSpacing.md) {
                    Image(systemName: "bookmark.rectangle.stack.fill")
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(.black)
                        .frame(width: 54, height: 54)
                        .background(HFColors.goldGradient)
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Your Watch Shelf")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Your saved titles, downloads, and watch progress live here.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                    }

                    Spacer()
                }

                HStack(spacing: HFSpacing.sm) {
                    countTile(value: "\(streamingStore.savedMovies.count)", label: "Saved")
                    countTile(value: "\(streamingStore.savedMovies.filter { $0.progress != nil }.count)", label: "Resume")
                    countTile(value: "\(streamingStore.savedMovies.filter { streamingStore.isDownloaded($0) }.count)", label: "Offline")
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func countTile(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xxs) {
            Text(value)
                .font(HFTypography.section)
                .foregroundStyle(HFColors.gold)
            Text(label)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
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
            HFSectionHeader(title: selectedFilter, actionTitle: "\(visibleMovies.count)")
            LazyVGrid(columns: columns, alignment: .leading, spacing: HFSpacing.lg) {
                ForEach(visibleMovies) { movie in
                    NavigationLink(value: movie) {
                        HFPosterCard(movie: movie, width: HFSpacing.posterGridWidth, showMetadata: true, showProgress: movie.progress != nil)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var recommendedNext: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Recommended Next", actionTitle: nil)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    ForEach(HFMockData.recommended.movies) { movie in
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
