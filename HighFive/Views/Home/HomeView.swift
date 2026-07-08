import SwiftUI
import AVKit
import CoreTransferable
import PhotosUI
import UniformTypeIdentifiers

struct HomeView: View {
    let selectedProfile: UserProfile
    var onSearch: () -> Void = {}
    var onDiscover: () -> Void = {}
    var onProfile: () -> Void = {}
    var onMyList: () -> Void = {}
    var onDownloads: () -> Void = {}

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject private var streamingStore: HFStreamingStore
    @State private var previewMovie: Movie?
    @State private var activeImportedVideo: HFImportedVideoItem?
    @State private var importedVideos: [HFImportedVideoItem] = HFImportedVideoLibrary.load()
    @State private var showsVideoImporter = false
    @State private var showsImportSourcePicker = false
    @State private var selectedPhotoLibraryVideo: PhotosPickerItem?
    @State private var importErrorMessage: String?
    @State private var showsProtectedDepthPreview = false
    @State private var isHeroAwake = false
    @State private var selectedContentCategory: HFContentCategory = .all

    private let showsCollectionsFirst = ProcessInfo.processInfo.arguments.contains("--hf-premium-streaming-collections")
    private let showsFPPStateQA = ProcessInfo.processInfo.arguments.contains("--hf-fpp-loading-states")
    private let showsFPPErrorQA = ProcessInfo.processInfo.arguments.contains("--hf-fpp-error-states")
    private let showsFPPAccessibilityQA = ProcessInfo.processInfo.arguments.contains("--hf-fpp-accessibility")
    private let showsFPPPerformanceQA = ProcessInfo.processInfo.arguments.contains("--hf-fpp-performance")
    private let showsFPPHomePolishQA = ProcessInfo.processInfo.arguments.contains("--hf-fpp-home-polish")

    private var heroMovie: Movie {
        streamingStore.featuredMovie
    }

    private var consumerSnapshot: HFConsumerExperienceSnapshot {
        HFLocalProjectStore.consumerExperienceSnapshot
    }

    private var continueWatching: [Movie] {
        streamingStore.catalogRuntimeMovies(filter: "Progress", sort: .progress, pageSize: 10)
    }

    private var recommendedForYouMovies: [Movie] {
        uniqueMovies(
            streamingStore.recommendationCollections(anchor: continueWatching.first ?? heroMovie)
                .flatMap(\.movies)
        )
    }

    private var featuredOriginalsMovies: [Movie] {
        let originals = streamingStore.queryCatalog().filter(\.isOriginal)
        return uniqueMovies(originals.isEmpty ? streamingStore.allCatalogMovies.filter(\.isOriginal) : originals)
    }

    private var categoryCatalogMovies: [Movie] {
        streamingStore.queryCatalog()
    }

    private var filteredCategoryMovies: [Movie] {
        categoryCatalogMovies.filter { selectedContentCategory.includes($0) }
    }

    private var availableNowMovies: [Movie] {
        ["friendly", "paranormall-s1"].compactMap(streamingStore.movie(id:))
    }

    private var comingSoonMovies: [Movie] {
        ["big-loss", "maple-street", "arrival-time", "sunshine", "old-satan"]
            .compactMap(streamingStore.movie(id:))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.sectionGap) {
                figmaHomeHero
                curatedPosterRail(
                    title: "Continue Watching",
                    detail: consumerSnapshot.continueWatchingDetail,
                    movies: continueWatching,
                    identifier: "hf.home.continueWatching"
                )
                curatedPosterRail(
                    title: "Recommended For You",
                    detail: consumerSnapshot.recommendedDetail,
                    movies: recommendedForYouMovies,
                    identifier: "hf.home.recommendedForYou"
                )
                curatedPosterRail(
                    title: "Featured Originals",
                    detail: "HighFive stories with premium local placement.",
                    movies: featuredOriginalsMovies,
                    identifier: "hf.home.featuredOriginals"
                )
                consumerSignalStrip
                curatedPosterRail(
                    title: "Coming Soon",
                    detail: consumerSnapshot.comingSoonDetail,
                    movies: comingSoonMovies,
                    identifier: "hf.home.comingSoon"
                )
                curatedPosterRail(
                    title: "Available Now",
                    detail: consumerSnapshot.availableNowDetail,
                    movies: availableNowMovies,
                    identifier: "hf.home.availableNow"
                )
                importedVideosSection
            }
            .padding(.bottom, HFResponsiveFit.floatingTabContentClearance(dynamicTypeSize: dynamicTypeSize))
        }
        .accessibilityIdentifier("hf.spatial.home")
        .accessibilityIdentifier("hf.streaming.premium.home")
        .background(HFColors.screenBackground.ignoresSafeArea())
        .fullScreenCover(item: $previewMovie) { movie in
            HFPlayerServiceSheet(movie: movie, startsInVerticalStage: true)
                .environmentObject(streamingStore)
        }
        .fullScreenCover(item: $activeImportedVideo) { importedVideo in
            HFPlayerServiceSheet(
                movie: importedVideo.movie,
                startsInVerticalStage: true,
                contentSource: .userImported,
                importedVideoURL: importedVideo.fileURL
            )
            .environmentObject(streamingStore)
        }
        .sheet(isPresented: $showsProtectedDepthPreview) {
            HighFiveProtectedSpatialPeekBridge()
        }
        .sheet(isPresented: $showsImportSourcePicker) {
            HFImportMovieSourceSheet(
                selectedPhotoLibraryVideo: $selectedPhotoLibraryVideo,
                onFiles: {
                    showsImportSourcePicker = false
                    showsVideoImporter = true
                }
            )
            .presentationDetents([.height(260)])
            .presentationDragIndicator(.visible)
            .preferredColorScheme(.dark)
        }
        .fileImporter(
            isPresented: $showsVideoImporter,
            allowedContentTypes: [.movie, .video, .mpeg4Movie, .quickTimeMovie],
            allowsMultipleSelection: false
        ) { result in
            handleImportedVideo(result)
        }
        .onChange(of: selectedPhotoLibraryVideo) { _, item in
            guard let item else { return }
            Task { await handlePhotoLibraryVideo(item) }
        }
        .onAppear {
            importedVideos = HFImportedVideoLibrary.load()
            guard !isHeroAwake else { return }
            withAnimation(reduceMotion ? .easeInOut(duration: 0.01) : HFSpatialMotionTokens.sceneEntranceAnimation) {
                isHeroAwake = true
            }
        }
    }

    private var figmaHomeHero: some View {
        DepthHeroStage(height: 540, depthEnabled: true, atmosphereTint: HFColors.gold) {
            markOfTheWestHeroMedia
                .accessibilityIdentifier("hf.home.hero.video")
        } foreground: { motion in
            markOfTheWestHeroContent(motion: motion)
        }
        .clipShape(RoundedRectangle(cornerRadius: 0, style: .continuous))
        .accessibilityElement(children: .contain)
        .background(Color.clear.accessibilityIdentifier("hf.rsf02.home.hero"))
        .accessibilityIdentifier("hf.home.hero")
    }

    private var markOfTheWestHeroMedia: some View {
        ZStack {
            if HFPosterAssetHealth.hasImage(named: "mark_west_hero_keyart") {
                Image("mark_west_hero_keyart")
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(reduceMotion ? 1 : (isHeroAwake ? 1.028 : 1.0))
                    .animation(reduceMotion ? nil : .easeOut(duration: 1.15), value: isHeroAwake)
                    .accessibilityHidden(true)
            } else {
                markOfTheWestProceduralBackdrop
            }

            LinearGradient(
                colors: [
                    Color.black.opacity(0.16),
                    Color.black.opacity(0.02),
                    Color.black.opacity(0.48),
                    HFColors.background.opacity(0.98)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            LinearGradient(
                colors: [
                    Color.black.opacity(0.72),
                    Color.black.opacity(0.12),
                    Color.black.opacity(0.46)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )

            RadialGradient(
                colors: [
                    HFColors.gold.opacity(0.28),
                    HFColors.gold.opacity(0.08),
                    .clear
                ],
                center: UnitPoint(x: 0.18, y: 0.72),
                startRadius: 20,
                endRadius: 360
            )
            .blendMode(.screen)
            .opacity(isHeroAwake ? 1 : 0.48)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.9), value: isHeroAwake)
        }
        .background(Color.black)
    }

    private var markOfTheWestProceduralBackdrop: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                LinearGradient(
                    colors: [
                        Color.black,
                        Color(red: 0.06, green: 0.038, blue: 0.025),
                        Color(red: 0.23, green: 0.13, blue: 0.045),
                        Color.black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                RadialGradient(
                    colors: [
                        Color(red: 1.0, green: 0.60, blue: 0.18).opacity(0.66),
                        HFColors.gold.opacity(0.20),
                        .clear
                    ],
                    center: UnitPoint(x: 0.72, y: 0.40),
                    startRadius: 4,
                    endRadius: max(size.width, size.height) * 0.58
                )

                westernMountainLayer(size: size, verticalOffset: size.height * 0.52, opacity: 0.72)
                    .fill(Color.black.opacity(0.42))

                westernMountainLayer(size: size, verticalOffset: size.height * 0.60, opacity: 0.92)
                    .fill(Color.black.opacity(0.64))

                desertHazeLayer(size: size)

                VStack {
                    Spacer()
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.0),
                            Color(red: 0.22, green: 0.12, blue: 0.035).opacity(0.30),
                            Color.black.opacity(0.80)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: size.height * 0.48)
                }
            }
        }
        .accessibilityHidden(true)
    }

    private func westernMountainLayer(size: CGSize, verticalOffset: CGFloat, opacity: Double) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: verticalOffset))
        path.addLine(to: CGPoint(x: size.width * 0.12, y: verticalOffset - size.height * 0.06))
        path.addLine(to: CGPoint(x: size.width * 0.24, y: verticalOffset - size.height * 0.025))
        path.addLine(to: CGPoint(x: size.width * 0.38, y: verticalOffset - size.height * 0.09))
        path.addLine(to: CGPoint(x: size.width * 0.52, y: verticalOffset - size.height * 0.035))
        path.addLine(to: CGPoint(x: size.width * 0.70, y: verticalOffset - size.height * 0.115))
        path.addLine(to: CGPoint(x: size.width * 0.86, y: verticalOffset - size.height * 0.04))
        path.addLine(to: CGPoint(x: size.width, y: verticalOffset - size.height * 0.075))
        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.addLine(to: CGPoint(x: 0, y: size.height))
        path.closeSubpath()
        return path
    }

    private func desertHazeLayer(size: CGSize) -> some View {
        ZStack {
            ForEach(0..<5, id: \.self) { index in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.018),
                                HFColors.gold.opacity(0.045),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: size.width * (0.78 - CGFloat(index) * 0.07), height: 2)
                    .blur(radius: 8 + CGFloat(index) * 2)
                    .offset(
                        x: CGFloat(index - 2) * 28,
                        y: size.height * (0.48 + CGFloat(index) * 0.05)
                    )
            }
        }
        .blendMode(.screen)
        .accessibilityHidden(true)
    }

    private func markOfTheWestHeroContent(motion: DepthMotionValues) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("HighFive")
                        .font(.system(size: 27, weight: .black, design: .default))
                        .foregroundStyle(HFColors.goldGradient)
                    Text("CINEMA")
                        .font(.system(size: 12, weight: .heavy, design: .default))
                        .tracking(6)
                        .foregroundStyle(HFColors.gold.opacity(0.92))
                        .padding(.leading, 42)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("HighFive Cinema")

                Spacer()

                Button(action: onSearch) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundStyle(.white.opacity(0.94))
                        .frame(width: 48, height: 48)
                        .background(Color.black.opacity(0.24), in: Circle())
                        .overlay(Circle().stroke(.white.opacity(0.10), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Search")
            }
            .padding(.top, 52)

            HStack(spacing: 30) {
                Text("Movies")
                    .foregroundStyle(.white)
                    .overlay(alignment: .bottom) {
                        Capsule()
                            .fill(HFColors.gold)
                            .frame(width: 34, height: 3)
                            .offset(y: 12)
                    }
                Text("Series")
                Text("Categories")
            }
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(.white.opacity(0.72))
            .padding(.top, 28)

            Spacer()

            VStack(alignment: .leading, spacing: 10) {
                Text(consumerSnapshot.heroEyebrow.uppercased())
                    .font(.system(size: 13, weight: .black, design: .default))
                    .tracking(1.7)
                    .foregroundStyle(HFColors.gold)

                Text("The Mark\nof the West")
                    .font(.system(size: 42, weight: .black, design: .serif))
                    .foregroundStyle(.white)
                    .lineLimit(3)
                    .minimumScaleFactor(0.70)
                    .shadow(color: .black.opacity(0.55), radius: 14, x: 0, y: 9)

                Text("Limited Series Coming Soon")
                    .font(.system(size: 16, weight: .heavy))
                    .tracking(1.1)
                    .foregroundStyle(HFColors.gold.opacity(0.94))
                    .textCase(.uppercase)

                Text(consumerSnapshot.heroDetail)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.86))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text("A HighFive Cinema Original")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.72))
                    .padding(.top, 1)

                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Label("Coming Soon", systemImage: "clock.fill")
                            .font(HFTypography.smallAction)
                            .foregroundStyle(.black)
                            .padding(.horizontal, 18)
                            .frame(height: 48)
                            .background(HFColors.goldGradient, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .accessibilityAddTraits(.isStaticText)
                            .accessibilityIdentifier("hf.home.hero.comingSoon")

                        Button(action: onSearch) {
                            Label("Learn More", systemImage: "info.circle")
                                .font(HFTypography.smallAction)
                                .foregroundStyle(.white.opacity(0.92))
                                .padding(.horizontal, 16)
                                .frame(height: 48)
                                .background(Color.black.opacity(0.38), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(.white.opacity(0.16), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("hf.home.hero.learnMore")
                    }

                    HStack(spacing: 12) {
                        Button(action: onMyList) {
                            Label("My List", systemImage: "plus")
                                .font(.system(size: 14, weight: .black))
                                .foregroundStyle(.white.opacity(0.92))
                                .padding(.horizontal, 16)
                                .frame(height: 42)
                                .background(Color.black.opacity(0.38), in: Capsule())
                                .overlay(Capsule().stroke(HFColors.gold.opacity(0.30), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("hf.home.hero.myList")

                        CompactImportSlateButton {
                            showsImportSourcePicker = true
                        }
                    }
                }
                .padding(.top, 10)
            }
            .frame(maxWidth: 360, alignment: .leading)
            .offset(x: motion.isActive ? -motion.x * 5 : 0, y: motion.isActive ? -motion.y * 4 : 0)
            .padding(.bottom, 42)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var importVideosCover: some View {
        HFImportMovieLibrarySlateCard {
            showsImportSourcePicker = true
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.home.importVideos.cover")
    }

    @ViewBuilder
    private var importedVideosSection: some View {
        if !importedVideos.isEmpty {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                Text("Imported Videos")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, HFSpacing.screenHorizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(alignment: .top, spacing: HFSpacing.md) {
                        ForEach(importedVideos) { importedVideo in
                            Button {
                                activeImportedVideo = importedVideo
                            } label: {
                                HFImportedVideoPosterCard(item: importedVideo)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, HFSpacing.screenHorizontal)
                }
            }
            .accessibilityIdentifier("hf.home.importedVideos.section")
        }
    }

    private var categoryBrowserSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HStack(alignment: .center, spacing: HFSpacing.sm) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Genres")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(.white)

                    Text("Categories: \(selectedContentCategory.rawValue)")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                }

                Spacer(minLength: 12)

                categoryMenu
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)

            if filteredCategoryMovies.isEmpty {
                categoryEmptyState
                    .padding(.horizontal, HFSpacing.screenHorizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(alignment: .top, spacing: HFSpacing.md) {
                        ForEach(filteredCategoryMovies.prefix(12)) { movie in
                            NavigationLink(value: movie) {
                                HFPosterCard(movie: movie, width: 136, showTitle: false, posterOnly: true)
                                    .accessibilityIdentifier(movie.catalogCardAccessibilityIdentifier)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, HFSpacing.screenHorizontal)
                }
                .accessibilityIdentifier("hf.categories.results")
            }
        }
    }

    private var categoryMenu: some View {
        Menu {
            ForEach(HFContentCategory.allCases) { category in
                Button {
                    selectedContentCategory = category
                } label: {
                    if category == selectedContentCategory {
                        Label(category.rawValue, systemImage: "checkmark")
                    } else {
                        Text(category.rawValue)
                    }
                }
                .accessibilityIdentifier(category.accessibilityIdentifier)
            }
        } label: {
            Label(selectedContentCategory.rawValue, systemImage: "line.3.horizontal.decrease.circle.fill")
                .font(HFTypography.caption.weight(.black))
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .padding(.horizontal, 13)
                .frame(height: 40)
                .background(HFColors.goldGradient, in: Capsule())
                .shadow(color: HFColors.gold.opacity(0.18), radius: 12, x: 0, y: 7)
        }
        .menuStyle(.button)
        .accessibilityIdentifier("hf.categories.dropdown")
    }

    private var categoryEmptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("More titles coming soon", systemImage: "sparkles.tv.fill")
                .font(HFTypography.cardTitle)
                .foregroundStyle(.white)

            Text("We're adding more HighFive Cinema titles to this category.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(HFColors.glassSurfaceRaised, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(HFColors.gold.opacity(0.22), lineWidth: 1)
        )
        .accessibilityIdentifier("hf.categories.emptyState")
    }

    private func figmaPosterRail(title: String, movies: [Movie]) -> some View {
        let railMovies = movies.isEmpty ? streamingStore.catalogRuntimeMovies(pageSize: 10) : movies
        return VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text(title)
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(.white)
                .padding(.horizontal, HFSpacing.screenHorizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: HFSpacing.md) {
                    ForEach(railMovies.prefix(10)) { movie in
                        NavigationLink(value: movie) {
                            HFPosterCard(movie: movie, width: 136, showTitle: false, posterOnly: true)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
        .accessibilityIdentifier("hf.rsf02.home.rail.\(title)")
    }

    private var consumerSignalStrip: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack {
                Text("Trending Locally")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(.white)

                Spacer()
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: HFSpacing.sm) {
                    ForEach(consumerSnapshot.trendingSignals.prefix(4)) { signal in
                        localConsumerSignalCard(signal)
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
        .accessibilityIdentifier("hf.home.localSignals")
    }

    private func localConsumerSignalCard(_ signal: HFConsumerExperienceSignal) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: signal.systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(HFColors.gold)
                .frame(width: 38, height: 38)
                .background(HFColors.gold.opacity(0.14), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            Text(signal.title)
                .font(HFTypography.caption.weight(.black))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
            Text(signal.detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .frame(width: 172, alignment: .topLeading)
        .frame(minHeight: 128, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(HFColors.gold.opacity(0.22), lineWidth: 1)
        )
    }

    private func curatedPosterRail(title: String, detail: String? = nil, movies: [Movie], identifier: String) -> some View {
        let railMovies = movies.isEmpty ? streamingStore.catalogRuntimeMovies(pageSize: 10) : movies
        return VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(.white)
                    if let detail, !detail.isEmpty {
                        Text(detail)
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.textSecondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                Text("\(min(railMovies.count, 10)) Local")
                    .font(HFTypography.micro.weight(.black))
                    .foregroundStyle(HFColors.gold)
                    .padding(.horizontal, HFSpacing.xs)
                    .frame(height: 26)
                    .background(Color.white.opacity(0.07), in: Capsule())
                    .overlay(Capsule().stroke(HFColors.gold.opacity(0.20), lineWidth: 1))
                    .accessibilityLabel("\(min(railMovies.count, 10)) local titles in \(title)")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: HFSpacing.md) {
                    ForEach(railMovies) { movie in
                        NavigationLink(value: movie) {
                            HFPosterCard(movie: movie, width: 148, showTitle: false, posterOnly: true)
                                .accessibilityIdentifier(movie.catalogCardAccessibilityIdentifier)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
        .opacity(isHeroAwake ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (isHeroAwake ? 0 : 10))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.38).delay(0.08), value: isHeroAwake)
        .accessibilityIdentifier(identifier)
    }

    private func uniqueMovies(_ movies: [Movie]) -> [Movie] {
        var seen = Set<String>()
        return movies.filter { seen.insert($0.id).inserted }
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

                        heroSignalStrip

                        HStack(spacing: HFSpacing.xs) {
                            HFEnergyAction(title: "Watch", systemImage: "play.fill", style: .gold) {
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

    private var heroSignalStrip: some View {
        HStack(spacing: HFSpacing.xs) {
            heroConfidencePill("Local Catalog", systemImage: "checkmark.seal.fill", color: HFColors.cyanGlow)
            heroConfidencePill("Creator Pick", systemImage: "person.crop.rectangle.stack.fill", color: HFColors.violet)
            heroConfidencePill(streamingStore.isSaved(heroMovie) ? "Saved" : "Ready", systemImage: streamingStore.isSaved(heroMovie) ? "bookmark.fill" : "sparkles.tv.fill", color: HFColors.gold)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Hero signals. Local catalog. Creator pick. \(streamingStore.isSaved(heroMovie) ? "Saved" : "Ready").")
    }

    private func heroConfidencePill(_ title: String, systemImage: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(HFIconography.symbolFont(size: HFIconography.chipIconSize, weight: .black))
                .symbolRenderingMode(.hierarchical)
                .frame(width: HFIconography.chipIconFrame)
                .accessibilityHidden(true)
            Text(title)
                .font(HFTypography.micro)
                .hfSingleLineText(minimumScaleFactor: 0.62)
        }
        .foregroundStyle(color == HFColors.gold ? .black : color)
        .padding(.horizontal, HFSpacing.xs)
        .frame(height: 26)
        .background(color == HFColors.gold ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(color.opacity(0.16)))
        .overlay(Capsule().stroke(color.opacity(0.28), lineWidth: 1))
        .clipShape(Capsule())
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
                        Text("Originals, premieres, continue-watching, and editorial collections now read as one premium streaming service.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        HFSpatialRouteBadge(title: "Home -> Detail -> Player", accent: HFColors.gold)
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
                LazyHStack(alignment: .top, spacing: HFSpacing.md) {
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
                LazyHStack(spacing: HFSpacing.md) {
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
                VStack(spacing: 4) {
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

    private var errorStateQASurface: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Error Recovery", actionTitle: "FPP-08")
            VStack(spacing: 5) {
                errorQARow(.playback, title: "Playback", detail: "Resume, retry, or choose another title")
                errorQARow(.search, title: "Search", detail: "Reset query and keep browsing")
                errorQARow(.network, title: "Network", detail: "Use local cache while services recover")
                errorQARow(.auth, title: "Account", detail: "Offer development sign-in fallback")
                errorQARow(.upload, title: "Upload", detail: "Retry asset preparation safely")
                errorQARow(.download, title: "Download", detail: "Explain offline entitlement state")
            }
            .padding(.horizontal, HFSpacing.sm)
            .padding(.vertical, HFSpacing.xs)
            .background(HFColors.glassSurface)
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous)
                    .stroke(HFColors.orange.opacity(0.36), lineWidth: 1)
            )
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityIdentifier("hf.fpp.errorStates")
    }

    private func errorQARow(_ kind: HFErrorRecoveryKind, title: String, detail: String) -> some View {
        HStack(spacing: HFSpacing.sm) {
            Image(systemName: kind.systemImage)
                .font(HFIconography.symbolFont(size: 11, weight: .black))
                .foregroundStyle(kind.accent)
                .frame(width: 24, height: 24)
                .background(kind.accent.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textPrimary)
                Text(detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            Spacer()
            Text("Recover")
                .font(HFTypography.micro)
                .foregroundStyle(kind.accent)
                .padding(.horizontal, HFSpacing.xs)
                .frame(minHeight: 24)
                .background(kind.accent.opacity(0.12))
                .clipShape(Capsule())
        }
        .padding(.horizontal, HFSpacing.xs)
        .padding(.vertical, 5)
        .background(HFColors.quietFill)
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
    }

    private var accessibilityQASurface: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Accessibility Audit", actionTitle: "FPP-09")
            HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.cyanGlow.opacity(0.38)) {
                VStack(alignment: .leading, spacing: 5) {
                    accessibilityQARow(
                        systemImage: "speaker.wave.2.fill",
                        title: "VoiceOver",
                        detail: "Cards, tabs, filters, search, and recovery states expose labels."
                    )
                    accessibilityQARow(
                        systemImage: "textformat.size",
                        title: "Dynamic Type",
                        detail: "Shared text keeps readable wrapping and scale behavior."
                    )
                    accessibilityQARow(
                        systemImage: "figure.wave",
                        title: "Reduced Motion",
                        detail: "Primary motion paths use system reduce-motion settings."
                    )
                    accessibilityQARow(
                        systemImage: "circle.lefthalf.filled",
                        title: "Contrast",
                        detail: "Accents stay paired with explicit text labels."
                    )
                    accessibilityQARow(
                        systemImage: "keyboard",
                        title: "Focus",
                        detail: "Controls keep stable labels, values, and 44 point targets."
                    )
                }
                .padding(HFSpacing.sm)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Accessibility audit. VoiceOver labels, Dynamic Type handling, reduced motion, contrast, and focus targets verified.")
        .accessibilityIdentifier("hf.fpp.accessibility")
    }

    private func accessibilityQARow(systemImage: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: systemImage)
                .font(HFIconography.symbolFont(size: 13, weight: .black))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(HFColors.cyanGlow)
                .frame(width: 26, height: 26)
                .background(HFColors.cyanGlow.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                    .hfSingleLineText(minimumScaleFactor: 0.74)
                Text(detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .hfSingleLineText(minimumScaleFactor: 0.70)
            }
        }
        .padding(.horizontal, HFSpacing.xs)
        .padding(.vertical, 6)
        .background(HFColors.quietFill)
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(detail)")
    }

    private var performanceQASurface: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Performance Pass", actionTitle: "FPP-10")
            HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
                VStack(alignment: .leading, spacing: 6) {
                    performanceQARow(systemImage: "rectangle.stack.fill", title: "Lazy Rails", detail: "Horizontal shelves instantiate visible cards first.")
                    performanceQARow(systemImage: "sparkles.rectangle.stack.fill", title: "Poster Cost", detail: "Poster shadows are tuned for lower overdraw.")
                    performanceQARow(systemImage: "speedometer", title: "Startup", detail: "Home uses cached runtime queries and bounded shelf counts.")
                    performanceQARow(systemImage: "memorychip.fill", title: "Memory", detail: "Large rows avoid eager offscreen card creation.")
                    performanceQARow(systemImage: "hand.draw.fill", title: "Scrolling", detail: "Core consumer rails keep smooth horizontal movement.")
                }
                .padding(HFSpacing.sm)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Performance pass. Lazy rails, tuned poster cost, startup, memory, and scrolling improvements verified.")
        .accessibilityIdentifier("hf.fpp.performance")
    }

    private func performanceQARow(systemImage: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: systemImage)
                .font(HFIconography.symbolFont(size: 13, weight: .black))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(HFColors.gold)
                .frame(width: 26, height: 26)
                .background(HFColors.gold.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                    .hfSingleLineText(minimumScaleFactor: 0.74)
                Text(detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .hfSingleLineText(minimumScaleFactor: 0.70)
            }
        }
        .padding(.horizontal, HFSpacing.xs)
        .padding(.vertical, 6)
        .background(HFColors.quietFill)
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(detail)")
    }

    private var homePolishQASurface: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Home Polish", actionTitle: "FPP-11")
            HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.violet.opacity(0.34)) {
                VStack(alignment: .leading, spacing: 6) {
                    homePolishQARow(systemImage: "sparkles.tv.fill", title: "Hero", detail: "Signals, metadata, and actions read in one premium viewport.")
                    homePolishQARow(systemImage: "rectangle.stack.fill", title: "Rails", detail: "Originals, premieres, trending, creator, and awards stay consistent.")
                    homePolishQARow(systemImage: "play.rectangle.on.rectangle.fill", title: "Previews", detail: "Watch, Depth, Save, Detail, and Player routes remain intact.")
                    homePolishQARow(systemImage: "arrow.triangle.2.circlepath", title: "Transitions", detail: "Hero handoff and route badges preserve cinematic continuity.")
                    homePolishQARow(systemImage: "wand.and.stars", title: "Service Feel", detail: "Home now reads as a premium streaming app first.")
                }
                .padding(HFSpacing.sm)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Home polish. Hero, rails, previews, transitions, and premium service feel verified.")
        .accessibilityIdentifier("hf.fpp.homePolish")
    }

    private func homePolishQARow(systemImage: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: systemImage)
                .font(HFIconography.symbolFont(size: 13, weight: .black))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(HFColors.violet)
                .frame(width: 26, height: 26)
                .background(HFColors.violet.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                    .hfSingleLineText(minimumScaleFactor: 0.74)
                Text(detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .hfSingleLineText(minimumScaleFactor: 0.70)
            }
        }
        .padding(.horizontal, HFSpacing.xs)
        .padding(.vertical, 6)
        .background(HFColors.quietFill)
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(detail)")
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
                    LazyHStack(spacing: HFSpacing.md) {
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
                LazyHStack(alignment: .top, spacing: HFSpacing.md) {
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

    private func handleImportedVideo(_ result: Result<[URL], Error>) {
        do {
            guard let sourceURL = try result.get().first else { return }
            let importedVideo = try HFImportedVideoLibrary.importVideo(from: sourceURL)
            importedVideos = HFImportedVideoLibrary.load()
            importErrorMessage = nil
            activeImportedVideo = importedVideo
        } catch {
            importErrorMessage = "Import failed: \(error.localizedDescription)"
        }
    }

    @MainActor
    private func handlePhotoLibraryVideo(_ item: PhotosPickerItem) async {
        do {
            guard let transfer = try await item.loadTransferable(type: HFPhotoLibraryVideoTransfer.self) else {
                importErrorMessage = "Photo Library import did not provide a readable video."
                selectedPhotoLibraryVideo = nil
                return
            }
            let importedVideo = try HFImportedVideoLibrary.importVideo(from: transfer.url)
            try? FileManager.default.removeItem(at: transfer.url)
            importedVideos = HFImportedVideoLibrary.load()
            importErrorMessage = nil
            selectedPhotoLibraryVideo = nil
            showsImportSourcePicker = false
            activeImportedVideo = importedVideo
        } catch {
            importErrorMessage = "Photo Library import failed: \(error.localizedDescription)"
            selectedPhotoLibraryVideo = nil
        }
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
    private func heroMedia(_ movie: Movie) -> some View {
        ZStack {
            heroArtwork(movie)

            if !reduceMotion, let timelineURL = Bundle.main.url(forResource: "Timeline1", withExtension: "mov") {
                HFHomeHeroTimelineVideo(url: timelineURL)
                    .accessibilityHidden(true)
                    .transition(.opacity)
            }
        }
        .background(Color.black)
        .accessibilityIdentifier("hf.home.hero.timelineVideo")
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

private struct HFHomeHeroTimelineVideo: UIViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }

    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.backgroundColor = .black
        view.playerLayer.videoGravity = .resizeAspectFill
        view.playerLayer.player = context.coordinator.player
        context.coordinator.play()
        return view
    }

    func updateUIView(_ uiView: PlayerView, context: Context) {
        if uiView.playerLayer.player !== context.coordinator.player {
            uiView.playerLayer.player = context.coordinator.player
        }
        context.coordinator.play()
    }

    static func dismantleUIView(_ uiView: PlayerView, coordinator: Coordinator) {
        coordinator.pause()
        uiView.playerLayer.player = nil
    }

    final class PlayerView: UIView {
        override static var layerClass: AnyClass {
            AVPlayerLayer.self
        }

        var playerLayer: AVPlayerLayer {
            layer as! AVPlayerLayer
        }
    }

    final class Coordinator {
        let player: AVPlayer
        private var endObserver: NSObjectProtocol?

        init(url: URL) {
            let item = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: item)
            player.isMuted = true
            player.actionAtItemEnd = .none
            player.automaticallyWaitsToMinimizeStalling = false

            endObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: item,
                queue: .main
            ) { [weak player] _ in
                player?.seek(to: .zero)
                player?.play()
            }
        }

        func play() {
            guard player.timeControlStatus != .playing else { return }
            player.play()
        }

        func pause() {
            player.pause()
        }

        deinit {
            if let endObserver {
                NotificationCenter.default.removeObserver(endObserver)
            }
        }
    }
}

private struct HFImportMovieSourceSheet: View {
    @Binding var selectedPhotoLibraryVideo: PhotosPickerItem?
    let onFiles: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Capsule()
                .fill(HFColors.gold.opacity(0.46))
                .frame(width: 42, height: 4)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text("Import Movie Library")
                    .font(.system(size: 24, weight: .black, design: .default))
                    .foregroundStyle(.white)
                Text("Choose a video from Photos or Files.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
            }

            HStack(spacing: 12) {
                PhotosPicker(
                    selection: $selectedPhotoLibraryVideo,
                    matching: .videos,
                    photoLibrary: .shared()
                ) {
                    importSourceButtonLabel(title: "Photo Library", systemImage: "photo.on.rectangle.angled")
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.home.importVideos.photos")

                Button(action: onFiles) {
                    importSourceButtonLabel(title: "Files", systemImage: "folder.badge.plus")
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.home.importVideos.files")
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .padding(.top, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(HFColors.screenBackground.ignoresSafeArea())
    }

    private func importSourceButtonLabel(title: String, systemImage: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 28, weight: .black))
                .foregroundStyle(HFColors.gold)

            Text(title)
                .font(HFTypography.caption.weight(.black))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 112)
        .background(HFColors.glassSurfaceRaised, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(HFColors.gold.opacity(0.30), lineWidth: 1)
        )
    }
}

private struct HFPhotoLibraryVideoTransfer: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { transfer in
            SentTransferredFile(transfer.url)
        } importing: { received in
            let sourceURL = received.file
            let extensionName = sourceURL.pathExtension.isEmpty ? "mov" : sourceURL.pathExtension
            let destinationURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("highfive-photo-library-\(UUID().uuidString).\(extensionName)")
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            return HFPhotoLibraryVideoTransfer(url: destinationURL)
        }
    }
}

private struct HFImportMovieLibrarySlateCard: View {
    let onTap: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isSlateOpen = false

    var body: some View {
        Button {
            playSlateTap()
            onTap()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black,
                                Color(red: 0.055, green: 0.055, blue: 0.06),
                                Color(red: 0.13, green: 0.10, blue: 0.045)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .opacity(0.14)

                HStack(spacing: 14) {
                    clapperGraphic
                        .frame(width: 66, height: 62)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Import Movie Library")
                            .font(.system(size: 20, weight: .black, design: .default))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)

                        Text("Local private playback")
                            .font(HFTypography.caption.weight(.semibold))
                            .foregroundStyle(HFColors.textSecondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .shadow(color: .black.opacity(0.34), radius: 8, x: 0, y: 5)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(HFColors.gold.opacity(0.86))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                slateLinework
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 106)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                HFColors.gold.opacity(0.62),
                                .white.opacity(0.12),
                                HFColors.gold.opacity(0.28)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.34), radius: 24, x: 0, y: 16)
            .shadow(color: HFColors.gold.opacity(0.10), radius: 18, x: 0, y: 10)
            .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Import Movie Library")
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                isSlateOpen = true
            }
        }
    }

    private var clapperGraphic: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(Color(red: 0.025, green: 0.025, blue: 0.028))
                .frame(height: 42)
                .overlay(
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .stroke(HFColors.gold.opacity(0.50), lineWidth: 1)
                )
                .overlay(alignment: .top) {
                    VStack(spacing: 8) {
                        Rectangle()
                            .fill(HFColors.gold.opacity(0.72))
                            .frame(height: 1)
                        Rectangle()
                            .fill(.white.opacity(0.12))
                            .frame(height: 1)
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 9)
                }
                .overlay(alignment: .bottomTrailing) {
                    Circle()
                        .fill(HFColors.gold.opacity(0.72))
                        .frame(width: 5, height: 5)
                        .padding(8)
                }

            clapperTop
                .frame(height: 23)
                .offset(y: -38)
                .rotationEffect(.degrees(isSlateOpen ? -11 : -2), anchor: .leading)
                .shadow(color: .black.opacity(0.34), radius: 8, x: 0, y: 5)
        }
    }

    private var clapperTop: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(red: 0.035, green: 0.035, blue: 0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(HFColors.gold.opacity(0.58), lineWidth: 1)
                )

            HStack(spacing: 0) {
                ForEach(0..<5, id: \.self) { index in
                    Rectangle()
                        .fill(index.isMultiple(of: 2) ? HFColors.gold.opacity(0.88) : .white.opacity(0.13))
                        .rotationEffect(.degrees(-22))
                        .frame(width: 21)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    private var slateLinework: some View {
        VStack {
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 9) {
                    Rectangle()
                        .fill(HFColors.gold.opacity(0.36))
                        .frame(width: 76, height: 1)
                    Rectangle()
                        .fill(.white.opacity(0.12))
                        .frame(width: 52, height: 1)
                }
            }
            Spacer()
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, HFColors.gold.opacity(0.22), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
        }
        .padding(18)
    }

    private func playSlateTap() {
        guard !reduceMotion else { return }
        withAnimation(.spring(response: 0.18, dampingFraction: 0.72)) {
            isSlateOpen.toggle()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            withAnimation(.spring(response: 0.26, dampingFraction: 0.82)) {
                isSlateOpen.toggle()
            }
        }
    }
}

private struct HFImportedVideoItem: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var fileName: String
    var filePath: String
    var importedAt: Date

    var fileURL: URL {
        URL(fileURLWithPath: filePath)
    }

    var movie: Movie {
        Movie(
            id: "imported-\(id.uuidString)",
            title: title,
            subtitle: "User imported video",
            synopsis: "A local video imported from your device for HighFive Cinema playback.",
            year: "",
            rating: "Imported",
            duration: "Local",
            genres: ["Imported"],
            posterAssetName: nil,
            backdropAssetName: nil,
            creatorName: "My Videos",
            isOriginal: false,
            isComingSoon: false,
            isDownloaded: true,
            progress: nil
        )
    }
}

private enum HFContentCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case movies = "Movies"
    case series = "Series"
    case drama = "Drama"
    case action = "Action"
    case horror = "Horror"
    case documentaries = "Documentaries"
    case comedy = "Comedy"
    case thriller = "Thriller"
    case mystery = "Mystery"
    case sciFi = "Sci-Fi"
    case fantasy = "Fantasy"
    case romance = "Romance"
    case family = "Family"
    case war = "War"
    case faithInspirational = "Faith / Inspirational"
    case music = "Music"
    case sports = "Sports"
    case other = "Other"

    var id: String { rawValue }

    var accessibilityIdentifier: String {
        switch self {
        case .all: return "hf.categories.option.all"
        case .movies: return "hf.categories.option.movies"
        case .series: return "hf.categories.option.series"
        case .drama: return "hf.categories.option.drama"
        case .action: return "hf.categories.option.action"
        case .horror: return "hf.categories.option.horror"
        case .documentaries: return "hf.categories.option.documentaries"
        case .comedy: return "hf.categories.option.comedy"
        case .thriller: return "hf.categories.option.thriller"
        case .mystery: return "hf.categories.option.mystery"
        case .sciFi: return "hf.categories.option.scifi"
        case .fantasy: return "hf.categories.option.fantasy"
        case .romance: return "hf.categories.option.romance"
        case .family: return "hf.categories.option.family"
        case .war: return "hf.categories.option.war"
        case .faithInspirational: return "hf.categories.option.faithInspirational"
        case .music: return "hf.categories.option.music"
        case .sports: return "hf.categories.option.sports"
        case .other: return "hf.categories.option.other"
        }
    }

    func includes(_ movie: Movie) -> Bool {
        switch self {
        case .all:
            return true
        case .movies:
            return movie.id == "friendly" || (movie.duration.localizedCaseInsensitiveContains("Feature") && !movie.genres.containsCaseInsensitive("Series"))
        case .series:
            return movie.id == "paranormall-s1" ||
                movie.genres.containsCaseInsensitive("Series") ||
                movie.duration.localizedCaseInsensitiveContains("episodes") ||
                movie.duration.localizedCaseInsensitiveContains("series")
        case .drama:
            return movie.genres.containsCaseInsensitive("Drama")
        case .action:
            return movie.genres.containsCaseInsensitive("Action")
        case .horror:
            return movie.genres.containsCaseInsensitive("Horror")
        case .documentaries:
            return movie.genres.containsCaseInsensitive("Documentary") ||
                movie.genres.containsCaseInsensitive("Documentaries")
        case .comedy:
            return movie.genres.containsCaseInsensitive("Comedy")
        case .thriller:
            return movie.genres.containsCaseInsensitive("Thriller")
        case .mystery:
            return movie.genres.containsCaseInsensitive("Mystery")
        case .sciFi:
            return movie.genres.containsCaseInsensitive("Sci-Fi") ||
                movie.genres.containsCaseInsensitive("Science Fiction") ||
                movie.genres.containsCaseInsensitive("SciFi")
        case .fantasy:
            return movie.genres.containsCaseInsensitive("Fantasy")
        case .romance:
            return movie.genres.containsCaseInsensitive("Romance")
        case .family:
            return movie.genres.containsCaseInsensitive("Family")
        case .war:
            return movie.genres.containsCaseInsensitive("War")
        case .faithInspirational:
            return movie.genres.containsCaseInsensitive("Faith") ||
                movie.genres.containsCaseInsensitive("Inspirational")
        case .music:
            return movie.genres.containsCaseInsensitive("Music")
        case .sports:
            return movie.genres.containsCaseInsensitive("Sports") ||
                movie.genres.containsCaseInsensitive("Sport")
        case .other:
            return movie.genres.isEmpty || movie.genres.containsCaseInsensitive("Other")
        }
    }
}

private extension Movie {
    var catalogCardAccessibilityIdentifier: String {
        switch id {
        case "friendly":
            return "hf.catalog.card.friendly"
        case "paranormall-s1":
            return "hf.catalog.card.paranormall"
        default:
            return "hf.catalog.card.\(id)"
        }
    }
}

private extension Array where Element == String {
    func containsCaseInsensitive(_ value: String) -> Bool {
        contains { $0.localizedCaseInsensitiveContains(value) }
    }
}

private enum HFImportedVideoLibrary {
    static func load() -> [HFImportedVideoItem] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let data = try? Data(contentsOf: manifestURL),
              let items = try? decoder.decode([HFImportedVideoItem].self, from: data) else {
            return []
        }

        return items
            .filter { FileManager.default.fileExists(atPath: $0.filePath) }
            .sorted { $0.importedAt > $1.importedAt }
    }

    static func importVideo(from sourceURL: URL) throws -> HFImportedVideoItem {
        let didStartAccess = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if didStartAccess {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }

        try FileManager.default.createDirectory(at: importDirectory, withIntermediateDirectories: true)

        let id = UUID()
        let originalName = sourceURL.lastPathComponent.isEmpty ? "ImportedVideo.mov" : sourceURL.lastPathComponent
        let extensionName = sourceURL.pathExtension.isEmpty ? "mov" : sourceURL.pathExtension
        let safeBaseName = sourceURL.deletingPathExtension().lastPathComponent
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
        let fileName = "\(safeBaseName)-\(id.uuidString.prefix(8)).\(extensionName)"
        let destinationURL = importDirectory.appendingPathComponent(fileName)

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }
        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)

        let title = sourceURL.deletingPathExtension().lastPathComponent.isEmpty
            ? originalName
            : sourceURL.deletingPathExtension().lastPathComponent
        let item = HFImportedVideoItem(
            id: id,
            title: title,
            fileName: fileName,
            filePath: destinationURL.path,
            importedAt: Date()
        )

        var items = load()
        items.removeAll { $0.filePath == item.filePath || $0.title == item.title }
        items.insert(item, at: 0)
        try save(items)
        return item
    }

    private static func save(_ items: [HFImportedVideoItem]) throws {
        try FileManager.default.createDirectory(at: importDirectory, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(items)
        try data.write(to: manifestURL, options: [.atomic])
    }

    private static var manifestURL: URL {
        importDirectory.appendingPathComponent("imported-videos.json")
    }

    private static var importDirectory: URL {
        let supportDirectory = (try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )) ?? FileManager.default.temporaryDirectory
        return supportDirectory.appendingPathComponent("ImportedVideos", isDirectory: true)
    }
}

private struct HFImportedVideoPosterCard: View {
    let item: HFImportedVideoItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black,
                                HFColors.gold.opacity(0.22),
                                Color(red: 0.08, green: 0.07, blue: 0.06)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: "play.rectangle.fill")
                    .font(.system(size: 34, weight: .black))
                    .foregroundStyle(HFColors.gold)
                    .padding(14)
            }
            .frame(width: 136, height: 204)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(HFColors.gold.opacity(0.28), lineWidth: 1)
            )

            Text(item.title)
                .font(HFTypography.caption.weight(.bold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .frame(width: 136, alignment: .leading)
        }
        .accessibilityIdentifier("hf.home.importedVideo.card")
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
