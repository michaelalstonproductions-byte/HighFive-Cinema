import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var streamingStore: HFStreamingStore
    @State private var previewMovie: Movie?

    private var creator: Creator {
        HFMockData.creator(for: movie)
    }

    private var cast: [String] {
        HFMockData.cast(for: movie)
    }

    private var galleryAssets: [String] {
        HFMockData.galleryAssets(for: movie)
    }

    private var relatedTitles: [Movie] {
        streamingStore.relatedMovies(for: catalogMovie)
    }

    private var catalogMovie: Movie {
        streamingStore.movie(id: movie.id) ?? movie
    }

    private var detailBottomClearance: CGFloat {
        HFSpacing.floatingTabClearance + HFSpacing.tabBarHeight + HFSpacing.xs
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                hero

                overview
                titleDecisionPanel
                titleSignalPanel
                viewingContextSection
                publicMomentumSection
                catalogIdentitySection
                playerServiceSection
                titlePathSection
                watchToReleaseSection
                relatedSection
                creatorSection
                castSection
                gallerySection
                bottomScrollClearance
            }
            .padding(.bottom, detailBottomClearance)
        }
        .accessibilityIdentifier("hf.consumer.movieDetail.root")
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .sheet(item: $previewMovie) { movie in
            HFPlayerServiceSheet(movie: movie)
                .environmentObject(streamingStore)
                .accessibilityIdentifier("hf.functional.player.sheet")
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                }
            }
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous)
                .fill(HFColors.warmGlow.opacity(0.34))
                .blur(radius: 28)
                .offset(y: 32)

            detailArtwork
                .frame(height: 610)
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous))

            LinearGradient(
                colors: [.clear, HFColors.warmGlow.opacity(0.30), HFColors.background.opacity(0.88), HFColors.background],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous))

            VStack {
                HStack {
                    Text(movie.isOriginal ? "HIGHFIVE ORIGINAL" : "FEATURED TITLE")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.gold)
                        .kerning(1.4)
                        .padding(.horizontal, HFSpacing.sm)
                        .frame(height: 28)
                        .background(Color.black.opacity(0.42))
                        .clipShape(Capsule())
                    Spacer()
                    HFPosterCard(movie: movie, width: 84, showTitle: false, posterOnly: true)
                        .rotationEffect(.degrees(7))
                        .shadow(color: HFColors.amberGlow.opacity(0.26), radius: 18, x: 0, y: 12)
                }
                Spacer()
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
            .padding(.top, HFSpacing.xl)

            HStack(alignment: .bottom, spacing: HFSpacing.md) {
                HFPosterCard(movie: movie, width: 126, showTitle: false, showProgress: movie.progress != nil)

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Now Streaming")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.gold)
                        .textCase(.uppercase)
                        .kerning(1.4)

                    Text(movie.title)
                        .font(HFTypography.heroTitle)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.68)

                    Text(movie.subtitle)
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    detailMetadataChips

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFButton("Watch Now", systemImage: "play.fill") {
                            streamingStore.markStartedWatching(catalogMovie)
                            previewMovie = catalogMovie
                        }
                        .accessibilityIdentifier("hf.consumer.movieDetail.watchNow")
                        .accessibilityLabel("Watch Now")

                        HStack(spacing: HFSpacing.xs) {
                            HFButton(
                                streamingStore.isSaved(movie) ? "In My List" : "Add to My List",
                                systemImage: streamingStore.isSaved(movie) ? "checkmark" : "plus",
                                style: .secondary
                            ) {
                                streamingStore.toggleSaved(movie)
                            }
                            .accessibilityIdentifier("hf.functional.movie.saveToggle")
                            .accessibilityLabel(streamingStore.isSaved(movie) ? "Remove from My List" : "Add to My List")

                            HFButton(
                                streamingStore.isDownloaded(movie) ? "Downloaded" : "Download",
                                systemImage: streamingStore.isDownloaded(movie) ? "checkmark.circle.fill" : "arrow.down.circle.fill",
                                style: .secondary
                            ) {
                                streamingStore.toggleDownload(movie)
                            }
                            .accessibilityIdentifier("hf.functional.movie.downloadToggle")
                            .accessibilityLabel(streamingStore.isDownloaded(movie) ? "Downloaded and available offline" : "Download for offline-ready viewing")
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Saved to \(streamingStore.activeViewingProfile.displayName)")
                                .font(HFTypography.micro)
                                .foregroundStyle(HFColors.gold)
                                .accessibilityIdentifier("hf.account.movieDetail.saveForProfile")
                            Text("Offline state for \(streamingStore.activeViewingProfile.displayName)")
                                .font(HFTypography.micro)
                                .foregroundStyle(HFColors.textSecondary)
                                .accessibilityIdentifier("hf.account.movieDetail.downloadForProfile")
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Saved to \(streamingStore.activeViewingProfile.displayName), offline state for \(streamingStore.activeViewingProfile.displayName)")
                        .accessibilityIdentifier("hf.account.movieDetail.profileState")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
            .padding(.bottom, HFSpacing.xl)
        }
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous)
                .stroke(HFColors.stroke, lineWidth: 1)
        )
        .shadow(color: HFColors.amberGlow.opacity(0.20), radius: 24, x: 0, y: 14)
        .accessibilityIdentifier("hf.consumer.movieDetail.hero")
    }

    private var detailMetadataChips: some View {
        HStack(spacing: HFSpacing.xs) {
            ForEach([movie.year, movie.rating, movie.duration], id: \.self) { value in
                Text(value)
                    .font(HFTypography.caption)
                    .foregroundStyle(value == movie.year ? .black : HFColors.textPrimary)
                    .padding(.horizontal, HFSpacing.sm)
                    .frame(height: 28)
                    .background(value == movie.year ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(Color.white.opacity(0.15)))
                    .clipShape(Capsule())
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.78)
    }

    private var overview: some View {
        VStack(alignment: .leading, spacing: HFSpacing.lg) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                Text("Overview")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.gold)
                    .textCase(.uppercase)

                Text(movie.synopsis)
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, HFSpacing.xs)

            genreTags
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var titleSignalPanel: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.32)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: movie.isComingSoon ? "calendar.badge.clock" : "play.rectangle.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 48, height: 48)
                        .background(HFColors.gold.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text(movie.isComingSoon ? "Premiere Watchlist" : "Ready to Stream")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(movie.isComingSoon ? "This title is staged as a coming-soon HighFive original." : "Watch, save, or continue from the local preview slate.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                HStack(spacing: HFSpacing.xs) {
                    HFDetailSignalChip(title: movie.creatorName, systemImage: "building.2.fill")
                    HFDetailSignalChip(title: streamingStore.isDownloaded(movie) ? "Offline-ready" : "Streaming", systemImage: streamingStore.isDownloaded(movie) ? "arrow.down.circle.fill" : "wifi")
                    if let progress = movie.progress {
                        HFDetailSignalChip(title: "\(Int(progress * 100))% watched", systemImage: "play.circle.fill")
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Movie detail readiness panel")
    }

    private var titleDecisionPanel: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Why Watch Tonight", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.36)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        Image(systemName: "sparkles.tv.fill")
                            .font(.system(size: 22, weight: .black))
                            .foregroundStyle(HFColors.gold)
                            .frame(width: 48, height: 48)
                            .background(HFColors.gold.opacity(0.13))
                            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            Text(movie.title)
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.78)
                            Text("A clear title decision surface for mood, story, audience fit, and what to watch next.")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: 0)
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: HFSpacing.xs)], alignment: .leading, spacing: HFSpacing.xs) {
                        HFTitleDecisionCard(title: "Watch mood", detail: movie.genres.prefix(2).joined(separator: " / "), systemImage: "moon.stars.fill", isActive: true)
                        HFTitleDecisionCard(title: "Story promise", detail: movie.subtitle, systemImage: "text.book.closed.fill")
                        HFTitleDecisionCard(title: "Audience fit", detail: movie.rating, systemImage: "person.2.fill")
                        HFTitleDecisionCard(title: "Premiere context", detail: movie.isOriginal ? "HighFive Original" : "Featured title", systemImage: "sparkles")
                        HFTitleDecisionCard(title: "Related titles", detail: "\(relatedTitles.count) more like this", systemImage: "rectangle.stack.fill")
                    }
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Why Watch Tonight, title decision panel")
        .accessibilityIdentifier("hf.consumer.movieDetail.decisionPanel")
    }

    private var viewingContextSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Viewing Context", actionTitle: nil)

            VStack(spacing: HFSpacing.xs) {
                HFConsumerMomentumRow(title: "Watch Now ready", detail: "Start from the cinematic title page.", status: "Ready", systemImage: "play.fill")
                HFConsumerMomentumRow(title: "Saved shelf ready", detail: streamingStore.isSaved(movie) ? "Already in My List." : "Save when this fits your night.", status: streamingStore.isSaved(movie) ? "Saved" : "Ready", systemImage: "bookmark.fill")
                HFConsumerMomentumRow(title: "Related titles ready", detail: "More Like This keeps the decision path moving.", status: "Ready", systemImage: "rectangle.stack.fill")
                HFConsumerMomentumRow(title: "Offline shelf", detail: streamingStore.isDownloaded(movie) ? "Available Offline appears in Downloads." : "Tap Download to mark this title offline-ready.", status: streamingStore.isDownloaded(movie) ? "Downloaded" : "Ready", systemImage: "arrow.down.circle.fill")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Viewing Context, watch now, saved shelf, related titles, and offline shelf")
        .accessibilityIdentifier("hf.consumer.movieDetail.viewingContext")
    }

    private var publicMomentumSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Public Momentum", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.30)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: HFSpacing.xs)], alignment: .leading, spacing: HFSpacing.xs) {
                        HFTitleDecisionCard(title: "Premiere angle", detail: movie.isOriginal ? "Original premiere" : "Featured title", systemImage: "flag.checkered", isActive: true)
                        HFTitleDecisionCard(title: "Audience conversation", detail: "Story-first watch prompt", systemImage: "person.2.fill")
                        HFTitleDecisionCard(title: "Related titles path", detail: "\(relatedTitles.count) titles to continue", systemImage: "rectangle.stack.fill")
                    }

                    Text("Explore More Like This")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .padding(.horizontal, HFSpacing.md)
                        .padding(.vertical, 11)
                        .background(HFColors.goldGradient)
                        .clipShape(Capsule())
                        .accessibilityLabel("Explore More Like This")
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Public Momentum, premiere angle audience conversation and related titles path")
        .accessibilityIdentifier("hf.consumer.movieDetail.publicMomentum")
    }

    private var titlePathSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Title Path", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.30)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: HFSpacing.xs)], alignment: .leading, spacing: HFSpacing.xs) {
                        HFTitleDecisionCard(title: "Watch path", detail: "Start with this title tonight", systemImage: "play.rectangle.fill", isActive: true)
                        HFTitleDecisionCard(title: "Collection fit", detail: movie.genres.first ?? "Featured", systemImage: "square.grid.2x2.fill")
                        HFTitleDecisionCard(title: "Public momentum", detail: movie.isOriginal ? "Original premiere path" : "Featured title path", systemImage: "flame.fill")
                        HFTitleDecisionCard(title: "Delivery readiness", detail: "Professional package signal", systemImage: "shippingbox.fill")
                    }

                    Text("Explore More Like This")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .padding(.horizontal, HFSpacing.md)
                        .padding(.vertical, 11)
                        .background(HFColors.goldGradient)
                        .clipShape(Capsule())
                        .accessibilityLabel("Explore More Like This")
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Title Path, watch path collection fit public momentum and delivery readiness")
        .accessibilityIdentifier("hf.consumer.movieDetail.titlePath")
    }

    private var catalogIdentitySection: some View {
        HFInsightCard(
            title: "Catalog Identity",
            message: "\(catalogMovie.title) is resolved through the shared movie catalog.",
            systemImage: "rectangle.stack.badge.play.fill"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Catalog Identity, this title is resolved through the shared movie catalog")
        .accessibilityIdentifier("hf.catalog.movieDetail.identity")
    }

    private var playerServiceSection: some View {
        HFInsightCard(
            title: "Player Service",
            message: "Watch Now resolves \(catalogMovie.title) through the playback source resolver.",
            systemImage: "play.rectangle.fill"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Player Service, Watch Now resolves the selected catalog title through the playback source resolver")
        .accessibilityIdentifier("hf.player.catalog.sourceConnection")
        .accessibilityIdentifier("hf.player.catalog.movieID")
        .accessibilityIdentifier("hf.player.catalog.title")
    }

    private var watchToReleaseSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "From Watch To Release", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.28)) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 122), spacing: HFSpacing.xs)], alignment: .leading, spacing: HFSpacing.xs) {
                    HFTitleDecisionCard(title: "Watch path", detail: "Start with this title", systemImage: "play.rectangle.fill", isActive: true)
                    HFTitleDecisionCard(title: "Public momentum", detail: "Premiere story signal", systemImage: "flame.fill")
                    HFTitleDecisionCard(title: "Professional delivery", detail: "Polished title journey", systemImage: "sparkles")
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("From Watch To Release, watch path public momentum and professional delivery")
        .accessibilityIdentifier("hf.consumer.movieDetail.watchToRelease")
    }

    private var genreTags: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 92), spacing: HFSpacing.xs)], alignment: .leading, spacing: HFSpacing.xs) {
            ForEach(movie.genres, id: \.self) { genre in
                Text(genre)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .padding(.horizontal, HFSpacing.sm)
                    .frame(maxWidth: .infinity)
                    .frame(height: 34)
                    .background(HFColors.gold.opacity(0.12))
                    .overlay(Capsule().stroke(HFColors.goldStroke, lineWidth: 1))
                    .clipShape(Capsule())
            }
        }
    }

    private var creatorSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Presented By", actionTitle: nil)
            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                HStack(spacing: HFSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(HFColors.goldGradient)
                        Image(systemName: "sparkles.tv.fill")
                            .font(.system(size: 24, weight: .black))
                            .foregroundStyle(.black)
                    }
                    .frame(width: 58, height: 58)

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

    private var castSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Cast", actionTitle: nil)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HFSpacing.sm) {
                    ForEach(cast, id: \.self) { name in
                        HFGlassPanel(cornerRadius: 18) {
                            VStack(spacing: HFSpacing.sm) {
                                ZStack {
                                    Circle()
                                        .fill(HFColors.charcoalLight)
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(HFColors.gold)
                                }
                                .frame(width: 62, height: 62)

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

    private var gallerySection: some View {
        Group {
            if !galleryAssets.isEmpty {
                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    HFSectionHeader(title: "Scenes From This Title", actionTitle: nil)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: HFSpacing.md) {
                            ForEach(galleryAssets, id: \.self) { assetName in
                                if HFPosterAssetHealth.hasImage(named: assetName) {
                                    Image(assetName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 228, height: 128)
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
                        .accessibilityLabel("Open \(related.title)")
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
            .accessibilityIdentifier("hf.consumer.movieDetail.related")
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("More Like This related titles")
        .accessibilityIdentifier("hf.consumer.movieDetail.moreLikeThis")
    }

    private var bottomScrollClearance: some View {
        Color.clear
            .frame(height: HFSpacing.xxl)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var detailArtwork: some View {
        if HFPosterAssetHealth.hasImage(named: movie.backdropAssetName ?? movie.posterAssetName),
           let assetName = movie.backdropAssetName ?? movie.posterAssetName {
            Image(assetName)
                .resizable()
                .scaledToFill()
        } else {
            HFPosterFallback(title: movie.title)
        }
    }

    private var bottomCTA: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [
                    HFColors.background.opacity(0),
                    HFColors.background.opacity(0.82),
                    HFColors.background
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: HFSpacing.xl)
            .allowsHitTesting(false)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
                HStack(spacing: HFSpacing.sm) {
                    HFButton(movie.isComingSoon ? "Preview" : "Watch Now", systemImage: movie.isComingSoon ? "play.rectangle.fill" : "play.fill") {
                        streamingStore.markStartedWatching(catalogMovie)
                        previewMovie = catalogMovie
                    }
                    .accessibilityIdentifier("hf.functional.player.watchNow")
                    HFButton(
                        streamingStore.isSaved(movie) ? "In My List" : "Add to My List",
                        systemImage: streamingStore.isSaved(movie) ? "checkmark" : "plus",
                        style: .secondary
                    ) {
                        streamingStore.toggleSaved(movie)
                    }
                    .accessibilityIdentifier("hf.functional.movie.saveToggle")
                }
                .padding(HFSpacing.sm)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
            .padding(.bottom, HFSpacing.sm)
        }
        .background(HFColors.background.opacity(0.72))
    }
}

struct HFPlayerServiceSheet: View {
    let movie: Movie
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var streamingStore: HFStreamingStore

    private var catalogMovie: Movie {
        streamingStore.movie(id: movie.id) ?? movie
    }

    private var source: HFPlaybackSource {
        streamingStore.playbackSource(for: catalogMovie)
    }

    var body: some View {
        ZStack {
            HFColors.screenBackground
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: HFSpacing.xl) {
                    header
                    artwork
                    readinessCard
                    sourceRows
                }
                .padding(HFSpacing.lg)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .accessibilityIdentifier("hf.functional.player.watchNow")
        .accessibilityIdentifier("hf.player.surface")
    }

    private var header: some View {
        HStack(alignment: .top, spacing: HFSpacing.md) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Text("HighFive Player")
                    .font(HFTypography.section)
                    .foregroundStyle(HFColors.textPrimary)
                Text(catalogMovie.title)
                    .font(HFTypography.display)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                Text("Catalog title active")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.gold)
                    .accessibilityIdentifier("hf.player.catalog.identity")
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
            .accessibilityIdentifier("hf.functional.player.close")
            .accessibilityIdentifier("hf.player.closeButton")
        }
    }

    private var artwork: some View {
        ZStack(alignment: .bottomLeading) {
            if HFPosterAssetHealth.hasImage(named: catalogMovie.backdropAssetName ?? catalogMovie.posterAssetName),
               let assetName = catalogMovie.backdropAssetName ?? catalogMovie.posterAssetName {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
            } else {
                HFPosterFallback(title: catalogMovie.title)
            }

            LinearGradient(
                colors: [.clear, Color.black.opacity(0.82)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Text("Player route ready.")
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                Text("Streaming source not connected yet.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .accessibilityIdentifier("hf.player.source.notConnected")
            }
            .padding(HFSpacing.lg)
        }
        .frame(height: 320)
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous)
                .stroke(HFColors.goldStroke, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Player route ready. Streaming source not connected yet.")
    }

    private var readinessCard: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(spacing: HFSpacing.sm) {
                    Image(systemName: "play.rectangle.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 48, height: 48)
                        .background(HFColors.gold.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text("Playback Source Resolver")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(source.readinessLabel)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                    }
                }

                Text(source.limitation)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Playback Source Resolver, streaming source not connected yet")
        .accessibilityIdentifier("hf.player.readiness")
    }

    private var sourceRows: some View {
        VStack(spacing: HFSpacing.xs) {
            HFConsumerMomentumRow(title: "Catalog title", detail: catalogMovie.title, status: "Active", systemImage: "rectangle.stack.fill")
                .accessibilityIdentifier("hf.player.catalog.title")
            HFConsumerMomentumRow(title: "Movie ID", detail: catalogMovie.id, status: "Catalog", systemImage: "number")
                .accessibilityIdentifier("hf.player.catalog.movieID")
            HFConsumerMomentumRow(title: "Local Playback Source", detail: source.status == .playableLocal ? "Active" : "Local source missing", status: source.status == .playableLocal ? "Active" : "Missing", systemImage: "play.slash.fill")
                .accessibilityIdentifier("hf.player.source.status")
            HFConsumerMomentumRow(title: "Remote Streaming Provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash")
                .accessibilityIdentifier("hf.player.provider.status")
        }
    }
}

private struct HFTitleDecisionCard: View {
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
                .minimumScaleFactor(0.76)

            Text(detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 104, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(isActive ? HFColors.gold.opacity(0.14) : Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous)
                .stroke(isActive ? HFColors.gold.opacity(0.38) : HFColors.glassStroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
    }
}

private struct HFDetailSignalChip: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: HFSpacing.xxs) {
            Image(systemName: systemImage)
                .font(.system(size: 10, weight: .black))
            Text(title)
                .font(HFTypography.caption)
        }
        .foregroundStyle(HFColors.gold)
        .lineLimit(1)
        .minimumScaleFactor(0.72)
        .padding(.horizontal, HFSpacing.xs)
        .frame(height: 28)
        .background(HFColors.gold.opacity(0.10))
        .overlay(Capsule().stroke(HFColors.gold.opacity(0.22), lineWidth: 1))
        .clipShape(Capsule())
    }
}
