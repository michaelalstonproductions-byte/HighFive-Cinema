import SwiftUI

enum HFStreamingTab: Hashable {
    case home
    case search
    case library
    case downloads
    case profile
}

struct HFStreamingRootView: View {
    @State private var selectedTab: HFStreamingTab = Self.initialTab
    @State private var selectedProfile = HFMockData.userProfiles[0]
    @State private var searchMode: HFSearchHubMode = .search
    @State private var hasCompletedLaunchIntro = Self.shouldSkipLaunchIntro
    @AppStorage("hf.hasCompletedCinematicOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var streamingStore = HFStreamingStore()

    private let tabItems: [HFTabItem<HFStreamingTab>] = [
        HFTabItem(value: .home, title: "Home", systemImage: "house.fill"),
        HFTabItem(value: .search, title: "Search", systemImage: "magnifyingglass"),
        HFTabItem(value: .library, title: "Library", systemImage: "bookmark.fill"),
        HFTabItem(value: .downloads, title: "Downloads", systemImage: "arrow.down.circle.fill"),
        HFTabItem(value: .profile, title: "Profile", systemImage: "person.crop.circle.fill")
    ]

    private static var initialTab: HFStreamingTab {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--hf-start-search") || arguments.contains("--hf-start-search-results") || arguments.contains("--hf-start-search-empty") { return .search }
        if arguments.contains("--hf-start-library") || arguments.contains("--hf-start-library-continue") || arguments.contains("--hf-start-library-empty") { return .library }
        if arguments.contains("--hf-start-downloads") || arguments.contains("--hf-start-downloads-offline") || arguments.contains("--hf-start-downloads-empty") { return .downloads }
        if arguments.contains("--hf-start-connect") { return .profile }
        if Self.shouldStartInProfile { return .profile }
        return .home
    }

    private static var shouldSkipLaunchIntro: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-skip-onboarding") || Self.shouldStartAfterOnboarding
    }

    private static var shouldForceLaunchIntro: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-onboarding")
            || arguments.contains("--hf-start-intro-video")
            || arguments.contains("--hf-onboarding-intro")
            || arguments.contains("--hf-start-training-controls")
            || arguments.contains("--hf-start-timeline-practice")
    }

    private static var shouldResetLaunchIntro: Bool {
        ProcessInfo.processInfo.arguments.contains("--hf-reset-onboarding")
    }

    private static var shouldStartAfterOnboarding: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-home")
            || arguments.contains("--hf-start-search")
            || arguments.contains("--hf-start-search-results")
            || arguments.contains("--hf-start-search-empty")
            || arguments.contains("--hf-start-library")
            || arguments.contains("--hf-start-library-continue")
            || arguments.contains("--hf-start-library-empty")
            || arguments.contains("--hf-start-downloads")
            || arguments.contains("--hf-start-downloads-offline")
            || arguments.contains("--hf-start-downloads-empty")
            || arguments.contains("--hf-start-movie-detail")
            || arguments.contains("--hf-start-player")
            || arguments.contains("--hf-start-protected-depth-preview")
            || arguments.contains("--hf-start-creator-studio")
            || arguments.contains("--hf-start-social-media-kit")
            || arguments.contains("--hf-start-social-media-kit-poster")
            || arguments.contains("--hf-start-social-media-kit-reel")
            || arguments.contains("--hf-start-social-media-kit-caption")
            || arguments.contains("--hf-start-social-media-kit-story")
            || arguments.contains("--hf-start-social-media-kit-platforms")
            || arguments.contains("--hf-start-instagram-connect")
            || arguments.contains("--hf-start-vod-package")
            || arguments.contains("--hf-start-vod-package-trailer")
            || arguments.contains("--hf-start-vod-package-poster")
            || arguments.contains("--hf-start-vod-package-synopsis")
            || arguments.contains("--hf-start-vod-package-access")
            || arguments.contains("--hf-start-vod-package-release")
            || arguments.contains("--hf-start-membership")
            || arguments.contains("--hf-start-membership-identity")
            || arguments.contains("--hf-start-membership-premieres")
            || arguments.contains("--hf-start-membership-creator-rooms")
            || arguments.contains("--hf-start-membership-protected-playback")
            || arguments.contains("--hf-start-membership-depth-peek")
            || arguments.contains("--hf-start-connect")
            || arguments.contains("--hf-start-premiere-lobby")
            || arguments.contains("--hf-start-backend-status")
            || Self.shouldStartInProfile
    }

    private static var shouldStartInProfile: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-profile")
            || arguments.contains("--hf-start-profile-rooms")
            || arguments.contains("--hf-start-watch-room")
            || arguments.contains("--hf-start-create-room")
            || arguments.contains("--hf-start-connect")
            || arguments.contains("--hf-start-connect-room")
            || arguments.contains("--hf-start-premiere-lobby")
            || arguments.contains("--hf-start-launch-room")
            || arguments.contains("--hf-start-export-room")
            || arguments.contains("--hf-start-creator-studio")
            || arguments.contains("--hf-start-social-media-kit")
            || arguments.contains("--hf-start-social-media-kit-poster")
            || arguments.contains("--hf-start-social-media-kit-reel")
            || arguments.contains("--hf-start-social-media-kit-caption")
            || arguments.contains("--hf-start-social-media-kit-story")
            || arguments.contains("--hf-start-social-media-kit-platforms")
            || arguments.contains("--hf-start-instagram-connect")
            || arguments.contains("--hf-start-vod-package")
            || arguments.contains("--hf-start-vod-package-trailer")
            || arguments.contains("--hf-start-vod-package-poster")
            || arguments.contains("--hf-start-vod-package-synopsis")
            || arguments.contains("--hf-start-vod-package-access")
            || arguments.contains("--hf-start-vod-package-release")
            || Self.shouldStartInMembership
            || arguments.contains("--hf-start-backend-status")
            || arguments.contains("--hf-start-developer-qa")
            || arguments.contains("--hf-start-demo-tour")
    }

    private static var shouldStartInMovieDetail: Bool {
        ProcessInfo.processInfo.arguments.contains("--hf-start-movie-detail")
    }

    private static var shouldStartInProtectedDepthPreview: Bool {
        ProcessInfo.processInfo.arguments.contains("--hf-start-protected-depth-preview")
    }

    private static var shouldStartInPlayer: Bool {
        ProcessInfo.processInfo.arguments.contains("--hf-start-player")
    }

    private static var shouldStartInCreatorStudio: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-creator-studio")
            || arguments.contains("--hf-start-social-media-kit")
            || arguments.contains("--hf-start-social-media-kit-poster")
            || arguments.contains("--hf-start-social-media-kit-reel")
            || arguments.contains("--hf-start-social-media-kit-caption")
            || arguments.contains("--hf-start-social-media-kit-story")
            || arguments.contains("--hf-start-social-media-kit-platforms")
            || arguments.contains("--hf-start-instagram-connect")
            || arguments.contains("--hf-start-vod-package")
            || arguments.contains("--hf-start-vod-package-trailer")
            || arguments.contains("--hf-start-vod-package-poster")
            || arguments.contains("--hf-start-vod-package-synopsis")
            || arguments.contains("--hf-start-vod-package-access")
            || arguments.contains("--hf-start-vod-package-release")
    }

    private static var shouldStartInConnect: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-connect")
            || arguments.contains("--hf-start-connect-room")
            || arguments.contains("--hf-start-premiere-lobby")
    }

    private static var shouldStartInBackendStatus: Bool {
        ProcessInfo.processInfo.arguments.contains("--hf-start-backend-status")
    }

    private static var connectInitialMode: HFConnectSpatialMode {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--hf-start-connect-room") { return .watchRoom }
        if arguments.contains("--hf-start-premiere-lobby") { return .premiereLobby }
        return .hub
    }

    private static var creatorStudioInitialFocus: HFCreatorStudioFocus {
        let arguments = ProcessInfo.processInfo.arguments
        if Self.shouldStartInSocialMediaKit { return .socialMediaKit }
        if arguments.contains("--hf-start-instagram-connect") { return .instagramConnect }
        if Self.shouldStartInVODPackage { return .vodPackage }
        return .dashboard
    }

    private static var shouldStartInSocialMediaKit: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-social-media-kit")
            || arguments.contains("--hf-start-social-media-kit-poster")
            || arguments.contains("--hf-start-social-media-kit-reel")
            || arguments.contains("--hf-start-social-media-kit-caption")
            || arguments.contains("--hf-start-social-media-kit-story")
            || arguments.contains("--hf-start-social-media-kit-platforms")
    }

    private static var socialCampaignInitialFocus: HFSocialCampaignFocus {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--hf-start-social-media-kit-reel") { return .reel }
        if arguments.contains("--hf-start-social-media-kit-caption") { return .caption }
        if arguments.contains("--hf-start-social-media-kit-story") { return .story }
        if arguments.contains("--hf-start-social-media-kit-platforms") { return .platforms }
        return .poster
    }

    private static var shouldStartInVODPackage: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-vod-package")
            || arguments.contains("--hf-start-vod-package-trailer")
            || arguments.contains("--hf-start-vod-package-poster")
            || arguments.contains("--hf-start-vod-package-synopsis")
            || arguments.contains("--hf-start-vod-package-access")
            || arguments.contains("--hf-start-vod-package-release")
    }

    private static var vodReleaseInitialFocus: HFVODReleaseFocus {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--hf-start-vod-package-poster") { return .poster }
        if arguments.contains("--hf-start-vod-package-synopsis") { return .synopsis }
        if arguments.contains("--hf-start-vod-package-access") { return .access }
        if arguments.contains("--hf-start-vod-package-release") { return .release }
        return .trailer
    }

    private static var shouldStartInMembership: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-start-membership")
            || arguments.contains("--hf-start-membership-identity")
            || arguments.contains("--hf-start-membership-premieres")
            || arguments.contains("--hf-start-membership-creator-rooms")
            || arguments.contains("--hf-start-membership-protected-playback")
            || arguments.contains("--hf-start-membership-depth-peek")
    }

    private static var membershipInitialFacet: HFMembershipPassFacet {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--hf-start-membership-premieres") { return .premieres }
        if arguments.contains("--hf-start-membership-creator-rooms") { return .creatorRooms }
        if arguments.contains("--hf-start-membership-protected-playback") { return .protectedPlayback }
        if arguments.contains("--hf-start-membership-depth-peek") { return .depthPeek }
        return .identity
    }

    private static var qaMovieDetailMovie: Movie {
        HFMockData.movie("friendly") ?? HFMockData.movies[0]
    }

    var body: some View {
        Group {
            if shouldShowStreamingShell {
                if Self.shouldStartInProtectedDepthPreview {
                    HighFiveProtectedSpatialPeekBridge()
                } else if Self.shouldStartInPlayer {
                    qaPlayerView
                } else if Self.shouldStartInBackendStatus {
                    qaBackendStatusView
                } else if Self.shouldStartInCreatorStudio {
                    qaCreatorStudioView
                } else if Self.shouldStartInConnect {
                    qaConnectView
                } else if Self.shouldStartInMovieDetail {
                    qaMovieDetailView
                } else {
                    streamingShell
                }
            } else {
                HighFiveIntroFlowView(
                    initialStep: HighFiveIntroStep.initialFromLaunchArguments,
                    onFinish: {
                    completeLaunchIntro()
                    }
                )
            }
        }
        .tint(HFColors.gold)
        .preferredColorScheme(.dark)
        .environmentObject(streamingStore)
        .onAppear {
            if Self.shouldResetLaunchIntro {
                hasCompletedOnboarding = false
                hasCompletedLaunchIntro = Self.shouldSkipLaunchIntro && !Self.shouldForceLaunchIntro
            }
        }
        .task {
            await streamingStore.refreshBackendRuntimeStatus()
        }
    }

    private var shouldShowStreamingShell: Bool {
        hasCompletedLaunchIntro || (hasCompletedOnboarding && !Self.shouldResetLaunchIntro && !Self.shouldForceLaunchIntro)
    }

    private func completeLaunchIntro() {
        withAnimation(.easeInOut(duration: 0.35)) {
            hasCompletedLaunchIntro = true
            hasCompletedOnboarding = true
        }
    }

    private var qaMovieDetailView: some View {
        NavigationStack {
            MovieDetailView(movie: Self.qaMovieDetailMovie)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
    }

    private var qaPlayerView: some View {
        HFPlayerServiceSheet(movie: Self.qaMovieDetailMovie)
            .background(HFColors.screenBackground.ignoresSafeArea())
    }

    private var qaCreatorStudioView: some View {
        NavigationStack {
            CreatorStudioView(
                initialFocus: Self.creatorStudioInitialFocus,
                initialSocialFocus: Self.socialCampaignInitialFocus,
                initialVODFocus: Self.vodReleaseInitialFocus
            )
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
    }

    private var qaConnectView: some View {
        NavigationStack {
            ConnectHubView(initialMode: Self.connectInitialMode)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
    }

    private var qaBackendStatusView: some View {
        NavigationStack {
            HFBackendStatusView()
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
    }

    private var streamingShell: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                HFColors.screenBackground
                    .ignoresSafeArea()

                Group {
                    switch selectedTab {
                    case .home:
                        HomeView(
                            selectedProfile: selectedProfile,
                            onSearch: {
                                searchMode = .search
                                selectedTab = .search
                            },
                            onDiscover: {
                                searchMode = .discover
                                selectedTab = .search
                            },
                            onProfile: {
                                selectedTab = .profile
                            },
                            onMyList: {
                                selectedTab = .library
                            },
                            onDownloads: {
                                selectedTab = .downloads
                            }
                        )
                    case .search:
                        SearchView(mode: $searchMode)
                    case .library:
                        MyListView(onBrowseDiscover: {
                            searchMode = .discover
                            selectedTab = .search
                        })
                    case .downloads:
                        DownloadsView(onFindMore: {
                            searchMode = .discover
                            selectedTab = .search
                        })
                    case .profile:
                        ProfileView(
                            selectedProfile: $selectedProfile,
                            initialMembershipFacet: Self.membershipInitialFacet,
                            startInMembership: Self.shouldStartInMembership,
                            onOpenMyList: {
                                selectedTab = .library
                            }
                        )
                    }
                }

                HFTabBar(items: tabItems, selection: $selectedTab)
                    .accessibilityIdentifier("hf.tabs.locked")
            }
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailView(movie: movie)
            }
        }
    }
}

private enum HFLaunchIntroStep: Int, CaseIterable {
    case intro
    case motion
    case controls
    case homeReveal

    var page: Int { rawValue }

    static var initialFromLaunchArguments: HFLaunchIntroStep {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--hf-onboarding-intro") { return .intro }
        if arguments.contains("--hf-onboarding-tilt-peek") { return .motion }
        if arguments.contains("--hf-onboarding-instructions") { return .controls }
        if arguments.contains("--hf-onboarding-controls") { return .controls }
        if arguments.contains("--hf-onboarding-home-reveal") { return .homeReveal }
        return .intro
    }
}

private struct HFLaunchIntroSequenceView: View {
    let onFinish: () -> Void

    @State private var step: HFLaunchIntroStep

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
        _step = State(initialValue: HFLaunchIntroStep.initialFromLaunchArguments)
    }

    var body: some View {
        ZStack {
            HFColors.screenBackground
                .ignoresSafeArea()

            switch step {
            case .intro:
                HFLaunchIntroVideoScreen(
                    onContinue: { advance(to: .motion) },
                    onSkip: onFinish
                )
                .transition(.opacity)
                .accessibilityIdentifier("hf.onboarding.brandIntro")
                .accessibilityLabel("HighFive Cinema brand intro")
            case .motion:
                HFLaunchMotionInstructionScreen(
                    onContinue: { advance(to: .controls) },
                    onSkip: onFinish
                )
                .transition(.opacity)
                .accessibilityIdentifier("hf.onboarding.motionTraining")
                .accessibilityLabel("Motion training, tilt to move and peek to explore")
            case .controls:
                HFLaunchControlsTrainingScreen(
                    onContinue: { advance(to: .homeReveal) },
                    onSkip: onFinish
                )
                .transition(.opacity)
                .accessibilityIdentifier("hf.onboarding.controlsTraining")
                .accessibilityLabel("Controls training, play scrub depth focus import and export")
            case .homeReveal:
                HFLaunchHomeRevealScreen(onFinish: onFinish)
                    .transition(.opacity)
                    .accessibilityIdentifier("hf.onboarding.homeReveal")
                    .accessibilityLabel("Home reveal, enter HighFive Cinema")
            }
        }
        .safeAreaInset(edge: .bottom) {
            HFLaunchPageDots(currentPage: step.page, totalPages: HFLaunchIntroStep.allCases.count)
                .padding(.bottom, 148)
        }
    }

    private func advance(to nextStep: HFLaunchIntroStep) {
        withAnimation(.easeInOut(duration: 0.28)) {
            step = nextStep
        }
    }
}

private struct HFLaunchIntroVideoScreen: View {
    let onContinue: () -> Void
    let onSkip: () -> Void

    @State private var isAnimating = false

    var body: some View {
        HFLaunchScreenFrame(
            primaryTitle: "Continue",
            secondaryTitle: "Skip Intro",
            primaryIdentifier: "hf.onboarding.continueButton",
            secondaryIdentifier: "hf.onboarding.skipButton",
            onPrimary: onContinue,
            onSecondary: onSkip
        ) {
            VStack(spacing: 22) {
                ZStack {
                    Image("UI_Feature_SpatialViewing")
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(isAnimating ? 1.08 : 1.0)
                        .frame(width: 278, height: 372)
                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                        .overlay(
                            LinearGradient(
                                colors: [
                                    .black.opacity(0.12),
                                    .black.opacity(0.72)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .stroke(HFColors.gold.opacity(0.36), lineWidth: 1)
                        )
                        .shadow(color: HFColors.gold.opacity(0.20), radius: 28, x: 0, y: 16)

                    VStack(spacing: 14) {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 58, weight: .semibold))
                            .foregroundStyle(.white, HFColors.gold)
                            .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: 8)

                        Text("HighFive Cinema")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(HFColors.gold)
                            .textCase(.uppercase)
                            .kerning(1.4)
                    }
                    .offset(y: 112)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("HighFive Cinema intro video")

                VStack(spacing: 12) {
                    Text("HighFive Cinema")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.82)

                    Text("A cinematic walk into the streaming home.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.white.opacity(0.76))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 28)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

private struct HFLaunchMotionInstructionScreen: View {
    let onContinue: () -> Void
    let onSkip: () -> Void

    @State private var isTilting = false

    var body: some View {
        HFLaunchScreenFrame(
            primaryTitle: "Next",
            secondaryTitle: "Skip",
            primaryIdentifier: "hf.onboarding.continueButton",
            secondaryIdentifier: "hf.onboarding.skipButton",
            onPrimary: onContinue,
            onSecondary: onSkip
        ) {
            VStack(spacing: 30) {
                ZStack {
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(.white)
                        .frame(width: 156, height: 308)
                        .shadow(color: .black.opacity(0.28), radius: 18, x: 0, y: 16)
                        .overlay {
                            ZStack {
                                RoundedRectangle(cornerRadius: 27, style: .continuous)
                                    .fill(Color(red: 0.05, green: 0.06, blue: 0.09))
                                    .padding(8)

                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                HFColors.gold.opacity(0.38),
                                                Color(red: 0.12, green: 0.15, blue: 0.22),
                                                .white.opacity(0.10)
                                            ],
                                            startPoint: isTilting ? .topLeading : .topTrailing,
                                            endPoint: isTilting ? .bottomTrailing : .bottomLeading
                                        )
                                    )
                                    .padding(14)
                                    .offset(x: isTilting ? 16 : -16)

                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(.white.opacity(0.16))
                                    .frame(width: 84, height: 88)
                                    .offset(x: isTilting ? -10 : 10, y: 78)

                                Capsule()
                                    .fill(Color.black.opacity(0.22))
                                    .frame(width: 44, height: 5)
                                    .offset(y: -134)
                            }
                        }
                        .rotationEffect(.degrees(isTilting ? -7 : 7), anchor: .bottom)
                        .rotation3DEffect(.degrees(isTilting ? -14 : 14), axis: (x: 0, y: 1, z: 0), perspective: 0.65)
                        .offset(x: isTilting ? -5 : 5)
                        .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: isTilting)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Tilting and peeking phone animation")

                VStack(spacing: 10) {
                    Text("Tilt to move")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("hf.onboarding.tiltToMove")

                    Text("Shift your view")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(HFColors.gold.opacity(0.92))
                        .multilineTextAlignment(.center)

                    Text("Peek to explore")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("hf.onboarding.peekToExplore")

                    Text("Reveal more of the scene with guided motion training.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.72))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Small movements work best.")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(HFColors.gold.opacity(0.88))
                        .padding(.top, 2)
                }
                .padding(.horizontal, 32)
            }
        }
        .onAppear { isTilting = true }
    }
}

private struct HFLaunchControlsTrainingScreen: View {
    let onContinue: () -> Void
    let onSkip: () -> Void

    var body: some View {
        HFLaunchScreenFrame(
            primaryTitle: "Next",
            secondaryTitle: "Skip",
            primaryIdentifier: "hf.onboarding.continueButton",
            secondaryIdentifier: "hf.onboarding.skipButton",
            onPrimary: onContinue,
            onSecondary: onSkip
        ) {
            VStack(spacing: HFSpacing.lg) {
                VStack(spacing: HFSpacing.sm) {
                    Text("Master the Controls")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("Everything you need to play, explore, and save your videos.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.white.opacity(0.74))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.sm) {
                    HFLaunchControlTile(title: "Play / Pause", detail: "Start or pause the scene.", systemImage: "playpause.fill")
                    HFLaunchControlTile(title: "Scrub", detail: "Move through a moment.", systemImage: "slider.horizontal.3")
                    HFLaunchControlTile(title: "Depth", detail: "Explore layered viewing.", systemImage: "square.stack.3d.down.forward.fill")
                        .accessibilityIdentifier("hf.onboarding.depthControl")
                    HFLaunchControlTile(title: "Focus", detail: "Keep the story clear.", systemImage: "scope")
                        .accessibilityIdentifier("hf.onboarding.focusControl")
                    HFLaunchControlTile(title: "Import", detail: "Training label only.", systemImage: "tray.and.arrow.down.fill")
                    HFLaunchControlTile(title: "Export", detail: "Training label only.", systemImage: "tray.and.arrow.up.fill")
                }
                .accessibilityIdentifier("hf.onboarding.importExportTraining")
            }
            .padding(.horizontal, 28)
        }
    }
}

private struct HFLaunchHomeRevealScreen: View {
    let onFinish: () -> Void

    var body: some View {
        HFLaunchScreenFrame(
            primaryTitle: "Enter Home",
            secondaryTitle: nil,
            primaryIdentifier: "hf.onboarding.enterHomeButton",
            secondaryIdentifier: nil,
            onPrimary: onFinish,
            onSecondary: nil
        ) {
            VStack(spacing: 22) {
                ZStack {
                    Circle()
                        .fill(HFColors.gold.opacity(0.18))
                        .frame(width: 210, height: 210)
                        .blur(radius: 18)

                    Image(systemName: "film.stack.fill")
                        .font(.system(size: 74, weight: .black))
                        .foregroundStyle(.black)
                        .frame(width: 132, height: 132)
                        .background(HFColors.goldGradient, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
                        .shadow(color: HFColors.gold.opacity(0.30), radius: 28, x: 0, y: 18)
                }

                VStack(spacing: 12) {
                    Text("HighFive Cinema")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("Home is ready.")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(HFColors.gold)
                        .multilineTextAlignment(.center)

                    Text("Start with premium streaming, then open the product suite when you are ready.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.white.opacity(0.74))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 30)
            }
        }
        .accessibilityIdentifier("hf.functional.onboarding.entersHome")
    }
}

private struct HFLaunchControlTile: View {
    let title: String
    let detail: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(HFColors.gold)
                .frame(width: 34, height: 34)
                .background(HFColors.gold.opacity(0.13))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(detail)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.68))
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 112, alignment: .topLeading)
        .padding(14)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(detail)")
    }
}

private struct HFLaunchInstructionFormatScreen: View {
    let onFinish: () -> Void

    var body: some View {
        HFLaunchScreenFrame(
            primaryTitle: "Enter Home",
            secondaryTitle: nil,
            primaryIdentifier: "hf.onboarding.enterHomeButton",
            secondaryIdentifier: nil,
            onPrimary: onFinish,
            onSecondary: nil
        ) {
            VStack(spacing: 14) {
                Text("Before you enter")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .textCase(.uppercase)
                    .kerning(1.2)

                Text("How to watch in HighFive")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.82)

                Text("Use small, comfortable phone movements. You can always watch normally from the Home screen.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.white.opacity(0.74))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 4)

                HFLaunchInstructionRow(identifier: "hf.onboarding.row.tilt", number: "1", title: "Tilt", detail: "Gently angle the phone to move through a scene.")
                HFLaunchInstructionRow(identifier: "hf.onboarding.row.peek", number: "2", title: "Peek", detail: "Lean left or right to reveal more of the frame.")
                HFLaunchInstructionRow(identifier: "hf.onboarding.row.watch", number: "3", title: "Watch", detail: "Enter the Home screen when you are ready to browse.")
            }
            .padding(.horizontal, 28)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("HighFive instructions, tilt to move, peek to explore, then enter the home screen")
        }
    }
}

private struct HFLaunchInstructionRow: View {
    let identifier: String
    let number: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text(number)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.black)
                .frame(width: 32, height: 32)
                .background(HFColors.gold, in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)

                Text(detail)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.white.opacity(0.70))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier(identifier)
        .accessibilityLabel("\(title) instruction, \(detail)")
    }
}

private struct HFLaunchScreenFrame<Content: View>: View {
    let primaryTitle: String
    let secondaryTitle: String?
    let primaryIdentifier: String
    let secondaryIdentifier: String?
    let onPrimary: () -> Void
    let onSecondary: (() -> Void)?
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.08, green: 0.06, blue: 0.04),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                Spacer(minLength: 22)
                content
                Spacer(minLength: 168)
            }

            VStack(spacing: 14) {
                Spacer()

                Button(action: onPrimary) {
                    Text(primaryTitle)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .accessibilityIdentifier(primaryIdentifier)
                .accessibilityLabel(primaryTitle == "Next" ? "Continue onboarding" : primaryTitle)

                if let secondaryTitle, let onSecondary {
                    Button(action: onSecondary) {
                        Text(secondaryTitle)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.82))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .accessibilityIdentifier(secondaryIdentifier ?? "hf.onboarding.skipButton")
                    .accessibilityLabel(secondaryTitle)
                }
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 26)
        }
    }
}

private struct HFLaunchPageDots: View {
    let currentPage: Int
    let totalPages: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? .white : .white.opacity(0.30))
                    .frame(width: index == currentPage ? 22 : 7, height: 7)
                    .animation(.easeInOut(duration: 0.20), value: currentPage)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Onboarding page \(currentPage + 1) of \(totalPages)")
    }
}
