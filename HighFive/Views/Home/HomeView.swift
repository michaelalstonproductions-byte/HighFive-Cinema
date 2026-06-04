import SwiftUI

struct HomeView: View {
    let selectedProfile: UserProfile
    @State private var savedMovieIDs: Set<String> = ["friendly", "paranormall-s1"]

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
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
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
                    NavigationLink(value: heroMovie) {
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
                        savedMovieIDs.contains(heroMovie.id) ? "In My List" : "Add To List",
                        systemImage: savedMovieIDs.contains(heroMovie.id) ? "checkmark" : "plus",
                        style: .secondary
                    ) {
                        toggleSaved(heroMovie)
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
                        NavigationLink(value: movie) {
                            HFPosterCard(movie: movie, width: 132, showProgress: category.id == "continue")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
    }

    @ViewBuilder
    private func heroArtwork(_ movie: Movie) -> some View {
        if let assetName = movie.backdropAssetName ?? movie.posterAssetName {
            Image(assetName)
                .resizable()
                .scaledToFill()
        } else {
            LinearGradient(
                colors: [HFColors.charcoalLight, HFColors.background, HFColors.goldDeep.opacity(0.32)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private func toggleSaved(_ movie: Movie) {
        if savedMovieIDs.contains(movie.id) {
            savedMovieIDs.remove(movie.id)
        } else {
            savedMovieIDs.insert(movie.id)
        }
    }
}
