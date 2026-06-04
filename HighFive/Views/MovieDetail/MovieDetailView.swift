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
        HFMockData.relatedTitles(for: movie)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                hero

                overview
                creatorSection
                castSection
                gallerySection
                relatedSection
            }
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom) {
            bottomCTA
        }
        .sheet(item: $previewMovie) { movie in
            HFMockPlayerSheet(movie: movie)
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
            detailArtwork
                .frame(height: 500)
                .clipped()

            LinearGradient(
                colors: [.clear, HFColors.background.opacity(0.72), HFColors.background],
                startPoint: .top,
                endPoint: .bottom
            )

            HFPosterCard(movie: movie, width: 150, showTitle: false, showProgress: movie.progress != nil)
                .padding(.horizontal, HFSpacing.screenHorizontal)
                .padding(.bottom, HFSpacing.lg)
        }
    }

    private var overview: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            Text(movie.title)
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(movie.metadataLine)
                .font(HFTypography.body)
                .foregroundStyle(HFColors.gold)

            Text(movie.synopsis)
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: HFSpacing.xs) {
                ForEach(movie.genres, id: \.self) { genre in
                    Text(genre)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.gold)
                        .padding(.horizontal, HFSpacing.sm)
                        .frame(height: 32)
                        .background(HFColors.gold.opacity(0.12))
                        .clipShape(Capsule())
                }
            }

            HStack(spacing: HFSpacing.sm) {
                HFButton(movie.isComingSoon ? "Preview" : "Watch Now", systemImage: movie.isComingSoon ? "play.rectangle.fill" : "play.fill") {
                    previewMovie = movie
                }
                HFButton(
                    streamingStore.isSaved(movie) ? "In My List" : "Add To List",
                    systemImage: streamingStore.isSaved(movie) ? "checkmark" : "plus",
                    style: .secondary
                ) {
                    streamingStore.toggleSaved(movie)
                }
            }

            HFButton(
                streamingStore.isDownloaded(movie) ? "Remove Download" : "Download",
                systemImage: streamingStore.isDownloaded(movie) ? "trash" : "arrow.down.circle.fill",
                style: .outline
            ) {
                streamingStore.toggleDownload(movie)
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var creatorSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Creator", actionTitle: nil)
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
                    HFSectionHeader(title: "Gallery", actionTitle: nil)
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
            HFSectionHeader(title: "Related Titles", actionTitle: nil)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    ForEach(relatedTitles) { related in
                        NavigationLink(value: related) {
                            HFPosterCard(movie: related, width: 132, showProgress: related.progress != nil)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
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
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
            HStack(spacing: HFSpacing.sm) {
                HFButton("Watch Now", systemImage: "play.fill") {
                    previewMovie = movie
                }
                HFButton(
                    streamingStore.isSaved(movie) ? "Saved" : "My List",
                    systemImage: streamingStore.isSaved(movie) ? "checkmark" : "plus",
                    style: .secondary
                ) {
                    streamingStore.toggleSaved(movie)
                }
            }
            .padding(HFSpacing.sm)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .padding(.bottom, HFSpacing.sm)
    }
}
