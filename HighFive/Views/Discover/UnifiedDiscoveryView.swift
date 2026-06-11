import SwiftUI

struct UnifiedDiscoveryView: View {
    @EnvironmentObject private var streamingStore: HFStreamingStore
    @State private var selectedFilter = "All"

    private var showMovies: Bool {
        selectedFilter == "All" || selectedFilter == "Movies"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xl) {
            header
            discoverSpotlight
            discoveryFilters

            ForEach(streamingDiscoveryRails) { category in
                movieRail(category)
            }
            .accessibilityIdentifier("hf.consumer.discovery.rails")
        }
        .accessibilityIdentifier("hf.consumer.discover.root")
    }

    private var streamingDiscoveryRails: [Category] {
        streamingStore.catalogRails(filter: selectedFilter)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Discover")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Text("Find the next premiere, original, or saved story worth watching tonight.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var discoverSpotlight: some View {
        let spotlight = streamingStore.movie(id: "paranormall-s1") ?? streamingStore.featuredMovie

        return NavigationLink(value: spotlight) {
            ZStack(alignment: .bottomLeading) {
                artwork(for: spotlight)
                    .frame(height: 270)
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous))

                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.50), Color.black.opacity(0.94)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous))

                HStack(alignment: .bottom, spacing: HFSpacing.md) {
                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("HIGHFIVE PICKS")
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.gold)
                            .kerning(1.2)
                        Text("A cinematic lane for tonight's next watch.")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(2)
                        Text("Originals, thrillers, saved titles, and upcoming premieres.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .lineLimit(2)
                    }

                    Spacer()

                    HFPosterCard(movie: spotlight, width: 92, showTitle: false, posterOnly: true)
                        .rotationEffect(.degrees(5))
                }
                .padding(HFSpacing.lg)
            }
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous)
                    .stroke(HFColors.gold.opacity(0.48), lineWidth: 1)
            )
            .background(
                HFColors.warmGlow.opacity(0.16),
                in: RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous)
            )
            .shadow(color: HFColors.amberGlow.opacity(0.22), radius: 22, x: 0, y: 14)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityLabel("Open HighFive picks")
    }

    private var discoveryFilters: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            Text("Genre and mood filters")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .padding(.horizontal, HFSpacing.screenHorizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HFSpacing.xs) {
                    ForEach(HFMockData.discoveryGenres, id: \.self) { filter in
                        HFFilterChip(title: filter, isSelected: selectedFilter == filter) {
                            selectedFilter = filter
                        }
                        .accessibilityLabel("Select \(filter) discovery filter")
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Genre and mood filters")
        .accessibilityIdentifier("hf.consumer.search.genreFilters")
    }

    private func movieRail(_ category: Category) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: category.title, actionTitle: nil)

            if let subtitle = category.subtitle {
                Text(subtitle)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .padding(.horizontal, HFSpacing.screenHorizontal)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    ForEach(category.movies) { movie in
                        NavigationLink(value: movie) {
                            HFPosterCard(movie: movie, width: 140, showMetadata: false, showProgress: movie.progress != nil)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Open \(movie.title)")
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
            .scrollClipDisabled()
        }
    }

    @ViewBuilder
    private func artwork(for movie: Movie) -> some View {
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
