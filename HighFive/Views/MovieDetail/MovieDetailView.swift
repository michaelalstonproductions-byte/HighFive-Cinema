import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var streamingStore: HFStreamingStore
    @State private var previewMovie: Movie?
    @State private var showsProtectedDepthPreview = false

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

    private var galleryAssets: [String] {
        HFMockData.galleryAssets(for: catalogMovie)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                hero
                overview
                actionPanel
                localDepthPreviewSection
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
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            detailArtwork
                .frame(height: 590)
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous))

            LinearGradient(
                colors: [.clear, HFColors.warmGlow.opacity(0.26), HFColors.background.opacity(0.92), HFColors.background],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous))

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

                    HFPosterCard(movie: catalogMovie, width: 94, showTitle: false, showProgress: catalogMovie.progress != nil)
                        .rotationEffect(.degrees(7))
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
                        HFButton(catalogMovie.isComingSoon ? "Preview" : "Watch Now", systemImage: "play.fill") {
                            streamingStore.markStartedWatching(catalogMovie)
                            previewMovie = catalogMovie
                        }
                        .accessibilityIdentifier("hf.consumer.movieDetail.watchNow")
                        .accessibilityIdentifier("hf.route.watchNow")

                        Button {
                            streamingStore.toggleSaved(catalogMovie)
                        } label: {
                            Image(systemName: streamingStore.isSaved(catalogMovie) ? "checkmark" : "plus")
                                .font(.system(size: 18, weight: .black))
                                .foregroundStyle(HFColors.textPrimary)
                                .frame(width: 54, height: 54)
                                .background(Color.white.opacity(0.14))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(streamingStore.isSaved(catalogMovie) ? "Remove from My List" : "Add to My List")
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous)
                .stroke(HFColors.gold.opacity(0.42), lineWidth: 1)
        )
        .shadow(color: HFColors.amberGlow.opacity(0.22), radius: 24, x: 0, y: 16)
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .padding(.top, HFSpacing.xxl)
        .accessibilityIdentifier("hf.movieDetail.signatureHero")
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
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                Label("Ready for your shelf", systemImage: "bookmark.fill")
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)

                HStack(spacing: HFSpacing.sm) {
                    detailAction(
                        title: streamingStore.isSaved(catalogMovie) ? "Saved" : "My List",
                        systemImage: streamingStore.isSaved(catalogMovie) ? "checkmark" : "plus",
                        action: { streamingStore.toggleSaved(catalogMovie) }
                    )
                    detailAction(
                        title: streamingStore.isDownloaded(catalogMovie) ? "Offline" : "Download",
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

                Text("My List, progress, and downloads update instantly across your profile.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
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

struct HFPlayerServiceSheet: View {
    let movie: Movie
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var streamingStore: HFStreamingStore
    @State private var showsProtectedDepthPreview = false

    private var catalogMovie: Movie {
        streamingStore.movie(id: movie.id) ?? movie
    }

    var body: some View {
        ZStack {
            HFColors.screenBackground
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                playerPreview
                localPreviewPanel
                primaryActions
                Spacer()
            }
            .padding(HFSpacing.lg)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showsProtectedDepthPreview) {
            HighFiveProtectedSpatialPeekBridge()
        }
        .accessibilityIdentifier("hf.player.surface")
    }

    private var header: some View {
        HStack(alignment: .top, spacing: HFSpacing.md) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Text("HighFive Player")
                    .font(HFTypography.section)
                    .foregroundStyle(HFColors.textPrimary)
                Text("Local Preview")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.gold)
                Text(catalogMovie.title)
                    .font(HFTypography.display)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
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
    }

    private var playerPreview: some View {
        ZStack(alignment: .bottomLeading) {
            if HFPosterAssetHealth.hasImage(named: catalogMovie.backdropAssetName ?? catalogMovie.posterAssetName),
               let assetName = catalogMovie.backdropAssetName ?? catalogMovie.posterAssetName {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
            } else {
                HFPosterFallback(title: catalogMovie.title)
            }

            LinearGradient(colors: [.clear, Color.black.opacity(0.86)], startPoint: .top, endPoint: .bottom)

            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 48, weight: .black))
                    .foregroundStyle(HFColors.gold)
                Text("Local Preview")
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                Text("No streaming provider connected")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.gold)
                Text(catalogMovie.metadataLine)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
            }
            .padding(HFSpacing.lg)
        }
        .frame(height: 340)
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous)
                .stroke(HFColors.goldStroke, lineWidth: 1)
        )
        .accessibilityIdentifier("hf.player.cinematicFrame")
    }

    private var localPreviewPanel: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                Label("Local Preview", systemImage: "play.rectangle.fill")
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                Text("HighFive Player is using local catalog state only. No streaming provider connected.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityIdentifier("hf.player.localPreview")
    }

    private var primaryActions: some View {
        VStack(spacing: HFSpacing.sm) {
            Button {
                streamingStore.markStartedWatching(catalogMovie)
            } label: {
                Label("Local Preview", systemImage: "play.fill")
                    .font(HFTypography.smallAction)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(HFColors.goldGradient)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Button {
                showsProtectedDepthPreview = true
            } label: {
                Label("Try Depth + Peek", systemImage: "cube.transparent")
                    .font(HFTypography.smallAction)
                    .foregroundStyle(HFColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.white.opacity(0.10))
                    .overlay(Capsule().stroke(HFColors.gold.opacity(0.32), lineWidth: 1))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("hf.player.depthPeekCTA")
        }
        .accessibilityIdentifier("hf.player.primaryActions")
    }
}
