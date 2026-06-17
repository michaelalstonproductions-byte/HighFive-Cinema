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
                librarySyncStatusPanel
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

    private var librarySyncStatusPanel: some View {
        let syncStatus = streamingStore.librarySyncRuntimeStatus
        let snapshot = streamingStore.librarySyncSnapshot
        return HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.24)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(.black)
                        .frame(width: 48, height: 48)
                        .background(HFColors.goldGradient)
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text("Library Sync")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(syncStatus.statusLabel)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)
                            .accessibilityIdentifier("hf.library.syncStatus")
                        Text(syncStatus.boundary.title)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 138), spacing: HFSpacing.xs)], alignment: .leading, spacing: HFSpacing.xs) {
                    librarySyncMetric(
                        title: "Saved Locally",
                        value: "\(snapshot.savedTitles.count)",
                        identifier: "hf.library.savedLocally"
                    )
                    librarySyncMetric(
                        title: "Progress Saved Locally",
                        value: "\(snapshot.progressRecords.count)",
                        identifier: "hf.library.progressSavedLocally"
                    )
                    librarySyncMetric(
                        title: "Offline Preview State",
                        value: "\(snapshot.offlineStates.count)",
                        identifier: "hf.library.offlinePreviewState"
                    )
                }

                HStack(spacing: HFSpacing.xs) {
                    Text("Cloud sync requires account")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.gold)
                        .padding(.horizontal, HFSpacing.xs)
                        .frame(height: 24)
                        .background(HFColors.gold.opacity(0.12))
                        .clipShape(Capsule())
                        .accessibilityIdentifier("hf.library.cloudNotConnected")

                    Text(syncStatus.conflictPolicy.detail)
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textMuted)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier(syncStatus.state.accessibilityIdentifier)
        .accessibilityIdentifier("hf.library.backendStatus")
    }

    private func librarySyncMetric(title: String, value: String, identifier: String) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xxs) {
            Text(value)
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.gold)
            Text(title)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityIdentifier(identifier)
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
                    .accessibilityIdentifier("hf.route.libraryToMovieDetail")
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityIdentifier(selectedFilter == "Continue Watching" ? "hf.library.continueWatching" : "hf.library.savedForTonight")
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
        .accessibilityIdentifier("hf.library.continueStory")
    }
}
