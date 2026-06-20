import SwiftUI

struct MyListView: View {
    @EnvironmentObject private var streamingStore: HFStreamingStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    var onBrowseDiscover: (() -> Void)?
    @State private var selectedFilter: String
    @State private var isSceneAwake = false
    @State private var showsInspector = false

    private let forcesEmptyState: Bool
    private let filters = ["Saved", "Continue Watching", "Downloads"]
    private let columns = [
        GridItem(.adaptive(minimum: HFSpacing.posterGridWidth), spacing: HFSpacing.md)
    ]

    init(onBrowseDiscover: (() -> Void)? = nil) {
        let arguments = ProcessInfo.processInfo.arguments
        self.onBrowseDiscover = onBrowseDiscover
        _selectedFilter = State(initialValue: arguments.contains("--hf-start-library-continue") ? "Continue Watching" : "Saved")
        forcesEmptyState = arguments.contains("--hf-start-library-empty")
    }

    private var usesFallbackLayout: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    private var savedMovies: [Movie] {
        forcesEmptyState ? [] : streamingStore.savedMovies
    }

    private var progressMovies: [Movie] {
        savedMovies.filter { $0.progress != nil }
    }

    private var offlineMovies: [Movie] {
        savedMovies.filter { streamingStore.isDownloaded($0) }
    }

    private var selectedMovie: Movie? {
        progressMovies.first ?? savedMovies.first ?? streamingStore.continueWatchingMovie
    }

    private var visibleMovies: [Movie] {
        switch selectedFilter {
        case "Continue Watching":
            return progressMovies
        case "Downloads":
            return offlineMovies
        default:
            return savedMovies
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                if savedMovies.isEmpty {
                    emptyVault
                } else {
                    vaultWorld
                    savedForTonightShelf
                    watchShelf
                    additionalSavedTitles
                }
            }
            .padding(.top, HFSpacing.xxl)
            .padding(.bottom, HFSpacing.floatingTabClearance + HFSpacing.tabBarHeight)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .sheet(isPresented: $showsInspector) {
            libraryInspector
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            withAnimation(reduceMotion ? .easeInOut(duration: 0.01) : HFSpatialMotionTokens.sceneEntranceAnimation) {
                isSceneAwake = true
            }
        }
        .accessibilityIdentifier("hf.spatial.library")
        .accessibilityIdentifier("hf.consumer.library.root")
        .accessibilityIdentifier("hf.library.screen")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Text("Library")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
            Text("Cinematic Library Vault")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilitySortPriority(4)
    }

    private var vaultWorld: some View {
        VStack(spacing: HFSpacing.md) {
            if let selectedMovie {
                vaultObject(for: selectedMovie)
                    .accessibilitySortPriority(3)
            }

            HFSpatialActionCluster {
                if let selectedMovie {
                    NavigationLink(value: selectedMovie) {
                        Label(selectedMovie.progress == nil ? "Open Movie" : "Continue Watching", systemImage: "play.fill")
                            .font(HFTypography.smallAction)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 52)
                            .background(HFColors.goldGradient)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.spatial.library.continueWatching")
                    .accessibilityIdentifier("hf.library.continueStory")
                    .accessibilityIdentifier("hf.route.libraryToMovieDetail")
                }

                HStack(spacing: HFSpacing.sm) {
                    HFEnergyAction(title: "Remove from My List", systemImage: "bookmark.slash", style: .glass) {
                        if let selectedMovie, streamingStore.isSaved(selectedMovie) {
                            streamingStore.toggleSaved(selectedMovie)
                        }
                    }
                    HFEnergyAction(title: "Open Library Inspector", systemImage: "slider.horizontal.3", style: .glass) {
                        showsInspector = true
                    }
                    .accessibilityIdentifier("hf.library.inspector")
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .hfSpatialSceneEntrance(isActive: isSceneAwake, reduceMotion: reduceMotion)
        .accessibilityIdentifier("hf.spatial.library.vault")
        .accessibilityIdentifier("hf.spatial.accessibility.largeType")
    }

    private func vaultObject(for movie: Movie) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius + 10, strokeColor: HFColors.gold.opacity(0.42)) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous)
                    .fill(reduceTransparency ? Color.black.opacity(0.96) : Color.black.opacity(0.54))
                HFDepthContourOverlay(color: HFColors.gold.opacity(0.58))
                    .opacity(0.24)
                HStack(alignment: .center, spacing: HFSpacing.md) {
                    HFPosterCard(movie: movie, width: usesFallbackLayout ? 122 : 154, showTitle: false, posterOnly: true)
                        .shadow(color: HFColors.amberGlow.opacity(0.24), radius: 22, x: 0, y: 14)
                    VStack(alignment: .leading, spacing: HFSpacing.sm) {
                        Text("LOCAL LIBRARY MODE")
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.gold)
                            .accessibilityIdentifier("hf.library.localLibraryMode")
                        Text(movie.title)
                            .font(HFTypography.display)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.72)
                            .accessibilityIdentifier("hf.spatial.library.selectedTitle")
                        Text(movie.subtitle)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .lineLimit(3)
                        HStack(spacing: HFSpacing.xs) {
                            statusPill("Saved Locally", color: HFColors.gold, identifier: "hf.library.savedLocally")
                            if movie.progress != nil {
                                statusPill("Progress Saved", color: HFColors.cyanGlow, identifier: "hf.library.progressSavedLocally")
                            }
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(HFSpacing.md)
            }
            .frame(height: usesFallbackLayout ? 300 : 340)
            .padding(HFSpacing.md)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Library vault selected title \(movie.title)")
    }

    private var savedForTonightShelf: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Saved for Tonight", actionTitle: "\(savedMovies.count)")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    ForEach(savedMovies.prefix(8)) { movie in
                        NavigationLink(value: movie) {
                            HFPosterCard(movie: movie, width: 132, showProgress: movie.progress != nil)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("hf.route.libraryToMovieDetail")
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
        .accessibilityIdentifier("hf.spatial.library.savedForTonight")
    }

    private var watchShelf: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Watch Shelf", actionTitle: selectedFilter)
            filterChips
            if visibleMovies.isEmpty {
                compactEmpty(message: "This shelf is quiet. Saved local stories remain available in your vault.")
            } else {
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
        }
        .accessibilityIdentifier("hf.spatial.library.watchShelf")
    }

    private var additionalSavedTitles: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Continue the Story", actionTitle: nil)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    ForEach(HFMockData.recommended.movies) { movie in
                        NavigationLink(value: movie) {
                            HFPosterCard(movie: movie, width: 132, showProgress: movie.progress != nil)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("hf.route.libraryToMovieDetail")
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
        .accessibilityIdentifier("hf.library.continueStory")
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HFSpacing.xs) {
                ForEach(filters, id: \.self) { filter in
                    HFFilterChip(title: filter, isSelected: selectedFilter == filter) {
                        withAnimation(reduceMotion ? nil : HFSpatialMotionTokens.microAnimation) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityIdentifier("hf.spatial.accessibility.fallbackLayout")
    }

    private var emptyVault: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius + 10, strokeColor: HFColors.gold.opacity(0.38)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                Image(systemName: "bookmark.rectangle.stack.fill")
                    .font(.system(size: 34, weight: .black))
                    .foregroundStyle(.black)
                    .frame(width: 62, height: 62)
                    .background(HFColors.goldGradient)
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
                Text("Your Library")
                    .font(HFTypography.display)
                    .foregroundStyle(HFColors.textPrimary)
                Text("Save a story for later.")
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textSecondary)
                HFEnergyAction(title: "Explore HighFive", systemImage: "sparkles", style: .gold) {
                    onBrowseDiscover?()
                }
                .accessibilityIdentifier("hf.library.explore")
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.library.emptyState")
    }

    private var libraryInspector: some View {
        NavigationStack {
            HFSpatialInspectorChrome(
                title: "Library Inspector",
                detail: "Saved titles, progress, and offline preview state remain local. Cloud sync stays secondary.",
                systemImage: "bookmark.fill",
                accent: HFColors.gold
            ) {
                VStack(spacing: HFSpacing.xs) {
                    let status = streamingStore.librarySyncRuntimeStatus
                    let snapshot = streamingStore.librarySyncSnapshot
                    inspectorRow(title: "Local Library Mode", detail: status.detail, status: status.statusLabel, color: HFColors.gold, identifier: "hf.library.localLibraryMode")
                    inspectorRow(title: "Saved Locally", detail: "\(snapshot.savedTitles.count) saved title records.", status: "\(snapshot.savedTitles.count)", color: HFColors.gold, identifier: "hf.library.savedLocally")
                    inspectorRow(title: "Progress Saved Locally", detail: "\(snapshot.progressRecords.count) progress records.", status: "\(snapshot.progressRecords.count)", color: HFColors.cyanGlow, identifier: "hf.library.progressSavedLocally")
                    inspectorRow(title: "Offline Preview State", detail: "\(snapshot.offlineStates.count) local offline preview states.", status: "\(snapshot.offlineStates.count)", color: HFColors.cyanGlow, identifier: "hf.library.offlinePreviewState")
                    inspectorRow(title: "Cloud Library Not Connected Yet", detail: "Cloud sync requires account and backend readiness.", status: "Not Connected Yet", color: HFColors.gold, identifier: "hf.library.cloudNotConnected")
                    inspectorRow(title: "Sync Status", detail: status.boundary.title, status: "Local", color: HFColors.gold, identifier: "hf.library.syncStatus")
                    inspectorRow(title: "No live cross-device sync", detail: "Backend-mediated library sync only. No live cross-device claim is made.", status: "Local only", color: HFColors.textSecondary, identifier: "hf.library.noLiveCrossDeviceSync")
                }
            }
            .navigationTitle("Inspector")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showsInspector = false }
                }
            }
        }
        .accessibilityIdentifier("hf.library.inspector")
    }

    private func compactEmpty(message: String) -> some View {
        Text(message)
            .font(HFTypography.caption)
            .foregroundStyle(HFColors.textSecondary)
            .padding(HFSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
            .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func statusPill(_ title: String, color: Color, identifier: String) -> some View {
        Text(title)
            .font(HFTypography.micro)
            .foregroundStyle(color)
            .padding(.horizontal, HFSpacing.xs)
            .frame(minHeight: 24)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
            .accessibilityIdentifier(identifier)
    }

    private func inspectorRow(title: String, detail: String, status: String, color: Color, identifier: String) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                Text(title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                Text(detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Text(status)
                .font(HFTypography.micro)
                .foregroundStyle(color)
                .padding(.horizontal, HFSpacing.xs)
                .frame(minHeight: 24)
                .background(color.opacity(0.12))
                .clipShape(Capsule())
        }
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityIdentifier(identifier)
    }
}
