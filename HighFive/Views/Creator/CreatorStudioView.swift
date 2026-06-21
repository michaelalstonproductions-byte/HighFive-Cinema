import SwiftUI

enum HFCreatorStudioFocus: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case socialMediaKit = "Social Kit"
    case instagramConnect = "Instagram Connect"
    case vodPackage = "VOD Package"

    var id: String { rawValue }
}

enum HFSocialCampaignFocus: String, CaseIterable, Identifiable {
    case poster
    case reel
    case caption
    case story
    case platforms

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .poster: return "Poster"
        case .reel: return "Reel"
        case .caption: return "Caption"
        case .story: return "Story"
        case .platforms: return "Platforms"
        }
    }

    var systemImage: String {
        switch self {
        case .poster: return "photo.fill"
        case .reel: return "film.stack.fill"
        case .caption: return "text.quote"
        case .story: return "rectangle.portrait.fill"
        case .platforms: return "square.grid.2x2.fill"
        }
    }

    var purpose: String {
        switch self {
        case .poster: return "Cinematic key-art crop and title lockup"
        case .reel: return "Local vertical clip placeholder and trailer note"
        case .caption: return "Dominant campaign caption and local alternates"
        case .story: return "Vertical story composition and title callout"
        case .platforms: return "Spatial variants with readiness kept secondary"
        }
    }

    var accessibilityIdentifier: String {
        switch self {
        case .poster: return "hf.spatial.social.poster"
        case .reel: return "hf.spatial.social.reel"
        case .caption: return "hf.spatial.social.caption"
        case .story: return "hf.spatial.social.story"
        case .platforms: return "hf.spatial.social.platforms"
        }
    }
}

enum HFVODReleaseFocus: String, CaseIterable, Identifiable {
    case trailer
    case poster
    case synopsis
    case access
    case release

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .trailer: return "Trailer"
        case .poster: return "Poster"
        case .synopsis: return "Synopsis"
        case .access: return "Access"
        case .release: return "Release"
        }
    }

    var systemImage: String {
        switch self {
        case .trailer: return "film.stack.fill"
        case .poster: return "photo.fill"
        case .synopsis: return "text.alignleft"
        case .access: return "checkmark.shield.fill"
        case .release: return "sparkles.tv.fill"
        }
    }

    var purpose: String {
        switch self {
        case .trailer: return "Local trailer-pull preview and timeline note"
        case .poster: return "Cinematic key art, title lockup, and poster note"
        case .synopsis: return "Short and long copy staged locally"
        case .access: return "Pricing, entitlement, and product mapping boundary"
        case .release: return "Distribution and storefront readiness review"
        }
    }

    var accessibilityIdentifier: String {
        switch self {
        case .trailer: return "hf.spatial.vod.trailer"
        case .poster: return "hf.spatial.vod.poster"
        case .synopsis: return "hf.spatial.vod.synopsis"
        case .access: return "hf.spatial.vod.access"
        case .release: return "hf.spatial.vod.release"
        }
    }

    var routeIdentifier: String {
        switch self {
        case .trailer: return "hf.route.vodTrailer"
        case .poster: return "hf.route.vodPoster"
        case .synopsis: return "hf.route.vodSynopsis"
        case .access: return "hf.route.vodAccess"
        case .release: return "hf.route.vodRelease"
        }
    }
}

private enum HFSpatialCreatorTool: String, CaseIterable, Identifiable {
    case look = "Look"
    case trailer = "Trailer"
    case sound = "Sound"
    case social = "Social"
    case vod = "VOD"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .look: return "paintpalette.fill"
        case .trailer: return "film.stack.fill"
        case .sound: return "waveform"
        case .social: return "bubble.left.and.bubble.right.fill"
        case .vod: return "play.rectangle.on.rectangle.fill"
        }
    }

    var purpose: String {
        switch self {
        case .look: return "Mood, poster direction, and color treatment"
        case .trailer: return "Trailer pull, clip placeholder, and timeline note"
        case .sound: return "Music mood, sound direction, and mix notes"
        case .social: return "Local Social Kit handoff"
        case .vod: return "Local VOD package handoff"
        }
    }

    var accessibilityIdentifier: String {
        switch self {
        case .look: return "hf.spatial.creatorStudio.look"
        case .trailer: return "hf.spatial.creatorStudio.trailer"
        case .sound: return "hf.spatial.creatorStudio.sound"
        case .social: return "hf.spatial.creatorStudio.social"
        case .vod: return "hf.spatial.creatorStudio.vod"
        }
    }
}

private enum HFCreatorProSpotlight {
    case dashboard
    case cms
    case pipeline
    case socialAssets
    case vodPackage
    case analytics

    static var launchSpotlight: HFCreatorProSpotlight {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--hf-start-content-management") { return .cms }
        if arguments.contains("--hf-cms-content-types") { return .cms }
        if arguments.contains("--hf-cms-collections") { return .cms }
        if arguments.contains("--hf-cms-relationships") { return .cms }
        if arguments.contains("--hf-start-creator-publishing") { return .pipeline }
        if arguments.contains("--hf-creator-pro-pipeline") { return .pipeline }
        if arguments.contains("--hf-creator-pro-social-assets") { return .socialAssets }
        if arguments.contains("--hf-creator-pro-vod-package") { return .vodPackage }
        if arguments.contains("--hf-creator-pro-analytics") { return .analytics }
        return .dashboard
    }
}

private enum HFLaunchProSpotlight {
    case dashboard
    case pipeline
    case platforms
    case campaign
    case assets
    case finalGate

    static var launchSpotlight: HFLaunchProSpotlight {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--hf-launch-pro-pipeline") { return .pipeline }
        if arguments.contains("--hf-launch-pro-platforms") { return .platforms }
        if arguments.contains("--hf-launch-pro-campaign") { return .campaign }
        if arguments.contains("--hf-launch-pro-assets") { return .assets }
        if arguments.contains("--hf-launch-pro-final-gate") { return .finalGate }
        return .dashboard
    }
}

struct CreatorStudioView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject private var streamingStore: HFStreamingStore
    @State private var selectedFocus: HFCreatorStudioFocus
    @State private var selectedTool: HFSpatialCreatorTool
    @State private var selectedSocialFocus: HFSocialCampaignFocus
    @State private var selectedVODFocus: HFVODReleaseFocus
    @State private var didSaveLocalDraft = false
    @State private var didSaveSocialCampaign = false
    @State private var didSaveVODPackage = false
    @State private var isWorktableAwake = false
    @State private var isInspectorPresented = false
    @State private var isSocialInspectorPresented = false
    @State private var isVODInspectorPresented = false
    private let proSpotlight: HFCreatorProSpotlight
    private let launchProSpotlight: HFLaunchProSpotlight

    init(
        initialFocus: HFCreatorStudioFocus = .dashboard,
        initialSocialFocus: HFSocialCampaignFocus = .poster,
        initialVODFocus: HFVODReleaseFocus = .trailer
    ) {
        _selectedFocus = State(initialValue: initialFocus)
        _selectedTool = State(initialValue: Self.tool(for: initialFocus))
        _selectedSocialFocus = State(initialValue: initialSocialFocus)
        _selectedVODFocus = State(initialValue: initialVODFocus)
        proSpotlight = HFCreatorProSpotlight.launchSpotlight
        launchProSpotlight = HFLaunchProSpotlight.launchSpotlight
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                if selectedFocus == .socialMediaKit {
                    socialCampaignAuthoringWorld
                } else if selectedFocus == .vodPackage {
                    launchProSurface
                    vodLaunchChamber
                } else {
                    creatorStudioProHero
                    spatialWorktable
                    creatorStudioActions
                    creatorStudioProSurface
                    selectedToolHandoff
                }
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance + HFSpacing.tabBarHeight)
        }
        .safeAreaInset(edge: .top) {
            Color.clear
                .frame(height: 4)
                .accessibilityIdentifier("hf.safeArea.topProtected")
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear
                .frame(height: 4)
                .accessibilityIdentifier("hf.safeArea.bottomProtected")
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isInspectorPresented) {
            creatorInspector
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isSocialInspectorPresented) {
            socialCampaignInspector
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isVODInspectorPresented) {
            vodReleaseInspector
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            guard !reduceMotion else {
                isWorktableAwake = true
                return
            }
            withAnimation(HFSpatialMotionTokens.sceneEntranceAnimation) {
                isWorktableAwake = true
            }
        }
        .accessibilityIdentifier("hf.creatorStudio.screen")
        .accessibilityIdentifier("hf.spatial.creatorStudio")
    }

    private var navigationTitle: String {
        switch selectedFocus {
        case .socialMediaKit: return "Social Media Kit"
        case .vodPackage: return "VOD Package"
        case .dashboard, .instagramConnect: return "Creator Studio"
        }
    }

    private var usesSpatialFallbackLayout: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    private static func tool(for focus: HFCreatorStudioFocus) -> HFSpatialCreatorTool {
        switch focus {
        case .dashboard: return .look
        case .socialMediaKit, .instagramConnect: return .social
        case .vodPackage: return .vod
        }
    }

    private var spatialWorktable: some View {
        Group {
            if usesSpatialFallbackLayout {
                VStack(spacing: HFSpacing.md) {
                    ZStack {
                        opticalBlackWorkSurface
                        spatialProjectSlab
                    }
                    .frame(height: 318)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: HFSpacing.sm) {
                            ForEach(HFSpatialCreatorTool.allCases) { tool in
                                spatialToolNode(for: tool, usesOrbitOffset: false)
                            }
                        }
                        .padding(.horizontal, HFSpacing.sm)
                    }
                    .accessibilityIdentifier("hf.spatial.accessibility.fallbackLayout")
                }
            } else {
                ZStack {
                    opticalBlackWorkSurface

                    HFDepthContourOverlay(color: HFColors.violet.opacity(0.72))
                        .opacity(0.34)
                        .blur(radius: min(0.3, HFSpatialMotionTokens.maximumDecorativeBlur))
                        .padding(.horizontal, -42)
                        .accessibilityHidden(true)

                    spatialProjectSlab

                    ForEach(HFSpatialCreatorTool.allCases) { tool in
                        spatialToolNode(for: tool)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: usesSpatialFallbackLayout ? 530 : 560)
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .hfSpatialSceneEntrance(isActive: isWorktableAwake, reduceMotion: reduceMotion)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Creator Studio spatial worktable with project slab and five tools")
        .accessibilityIdentifier("hf.spatial.accessibility.largeType")
        .accessibilityIdentifier("hf.spatial.creatorStudio.worktable")
    }

    private var opticalBlackWorkSurface: some View {
        RoundedRectangle(cornerRadius: HFSpacing.panelRadius + 10, style: .continuous)
            .fill(
                RadialGradient(
                    colors: [
                        HFColors.violet.opacity(0.24),
                (reduceTransparency ? Color.black : HFColors.background.opacity(0.98)),
                Color.black
                    ],
                    center: .center,
                    startRadius: 40,
                    endRadius: 430
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.panelRadius + 10, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                HFColors.gold.opacity(0.38),
                                HFColors.violet.opacity(0.34),
                                Color.white.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: HFColors.violet.opacity(0.24), radius: 34, x: 0, y: 16)
            .accessibilityHidden(true)
    }

    private var spatialProjectSlab: some View {
        let movie = streamingStore.featuredMovie
        let slabLift: CGFloat = isWorktableAwake && !reduceMotion ? -8 : 0

        return VStack(spacing: HFSpacing.sm) {
            ZStack(alignment: .bottomLeading) {
                projectArtwork(for: movie)
                    .frame(width: 214, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous)
                            .stroke(HFColors.gold.opacity(0.66), lineWidth: 1.2)
                    )
                    .shadow(color: HFColors.gold.opacity(0.32), radius: 24, x: 0, y: 18)
                    .shadow(color: HFColors.violet.opacity(0.32), radius: 32, x: 0, y: -8)

                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.86)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HFCreatorStudioPill(title: didSaveLocalDraft ? "Local Draft Saved" : "Local Draft", isActive: true)
                        .accessibilityIdentifier("hf.creatorStudio.localDraft")

                    Text(movie.title)
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.74)
                        .accessibilityIdentifier("hf.spatial.creatorStudio.projectTitle")

                    Text("Creative worktable")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                }
                .padding(HFSpacing.md)
            }
            .accessibilityIdentifier("hf.spatial.creatorStudio.project")

            HStack(spacing: HFSpacing.xs) {
                HFCreatorStudioPill(title: "Provider-ready")
                    .accessibilityIdentifier("hf.creatorStudio.providerReady")
                HFCreatorStudioPill(title: "Not Connected Yet")
                    .accessibilityIdentifier("hf.creatorStudio.notConnected")
            }
        }
        .offset(y: slabLift)
        .scaleEffect(isWorktableAwake ? 1 : 0.96)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(movie.title) project slab. Local Draft. Selected tool \(selectedTool.rawValue).")
        .hfSpatialFocalHandoff(
            "hf.spatial.handoff.movieToCreator",
            "hf.spatial.handoff.creatorToSocial",
            "hf.spatial.handoff.creatorToVOD"
        )
    }

    @ViewBuilder
    private func projectArtwork(for movie: Movie) -> some View {
        if let assetName = movie.backdropAssetName ?? movie.posterAssetName,
           HFPosterAssetHealth.hasImage(named: assetName) {
            Image(assetName)
                .resizable()
                .scaledToFill()
        } else {
            HFPosterFallback(title: movie.title)
        }
    }

    private func spatialToolNode(for tool: HFSpatialCreatorTool, usesOrbitOffset: Bool = true) -> some View {
        let isSelected = selectedTool == tool
        let base = orbitOffset(for: tool)
        let lift: CGFloat = isWorktableAwake && !reduceMotion ? 1 : 0
        let selectedPull = isSelected ? selectedOffset(for: tool) : .zero
        let orbitOffset = CGSize(
            width: base.width + selectedPull.width * lift,
            height: base.height + selectedPull.height * lift
        )
        let offset = usesOrbitOffset ? orbitOffset : .zero

        return Button(action: {
            select(tool)
        }) {
            spatialToolNodeLabel(for: tool, isSelected: isSelected)
        }
        .buttonStyle(.plain)
        .frame(minWidth: 72, minHeight: 72)
        .offset(offset)
        .hfSpatialSelectionTreatment(
            isSelected: isSelected,
            accent: HFColors.violet,
            reduceMotion: reduceMotion,
            differentiateWithoutColor: differentiateWithoutColor
        )
        .animation(reduceMotion ? nil : HFSpatialMotionTokens.focusAnimation, value: selectedTool)
        .accessibilityLabel("\(tool.rawValue) tool")
        .accessibilityValue(isSelected ? "Selected" : "Available")
        .accessibilityHint(tool == .social ? "Opens the local Social Media Kit handoff." : tool == .vod ? "Opens the local VOD Package handoff." : tool.purpose)
        .accessibilityIdentifier(tool.accessibilityIdentifier)
    }

    private func spatialToolNodeLabel(for tool: HFSpatialCreatorTool, isSelected: Bool) -> some View {
        VStack(spacing: HFSpacing.xs) {
            ZStack {
                Circle()
                    .fill(isSelected ? AnyShapeStyle(HFColors.violet.opacity(0.88)) : AnyShapeStyle(Color.white.opacity(0.075)))
                Image(systemName: tool.systemImage)
                    .font(.system(size: 19, weight: .black))
                    .foregroundStyle(isSelected ? HFColors.gold : HFColors.textPrimary)
            }
            .frame(width: 46, height: 46)

            Text(tool.rawValue)
                .font(HFTypography.smallAction)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Text(tool.purpose)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            if isSelected || differentiateWithoutColor {
                Label(isSelected ? "Selected" : "Available", systemImage: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(HFTypography.micro)
                    .foregroundStyle(isSelected ? HFColors.gold : HFColors.textMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
            }
        }
        .frame(width: 104)
        .frame(minHeight: 100)
        .padding(HFSpacing.xs)
        .background(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .fill(isSelected ? HFColors.violet.opacity(0.26) : Color.black.opacity(0.34))
        )
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(isSelected ? HFColors.gold.opacity(0.58) : HFColors.glassStroke, lineWidth: 1)
        )
        .shadow(color: isSelected ? HFColors.violet.opacity(0.38) : Color.clear, radius: 18, x: 0, y: 8)
    }

    private func orbitOffset(for tool: HFSpatialCreatorTool) -> CGSize {
        switch tool {
        case .look: return CGSize(width: -112, height: -188)
        case .trailer: return CGSize(width: 112, height: -188)
        case .sound: return CGSize(width: -126, height: -2)
        case .social: return CGSize(width: 126, height: -2)
        case .vod: return CGSize(width: 0, height: 194)
        }
    }

    private func selectedOffset(for tool: HFSpatialCreatorTool) -> CGSize {
        switch tool {
        case .look: return CGSize(width: 8, height: 18)
        case .trailer: return CGSize(width: -8, height: 18)
        case .sound: return CGSize(width: 20, height: -2)
        case .social: return CGSize(width: -20, height: -2)
        case .vod: return CGSize(width: 0, height: -22)
        }
    }

    private func select(_ tool: HFSpatialCreatorTool) {
        withAnimation(reduceMotion ? nil : HFSpatialMotionTokens.focusAnimation) {
            selectedTool = tool
            switch tool {
            case .social:
                selectedFocus = .socialMediaKit
            case .vod:
                selectedFocus = .vodPackage
            case .look, .trailer, .sound:
                selectedFocus = .dashboard
            }
        }
    }

    private var creatorStudioActions: some View {
        HFSpatialActionCluster {
            HFEnergyAction(title: "Build the Release", systemImage: "checkmark.seal.fill", style: .gold) {
                didSaveLocalDraft = true
                select(.vod)
            }
            .accessibilityLabel("Build the Release as a local draft")
            .accessibilityIdentifier("hf.spatial.creatorStudio.buildRelease")

            HStack(spacing: HFSpacing.sm) {
                Button {
                    didSaveLocalDraft = true
                } label: {
                    HFCreatorStudioAction(title: didSaveLocalDraft ? "Local Draft Saved" : "Save Local Draft", systemImage: "square.and.arrow.down")
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.spatial.creatorStudio.saveDraft")
                .accessibilityIdentifier("hf.creatorStudio.localDraft")

                Button {
                    isInspectorPresented = true
                } label: {
                    HFCreatorStudioAction(title: "Open Inspector", systemImage: "slider.horizontal.3")
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.spatial.creatorStudio.inspector")
                .accessibilityIdentifier("hf.creatorStudio.inspector")
            }

            Button {
                dismiss()
            } label: {
                HFCreatorStudioAction(title: "Back to Streaming", systemImage: "play.tv.fill")
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("hf.spatial.creatorStudio.backToStreaming")
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    @ViewBuilder
    private var selectedToolHandoff: some View {
        switch selectedTool {
        case .social:
            socialCampaignAuthoringWorld
        case .vod:
            vodLaunchChamber
        case .look:
            creativeToolSummary(title: "Look", detail: "Poster direction, color treatment, and mood notes are staged around the project slab.", systemImage: "paintpalette.fill")
        case .trailer:
            creativeToolSummary(title: "Trailer", detail: "Trailer pull and clip placeholders stay local for editorial review.", systemImage: "film.stack.fill")
        case .sound:
            creativeToolSummary(title: "Sound", detail: "Music mood, sonic direction, and mix notes remain local notes.", systemImage: "waveform")
        }
    }

    private func creativeToolSummary(title: String, detail: String, systemImage: String) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.24)) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 44, height: 44)
                    .background(HFColors.violet.opacity(0.22))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text(title)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    Text(detail)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(HFSpacing.md)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) tool. \(detail)")
    }

    private var socialCampaignAuthoringWorld: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius + 10, strokeColor: HFColors.violet.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFSpatialRouteBadge(title: "Creator -> Social", accent: HFColors.violet)

                        Text("Social Media Kit")
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.gold)
                            .textCase(.uppercase)
                            .tracking(1.2)

                        Text(streamingStore.featuredMovie.title)
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.74)
                            .accessibilityIdentifier("hf.spatial.social.projectTitle")

                        Text("\(selectedSocialFocus.displayName) campaign format")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .accessibilityIdentifier("hf.spatial.social.selectedFormat")
                    }

                    Spacer(minLength: HFSpacing.sm)

                    Button {
                        select(.look)
                    } label: {
                        Label("Back to Creator Studio", systemImage: "chevron.left")
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.70)
                            .padding(.horizontal, HFSpacing.xs)
                            .frame(height: 34)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.spatial.social.backToStudio")
                    .accessibilityIdentifier("hf.route.socialToCreatorStudio")
                }

                ZStack {
                    socialOpticalBlackSurface
                    socialCampaignPreview
                    if usesSpatialFallbackLayout {
                        VStack {
                            Spacer()
                            socialFocusFallbackRow
                        }
                        .padding(.bottom, HFSpacing.sm)
                    } else {
                        ForEach(HFSocialCampaignFocus.allCases) { focus in
                            socialCreativeObject(focus)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: usesSpatialFallbackLayout ? 420 : 430)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Campaign preview first. Selected format \(selectedSocialFocus.displayName). Five local creative formats.")
                .accessibilityIdentifier("hf.spatial.accessibility.fallbackLayout")
                .accessibilityIdentifier("hf.spatial.social.world")

                HFSpatialActionCluster {
                    HFEnergyAction(title: "Review Campaign", systemImage: "checkmark.seal.fill", style: .gold) {
                        didSaveSocialCampaign = true
                        didSaveLocalDraft = true
                    }
                    .accessibilityIdentifier("hf.spatial.social.reviewCampaign")
                    .accessibilityIdentifier("hf.creatorStudio.prepareSocialKit")
                    .accessibilityIdentifier("hf.route.creatorStudioToSocial")

                    HStack(spacing: HFSpacing.sm) {
                        HFEnergyAction(title: didSaveSocialCampaign ? "Campaign Saved" : "Save Local Campaign", systemImage: "square.and.arrow.down", style: .glass) {
                            didSaveSocialCampaign = true
                            didSaveLocalDraft = true
                        }
                        .accessibilityIdentifier("hf.spatial.social.saveDraft")

                        HFEnergyAction(title: "Open Inspector", systemImage: "slider.horizontal.3", style: .glass) {
                            isSocialInspectorPresented = true
                        }
                        .accessibilityIdentifier("hf.spatial.social.inspector")
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.spatial.social")
        .hfSpatialFocalHandoff("hf.spatial.handoff.creatorToSocial")
    }

    private var socialOpticalBlackSurface: some View {
        RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous)
            .fill(
                RadialGradient(
                    colors: [
                        HFColors.violet.opacity(0.28),
                        reduceTransparency ? Color.black : HFColors.background.opacity(0.98),
                        Color.black
                    ],
                    center: .center,
                    startRadius: 30,
                    endRadius: 390
                )
            )
            .overlay(
                HFDepthContourOverlay(color: HFColors.violet.opacity(0.78), lineWidth: 0.8)
                    .opacity(0.34)
                    .padding(.horizontal, -30)
            )
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous))
            .accessibilityHidden(true)
    }

    private var socialFocusFallbackRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HFSpacing.sm) {
                ForEach(HFSocialCampaignFocus.allCases) { focus in
                    socialCreativeObject(focus, usesSpatialOffset: false)
                }
            }
            .padding(.horizontal, HFSpacing.sm)
        }
        .accessibilityIdentifier("hf.spatial.accessibility.largeType")
    }

    private var socialCampaignPreview: some View {
        ZStack(alignment: .bottomLeading) {
            projectArtwork(for: streamingStore.featuredMovie)
                .frame(width: 214, height: 316)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .overlay(
                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.28), Color.black.opacity(0.92)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(HFColors.gold.opacity(0.64), lineWidth: 1.2)
                )
                .shadow(color: HFColors.violet.opacity(reduceMotion ? 0 : 0.35), radius: reduceMotion ? 0 : 30, x: 0, y: 18)

            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Text(selectedSocialFocus.displayName)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.violet.opacity(0.95))
                    .textCase(.uppercase)
                    .tracking(1.1)

                Text(streamingStore.featuredMovie.title)
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.68)

                socialPreviewContent
            }
            .frame(maxWidth: 182, alignment: .leading)
            .padding(HFSpacing.md)
            .padding(.bottom, selectedSocialFocus == .platforms ? 58 : 0)
        }
        .scaleEffect(reduceMotion ? 1 : 1.02)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Dominant vertical campaign preview. \(selectedSocialFocus.displayName). \(selectedSocialFocus.purpose).")
        .accessibilityIdentifier("hf.spatial.social.preview")
    }

    @ViewBuilder
    private var socialPreviewContent: some View {
        Group {
            switch selectedSocialFocus {
            case .poster:
                Text("Key-art crop. Title lockup. Local composition note.")
                    .accessibilityIdentifier("hf.social.posterPreview")
            case .reel:
                Text("Vertical clip placeholder. 00:18 local trailer note.")
                    .accessibilityIdentifier("hf.social.reelPreview")
            case .caption:
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tonight on HighFive: choose the scene you would replay first.")
                        .accessibilityIdentifier("hf.social.captionPreview")
                    Text("2 alternate local drafts")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textMuted)
                        .accessibilityIdentifier("hf.social.captionDrafts")
                }
            case .story:
                Text("Vertical story composition. Premiere callout. Local-only preview.")
                    .accessibilityIdentifier("hf.social.storyPreview")
            case .platforms:
                Text("Campaign variants staged locally. Readiness stays in the inspector.")
                    .accessibilityIdentifier("hf.social.platformPreview")
            }
        }
        .font(HFTypography.caption)
        .foregroundStyle(HFColors.textPrimary)
        .lineLimit(3)
        .minimumScaleFactor(0.74)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func socialCreativeObject(_ focus: HFSocialCampaignFocus, usesSpatialOffset: Bool = true) -> some View {
        let isSelected = selectedSocialFocus == focus
        let offset = usesSpatialOffset ? socialFocusOffset(focus, isSelected: isSelected) : .zero

        return Button {
            withAnimation(reduceMotion ? nil : HFSpatialMotionTokens.focusAnimation) {
                selectedSocialFocus = focus
            }
        } label: {
            VStack(spacing: HFSpacing.xxs) {
                Image(systemName: focus.systemImage)
                    .font(.system(size: isSelected ? 20 : 17, weight: .black))
                    .foregroundStyle(isSelected ? .black : HFColors.textPrimary)
                    .frame(width: isSelected ? 54 : 46, height: isSelected ? 54 : 46)
                    .background(isSelected ? AnyShapeStyle(LinearGradient(colors: [HFColors.violet, HFColors.gold.opacity(0.88)], startPoint: .topLeading, endPoint: .bottomTrailing)) : AnyShapeStyle(Color.white.opacity(0.08)))
                    .clipShape(Circle())

                Text(focus.displayName)
                    .font(HFTypography.micro)
                    .foregroundStyle(isSelected ? HFColors.gold : HFColors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                if isSelected || differentiateWithoutColor {
                    Label(isSelected ? "Selected" : "Available", systemImage: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(HFTypography.micro)
                        .foregroundStyle(isSelected ? HFColors.gold : HFColors.textMuted)
                        .lineLimit(1)
                        .minimumScaleFactor(0.66)
                }
            }
            .frame(width: 88, height: 88)
            .background(isSelected ? HFColors.violet.opacity(0.18) : Color.black.opacity(0.22))
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                    .stroke(isSelected ? HFColors.violet.opacity(0.62) : HFColors.glassStroke, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .offset(offset)
        .hfSpatialSelectionTreatment(
            isSelected: isSelected,
            accent: HFColors.violet,
            reduceMotion: reduceMotion,
            differentiateWithoutColor: differentiateWithoutColor
        )
        .accessibilityLabel("\(focus.displayName), \(isSelected ? "selected" : "not selected"). \(focus.purpose)")
        .accessibilityIdentifier(focus.accessibilityIdentifier)
    }

    private func socialFocusOffset(_ focus: HFSocialCampaignFocus, isSelected: Bool) -> CGSize {
        let selectedLift: CGFloat = isSelected && !reduceMotion ? -10 : 0
        switch focus {
        case .poster: return CGSize(width: -118, height: -154 + selectedLift)
        case .reel: return CGSize(width: 118, height: -154 + selectedLift)
        case .caption: return CGSize(width: -128, height: 4 + selectedLift)
        case .story: return CGSize(width: 128, height: 4 + selectedLift)
        case .platforms: return CGSize(width: 0, height: 162 + selectedLift)
        }
    }

    private var socialCampaignInspector: some View {
        HFSpatialInspectorChrome(
            title: "Campaign Inspector",
            detail: "Local Draft, provider readiness, and platform boundaries stay secondary to the campaign preview.",
            accent: HFColors.violet
        ) {
            VStack(spacing: HFSpacing.xs) {
                HFCreatorStudioReadinessRow(title: "Local Draft", detail: didSaveSocialCampaign ? "Campaign saved locally for review." : "Campaign remains editable locally.", status: "Local", systemImage: "pencil", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.social.localDraft")
                HFCreatorStudioReadinessRow(title: "Provider-ready", detail: "Campaign fields are staged without provider behavior.", status: "Ready", systemImage: "checkmark.seal.fill", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.social.providerReady")
                HFCreatorStudioReadinessRow(title: "Not Connected Yet", detail: "No provider account is connected for this local campaign.", status: "Boundary", systemImage: "network.slash", accent: HFColors.violet)
                    .accessibilityIdentifier("hf.social.notConnected")
                HFCreatorStudioReadinessRow(title: "Caption drafts", detail: "\(captionDraftCards.count) local caption drafts remain available.", status: "Local", systemImage: "text.quote", accent: HFColors.violet)
                HFCreatorStudioReadinessRow(title: "Poster placeholder", detail: "Key-art crop remains a local composition preview.", status: "Local", systemImage: "photo.fill", accent: HFColors.violet)
                HFCreatorStudioReadinessRow(title: "Reel placeholder", detail: "Vertical moving-image placeholder remains local.", status: "Local", systemImage: "film.fill", accent: HFColors.violet)
                HFCreatorStudioReadinessRow(title: "Story placeholder", detail: "Story composition remains local-only.", status: "Local", systemImage: "rectangle.portrait.fill", accent: HFColors.violet)
                HFCreatorStudioReadinessRow(title: "Instagram readiness", detail: "Poster and caption planning only.", status: "Provider-ready", systemImage: "camera.viewfinder", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.social.instagramReadiness")
                HFCreatorStudioReadinessRow(title: "TikTok readiness", detail: "Reel placeholder and caption planning only.", status: "Provider-ready", systemImage: "music.note", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.social.tiktokReadiness")
                HFCreatorStudioReadinessRow(title: "YouTube Shorts readiness", detail: "Short-form preview planning only.", status: "Provider-ready", systemImage: "play.rectangle.fill", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.social.youtubeShortsReadiness")
                HFCreatorStudioReadinessRow(title: "X / Threads readiness", detail: "Prompt and copy planning only.", status: "Provider-ready", systemImage: "text.bubble.fill", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.social.threadsReadiness")
                HFCreatorStudioReadinessRow(title: "No live publishing", detail: "No posting, scheduling, upload, or platform action is active.", status: "Safe", systemImage: "lock.shield.fill", accent: HFColors.violet)
                    .accessibilityIdentifier("hf.social.noLivePublishing")
                HFCreatorStudioReadinessRow(title: "No provider account connected", detail: "Campaign authoring remains local and provider-free.", status: "Safe", systemImage: "person.crop.circle.badge.xmark", accent: HFColors.violet)
                    .accessibilityIdentifier("hf.social.noProviderConnection")
                HFCreatorStudioReadinessRow(title: "Campaign remains local", detail: "No export, file picker, upload, or media write is active.", status: "Local", systemImage: "lock.fill", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.social.campaignLocalOnly")
            }
        }
        .accessibilityIdentifier("hf.social.inspector")
    }

    private var launchProSurface: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius + 10, strokeColor: HFColors.gold.opacity(0.44)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                launchProHero
                launchProSpotlightPanel

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 158), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    launchCommandDashboard
                    releaseReadinessMatrix
                    distributionPipeline
                    platformTargetsPreview
                    campaignTimeline
                    premiereSchedulingPreview
                    marketingAssetsBoard
                    trailerPosterSynopsisChecklist
                    vodPackageReview
                    pricingPreview
                    territoryPreview
                    rightsClearancePreview
                    analyticsForecastPreview
                    creatorRevenuePreview
                    launchControlRoom
                    finalReviewGate
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Launch and Distribution Center Pro. Local release review for \(streamingStore.featuredMovie.title).")
    }

    private var launchProHero: some View {
        HStack(alignment: .top, spacing: HFSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                    .fill(HFColors.goldGradient)
                Image(systemName: "sparkles.tv.fill")
                    .font(.system(size: 30, weight: .black))
                    .foregroundStyle(.black)
            }
            .frame(width: 76, height: 76)

            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Text("Launch & Distribution Center Pro")
                    .font(HFTypography.section)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)

                Text("Studio release command surface for local review, draft readiness, mock platform targets, and final gate planning.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: HFSpacing.xs) {
                    HFCreatorStudioPill(title: "Draft", isActive: true)
                    HFCreatorStudioPill(title: "Visual only")
                    HFCreatorStudioPill(title: "Not released")
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Launch and Distribution Center Pro. Draft, visual only, not released.")
    }

    @ViewBuilder
    private var launchProSpotlightPanel: some View {
        switch launchProSpotlight {
        case .dashboard:
            launchProSpotlight(
                title: "Launch Command Dashboard",
                detail: "Release state, target boards, and final review stay organized as local preview signals.",
                systemImage: "rectangle.grid.2x2.fill",
                accent: HFColors.gold,
                identifier: "hf.launch.pro.dashboard"
            ) {
                HStack(spacing: HFSpacing.xs) {
                    launchProStat(title: "Release", value: "Draft")
                    launchProStat(title: "Targets", value: "Mock")
                    launchProStat(title: "Gate", value: "Review")
                }
            }
        case .pipeline:
            launchProSpotlight(
                title: "Distribution Pipeline",
                detail: "Trailer, artwork, copy, pricing note, territories, and rights checks are staged visually.",
                systemImage: "point.3.connected.trianglepath.dotted",
                accent: HFColors.cyanGlow,
                identifier: "hf.launch.pro.distributionPipeline"
            ) {
                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    launchProCapsule("Package", active: true, accent: HFColors.gold)
                    launchProCapsule("Targets", active: true, accent: HFColors.cyanGlow)
                    launchProCapsule("Final gate", active: false, accent: HFColors.violet)
                }
            }
        case .platforms:
            platformTargetsPreview
        case .campaign:
            campaignTimeline
        case .assets:
            marketingAssetsBoard
        case .finalGate:
            finalReviewGate
        }
    }

    private var launchCommandDashboard: some View {
        launchProModule(
            title: "Launch Command",
            detail: "Release readiness, target boards, and local final review.",
            systemImage: "rectangle.grid.2x2.fill",
            accent: HFColors.gold,
            identifier: "hf.launch.pro.dashboard"
        ) {
            HStack(spacing: HFSpacing.xs) {
                launchProStat(title: "Mode", value: "Draft")
                launchProStat(title: "Review", value: "Local")
            }
        }
    }

    private var releaseReadinessMatrix: some View {
        launchProModule(
            title: "Readiness Matrix",
            detail: "Local checks only.",
            systemImage: "checklist.checked",
            accent: HFColors.gold,
            identifier: "hf.launch.pro.readinessMatrix"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                launchProCapsule("Trailer", active: true, accent: HFColors.gold)
                launchProCapsule("Poster", active: true, accent: HFColors.gold)
                launchProCapsule("Synopsis", active: true, accent: HFColors.gold)
            }
        }
    }

    private var distributionPipeline: some View {
        launchProModule(
            title: "Distribution Pipeline",
            detail: "Package, target preview, campaign board, and review gate stay local.",
            systemImage: "arrow.triangle.branch",
            accent: HFColors.cyanGlow,
            identifier: "hf.launch.pro.distributionPipeline"
        ) {
            HStack(spacing: 6) {
                launchProStep("01")
                launchProStep("02")
                launchProStep("03")
                launchProStep("04", muted: true)
            }
        }
    }

    private var platformTargetsPreview: some View {
        launchProModule(
            title: "Platform Targets",
            detail: "Mock target cards keep storefront, VOD, premiere, and campaign visual.",
            systemImage: "square.grid.2x2.fill",
            accent: HFColors.cyanGlow,
            identifier: "hf.launch.pro.platformTargets"
        ) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                launchProMiniTarget("VOD")
                launchProMiniTarget("Store")
                launchProMiniTarget("Premiere")
                launchProMiniTarget("Social")
            }
        }
    }

    private var campaignTimeline: some View {
        launchProModule(
            title: "Campaign Timeline",
            detail: "Key art, trailer tease, premiere reminder, and release review beats remain planned locally.",
            systemImage: "timeline.selection",
            accent: HFColors.violet,
            identifier: "hf.launch.pro.campaignTimeline"
        ) {
            VStack(alignment: .leading, spacing: 4) {
                launchTimelineRow("Key art", "Planned")
                launchTimelineRow("Trailer tease", "Draft")
                launchTimelineRow("Review gate", "Local")
            }
        }
    }

    private var premiereSchedulingPreview: some View {
        launchProModule(
            title: "Premiere Scheduling Preview",
            detail: "A visual premiere window keeps date planning separate from external date systems.",
            systemImage: "clock.badge.checkmark.fill",
            accent: HFColors.gold,
            identifier: "hf.launch.pro.premiereScheduling"
        ) {
            HStack(spacing: HFSpacing.xs) {
                launchProStat(title: "Window", value: "Fri")
                launchProStat(title: "State", value: "Planned")
            }
        }
    }

    private var marketingAssetsBoard: some View {
        launchProModule(
            title: "Marketing Assets Board",
            detail: "Poster crop, trailer card, synopsis copy, and campaign note are grouped for local review.",
            systemImage: "photo.on.rectangle.angled",
            accent: HFColors.violet,
            identifier: "hf.launch.pro.marketingAssets"
        ) {
            HStack(spacing: 6) {
                launchAssetTile("Poster", accent: HFColors.gold)
                launchAssetTile("Trailer", accent: HFColors.cyanGlow)
                launchAssetTile("Copy", accent: HFColors.violet)
            }
        }
    }

    private var trailerPosterSynopsisChecklist: some View {
        launchProModule(
            title: "Trailer / Poster / Synopsis Checklist",
            detail: "Three core release assets stay staged as review-ready visual checks.",
            systemImage: "checkmark.rectangle.stack.fill",
            accent: HFColors.gold,
            identifier: "hf.launch.pro.assetChecklist"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                launchCheckRow("Trailer frame")
                launchCheckRow("Poster lockup")
                launchCheckRow("Synopsis copy")
            }
        }
    }

    private var vodPackageReview: some View {
        launchProModule(
            title: "VOD Package Review",
            detail: "Trailer, poster, synopsis, access note, and release focus remain tied to the VOD chamber.",
            systemImage: "play.rectangle.on.rectangle.fill",
            accent: HFColors.gold,
            identifier: "hf.launch.pro.vodReview"
        ) {
            Button {
                selectedVODFocus = .release
            } label: {
                HFCreatorStudioAction(title: "Review VOD", systemImage: "play.rectangle.on.rectangle.fill")
            }
            .buttonStyle(.plain)
        }
    }

    private var pricingPreview: some View {
        launchProModule(
            title: "Pricing Preview",
            detail: "Visual pricing tiers remain draft notes without commerce behavior.",
            systemImage: "tag.fill",
            accent: HFColors.gold,
            identifier: "hf.launch.pro.pricingPreview"
        ) {
            HStack(spacing: HFSpacing.xs) {
                launchProStat(title: "Rent", value: "$4.99")
                launchProStat(title: "Own", value: "$14")
            }
        }
    }

    private var territoryPreview: some View {
        launchProModule(
            title: "Territory Preview",
            detail: "Market regions are visual planning chips for local review.",
            systemImage: "globe.americas.fill",
            accent: HFColors.cyanGlow,
            identifier: "hf.launch.pro.territoryPreview"
        ) {
            HStack(spacing: HFSpacing.xs) {
                launchProCapsule("US", active: true, accent: HFColors.cyanGlow)
                launchProCapsule("CA", active: true, accent: HFColors.cyanGlow)
                launchProCapsule("UK", active: false, accent: HFColors.cyanGlow)
            }
        }
    }

    private var rightsClearancePreview: some View {
        launchProModule(
            title: "Rights & Clearance Preview",
            detail: "Clearance checkpoints are read-only visual review notes.",
            systemImage: "doc.badge.gearshape.fill",
            accent: HFColors.violet,
            identifier: "hf.launch.pro.rightsClearance"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                launchCheckRow("Music note")
                launchCheckRow("Artwork note")
                launchCheckRow("Talent note")
            }
        }
    }

    private var analyticsForecastPreview: some View {
        launchProModule(
            title: "Analytics Forecast Preview",
            detail: "Local forecast cards show interest, saves, and room energy as mock planning signals.",
            systemImage: "chart.line.uptrend.xyaxis",
            accent: HFColors.cyanGlow,
            identifier: "hf.launch.pro.analyticsForecast"
        ) {
            HStack(spacing: HFSpacing.xs) {
                launchProStat(title: "Saves", value: "\(max(18, streamingStore.savedMovieIDs.count * 8))")
                launchProStat(title: "Energy", value: "High")
            }
        }
    }

    private var creatorRevenuePreview: some View {
        launchProModule(
            title: "Creator Revenue Preview",
            detail: "Visual revenue cards stay planning-only and do not activate commerce flows.",
            systemImage: "dollarsign.circle.fill",
            accent: HFColors.gold,
            identifier: "hf.launch.pro.creatorRevenue"
        ) {
            HStack(spacing: HFSpacing.xs) {
                launchProStat(title: "Gross", value: "Mock")
                launchProStat(title: "Share", value: "Plan")
            }
        }
    }

    private var launchControlRoom: some View {
        launchProModule(
            title: "Launch Control Room",
            detail: "Final checks, room handoff, VOD review, and campaign readiness are collected in one board.",
            systemImage: "slider.horizontal.3",
            accent: HFColors.gold,
            identifier: "hf.launch.pro.controlRoom"
        ) {
            HStack(spacing: HFSpacing.xs) {
                launchProCapsule("Room", active: true, accent: HFColors.cyanGlow)
                launchProCapsule("VOD", active: true, accent: HFColors.gold)
                launchProCapsule("Campaign", active: true, accent: HFColors.violet)
            }
        }
    }

    private var finalReviewGate: some View {
        launchProModule(
            title: "Final Review Gate",
            detail: "A locked local gate confirms draft readiness before any future release workflow.",
            systemImage: "lock.shield.fill",
            accent: HFColors.gold,
            identifier: "hf.launch.pro.finalReviewGate"
        ) {
            HStack(spacing: HFSpacing.xs) {
                launchProCapsule("Visual only", active: true, accent: HFColors.gold)
                launchProCapsule("Not released", active: false, accent: HFColors.violet)
            }
        }
    }

    private func launchProSpotlight<Content: View>(
        title: String,
        detail: String,
        systemImage: String,
        accent: Color,
        identifier: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        launchProModule(
            title: title,
            detail: detail,
            systemImage: systemImage,
            accent: accent,
            identifier: identifier,
            content: content
        )
        .background(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .fill(accent.opacity(0.06))
        )
    }

    private func launchProModule<Content: View>(
        title: String,
        detail: String,
        systemImage: String,
        accent: Color,
        identifier: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack(alignment: .top, spacing: HFSpacing.sm) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(accent == HFColors.gold ? .black : accent)
                    .frame(width: 42, height: 42)
                    .background(accent == HFColors.gold ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(accent.opacity(0.16)))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.70)
                    Text(detail)
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textSecondary)
                        .lineLimit(4)
                        .minimumScaleFactor(0.70)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            content()
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(HFSpacing.md)
        .background(Color.white.opacity(0.055))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(accent.opacity(0.28), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(detail)")
        .accessibilityIdentifier(identifier)
    }

    private func launchProStat(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.70)
            Text(title)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.70)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.xs)
        .background(Color.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
    }

    private func launchProCapsule(_ title: String, active: Bool, accent: Color) -> some View {
        Text(title)
            .font(HFTypography.micro)
            .foregroundStyle(active ? .black : HFColors.textSecondary)
            .lineLimit(1)
            .minimumScaleFactor(0.70)
            .padding(.horizontal, HFSpacing.xs)
            .frame(height: 28)
            .background(active ? AnyShapeStyle(accent == HFColors.gold ? HFColors.goldGradient : LinearGradient(colors: [accent.opacity(0.92), accent.opacity(0.58)], startPoint: .topLeading, endPoint: .bottomTrailing)) : AnyShapeStyle(Color.white.opacity(0.07)))
            .clipShape(Capsule())
    }

    private func launchProStep(_ title: String, muted: Bool = false) -> some View {
        Text(title)
            .font(HFTypography.micro)
            .foregroundStyle(muted ? HFColors.textSecondary : .black)
            .frame(maxWidth: .infinity)
            .frame(height: 30)
            .background(muted ? AnyShapeStyle(Color.white.opacity(0.08)) : AnyShapeStyle(HFColors.cyanGlow.opacity(0.88)))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func launchProMiniTarget(_ title: String) -> some View {
        Text(title)
            .font(HFTypography.micro)
            .foregroundStyle(HFColors.textPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.70)
            .frame(maxWidth: .infinity)
            .frame(height: 32)
            .background(HFColors.cyanGlow.opacity(0.16))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(HFColors.cyanGlow.opacity(0.24), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func launchTimelineRow(_ title: String, _ state: String) -> some View {
        HStack {
            Text(title)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.70)
            Spacer(minLength: HFSpacing.xs)
            Text(state)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.gold)
                .lineLimit(1)
                .minimumScaleFactor(0.70)
        }
    }

    private func launchAssetTile(_ title: String, accent: Color) -> some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(accent.opacity(0.28))
                .frame(height: 36)
            Text(title)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.70)
        }
        .frame(maxWidth: .infinity)
    }

    private func launchCheckRow(_ title: String) -> some View {
        Label(title, systemImage: "checkmark.seal.fill")
            .font(HFTypography.micro)
            .foregroundStyle(HFColors.textSecondary)
            .lineLimit(1)
            .minimumScaleFactor(0.70)
    }

    private var vodLaunchChamber: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius + 10, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFSpatialRouteBadge(title: "Creator -> VOD", accent: HFColors.gold)

                        Text("VOD Launch Chamber")
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.gold)
                            .textCase(.uppercase)
                            .tracking(1.2)

                        Text(streamingStore.featuredMovie.title)
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.74)
                            .accessibilityIdentifier("hf.spatial.vod.projectTitle")

                        Text(selectedVODFocus == .release ? "Release readiness focus" : "\(selectedVODFocus.displayName) release focus")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .accessibilityIdentifier("hf.spatial.vod.selectedFocus")
                    }

                    Spacer(minLength: HFSpacing.sm)

                    Button {
                        select(.look)
                    } label: {
                        Label("Back to Creator Studio", systemImage: "chevron.left")
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.70)
                            .padding(.horizontal, HFSpacing.xs)
                            .frame(height: 34)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.vod.backToStudio")
                    .accessibilityIdentifier("hf.route.vodToCreatorStudio")
                }

                ZStack {
                    vodOpticalBlackSurface
                    vodReleaseCore
                    if usesSpatialFallbackLayout {
                        VStack {
                            Spacer()
                            vodFocusFallbackRow
                        }
                        .padding(.bottom, HFSpacing.sm)
                    } else {
                        ForEach(HFVODReleaseFocus.allCases) { focus in
                            vodReleaseObject(focus)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: usesSpatialFallbackLayout ? 430 : 452)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Release core first. Selected focus \(selectedVODFocus.displayName). Five local VOD release focuses.")
                .accessibilityIdentifier("hf.spatial.accessibility.fallbackLayout")
                .accessibilityIdentifier("hf.spatial.vod.chamber")

                HFSpatialActionCluster {
                    HFEnergyAction(title: "Review Release", systemImage: "checkmark.seal.fill", style: .gold) {
                        didSaveVODPackage = true
                        didSaveLocalDraft = true
                    }
                    .accessibilityIdentifier("hf.vod.reviewRelease")
                    .accessibilityIdentifier("hf.creatorStudio.packageVOD")
                    .accessibilityIdentifier("hf.route.creatorStudioToVOD")

                    HStack(spacing: HFSpacing.sm) {
                        HFEnergyAction(title: didSaveVODPackage ? "Package Saved" : "Save Local Package", systemImage: "square.and.arrow.down", style: .glass) {
                            didSaveVODPackage = true
                            didSaveLocalDraft = true
                        }
                        .accessibilityIdentifier("hf.vod.saveDraft")

                        HFEnergyAction(title: "Open Inspector", systemImage: "slider.horizontal.3", style: .glass) {
                            isVODInspectorPresented = true
                        }
                        .accessibilityIdentifier("hf.vod.inspector")
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.spatial.vod")
        .hfSpatialFocalHandoff("hf.spatial.handoff.creatorToVOD")
    }

    private var vodOpticalBlackSurface: some View {
        RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous)
            .fill(
                RadialGradient(
                    colors: [
                        HFColors.gold.opacity(0.22),
                        HFColors.violet.opacity(0.16),
                        reduceTransparency ? Color.black : HFColors.background.opacity(0.98),
                        Color.black
                    ],
                    center: .center,
                    startRadius: 24,
                    endRadius: 410
                )
            )
            .overlay(
                HFDepthContourOverlay(color: HFColors.gold.opacity(0.70), lineWidth: 0.78)
                    .opacity(0.28)
                    .padding(.horizontal, -36)
            )
            .overlay(
                Circle()
                    .trim(from: 0.08, to: 0.86)
                    .stroke(
                        LinearGradient(
                            colors: [HFColors.gold.opacity(0.62), HFColors.violet.opacity(0.28), Color.white.opacity(0.10)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 1.2, lineCap: .round)
                    )
                    .frame(width: 286, height: 286)
                    .rotationEffect(.degrees(reduceMotion ? 0 : -12))
                    .opacity(0.78)
            )
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous))
            .accessibilityHidden(true)
    }

    private var vodFocusFallbackRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HFSpacing.sm) {
                ForEach(HFVODReleaseFocus.allCases) { focus in
                    vodReleaseObject(focus, usesSpatialOffset: false)
                }
            }
            .padding(.horizontal, HFSpacing.sm)
        }
        .accessibilityIdentifier("hf.spatial.accessibility.largeType")
    }

    private var vodReleaseCore: some View {
        ZStack(alignment: .bottomLeading) {
            projectArtwork(for: streamingStore.featuredMovie)
                .frame(width: 226, height: 318)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.24), Color.black.opacity(0.92)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(HFColors.gold.opacity(0.72), lineWidth: 1.3)
                )
                .shadow(color: HFColors.gold.opacity(reduceMotion ? 0 : 0.34), radius: reduceMotion ? 0 : 28, x: 0, y: 20)
                .shadow(color: HFColors.violet.opacity(reduceMotion ? 0 : 0.28), radius: reduceMotion ? 0 : 30, x: 0, y: -8)

            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Text(selectedVODFocus.displayName)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.gold.opacity(0.96))
                    .textCase(.uppercase)
                    .tracking(1.1)

                Text(streamingStore.featuredMovie.title)
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.68)

                vodReleasePreviewContent
            }
            .frame(maxWidth: 186, alignment: .leading)
            .padding(HFSpacing.md)
            .padding(.bottom, selectedVODFocus == .release ? 46 : 0)
        }
        .scaleEffect(reduceMotion ? 1 : 1.02)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Dominant VOD release core. \(selectedVODFocus.displayName). \(selectedVODFocus.purpose).")
        .accessibilityIdentifier("hf.spatial.vod.core")
    }

    @ViewBuilder
    private var vodReleasePreviewContent: some View {
        Group {
            switch selectedVODFocus {
            case .trailer:
                Text("Trailer frame. 00:42 local pull. Timeline note staged for review.")
                    .accessibilityIdentifier("hf.vod.trailerPreview")
            case .poster:
                Text("Cinematic poster treatment. Title lockup. Local poster-readiness note.")
                    .accessibilityIdentifier("hf.vod.posterPreview")
            case .synopsis:
                VStack(alignment: .leading, spacing: 4) {
                    Text("A compact release synopsis sits inside the chamber.")
                        .accessibilityIdentifier("hf.vod.synopsisPreview")
                    Text("Short copy ready")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textMuted)
                        .accessibilityIdentifier("hf.vod.shortSynopsis")
                    Text("Long copy staged locally")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textMuted)
                        .accessibilityIdentifier("hf.vod.longSynopsis")
                }
            case .access:
                VStack(alignment: .leading, spacing: 4) {
                    Text("Access boundary review. Local Preview remains available.")
                        .accessibilityIdentifier("hf.vod.accessPreview")
                    Text("Pricing boundary")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textMuted)
                        .accessibilityIdentifier("hf.vod.pricingBoundary")
                    Text("Entitlement boundary")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textMuted)
                        .accessibilityIdentifier("hf.vod.entitlementBoundary")
                    Text("StoreKit product mapping readiness")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textMuted)
                        .accessibilityIdentifier("hf.vod.storeKitMapping")
                    Text("Local Preview fallback")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textMuted)
                        .accessibilityIdentifier("hf.vod.localPreviewFallback")
                }
            case .release:
                VStack(alignment: .leading, spacing: 4) {
                    Text("Local release review. Provider readiness stays secondary.")
                        .accessibilityIdentifier("hf.vod.releasePreview")
                    Text("Distribution readiness")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textMuted)
                        .accessibilityIdentifier("hf.vod.distributionReadiness")
                    Text("Storefront readiness")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textMuted)
                        .accessibilityIdentifier("hf.vod.storefrontReadiness")
                    Text("Release package remains local")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textMuted)
                        .accessibilityIdentifier("hf.vod.releaseLocalOnly")
                }
            }
        }
        .font(HFTypography.caption)
        .foregroundStyle(HFColors.textPrimary)
        .lineLimit(5)
        .minimumScaleFactor(0.72)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func vodReleaseObject(_ focus: HFVODReleaseFocus, usesSpatialOffset: Bool = true) -> some View {
        let isSelected = selectedVODFocus == focus
        let offset = usesSpatialOffset ? vodFocusOffset(focus, isSelected: isSelected) : .zero

        return Button {
            withAnimation(reduceMotion ? nil : HFSpatialMotionTokens.focusAnimation) {
                selectedVODFocus = focus
            }
        } label: {
            VStack(spacing: HFSpacing.xxs) {
                Image(systemName: focus.systemImage)
                    .font(.system(size: isSelected ? 20 : 17, weight: .black))
                    .foregroundStyle(isSelected ? .black : HFColors.textPrimary)
                    .frame(width: isSelected ? 54 : 46, height: isSelected ? 54 : 46)
                    .background(isSelected ? AnyShapeStyle(LinearGradient(colors: [HFColors.gold, HFColors.violet.opacity(0.82)], startPoint: .topLeading, endPoint: .bottomTrailing)) : AnyShapeStyle(Color.white.opacity(0.08)))
                    .clipShape(Circle())

                Text(focus.displayName)
                    .font(HFTypography.micro)
                    .foregroundStyle(isSelected ? HFColors.gold : HFColors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                if isSelected || differentiateWithoutColor {
                    Label(isSelected ? "Selected" : "Available", systemImage: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(HFTypography.micro)
                        .foregroundStyle(isSelected ? HFColors.gold : HFColors.textMuted)
                        .lineLimit(1)
                        .minimumScaleFactor(0.66)
                }
            }
            .frame(width: 92, height: 88)
            .background(isSelected ? HFColors.gold.opacity(0.16) : Color.black.opacity(0.22))
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                    .stroke(isSelected ? HFColors.gold.opacity(0.62) : HFColors.glassStroke, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .offset(offset)
        .hfSpatialSelectionTreatment(
            isSelected: isSelected,
            accent: HFColors.gold,
            reduceMotion: reduceMotion,
            differentiateWithoutColor: differentiateWithoutColor
        )
        .accessibilityLabel("\(focus.displayName), \(isSelected ? "selected" : "not selected"). \(focus.purpose)")
        .accessibilityValue(isSelected ? "Selected" : "Available")
        .accessibilityIdentifier(focus.accessibilityIdentifier)
        .accessibilityIdentifier(focus.routeIdentifier)
    }

    private func vodFocusOffset(_ focus: HFVODReleaseFocus, isSelected: Bool) -> CGSize {
        let selectedLift: CGFloat = isSelected && !reduceMotion ? -10 : 0
        switch focus {
        case .trailer: return CGSize(width: -120, height: -164 + selectedLift)
        case .poster: return CGSize(width: 120, height: -164 + selectedLift)
        case .synopsis: return CGSize(width: -132, height: 6 + selectedLift)
        case .access: return CGSize(width: 132, height: 6 + selectedLift)
        case .release: return CGSize(width: 0, height: 170 + selectedLift)
        }
    }

    private var vodReleaseInspector: some View {
        HFSpatialInspectorChrome(
            title: "Release Inspector",
            detail: "Local Draft, access boundaries, and release readiness stay secondary to the launch chamber.",
            accent: HFColors.gold
        ) {
            VStack(spacing: HFSpacing.xs) {
                HFCreatorStudioReadinessRow(title: "Local Draft", detail: didSaveVODPackage ? "Release package saved locally for review." : "Release package remains editable locally.", status: "Local", systemImage: "pencil", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.vod.localDraft")
                HFCreatorStudioReadinessRow(title: "Provider-ready", detail: "Release fields are staged without provider behavior.", status: "Ready", systemImage: "checkmark.seal.fill", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.vod.providerReady")
                HFCreatorStudioReadinessRow(title: "Not Connected Yet", detail: "Distribution, storefront, and entitlement providers are outside this local chamber.", status: "Boundary", systemImage: "network.slash", accent: HFColors.violet)
                    .accessibilityIdentifier("hf.vod.notConnected")
                HFCreatorStudioReadinessRow(title: "Trailer readiness", detail: "Trailer frame and duration note are staged locally.", status: "Local", systemImage: "film.fill", accent: HFColors.violet)
                    .accessibilityIdentifier("hf.vod.trailerReadiness")
                HFCreatorStudioReadinessRow(title: "Poster readiness", detail: "Key-art crop and title lockup are ready for local review.", status: "Local", systemImage: "photo.fill", accent: HFColors.violet)
                    .accessibilityIdentifier("hf.vod.posterReadiness")
                HFCreatorStudioReadinessRow(title: "Synopsis readiness", detail: "Short and long synopsis copy remain local.", status: "Local", systemImage: "text.alignleft", accent: HFColors.violet)
                    .accessibilityIdentifier("hf.vod.synopsisReadiness")
                HFCreatorStudioReadinessRow(title: "Pricing boundary", detail: "Access planning is staged without transaction behavior.", status: "Boundary", systemImage: "tag.fill", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.vod.pricingBoundary")
                HFCreatorStudioReadinessRow(title: "Entitlement boundary", detail: "Server validation remains a future provider boundary.", status: "Boundary", systemImage: "checkmark.shield.fill", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.vod.entitlementBoundary")
                HFCreatorStudioReadinessRow(title: "No live VOD provider", detail: "No release provider is active in this local package.", status: "Safe", systemImage: "lock.shield.fill", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.vod.noLiveProvider")
                HFCreatorStudioReadinessRow(title: "No distribution provider connected", detail: "Distribution readiness is a local review state.", status: "Safe", systemImage: "network.slash", accent: HFColors.violet)
                    .accessibilityIdentifier("hf.vod.noDistributionProvider")
                HFCreatorStudioReadinessRow(title: "No storefront provider connected", detail: "Storefront readiness is a local review state.", status: "Safe", systemImage: "cart.badge.questionmark", accent: HFColors.violet)
                    .accessibilityIdentifier("hf.vod.noStorefrontProvider")
                HFCreatorStudioReadinessRow(title: "Release package remains local", detail: "No media transfer, file generation, provider session, or transaction path is active.", status: "Local", systemImage: "lock.fill", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.vod.packageLocalOnly")
            }
        }
        .accessibilityIdentifier("hf.vod.inspector")
    }

    private func compactHandoffPanel(
        title: String,
        detail: String,
        systemImage: String,
        accent: Color,
        actionTitle: String,
        actionIdentifier: String,
        routeIdentifier: String,
        action: @escaping () -> Void
    ) -> some View {
        let usesGold = title == "VOD Package"

        return HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: accent.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: systemImage)
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(usesGold ? .black : HFColors.gold)
                        .frame(width: 46, height: 46)
                        .background(usesGold ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(accent.opacity(0.34)))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text(title)
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(detail)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Button(action: action) {
                    HFCreatorStudioAction(title: actionTitle, systemImage: systemImage, isPrimary: true)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(actionIdentifier)
                .accessibilityIdentifier(routeIdentifier)

                HFCreatorStudioReadinessRow(
                    title: "No live publishing",
                    detail: title == "VOD Package" ? "No live VOD provider, storefront, payment, or delivery action is active." : "No social posting, provider account, or platform action is active.",
                    status: "Local only",
                    systemImage: "lock.shield.fill",
                    accent: accent
                )
                .accessibilityIdentifier(title == "VOD Package" ? "hf.creatorStudio.noLiveVODProvider" : "hf.creatorStudio.noLivePublishing")
            }
            .padding(HFSpacing.md)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(title) local handoff. \(detail)")
    }

    private var creatorStudioProHero: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius + 10, strokeColor: HFColors.gold.opacity(0.42)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Creator Studio Pro",
                    detail: "Local command surface for release planning, social assets, VOD package state, commentary rooms, and creator identity.",
                    systemImage: "wand.and.stars.inverse",
                    accent: HFColors.gold
                )

                creatorIdentityCard
                creatorPublishingSummaryStrip
                creatorProSpotlightPanel
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Creator Studio Pro dashboard for \(streamingStore.featuredMovie.title)")
        .accessibilityIdentifier("hf.creator.pro.dashboard")
    }

    private var creatorIdentityCard: some View {
        HStack(alignment: .center, spacing: HFSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                    .fill(HFColors.goldGradient)
                Image(systemName: streamingStore.activeViewingProfile.avatarSymbol)
                    .font(.system(size: 30, weight: .black))
                    .foregroundStyle(.black)
            }
            .frame(width: 78, height: 78)

            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Text(streamingStore.activeViewingProfile.displayName)
                    .font(HFTypography.section)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)

                Text("Creator identity card")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.gold)

                Text("Current project: \(streamingStore.featuredMovie.title)")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.76)
            }

            Spacer(minLength: HFSpacing.xs)
        }
        .padding(HFSpacing.md)
        .background(Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(HFColors.gold.opacity(0.24), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Creator identity card. \(streamingStore.activeViewingProfile.displayName). Current project \(streamingStore.featuredMovie.title).")
        .accessibilityIdentifier("hf.creator.pro.identityCard")
    }

    @ViewBuilder
    private var creatorProSpotlightPanel: some View {
        switch proSpotlight {
        case .dashboard:
            creatorProSpotlight(
                title: "Creator Command Dashboard",
                detail: "A compact operating center for local project status, creative notes, and room handoffs.",
                systemImage: "rectangle.grid.2x2.fill",
                accent: HFColors.gold,
                identifier: "hf.creator.pro.dashboard"
            ) {
                HStack(spacing: HFSpacing.xs) {
                    creatorProStat(title: "Project", value: "Local")
                    creatorProStat(title: "Rooms", value: "3")
                    creatorProStat(title: "Ready", value: "Review")
                }
            }
        case .cms:
            contentManagementSpotlightPanel
        case .pipeline:
            creatorPublishingSpotlightPanel
        case .socialAssets:
            socialAssetKitSection
        case .vodPackage:
            vodPackageStatusSection
        case .analytics:
            analyticsPreviewSection
        }
    }

    private var creatorStudioProSurface: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            contentManagementSystemSection
            creatorPublishingPipelineSection

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 156), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                contentTypesSection
                collectionManagementSection
                contentStatusSection
                contentRelationshipsSection
                projectPipelineSection
                releaseReadinessSection
                socialAssetKitSection
                vodPackageStatusSection
                analyticsPreviewSection
                launchControlPreviewSection
            }

            creatorPublishingLibrarySection
            commentaryGatewaySection
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var contentManagementSpotlightPanel: some View {
        creatorProSpotlight(
            title: "Content Management System",
            detail: "Movies, series, episodes, trailers, collections, creators, metadata, status, and relationships are indexed locally.",
            systemImage: "rectangle.stack.badge.person.crop.fill",
            accent: HFColors.cyanGlow,
            identifier: "hf.cms.dashboard"
        ) {
            HStack(spacing: HFSpacing.xs) {
                creatorProStat(title: "Records", value: "\(streamingStore.cmsContentRecords.count)")
                creatorProStat(title: "Collections", value: "\(streamingStore.cmsCollections.count)")
                creatorProStat(title: "Relations", value: "\(streamingStore.cmsRelationships.count)")
            }
        }
    }

    private var contentManagementSystemSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius + 6, strokeColor: HFColors.cyanGlow.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Content Management System",
                    detail: "A local content backbone for movies, series, episodes, trailers, collections, creators, metadata, and relationships.",
                    systemImage: "rectangle.stack.badge.person.crop.fill",
                    accent: HFColors.cyanGlow
                )

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 118), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    ForEach(HFCMSContentType.allCases) { type in
                        cmsTypeTile(type)
                    }
                }
                .accessibilityIdentifier("hf.cms.contentTypes")

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text("Metadata Management")
                        .font(HFTypography.caption.weight(.bold))
                        .foregroundStyle(HFColors.textPrimary)
                    Text("Title, description, genre, tags, runtime, rating, artwork, trailer, creator, collection, series, and related-title fields are represented from local catalog records.")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(HFSpacing.sm)
                .background(Color.black.opacity(0.26))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
                .accessibilityIdentifier("hf.cms.metadataManagement")
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Content Management System. Local content backbone for movies, series, episodes, trailers, collections, creators, metadata, and relationships.")
        .accessibilityIdentifier("hf.cms.dashboard")
    }

    private var contentTypesSection: some View {
        creatorProSpotlight(
            title: "Content Types",
            detail: "Movies, series, episodes, trailers, collections, and creators share one local catalog model.",
            systemImage: "square.grid.3x2.fill",
            accent: HFColors.cyanGlow,
            identifier: "hf.cms.contentTypes"
        ) {
            HStack(spacing: HFSpacing.xs) {
                creatorProStat(title: "Movies", value: "\(cmsCount(.movie))")
                creatorProStat(title: "Series", value: "\(cmsCount(.series))")
                creatorProStat(title: "Episodes", value: "\(cmsCount(.episode))")
            }
        }
    }

    private var collectionManagementSection: some View {
        creatorProSpotlight(
            title: "Collection Management",
            detail: "Horror, crime, drama, documentary, western, premieres, and creator collections are managed locally.",
            systemImage: "rectangle.grid.2x2.fill",
            accent: HFColors.gold,
            identifier: "hf.cms.collectionManagement"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                ForEach(streamingStore.cmsCollections.prefix(3)) { collection in
                    cmsCompactRow(title: collection.title, detail: "\(collection.movieIDs.count) titles", color: HFColors.gold)
                }
            }
        }
    }

    private var contentStatusSection: some View {
        creatorProSpotlight(
            title: "Content Status",
            detail: "Draft, review, scheduled, published, and archived states are shared with the publishing pipeline.",
            systemImage: "checkmark.seal.fill",
            accent: HFColors.violet,
            identifier: "hf.cms.statusBoard"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                ForEach(streamingStore.cmsStatusCounts) { status in
                    cmsCompactRow(title: status.state.rawValue, detail: "\(status.count) records", color: status.state == .published ? HFColors.gold : HFColors.violet)
                }
            }
        }
    }

    private var contentRelationshipsSection: some View {
        creatorProSpotlight(
            title: "Content Relationships",
            detail: "Movie to creator, collection, series, and related-title relationships power discovery and profiles.",
            systemImage: "point.3.connected.trianglepath.dotted",
            accent: HFColors.cyanGlow,
            identifier: "hf.cms.relationships"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                ForEach(streamingStore.cmsRelationships.prefix(3)) { relationship in
                    cmsCompactRow(title: relationship.relationship, detail: "\(relationship.source) -> \(relationship.target)", color: HFColors.cyanGlow)
                }
            }
        }
    }

    private func cmsTypeTile(_ type: HFCMSContentType) -> some View {
        let count = cmsCount(type)
        return VStack(alignment: .leading, spacing: HFSpacing.xxs) {
            Image(systemName: type.systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(HFColors.cyanGlow)
                .accessibilityHidden(true)
            Text("\(count)")
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
            Text(type.rawValue)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.black.opacity(0.28))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous)
                .stroke(HFColors.cyanGlow.opacity(0.22), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(type.rawValue), \(count) records")
    }

    private func cmsCompactRow(title: String, detail: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.xs) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .padding(.top, 5)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
                Text(detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.70)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
    }

    private func cmsCount(_ type: HFCMSContentType) -> Int {
        streamingStore.cmsContentRecords.filter { $0.type == type }.count
    }

    private var creatorPublishingSummaryStrip: some View {
        HStack(spacing: HFSpacing.xs) {
            creatorProStat(title: "Drafts", value: "\(streamingStore.creatorDraftProjects.count)")
            creatorProStat(title: "Review", value: "\(streamingStore.creatorReviewProjects.count)")
            creatorProStat(title: "Published", value: "\(streamingStore.creatorPublishedProjects.count)")
            creatorProStat(title: "Archived", value: "\(streamingStore.creatorArchivedProjects.count)")
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Creator publishing summary. \(streamingStore.creatorDraftProjects.count) drafts, \(streamingStore.creatorReviewProjects.count) in review, \(streamingStore.creatorPublishedProjects.count) published, \(streamingStore.creatorArchivedProjects.count) archived.")
        .accessibilityIdentifier("hf.creator.pipeline.creatorLibrary")
    }

    private var creatorPublishingPipelineSection: some View {
        let project = creatorPrimaryPublishingProject

        return HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius + 6, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Creator Publishing Pipeline",
                    detail: "Content object, metadata, poster, trailer, creator library state, and local discovery connection.",
                    systemImage: "square.stack.3d.up.fill",
                    accent: HFColors.gold
                )

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text(project.title)
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.74)

                    Text("\(project.creator) • \(project.genre) • \(project.runtime) • \(project.releaseState.rawValue)")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.gold)
                        .lineLimit(2)
                        .minimumScaleFactor(0.76)

                    Text(project.description)
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityIdentifier("hf.creator.pipeline.contentObject")

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 118), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    publishingStatusTile(title: "Poster", status: project.posterStatus.rawValue, systemImage: "photo.fill.on.rectangle.fill", identifier: "hf.creator.pipeline.posterStatus", accent: HFColors.gold)
                    publishingStatusTile(title: "Trailer", status: project.trailerStatus.rawValue, systemImage: "film.stack.fill", identifier: "hf.creator.pipeline.trailerStatus", accent: HFColors.cyanGlow)
                    publishingStatusTile(title: "Metadata", status: project.metadataStatus.rawValue, systemImage: "text.justify.left", identifier: "hf.creator.pipeline.metadataStatus", accent: HFColors.violet)
                    publishingStatusTile(title: "Artwork", status: project.artworkStatus.rawValue, systemImage: "rectangle.stack.fill", identifier: "hf.creator.pipeline.artworkStatus", accent: HFColors.gold)
                }

                HStack(alignment: .center, spacing: HFSpacing.sm) {
                    Label(project.readyForReview ? "Ready For Review" : "Needs Local Review", systemImage: project.readyForReview ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                        .font(HFTypography.caption.weight(.bold))
                        .foregroundStyle(project.readyForReview ? HFColors.gold : HFColors.textSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.76)
                        .accessibilityIdentifier("hf.creator.pipeline.readyForReview")

                    Spacer(minLength: HFSpacing.xs)

                    Text(project.discoveryEligible ? "Visible in local discovery" : "Creator library only")
                        .font(HFTypography.micro.weight(.semibold))
                        .foregroundStyle(project.discoveryEligible ? HFColors.cyanGlow : HFColors.textSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.76)
                        .accessibilityIdentifier("hf.creator.pipeline.discoveryConnection")
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Creator publishing pipeline. \(project.title). \(project.releaseState.rawValue).")
        .accessibilityIdentifier("hf.creator.pipeline.dashboard")
    }

    private var creatorPublishingLibrarySection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.26)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Creator Library",
                    detail: "My Projects, drafts, published titles, and archived packages stay local until a project reaches Published.",
                    systemImage: "books.vertical.fill",
                    accent: HFColors.violet
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: HFSpacing.sm) {
                        ForEach(streamingStore.creatorPublishingContents) { project in
                            creatorPublishingProjectCard(project)
                        }
                    }
                    .padding(.vertical, 2)
                }

                HStack(spacing: HFSpacing.xs) {
                    HFCreatorStudioPill(title: "My Projects \(streamingStore.creatorPublishingContents.count)", isActive: true)
                    HFCreatorStudioPill(title: "Draft \(streamingStore.creatorDraftProjects.count)")
                    HFCreatorStudioPill(title: "Published \(streamingStore.creatorPublishedProjects.count)")
                    HFCreatorStudioPill(title: "Archived \(streamingStore.creatorArchivedProjects.count)")
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Creator library filters for my projects, drafts, published, and archived.")
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Creator library. My Projects, Drafts, Published, and Archived.")
        .accessibilityIdentifier("hf.creator.pipeline.creatorLibrary")
    }

    private var creatorPublishingSpotlightPanel: some View {
        let project = creatorPrimaryPublishingProject

        return creatorProSpotlight(
            title: "Creator Publishing Pipeline",
            detail: "Content ingestion, metadata, poster, trailer, creator library state, and discovery connection are staged locally.",
            systemImage: "square.stack.3d.up.fill",
            accent: HFColors.gold,
            identifier: "hf.creator.pipeline.dashboard"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    Text(project.title)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.74)
                    Text("\(project.releaseState.rawValue) • \(project.creator) • \(project.genre)")
                        .font(HFTypography.micro.weight(.bold))
                        .foregroundStyle(HFColors.gold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                }
                .accessibilityIdentifier("hf.creator.pipeline.contentObject")

                HStack(spacing: HFSpacing.xs) {
                    creatorProStat(title: "Drafts", value: "\(streamingStore.creatorDraftProjects.count)")
                    creatorProStat(title: "Review", value: "\(streamingStore.creatorReviewProjects.count)")
                    creatorProStat(title: "Published", value: "\(streamingStore.creatorPublishedProjects.count)")
                }

                Label(project.readyForReview ? "Ready For Review" : "Needs Local Review", systemImage: "checkmark.seal.fill")
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(project.readyForReview ? HFColors.gold : HFColors.textSecondary)
                    .accessibilityIdentifier("hf.creator.pipeline.readyForReview")

                Text(project.discoveryEligible ? "Published content appears in local discovery." : "Project remains in Creator Library until Published.")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.creator.pipeline.discoveryConnection")
            }
        }
    }

    private var creatorPrimaryPublishingProject: HFCreatorPublishingContent {
        streamingStore.creatorReviewProjects.first
            ?? streamingStore.creatorDraftProjects.first
            ?? streamingStore.creatorScheduledProjects.first
            ?? streamingStore.creatorPublishedProjects.first
            ?? streamingStore.creatorPublishingContents[0]
    }

    private func publishingStatusTile(title: String, status: String, systemImage: String, identifier: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xxs) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(accent)
                .accessibilityHidden(true)

            Text(status)
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(title)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.black.opacity(0.28))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous)
                .stroke(accent.opacity(0.26), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) status \(status).")
        .accessibilityIdentifier(identifier)
    }

    private func creatorPublishingProjectCard(_ project: HFCreatorPublishingContent) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            HStack(spacing: HFSpacing.xs) {
                Image(systemName: project.releaseState == .published ? "checkmark.seal.fill" : "doc.text.image.fill")
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(project.releaseState == .published ? HFColors.gold : HFColors.cyanGlow)
                Text(project.releaseState.rawValue)
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(project.releaseState == .published ? HFColors.gold : HFColors.textSecondary)
                    .lineLimit(1)
            }

            Text(project.title)
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            Text(project.updatedAtLabel)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.74)

            Spacer(minLength: 0)

            Text(project.discoveryEligible ? "Discovery connected" : "Library only")
                .font(HFTypography.micro.weight(.semibold))
                .foregroundStyle(project.discoveryEligible ? HFColors.cyanGlow : HFColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(width: 168, height: 146, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(project.releaseState == .published ? HFColors.gold.opacity(0.34) : HFColors.violet.opacity(0.22), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(project.title). \(project.releaseState.rawValue). \(project.updatedAtLabel).")
        .accessibilityIdentifier(accessibilityIdentifier(for: project.releaseState))
    }

    private func accessibilityIdentifier(for state: HFCreatorReleaseState) -> String {
        switch state {
        case .draft:
            return "hf.creator.pipeline.drafts"
        case .review:
            return "hf.creator.pipeline.review"
        case .scheduled:
            return "hf.creator.pipeline.scheduled"
        case .published:
            return "hf.creator.pipeline.published"
        case .archived:
            return "hf.creator.pipeline.archived"
        }
    }

    private var projectPipelineSection: some View {
        creatorProSpotlight(
            title: "Project Pipeline",
            detail: "Look, trailer, sound, campaign, and VOD steps stay staged as local review states.",
            systemImage: "point.3.connected.trianglepath.dotted",
            accent: HFColors.violet,
            identifier: "hf.creator.pro.projectPipeline"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                HFCreatorStudioPill(title: "Look", isActive: selectedTool == .look)
                HFCreatorStudioPill(title: "Trailer", isActive: selectedTool == .trailer)
                HFCreatorStudioPill(title: "Social", isActive: selectedTool == .social)
            }
        }
    }

    private var releaseReadinessSection: some View {
        creatorProSpotlight(
            title: "Release Readiness",
            detail: didSaveLocalDraft ? "Local draft is marked for review." : "Local draft is ready to review before launch planning.",
            systemImage: "checkmark.seal.fill",
            accent: HFColors.gold,
            identifier: "hf.creator.pro.releaseReadiness"
        ) {
            Button {
                didSaveLocalDraft = true
            } label: {
                HFCreatorStudioAction(title: didSaveLocalDraft ? "Draft Ready" : "Mark Ready", systemImage: "checkmark.seal.fill", isPrimary: true)
            }
            .buttonStyle(.plain)
        }
    }

    private var socialAssetKitSection: some View {
        creatorProSpotlight(
            title: "Social Asset Kit",
            detail: "Poster note, caption draft, vertical reel note, and story copy stay local.",
            systemImage: "bubble.left.and.bubble.right.fill",
            accent: HFColors.violet,
            identifier: "hf.creator.pro.socialAssetKit"
        ) {
            Button {
                select(.social)
            } label: {
                HFCreatorStudioAction(title: "Review Social Kit", systemImage: "bubble.left.and.bubble.right.fill")
            }
            .buttonStyle(.plain)
        }
    }

    private var vodPackageStatusSection: some View {
        creatorProSpotlight(
            title: "VOD Package Status",
            detail: "Trailer, poster, synopsis, access notes, and release copy are grouped for local review.",
            systemImage: "play.rectangle.on.rectangle.fill",
            accent: HFColors.gold,
            identifier: "hf.creator.pro.vodPackage"
        ) {
            Button {
                select(.vod)
            } label: {
                HFCreatorStudioAction(title: "Review VOD Package", systemImage: "play.rectangle.on.rectangle.fill")
            }
            .buttonStyle(.plain)
        }
    }

    private var analyticsPreviewSection: some View {
        creatorProSpotlight(
            title: "Creator Analytics Preview",
            detail: "Local preview signals summarize watch interest, saves, and room activity.",
            systemImage: "chart.bar.xaxis",
            accent: HFColors.cyanGlow,
            identifier: "hf.creator.pro.analyticsPreview"
        ) {
            HStack(spacing: HFSpacing.xs) {
                creatorProStat(title: "Saves", value: "\(max(12, streamingStore.savedMovieIDs.count * 6))")
                creatorProStat(title: "Signals", value: "Local")
            }
        }
    }

    private var launchControlPreviewSection: some View {
        creatorProSpotlight(
            title: "Launch Control Preview",
            detail: "A local launch review surface keeps release, campaign, and room steps visible.",
            systemImage: "sparkles.tv.fill",
            accent: HFColors.gold,
            identifier: "hf.creator.pro.launchControl"
        ) {
            HStack(spacing: HFSpacing.xs) {
                HFCreatorStudioPill(title: "Review", isActive: true)
                HFCreatorStudioPill(title: "Local")
            }
        }
    }

    private var commentaryGatewaySection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.34)) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(.black)
                    .frame(width: 50, height: 50)
                    .background(HFColors.cyanGlow)
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text("Commentary Room Gateway")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("Creator notes, watch-party context, and commentary entry stay local to this project.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Commentary room gateway. Creator notes and watch party context stay local.")
        .accessibilityIdentifier("hf.creator.pro.commentaryGateway")
    }

    private func creatorProSpotlight<Content: View>(
        title: String,
        detail: String,
        systemImage: String,
        accent: Color,
        identifier: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HStack(alignment: .top, spacing: HFSpacing.sm) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(accent == HFColors.gold ? .black : accent)
                    .frame(width: 42, height: 42)
                    .background(accent == HFColors.gold ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(accent.opacity(0.16)))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    Text(title)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                    Text(detail)
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            content()
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(HFSpacing.md)
        .background(Color.white.opacity(0.055))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(accent.opacity(0.28), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(detail)")
        .accessibilityIdentifier(identifier)
    }

    private func creatorProStat(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(title)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.xs)
        .background(Color.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
    }

    private var creatorInspector: some View {
        HFSpatialInspectorChrome(
            title: "Creative Inspector",
            detail: "Local status, provider boundaries, and package notes stay secondary to the film worktable.",
            accent: HFColors.gold
        ) {
            VStack(spacing: HFSpacing.xs) {
                HFCreatorStudioReadinessRow(title: "Local Draft", detail: didSaveLocalDraft ? "Saved in local preview state." : "Available for this project.", status: "Local", systemImage: "pencil", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.creatorStudio.localDraft")
                HFCreatorStudioReadinessRow(title: "Provider-ready", detail: "Creator package fields are staged without live provider behavior.", status: "Ready", systemImage: "checkmark.seal.fill", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.creatorStudio.providerReady")
                HFCreatorStudioReadinessRow(title: "Not Connected Yet", detail: "External platform, storefront, and entitlement systems are outside this local preview.", status: "Boundary", systemImage: "network.slash", accent: HFColors.violet)
                    .accessibilityIdentifier("hf.creatorStudio.notConnected")
                HFCreatorStudioReadinessRow(title: "Creative assets", detail: "Poster placeholder, trailer placeholder, synopsis, and sound notes are local.", status: "5 items", systemImage: "rectangle.stack.fill", accent: HFColors.violet)
                HFCreatorStudioReadinessRow(title: "No live publishing", detail: "No upload, social posting, provider session, or platform action is active.", status: "Safe", systemImage: "lock.shield.fill", accent: HFColors.violet)
                    .accessibilityIdentifier("hf.creatorStudio.noLivePublishing")
                HFCreatorStudioReadinessRow(title: "No live VOD provider", detail: "No storefront, distribution, entitlement, or payment action is active.", status: "Safe", systemImage: "lock.shield.fill", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.creatorStudio.noLiveVODProvider")
            }
        }
        .accessibilityIdentifier("hf.creatorStudio.inspector")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(.black)
                    .frame(width: 54, height: 54)
                    .background(HFColors.goldGradient)
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text("Creator Studio")
                        .font(HFTypography.display)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)

                    Text("Build the Release, Prepare the Social Kit, and Package the VOD for local review.")
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textSecondary)
                        .lineLimit(3)
                        .minimumScaleFactor(0.86)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: HFSpacing.xs) {
                        HFCreatorStudioPill(title: "Local Draft", isActive: true)
                        HFCreatorStudioPill(title: "Provider-ready")
                        HFCreatorStudioPill(title: "Not Connected Yet")
                    }
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var focusTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HFSpacing.xs) {
                ForEach(HFCreatorStudioFocus.allCases) { focus in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFocus = focus
                        }
                    } label: {
                        Text(focus.rawValue)
                            .font(HFTypography.smallAction)
                            .foregroundStyle(selectedFocus == focus ? .black : HFColors.textPrimary)
                            .padding(.horizontal, HFSpacing.md)
                            .frame(height: 36)
                            .background(selectedFocus == focus ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(Color.white.opacity(0.10)))
                            .overlay(Capsule().stroke(selectedFocus == focus ? Color.clear : HFColors.glassStroke, lineWidth: 1))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var backendReadinessSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Backend Readiness",
                    detail: "Local Draft actions stay available while Creator, Social, and VOD providers remain Not Connected Yet.",
                    systemImage: "server.rack",
                    accent: HFColors.gold
                )

                VStack(spacing: HFSpacing.xs) {
                    HFCreatorStudioReadinessRow(
                        title: "Creator Studio Backend",
                        detail: streamingStore.creatorStudioBackendStatus.statusLabel,
                        status: streamingStore.creatorStudioBackendStatus.isConfigured ? "Configured" : "Not Connected Yet",
                        systemImage: streamingStore.creatorStudioBackendStatus.systemImage,
                        accent: HFColors.gold
                    )
                    .accessibilityIdentifier("hf.creatorStudio.backendStatus")

                    HFCreatorStudioReadinessRow(
                        title: "Social Media Backend",
                        detail: streamingStore.socialKitBackendStatus.statusLabel,
                        status: streamingStore.socialKitBackendStatus.isConfigured ? "Configured" : "Not Connected Yet",
                        systemImage: streamingStore.socialKitBackendStatus.systemImage,
                        accent: Color.orange
                    )
                    .accessibilityIdentifier("hf.creatorStudio.socialBackendStatus")

                    HFCreatorStudioReadinessRow(
                        title: "VOD Backend",
                        detail: streamingStore.vodBackendStatus.statusLabel,
                        status: streamingStore.vodBackendStatus.isConfigured ? "Configured" : "Not Connected Yet",
                        systemImage: streamingStore.vodBackendStatus.systemImage,
                        accent: HFColors.gold
                    )
                    .accessibilityIdentifier("hf.creatorStudio.vodBackendStatus")
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Creator Studio backend readiness \(streamingStore.backendStatus.statusLabel)")
    }

    private var dashboardSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Current Project", actionTitle: "Tonight on HighFive")

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.36)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        Image(systemName: "film.stack.fill")
                            .font(.system(size: 22, weight: .black))
                            .foregroundStyle(HFColors.gold)
                            .frame(width: 48, height: 48)
                            .background(HFColors.gold.opacity(0.13))
                            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            Text("\(streamingStore.featuredMovie.title) Creator Slate")
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                            Text("Current project, local project status, and creator profile context stay inside this app.")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 138), spacing: HFSpacing.xs)], alignment: .leading, spacing: HFSpacing.xs) {
                        HFCreatorStudioMetric(title: "Current project", detail: streamingStore.featuredMovie.title, systemImage: "sparkles.tv.fill", isActive: true)
                        HFCreatorStudioMetric(title: "Local project status", detail: "Local Draft", systemImage: "pencil")
                        HFCreatorStudioMetric(title: "Creator profile", detail: streamingStore.activeViewingProfile.displayName, systemImage: streamingStore.activeViewingProfile.avatarSymbol)
                        HFCreatorStudioMetric(title: "Provider boundary", detail: "Not Connected Yet", systemImage: "network.slash")
                    }

                    VStack(spacing: HFSpacing.sm) {
                        Button {
                            didSaveLocalDraft = true
                        } label: {
                            HFCreatorStudioAction(title: "Build the Release", systemImage: "checkmark.seal.fill", isPrimary: true)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("hf.creatorStudio.primaryAction")
                        .accessibilityIdentifier("hf.creatorStudio.buildTheRelease")

                        Button {
                            selectedFocus = .socialMediaKit
                        } label: {
                            HFCreatorStudioAction(title: "Prepare the Social Kit", systemImage: "bubble.left.and.bubble.right.fill")
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("hf.creatorStudio.prepareSocialKit")

                        Button {
                            selectedFocus = .vodPackage
                        } label: {
                            HFCreatorStudioAction(title: "Package the VOD", systemImage: "play.rectangle.on.rectangle.fill")
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("hf.creatorStudio.packageVOD")
                    }
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Studio Dashboard, local project status, creator profile context")
        .accessibilityIdentifier("hf.creatorStudio.dashboard")
        .accessibilityIdentifier("hf.creatorStudio.currentProject")
        .accessibilityIdentifier("hf.creatorStudio.workspaceModules")
    }

    private var toolControlStrip: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Tool Control Strip", actionTitle: "Provider-ready")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    toolControlCard(title: "Project Slate", detail: "Current Project", systemImage: "film.stack.fill", identifier: "hf.creatorStudio.projectSlate", focus: .dashboard)
                    toolControlCard(title: "Asset Board", detail: "Poster + clip placeholders", systemImage: "photo.on.rectangle.angled", identifier: "hf.creatorStudio.assetBoard", focus: .dashboard)
                    toolControlCard(title: "Caption Lab", detail: "Caption Drafts", systemImage: "text.quote", identifier: "hf.creatorStudio.captionLab", focus: .socialMediaKit)
                    toolControlCard(title: "Social Media Kit", detail: "Review Social Kit", systemImage: "bubble.left.and.bubble.right.fill", identifier: "hf.creatorStudio.socialMediaKit", focus: .socialMediaKit)
                    toolControlCard(title: "Instagram Connect", detail: "Not Connected Yet", systemImage: "camera.viewfinder", identifier: "hf.creatorStudio.instagramConnect", focus: .instagramConnect)
                    toolControlCard(title: "VOD Package", detail: "Preview VOD Package", systemImage: "shippingbox.fill", identifier: "hf.creatorStudio.vodPackage", focus: .vodPackage)
                    toolControlCard(title: "Release Checklist", detail: "Build the Release", systemImage: "checklist.checked", identifier: "hf.creatorStudio.releaseChecklist", focus: .vodPackage)
                    toolControlCard(title: "Provider Readiness", detail: "Not Connected Yet", systemImage: "network.slash", identifier: "hf.creatorStudio.providerReadiness", focus: .instagramConnect)
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
        .accessibilityIdentifier("hf.creatorStudio.toolControlStrip")
    }

    private func toolControlCard(title: String, detail: String, systemImage: String, identifier: String, focus: HFCreatorStudioFocus) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedFocus = focus
            }
        } label: {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Image(systemName: systemImage)
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(selectedFocus == focus ? .black : HFColors.gold)
                    .frame(width: 36, height: 36)
                    .background(selectedFocus == focus ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(HFColors.gold.opacity(0.12)))
                    .clipShape(Circle())

                Text(title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.74)

                Text(detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
            }
            .frame(width: 136, height: 132, alignment: .topLeading)
            .padding(HFSpacing.sm)
            .background(selectedFocus == focus ? HFColors.gold.opacity(0.14) : Color.white.opacity(0.065))
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                    .stroke(selectedFocus == focus ? HFColors.gold.opacity(0.42) : HFColors.glassStroke, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
    }

    private var socialMediaKitSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Social Media Kit", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: Color.orange.opacity(0.36)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    sectionLead(
                        title: "Social Media Kit",
                        detail: "Build local captions, poster notes, and platform readiness before any account is connected.",
                        systemImage: "bubble.left.and.bubble.right.fill",
                        accent: Color.orange
                    )

                    HStack(spacing: HFSpacing.xs) {
                        HFCreatorStudioPill(title: "Local Draft", isActive: true)
                        HFCreatorStudioPill(title: "Provider-ready")
                        HFCreatorStudioPill(title: "Not Connected Yet")
                    }

                    Button {
                        selectedFocus = .socialMediaKit
                    } label: {
                        HFCreatorStudioAction(title: "Prepare the Social Kit", systemImage: "bubble.left.and.bubble.right.fill", isPrimary: selectedFocus == .socialMediaKit)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.creatorStudio.prepareSocialKit")

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Caption Drafts")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .accessibilityIdentifier("hf.creatorStudio.socialCaptionDrafts")

                        ForEach(captionDraftCards) { draft in
                            HFCreatorStudioReadinessRow(title: draft.title, detail: draft.detail, status: "Local Draft", systemImage: "text.quote", accent: Color.orange)
                        }
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: HFSpacing.xs)], alignment: .leading, spacing: HFSpacing.xs) {
                        HFCreatorStudioMetric(title: "Poster", detail: "Placeholder", systemImage: "photo.fill")
                        HFCreatorStudioMetric(title: "Clip", detail: "Placeholder", systemImage: "play.rectangle.fill")
                        HFCreatorStudioMetric(title: "Trailer pull", detail: "Local Draft", systemImage: "film.fill")
                        HFCreatorStudioMetric(title: "Caption set", detail: "Local Draft", systemImage: "text.bubble.fill")
                    }

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Platform readiness")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .accessibilityIdentifier("hf.creatorStudio.socialPlatformReadiness")

                        ForEach(socialPlatformRows) { platform in
                            HFCreatorStudioReadinessRow(title: platform.title, detail: platform.detail, status: "Not Connected Yet", systemImage: "network.slash", accent: Color.orange)
                        }
                    }

                    instagramConnectMiniCard

                    HFCreatorStudioReadinessRow(
                        title: "No live publishing",
                        detail: "Local planning only. No account connection, posting, sharing, or provider SDK is active.",
                        status: "Safe Boundary",
                        systemImage: "lock.shield.fill",
                        accent: Color.orange
                    )
                    .accessibilityIdentifier("hf.creatorStudio.noLivePublishing")
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Social Media Kit, Local Draft, Provider-ready, Not Connected Yet, local-only release boundary")
        .accessibilityIdentifier("hf.creatorStudio.socialMediaKit")
        .accessibilityIdentifier("hf.creatorStudio.prepareSocialKit")
    }

    private var instagramConnectMiniCard: some View {
        Button {
            selectedFocus = .instagramConnect
        } label: {
            HStack(alignment: .top, spacing: HFSpacing.sm) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
                    .background(
                        LinearGradient(
                            colors: [HFColors.gold, Color.orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text("Instagram Connect")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("Local Social Draft is ready to preview while Instagram stays Not Connected Yet.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: HFSpacing.xs) {
                        HFCreatorStudioPill(title: "Provider-ready")
                        HFCreatorStudioPill(title: "Not Connected Yet")
                    }
                }

                Spacer(minLength: HFSpacing.xs)
            }
            .padding(HFSpacing.md)
            .background(Color.white.opacity(0.065))
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                    .stroke(Color.orange.opacity(0.26), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("hf.creatorStudio.instagramConnect")
    }

    private var instagramConnectSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Instagram Connect", actionTitle: "Provider-ready")

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: Color.orange.opacity(0.38)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    sectionLead(
                        title: "Instagram Connect",
                        detail: "Preview a Local Social Draft and provider readiness before any account, backend, or permissions are connected.",
                        systemImage: "camera.viewfinder",
                        accent: Color.orange
                    )

                    HStack(spacing: HFSpacing.xs) {
                        HFCreatorStudioPill(title: "Local Social Draft", isActive: true)
                            .accessibilityIdentifier("hf.instagramConnect.localDraft")
                        HFCreatorStudioPill(title: "Provider-ready")
                            .accessibilityIdentifier("hf.instagramConnect.providerReady")
                        HFCreatorStudioPill(title: "Not Connected Yet")
                            .accessibilityIdentifier("hf.instagramConnect.notConnected")
                    }
                    .accessibilityIdentifier("hf.instagramConnect.status")

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Account Readiness")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .accessibilityIdentifier("hf.instagramConnect.accountReadiness")

                        HFCreatorStudioReadinessRow(title: "Instagram account", detail: "Not Connected Yet", status: "Waiting", systemImage: "person.crop.circle.badge.questionmark", accent: Color.orange)
                            .accessibilityIdentifier("hf.instagramConnect.notConnected")
                        HFCreatorStudioReadinessRow(title: "Creator identity", detail: "Local profile only", status: "Local Draft", systemImage: streamingStore.activeViewingProfile.avatarSymbol, accent: Color.orange)
                            .accessibilityIdentifier("hf.instagramConnect.creatorIdentity")
                        HFCreatorStudioReadinessRow(title: "Permission review", detail: "Required later", status: "Waiting", systemImage: "checkmark.shield.fill", accent: Color.orange)
                            .accessibilityIdentifier("hf.instagramConnect.permissionStatus")
                        HFCreatorStudioReadinessRow(title: "Backend vault", detail: "Required later", status: "Boundary", systemImage: "lock.shield.fill", accent: Color.orange)
                            .accessibilityIdentifier("hf.instagramConnect.backendRequired")
                    }

                    instagramDraftPreview

                    VStack(spacing: HFSpacing.sm) {
                        Button {
                            didSaveLocalDraft = true
                        } label: {
                            HFCreatorStudioAction(title: "Save Local Draft", systemImage: "square.and.arrow.down", isPrimary: true)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("hf.instagramConnect.saveLocalDraft")

                        Button {
                            didSaveLocalDraft = true
                        } label: {
                            HFCreatorStudioAction(title: "Copy Local Caption", systemImage: "doc.on.doc")
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("hf.instagramConnect.copyLocalCaption")

                        Button {
                            selectedFocus = .socialMediaKit
                        } label: {
                            HFCreatorStudioAction(title: "Preview Social Kit", systemImage: "bubble.left.and.bubble.right.fill")
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("hf.instagramConnect.previewSocialKit")
                    }

                    HFCreatorStudioReadinessRow(
                        title: "No live Instagram provider",
                        detail: "No live posting, no account session, and no OAuth credentials are active in this app.",
                        status: "Provider-ready only",
                        systemImage: "lock.shield.fill",
                        accent: Color.orange
                    )
                    .accessibilityIdentifier("hf.instagramConnect.noLiveProvider")
                    .accessibilityIdentifier("hf.instagramConnect.noLivePosting")
                    .accessibilityIdentifier("hf.instagramConnect.noOAuthTokens")
                    .accessibilityIdentifier("hf.instagramConnect.localOnlyBoundary")
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Instagram Connect, Provider-ready, Not Connected Yet, Local Social Draft")
        .accessibilityIdentifier("hf.instagramConnect.screen")
        .accessibilityIdentifier("hf.creatorStudio.instagramConnect")
    }

    private var instagramDraftPreview: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Post Draft Preview")
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)
                .accessibilityIdentifier("hf.instagramConnect.postDraftPreview")

            HStack(alignment: .top, spacing: HFSpacing.sm) {
                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text("Caption draft")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.gold)
                    Text("Tonight on HighFive: choose the scene you would replay first.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("hf.instagramConnect.captionDraft")
                    Text("#HighFiveCinema #TheFriendly #LocalSocialDraft")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textSecondary)
                        .accessibilityIdentifier("hf.instagramConnect.hashtagDraft")
                }

                Spacer(minLength: HFSpacing.sm)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: HFSpacing.xs)], alignment: .leading, spacing: HFSpacing.xs) {
                HFCreatorStudioMetric(title: "Poster placeholder", detail: "Local", systemImage: "photo.fill")
                    .accessibilityIdentifier("hf.instagramConnect.posterPlaceholder")
                HFCreatorStudioMetric(title: "Clip placeholder", detail: "Local", systemImage: "play.rectangle.fill")
                    .accessibilityIdentifier("hf.instagramConnect.clipPlaceholder")
                HFCreatorStudioMetric(title: "Alt text draft", detail: "Local", systemImage: "text.alignleft")
                    .accessibilityIdentifier("hf.instagramConnect.altTextDraft")
                HFCreatorStudioMetric(title: "Call-to-watch", detail: "HighFive", systemImage: "play.tv.fill")
            }
        }
        .padding(HFSpacing.md)
        .background(Color.white.opacity(0.055))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(Color.orange.opacity(0.18), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }

    private var vodPackageSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "VOD Package", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.38)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    sectionLead(
                        title: "VOD Package",
                        detail: "Prepare trailer, poster, synopsis, and provider-readiness before distribution is connected.",
                        systemImage: "shippingbox.fill",
                        accent: HFColors.gold
                    )

                    HStack(spacing: HFSpacing.xs) {
                        HFCreatorStudioPill(title: "Local Draft", isActive: true)
                        HFCreatorStudioPill(title: "Provider-ready")
                        HFCreatorStudioPill(title: "Not Connected Yet")
                    }

                    Button {
                        selectedFocus = .vodPackage
                    } label: {
                        HFCreatorStudioAction(title: "Package the VOD", systemImage: "play.rectangle.on.rectangle.fill", isPrimary: selectedFocus == .vodPackage)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.creatorStudio.packageVOD")

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("VOD release checklist")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .accessibilityIdentifier("hf.creatorStudio.vodChecklist")

                        ForEach(vodChecklistRows) { item in
                            HFCreatorStudioReadinessRow(title: item.title, detail: item.detail, status: item.status, systemImage: item.systemImage, accent: HFColors.gold)
                        }
                    }

                    packagePreviewCard
                    vodEntitlementBoundary

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Provider status")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .accessibilityIdentifier("hf.creatorStudio.vodProviderStatus")

                        HFCreatorStudioReadinessRow(title: "Distribution provider", detail: "Distribution provider — Not Connected Yet", status: "Provider-ready", systemImage: "network.slash", accent: HFColors.gold)
                        HFCreatorStudioReadinessRow(title: "Storefront provider", detail: "Storefront provider — Not Connected Yet", status: "Provider-ready", systemImage: "cart.badge.questionmark", accent: HFColors.gold)
                        HFCreatorStudioReadinessRow(title: "Payment / entitlement provider", detail: "Payment Provider Not Connected Yet", status: "Provider-ready", systemImage: "checkmark.shield.fill", accent: HFColors.gold)
                            .accessibilityIdentifier("hf.entitlement.status")
                    }
                    .accessibilityIdentifier("hf.creatorStudio.vodProviderStatus")

                    HFCreatorStudioReadinessRow(
                        title: "No live VOD provider",
                        detail: "No live VOD release, payments, media delivery, or file export is active.",
                        status: "Safe Boundary",
                        systemImage: "lock.shield.fill",
                        accent: HFColors.gold
                    )
                    .accessibilityIdentifier("hf.creatorStudio.noLiveVODProvider")
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("VOD Package, VOD release checklist, provider status Not Connected Yet")
        .accessibilityIdentifier("hf.creatorStudio.vodPackage")
        .accessibilityIdentifier("hf.creatorStudio.releasePrep")
        .accessibilityIdentifier("hf.creatorStudio.packageVOD")
    }

    private var vodEntitlementBoundary: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Text("Pricing / entitlement boundary")
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)
                .accessibilityIdentifier("hf.creatorStudio.vodPricingBoundary")

            HFCreatorStudioReadinessRow(
                title: "Local Draft",
                detail: "VOD pricing remains a local planning boundary.",
                status: "Local Draft",
                systemImage: "pencil",
                accent: HFColors.gold
            )

            HFCreatorStudioReadinessRow(
                title: "Provider-ready",
                detail: "Pricing and entitlement records are staged without a live payment provider.",
                status: "Provider-ready",
                systemImage: "checkmark.shield.fill",
                accent: HFColors.gold
            )
            .accessibilityIdentifier("hf.creatorStudio.vodEntitlementBoundary")

            HFCreatorStudioReadinessRow(
                title: "Payment Provider Not Connected Yet",
                detail: "Server Entitlement Validation Required before paid VOD access.",
                status: "Boundary",
                systemImage: "creditcard.and.123",
                accent: HFColors.gold
            )
            .accessibilityIdentifier("hf.entitlement.status")

            HFCreatorStudioReadinessRow(
                title: "No live VOD provider",
                detail: "No live VOD provider. No payment activation, media delivery, or distributor handoff is active.",
                status: "Safe Boundary",
                systemImage: "lock.shield.fill",
                accent: HFColors.gold
            )
            .accessibilityIdentifier("hf.creatorStudio.noLiveVODProvider")
        }
        .padding(HFSpacing.md)
        .background(Color.white.opacity(0.055))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(HFColors.gold.opacity(0.18), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityIdentifier("hf.creatorStudio.vodEntitlementBoundary")
    }

    private var localDraftActions: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Local Draft", actionTitle: nil)

            VStack(spacing: HFSpacing.sm) {
                Button {
                    selectedFocus = .socialMediaKit
                } label: {
                    HFCreatorStudioAction(title: "Review Social Kit", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.creatorStudio.reviewSocialKit")

                Button {
                    selectedFocus = .instagramConnect
                } label: {
                    HFCreatorStudioAction(title: "Preview Instagram Draft", systemImage: "camera.viewfinder")
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.creatorStudio.previewInstagramDraft")

                Button {
                    selectedFocus = .vodPackage
                } label: {
                    HFCreatorStudioAction(title: "Preview VOD Package", systemImage: "play.rectangle.on.rectangle.fill")
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.creatorStudio.previewVODPackage")

                Button {
                    didSaveLocalDraft = true
                } label: {
                    HFCreatorStudioAction(title: didSaveLocalDraft ? "Local Draft Saved" : "Save Local Draft", systemImage: "square.and.arrow.down", isPrimary: true)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.creatorStudio.localDraft")
                .accessibilityIdentifier("hf.creatorStudio.saveLocalDraft")

                Button {
                    dismiss()
                } label: {
                    HFCreatorStudioAction(title: "Back to Profile", systemImage: "person.crop.circle.fill")
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.creatorStudio.backToProfile")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var packagePreviewCard: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Package preview")
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)

            HStack(alignment: .top, spacing: HFSpacing.sm) {
                Image(systemName: "play.rectangle.on.rectangle.fill")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
                    .background(HFColors.goldGradient)
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text(streamingStore.featuredMovie.title)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("Synopsis, poster placeholder, trailer placeholder, release mood, and Local Draft status are grouped for review.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(HFSpacing.md)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(HFColors.gold.opacity(0.18), lineWidth: 1)
        )
    }

    private var captionDraftCards: [HFCreatorStudioDraftCard] {
        [
            HFCreatorStudioDraftCard(title: "Premiere", detail: "Tonight on HighFive: choose the scene you would replay first."),
            HFCreatorStudioDraftCard(title: "Behind the Shot", detail: "Move the frame and peek into the moment."),
            HFCreatorStudioDraftCard(title: "Creator Note", detail: "Poster, mood, and trailer direction are ready for review.")
        ]
    }

    private var socialPlatformRows: [HFCreatorStudioDraftCard] {
        [
            HFCreatorStudioDraftCard(title: "Instagram - Not Connected Yet", detail: "Poster drop - Provider-ready"),
            HFCreatorStudioDraftCard(title: "TikTok - Not Connected Yet", detail: "Trailer clip - Provider-ready"),
            HFCreatorStudioDraftCard(title: "YouTube Shorts - Not Connected Yet", detail: "Short caption - Provider-ready"),
            HFCreatorStudioDraftCard(title: "X / Threads - Not Connected Yet", detail: "Creator prompt - Provider-ready")
        ]
    }

    private var vodChecklistRows: [HFCreatorStudioChecklistRow] {
        [
            HFCreatorStudioChecklistRow(title: "Trailer readiness", detail: "Trailer placeholder is staged for review.", status: "Local Draft", systemImage: "film.fill"),
            HFCreatorStudioChecklistRow(title: "Poster readiness", detail: "Poster placeholder is ready for notes.", status: "Placeholder", systemImage: "photo.fill"),
            HFCreatorStudioChecklistRow(title: "Synopsis readiness", detail: "Synopsis copy stays editable locally.", status: "Local Draft", systemImage: "text.alignleft"),
            HFCreatorStudioChecklistRow(title: "Metadata readiness", detail: "Title, genre, and release mood are grouped.", status: "Local Draft", systemImage: "tag.fill"),
            HFCreatorStudioChecklistRow(title: "Pricing / entitlement boundary", detail: "No payment flow is active.", status: "Boundary", systemImage: "checkmark.shield.fill"),
            HFCreatorStudioChecklistRow(title: "Distribution provider", detail: "Not Connected Yet", status: "Provider-ready", systemImage: "network.slash"),
            HFCreatorStudioChecklistRow(title: "Storefront provider", detail: "Not Connected Yet", status: "Provider-ready", systemImage: "cart.badge.questionmark")
        ]
    }

    private func sectionLead(title: String, detail: String, systemImage: String, accent: Color) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(accent)
                .frame(width: 48, height: 48)
                .background(accent.opacity(0.13))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Text(title)
                    .font(HFTypography.section)
                    .foregroundStyle(HFColors.textPrimary)
                Text(detail)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct HFCreatorStudioPill: View {
    let title: String
    var isActive = false

    var body: some View {
        Text(title)
            .font(HFTypography.micro)
            .foregroundStyle(isActive ? .black : HFColors.gold)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, HFSpacing.xs)
            .frame(height: 24)
            .background(isActive ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(HFColors.gold.opacity(0.10)))
            .overlay(Capsule().stroke(isActive ? Color.clear : HFColors.gold.opacity(0.24), lineWidth: 1))
            .clipShape(Capsule())
    }
}

private struct HFCreatorStudioDraftCard: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
}

private struct HFCreatorStudioChecklistRow: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let status: String
    let systemImage: String
}

private struct HFCreatorStudioMetric: View {
    let title: String
    let detail: String
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
                .lineLimit(1)
                .minimumScaleFactor(0.74)

            Text(detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 102, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(isActive ? HFColors.gold.opacity(0.14) : Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous)
                .stroke(isActive ? HFColors.gold.opacity(0.38) : HFColors.glassStroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
    }
}

private struct HFCreatorStudioReadinessRow: View {
    let title: String
    let detail: String
    let status: String
    let systemImage: String
    let accent: Color

    var body: some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(accent)
                .frame(width: 32, height: 32)
                .background(accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

            VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                Text(title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: HFSpacing.xs)

            Text(status)
                .font(HFTypography.micro)
                .foregroundStyle(accent)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .padding(.horizontal, HFSpacing.xs)
                .frame(height: 24)
                .background(accent.opacity(0.10))
                .overlay(Capsule().stroke(accent.opacity(0.26), lineWidth: 1))
                .clipShape(Capsule())
        }
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }
}

private struct HFCreatorStudioAction: View {
    let title: String
    let systemImage: String
    var isPrimary = false

    var body: some View {
        HStack(spacing: HFSpacing.xs) {
            Image(systemName: systemImage)
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .black))
        }
        .font(HFTypography.smallAction)
        .foregroundStyle(isPrimary ? .black : HFColors.textPrimary)
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .padding(.horizontal, HFSpacing.md)
        .background(isPrimary ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(Color.white.opacity(0.08)))
        .overlay(Capsule().stroke(isPrimary ? Color.clear : HFColors.glassStroke, lineWidth: 1))
        .clipShape(Capsule())
    }
}
