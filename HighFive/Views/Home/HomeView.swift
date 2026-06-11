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

    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }

    private var screenPadding: CGFloat {
        HFResponsiveFit.safeHorizontalPadding(width: screenWidth)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: HFSpacing.xl) {
                header
                homeCategoryPills
                homePremiereMetrics
                heroSection
                tonightFeatureSection
                programmingPulseSection
                homeStreamingMomentumSection
                watchSectionHeader

                ForEach(HFMockData.premiumHomeRails) { category in
                    movieRail(category)
                }
                .accessibilityIdentifier("hf.consumer.home.posterRails")

                goldDiscoveryRail
                smartRecommendationsSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .accessibilityIdentifier("hf.consumer.home.root")
        .background(HFColors.screenBackground.ignoresSafeArea())
        .sheet(item: $previewMovie) { movie in
            HFMockPlayerSheet(movie: movie)
        }
        .sheet(isPresented: $showsNotifications) {
            HFNotificationSheet(store: notificationStore)
        }
    }

    private var header: some View {
        HStack(spacing: HFSpacing.sm) {
            ZStack {
                Circle()
                    .fill(HFColors.goldGradient)
                Image(systemName: "film.stack.fill")
                    .font(.system(size: HFResponsiveFit.headerIconSize(width: screenWidth) - 4, weight: .black))
                    .foregroundStyle(.black)
            }
            .frame(
                width: HFResponsiveFit.headerLogoSize(width: screenWidth),
                height: HFResponsiveFit.headerLogoSize(width: screenWidth)
            )
            .layoutPriority(1)

            VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                Text("HIGHFIVE CINEMA")
                    .font(.system(size: HFResponsiveFit.isCompactPhone(width: screenWidth) ? 18 : 20, weight: .black, design: .default))
                    .kerning(0.4)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
                Text("Streaming now.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .foregroundStyle(HFColors.gold)
            .layoutPriority(2)

            Spacer(minLength: HFSpacing.xs)

            HStack(spacing: HFResponsiveFit.isLargePhone(width: screenWidth) ? HFSpacing.xxs : 0) {
                Button(action: onSearch) {
                    Image(systemName: "magnifyingglass")
                        .frame(width: HFResponsiveFit.minimumTapTarget, height: HFResponsiveFit.minimumTapTarget)
                }
                .accessibilityLabel("Search")

                Button {
                    showsNotifications = true
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell.fill")
                            .frame(width: HFResponsiveFit.minimumTapTarget, height: HFResponsiveFit.minimumTapTarget)
                        HFUnreadBadge(count: notificationStore.unreadCount)
                            .offset(x: 7, y: -7)
                    }
                }
                .accessibilityLabel("Notifications")

                Button(action: onProfile) {
                    Image(systemName: selectedProfile.avatarSystemName)
                        .frame(width: HFResponsiveFit.minimumTapTarget, height: HFResponsiveFit.minimumTapTarget)
                }
                .accessibilityLabel("Profile")
            }
            .font(.system(size: HFResponsiveFit.headerIconSize(width: screenWidth), weight: .bold))
            .foregroundStyle(HFColors.textPrimary)
            .buttonStyle(.plain)
        }
        .padding(.horizontal, screenPadding)
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
        .padding(.horizontal, screenPadding)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Home categories Movies, Series, Originals")
    }

    private var homePremiereMetrics: some View {
        HStack(spacing: HFSpacing.sm) {
            HFHomeMetricPill(value: "\(HFMockData.movies.filter(\.isOriginal).count)", label: "Originals", systemImage: "sparkles")
            HFHomeMetricPill(value: "\(HFMockData.movies.filter { $0.progress != nil }.count)", label: "In Progress", systemImage: "play.circle.fill")
            HFHomeMetricPill(value: "\(HFMockData.movies.filter(\.isDownloaded).count)", label: "Offline", systemImage: "arrow.down.circle.fill")
        }
        .padding(.horizontal, screenPadding)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Home summary, originals, in progress titles, and offline titles")
    }

    private var programmingPulseSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.44)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Tonight on HighFive")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("A curated slate of premieres, originals, and saved titles ready for the next watch.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: HFSpacing.sm)

                    Image(systemName: "sparkles.tv.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 38, height: 38)
                        .background(HFColors.gold.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 138), spacing: HFSpacing.xs)], alignment: .leading, spacing: HFSpacing.xs) {
                    HFHomeCommandCard(title: "Featured Premiere", subtitle: "Your next watch starts here.", systemImage: "play.fill", isActive: true)
                    HFHomeCommandCard(title: "Pick Up Where You Left Off", subtitle: "Continue the story.", systemImage: "play.circle.fill")
                    HFHomeCommandCard(title: "HighFive Originals", subtitle: "Premium local slate.", systemImage: "star.fill")
                    HFHomeCommandCard(title: "New This Week", subtitle: "Fresh premieres.", systemImage: "calendar")
                    HFHomeCommandCard(title: "Because You Watched", subtitle: "More like your mood.", systemImage: "sparkles")
                }
            }
            .padding(HFSpacing.lg)
            .background(
                LinearGradient(
                    colors: [HFColors.warmGlow.opacity(0.24), Color.clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Tonight on HighFive, curated premieres, originals, and saved titles")
        .accessibilityIdentifier("hf.consumer.home.tonight")
    }

    private var homeStreamingMomentumSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Streaming Momentum", actionTitle: nil)

            VStack(spacing: HFSpacing.xs) {
                HFConsumerMomentumRow(title: "Featured title ready", detail: heroMovie.title, status: "Ready", systemImage: "sparkles.tv.fill")
                HFConsumerMomentumRow(title: "Saved shelf active", detail: "My List is one tap away.", status: "Active", systemImage: "bookmark.fill")
                HFConsumerMomentumRow(title: "Originals highlighted", detail: "HighFive Originals anchor the home rail.", status: "Featured", systemImage: "star.fill")
                HFConsumerMomentumRow(title: "Offline shelf preview", detail: "Offline picks stay visible in the viewing path.", status: "Preview", systemImage: "arrow.down.circle.fill")
                HFConsumerMomentumRow(title: "Discovery path ready", detail: "Search and Discover lead into the next watch.", status: "Ready", systemImage: "magnifyingglass")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Home streaming momentum, featured title, saved shelf, originals, offline shelf, and discovery path")
        .accessibilityIdentifier("hf.consumer.home.momentum")
    }

    private var watchSectionHeader: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Start Watching", actionTitle: nil)

            HStack(spacing: HFSpacing.sm) {
                Button(action: onDiscover) {
                    HFRouteChip(title: "Browse Premieres", systemImage: "sparkles")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Browse premieres")

                Button(action: onMyList) {
                    HFRouteChip(title: "My List", systemImage: "bookmark.fill")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open My List")
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
            RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous)
                .fill(HFColors.warmGlow.opacity(0.36))
                .blur(radius: 24)
                .offset(y: 26)

            NavigationLink(value: heroMovie) {
                ZStack(alignment: .bottomLeading) {
                    heroArtwork(heroMovie)
                        .frame(height: HFResponsiveFit.heroImageHeight(width: screenWidth))
                        .clipShape(RoundedRectangle(cornerRadius: HFResponsiveFit.heroCardCornerRadius(width: screenWidth), style: .continuous))

                    HFColors.cinematicGoldScrim
                        .clipShape(RoundedRectangle(cornerRadius: HFResponsiveFit.heroCardCornerRadius(width: screenWidth), style: .continuous))

                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.18), Color.black.opacity(0.94)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: HFResponsiveFit.heroCardCornerRadius(width: screenWidth), style: .continuous))
                }
            }
            .buttonStyle(.plain)

            heroPosterStack
                .frame(width: 92, height: 132, alignment: .topTrailing)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .padding(.top, HFSpacing.lg)
                .padding(.trailing, HFSpacing.sm)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    Spacer()

                NavigationLink(value: heroMovie) {
                    VStack(alignment: .leading, spacing: HFSpacing.sm) {
                        Text("TONIGHT ON HIGHFIVE")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)
                            .kerning(1.6)

                        Text(heroMovie.title)
                            .font(.system(size: HFResponsiveFit.isCompactPhone(width: screenWidth) ? 38 : 44, weight: .black, design: .default))
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.66)

                        Text("A cinematic premiere selected for tonight.")
                            .font(HFTypography.body)
                            .foregroundStyle(HFColors.textSecondary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.78)

                        HStack(spacing: HFSpacing.xs) {
                            Image(systemName: "sparkles")
                            Text("Premium local premiere")
                            Spacer(minLength: 0)
                            Text("4K Mood")
                        }
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.gold)
                        .padding(.horizontal, HFSpacing.sm)
                        .frame(height: 34)
                        .background(Color.black.opacity(0.36))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(HFColors.gold.opacity(0.26), lineWidth: 1))

                        HStack(spacing: HFSpacing.xs) {
                            ForEach([heroMovie.rating, heroMovie.duration, "Original"], id: \.self) { badge in
                                Text(badge)
                                    .font(HFTypography.caption)
                                    .foregroundStyle(.black)
                                    .padding(.horizontal, HFSpacing.sm)
                                    .frame(height: 30)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.74)
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
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
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
            .padding(.horizontal, HFSpacing.lg)
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFResponsiveFit.heroContentBottomPadding(width: screenWidth))
        }
        .overlay(
            RoundedRectangle(cornerRadius: HFResponsiveFit.heroCardCornerRadius(width: screenWidth), style: .continuous)
                .stroke(HFColors.gold.opacity(0.62), lineWidth: 1.4)
        )
        .shadow(color: HFColors.amberGlow.opacity(0.30), radius: 28, x: 0, y: 18)
        .padding(.horizontal, HFResponsiveFit.heroHorizontalInset(width: screenWidth))
        .accessibilityIdentifier("hf.consumer.home.hero")
    }

    private var heroPosterStack: some View {
        VStack(spacing: -14) {
            ForEach(Array(HFMockData.recommended.movies.prefix(1)), id: \.id) { movie in
                HFPosterCard(movie: movie, width: max(58, HFResponsiveFit.heroPosterWidth(width: screenWidth) * 0.52), showTitle: false, posterOnly: true)
                    .rotationEffect(.degrees(-6))
                    .shadow(color: HFColors.shadow, radius: 12, x: 0, y: 10)
            }
        }
        .opacity(0.88)
        .padding(HFSpacing.xs)
        .background(Color.black.opacity(0.30))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(HFColors.gold.opacity(0.38), lineWidth: 1)
        )
    }

    private var tonightFeatureSection: some View {
        NavigationLink(value: heroMovie) {
            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.52)) {
                HStack(spacing: HFSpacing.md) {
                    ZStack {
                        ForEach(Array(HFMockData.newThisWeek.movies.prefix(3).enumerated()), id: \.element.id) { index, movie in
                            HFPosterCard(movie: movie, width: 88, showTitle: false, posterOnly: true)
                                .rotationEffect(.degrees(Double(index - 1) * 8))
                                .offset(x: CGFloat(index - 1) * 36, y: CGFloat(abs(index - 1)) * 8)
                                .zIndex(Double(index))
                        }
                    }
                    .frame(width: 158, height: 142)

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("FEATURED PREMIERE")
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.gold)
                            .kerning(1.2)
                        Text("The Friendly leads a slate built for a late-night HighFive premiere.")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(3)
                        Text("Crime, drama, originals")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                        HStack(spacing: HFSpacing.xxs) {
                            Image(systemName: "play.circle.fill")
                            Text("Open Premiere")
                        }
                        .font(HFTypography.smallAction)
                        .foregroundStyle(HFColors.gold)
                    }

                    Spacer(minLength: 0)
                }
                .padding(HFSpacing.lg)
                .background(
                    LinearGradient(
                        colors: [HFColors.warmGlow.opacity(0.32), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open tonight on HighFive featured premiere")
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var goldDiscoveryRail: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "HighFive Originals", actionTitle: "Discover", action: onDiscover)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    ForEach(HFMockData.onlyOnHighFive.movies.prefix(8)) { movie in
                        NavigationLink(value: movie) {
                            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                                HFPosterCard(movie: movie, width: 152, showTitle: false, showProgress: movie.progress != nil)
                                Text(movie.title)
                                    .font(HFTypography.cardTitle)
                                    .foregroundStyle(HFColors.textPrimary)
                                    .lineLimit(1)
                                    .frame(width: 152, alignment: .leading)
                                Text(movie.genres.prefix(2).joined(separator: " / "))
                                    .font(HFTypography.caption)
                                    .foregroundStyle(HFColors.gold)
                                    .lineLimit(1)
                                    .frame(width: 152, alignment: .leading)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
                .padding(.vertical, HFSpacing.sm)
            }
            .background(
                LinearGradient(
                    colors: [HFColors.warmGlow.opacity(0.26), Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .scrollClipDisabled()
        }
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
                                HFPosterCard(movie: movie, width: HFResponsiveFit.posterRailWidth(width: screenWidth), showProgress: true)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Continue watching \(movie.title)")
                        } else {
                            NavigationLink(value: movie) {
                                HFPosterCard(movie: movie, width: HFResponsiveFit.posterRailWidth(width: screenWidth), showProgress: category.id == "continue")
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

private struct HFHomeMetricPill: View {
    let value: String
    let label: String
    let systemImage: String

    var body: some View {
        HFGlassPanel(cornerRadius: 18, strokeColor: HFColors.gold.opacity(0.24)) {
            HStack(spacing: HFSpacing.xs) {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 30, height: 30)
                    .background(HFColors.gold.opacity(0.12))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 1) {
                    Text(value)
                        .font(.system(size: 18, weight: .black, design: .default))
                        .foregroundStyle(HFColors.textPrimary)
                    Text(label)
                        .font(.system(size: 10, weight: .bold, design: .default))
                        .foregroundStyle(HFColors.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.74)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, HFSpacing.sm)
            .padding(.vertical, HFSpacing.xs)
        }
    }
}

private struct HFHomeCommandCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    var isActive = false

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(isActive ? .black : HFColors.gold)
                .frame(width: 30, height: 30)
                .background(isActive ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(HFColors.gold.opacity(0.12)))
                .clipShape(Circle())

            Text(title)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.78)

            Text(subtitle)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.74)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 112, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(isActive ? HFColors.gold.opacity(0.14) : Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous)
                .stroke(isActive ? HFColors.gold.opacity(0.38) : HFColors.glassStroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
    }
}

struct HFConsumerMomentumRow: View {
    let title: String
    let detail: String
    let status: String
    let systemImage: String

    var body: some View {
        HFGlassPanel(cornerRadius: 16, strokeColor: HFColors.gold.opacity(0.18)) {
            HStack(spacing: HFSpacing.sm) {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 34, height: 34)
                    .background(HFColors.gold.opacity(0.12))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                    Text(detail)
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.74)
                }

                Spacer(minLength: HFSpacing.xs)

                Text(status)
                    .font(HFTypography.micro)
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .padding(.horizontal, HFSpacing.xs)
                    .frame(height: 24)
                    .background(HFColors.goldGradient)
                    .clipShape(Capsule())
            }
            .padding(HFSpacing.sm)
        }
    }
}
