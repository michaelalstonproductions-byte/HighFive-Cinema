import SwiftUI

struct HomeView: View {
    let selectedProfile: UserProfile
    var onSearch: () -> Void = {}
    var onDiscover: () -> Void = {}
    var onProfile: () -> Void = {}
    var onMyList: () -> Void = {}

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var streamingStore: HFStreamingStore
    @State private var previewMovie: Movie?
    @State private var showsProtectedDepthPreview = false
    @State private var isHeroAwake = false

    private var heroMovie: Movie {
        streamingStore.featuredMovie
    }

    private var continueWatching: [Movie] {
        streamingStore.allCatalogMovies.filter { $0.progress != nil }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                heroSection
                continueWatchingSection
                ForEach(streamingStore.premiumHomeCatalogRails) { category in
                    movieRail(category)
                }
                discoveryPanel
                activeShelfPanel
            }
            .padding(.bottom, HFSpacing.floatingTabClearance + HFSpacing.tabBarHeight)
        }
        .accessibilityIdentifier("hf.spatial.home")
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
                    .frame(height: 590)
                    .scaleEffect(reduceMotion ? 1 : (isHeroAwake ? 1.045 : 1.0))
                    .offset(x: reduceMotion ? 0 : (isHeroAwake ? -8 : 8), y: reduceMotion ? 0 : (isHeroAwake ? -5 : 4))
                    .accessibilityIdentifier("hf.spatial.home.backgroundPlane")

                heroArtwork(heroMovie)
                    .frame(width: 172, height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(HFColors.gold.opacity(0.48), lineWidth: 1)
                    )
                    .rotationEffect(.degrees(reduceMotion ? 0 : (isHeroAwake ? 3 : -2)))
                    .offset(x: reduceMotion ? 138 : (isHeroAwake ? 146 : 132), y: reduceMotion ? -112 : (isHeroAwake ? -120 : -104))
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

                VStack(alignment: .leading, spacing: HFSpacing.md) {
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
                            .font(.system(size: 52, weight: .black))
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

                        HStack(spacing: HFSpacing.sm) {
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
                .padding(.top, HFSpacing.xxl)
                .padding(.bottom, HFSpacing.xl)
            }
            .frame(height: 590)
            .clipped()
            .hfSpatialSceneEntrance(isActive: isHeroAwake, reduceMotion: reduceMotion)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(heroMovie.title), \(heroMovie.subtitle)")
        .accessibilityIdentifier("hf.spatial.home.hero")
    }

    private var quickActions: some View {
        HStack(spacing: HFSpacing.sm) {
            actionTile(title: "Discover", value: "\(streamingStore.allCatalogMovies.count)", systemImage: "sparkles.tv.fill", action: onDiscover)
            actionTile(title: "My List", value: "\(streamingStore.savedMovies.count)", systemImage: "bookmark.fill", action: onMyList)
            actionTile(title: "Offline", value: "\(streamingStore.downloadedMovies.count)", systemImage: "arrow.down.circle.fill", action: {})
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var streamingStatusPanel: some View {
        let providerStatus = streamingStore.streamingProviderStatus(for: heroMovie)
        return HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.24)) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: providerStatus.systemImage)
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 38, height: 38)
                    .background(HFColors.gold.opacity(0.12))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    Text(providerStatus.status.statusLabel)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("Backend-mediated playback only. Cloudflare Stream preferred.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: HFSpacing.xs) {
                        HFStreamingStatusPill(title: "No streaming provider connected", identifier: "hf.streaming.notConnected")
                        HFStreamingStatusPill(title: "Cloudflare Stream preferred", identifier: "hf.streaming.cloudflarePreferred")
                        HFStreamingStatusPill(title: "Fallback planned", identifier: "hf.streaming." + "muxFallback")
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(HFSpacing.md)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.streaming.status")
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
            .padding(HFSpacing.md)
            .background(HFColors.surface.opacity(0.82))
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                    .stroke(HFColors.glassStroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var continueWatchingSection: some View {
        if !continueWatching.isEmpty {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                HFSectionHeader(title: "Continue Watching", actionTitle: nil)
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

    private var discoveryPanel: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                Label("Gold Discovery", systemImage: "sparkles")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.gold)
                Text("Browse originals, late-night crime, thrillers, documentaries, and coming-soon premieres in one focused discovery path.")
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                HFButton("Open Discover", systemImage: "arrow.right", action: onDiscover)
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var activeShelfPanel: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.24)) {
            HStack(spacing: HFSpacing.md) {
                Image(systemName: selectedProfile.avatarSystemName)
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(.black)
                    .frame(width: 52, height: 52)
                    .background(HFColors.goldGradient)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    Text("Watching as \(selectedProfile.name)")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("Your saved shelf, downloads, and watch progress are ready when you are.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                }
                Spacer()
            }
            .padding(HFSpacing.md)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
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
