import SwiftUI

struct HomeView: View {
    let selectedProfile: UserProfile
    var onSearch: () -> Void = {}
    var onDiscover: () -> Void = {}
    var onProfile: () -> Void = {}
    var onMyList: () -> Void = {}

    @EnvironmentObject private var streamingStore: HFStreamingStore
    @State private var previewMovie: Movie?
    @State private var showsProtectedDepthPreview = false

    private var heroMovie: Movie {
        streamingStore.featuredMovie
    }

    private var continueWatching: [Movie] {
        streamingStore.allCatalogMovies.filter { $0.progress != nil }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                heroSection
                quickActions
                continueWatchingSection
                ForEach(streamingStore.premiumHomeCatalogRails) { category in
                    movieRail(category)
                }
                discoveryPanel
                activeShelfPanel
            }
            .padding(.top, HFSpacing.xxl)
            .padding(.bottom, HFSpacing.floatingTabClearance + HFSpacing.tabBarHeight)
        }
        .accessibilityIdentifier("hf.consumer.home.root")
        .accessibilityIdentifier("hf.home.screen")
        .background(HFColors.screenBackground.ignoresSafeArea())
        .sheet(item: $previewMovie) { movie in
            HFPlayerServiceSheet(movie: movie)
                .environmentObject(streamingStore)
        }
        .sheet(isPresented: $showsProtectedDepthPreview) {
            HighFiveProtectedSpatialPeekBridge()
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
                    .frame(height: 510)
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous))

                HFColors.cinematicGoldScrim
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous))

                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.28), Color.black.opacity(0.96)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack {
                        Text(heroMovie.isOriginal ? "HIGHFIVE ORIGINAL" : "FEATURED")
                            .font(HFTypography.micro)
                            .foregroundStyle(.black)
                            .padding(.horizontal, HFSpacing.sm)
                            .frame(height: 26)
                            .background(HFColors.goldGradient)
                            .clipShape(Capsule())
                        Spacer()
                        HFPosterCard(movie: heroMovie, width: 76, showTitle: false, posterOnly: true)
                            .rotationEffect(.degrees(6))
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: HFSpacing.sm) {
                        Text("Tonight on HighFive")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)
                            .textCase(.uppercase)
                            .accessibilityIdentifier("hf.home.tonightOnHighFive")
                        Text(heroMovie.title)
                            .font(.system(size: 40, weight: .black))
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.68)
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
                            Button {
                                streamingStore.markStartedWatching(heroMovie)
                                previewMovie = heroMovie
                            } label: {
                                Label("Watch Now", systemImage: "play.fill")
                                    .font(.system(size: 15, weight: .black))
                                    .foregroundStyle(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(HFColors.goldGradient)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("hf.functional.player.watchNow")
                            .accessibilityIdentifier("hf.route.watchNow")

                            Button {
                                streamingStore.toggleSaved(heroMovie)
                            } label: {
                                Image(systemName: streamingStore.isSaved(heroMovie) ? "checkmark" : "plus")
                                    .font(.system(size: 18, weight: .black))
                                    .foregroundStyle(HFColors.textPrimary)
                                    .frame(width: 54, height: 50)
                                    .background(Color.white.opacity(0.14))
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(streamingStore.isSaved(heroMovie) ? "Remove from My List" : "Add to My List")
                        }

                        Button {
                            showsProtectedDepthPreview = true
                        } label: {
                            Label("Try Depth + Peek", systemImage: "cube.transparent")
                                .font(HFTypography.smallAction)
                                .foregroundStyle(HFColors.textPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.black.opacity(0.42))
                                .overlay(Capsule().stroke(HFColors.gold.opacity(0.32), lineWidth: 1))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Try Depth and Peek local preview")
                        .accessibilityIdentifier("hf.home.depthPeekCTA")
                    }
                }
                .padding(HFSpacing.lg)
            }
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous)
                    .stroke(HFColors.gold.opacity(0.52), lineWidth: 1)
            )
            .shadow(color: HFColors.amberGlow.opacity(0.25), radius: 26, x: 0, y: 18)
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("hf.consumer.home.hero")
        .accessibilityIdentifier("hf.home.signatureHero")
        .accessibilityIdentifier("hf.route.homeToMovieDetail")
    }

    private var quickActions: some View {
        HStack(spacing: HFSpacing.sm) {
            actionTile(title: "Discover", value: "\(streamingStore.allCatalogMovies.count)", systemImage: "sparkles.tv.fill", action: onDiscover)
            actionTile(title: "My List", value: "\(streamingStore.savedMovies.count)", systemImage: "bookmark.fill", action: onMyList)
            actionTile(title: "Offline", value: "\(streamingStore.downloadedMovies.count)", systemImage: "arrow.down.circle.fill", action: {})
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
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
