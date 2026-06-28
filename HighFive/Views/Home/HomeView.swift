import SwiftUI

struct HomeView: View {
    let selectedProfile: UserProfile
    var onSearch: () -> Void = {}
    var onDiscover: () -> Void = {}
    var onProfile: () -> Void = {}
    var onMyList: () -> Void = {}
    var onDownloads: () -> Void = {}

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var streamingStore: HFStreamingStore
    @State private var previewMovie: Movie?
    @State private var showsProtectedDepthPreview = false
    @State private var isHeroAwake = false

    private let showsCollectionsFirst = ProcessInfo.processInfo.arguments.contains("--hf-premium-streaming-collections")
    private let showsFPPStateQA = ProcessInfo.processInfo.arguments.contains("--hf-fpp-loading-states")

    private var heroMovie: Movie {
        streamingStore.featuredMovie
    }

    private var continueWatching: [Movie] {
        streamingStore.catalogRuntimeMovies(filter: "Progress", sort: .progress, pageSize: 10)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.sectionGap) {
                heroSection
                if showsFPPStateQA {
                    loadingStateQASurface
                }
                if showsCollectionsFirst {
                    collectionWorlds
                    premiumBrandSystem
                } else {
                    premiumBrandSystem
                }
                premiumStreamingRails
                streamingCommandSurface
                continueWatchingSection
                ForEach(streamingStore.premiumHomeCatalogRails) { category in
                    movieRail(category)
                }
            }
            .padding(.bottom, HFSpacing.floatingTabClearance + HFSpacing.tabBarHeight)
        }
        .accessibilityIdentifier("hf.spatial.home")
        .accessibilityIdentifier("hf.streaming.premium.home")
        .background(HFColors.screenBackground.ignoresSafeArea())
        .sheet(item: $previewMovie) { movie in
            HFPlayerServiceSheet(movie: movie)
                .environmentObject(streamingStore)
        }
        .sheet(isPresented: $showsProtectedDepthPreview) {
            HighFiveProtectedSpatialPeekBridge()
        }
        .onAppear {
            guard !isHeroAwake else { return }
            withAnimation(reduceMotion ? .easeInOut(duration: 0.01) : HFSpatialMotionTokens.sceneEntranceAnimation) {
                isHeroAwake = true
            }
        }
    }

    private var header: some View {
        HStack(spacing: HFSpacing.sm) {
            ZStack {
                Circle()
                    .fill(HFColors.goldGradient)
                Image(systemName: "bolt.fill")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(.black)
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                Text("HIGHFIVE")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(HFColors.gold)
                Text("Cinema for \(selectedProfile.name)")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
            }

            Spacer()

            backendStatusChip

            Button(action: onSearch) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.10))
                    .clipShape(Circle())
            }
            .accessibilityLabel("Search")

            Button(action: onProfile) {
                Image(systemName: selectedProfile.avatarSystemName)
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
                    .background(HFColors.goldGradient)
                    .clipShape(Circle())
            }
            .accessibilityLabel("Profile")
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var backendStatusChip: some View {
        HStack(spacing: 5) {
            Image(systemName: streamingStore.backendStatus.systemImage)
                .font(.system(size: 10, weight: .black))
            Text(streamingStore.backendStatus.statusLabel)
                .font(HFTypography.micro)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
        }
        .foregroundStyle(streamingStore.backendStatus.isConfigured ? .black : HFColors.gold)
        .padding(.horizontal, HFSpacing.xs)
        .frame(height: 28)
        .background(streamingStore.backendStatus.isConfigured ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(Color.white.opacity(0.10)))
        .overlay(Capsule().stroke(HFColors.gold.opacity(0.26), lineWidth: 1))
        .clipShape(Capsule())
        .accessibilityIdentifier("hf.home.backendStatus")
    }

    private var heroSection: some View {
        NavigationLink(value: heroMovie) {
            ZStack(alignment: .bottomLeading) {
                heroArtwork(heroMovie)
                    .frame(height: 392)
                    .scaleEffect(reduceMotion ? 1 : (isHeroAwake ? 1.045 : 1.0))
                    .offset(x: reduceMotion ? 0 : (isHeroAwake ? -8 : 8), y: reduceMotion ? 0 : (isHeroAwake ? -5 : 4))
                    .accessibilityIdentifier("hf.spatial.home.backgroundPlane")

                heroArtwork(heroMovie)
                    .frame(width: 152, height: 226)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(HFColors.gold.opacity(0.48), lineWidth: 1)
                    )
                    .rotationEffect(.degrees(reduceMotion ? 0 : (isHeroAwake ? 3 : -2)))
                    .offset(x: reduceMotion ? 140 : (isHeroAwake ? 146 : 134), y: reduceMotion ? -64 : (isHeroAwake ? -70 : -58))
                    .shadow(color: HFColors.amberGlow.opacity(0.26), radius: 26, x: 0, y: 16)
                    .accessibilityIdentifier("hf.spatial.home.subjectPlane")

                LinearGradient(
                    colors: [
                        Color.black.opacity(0.02),
                        Color.black.opacity(0.30),
                        Color.black.opacity(0.88),
                        HFColors.background
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                HFColors.cinematicGoldScrim
                    .opacity(0.72)

                HFDepthContourOverlay(color: HFColors.cyanGlow)
                    .opacity(0.72)

                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.62)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(HFColors.goldGradient)
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 18, weight: .black))
                                .foregroundStyle(.black)
                        }
                        .frame(width: 40, height: 40)

                        Text("HIGHFIVE")
                            .font(.system(size: 18, weight: .black))
                            .foregroundStyle(HFColors.gold)

                        Spacer()

                        Button(action: onSearch) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(HFColors.textPrimary)
                                .frame(width: 44, height: 44)
                                .background(Color.black.opacity(0.48))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Search")

                        Button(action: onProfile) {
                            Image(systemName: selectedProfile.avatarSystemName)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.black)
                                .frame(width: 44, height: 44)
                                .background(HFColors.goldGradient)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Profile")
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: HFSpacing.sm) {
                        Text(heroMovie.isOriginal ? "HIGHFIVE ORIGINAL" : "FEATURED")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)
                            .textCase(.uppercase)
                        Text(heroMovie.title)
                            .font(.system(size: 42, weight: .black))
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.54)
                        Text(heroMovie.subtitle)
                            .font(HFTypography.body)
                            .foregroundStyle(HFColors.textSecondary)
                            .lineLimit(2)

                        HStack(spacing: HFSpacing.xs) {
                            heroChip(heroMovie.rating)
                            heroChip(heroMovie.duration)
                            heroChip(heroMovie.genres.first ?? "Cinema")
                        }

                        HStack(spacing: HFSpacing.xs) {
                            HFEnergyAction(title: "Watch", systemImage: "play.fill", style: .gold) {
                                streamingStore.markStartedWatching(heroMovie)
                                previewMovie = heroMovie
                            }
                            .accessibilityIdentifier("hf.spatial.home.watch")

                            HFEnergyAction(title: "Depth", systemImage: "cube.transparent", style: .cyan) {
                                showsProtectedDepthPreview = true
                            }
                            .accessibilityIdentifier("hf.spatial.home.depth")

                            HFEnergyAction(
                                title: streamingStore.isSaved(heroMovie) ? "Saved" : "Save",
                                systemImage: streamingStore.isSaved(heroMovie) ? "checkmark" : "plus",
                                style: .glass
                            ) {
                                streamingStore.toggleSaved(heroMovie)
                            }
                            .accessibilityLabel(streamingStore.isSaved(heroMovie) ? "Remove from My List" : "Add to My List")
                            .accessibilityIdentifier("hf.spatial.home.save")
                        }
                    }
                    .accessibilityIdentifier("hf.spatial.home.foregroundPlane")
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
                .padding(.top, HFSpacing.xl)
                .padding(.bottom, HFSpacing.lg)
            }
            .frame(height: 392)
            .clipped()
            .hfSpatialSceneEntrance(isActive: isHeroAwake, reduceMotion: reduceMotion)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(heroMovie.title), \(heroMovie.subtitle)")
        .accessibilityIdentifier("hf.spatial.home.hero")
        .accessibilityIdentifier("hf.streaming.premium.heroTheater")
        .hfSpatialFocalHandoff("hf.spatial.handoff.homeToMovie")
    }

    private var premiumBrandSystem: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "sparkles.tv.fill")
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(.black)
                        .frame(width: 54, height: 54)
                        .background(HFColors.goldGradient)
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("HighFive Premium")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Originals, premieres, collections, and local continue-watching paths share one cinematic service layer.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                HStack(spacing: HFSpacing.xs) {
                    premiumSignal(title: "Originals", value: "\(streamingStore.originalsCatalog.count)", color: HFColors.gold)
                    premiumSignal(title: "Catalog", value: "\(streamingStore.catalogRuntimeSnapshot.totalTitles)", color: HFColors.cyanGlow)
                    premiumSignal(title: "Saved", value: "\(streamingStore.savedMovies.count)", color: HFColors.violet)
                }
            }
            .padding(HFSpacing.md)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("HighFive premium streaming brand system")
        .accessibilityIdentifier("hf.streaming.premium.brandSystem")
    }

    private var premiumStreamingRails: some View {
        VStack(alignment: .leading, spacing: HFSpacing.lg) {
            premiumRail(
                title: "HighFive Originals",
                subtitle: "Only on HighFive",
                movies: streamingStore.originalsCatalog.filter { !$0.isComingSoon },
                identifier: "hf.streaming.premium.originalsRail"
            )
            premiumRail(
                title: "Premiere Previews",
                subtitle: "Featured local catalog",
                movies: streamingStore.catalogRuntimeMovies(filter: "Premieres", sort: .recentlyPublished, pageSize: 10),
                identifier: "hf.streaming.premium.premieresRail"
            )
            premiumRail(
                title: "Trending Now",
                subtitle: "Tonight's local picks",
                movies: streamingStore.catalogRuntimeMovies(sort: .editorial, pageSize: 8),
                identifier: "hf.streaming.premium.trendingRail"
            )
            premiumRail(
                title: "Creator Spotlight",
                subtitle: "Creator-led stories",
                movies: Array(streamingStore.queryCatalog().filter { $0.creatorName == heroMovie.creatorName }.prefix(8)),
                identifier: "hf.streaming.premium.creatorSpotlightRail"
            )
            premiumRail(
                title: "Award Winners",
                subtitle: "Editorial collection",
                movies: streamingStore.catalogRuntimeMovies(sort: .recentlyPublished, pageSize: 8),
                identifier: "hf.streaming.premium.awardWinnersRail"
            )
            collectionWorlds
        }
    }

    private func premiumRail(title: String, subtitle: String, movies: [Movie], identifier: String) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: title, actionTitle: subtitle)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    ForEach((movies.isEmpty ? streamingStore.catalogRuntimeMovies(pageSize: 10) : movies).prefix(10)) { movie in
                        NavigationLink(value: movie) {
                            HFPosterCard(movie: movie, width: 148, showMetadata: true, showProgress: movie.progress != nil)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
        .accessibilityIdentifier(identifier)
    }

    private var collectionWorlds: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Collection Worlds", actionTitle: "Editorial")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HFSpacing.md) {
                    collectionWorldCard(title: "Gold Room", detail: "Prestige originals", color: HFColors.gold, systemImage: "sparkles.tv.fill")
                    collectionWorldCard(title: "Deep Space", detail: "Spatial cinema", color: HFColors.cyanGlow, systemImage: "cube.transparent")
                    collectionWorldCard(title: "Creator Cuts", detail: "Artist-led picks", color: HFColors.violet, systemImage: "wand.and.stars.inverse")
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
        .accessibilityIdentifier("hf.streaming.premium.collectionWorlds")
    }

    private var loadingStateQASurface: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "State System", actionTitle: "FPP-07")
            HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.cyanGlow.opacity(0.36)) {
                VStack(spacing: 5) {
                    stateQARow(.loading, title: "Loading", detail: "Catalog preparing")
                    stateQARow(.empty, title: "Empty", detail: "Shelf explains next step")
                    stateQARow(.retry, title: "Retry", detail: "Recoverable action shown")
                    stateQARow(.offline, title: "Offline", detail: "Local fallback visible")
                    stateQARow(.progress(0.68), title: "Progress", detail: "Determinate status")
                    stateQARow(.placeholder, title: "Placeholder", detail: "No blank gaps")
                }
                .padding(HFSpacing.sm)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityIdentifier("hf.fpp.loadingStates")
    }

    private func stateQARow(_ kind: HFContentStateKind, title: String, detail: String) -> some View {
        HStack(spacing: HFSpacing.sm) {
            Image(systemName: kind.systemImage)
                .font(HFIconography.symbolFont(size: HFIconography.smallIconSize, weight: .black))
                .foregroundStyle(kind.accent)
                .frame(width: 28, height: 28)
                .background(kind.accent.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textPrimary)
                Text(detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
            }
            Spacer()
            if let progress = kind.progressValue {
                ProgressView(value: progress)
                    .tint(kind.accent)
                    .frame(width: 64)
                    .accessibilityLabel("Progress preview")
            } else {
                Text(kind.label)
                    .font(HFTypography.micro)
                    .foregroundStyle(kind.accent)
                    .padding(.horizontal, HFSpacing.xs)
                    .frame(minHeight: 24)
                    .background(kind.accent.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, HFSpacing.xs)
        .padding(.vertical, 6)
        .background(HFColors.quietFill)
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
    }

    private func premiumSignal(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
            Text(title)
                .font(HFTypography.micro)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.xs)
        .background(Color.black.opacity(0.28))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
    }

    private func collectionWorldCard(title: String, detail: String, color: Color, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(color == HFColors.gold ? .black : color)
                .frame(width: 48, height: 48)
                .background(color == HFColors.gold ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(color.opacity(0.18)))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
            Text(title)
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)
            Text(detail)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
        }
        .frame(width: 190, alignment: .leading)
        .padding(HFSpacing.md)
        .background(Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(color.opacity(0.28), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }

    private var streamingCommandSurface: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.36)) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "sparkles.tv.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(.black)
                        .frame(width: 50, height: 50)
                        .background(HFColors.goldGradient)
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text("Streaming Command")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Browse the local catalog, return to saved stories, or continue local offline previews without leaving the five-tab shell.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)

                        HFSpatialRouteBadge(title: "Home -> Detail", accent: HFColors.gold)
                    }
                }

                HStack(spacing: HFSpacing.sm) {
                    actionTile(title: "Discover", value: "\(streamingStore.catalogRuntimeSnapshot.totalTitles)", systemImage: "sparkles", action: onDiscover)
                    actionTile(title: "Library", value: "\(streamingStore.savedMovies.count)", systemImage: "bookmark.fill", action: onMyList)
                    actionTile(title: "Offline", value: "\(streamingStore.downloadedMovies.count)", systemImage: "arrow.down.circle.fill", action: onDownloads)
                }

                HStack(spacing: HFSpacing.sm) {
                    Image(systemName: selectedProfile.avatarSystemName)
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(.black)
                        .frame(width: 38, height: 38)
                        .background(HFColors.goldGradient)
                        .clipShape(Circle())
                    Text("Watching as \(selectedProfile.name)")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                    Spacer()
                    Text("Local Preview")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.gold)
                        .padding(.horizontal, HFSpacing.xs)
                        .frame(height: 24)
                        .background(HFColors.gold.opacity(0.12))
                        .clipShape(Capsule())
                }
            }
            .padding(HFSpacing.md)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.home.streamingCommand")
    }

    private func actionTile(title: String, value: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(HFColors.gold)
                Text(value)
                    .font(HFTypography.section)
                    .foregroundStyle(HFColors.textPrimary)
                Text(title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(HFSpacing.sm)
            .background(Color.black.opacity(0.54))
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                    .stroke(HFColors.gold.opacity(0.24), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var continueWatchingSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Continue Watching", actionTitle: continueWatching.isEmpty ? "Ready" : nil)
            if continueWatching.isEmpty {
                HFContentStateCard(
                    kind: .progress(1),
                    title: "Continue Watching is ready",
                    message: "Playback progress will appear here after a local preview starts.",
                    isCompact: true
                )
                .padding(.horizontal, HFSpacing.screenHorizontal)
                .accessibilityIdentifier("hf.home.continueWatching.placeholder")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: HFSpacing.md) {
                        ForEach(continueWatching) { movie in
                            NavigationLink(value: movie) {
                                HFMovieCard(movie: movie)
                                    .frame(width: 304)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, HFSpacing.screenHorizontal)
                }
            }
        }
        .accessibilityIdentifier("hf.streaming.premium.continueWatchingRail")
    }

    private func movieRail(_ category: Category) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: category.title, actionTitle: category.subtitle)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    ForEach(category.movies) { movie in
                        NavigationLink(value: movie) {
                            HFPosterCard(movie: movie, width: HFSpacing.posterRailWidth, showProgress: movie.progress != nil)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
        .accessibilityIdentifier("hf.home.curatedRails")
    }
    private func heroChip(_ title: String) -> some View {
        Text(title)
            .font(HFTypography.caption)
            .foregroundStyle(HFColors.textPrimary)
            .lineLimit(1)
            .padding(.horizontal, HFSpacing.sm)
            .frame(height: 30)
            .background(Color.white.opacity(0.14))
            .clipShape(Capsule())
    }

    @ViewBuilder
    private func heroArtwork(_ movie: Movie) -> some View {
        if HFPosterAssetHealth.hasImage(named: movie.backdropAssetName ?? movie.posterAssetName),
           let assetName = movie.backdropAssetName ?? movie.posterAssetName {
            Image(assetName)
                .resizable()
                .scaledToFill()
        } else {
            HFPosterFallback(title: movie.title)
        }
    }
}

private struct HFStreamingStatusPill: View {
    let title: String
    let identifier: String

    var body: some View {
        Text(title)
            .font(HFTypography.micro)
            .foregroundStyle(HFColors.gold)
            .lineLimit(1)
            .minimumScaleFactor(0.68)
            .padding(.horizontal, HFSpacing.xs)
            .frame(height: 24)
            .background(HFColors.gold.opacity(0.10))
            .clipShape(Capsule())
            .accessibilityIdentifier(identifier)
    }
}
