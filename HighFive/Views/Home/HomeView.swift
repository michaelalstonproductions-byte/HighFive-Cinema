import SwiftUI

struct HomeView: View {
    let selectedProfile: UserProfile
    @EnvironmentObject private var streamingStore: HFStreamingStore
    @State private var previewMovie: Movie?

    private var heroMovie: Movie {
        HFMockData.movie("friendly") ?? HFMockData.movies[0]
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: HFSpacing.xl) {
                header
                heroSection

                ForEach(HFMockData.premiumHomeRails) { category in
                    movieRail(category)
                }
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .sheet(item: $previewMovie) { movie in
            HFMockPlayerSheet(movie: movie)
        }
    }

    private var header: some View {
        HStack(spacing: HFSpacing.md) {
            ZStack {
                Circle()
                    .fill(HFColors.goldGradient)
                Image(systemName: "film.stack.fill")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(.black)
            }
            .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 0) {
                Text("HIGHFIVE")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                Text("CINEMA")
                    .font(.system(size: 22, weight: .black, design: .rounded))
            }
            .foregroundStyle(HFColors.gold)

            Spacer()

            HStack(spacing: HFSpacing.md) {
                Image(systemName: "magnifyingglass")
                Image(systemName: "bell.fill")
                Image(systemName: selectedProfile.avatarSystemName)
            }
            .font(.system(size: 25, weight: .bold))
            .foregroundStyle(HFColors.textPrimary)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            NavigationLink(value: heroMovie) {
                heroArtwork(heroMovie)
                    .frame(height: 430)
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous))
            }
            .buttonStyle(.plain)

            HFColors.heroGradient
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous))

            VStack(alignment: .leading, spacing: HFSpacing.md) {
                Spacer()
                Text("FEATURED PREMIERE")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.gold)
                    .kerning(1.6)

                Text(heroMovie.title)
                    .font(HFTypography.heroTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)

                Text(heroMovie.subtitle + "\n" + heroMovie.synopsis)
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: HFSpacing.xs) {
                    ForEach(["4K HDR", "HighFive Original", "Cinematic Cut"], id: \.self) { badge in
                        Text(badge)
                            .font(HFTypography.caption)
                            .foregroundStyle(.black)
                            .padding(.horizontal, HFSpacing.sm)
                            .frame(height: 30)
                            .background(HFColors.goldGradient)
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: HFSpacing.sm) {
                    Button {
                        previewMovie = heroMovie
                    } label: {
                        HStack(spacing: HFSpacing.xs) {
                            Image(systemName: "play.fill")
                            Text("Watch Now")
                        }
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(HFColors.goldGradient)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    HFButton(
                        streamingStore.isSaved(heroMovie) ? "In My List" : "Add To List",
                        systemImage: streamingStore.isSaved(heroMovie) ? "checkmark" : "plus",
                        style: .secondary
                    ) {
                        streamingStore.toggleSaved(heroMovie)
                    }
                }
            }
            .padding(HFSpacing.xl)
        }
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous)
                .stroke(HFColors.goldStroke, lineWidth: 1)
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func movieRail(_ category: Category) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: category.title)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    ForEach(category.movies) { movie in
                        if category.id == "continue-watching" {
                            Button {
                                previewMovie = movie
                            } label: {
                                HFPosterCard(movie: movie, width: 132, showProgress: true)
                            }
                            .buttonStyle(.plain)
                        } else {
                            NavigationLink(value: movie) {
                                HFPosterCard(movie: movie, width: 132, showProgress: category.id == "continue")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
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
