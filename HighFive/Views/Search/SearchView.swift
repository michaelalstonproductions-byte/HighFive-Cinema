import SwiftUI

enum HFSearchHubMode: String, Hashable {
    case search = "Search"
    case discover = "Discover"
}

private enum HFDiscoveryFocus: String, CaseIterable, Identifiable {
    case tonight
    case films
    case series
    case mystery
    case creatorPicks

    var id: String { rawValue }

    var title: String {
        switch self {
        case .tonight: return "Tonight"
        case .films: return "Films"
        case .series: return "Series"
        case .mystery: return "Mystery"
        case .creatorPicks: return "Creator Picks"
        }
    }

    var detail: String {
        switch self {
        case .tonight: return "Local mood scan"
        case .films: return "Feature cinema"
        case .series: return "Episodic worlds"
        case .mystery: return "Shadow stories"
        case .creatorPicks: return "HighFive originals"
        }
    }

    var systemImage: String {
        switch self {
        case .tonight: return "moon.stars.fill"
        case .films: return "film.stack.fill"
        case .series: return "rectangle.stack.fill"
        case .mystery: return "eye.fill"
        case .creatorPicks: return "sparkles"
        }
    }

    var filter: String {
        switch self {
        case .films: return "Movies"
        case .series: return "Series"
        case .creatorPicks: return "Originals"
        default: return "All"
        }
    }

    var querySeed: String {
        switch self {
        case .mystery: return "Mystery"
        case .creatorPicks: return "HighFive"
        default: return ""
        }
    }

    var accessibilityIdentifier: String {
        "hf.spatial.search.\(rawValue)"
    }
}

struct SearchView: View {
    @EnvironmentObject private var streamingStore: HFStreamingStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Binding private var mode: HFSearchHubMode
    @State private var query: String
    @State private var selectedFilter: String
    @State private var selectedFocus: HFDiscoveryFocus
    @State private var isSceneAwake = false
    @State private var showsInspector = false
    @State private var didRequestDiscoveryService = false

    private let forcesEmptyState: Bool
    private let shouldRunDiscoveryService: Bool
    private let filters = ["All", "Movies", "Series", "Originals", "Creator Published", "Downloaded"]
    private let columns = [
        GridItem(.adaptive(minimum: HFSpacing.posterGridWidth), spacing: HFSpacing.md)
    ]

    init(mode: Binding<HFSearchHubMode>) {
        let arguments = ProcessInfo.processInfo.arguments
        let startsWithResults = arguments.contains("--hf-start-search-results") || arguments.contains("--hf-premium-streaming-discovery") || arguments.contains("--hf-start-discovery-service") || arguments.contains("--hf-discovery-search-service")
        let startsEmpty = arguments.contains("--hf-start-search-empty") || arguments.contains("--hf-discovery-empty")
        _mode = mode
        _query = State(initialValue: arguments.contains("--hf-discovery-creator") ? "Maya" : startsWithResults ? "Friendly" : "")
        _selectedFilter = State(initialValue: startsWithResults ? "Movies" : "All")
        _selectedFocus = State(initialValue: startsWithResults ? .films : .tonight)
        forcesEmptyState = startsEmpty
        shouldRunDiscoveryService = arguments.contains("--hf-start-discovery-service")
            || arguments.contains("--hf-discovery-search-service")
            || arguments.contains("--hf-discovery-recommendations")
            || arguments.contains("--hf-discovery-related")
            || arguments.contains("--hf-discovery-creator")
            || arguments.contains("--hf-discovery-empty")
    }

    private var usesFallbackLayout: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    private var results: [Movie] {
        guard !forcesEmptyState else { return [] }
        let seedQuery = query.isEmpty ? selectedFocus.querySeed : query
        let filter = selectedFilter == "All" ? selectedFocus.filter : selectedFilter
        return streamingStore.searchMovies(query: seedQuery, filter: filter)
    }

    private var featuredTitle: Movie {
        results.first ?? streamingStore.featuredMovie
    }

    private var creatorProfiles: [HFCreatorProfile] {
        let seedQuery = query.isEmpty ? selectedFocus.querySeed : query
        return streamingStore.searchCreatorProfiles(query: seedQuery)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.sectionGap) {
                header
                if shouldRunDiscoveryService {
                    discoveryServiceRuntimeSurface
                }
                discoveryWorld
                premiumDiscoveryCollections
                creatorProfilesSection
                recommendationLayer
                resultsSection
            }
            .padding(.top, HFSpacing.screenTop)
            .padding(.bottom, HFSpacing.floatingTabClearance + HFSpacing.tabBarHeight)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .sheet(isPresented: $showsInspector) {
            searchInspector
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
            guard shouldRunDiscoveryService, !didRequestDiscoveryService else { return }
            didRequestDiscoveryService = true
            let serviceQuery = query.isEmpty ? selectedFocus.querySeed : query
            let serviceFilter = selectedFilter == "All" ? selectedFocus.filter : selectedFilter
            await streamingStore.runSearchDiscoveryRecommendationServiceFixture(query: serviceQuery, filter: serviceFilter, anchor: featuredTitle)
        }
        .accessibilityIdentifier("hf.spatial.search")
        .accessibilityIdentifier("hf.streaming.premium.discovery")
        .accessibilityIdentifier("hf.consumer.search.root")
        .accessibilityIdentifier("hf.search.screen")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Text(mode == .search ? "Search" : "Discover")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
            Text("Spatial Discovery Observatory")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilitySortPriority(4)
    }

    private var discoveryWorld: some View {
        VStack(spacing: HFSpacing.md) {
            discoveryLens
                .accessibilitySortPriority(3)

            HFSpatialActionCluster {
                HFEnergyAction(title: "Browse Local Catalog", systemImage: "sparkle.magnifyingglass", style: .gold) {
                    query = ""
                    selectedFilter = selectedFocus.filter
                    mode = .search
                }
                .accessibilityIdentifier("hf.search.browseCatalog")
                .accessibilityIdentifier("hf.search.localCatalog")

                HStack(spacing: HFSpacing.sm) {
                    HFEnergyAction(title: "Clear", systemImage: "xmark.circle.fill", style: .glass) {
                        query = ""
                        selectedFilter = "All"
                    }
                    HFEnergyAction(title: "Open Inspector", systemImage: "slider.horizontal.3", style: .glass) {
                        showsInspector = true
                    }
                    .accessibilityIdentifier("hf.search.inspector")
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)

            if !usesFallbackLayout {
                focusSelector
                    .accessibilitySortPriority(1)
            }
        }
        .hfSpatialSceneEntrance(isActive: isSceneAwake, reduceMotion: reduceMotion)
        .accessibilityIdentifier("hf.spatial.search.world")
        .accessibilityIdentifier("hf.spatial.accessibility.largeType")
    }

    private var discoveryServiceRuntimeSurface: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.cyanGlow.opacity(0.42)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "sparkle.magnifyingglass")
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(HFColors.cyanGlow)
                        .frame(width: 54, height: 54)
                        .background(HFColors.cyanGlow.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Discovery Service")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(streamingStore.searchDiscoveryRecommendationSnapshot.detail)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Text(streamingStore.searchDiscoveryRecommendationSnapshot.statusLabel)
                        .font(HFTypography.micro.weight(.bold))
                        .foregroundStyle(HFColors.cyanGlow)
                        .padding(.horizontal, HFSpacing.sm)
                        .frame(minHeight: 34)
                        .background(HFColors.cyanGlow.opacity(0.12))
                        .clipShape(Capsule())
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.sm) {
                    ForEach(streamingStore.searchDiscoveryServiceRows) { row in
                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            Image(systemName: row.systemImage)
                                .font(.system(size: 20, weight: .black))
                                .foregroundStyle(HFColors.cyanGlow)
                            Text(row.value)
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                            Text(row.title)
                                .font(HFTypography.caption.weight(.bold))
                                .foregroundStyle(HFColors.textSecondary)
                            Text(row.detail)
                                .font(HFTypography.micro)
                                .foregroundStyle(HFColors.textMuted)
                                .lineLimit(2)
                                .minimumScaleFactor(0.74)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(minHeight: 132, alignment: .topLeading)
                        .padding(HFSpacing.sm)
                        .background(Color.white.opacity(0.07))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
                        .accessibilityIdentifier("hf.discovery.service.\(row.id)")
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.discovery.service.runtime")
    }

    private var discoveryLens: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius + 10, strokeColor: HFColors.cyanGlow.opacity(0.42)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HFSearchBar(text: $query, placeholder: "Search your HighFive library")
                    .onSubmit { streamingStore.addRecentSearch(query) }
                    .accessibilityIdentifier("hf.spatial.search.field")

                ZStack(alignment: .bottomLeading) {
                    posterField

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("LOCAL CATALOG")
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.cyanGlow)
                        Text(featuredTitle.title)
                            .font(HFTypography.display)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.72)
                        Text(featuredTitle.subtitle)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .lineLimit(2)
                        HStack(spacing: HFSpacing.xs) {
                            Text(selectedFocus.title)
                            Text("\(results.count) local matches")
                        }
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textPrimary)
                    }
                    .padding(HFSpacing.md)
                }
                .frame(maxWidth: .infinity)
                .frame(height: usesFallbackLayout ? 258 : 292)
                .accessibilityIdentifier("hf.spatial.search.lens")
                .accessibilityIdentifier("hf.spatial.search.featuredTitle")
                .accessibilityLabel("Discovery lens. Featured local title \(featuredTitle.title). Selected focus \(selectedFocus.title).")

                filterRow
            }
            .padding(HFSpacing.md)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var posterField: some View {
        ZStack {
            RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous)
                .fill(reduceTransparency ? Color.black.opacity(0.95) : Color.black.opacity(0.58))
            HFDepthContourOverlay(color: HFColors.cyanGlow.opacity(0.62))
                .opacity(0.30)
            HStack(spacing: usesFallbackLayout ? -18 : -24) {
                ForEach(Array(results.prefix(3).enumerated()), id: \.element.id) { index, movie in
                    HFPosterCard(movie: movie, width: usesFallbackLayout ? 88 : 110, showTitle: false, posterOnly: true)
                        .rotationEffect(.degrees(Double(index - 1) * (reduceMotion ? 0 : 6)))
                        .opacity(index == 0 ? 1 : 0.72)
                        .offset(y: CGFloat(index) * (reduceMotion ? 0 : 8))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(.horizontal, HFSpacing.md)
            .clipped()
            .accessibilityHidden(true)
        }
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous))
    }

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HFSpacing.xs) {
                ForEach(filters, id: \.self) { filter in
                    HFFilterChip(title: filter, isSelected: selectedFilter == filter) {
                        selectedFilter = filter
                    }
                }
            }
        }
        .accessibilityIdentifier("hf.consumer.search.genreFilters")
    }

    private var focusSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HFSpacing.sm) {
                ForEach(HFDiscoveryFocus.allCases) { focus in
                    focusButton(focus)
                        .frame(width: usesFallbackLayout ? 150 : 132)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
            .padding(.vertical, HFSpacing.xs)
        }
        .accessibilityIdentifier("hf.spatial.search.selectedFocus")
        .accessibilityIdentifier("hf.spatial.accessibility.fallbackLayout")
    }

    private func focusButton(_ focus: HFDiscoveryFocus) -> some View {
        let isSelected = selectedFocus == focus
        return Button {
            withAnimation(reduceMotion ? nil : HFSpatialMotionTokens.focusAnimation) {
                selectedFocus = focus
                selectedFilter = focus.filter
            }
        } label: {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Image(systemName: focus.systemImage)
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(isSelected ? HFColors.cyanGlow : HFColors.textSecondary)
                Text(focus.title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                Text(isSelected ? "Selected" : focus.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(isSelected ? HFColors.cyanGlow : HFColors.textMuted)
                    .lineLimit(2)
                if differentiateWithoutColor {
                    Label(isSelected ? "Selected" : "Available", systemImage: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(HFTypography.micro)
                        .foregroundStyle(isSelected ? HFColors.cyanGlow : HFColors.textMuted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 86, alignment: .topLeading)
            .padding(HFSpacing.sm)
            .background(isSelected ? HFColors.cyanGlow.opacity(0.16) : Color.white.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                    .stroke(isSelected ? HFColors.cyanGlow.opacity(0.72) : Color.white.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .hfSpatialSelectionTreatment(isSelected: isSelected, accent: HFColors.cyanGlow, reduceMotion: reduceMotion, differentiateWithoutColor: differentiateWithoutColor)
        .accessibilityLabel("\(focus.title), \(focus.detail)")
        .accessibilityIdentifier(focus.accessibilityIdentifier)
    }

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: query.isEmpty ? "Local Results" : "Results", actionTitle: "\(results.count)")
            if results.isEmpty {
                emptyState
            } else {
                LazyVGrid(columns: columns, alignment: .leading, spacing: HFSpacing.lg) {
                    ForEach(results) { movie in
                        NavigationLink(value: movie) {
                            HFPosterCard(movie: movie, width: HFSpacing.posterGridWidth, showMetadata: true, showProgress: movie.progress != nil)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("hf.search.resultCard")
                        .accessibilityIdentifier("hf.route.searchToMovieDetail")
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
        .accessibilityIdentifier("hf.search.results")
        .accessibilityIdentifier("hf.streaming.premium.searchResults")
        .accessibilityIdentifier("hf.consumer.search.results")
    }

    private var premiumDiscoveryCollections: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Discovery Engine", actionTitle: "Local catalog")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HFSpacing.md) {
                    ForEach(streamingStore.discoveryCollections) { category in
                        premiumDiscoveryCard(category)
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Discovery collections including featured, trending, new releases, HighFive originals, creator published, award winners, and premieres.")
        .accessibilityIdentifier("hf.discovery.engine.collections")
        .accessibilityIdentifier("hf.streaming.premium.collectionWorlds")
    }

    private func premiumDiscoveryCard(_ category: Category) -> some View {
        let accent = discoveryAccent(for: category.id)

        return Button {
            withAnimation(reduceMotion ? nil : HFSpatialMotionTokens.microAnimation) {
                selectedFilter = category.id == "creator-published" ? "Creator Published" : "All"
                query = category.title
            }
        } label: {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                Image(systemName: discoveryIcon(for: category.id))
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(accent == HFColors.gold ? .black : accent)
                    .frame(width: 48, height: 48)
                    .background(accent == HFColors.gold ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(accent.opacity(0.18)))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
                Text(category.title)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                Text(category.subtitle ?? "\(category.movies.count) local titles")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                Text("\(category.movies.count) titles")
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(accent)
            }
            .frame(width: 190, alignment: .leading)
            .padding(HFSpacing.md)
            .background(Color.white.opacity(0.06))
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                    .stroke(accent.opacity(0.28), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open \(category.title) collection. \(category.subtitle ?? "")")
    }

    private var recommendationLayer: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Recommendation Layer", actionTitle: "Local first")

            VStack(spacing: HFSpacing.md) {
                ForEach(streamingStore.recommendationCollections(anchor: featuredTitle)) { category in
                    recommendationRail(category)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Local recommendation layer with because you watched, similar titles, from same creator, and continue watching.")
        .accessibilityIdentifier("hf.discovery.engine.recommendations")
    }

    private var creatorProfilesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Creator Profiles", actionTitle: "Discovery")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    ForEach(creatorProfiles) { profile in
                        NavigationLink(value: profile.creator) {
                            creatorProfileCard(profile)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("hf.route.searchToCreatorProfile")
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Creator profiles searchable from discovery.")
        .accessibilityIdentifier("hf.search.creatorProfiles")
        .accessibilityIdentifier("hf.discovery.creatorProfiles")
    }

    private func creatorProfileCard(_ profile: HFCreatorProfile) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                HStack(spacing: HFSpacing.sm) {
                    Image(systemName: profile.avatarSymbol)
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(HFColors.violet)
                        .frame(width: 48, height: 48)
                        .background(HFColors.violet.opacity(0.14))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 3) {
                        Text(profile.creator.name)
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.70)
                        Text(profile.creator.role)
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.violet)
                            .lineLimit(1)
                    }
                }

                Text(profile.bio)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: HFSpacing.xs) {
                    creatorMetricPill(title: "\(profile.publishedTitles.count)", detail: "Published")
                    creatorMetricPill(title: "\(profile.filmography.count)", detail: "Filmography")
                }

                Label("Open Creator Profile", systemImage: "person.crop.rectangle.stack.fill")
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(HFColors.gold)
            }
            .padding(HFSpacing.md)
            .frame(width: 244, alignment: .topLeading)
            .frame(minHeight: 214, alignment: .topLeading)
        }
        .accessibilityLabel("\(profile.creator.name), \(profile.creator.role), \(profile.publishedTitles.count) published titles")
    }

    private func creatorMetricPill(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(HFTypography.caption.weight(.black))
                .foregroundStyle(HFColors.textPrimary)
            Text(detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, HFSpacing.xs)
        .frame(height: 48)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
    }

    private func recommendationRail(_ category: Category) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Text(category.title)
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)
                .padding(.horizontal, HFSpacing.screenHorizontal)

            if let subtitle = category.subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .padding(.horizontal, HFSpacing.screenHorizontal)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    ForEach(category.movies.prefix(8)) { movie in
                        NavigationLink(value: movie) {
                            HFPosterCard(movie: movie, width: 112, showMetadata: false, showProgress: movie.progress != nil)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Open recommended title \(movie.title)")
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
        .accessibilityIdentifier("hf.discovery.engine.\(category.id)")
    }

    private func discoveryIcon(for id: String) -> String {
        switch id {
        case "featured": return "star.fill"
        case "trending": return "chart.line.uptrend.xyaxis"
        case "new-releases": return "sparkles.tv.fill"
        case "highfive-originals": return "hifispeaker.2.fill"
        case "creator-published": return "checkmark.seal.fill"
        case "award-winners": return "rosette"
        case "premieres": return "theatermasks.fill"
        default: return "rectangle.stack.fill"
        }
    }

    private func discoveryAccent(for id: String) -> Color {
        switch id {
        case "creator-published", "new-releases":
            return HFColors.violet
        case "premieres", "trending":
            return HFColors.cyanGlow
        default:
            return HFColors.gold
        }
    }

    private var emptyState: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.cyanGlow.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                Image(systemName: "magnifyingglass.circle.fill")
                    .font(.system(size: 32, weight: .black))
                    .foregroundStyle(HFColors.cyanGlow)
                Text("Search your HighFive library")
                    .font(HFTypography.section)
                    .foregroundStyle(HFColors.textPrimary)
                Text("Try another title, genre, or mood.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                Text("Local catalog")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.cyanGlow)
                    .accessibilityIdentifier("hf.search.localOnly")
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.search.emptyState")
    }

    private var searchInspector: some View {
        NavigationStack {
            HFSpatialInspectorChrome(
                title: "Search Inspector",
                detail: "Discovery stays on the local HighFive catalog. No remote query or provider search is active.",
                systemImage: "magnifyingglass",
                accent: HFColors.cyanGlow
            ) {
                VStack(spacing: HFSpacing.xs) {
                    inspectorRow(title: "Catalog runtime", detail: streamingStore.catalogRuntimeSnapshot.detail, status: streamingStore.catalogRuntimeSnapshot.statusLabel, identifier: "hf.search.localCatalog")
                    inspectorRow(title: "Selected focus", detail: selectedFocus.title, status: "Selected", identifier: "hf.spatial.search.selectedFocus")
                    inspectorRow(title: "Remote search", detail: "No remote catalog search is connected.", status: "Not Connected Yet", identifier: "hf.search.localOnly")
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
        .accessibilityIdentifier("hf.search.inspector")
    }

    private func inspectorRow(title: String, detail: String, status: String, identifier: String) -> some View {
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
                .foregroundStyle(HFColors.cyanGlow)
                .padding(.horizontal, HFSpacing.xs)
                .frame(minHeight: 24)
                .background(HFColors.cyanGlow.opacity(0.12))
                .clipShape(Capsule())
        }
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityIdentifier(identifier)
    }
}
