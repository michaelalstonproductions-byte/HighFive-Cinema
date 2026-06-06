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
                heroSection
                todaySection
                commandCenterSection
                smartRecommendationsSection
                insightSection
                watchSectionHeader

                ForEach(HFMockData.premiumHomeRails) { category in
                    movieRail(category)
                }

                createSection
                connectSection
                launchAccessSection
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
            .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 0) {
                Text("HIGHFIVE")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                Text("CINEMA")
                    .font(.system(size: 22, weight: .black, design: .rounded))
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

    private var insightSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "For You", actionTitle: nil)

            HFInsightCard(
                title: "Your HighFive spine",
                message: "Watch stories, build creator packages, connect with communities, and prepare launch previews from local data.",
                systemImage: "sparkles"
            )
            .padding(.horizontal, HFSpacing.screenHorizontal)

            Button(action: onProfile) {
                HFInsightCard(
                    title: "Create and launch next",
                    message: "Open Profile for Creator Mode, Launch Center, Access Preview, and the local release presentation.",
                    systemImage: "sparkles"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open HighFive preview from Profile")
            .padding(.horizontal, HFSpacing.screenHorizontal)

            Button(action: onProfile) {
                HFInsightCard(
                    title: "Connect with creators",
                    message: "Open Profile for local Connect previews, creator communities, and project signals.",
                    systemImage: "person.2.fill"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Connect Preview from Profile")
            .padding(.horizontal, HFSpacing.screenHorizontal)

            Button(action: onMyList) {
                HFInsightCard(
                    title: "View My List",
                    message: "Open saved titles and pick up your local watchlist.",
                    systemImage: "bookmark.fill"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("View My List")
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var todaySection: some View {
        HFTodaySummaryCard(items: HFEcosystemPreviewData.todaySummaryItems)
            .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var commandCenterSection: some View {
        NavigationLink {
            EcosystemCommandCenterView()
        } label: {
            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        Image(systemName: "command")
                            .font(.system(size: 26, weight: .black))
                            .foregroundStyle(HFColors.gold)
                            .frame(width: 58, height: 58)
                            .background(HFColors.gold.opacity(0.14))
                            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.sm, style: .continuous))

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            HStack(spacing: HFSpacing.xs) {
                                Text("HighFive Command Center")
                                    .font(HFTypography.section)
                                    .foregroundStyle(HFColors.textPrimary)
                                    .fixedSize(horizontal: false, vertical: true)

                                Spacer(minLength: HFSpacing.xs)

                                HFStatusBadge(title: "Local", isProminent: false)
                            }

                            Text("Watch stories, create packages, connect communities, preview launch readiness, and see future export tools stay disconnected.")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    HStack(spacing: HFSpacing.xs) {
                        Text("Open Command Center")
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .black))
                    }
                    .font(HFTypography.smallAction)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(HFColors.goldGradient)
                    .clipShape(Capsule())
                }
                .padding(HFSpacing.lg)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open HighFive Command Center")
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
        ecosystemRail(title: "Smart Recommendations") {
            NavigationLink {
                PersonalizedHubView()
            } label: {
                HFRecommendationCard(recommendation: HFPersonalizationPreviewData.homeRecommendations[0])
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Personalized Hub")

            NavigationLink {
                CreatorPackageBuilderPreviewView()
            } label: {
                HFRecommendationCard(recommendation: HFPersonalizationPreviewData.homeRecommendations[1])
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Continue Package Builder")

            NavigationLink {
                ConnectHubView()
            } label: {
                HFRecommendationCard(recommendation: HFPersonalizationPreviewData.homeRecommendations[2])
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Explore Connect")

            NavigationLink {
                CreatorLaunchCenterPreviewView()
            } label: {
                HFRecommendationCard(recommendation: HFPersonalizationPreviewData.homeRecommendations[3])
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Launch Center")
        }
    }

    private var createSection: some View {
        ecosystemRail(title: "Create") {
            NavigationLink {
                CreatorWorkflowCommandCenterView()
            } label: {
                HFEcosystemCard(
                    title: "Creator Command Center",
                    subtitle: "Build creator packages from draft to review.",
                    systemImage: "rectangle.grid.2x2.fill",
                    status: "72%"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Creator Command Center")

            NavigationLink {
                CreatorPackageBuilderPreviewView()
            } label: {
                HFEcosystemCard(
                    title: "Package Builder",
                    subtitle: "Assemble The Friendly package details.",
                    systemImage: "shippingbox.fill",
                    status: "In Progress"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Package Builder")

            NavigationLink {
                CreatorLaunchCenterPreviewView()
            } label: {
                HFEcosystemCard(
                    title: "Launch Center",
                    subtitle: "Prepare audience, access, and release planning.",
                    systemImage: "rocket.fill",
                    status: "Preview"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Launch Center")

            NavigationLink {
                CreatorReleaseReadinessPreviewView()
            } label: {
                HFEcosystemCard(
                    title: "Release Readiness",
                    subtitle: "Review launch blockers and ready items.",
                    systemImage: "gauge.with.dots.needle.bottom.50percent",
                    status: "72%"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Release Readiness")
        }
    }

    private var connectSection: some View {
        ecosystemRail(title: "Connect") {
            NavigationLink {
                CommunityDiscoveryPreviewView()
            } label: {
                HFEcosystemCard(
                    title: "Community Discovery",
                    subtitle: "Find creator communities and project circles.",
                    systemImage: "person.3.fill",
                    status: "Preview"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Community Discovery")

            NavigationLink {
                SocialRoomsPreviewView()
            } label: {
                HFEcosystemCard(
                    title: "Social Rooms",
                    subtitle: "Preview local rooms for reviews and watch circles.",
                    systemImage: "bubble.left.and.bubble.right.fill",
                    status: "Live Mock"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Social Rooms")

            NavigationLink {
                CreatorCirclesPreviewView()
            } label: {
                HFEcosystemCard(
                    title: "Creator Circles",
                    subtitle: "Explore collaborator networks and creative teams.",
                    systemImage: "circle.hexagongrid.fill",
                    status: "Preview"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Creator Circles")

            NavigationLink {
                WatchPartyPreviewView()
            } label: {
                HFEcosystemCard(
                    title: "Watch Party Preview",
                    subtitle: "Shared viewing preview without playback sync.",
                    systemImage: "play.tv.fill",
                    status: "Mock Only"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Watch Party Preview")

            NavigationLink {
                ActivityFeedPreviewView()
            } label: {
                HFEcosystemCard(
                    title: "Activity Feed",
                    subtitle: "Project updates and community signals.",
                    systemImage: "text.bubble.fill",
                    status: "Local"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Activity Feed")
        }
    }

    private var launchAccessSection: some View {
        ecosystemRail(title: "Launch + Access") {
            NavigationLink {
                CreatorLaunchCenterPreviewView()
            } label: {
                HFEcosystemCard(
                    title: "Launch Center",
                    subtitle: "Prepare package, audience, and release previews.",
                    systemImage: "rocket.fill",
                    status: "Planning"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Launch Center")

            NavigationLink {
                CreatorAccessPreviewView()
            } label: {
                HFEcosystemCard(
                    title: "Access Preview",
                    subtitle: "Mock premium access without real purchases.",
                    systemImage: "lock.shield.fill",
                    status: "Mock Only"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Access Preview")

            NavigationLink {
                AppReleasePresentationView()
            } label: {
                HFEcosystemCard(
                    title: "Release Presentation",
                    subtitle: "Review the local Watch to Launch story.",
                    systemImage: "rectangle.on.rectangle.angled.fill",
                    status: "Ready"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Release Presentation")

            NavigationLink {
                AppDemoChecklistView()
            } label: {
                HFEcosystemCard(
                    title: "Demo Checklist",
                    subtitle: "Verify Watch, Create, Connect, and Launch routes.",
                    systemImage: "checklist.checked",
                    status: "QA"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Demo Checklist")
        }
    }

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            NavigationLink(value: heroMovie) {
                heroArtwork(heroMovie)
                    .frame(height: 430)
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous))
            }
            .buttonStyle(.plain)

            HFColors.heroGradient
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous))
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: HFSpacing.md) {
                Spacer()

                NavigationLink(value: heroMovie) {
                    VStack(alignment: .leading, spacing: HFSpacing.md) {
                        Text("FEATURED PREMIERE")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)
                            .kerning(1.6)

                        Text(heroMovie.title)
                            .font(HFTypography.heroTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.72)

                        Text(heroMovie.subtitle + "\n" + heroMovie.synopsis)
                            .font(HFTypography.body)
                            .foregroundStyle(HFColors.textSecondary)
                            .lineLimit(4)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: HFSpacing.xs) {
                            ForEach(["4K HDR", "HighFive Original", "Cinematic Cut"], id: \.self) { badge in
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
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(HFColors.goldGradient)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Watch Now")

                    HFButton(
                        streamingStore.isSaved(heroMovie) ? "In My List" : "Add To List",
                        systemImage: streamingStore.isSaved(heroMovie) ? "checkmark" : "plus",
                        style: .secondary
                    ) {
                        streamingStore.toggleSaved(heroMovie)
                    }
                    .accessibilityLabel(streamingStore.isSaved(heroMovie) ? "Remove from My List" : "Add to My List")
                }
            }
            .padding(HFSpacing.xl)
        }
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous)
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
                                HFPosterCard(movie: movie, width: 132, showProgress: true)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Continue watching \(movie.title)")
                        } else {
                            NavigationLink(value: movie) {
                                HFPosterCard(movie: movie, width: 132, showProgress: category.id == "continue")
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Open \(movie.title)")
                        }
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
    }

    private func ecosystemRail<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: title, actionTitle: nil)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    content()
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
