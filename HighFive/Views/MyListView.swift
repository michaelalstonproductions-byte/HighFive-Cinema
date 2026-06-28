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
    @State private var didRequestViewerRuntime = false

    private let forcesEmptyState: Bool
    private let filters = ["Saved", "Continue Watching", "Watch Later", "Favorites", "History", "Offline"]
    private let columns = [
        GridItem(.adaptive(minimum: HFSpacing.posterGridWidth), spacing: HFSpacing.md)
    ]

    init(onBrowseDiscover: (() -> Void)? = nil) {
        let arguments = ProcessInfo.processInfo.arguments
        self.onBrowseDiscover = onBrowseDiscover
        let initialFilter: String
        if arguments.contains("--hf-start-library-continue") {
            initialFilter = "Continue Watching"
        } else if arguments.contains("--hf-start-library-history") {
            initialFilter = "History"
        } else if arguments.contains("--hf-start-library-favorites") {
            initialFilter = "Favorites"
        } else if arguments.contains("--hf-start-library-watch-later") {
            initialFilter = "Watch Later"
        } else if arguments.contains("--hf-start-library-offline") {
            initialFilter = "Offline"
        } else {
            initialFilter = "Saved"
        }
        _selectedFilter = State(initialValue: initialFilter)
        forcesEmptyState = arguments.contains("--hf-start-library-empty")
    }

    private var usesFallbackLayout: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    private var shouldRunViewerRuntime: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-viewer-library-runtime")
            || arguments.contains("--hf-library-progress-sync")
            || arguments.contains("--hf-library-recommendations-sync")
    }

    private var savedMovies: [Movie] {
        forcesEmptyState ? [] : streamingStore.savedMovies
    }

    private var progressMovies: [Movie] {
        forcesEmptyState ? [] : streamingStore.libraryContinueWatchingMovies
    }

    private var offlineMovies: [Movie] {
        forcesEmptyState ? [] : streamingStore.downloadedMovies
    }

    private var selectedMovie: Movie? {
        forcesEmptyState ? nil : streamingStore.libraryLastViewedMovie
    }

    private var visibleMovies: [Movie] {
        switch selectedFilter {
        case "Continue Watching":
            return progressMovies
        case "Watch Later":
            return streamingStore.libraryWatchLaterMovies
        case "Favorites":
            return streamingStore.libraryFavoriteMovies
        case "History":
            return streamingStore.libraryViewingHistory.map(\.movie)
        case "Offline":
            return offlineMovies
        default:
            return savedMovies
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.sectionGap) {
                header
                if shouldRunViewerRuntime {
                    viewerLibraryRuntimeSurface
                }
                if savedMovies.isEmpty {
                    emptyVault
                } else {
                    vaultWorld
                    premiumVaultStats
                    personalLibrarySystem
                    if !shouldRunViewerRuntime {
                        viewerLibraryRuntimeSurface
                    }
                    libraryActivitySurface
                    libraryCollectionsSurface
                    libraryIntelligenceSurface
                    savedForTonightShelf
                    watchShelf
                    additionalSavedTitles
                }
            }
            .padding(.top, HFSpacing.screenTop)
            .padding(.bottom, HFSpacing.floatingTabClearance + HFSpacing.tabBarHeight)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .sheet(isPresented: $showsInspector) {
            libraryInspector
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            guard !isSceneAwake else { return }
            withAnimation(reduceMotion ? .easeInOut(duration: 0.01) : HFSpatialMotionTokens.sceneEntranceAnimation) {
                isSceneAwake = true
            }
        }
        .task {
            guard shouldRunViewerRuntime, !didRequestViewerRuntime else { return }
            didRequestViewerRuntime = true
            await streamingStore.runViewerLibraryProgressOfflineFixture(for: selectedMovie)
        }
        .accessibilityIdentifier("hf.spatial.library")
        .accessibilityIdentifier("hf.streaming.premium.libraryVault")
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
        VStack(spacing: HFSpacing.sm) {
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
                            .frame(minHeight: 48)
                            .background(HFColors.goldGradient)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.spatial.library.continueWatching")
                    .accessibilityIdentifier("hf.library.continueWatching")
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
        .accessibilityIdentifier("hf.streaming.premium.libraryVault")
        .accessibilityIdentifier("hf.spatial.accessibility.largeType")
    }

    private var premiumVaultStats: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 112), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
            vaultStat(title: "Saved", value: "\(savedMovies.count)", systemImage: "bookmark.fill", color: HFColors.gold)
            vaultStat(title: "Watching", value: "\(progressMovies.count)", systemImage: "play.circle.fill", color: HFColors.cyanGlow)
            vaultStat(title: "Offline", value: "\(offlineMovies.count)", systemImage: "arrow.down.circle.fill", color: HFColors.violet)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.library.system")
    }

    private var personalLibrarySystem: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "person.text.rectangle.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(.black)
                        .frame(width: 50, height: 50)
                        .background(HFColors.goldGradient)
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Personal Library System")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Continue Watching, My List, Watch Later, Favorites, History, and Offline Preview are organized locally for this profile.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 128), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    librarySignal(title: "Resume Progress", value: "\(progressMovies.count)", systemImage: "play.circle.fill", color: HFColors.cyanGlow, identifier: "hf.library.resumeProgress")
                    librarySignal(title: "My List", value: "\(savedMovies.count)", systemImage: "bookmark.fill", color: HFColors.gold, identifier: "hf.library.myList")
                    librarySignal(title: "Watch Later", value: "\(streamingStore.libraryWatchLaterMovies.count)", systemImage: "clock.fill", color: HFColors.violet, identifier: "hf.library.watchLater")
                    librarySignal(title: "Favorites", value: "\(streamingStore.libraryFavoriteMovies.count)", systemImage: "star.fill", color: HFColors.gold, identifier: "hf.library.favorites")
                }
            }
            .padding(HFSpacing.md)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.library.personalHub")
    }

    private var viewerLibraryRuntimeSurface: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.cyanGlow.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "rectangle.stack.person.crop.fill")
                        .font(.system(size: 21, weight: .black))
                        .foregroundStyle(HFColors.cyanGlow)
                        .frame(width: 48, height: 48)
                        .background(HFColors.cyanGlow.opacity(0.16))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Viewer Library Runtime")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                            .accessibilityIdentifier("hf.viewer.library.runtime")
                        Text(streamingStore.viewerLibraryRuntimeSnapshot.detail)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Text(streamingStore.viewerLibraryRuntimeSnapshot.statusLabel)
                        .font(HFTypography.micro.weight(.bold))
                        .foregroundStyle(HFColors.cyanGlow)
                        .padding(.horizontal, HFSpacing.xs)
                        .frame(minHeight: 26)
                        .background(HFColors.cyanGlow.opacity(0.12))
                        .clipShape(Capsule())
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(streamingStore.viewerLibraryRuntimeRows) { row in
                        librarySignal(
                            title: row.title,
                            value: row.value,
                            systemImage: row.systemImage,
                            color: row.id == "offline" ? HFColors.violet : HFColors.cyanGlow,
                            identifier: "hf.viewer.library.runtime.\(row.id)"
                        )
                        .accessibilityLabel("\(row.title), \(row.value), \(row.detail)")
                    }
                }

                if let error = streamingStore.viewerLibraryRuntimeSnapshot.lastError {
                    Text(error)
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.gold)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("hf.viewer.library.runtime.error")
                }
            }
            .padding(HFSpacing.md)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.viewer.library.sync")
    }

    private var libraryActivitySurface: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Viewing History", actionTitle: "\(streamingStore.libraryViewingHistory.count)")

            if let nextEpisode = streamingStore.libraryNextEpisode {
                HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.30)) {
                    HStack(alignment: .center, spacing: HFSpacing.md) {
                        Image(systemName: "forward.end.fill")
                            .font(.system(size: 20, weight: .black))
                            .foregroundStyle(HFColors.cyanGlow)
                            .frame(width: 46, height: 46)
                            .background(HFColors.cyanGlow.opacity(0.14))
                            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
                        VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                            Text("Next Episode")
                                .font(HFTypography.micro)
                                .foregroundStyle(HFColors.cyanGlow)
                            Text(nextEpisode.title)
                                .font(HFTypography.cardTitle)
                                .foregroundStyle(HFColors.textPrimary)
                            Text(nextEpisode.detail)
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                        }
                        Spacer()
                    }
                    .padding(HFSpacing.md)
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
                .accessibilityIdentifier("hf.library.nextEpisode")
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HFSpacing.md) {
                    ForEach(streamingStore.libraryViewingHistory.prefix(8)) { record in
                        NavigationLink(value: record.movie) {
                            libraryActivityCard(record)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("hf.route.libraryToMovieDetail")
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
        .accessibilityIdentifier("hf.library.viewingHistory")
        .accessibilityIdentifier("hf.library.recentlyWatched")
    }

    private var libraryCollectionsSurface: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "User Collections", actionTitle: "\(streamingStore.libraryUserCollections.count)")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HFSpacing.md) {
                    ForEach(streamingStore.libraryUserCollections) { collection in
                        vaultCollectionCard(
                            title: collection.title,
                            detail: collection.detail,
                            count: collection.movies.count,
                            color: collection.id == "available-offline" ? HFColors.cyanGlow : (collection.id == "creator-collections" ? HFColors.violet : HFColors.gold),
                            systemImage: collection.systemImage
                        )
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
        .accessibilityIdentifier("hf.library.collections")
        .accessibilityIdentifier("hf.library.userCollections")
    }

    private var libraryIntelligenceSurface: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.cyanGlow.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                Label("Library Intelligence", systemImage: "sparkle.magnifyingglass")
                    .font(HFTypography.section)
                    .foregroundStyle(HFColors.textPrimary)

                Text("Continue Watching feeds recommendations, collections, and Discovery without leaving local catalog mode.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(streamingStore.libraryIntelligenceSignals) { signal in
                        librarySignal(
                            title: signal.title,
                            value: signal.value,
                            systemImage: signal.systemImage,
                            color: signal.id == "offline" ? HFColors.violet : HFColors.cyanGlow,
                            identifier: signal.id == "offline" ? "hf.library.downloadsIntegration" : "hf.library.intelligence.\(signal.id)"
                        )
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.library.intelligence")
        .accessibilityIdentifier("hf.library.discoveryConnection")
    }

    private func vaultStat(title: String, value: String, systemImage: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: systemImage)
                .font(HFIconography.symbolFont(size: HFIconography.controlIconSize, weight: .black))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(color)
                .frame(width: HFIconography.actionIconFrame)
            Text(value)
                .font(.system(size: 28, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
            Text(title)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.md)
        .background(Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(color.opacity(0.26), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }

    private func vaultCollectionCard(title: String, detail: String, count: Int, color: Color, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Image(systemName: systemImage)
                .font(HFIconography.symbolFont(size: HFIconography.featureIconSize, weight: .black))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(color == HFColors.gold ? .black : color)
                .frame(width: HFIconography.circularIconFrame, height: HFIconography.circularIconFrame)
                .background(color == HFColors.gold ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(color.opacity(0.18)))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
            Text(title)
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)
            Text(detail)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)
            Text("\(count) titles")
                .font(HFTypography.micro.weight(.bold))
                .foregroundStyle(color)
                .lineLimit(1)
        }
        .frame(width: 188, alignment: .leading)
        .padding(HFSpacing.md)
        .background(Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(color.opacity(0.26), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }

    private func librarySignal(title: String, value: String, systemImage: String, color: Color, identifier: String) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: systemImage)
                .font(HFIconography.symbolFont(size: HFIconography.controlIconSize, weight: .black))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(color)
                .frame(width: HFIconography.actionIconFrame)
            Text(value)
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
            Text(title)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.70)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityIdentifier(identifier)
    }

    private func libraryActivityCard(_ record: HFLibraryActivityRecord) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: record.status == "Last Viewed" ? HFColors.gold.opacity(0.34) : HFColors.cyanGlow.opacity(0.24)) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                HFPosterCard(movie: record.movie, width: 118, showTitle: false, posterOnly: true)
                Text(record.status)
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(record.status == "Last Viewed" ? HFColors.gold : HFColors.cyanGlow)
                    .accessibilityIdentifier(record.status == "Last Viewed" ? "hf.library.lastViewed" : "hf.library.inProgress")
                Text(record.movie.title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                Text(record.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
                if record.status == "Completed" {
                    Text("Completed")
                        .font(HFTypography.micro.weight(.bold))
                        .foregroundStyle(HFColors.gold)
                        .accessibilityIdentifier("hf.library.completed")
                }
            }
            .padding(HFSpacing.sm)
            .frame(width: 152, alignment: .topLeading)
        }
    }

    private func vaultObject(for movie: Movie) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius + 10, strokeColor: HFColors.gold.opacity(0.42)) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous)
                    .fill(reduceTransparency ? Color.black.opacity(0.96) : Color.black.opacity(0.54))
                HFDepthContourOverlay(color: HFColors.gold.opacity(0.58))
                    .opacity(0.24)
                HStack(alignment: .center, spacing: HFSpacing.md) {
                    HFPosterCard(movie: movie, width: usesFallbackLayout ? 100 : 124, showTitle: false, posterOnly: true)
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
            .frame(height: usesFallbackLayout ? 248 : 276)
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
                    ForEach(streamingStore.queryLibraryRecommendations(anchor: selectedMovie, limit: 10)) { movie in
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
        HFContentStateCard(
            kind: .empty,
            title: "Your Library is ready",
            message: "Save a story, start watching, or mark a local offline preview to fill this vault.",
            actionTitle: "Explore HighFive"
        ) {
            onBrowseDiscover?()
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.library.emptyState")
        .accessibilityIdentifier("hf.library.explore")
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
                    inspectorRow(title: "Viewing History", detail: "\(streamingStore.libraryViewingHistory.count) local activity records.", status: "Local", color: HFColors.cyanGlow, identifier: "hf.library.viewingHistory")
                    inspectorRow(title: "Favorites", detail: "\(streamingStore.libraryFavoriteMovies.count) favorite titles inferred from saved originals.", status: "Local", color: HFColors.gold, identifier: "hf.library.favorites")
                    inspectorRow(title: "Watch Later", detail: "\(streamingStore.libraryWatchLaterMovies.count) saved titles waiting to start.", status: "Local", color: HFColors.violet, identifier: "hf.library.watchLater")
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
        HFContentStateCard(
            kind: .placeholder,
            title: "Shelf placeholder",
            message: message,
            isCompact: true
        )
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
