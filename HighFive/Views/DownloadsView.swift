import SwiftUI

struct DownloadsView: View {
    @EnvironmentObject private var streamingStore: HFStreamingStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    var onFindMore: (() -> Void)?
    @State private var isSceneAwake = false
    @State private var showsInspector = false
    @State private var didRequestOfflineRuntime = false

    private let forcesEmptyState: Bool

    init(onFindMore: (() -> Void)? = nil) {
        let arguments = ProcessInfo.processInfo.arguments
        self.onFindMore = onFindMore
        forcesEmptyState = arguments.contains("--hf-start-downloads-empty")
    }

    private var usesFallbackLayout: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    private var shouldRunOfflineRuntime: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-download-offline-sync")
            || arguments.contains("--hf-download-storage")
    }

    private var downloads: [Movie] {
        forcesEmptyState ? [] : streamingStore.downloadedMovies
    }

    private var selectedMovie: Movie {
        downloads.first ?? streamingStore.continueWatchingMovie
    }

    private var downloadPolicyStatus: HFDownloadRuntimeStatus {
        streamingStore.downloadPolicyRuntimeStatus
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.sectionGap) {
                header
                if shouldRunOfflineRuntime {
                    viewerOfflineRuntimeSurface
                }
                capsuleWorld
                if forcesEmptyState {
                    compactNotice("No local offline preview titles yet. Browse HighFive to mark stories for nearby viewing.")
                }
                premiumCapsuleStats
                if !shouldRunOfflineRuntime {
                    viewerOfflineRuntimeSurface
                }
                localOfflineShelf
                if downloads.isEmpty {
                    emptyShelf
                } else {
                    secondaryTitles
                }
            }
            .padding(.top, HFSpacing.screenTop)
            .padding(.bottom, HFResponsiveFit.floatingTabContentClearance(dynamicTypeSize: dynamicTypeSize))
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .sheet(isPresented: $showsInspector) {
            downloadInspector
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
            guard shouldRunOfflineRuntime, !didRequestOfflineRuntime else { return }
            didRequestOfflineRuntime = true
            await streamingStore.runViewerLibraryProgressOfflineFixture(for: selectedMovie)
        }
        .accessibilityIdentifier("hf.spatial.downloads")
        .accessibilityIdentifier("hf.streaming.premium.downloadsCapsule")
        .accessibilityIdentifier("hf.consumer.downloads.root")
        .accessibilityIdentifier("hf.downloads.screen")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Text("Downloads")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
            Text("Offline Preview Capsule")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilitySortPriority(4)
    }

    private var capsuleWorld: some View {
        VStack(spacing: HFSpacing.md) {
            offlineCapsule
                .accessibilitySortPriority(3)

            HFSpatialActionCluster {
                NavigationLink(value: selectedMovie) {
                    Label("Continue Local Preview", systemImage: "play.fill")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 52)
                        .background(HFColors.goldGradient)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.downloads.continueLocalPreview")
                .accessibilityIdentifier("hf.route.downloadsToMovieDetail")

                HStack(spacing: HFSpacing.sm) {
                    HFEnergyAction(title: "Remove Local Preview", systemImage: "xmark.circle", style: .glass) {
                        if streamingStore.isDownloaded(selectedMovie) {
                            streamingStore.toggleDownload(selectedMovie)
                        }
                    }
                    HFEnergyAction(title: "Open Download Inspector", systemImage: "slider.horizontal.3", style: .glass) {
                        showsInspector = true
                    }
                    .accessibilityIdentifier("hf.downloads.inspector")
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .hfSpatialSceneEntrance(isActive: isSceneAwake, reduceMotion: reduceMotion)
        .accessibilityIdentifier("hf.spatial.accessibility.largeType")
    }

    private var offlineCapsule: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius + 10, strokeColor: HFColors.cyanGlow.opacity(0.42)) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous)
                    .fill(reduceTransparency ? Color.black.opacity(0.96) : Color.black.opacity(0.56))
                HFDepthContourOverlay(color: HFColors.cyanGlow.opacity(0.64))
                    .opacity(0.28)

                HStack(alignment: .center, spacing: HFSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(HFColors.cyanGlow.opacity(0.16))
                            .frame(width: usesFallbackLayout ? 118 : 142, height: usesFallbackLayout ? 118 : 142)
                            .blur(radius: reduceMotion ? 0 : 2)
                        HFPosterCard(movie: selectedMovie, width: usesFallbackLayout ? 94 : 112, showTitle: false, posterOnly: true)
                            .shadow(color: HFColors.cyanGlow.opacity(0.22), radius: 22, x: 0, y: 14)
                    }

                    VStack(alignment: .leading, spacing: HFSpacing.sm) {
                        Text("OFFLINE PREVIEW")
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.cyanGlow)
                            .accessibilityIdentifier("hf.downloads.offlinePreview")
                        Text(selectedMovie.title)
                            .font(HFTypography.title)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.62)
                            .accessibilityIdentifier("hf.spatial.downloads.selectedTitle")
                        Text("Local Offline Shelf")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .accessibilityIdentifier("hf.downloads.localOfflineShelf")
                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            statusPill("Local only", color: HFColors.cyanGlow, identifier: "hf.downloads.localOnlyBoundary")
                            Text("No real media file")
                                .font(HFTypography.micro)
                                .foregroundStyle(HFColors.gold)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                                .minimumScaleFactor(0.78)
                                .accessibilityIdentifier("hf.downloads.realDownloadsNotActive")
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(HFSpacing.md)
            }
            .frame(height: usesFallbackLayout ? 254 : 284)
            .padding(HFSpacing.md)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Offline Preview Capsule for \(selectedMovie.title). Real downloads are not active yet.")
        .accessibilityIdentifier("hf.spatial.downloads.capsule")
        .accessibilityIdentifier("hf.streaming.premium.downloadsCapsule")
    }

    private var premiumCapsuleStats: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 118), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
            capsuleStat(title: "Shelf", value: "\(downloads.count)", systemImage: "rectangle.stack.fill", color: HFColors.cyanGlow)
            capsuleStat(title: "Preview", value: "Local", systemImage: "play.rectangle.fill", color: HFColors.gold)
            capsuleStat(title: "Storage", value: "Visual", systemImage: "internaldrive.fill", color: HFColors.violet)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var viewerOfflineRuntimeSurface: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.cyanGlow.opacity(0.32)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "externaldrive.badge.checkmark")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(HFColors.cyanGlow)
                        .frame(width: 50, height: 50)
                        .background(HFColors.cyanGlow.opacity(0.16))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Offline Download Runtime")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                            .accessibilityIdentifier("hf.viewer.offline.runtime")
                        Text(streamingStore.viewerLibraryRuntimeSnapshot.detail)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    Text(streamingStore.viewerLibraryRuntimeSnapshot.statusLabel)
                        .font(HFTypography.micro.weight(.bold))
                        .foregroundStyle(HFColors.cyanGlow)
                        .padding(.horizontal, HFSpacing.xs)
                        .frame(minHeight: 26)
                        .background(HFColors.cyanGlow.opacity(0.12))
                        .clipShape(Capsule())
                }

                if streamingStore.viewerOfflineDownloadRecords.isEmpty {
                    compactNotice("No synced offline records yet. Local offline preview remains available.")
                        .padding(.horizontal, -HFSpacing.screenHorizontal)
                } else {
                    VStack(spacing: HFSpacing.xs) {
                        ForEach(streamingStore.viewerOfflineDownloadRecords.prefix(4)) { record in
                            inspectorRow(
                                title: record.title,
                                detail: "\(record.state) • \(record.storageState) • \(Self.byteCount(record.bytes))",
                                status: record.entitlementState,
                                color: HFColors.cyanGlow,
                                identifier: "hf.viewer.offline.record.\(record.movieID)"
                            )
                        }
                    }
                    .accessibilityIdentifier("hf.viewer.offline.records")
                }
            }
            .padding(HFSpacing.md)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.downloads.offlineRuntime")
    }

    private static func byteCount(_ bytes: Int) -> String {
        guard bytes > 0 else { return "Local" }
        return ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file)
    }

    private func capsuleStat(title: String, value: String, systemImage: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: systemImage)
                .font(HFIconography.symbolFont(size: HFIconography.controlIconSize, weight: .black))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(color)
                .frame(width: HFIconography.actionIconFrame)
            Text(value)
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
            Text(title)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.md)
        .background(Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(color.opacity(0.26), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }

    private var localOfflineShelf: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Local Offline Shelf", actionTitle: "\(downloads.count)")
            if downloads.isEmpty {
                compactNotice("No local offline preview titles yet. Browse HighFive to mark stories for nearby viewing.")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(alignment: .top, spacing: HFSpacing.md) {
                        ForEach(downloads) { movie in
                            NavigationLink(value: movie) {
                                HFPosterCard(movie: movie, width: 132, showProgress: movie.progress != nil)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("hf.route.downloadsToMovieDetail")
                        }
                    }
                    .padding(.horizontal, HFSpacing.screenHorizontal)
                }
            }
        }
        .accessibilityIdentifier("hf.downloads.localOfflineShelf")
    }

    private var secondaryTitles: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Nearby Stories", actionTitle: "Local")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: HFSpacing.posterGridWidth), spacing: HFSpacing.md)], alignment: .leading, spacing: HFSpacing.lg) {
                ForEach(downloads) { movie in
                    NavigationLink(value: movie) {
                        HFPosterCard(movie: movie, width: HFSpacing.posterGridWidth, showMetadata: true, showProgress: movie.progress != nil)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.route.downloadsToMovieDetail")
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var emptyShelf: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.cyanGlow.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 34, weight: .black))
                    .foregroundStyle(HFColors.cyanGlow)
                Text("Local Offline Shelf")
                    .font(HFTypography.section)
                    .foregroundStyle(HFColors.textPrimary)
                Text("Offline Preview keeps the experience local. Real Downloads Not Active Yet.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                HFEnergyAction(title: "Browse Local Catalog", systemImage: "magnifyingglass", style: .gold) {
                    onFindMore?()
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var downloadInspector: some View {
        let status = downloadPolicyStatus
        return NavigationStack {
            HFSpatialInspectorChrome(
                title: "Download Inspector",
                detail: "Offline state is a local preview. No provider media source or real file storage is active.",
                systemImage: "arrow.down.circle.fill",
                accent: HFColors.cyanGlow
            ) {
                VStack(spacing: HFSpacing.xs) {
                    inspectorRow(title: "Local Offline Shelf", detail: "\(downloads.count) local preview titles.", status: "Local", color: HFColors.cyanGlow, identifier: "hf.downloads.localOfflineShelf")
                    inspectorRow(title: "Offline Preview", detail: status.detail, status: status.statusLabel, color: HFColors.cyanGlow, identifier: "hf.downloads.offlinePreview")
                    inspectorRow(title: "Real Downloads Not Active Yet", detail: "No background media transfer is active in this build.", status: "Not Active Yet", color: HFColors.gold, identifier: "hf.downloads.realDownloadsNotActive")
                    inspectorRow(title: "Download Policy Not Configured", detail: status.policy.boundary.title, status: status.policy.actionReadiness.statusLabel, color: HFColors.gold, identifier: "hf.downloads.policyStatus")
                    inspectorRow(title: "Provider media source required", detail: "Playback descriptor approval is required first.", status: "Required", color: HFColors.textSecondary, identifier: "hf.downloads.providerNotConnected")
                    inspectorRow(title: "Entitlement required", detail: "Server entitlement validation is required before provider media access.", status: status.offlineLicenseState.statusLabel, color: HFColors.textSecondary, identifier: "hf.downloads.entitlementRequired")
                    inspectorRow(title: "Expiration-policy readiness", detail: status.policy.expirationPolicy.statusLabel, status: "Readiness", color: HFColors.textSecondary, identifier: "hf.downloads.expirationPolicy")
                    inspectorRow(title: "Storage-policy readiness", detail: status.storagePressureState.statusLabel, status: "Readiness", color: HFColors.textSecondary, identifier: "hf.downloads.storagePolicy")
                    inspectorRow(title: "No real media file", detail: "Local preview state does not create a stored media file.", status: "No file", color: HFColors.textSecondary, identifier: "hf.downloads.noRealMediaFile")
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
        .accessibilityIdentifier("hf.downloads.inspector")
    }

    private func compactNotice(_ message: String) -> some View {
        HFContentStateCard(
            kind: .offline,
            title: "Offline preview placeholder",
            message: message,
            isCompact: true
        )
            .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func statusPill(_ title: String, color: Color, identifier: String) -> some View {
        Text(title)
            .font(HFTypography.micro)
            .foregroundStyle(color)
            .padding(.horizontal, HFSpacing.xs)
            .frame(minHeight: 24)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
            .accessibilityIdentifier(identifier)
    }

    private func inspectorRow(title: String, detail: String, status: String, color: Color, identifier: String) -> some View {
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
                .foregroundStyle(color)
                .padding(.horizontal, HFSpacing.xs)
                .frame(minHeight: 24)
                .background(color.opacity(0.12))
                .clipShape(Capsule())
        }
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityIdentifier(identifier)
    }
}
