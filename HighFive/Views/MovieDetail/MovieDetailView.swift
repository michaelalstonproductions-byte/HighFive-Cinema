import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var streamingStore: HFStreamingStore
    @State private var previewMovie: Movie?
    @State private var showsProtectedDepthPreview = false
    @State private var showsAccessReadiness = false
    @State private var isDetailWorldAwake = false

    private var catalogMovie: Movie {
        streamingStore.movie(id: movie.id) ?? movie
    }

    private var creator: Creator {
        HFMockData.creator(for: catalogMovie)
    }

    private var cast: [String] {
        HFMockData.cast(for: catalogMovie)
    }

    private var relatedTitles: [Movie] {
        streamingStore.relatedMovies(for: catalogMovie)
    }

    private var playbackDescriptor: HFPlaybackDescriptor {
        streamingStore.playbackDescriptor(for: catalogMovie)
    }

    private var entitlementContext: HFPlaybackDescriptorEntitlementContext {
        streamingStore.playbackEntitlementContext(for: catalogMovie)
    }

    private var gatedPlaybackDescriptor: HFPlaybackDescriptorAccessResponse {
        streamingStore.entitlementGatedPlaybackDescriptor(for: catalogMovie)
    }

    private var backendContract: HFBackendPlaybackDescriptorContract {
        streamingStore.backendPlaybackDescriptorContract(for: catalogMovie)
    }

    private var galleryAssets: [String] {
        HFMockData.galleryAssets(for: catalogMovie)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                hero
                overview
                actionPanel
                creatorSection
                relatedSection
                castSection
                gallerySection
            }
            .padding(.bottom, HFSpacing.floatingTabClearance + HFSpacing.tabBarHeight)
        }
        .accessibilityIdentifier("hf.consumer.movieDetail.root")
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 42, height: 42)
                        .background(Color.black.opacity(0.46))
                        .clipShape(Circle())
                }
            }
        }
        .sheet(item: $previewMovie) { movie in
            HFPlayerServiceSheet(movie: movie)
                .environmentObject(streamingStore)
        }
        .sheet(isPresented: $showsProtectedDepthPreview) {
            HighFiveProtectedSpatialPeekBridge()
        }
        .sheet(isPresented: $showsAccessReadiness) {
            accessPlaybackReadinessSheet
        }
        .onAppear {
            guard !isDetailWorldAwake else { return }
            withAnimation(reduceMotion ? .easeInOut(duration: 0.01) : HFSpatialMotionTokens.sceneEntranceAnimation) {
                isDetailWorldAwake = true
            }
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            detailArtwork
                .frame(height: 620)
                .scaleEffect(reduceMotion ? 1 : (isDetailWorldAwake ? 1.04 : 1.0))
                .offset(x: reduceMotion ? 0 : (isDetailWorldAwake ? -8 : 8), y: reduceMotion ? 0 : (isDetailWorldAwake ? -5 : 4))
                .accessibilityIdentifier("hf.spatial.movieDetail.scene")

            detailArtwork
                .frame(width: 164, height: 238)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(HFColors.gold.opacity(0.48), lineWidth: 1)
                )
                .rotationEffect(.degrees(reduceMotion ? 0 : (isDetailWorldAwake ? 4 : -2)))
                .offset(x: reduceMotion ? 136 : (isDetailWorldAwake ? 146 : 130), y: reduceMotion ? -172 : (isDetailWorldAwake ? -182 : -160))
                .shadow(color: HFColors.amberGlow.opacity(0.28), radius: 28, x: 0, y: 18)

            LinearGradient(
                colors: [.clear, HFColors.warmGlow.opacity(0.22), HFColors.background.opacity(0.90), HFColors.background],
                startPoint: .top,
                endPoint: .bottom
            )

            HFDepthContourOverlay(color: HFColors.cyanGlow)
                .opacity(0.72)

            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top) {
                    Text(catalogMovie.isOriginal ? "HIGHFIVE ORIGINAL" : "FEATURED TITLE")
                        .font(HFTypography.micro)
                        .foregroundStyle(.black)
                        .padding(.horizontal, HFSpacing.sm)
                        .frame(height: 28)
                        .background(HFColors.goldGradient)
                        .clipShape(Capsule())

                    Spacer()
                }

                Spacer()

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text(catalogMovie.title)
                        .font(HFTypography.heroTitle)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.62)
                    Text(catalogMovie.subtitle)
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textSecondary)
                        .lineLimit(2)

                    metadataChips

                    HStack(spacing: HFSpacing.sm) {
                        HFEnergyAction(title: catalogMovie.isComingSoon ? "Preview" : "Watch", systemImage: "play.fill", style: .gold) {
                            streamingStore.markStartedWatching(catalogMovie)
                            previewMovie = catalogMovie
                        }
                        .accessibilityIdentifier("hf.spatial.movieDetail.watch")
                        .hfSpatialFocalHandoff("hf.spatial.handoff.movieToPlayer")

                        HFEnergyAction(title: "Depth", systemImage: "cube.transparent", style: .cyan) {
                            showsProtectedDepthPreview = true
                        }
                        .accessibilityLabel("Open Depth and Peek local preview")
                        .accessibilityIdentifier("hf.spatial.movieDetail.depth")
                    }

                    NavigationLink {
                        ConnectHubView(initialMode: .watchRoom, movie: catalogMovie)
                    } label: {
                        Label("Watch Together", systemImage: "person.2.fill")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.80)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(Color.white.opacity(0.10))
                            .overlay(Capsule().stroke(HFColors.cyanGlow.opacity(0.36), lineWidth: 1))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.movieDetail.watchTogether")
                    .accessibilityIdentifier("hf.route.movieDetailToConnect")
                }
            }
            .padding(HFSpacing.lg)
        }
        .shadow(color: HFColors.amberGlow.opacity(0.22), radius: 24, x: 0, y: 16)
        .frame(height: 620)
        .clipped()
        .hfSpatialSceneEntrance(isActive: isDetailWorldAwake, reduceMotion: reduceMotion)
        .accessibilityIdentifier("hf.spatial.movieDetail")
        .hfSpatialFocalHandoff(
            "hf.spatial.handoff.homeToMovie",
            "hf.spatial.handoff.movieToPlayer",
            "hf.spatial.handoff.movieToConnect",
            "hf.spatial.handoff.movieToCreator"
        )
    }

    private var metadataChips: some View {
        HStack(spacing: HFSpacing.xs) {
            ForEach([catalogMovie.year, catalogMovie.rating, catalogMovie.duration], id: \.self) { value in
                Text(value)
                    .font(HFTypography.caption)
                    .foregroundStyle(value == catalogMovie.year ? .black : HFColors.textPrimary)
                    .padding(.horizontal, HFSpacing.sm)
                    .frame(height: 30)
                    .background(value == catalogMovie.year ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(Color.white.opacity(0.15)))
                    .clipShape(Capsule())
            }
        }
    }

    private var overview: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            Text("Overview")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .textCase(.uppercase)
            Text(catalogMovie.synopsis)
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            genreTags
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.movieDetail.primaryActions")
    }

    private var genreTags: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 92), spacing: HFSpacing.xs)], alignment: .leading, spacing: HFSpacing.xs) {
            ForEach(catalogMovie.genres, id: \.self) { genre in
                Text(genre)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.gold)
                    .padding(.horizontal, HFSpacing.sm)
                    .frame(maxWidth: .infinity)
                    .frame(height: 34)
                    .background(HFColors.gold.opacity(0.12))
                    .overlay(Capsule().stroke(HFColors.goldStroke, lineWidth: 1))
                    .clipShape(Capsule())
            }
        }
    }

    private var actionPanel: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                Text("Keep the film close")
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)

                HStack(spacing: HFSpacing.sm) {
                    detailAction(
                        title: streamingStore.isSaved(catalogMovie) ? "Saved" : "Save",
                        systemImage: streamingStore.isSaved(catalogMovie) ? "checkmark" : "plus",
                        action: { streamingStore.toggleSaved(catalogMovie) }
                    )
                    detailAction(
                        title: streamingStore.isDownloaded(catalogMovie) ? "Offline" : "Offline",
                        systemImage: streamingStore.isDownloaded(catalogMovie) ? "checkmark.circle.fill" : "arrow.down.circle.fill",
                        action: {
                            if streamingStore.isDownloaded(catalogMovie) {
                                streamingStore.removeOfflineAsset(for: catalogMovie)
                            } else {
                                streamingStore.queueOfflineAsset(for: catalogMovie)
                            }
                        }
                    )
                }

                HStack(spacing: HFSpacing.sm) {
                    NavigationLink {
                        ConnectHubView(initialMode: .watchRoom, movie: catalogMovie)
                    } label: {
                        contextualAction(title: "Watch Together", systemImage: "person.2.fill")
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.movieDetail.watchTogether")
                    .accessibilityIdentifier("hf.route.movieDetailToConnect")

                    NavigationLink {
                        CreatorStudioView()
                    } label: {
                        contextualAction(title: "Build Release", systemImage: "shippingbox.fill")
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.spatial.handoff.movieToCreator")
                    .accessibilityIdentifier("hf.route.movieDetailToCreator")

                    Button {
                        showsAccessReadiness = true
                    } label: {
                        VStack(spacing: HFSpacing.xs) {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 18, weight: .black))
                            Text("Access")
                                .font(HFTypography.caption)
                                .lineLimit(1)
                        }
                        .foregroundStyle(HFColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 72)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                                .stroke(HFColors.glassStroke, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Access and Playback Readiness")
                }
            }
            .padding(HFSpacing.md)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func contextualAction(title: String, systemImage: String) -> some View {
        VStack(spacing: HFSpacing.xs) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .black))
            Text(title)
                .font(HFTypography.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .foregroundStyle(HFColors.textPrimary)
        .frame(maxWidth: .infinity)
        .frame(height: 72)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(HFColors.glassStroke, lineWidth: 1)
        )
    }

    private var playbackStatusPanel: some View {
        let providerStatus = streamingStore.streamingProviderStatus(for: catalogMovie)
        return HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.26)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: providerStatus.systemImage)
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(.black)
                        .frame(width: 48, height: 48)
                        .background(HFColors.goldGradient)
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text("Streaming Provider")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(providerStatus.status.statusLabel)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)
                        Text(providerStatus.detail)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                HFPlaybackBoundaryRow(
                    title: playbackDescriptor.boundary.title,
                    detail: playbackDescriptor.boundary.detail,
                    status: playbackDescriptor.status.statusLabel,
                    identifier: "hf.playback.descriptorBoundary"
                )
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.movieDetail.playbackStatus")
        .accessibilityIdentifier(providerStatus.accessibilityIdentifier)
    }

    private var entitlementStatusPanel: some View {
        let entitlementStatus = streamingStore.entitlementRuntimeStatus
        let accessRule = streamingStore.storeKitAccessRule(for: catalogMovie)
        let entitlementContext = streamingStore.playbackEntitlementContext(for: catalogMovie)
        let gatedDescriptor = streamingStore.entitlementGatedPlaybackDescriptor(for: catalogMovie)
        let backendContract = streamingStore.backendPlaybackDescriptorContract(for: catalogMovie)
        let episodeMappings = streamingStore.storeKitEpisodeMappings(for: catalogMovie)
        return HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.24)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(.black)
                        .frame(width: 48, height: 48)
                        .background(HFColors.goldGradient)
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text("Access")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(entitlementStatus.statusLabel)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)
                            .accessibilityIdentifier("hf.entitlement.status")
                        Text("Watch Now remains available for local preview. No live purchase or paywall is active.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                HFPlaybackBoundaryRow(
                    title: "Local Preview Access",
                    detail: "Payment Provider Not Connected Yet",
                    status: entitlementStatus.accessState.statusLabel,
                    identifier: "hf.entitlement.localPreviewAccess"
                )

                HFPlaybackBoundaryRow(
                    title: "Restore Purchases Not Active Yet",
                    detail: "No restore purchase implementation is active in this staging foundation.",
                    status: entitlementStatus.restoreState.statusLabel,
                    identifier: "hf.entitlement.restoreNotActive"
                )

                HFPlaybackBoundaryRow(
                    title: "StoreKit product mapping",
                    detail: "\(accessRule.currentMovieID) -> \(accessRule.productReference.productIdentifier.rawValue)",
                    status: accessRule.productReference.readiness.statusLabel,
                    identifier: "hf.movieDetail.storeKitMapping"
                )

                HFPlaybackBoundaryRow(
                    title: "Paywall readiness",
                    detail: "Readiness only. No live Buy, Subscribe, Pay, Purchase, Rent, or restore action is enabled.",
                    status: accessRule.paywallReadiness.statusLabel,
                    identifier: "hf.movieDetail.paywallReadiness"
                )

                HFPlaybackBoundaryRow(
                    title: "Product ID required",
                    detail: accessRule.detail,
                    status: accessRule.productReference.readiness.statusLabel,
                    identifier: "hf.entitlement.productIDRequired"
                )

                HFPlaybackBoundaryRow(
                    title: "Playback descriptor requires entitlement",
                    detail: entitlementContext.detail,
                    status: entitlementContext.playbackAccessDecision.statusLabel,
                    identifier: "hf.entitlement.playbackAccessDecision"
                )

                HFPlaybackBoundaryRow(
                    title: "Entitlement gate required",
                    detail: gatedDescriptor.gate.detail,
                    status: gatedDescriptor.gateStatus.statusLabel,
                    identifier: "hf.movieDetail.entitlementGate"
                )

                HFPlaybackBoundaryRow(
                    title: "Backend descriptor required",
                    detail: gatedDescriptor.request.backendRequirement.detail,
                    status: gatedDescriptor.request.backendRequirement.status.statusLabel,
                    identifier: "hf.movieDetail.backendDescriptorRequired"
                )

                HFPlaybackBoundaryRow(
                    title: "Backend entitlement validation required",
                    detail: "Server entitlement validation pending for \(backendContract.entitlementValidationRequest.movieID).",
                    status: backendContract.entitlementValidationResponse.entitlementStatus.statusLabel,
                    identifier: "hf.movieDetail.backendEntitlementValidation"
                )

                HFPlaybackBoundaryRow(
                    title: "Backend playback descriptor endpoint required",
                    detail: backendContract.playbackDescriptorRequest.endpoint.detail,
                    status: backendContract.playbackDescriptorResponse.detail,
                    identifier: "hf.movieDetail.backendPlaybackDescriptor"
                )

                HFPlaybackBoundaryRow(
                    title: "Staging backend not configured",
                    detail: "Check Staging Access uses runtime endpoint config only and keeps Local Preview fallback active when config is missing.",
                    status: streamingStore.backendEntitlementRequestState.statusLabel,
                    identifier: "hf.movieDetail.stagingEntitlementState"
                )

                HFPlaybackBoundaryRow(
                    title: "Server-side Cloudflare signing required",
                    detail: "No Cloudflare token in app. Descriptor references are not shown or persisted.",
                    status: streamingStore.backendPlaybackDescriptorRequestState.statusLabel,
                    identifier: "hf.movieDetail.stagingDescriptorState"
                )

                Button {
                    Task {
                        await streamingStore.refreshEntitlementAndPlaybackDescriptor(for: catalogMovie)
                    }
                } label: {
                    Label(
                        streamingStore.canRunStagingEntitlementPlaybackCheck ? "Check Staging Access" : "Review Backend Readiness",
                        systemImage: "checkmark.shield.fill"
                    )
                    .font(HFTypography.smallAction)
                    .foregroundStyle(streamingStore.canRunStagingEntitlementPlaybackCheck ? .black : HFColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(streamingStore.canRunStagingEntitlementPlaybackCheck ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(Color.white.opacity(0.08)))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(!streamingStore.canRunStagingEntitlementPlaybackCheck)
                .accessibilityIdentifier("hf.movieDetail.stagingEntitlementAction")

                HFPlaybackBoundaryRow(
                    title: "Playback descriptor unavailable",
                    detail: "Local Preview fallback active",
                    status: backendContract.policy.localFallbackPolicy,
                    identifier: "hf.playback.descriptorBoundary"
                )

                HFPlaybackBoundaryRow(
                    title: "Cloudflare descriptor not connected",
                    detail: "Cloudflare descriptor ready only after backend descriptor and entitlement validation are configured.",
                    status: gatedDescriptor.cloudflareState.statusLabel,
                    identifier: "hf.movieDetail.cloudflareDescriptorState"
                )

                HFPlaybackBoundaryRow(
                    title: "Cloudflare playback requires backend descriptor",
                    detail: entitlementContext.cloudflareReference.detail,
                    status: entitlementContext.cloudflareReference.statusLabel,
                    identifier: "hf.streaming.cloudflarePlaybackReference"
                )

                HFPlaybackBoundaryRow(
                    title: "No Cloudflare token in app",
                    detail: "Backend-mediated playback only",
                    status: gatedDescriptor.auditContext.localFallback,
                    identifier: "hf.playback.descriptorBoundary"
                )

                if !episodeMappings.isEmpty {
                    HFPlaybackBoundaryRow(
                        title: "Episode Product IDs",
                        detail: "\(episodeMappings.count) Paranormall episode product IDs mapped from source paywall.",
                        status: "Mapped",
                        identifier: "hf.entitlement.episodeProductIDs"
                    )
                }

                HFPlaybackBoundaryRow(
                    title: "Server Entitlement Validation Required",
                    detail: entitlementStatus.boundary.detail,
                    status: "Required",
                    identifier: "hf.entitlement.serverValidationRequired"
                )

                HFPlaybackBoundaryRow(
                    title: entitlementStatus.boundary.title,
                    detail: "Review Access Readiness",
                    status: entitlementStatus.paymentProviderLabel,
                    identifier: "hf.movieDetail.paymentBoundary"
                )
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.movieDetail.entitlementStatus")
    }

    private var downloadBoundaryPanel: some View {
        let eligibility = streamingStore.downloadEligibility(for: catalogMovie)
        return HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.24)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(.black)
                        .frame(width: 48, height: 48)
                        .background(HFColors.goldGradient)
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text("Offline Preview")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(eligibility.statusLabel)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)
                            .accessibilityIdentifier("hf.movieDetail.downloadEligibility")
                        Text("Real downloads disabled")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier("hf.downloads.realDownloadsDisabled")
                    }
                }

                HFPlaybackBoundaryRow(
                    title: "Media Source Required",
                    detail: "Playback descriptor approval is required first.",
                    status: "Required",
                    identifier: "hf.downloads.mediaSourceRequired"
                )

                HFPlaybackBoundaryRow(
                    title: "License Required",
                    detail: eligibility.policy.licensePolicy.statusLabel,
                    status: "Required",
                    identifier: "hf.downloads.licenseRequired"
                )

                HFPlaybackBoundaryRow(
                    title: "Entitlement Required",
                    detail: "Server entitlement validation is required first.",
                    status: "Required",
                    identifier: "hf.downloads.entitlementRequired"
                )

                HFPlaybackBoundaryRow(
                    title: "Download Provider Not Connected Yet",
                    detail: eligibility.policy.boundary.title,
                    status: eligibility.policy.providerStatus.statusLabel,
                    identifier: "hf.downloads.downloadProviderNotConnected"
                )

                Button {} label: {
                    Text("Review Download Eligibility")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(HFColors.goldGradient)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.movieDetail.downloadBoundary")
    }

    private var accessPlaybackReadinessSheet: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: HFSpacing.lg) {
                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Access & Playback Readiness")
                            .font(HFTypography.title)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Local preview remains available while provider, entitlement, and download boundaries stay separated from the title world.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, HFSpacing.screenHorizontal)

                    playbackStatusPanel
                    entitlementStatusPanel
                    downloadBoundaryPanel
                }
                .padding(.top, HFSpacing.lg)
                .padding(.bottom, HFSpacing.xxl)
            }
            .background(HFColors.screenBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showsAccessReadiness = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(HFColors.textPrimary)
                            .frame(width: 38, height: 38)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close readiness")
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func detailAction(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: HFSpacing.xs) {
                Image(systemName: systemImage)
                    .font(.system(size: 19, weight: .black))
                    .foregroundStyle(HFColors.gold)
                Text(title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 82)
            .background(Color.white.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                    .stroke(HFColors.glassStroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var localDepthPreviewSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "cube.transparent")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(.black)
                        .frame(width: 50, height: 50)
                        .background(HFColors.goldGradient)
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Local Depth Preview")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Preview the protected Depth + Peek experience locally. No streaming provider connected.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Button {
                    showsProtectedDepthPreview = true
                } label: {
                    Label("Try Depth + Peek", systemImage: "cube.transparent")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(HFColors.goldGradient)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.movieDetail.localDepthPreview")
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.movieDetail.localDepthPreview")
    }

    private var creatorSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Presented By", actionTitle: nil)
            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                HStack(spacing: HFSpacing.md) {
                    Image(systemName: "sparkles.tv.fill")
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(.black)
                        .frame(width: 58, height: 58)
                        .background(HFColors.goldGradient)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text(creator.name)
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(creator.role)
                            .font(HFTypography.body)
                            .foregroundStyle(HFColors.textSecondary)
                    }
                    Spacer()
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var relatedSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "More Like This", actionTitle: nil)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    ForEach(relatedTitles) { related in
                        NavigationLink(value: related) {
                            HFPosterCard(movie: related, width: HFSpacing.posterRailWidth, showProgress: related.progress != nil)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
        .accessibilityIdentifier("hf.consumer.movieDetail.moreLikeThis")
    }

    private var castSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Cast & Creators", actionTitle: nil)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HFSpacing.sm) {
                    ForEach(cast, id: \.self) { name in
                        HFGlassPanel(cornerRadius: 18) {
                            VStack(spacing: HFSpacing.sm) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(HFColors.gold)
                                    .frame(width: 62, height: 62)
                                    .background(HFColors.charcoalLight)
                                    .clipShape(Circle())

                                Text(name)
                                    .font(HFTypography.caption)
                                    .foregroundStyle(HFColors.textPrimary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }
                            .frame(width: 112)
                            .padding(HFSpacing.sm)
                        }
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
    }

    @ViewBuilder
    private var gallerySection: some View {
        if !galleryAssets.isEmpty {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                HFSectionHeader(title: "Scenes", actionTitle: nil)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: HFSpacing.md) {
                        ForEach(galleryAssets, id: \.self) { assetName in
                            if HFPosterAssetHealth.hasImage(named: assetName) {
                                Image(assetName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 230, height: 132)
                                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                                            .stroke(HFColors.stroke, lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, HFSpacing.screenHorizontal)
                }
            }
        }
    }

    @ViewBuilder
    private var detailArtwork: some View {
        if HFPosterAssetHealth.hasImage(named: catalogMovie.backdropAssetName ?? catalogMovie.posterAssetName),
           let assetName = catalogMovie.backdropAssetName ?? catalogMovie.posterAssetName {
            Image(assetName)
                .resizable()
                .scaledToFill()
        } else {
            HFPosterFallback(title: catalogMovie.title)
        }
    }
}

private struct HFPlaybackBoundaryRow: View {
    let title: String
    let detail: String
    let status: String
    let identifier: String

    var body: some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(HFColors.gold)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                Text(title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                Text(detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: HFSpacing.xs)

            Text(status)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.gold)
                .lineLimit(1)
                .minimumScaleFactor(0.66)
                .padding(.horizontal, HFSpacing.xs)
                .frame(height: 24)
                .background(Color.white.opacity(0.08))
                .clipShape(Capsule())
        }
        .accessibilityIdentifier(identifier)
    }
}

enum HFPlayerSurfaceFocus: String, CaseIterable, Identifiable {
    case cinema
    case controls
    case metadata
    case watchTogether
    case creatorCommentary

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .cinema: return "Cinema"
        case .controls: return "Controls"
        case .metadata: return "Metadata"
        case .watchTogether: return "Watch Together"
        case .creatorCommentary: return "Creator Commentary"
        }
    }

    var systemImage: String {
        switch self {
        case .cinema: return "play.rectangle.fill"
        case .controls: return "slider.horizontal.3"
        case .metadata: return "info.circle.fill"
        case .watchTogether: return "person.2.fill"
        case .creatorCommentary: return "quote.bubble.fill"
        }
    }

    var accent: Color {
        switch self {
        case .watchTogether:
            return HFColors.cyanGlow
        case .creatorCommentary:
            return HFColors.violet
        default:
            return HFColors.gold
        }
    }

    var accessibilityIdentifier: String {
        "hf.player.surface.\(rawValue)"
    }
}

struct HFPlayerServiceSheet: View {
    let movie: Movie
    let initialSurface: HFPlayerSurfaceFocus
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var streamingStore: HFStreamingStore
    @State private var showsProtectedDepthPreview = false
    @State private var showsPlayerDetails = false
    @State private var isSceneReady = false
    @State private var selectedSurface: HFPlayerSurfaceFocus

    init(movie: Movie, initialSurface: HFPlayerSurfaceFocus = .cinema) {
        self.movie = movie
        self.initialSurface = initialSurface
        _selectedSurface = State(initialValue: initialSurface)
    }

    private var catalogMovie: Movie {
        streamingStore.movie(id: movie.id) ?? movie
    }

    private var gatedPlaybackDescriptor: HFPlaybackDescriptorAccessResponse {
        streamingStore.entitlementGatedPlaybackDescriptor(for: catalogMovie)
    }

    var body: some View {
        ZStack {
            HFColors.screenBackground
                .ignoresSafeArea()

            atmosphereLayer

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: HFSpacing.lg) {
                    header
                    playerPreview
                    routeSpotlight
                    premiumTimeline
                    floatingControls
                    viewerIntelligenceStrip
                    gatewaySurface
                    metadataSurface
                }
                .padding(HFSpacing.lg)
                .padding(.bottom, HFSpacing.xxl)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showsProtectedDepthPreview) {
            HighFiveProtectedSpatialPeekBridge()
        }
        .sheet(isPresented: $showsPlayerDetails) {
            playerDetailsSheet
        }
        .onAppear {
            guard !isSceneReady else { return }
            withAnimation(reduceMotion ? .easeInOut(duration: 0.01) : HFSpatialMotionTokens.sceneEntranceAnimation) {
                isSceneReady = true
            }
        }
        .hfSpatialSceneEntrance(isActive: isSceneReady, reduceMotion: reduceMotion)
        .hfSpatialFocalHandoff("hf.spatial.handoff.movieToPlayer")
        .accessibilityIdentifier("hf.spatial.player")
    }

    private var atmosphereLayer: some View {
        ZStack {
            RadialGradient(
                colors: [
                    selectedSurface.accent.opacity(reduceTransparency ? 0.14 : 0.24),
                    HFColors.background.opacity(0.82),
                    Color.black
                ],
                center: .topTrailing,
                startRadius: 16,
                endRadius: 520
            )
            LinearGradient(
                colors: [
                    Color.black.opacity(0.24),
                    selectedSurface.accent.opacity(reduceTransparency ? 0.08 : 0.16),
                    Color.black.opacity(0.72)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
        .accessibilityIdentifier("hf.player.atmosphereLayer")
    }

    private var header: some View {
        HStack(alignment: .top, spacing: HFSpacing.md) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Text("HIGHFIVE PLAYER")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.gold)
                Text(catalogMovie.title)
                    .font(HFTypography.display)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                Text("Local Preview destination")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .frame(width: 42, height: 42)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close Player")
        }
        .accessibilityElement(children: .combine)
        .accessibilitySortPriority(10)
        .accessibilityIdentifier("hf.player.header")
    }

    private var playerPreview: some View {
        ZStack(alignment: .bottom) {
            if HFPosterAssetHealth.hasImage(named: catalogMovie.backdropAssetName ?? catalogMovie.posterAssetName),
               let assetName = catalogMovie.backdropAssetName ?? catalogMovie.posterAssetName {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(reduceMotion ? 1 : (isSceneReady ? 1.025 : 1.0))
                    .offset(y: reduceMotion ? 0 : (isSceneReady ? -3 : 5))
            } else {
                HFPosterFallback(title: catalogMovie.title)
            }

            LinearGradient(colors: [.clear, Color.black.opacity(0.86)], startPoint: .top, endPoint: .bottom)

            HFDepthContourOverlay(color: HFColors.cyanGlow)
                .opacity(0.64)

            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .center, spacing: HFSpacing.md) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 58, weight: .black))
                        .foregroundStyle(HFColors.gold)
                        .shadow(color: HFColors.amberGlow.opacity(0.42), radius: 18)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Local Preview")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(catalogMovie.metadataLine)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                    }
                }

                HStack(spacing: HFSpacing.xs) {
                    HFPlayerStatusPill(title: "Cinema Mode", color: HFColors.gold)
                    HFPlayerStatusPill(title: "Local", color: HFColors.cyanGlow)
                    HFPlayerStatusPill(title: gatedPlaybackDescriptor.gateStatus.statusLabel, color: HFColors.gold)
                }
            }
            .padding(HFSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 390)
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous)
                .stroke(HFColors.goldStroke, lineWidth: 1)
        )
        .overlay(alignment: .topLeading) {
            HFSpatialRouteBadge(title: "Movie -> Player", accent: HFColors.gold)
                .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Player frame, \(catalogMovie.title), Local Preview")
        .accessibilitySortPriority(9)
        .accessibilityIdentifier("hf.player.cinematicFrame")
    }

    @ViewBuilder
    private var routeSpotlight: some View {
        switch selectedSurface {
        case .cinema:
            EmptyView()
        case .controls:
            HFOpticalGlassSurface(cornerRadius: 26, strokeColor: HFColors.gold.opacity(0.58)) {
                HStack(spacing: HFSpacing.md) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 48, height: 48)
                        .background(HFColors.gold.opacity(0.14))
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Floating Controls")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Timeline and command deck are active for local preview.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                    }
                }
                .padding(HFSpacing.md)
            }
            .accessibilityIdentifier("hf.player.controlsSpotlight")
        case .metadata:
            metadataSurface
        case .watchTogether:
            gatewayCard(
                title: "Watch Together Gateway",
                detail: "Player routes into the local Connect room for this title.",
                systemImage: "person.2.fill",
                color: HFColors.cyanGlow,
                isSelected: true
            )
            .accessibilityIdentifier("hf.player.watchTogetherGatewaySpotlight")
        case .creatorCommentary:
            gatewayCard(
                title: "Creator Commentary Gateway",
                detail: "Player routes into Creator Studio context without changing playback.",
                systemImage: "quote.bubble.fill",
                color: HFColors.violet,
                isSelected: true
            )
            .accessibilityIdentifier("hf.player.creatorCommentaryGatewaySpotlight")
        }
    }

    private var premiumTimeline: some View {
        HFOpticalGlassSurface(cornerRadius: 28, strokeColor: HFColors.gold.opacity(selectedSurface == .controls ? 0.58 : 0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                HStack {
                    Label("Premium Timeline", systemImage: "waveform.path.ecg")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    Spacer()
                    Text("00:42 / 1:47:00")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.gold)
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.12))
                        Capsule()
                            .fill(HFColors.goldGradient)
                            .frame(width: proxy.size.width * 0.22)
                        Circle()
                            .fill(HFColors.gold)
                            .frame(width: 16, height: 16)
                            .offset(x: max(0, proxy.size.width * 0.22 - 8))
                    }
                }
                .frame(height: 12)
                .accessibilityHidden(true)

                HStack {
                    Text("Chapter 01")
                    Spacer()
                    Text("Opening pull")
                    Spacer()
                    Text("Depth cues ready")
                }
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
            }
            .padding(HFSpacing.md)
        }
        .accessibilityLabel("Premium Timeline, 42 seconds elapsed")
        .accessibilityIdentifier("hf.player.timeline")
    }

    private var floatingControls: some View {
        HFSpatialCommandBar {
            HFEnergyAction(title: "Continue Local Preview", systemImage: "play.fill", style: .gold) {
                streamingStore.markStartedWatching(catalogMovie)
                selectedSurface = .controls
            }
            .accessibilityIdentifier("hf.player.continueLocalPreview")

            HStack(spacing: HFSpacing.sm) {
                HFEnergyAction(title: "Depth + Peek", systemImage: "cube.transparent", style: .cyan) {
                    showsProtectedDepthPreview = true
                    selectedSurface = .controls
                }
                .accessibilityIdentifier("hf.player.depthPeekCTA")

                HFEnergyAction(title: "Player Details", systemImage: "info.circle.fill", style: .glass) {
                    selectedSurface = .metadata
                    showsPlayerDetails = true
                }
                .accessibilityIdentifier("hf.player.details")
            }
        }
        .accessibilityIdentifier("hf.player.floatingControls")
    }

    private var viewerIntelligenceStrip: some View {
        HFOpticalGlassSurface(cornerRadius: 26, strokeColor: HFColors.cyanGlow.opacity(0.34)) {
            HStack(spacing: HFSpacing.sm) {
                HFPlayerInsight(title: "Local Signal", value: "Ready", systemImage: "antenna.radiowaves.left.and.right", color: HFColors.cyanGlow)
                HFPlayerInsight(title: "Best Scene", value: "Opening", systemImage: "sparkles.tv.fill", color: HFColors.gold)
                HFPlayerInsight(title: "Room Fit", value: "3 viewers", systemImage: "person.2.fill", color: HFColors.cyanGlow)
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Viewer Intelligence, Local Signal Ready, Best Scene Opening, Room Fit 3 viewers")
        .accessibilityIdentifier("hf.player.viewerIntelligence")
    }

    private var gatewaySurface: some View {
        HStack(spacing: HFSpacing.md) {
            NavigationLink {
                ConnectHubView(initialMode: .watchRoom)
            } label: {
                gatewayCard(
                    title: "Watch Together",
                    detail: "Open a local room around this title.",
                    systemImage: "person.2.fill",
                    color: HFColors.cyanGlow,
                    isSelected: selectedSurface == .watchTogether
                )
            }
            .buttonStyle(.plain)
            .simultaneousGesture(TapGesture().onEnded { selectedSurface = .watchTogether })
            .accessibilityIdentifier("hf.player.watchTogetherGateway")

            NavigationLink {
                CreatorStudioView()
            } label: {
                gatewayCard(
                    title: "Creator Commentary",
                    detail: "Review the creator context locally.",
                    systemImage: "quote.bubble.fill",
                    color: HFColors.violet,
                    isSelected: selectedSurface == .creatorCommentary
                )
            }
            .buttonStyle(.plain)
            .simultaneousGesture(TapGesture().onEnded { selectedSurface = .creatorCommentary })
            .accessibilityIdentifier("hf.player.creatorCommentaryGateway")
        }
    }

    private func gatewayCard(title: String, detail: String, systemImage: String, color: Color, isSelected: Bool) -> some View {
        HFOpticalGlassSurface(cornerRadius: 28, strokeColor: color.opacity(isSelected ? 0.74 : 0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                Image(systemName: systemImage)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(color)
                    .frame(width: 48, height: 48)
                    .background(color.opacity(0.14))
                    .clipShape(Circle())
                Text(title)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.76)
                Text(detail)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                if isSelected || differentiateWithoutColor {
                    Label(isSelected ? "Selected gateway" : "Gateway", systemImage: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(HFTypography.micro)
                        .foregroundStyle(color)
                }
            }
            .padding(HFSpacing.md)
            .frame(maxWidth: .infinity, minHeight: 190, alignment: .topLeading)
        }
        .hfSpatialSelectionTreatment(isSelected: isSelected, accent: color, reduceMotion: reduceMotion, differentiateWithoutColor: differentiateWithoutColor)
        .accessibilityElement(children: .combine)
        .accessibilityValue(isSelected ? "Selected" : "Available")
    }

    private var metadataSurface: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(selectedSurface == .metadata ? 0.56 : 0.26)) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                Label("Premium Metadata", systemImage: "rectangle.stack.fill")
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)

                Text("Local preview uses the on-device catalog surface for this title. Access, source, and room context remain reviewable without changing playback systems.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.sm) {
                    metadataItem(title: "Format", value: "Cinematic")
                    metadataItem(title: "Preview", value: "Local")
                    metadataItem(title: "Access", value: gatedPlaybackDescriptor.gateStatus.statusLabel)
                    metadataItem(title: "Room", value: "Ready")
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityIdentifier("hf.player.metadataSurface")
    }

    private func metadataItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title.uppercased())
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
            Text(value)
                .font(HFTypography.caption.weight(.bold))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(HFSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var playerDetailsSheet: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: HFSpacing.lg) {
                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Player Details")
                            .font(HFTypography.title)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Local preview, viewer context, and access state stay secondary to the cinematic frame.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                    }
                    metadataSurface
                    viewerIntelligenceStrip
                }
                .padding(HFSpacing.lg)
            }
            .background(HFColors.screenBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showsPlayerDetails = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(HFColors.textPrimary)
                            .frame(width: 38, height: 38)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close player details")
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct HFPlayerStatusPill: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(HFTypography.micro)
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, HFSpacing.sm)
            .frame(height: 26)
            .background(color.opacity(0.12))
            .overlay(Capsule().stroke(color.opacity(0.32), lineWidth: 1))
            .clipShape(Capsule())
    }
}

private struct HFPlayerInsight: View {
    let title: String
    let value: String
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(color)
            Text(title)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(value)
                .font(HFTypography.caption.weight(.bold))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
