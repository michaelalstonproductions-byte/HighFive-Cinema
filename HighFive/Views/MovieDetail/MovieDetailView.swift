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

    private var detailBottomClearance: CGFloat {
        HFSpacing.floatingTabClearance + HFSpacing.tabBarHeight + HFSpacing.xs
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                hero

                overview
                relatedSection
                creatorSection
                gallerySection
                bottomScrollClearance
            }
            .padding(.bottom, detailBottomClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
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
            RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous)
                .fill(HFColors.warmGlow.opacity(0.34))
                .blur(radius: 28)
                .offset(y: 32)

            detailArtwork
                .frame(height: 610)
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous))

            LinearGradient(
                colors: [.clear, HFColors.background.opacity(0.34), HFColors.background.opacity(0.88), HFColors.background],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous))

            VStack {
                HStack {
                    Text("HIGHFIVE TITLE")
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
                    Text(movie.title)
                        .font(HFTypography.heroTitle)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.68)

                    detailMetadataChips

                    HStack(spacing: HFSpacing.xs) {
                        HFButton(movie.isComingSoon ? "Preview" : "Watch Now", systemImage: movie.isComingSoon ? "play.rectangle.fill" : "play.fill") {
                            previewMovie = movie
                        }

                        HFButton(
                            streamingStore.isSaved(movie) ? "Saved" : "Save",
                            systemImage: streamingStore.isSaved(movie) ? "checkmark" : "plus",
                            style: .secondary
                        ) {
                            streamingStore.toggleSaved(movie)
                        }
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
                Text("Synopsis")
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
                    HFPosterCard(movie: related, width: HFSpacing.posterRailWidth, showProgress: related.progress != nil)
                }
                .buttonStyle(.plain)
            }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
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
        .background(HFColors.background.opacity(0.72))
    }
}
