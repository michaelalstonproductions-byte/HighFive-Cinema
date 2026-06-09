import SwiftUI

struct HomeView: View {
    let selectedProfile: UserProfile
    var onSearch: () -> Void = {}
    var onDiscover: () -> Void = {}
    var onProfile: () -> Void = {}
    var onMyList: () -> Void = {}
    @EnvironmentObject private var streamingStore: HFStreamingStore
    @State private var previewMovie: Movie?
    @State private var showsNotifications = false
    @StateObject private var notificationStore = HFNotificationCenterStore()

    private var heroMovie: Movie {
        HFMockData.movie("friendly") ?? HFMockData.movies[0]
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: HFSpacing.xl) {
                header
                homeCategoryPills
                heroSection
                todaySection
                watchSectionHeader

                ForEach(HFMockData.premiumHomeRails) { category in
                    movieRail(category)
                }

                smartRecommendationsSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .sheet(item: $previewMovie) { movie in
            HFMockPlayerSheet(movie: movie)
        }
        .sheet(isPresented: $showsNotifications) {
            HFNotificationSheet(store: notificationStore)
        }
    }

    private var header: some View {
        HStack(spacing: HFSpacing.md) {
            ZStack {
                Circle()
                    .fill(HFColors.goldGradient)
                Image(systemName: "film.stack.fill")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(.black)
            }
            .frame(width: 50, height: 50)

            VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                Text("HIGHFIVE CINEMA")
                    .font(.system(size: 20, weight: .black, design: .default))
                    .kerning(0.8)
                Text("Premium stories. Ready now.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
            }
            .foregroundStyle(HFColors.gold)

            Spacer()

            HStack(spacing: HFSpacing.md) {
                Button(action: onSearch) {
                    Image(systemName: "magnifyingglass")
                }
                .accessibilityLabel("Search")

                Button {
                    showsNotifications = true
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell.fill")
                        HFUnreadBadge(count: notificationStore.unreadCount)
                            .offset(x: 10, y: -10)
                    }
                }
                .accessibilityLabel("Notifications")

                Button(action: onProfile) {
                    Image(systemName: selectedProfile.avatarSystemName)
                }
                .accessibilityLabel("Profile")
            }
            .font(.system(size: 25, weight: .bold))
            .foregroundStyle(HFColors.textPrimary)
            .buttonStyle(.plain)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var homeCategoryPills: some View {
        HStack(spacing: HFSpacing.sm) {
            ForEach(["Movies", "Series", "Originals"], id: \.self) { title in
                Text(title)
                    .font(HFTypography.smallAction)
                    .foregroundStyle(title == "Movies" ? .black : HFColors.textPrimary)
                    .padding(.horizontal, HFSpacing.md)
                    .frame(height: 34)
                    .background(title == "Movies" ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(Color.white.opacity(0.10)))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(title == "Movies" ? Color.clear : HFColors.glassStroke, lineWidth: 1)
                    )
            }

            Spacer()
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Home categories Movies, Series, Originals")
    }

    private var todaySection: some View {
        HFTodaySummaryCard(items: HFEcosystemPreviewData.todaySummaryItems)
            .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var watchSectionHeader: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Watch", actionTitle: nil)

            HStack(spacing: HFSpacing.sm) {
                Button(action: onDiscover) {
                    HFRouteChip(title: "Open Discover", systemImage: "sparkles")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open Discover")

                Button(action: onMyList) {
                    HFRouteChip(title: "View My List", systemImage: "bookmark.fill")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("View My List")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var smartRecommendationsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "For You", actionTitle: nil)

            Button(action: onDiscover) {
                HFActionTile(
                    title: "Recommended For You",
                    subtitle: "More originals, premieres, and saved titles selected for your next watch.",
                    systemImage: "sparkles"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Discover recommendations")
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            NavigationLink(value: heroMovie) {
                heroArtwork(heroMovie)
                    .frame(height: HFSpacing.heroHeight)
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous))
            }
            .buttonStyle(.plain)

            HFColors.heroGradient
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous))
                .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    Spacer()

                NavigationLink(value: heroMovie) {
                    VStack(alignment: .leading, spacing: HFSpacing.sm) {
                        Text("FEATURED PREMIERE")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)
                            .kerning(1.6)

                        Text(heroMovie.title)
                            .font(HFTypography.heroTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.72)

                        Text(heroMovie.subtitle)
                            .font(HFTypography.body)
                            .foregroundStyle(HFColors.textSecondary)
                            .lineLimit(1)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: HFSpacing.xs) {
                            ForEach([heroMovie.rating, heroMovie.duration, "Original"], id: \.self) { badge in
                                Text(badge)
                                    .font(HFTypography.caption)
                                    .foregroundStyle(.black)
                                    .padding(.horizontal, HFSpacing.sm)
                                    .frame(height: 30)
                                    .background(HFColors.goldGradient)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                .buttonStyle(.plain)

                HStack(spacing: HFSpacing.sm) {
                    Button {
                        previewMovie = heroMovie
                    } label: {
                        HStack(spacing: HFSpacing.xs) {
                            Image(systemName: "play.fill")
                            Text("Watch Now")
                        }
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(HFColors.goldGradient)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Watch Now")

                    HFButton(
                        streamingStore.isSaved(heroMovie) ? "In My List" : "Save",
                        systemImage: streamingStore.isSaved(heroMovie) ? "checkmark" : "plus",
                        style: .secondary
                    ) {
                        streamingStore.toggleSaved(heroMovie)
                    }
                    .accessibilityLabel(streamingStore.isSaved(heroMovie) ? "Remove from My List" : "Add to My List")
                }
            }
            .padding(HFSpacing.lg)
        }
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous)
                .stroke(HFColors.goldStroke, lineWidth: 1)
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func movieRail(_ category: Category) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: category.title)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    ForEach(category.movies) { movie in
                        if category.id == "continue-watching" {
                            Button {
                                previewMovie = movie
                            } label: {
                                HFPosterCard(movie: movie, width: HFSpacing.posterRailWidth, showProgress: true)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Continue watching \(movie.title)")
                        } else {
                            NavigationLink(value: movie) {
                                HFPosterCard(movie: movie, width: HFSpacing.posterRailWidth, showProgress: category.id == "continue")
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Open \(movie.title)")
                        }
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
            .scrollClipDisabled()
        }
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
