import AVKit
import Combine
import CoreMotion
import SwiftUI
#if os(iOS)
import UIKit
#endif
import UniformTypeIdentifiers

private enum HFPlayerLayer4DebugGate {
    static var isEnabled: Bool {
        ProcessInfo.processInfo.environment["HF_SHOW_LAYER4_DEBUG"] == "1"
            || ProcessInfo.processInfo.arguments.contains("HF_SHOW_LAYER4_DEBUG=1")
            || ProcessInfo.processInfo.arguments.contains("--hf-show-layer4-debug")
    }
}

enum HFPlaybackContentSource: Equatable {
    case officialCatalog
    case userImported
}

private enum HFStreamingAccessPolicy {
    static func isLockedOfficialTitle(_ movie: Movie) -> Bool {
        movie.isOriginal
            && !movie.isComingSoon
            && !freeOriginalIDs.contains(movie.id)
    }

    static var isDebugPaywallUnlockAvailable: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["HF_ALLOW_DEBUG_PAYWALL_UNLOCK"] == "1"
            || ProcessInfo.processInfo.arguments.contains("HF_ALLOW_DEBUG_PAYWALL_UNLOCK=1")
            || ProcessInfo.processInfo.arguments.contains("--hf-allow-debug-paywall-unlock")
        #else
        false
        #endif
    }

    private static let freeOriginalIDs: Set<String> = [
        "behind-vision"
    ]
}

private struct HFTitleEpisodeDetail: Identifiable, Equatable {
    let id: Int
    let title: String
    let runtime: String
    let storeKitProductID: String
}

private struct HFTitleDetailMetadata: Equatable {
    let displayTitle: String
    let year: String
    let runtimeOrSeason: String
    let rating: String
    let genres: [String]
    let synopsis: String
    let director: String?
    let writers: [String]
    let stars: [String]
    let executiveProducers: [String]
    let productionCompanies: [String]
    let trailerPreviewNames: [String]
    let fullSourceNames: [String]
    let episodes: [HFTitleEpisodeDetail]

    var isSeries: Bool {
        !episodes.isEmpty
    }

    var resolvedTrailerPreviewURL: URL? {
        Self.localVideoURL(named: trailerPreviewNames, subdirectories: [
            nil,
            "App/Resources/PreviewClips",
            "Resources/PreviewClips",
            "PreviewClips"
        ])
    }

    static func metadata(for movie: Movie) -> HFTitleDetailMetadata {
        switch movie.id {
        case "friendly":
            return HFTitleDetailMetadata(
                displayTitle: "The Friendly",
                year: "2024",
                runtimeOrSeason: "1h 41m",
                rating: "HD",
                genres: ["Action", "Drama", "War"],
                synopsis: "Military medic Curtis gets injured, returns home with dog Friendly who saved him. Curtis and Friendly adjust to civilian life. Curtis falls in love with nurse Sophia, who has a child.",
                director: "Jason Strickland",
                writers: ["Juan Manuel Armijos", "Jason Strickland"],
                stars: ["Casey Deidrick", "Daniela Nieves", "Joe Mantegna"],
                executiveProducers: [],
                productionCompanies: ["InTheLight Productions"],
                trailerPreviewNames: ["preview_the_friendly_30s"],
                fullSourceNames: ["TheFriendly_ref"],
                episodes: []
            )
        case "paranormall-s1":
            return HFTitleDetailMetadata(
                displayTitle: "Paranormall",
                year: "Season 1",
                runtimeOrSeason: "Short Micro Vertical Horror",
                rating: "7 Episodes",
                genres: ["Horror", "Mystery", "Short", "Vertical"],
                synopsis: "A mall security guard discovers an Ouija board during a quiet shift. What starts as a strange late-night find becomes a doorway to something truly horrific, turning the mall into a vertical nightmare one episode at a time.",
                director: "Jason Strickland",
                writers: [],
                stars: [],
                executiveProducers: ["Kumbali Satori", "Jason Strickland", "Charles Jones"],
                productionCompanies: ["InTheLight Productions", "HigherKey, Inc Originals"],
                trailerPreviewNames: ["preview_paranormall_e1_30s"],
                fullSourceNames: (1...7).map { "Paranormall_E\($0)_ref" },
                episodes: (1...7).map { episode in
                    HFTitleEpisodeDetail(
                        id: episode,
                        title: "Episode \(episode)",
                        runtime: episode == 1 ? "47m" : "44m",
                        storeKitProductID: HFProductIdentifier.paranormallEpisode(episode).rawValue
                    )
                }
            )
        default:
            return HFTitleDetailMetadata(
                displayTitle: movie.title,
                year: movie.year,
                runtimeOrSeason: movie.duration,
                rating: movie.rating,
                genres: movie.genres,
                synopsis: movie.synopsis,
                director: nil,
                writers: [],
                stars: [],
                executiveProducers: [],
                productionCompanies: [movie.creatorName],
                trailerPreviewNames: [],
                fullSourceNames: [],
                episodes: []
            )
        }
    }

    private static func localVideoURL(named names: [String], subdirectories: [String?]) -> URL? {
        for name in names {
            for extensionName in ["mp4", "mov", "m4v"] {
                for subdirectory in subdirectories {
                    let url: URL?
                    if let subdirectory {
                        url = Bundle.main.url(forResource: name, withExtension: extensionName, subdirectory: subdirectory)
                    } else {
                        url = Bundle.main.url(forResource: name, withExtension: extensionName)
                    }

                    if let url {
                        return url
                    }
                }
            }
        }
        return nil
    }
}

private struct HFTitleTrailerPreview: Identifiable {
    let id = UUID()
    let title: String
    let url: URL
}

private struct HFStreamingTitleDetailView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let movie: Movie
    let metadata: HFTitleDetailMetadata
    let isUnlocked: Bool
    let isLocked: Bool
    let selectedEpisodeNumber: Int
    let isSeasonUnlocked: Bool
    let isSelectedEpisodeUnlocked: Bool
    let unlockedEpisodeNumbers: Set<Int>
    let friendlyPrice: String
    let episodePrice: String
    let seasonPrice: String
    let trailerPreviewURL: URL?
    let onWatchTrailer: () -> Void
    let onPrimaryAction: () -> Void
    let onEpisodePurchase: () -> Void
    let onSeasonPurchase: () -> Void
    let onEpisodeAction: (Int) -> Void

    private var detailIdentifier: String {
        switch movie.id {
        case "friendly":
            return "hf.titleDetail.theFriendly"
        case "paranormall-s1":
            return "hf.titleDetail.paranormall"
        default:
            return "hf.titleDetail.screen"
        }
    }

    private var compactPrimaryPosterWidth: CGFloat {
        #if os(iOS)
        let framedWidth = UIScreen.main.bounds.width - 60
        let posterWidth = framedWidth - HFDepthPosterScale.detail.padding * 2
        return max(228, min(posterWidth, 338))
        #else
        return 340
        #endif
    }

    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                compactBody
            } else {
                regularBody
            }
        }
        .accessibilityIdentifier("hf.titleDetail.screen")
        .background(
            Color.clear
                .frame(width: 1, height: 1)
                .accessibilityIdentifier(detailIdentifier)
        )
    }

    private var compactBody: some View {
        VStack(alignment: .leading, spacing: HFSpacing.lg) {
            primaryPosterShowcase

            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                trailerCard
                actionStack
                cinematicCastSection

                if metadata.isSeries {
                    episodeList
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
            .padding(.bottom, HFSpacing.xxl)
        }
    }

    private var regularBody: some View {
        VStack(alignment: .leading, spacing: HFSpacing.lg) {
            heroBand

            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                cinematicMetadataPanel
                mediaRow
                actionStack
                cinematicCastSection

                if metadata.isSeries {
                    episodeList
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
            .padding(.bottom, HFSpacing.lg)
        }
    }

    private var heroBand: some View {
        ZStack(alignment: .bottomLeading) {
            detailArtwork(named: movie.backdropAssetName ?? movie.posterAssetName, verticalOffset: 14)
                .frame(height: 270)
                .clipped()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.02),
                    Color.black.opacity(0.28),
                    HFColors.background.opacity(0.92),
                    HFColors.background
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(metadata.displayTitle)
                    .font(.system(size: 44, weight: .black, design: .default))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.62)

                HStack(spacing: 8) {
                    metadataBadge(metadata.year)
                    metadataBadge(metadata.runtimeOrSeason)
                    if !metadata.rating.isEmpty {
                        metadataBadge(metadata.rating)
                    }
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
            .padding(.bottom, HFSpacing.lg)
        }
        .frame(height: 270)
    }

    private var titleBlock: some View {
        HStack(alignment: .center, spacing: HFSpacing.md) {
            VStack(alignment: .leading, spacing: 8) {
                Text(movie.creatorName)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(1)

                Text(isUnlocked ? "Access active" : (isLocked ? "Unlock to watch the full title" : "Ready to watch"))
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer()

            ratingCapsule(systemImage: "star.fill", title: "8.6", subtitle: "Rating")
            ratingCapsule(systemImage: "chart.line.uptrend.xyaxis", title: "94%", subtitle: "Score")
        }
    }

    private var cinematicMetadataPanel: some View {
        HStack(alignment: .top, spacing: 12) {
            Capsule()
                .fill(HFColors.goldGradient)
                .frame(width: 3)
                .frame(maxHeight: .infinity)
                .opacity(0.78)

            VStack(alignment: .leading, spacing: 14) {
                Text(metadata.displayTitle)
                    .font(.system(size: 36, weight: .black, design: .default))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)

                Text(metadataLine)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(metadata.genres, id: \.self) { genre in
                            genrePill(genre)
                        }
                    }
                    .padding(.horizontal, 1)
                }

                VStack(alignment: .leading, spacing: 10) {
                    if let director = metadata.director {
                        cinematicMetadataRow(label: "Director", value: director)
                    }

                    if !primaryCastNames.isEmpty {
                        cinematicMetadataRow(label: "Cast", value: primaryCastNames.prefix(4).joined(separator: "  •  "))
                    }

                    if !metadata.productionCompanies.isEmpty {
                        cinematicMetadataRow(label: "Companies", value: metadata.productionCompanies.joined(separator: "  •  "))
                    }
                }

                Text(metadata.synopsis)
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    ratingCapsule(systemImage: "star.fill", title: "8.6", subtitle: "Rating")
                    ratingCapsule(systemImage: "chart.line.uptrend.xyaxis", title: "94%", subtitle: "Score")
                }
            }
        }
        .accessibilityIdentifier("hf.titleDetail.compactTitleInfo")
    }

    private var compactTitleInfoBlock: some View {
        cinematicMetadataPanel
    }

    private var mediaRow: some View {
        HStack(alignment: .top, spacing: HFSpacing.md) {
            detailMiniPosterArtwork(
                named: movie.posterAssetName,
                width: 126,
                height: 188
            )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(HFColors.gold.opacity(0.34), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.34), radius: 18, x: 0, y: 12)
                .accessibilityIdentifier("hf.titleDetail.poster")

            trailerCard
        }
        .accessibilityIdentifier("hf.titleDetail.mediaStack")
    }

    private var trailerCard: some View {
        Button(action: onWatchTrailer) {
            ZStack {
                detailArtwork(named: movie.backdropAssetName ?? movie.posterAssetName, verticalOffset: 18)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()

                DepthMotionProvider(
                    isEnabled: true,
                    clamp: 1,
                    geometryInfluence: HFCinematicDepthDirector.profile(for: .focusedCard).geometryInfluence,
                    role: .focusedCard
                ) { motion in
                    HFLayer4UltraDepthFX(
                        motion: motion,
                        role: .focusedCard,
                        tint: HFColors.gold,
                        showDust: true,
                        showFocusBreath: true
                    )
                    .opacity(0.72)
                }

                LinearGradient(
                    colors: [.black.opacity(0.10), .black.opacity(0.22), .black.opacity(0.72)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack {
                    HStack {
                        Text("Trailer")
                            .font(.system(size: 11, weight: .black, design: .default))
                            .textCase(.uppercase)
                            .foregroundStyle(.black)
                            .padding(.horizontal, 10)
                            .frame(height: 24)
                            .background(HFColors.goldGradient, in: Capsule())
                        Spacer()
                    }

                    Spacer()

                    HStack(spacing: 12) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 20, weight: .black))
                            .foregroundStyle(.black)
                            .frame(width: 54, height: 54)
                            .background(HFColors.goldGradient, in: Circle())
                            .shadow(color: HFColors.amberGlow.opacity(0.44), radius: 18, x: 0, y: 0)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Watch Trailer")
                                .font(HFTypography.cardTitle)
                                .foregroundStyle(HFColors.textPrimary)
                            Text("Premium preview")
                                .font(HFTypography.caption.weight(.semibold))
                                .foregroundStyle(HFColors.textSecondary)
                        }

                        Spacer()
                    }
                }
                .padding(14)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .frame(height: 206)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            HFColors.gold.opacity(0.34),
                            Color.white.opacity(0.13),
                            HFColors.gold.opacity(0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.44), radius: 24, x: 0, y: 16)
        .shadow(color: HFColors.gold.opacity(0.10), radius: 22, x: 0, y: 8)
        .background(
            Color.clear
                .frame(width: 1, height: 1)
                .accessibilityIdentifier("hf.titleDetail.previewCard")
        )
        .accessibilityIdentifier("hf.titleDetail.trailerPreview")
        .background(
            Color.clear
                .frame(width: 1, height: 1)
                .accessibilityIdentifier("hf.v13.detail.trailer")
        )
    }

    private var genreRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(metadata.genres, id: \.self) { genre in
                    Text(genre)
                        .font(HFTypography.caption.weight(.bold))
                        .foregroundStyle(HFColors.textPrimary)
                        .padding(.horizontal, 12)
                        .frame(height: 34)
                        .background(Color.white.opacity(0.08), in: Capsule())
                        .overlay(Capsule().stroke(.white.opacity(0.14), lineWidth: 1))
                }
            }
            .padding(.horizontal, 1)
        }
    }

    private var actionStack: some View {
        VStack(spacing: 10) {
            Button(action: onWatchTrailer) {
                Label("Watch Trailer", systemImage: "play")
                    .font(HFTypography.smallAction)
                    .foregroundStyle(HFColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(.white.opacity(0.16), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("hf.titleDetail.watchTrailer")

            if metadata.isSeries {
                if isSeasonUnlocked || isSelectedEpisodeUnlocked {
                    Button(action: onPrimaryAction) {
                        Label(primaryActionTitle, systemImage: "play.fill")
                            .font(HFTypography.smallAction)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(HFColors.goldGradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .shadow(color: HFColors.amberGlow.opacity(0.24), radius: 16, x: 0, y: 8)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.titleDetail.watchFull")
                } else {
                    Button(action: onSeasonPurchase) {
                        Label("Unlock Season 1 - \(seasonPrice)", systemImage: "lock.fill")
                            .font(HFTypography.smallAction)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(HFColors.goldGradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .shadow(color: HFColors.amberGlow.opacity(0.24), radius: 16, x: 0, y: 8)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.titleDetail.unlockSeason")

                    Button(action: onEpisodePurchase) {
                        Label("Unlock Episode - \(episodePrice)", systemImage: "lock.fill")
                            .font(HFTypography.smallAction)
                            .foregroundStyle(HFColors.gold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(HFColors.gold.opacity(0.28), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.titleDetail.unlockEpisode")
                }
            } else {
                Button(action: onPrimaryAction) {
                    Label(primaryActionTitle, systemImage: isUnlocked ? "play.fill" : "lock.fill")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(HFColors.goldGradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .shadow(color: HFColors.amberGlow.opacity(0.24), radius: 16, x: 0, y: 8)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(isUnlocked ? "hf.titleDetail.watchFull" : "hf.titleDetail.unlockFull")
            }
        }
    }

    private var synopsisBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Synopsis")
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)

            Text(metadata.synopsis)
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityIdentifier("hf.titleDetail.synopsis")
    }

    private var cinematicCastSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cast")
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(cinematicCastCards) { person in
                        cinematicActorCard(person)
                    }
                }
                .padding(.horizontal, 1)
                .padding(.vertical, 3)
            }
        }
        .accessibilityIdentifier("hf.v13.detail.cast")
    }

    private var creditsBlock: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let director = metadata.director {
                creditRow(title: "Director", values: [director])
                    .accessibilityIdentifier("hf.titleDetail.director")
            }
            if !metadata.writers.isEmpty {
                creditRow(title: "Writers", values: metadata.writers)
            }
            if !metadata.stars.isEmpty {
                creditRow(title: "Stars", values: metadata.stars)
            }
            if !metadata.executiveProducers.isEmpty {
                creditRow(title: "Executive Producers", values: metadata.executiveProducers)
                    .accessibilityIdentifier("hf.titleDetail.executiveProducers")
            }
            if !metadata.productionCompanies.isEmpty {
                creditRow(title: "Production Companies", values: metadata.productionCompanies)
                    .accessibilityIdentifier("hf.titleDetail.productionCompanies")
            }
        }
        .padding(.vertical, 2)
        .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var episodeList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Season 1")
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)

                Spacer()

                Text("\(metadata.episodes.count) Episodes")
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textMuted)
            }

            VStack(spacing: 12) {
                ForEach(metadata.episodes) { episode in
                    episodeCard(episode)
                }
            }
        }
        .accessibilityIdentifier("hf.titleDetail.episodeList")
        .background(
            Color.clear
                .frame(width: 1, height: 1)
                .accessibilityIdentifier("hf.v13.detail.episodes")
        )
    }

    private var primaryActionTitle: String {
        if isUnlocked {
            return metadata.isSeries ? (isSeasonUnlocked ? "Season 1 Unlocked" : "Watch Episode") : "Watch Full Movie"
        }
        return metadata.isSeries ? "Unlock Episode - \(episodePrice)" : "Unlock Full Movie - \(friendlyPrice)"
    }

    private func isEpisodeUnlocked(_ episodeNumber: Int) -> Bool {
        isSeasonUnlocked || unlockedEpisodeNumbers.contains(episodeNumber)
    }

    private func episodeActionTitle(for episodeNumber: Int) -> String {
        isEpisodeUnlocked(episodeNumber) ? "Watch" : episodePrice
    }

    private func episodeActionSystemImage(for episodeNumber: Int) -> String {
        isEpisodeUnlocked(episodeNumber) ? "play.fill" : "lock.fill"
    }

    private func metadataBadge(_ text: String) -> some View {
        Text(text)
            .font(HFTypography.caption.weight(.bold))
            .foregroundStyle(.white.opacity(0.90))
            .padding(.horizontal, 9)
            .frame(height: 26)
            .background(.black.opacity(0.38), in: Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.14), lineWidth: 1))
    }

    private var metadataLine: String {
        if metadata.isSeries {
            return [metadata.year, metadata.rating, "\(metadata.episodes.count) Episodes"]
                .filter { !$0.isEmpty }
                .joined(separator: "  •  ")
        }
        return [metadata.year, metadata.rating, metadata.runtimeOrSeason]
            .filter { !$0.isEmpty }
            .joined(separator: "  •  ")
    }

    private var primaryCastNames: [String] {
        if !metadata.stars.isEmpty {
            return metadata.stars
        }
        if !metadata.executiveProducers.isEmpty {
            return metadata.executiveProducers
        }
        if let director = metadata.director {
            return [director]
        }
        return metadata.productionCompanies
    }

    private struct CinematicCastPerson: Identifiable {
        let id = UUID()
        let name: String
        let role: String
    }

    private var cinematicCastCards: [CinematicCastPerson] {
        let stars = metadata.stars.map { CinematicCastPerson(name: $0, role: "Cast") }
        if !stars.isEmpty {
            return stars
        }

        var people: [CinematicCastPerson] = []
        if let director = metadata.director {
            people.append(CinematicCastPerson(name: director, role: "Director"))
        }
        people.append(contentsOf: metadata.executiveProducers.prefix(4).map { CinematicCastPerson(name: $0, role: "Executive Producer") })
        people.append(contentsOf: metadata.productionCompanies.prefix(2).map { CinematicCastPerson(name: $0, role: "Studio") })
        return people
    }

    private func genrePill(_ text: String) -> some View {
        Text(text)
            .font(HFTypography.caption.weight(.bold))
            .foregroundStyle(HFColors.textPrimary)
            .padding(.horizontal, 12)
            .frame(height: 34)
            .background(Color.white.opacity(0.08), in: Capsule())
            .overlay(Capsule().stroke(HFColors.gold.opacity(0.18), lineWidth: 1))
    }

    private func cinematicMetadataRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(HFTypography.micro.weight(.black))
                .foregroundStyle(HFColors.gold)
                .textCase(.uppercase)
            Text(value)
                .font(HFTypography.caption.weight(.semibold))
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func cinematicActorCard(_ person: CinematicCastPerson) -> some View {
        DepthMotionProvider(
            isEnabled: true,
            clamp: 0.65,
            geometryInfluence: HFCinematicDepthDirector.profile(for: .rowCard).geometryInfluence,
            role: .rowCard
        ) { motion in
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    HFColors.gold.opacity(0.22),
                                    Color.white.opacity(0.07),
                                    Color.black.opacity(0.36)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: HFColors.gold.opacity(0.14), radius: 16, x: 0, y: 8)

                    Image(systemName: "person.fill")
                        .font(.system(size: 29, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .offset(x: motion.isActive ? motion.x * 2 : 0, y: motion.isActive ? motion.y * 2 : 0)
                }
                .frame(width: 74, height: 74)

                VStack(spacing: 3) {
                    Text(person.name)
                        .font(HFTypography.caption.weight(.black))
                        .foregroundStyle(HFColors.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    Text(person.role)
                        .font(HFTypography.micro.weight(.bold))
                        .foregroundStyle(HFColors.textMuted)
                        .lineLimit(1)
                }
            }
            .frame(width: 132, height: 154)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.055))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.13),
                                HFColors.gold.opacity(0.18),
                                Color.white.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.34), radius: 16, x: 0, y: 10)
            .overlay(
                HFLayer4GlassSweep(motion: motion, tint: HFColors.gold, intensity: 0.35)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            )
        }
    }

    private func episodeCard(_ episode: HFTitleEpisodeDetail) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.10),
                                Color.black.opacity(0.22)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text("\(episode.id)")
                    .font(.system(size: 24, weight: .black, design: .default))
                    .foregroundStyle(HFColors.gold)
            }
            .frame(width: 70, height: 58)

            VStack(alignment: .leading, spacing: 4) {
                Text(episode.title)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                Text(episode.runtime)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textMuted)
            }

            Spacer()

            Button {
                onEpisodeAction(episode.id)
            } label: {
                Label(episodeActionTitle(for: episode.id), systemImage: episodeActionSystemImage(for: episode.id))
                    .font(HFTypography.micro.weight(.black))
                    .foregroundStyle(isEpisodeUnlocked(episode.id) ? .black : HFColors.gold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .frame(width: 116, height: 38)
                    .background(isEpisodeUnlocked(episode.id) ? HFColors.gold : Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(HFColors.gold.opacity(0.32), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.050))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            HFColors.gold.opacity(0.22),
                            Color.white.opacity(0.08),
                            Color.white.opacity(0.03)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.32), radius: 18, x: 0, y: 10)
    }

    private func ratingCapsule(systemImage: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(HFColors.gold)
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(HFColors.textPrimary)
                Text(subtitle)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(HFColors.textMuted)
            }
        }
        .padding(.horizontal, 10)
        .frame(height: 42)
        .background(Color.white.opacity(0.07), in: Capsule())
        .overlay(Capsule().stroke(.white.opacity(0.12), lineWidth: 1))
    }

    private func creditRow(title: String, values: [String]) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(title)
                .font(HFTypography.caption.weight(.bold))
                .foregroundStyle(HFColors.textMuted)
                .frame(width: 118, alignment: .leading)

            Text(values.joined(separator: "  •  "))
                .font(HFTypography.caption.weight(.semibold))
                .foregroundStyle(HFColors.cyanGlow)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func detailArtwork(named assetName: String?, verticalOffset: CGFloat = 0) -> some View {
        if let assetName, HFPosterAssetHealth.hasImage(named: assetName) {
            Image(assetName)
                .resizable()
                .scaledToFill()
                .offset(y: verticalOffset)
        } else {
            ZStack {
                LinearGradient(
                    colors: [
                        HFColors.glassSurfaceRaised,
                        HFColors.background.opacity(0.94),
                        HFColors.goldDeep.opacity(0.28)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Image(systemName: "film.stack")
                    .font(.system(size: 32, weight: .black))
                    .foregroundStyle(HFColors.gold.opacity(0.80))
            }
        }
    }

    private func detailMiniPosterArtwork(
        named assetName: String?,
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        let tuning = HFPosterCropTuning.detailMini(movieID: movie.id)
        let effectiveScale = max(tuning.scale, 1 + ((abs(tuning.yOffset) * 2 + 2) / height))

        return ZStack {
            if let assetName, HFPosterAssetHealth.hasImage(named: assetName) {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: width * effectiveScale,
                        height: height * effectiveScale,
                        alignment: tuning.alignment
                    )
                    .offset(y: tuning.yOffset)
            } else {
                LinearGradient(
                    colors: [
                        HFColors.glassSurfaceRaised,
                        HFColors.background.opacity(0.94),
                        HFColors.goldDeep.opacity(0.28)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Image(systemName: "film.stack")
                    .font(.system(size: 32, weight: .black))
                    .foregroundStyle(HFColors.gold.opacity(0.80))
            }
        }
        .frame(width: width, height: height)
        .clipped()
    }

    private var primaryPosterShowcase: some View {
        VStack(alignment: .leading, spacing: 14) {
            primaryPosterSection

            compactTitleInfoBlock
                .padding(16)
                .background(titleInfoPanelBackground)
                .overlay(titleInfoPanelBorder)
                .shadow(color: .black.opacity(0.28), radius: 16, x: 0, y: 10)
                .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityIdentifier("hf.titleDetail.primaryPosterShowcase")
    }

    private var titleInfoPanelBackground: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.045),
                        HFColors.gold.opacity(0.035),
                        Color.black.opacity(0.12)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    private var titleInfoPanelBorder: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        HFColors.gold.opacity(0.16),
                        Color.white.opacity(0.08),
                        HFColors.gold.opacity(0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }

    private var primaryPosterSection: some View {
        let posterWidth = compactPrimaryPosterWidth
        let posterHeight = posterWidth * 1.5
        let framedHeight = posterHeight + HFDepthPosterScale.detail.padding * 2

        return ZStack {
            DepthMotionProvider(
                isEnabled: true,
                clamp: 1,
                geometryInfluence: HFCinematicDepthDirector.profile(for: .detailPoster).geometryInfluence,
                role: .detailPoster
            ) { motion in
                HFLayer4UltraDepthFX(
                    motion: motion,
                    role: .detailPoster,
                    tint: movie.id == "paranormall-s1" ? HFColors.cyanGlow : HFColors.gold,
                    showDust: true,
                    showFocusBreath: true
                )
            }
            .frame(height: framedHeight + 92)
            .opacity(0.58)

            DepthAtmosphereLayer(
                intensity: 0.58,
                tint: movie.id == "paranormall-s1" ? HFColors.cyanGlow : HFColors.gold
            )
            .frame(height: framedHeight + 92)
            .opacity(0.56)

            HStack {
                Spacer(minLength: 0)

                ZStack(alignment: .bottom) {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .black.opacity(0.0),
                                    .black.opacity(0.38),
                                    (movie.id == "paranormall-s1" ? HFColors.cyanGlow : HFColors.gold).opacity(0.16),
                                    .black.opacity(0.0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: posterWidth * 0.86, height: 24)
                        .blur(radius: 18)
                        .offset(y: 18)
                        .accessibilityHidden(true)

                    PremiumDepthPosterView(
                        width: posterWidth,
                        height: posterHeight,
                        scale: .detail,
                        role: .detailPoster,
                        depthEnabled: true
                    ) {
                        primaryDetailPosterImage(named: movie.posterAssetName, width: posterWidth, height: posterHeight)
                    }
                }
                .accessibilityIdentifier("hf.titleDetail.primaryPoster")

                Spacer(minLength: 0)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .frame(maxWidth: .infinity)
        .frame(height: framedHeight + 36)
        .accessibilityIdentifier("hf.titleDetail.primaryPosterSection")
        .background(
            Color.clear
                .frame(width: 1, height: 1)
                .accessibilityIdentifier("hf.v13.detail.hero")
        )
    }

    private var compactPrimaryHeroHeight: CGFloat {
        #if os(iOS)
        return min(UIScreen.main.bounds.height * 0.68, 620)
        #else
        return 620
        #endif
    }

    private var primaryHeroEdgeGlow: some View {
        ZStack {
            HStack {
                edgeGlowStrip
                Spacer(minLength: 0)
                edgeGlowStrip
            }

            VStack {
                horizontalGlowStrip
                Spacer(minLength: 0)
                horizontalGlowStrip
            }

            Rectangle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.08),
                            HFColors.gold.opacity(0.30),
                            Color(red: 0.95, green: 0.52, blue: 0.18).opacity(0.18),
                            Color.white.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .blendMode(.screen)
        }
        .accessibilityHidden(true)
    }

    private var edgeGlowStrip: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            HFColors.gold.opacity(0.08),
                            Color.white.opacity(0.18),
                            HFColors.gold.opacity(0.20),
                            Color(red: 0.98, green: 0.46, blue: 0.14).opacity(0.12)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 2)
                .blur(radius: 0.5)

            Rectangle()
                .fill(HFColors.gold.opacity(0.18))
                .frame(width: 18)
                .blur(radius: 20)
        }
    }

    private var horizontalGlowStrip: some View {
        Rectangle()
            .fill(HFColors.gold.opacity(0.12))
            .frame(height: 12)
            .blur(radius: 18)
    }

    private func primaryDetailPosterImage(named assetName: String?, width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            Color.black.opacity(0.94)

            if let assetName, HFPosterAssetHealth.hasImage(named: assetName) {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height)
                    .background(Color.black)
            } else {
                LinearGradient(
                    colors: [
                        HFColors.glassSurfaceRaised,
                        HFColors.background.opacity(0.94),
                        HFColors.goldDeep.opacity(0.28)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Image(systemName: "film.stack")
                    .font(.system(size: 44, weight: .black))
                    .foregroundStyle(HFColors.gold.opacity(0.82))
            }
        }
        .frame(width: width, height: height)
    }
}

private struct HFTitleTrailerPreviewSheet: View {
    let preview: HFTitleTrailerPreview
    @Environment(\.dismiss) private var dismiss
    @State private var player: AVPlayer

    init(preview: HFTitleTrailerPreview) {
        self.preview = preview
        _player = State(initialValue: AVPlayer(url: preview.url))
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            VideoPlayer(player: player)
                .ignoresSafeArea()
                .onAppear {
                    player.play()
                }
                .onDisappear {
                    player.pause()
                }

            Button {
                player.pause()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(.black.opacity(0.54), in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.18), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .padding(.top, 28)
            .padding(.trailing, 18)
            .accessibilityLabel("Close trailer")
        }
        .accessibilityIdentifier("hf.titleDetail.trailerPreviewSheet")
    }
}

private struct HFInlineTrailerPreviewView: View {
    let url: URL
    @State private var player: AVPlayer

    init(url: URL) {
        self.url = url
        let player = AVPlayer(url: url)
        player.isMuted = true
        _player = State(initialValue: player)
    }

    var body: some View {
        HFAspectFillAVPlayerView(
            player: player,
            showsPlaybackControls: false,
            videoGravity: .resizeAspectFill
        )
        .allowsHitTesting(false)
        .onAppear {
            player.isMuted = true
            player.play()
        }
        .onDisappear {
            player.pause()
        }
        .onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)) { notification in
            guard let endedItem = notification.object as? AVPlayerItem,
                  endedItem === player.currentItem else {
                return
            }
            player.seek(to: .zero)
            player.play()
        }
    }
}

struct MovieDetailView: View {
    let movie: Movie
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject private var streamingStore: HFStreamingStore
    @State private var verticalStageMovie: Movie?
    @State private var showsProtectedDepthPreview = false
    @State private var showsAccessReadiness = false
    @State private var showsPaywall = false
    #if DEBUG
    @State private var debugUnlockedMovieIDs: Set<String> = []
    #endif
    @State private var isDetailWorldAwake = false
    @State private var activeTrailerPreview: HFTitleTrailerPreview?
    @State private var selectedEpisodeNumber = 1

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

    private var isHighFivePassLockedTitle: Bool {
        HFStreamingAccessPolicy.isLockedOfficialTitle(catalogMovie)
    }

    private var isUnlockedForLocalTesting: Bool {
        #if DEBUG
        let debugUnlocked = isDebugPaywallUnlockAvailable && debugUnlockedMovieIDs.contains(catalogMovie.id)
        #else
        let debugUnlocked = false
        #endif

        return !isHighFivePassLockedTitle
            || streamingStore.hasVerifiedStoreKitAccess(for: catalogMovie)
            || debugUnlocked
    }

    private var showsInternalDetailDiagnostics: Bool {
        ProcessInfo.processInfo.arguments.contains("--hf-show-internal-diagnostics")
            || ProcessInfo.processInfo.arguments.contains("--hf-start-entitlement-gate")
            || ProcessInfo.processInfo.arguments.contains("--hf-start-download-boundary")
    }

    private var galleryAssets: [String] {
        HFMockData.galleryAssets(for: catalogMovie)
    }

    private var titleDetailMetadata: HFTitleDetailMetadata {
        HFTitleDetailMetadata.metadata(for: catalogMovie)
    }

    private var selectedEpisodeProductID: String {
        HFProductIdentifier.paranormallEpisode(selectedEpisodeNumber).rawValue
    }

    private var paranormallSeasonProductID: String {
        HFProductIdentifier.paranormallSeasonOneUnlock.rawValue
    }

    private var friendlyDisplayPrice: String {
        streamingStore.storeKitDisplayPrice(
            productID: HFProductIdentifier.theFriendlyMovie.rawValue,
            fallback: HFPurchaseDisplayPrice.friendly
        )
    }

    private var episodeDisplayPrice: String {
        streamingStore.storeKitDisplayPrice(
            productID: selectedEpisodeProductID,
            fallback: HFPurchaseDisplayPrice.paranormallEpisode
        )
    }

    private var seasonDisplayPrice: String {
        streamingStore.storeKitDisplayPrice(
            productID: paranormallSeasonProductID,
            fallback: HFPurchaseDisplayPrice.paranormallSeasonOne
        )
    }

    private var hasSelectedEpisodeAccess: Bool {
        streamingStore.hasVerifiedStoreKitAccess(for: catalogMovie, episodeNumber: selectedEpisodeNumber)
    }

    private var hasParanormallSeasonAccess: Bool {
        streamingStore.hasVerifiedStoreKitAccess(productID: paranormallSeasonProductID)
    }

    private var unlockedParanormallEpisodeNumbers: Set<Int> {
        Set((1...7).filter { episode in
            streamingStore.hasVerifiedStoreKitAccess(productID: HFProductIdentifier.paranormallEpisode(episode).rawValue)
        })
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                HFStreamingTitleDetailView(
                    movie: catalogMovie,
                    metadata: titleDetailMetadata,
                    isUnlocked: titleDetailMetadata.isSeries ? hasSelectedEpisodeAccess : isUnlockedForLocalTesting,
                    isLocked: isHighFivePassLockedTitle,
                    selectedEpisodeNumber: selectedEpisodeNumber,
                    isSeasonUnlocked: hasParanormallSeasonAccess,
                    isSelectedEpisodeUnlocked: hasSelectedEpisodeAccess,
                    unlockedEpisodeNumbers: unlockedParanormallEpisodeNumbers,
                    friendlyPrice: friendlyDisplayPrice,
                    episodePrice: episodeDisplayPrice,
                    seasonPrice: seasonDisplayPrice,
                    trailerPreviewURL: titleDetailMetadata.resolvedTrailerPreviewURL,
                    onWatchTrailer: {
                        startTrailerPreview()
                    },
                    onPrimaryAction: {
                        startPlaybackIfAllowed()
                    },
                    onEpisodePurchase: {
                        purchaseSelectedEpisode()
                    },
                    onSeasonPurchase: {
                        purchaseParanormallSeasonOne()
                    },
                    onEpisodeAction: { episodeNumber in
                        selectedEpisodeNumber = max(1, min(7, episodeNumber))
                        if streamingStore.hasVerifiedStoreKitAccess(for: catalogMovie, episodeNumber: selectedEpisodeNumber) {
                            startPlaybackIfAllowed()
                        }
                    }
                )
                if showsInternalDetailDiagnostics {
                    playbackStatusPanel
                    entitlementStatusPanel
                    downloadBoundaryPanel
                } else if isHighFivePassLockedTitle && !isUnlockedForLocalTesting {
                    lockedTitleAccessBand
                }
                relatedSection
            }
            .padding(.bottom, HFResponsiveFit.floatingTabContentClearance(dynamicTypeSize: dynamicTypeSize))
        }
        .accessibilityIdentifier("hf.consumer.movieDetail.root")
        .accessibilityIdentifier("hf.streaming.premium.movieDetail")
        .background(movieDetailCinematicBackground)
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
        .fullScreenCover(item: $verticalStageMovie) { movie in
            HFPlayerServiceSheet(movie: movie, startsInVerticalStage: true, initialEpisodeNumber: selectedEpisodeNumber)
                .environmentObject(streamingStore)
        }
        .sheet(isPresented: $showsProtectedDepthPreview) {
            HighFiveProtectedSpatialPeekBridge()
        }
        .sheet(isPresented: $showsAccessReadiness) {
            accessPlaybackReadinessSheet
        }
        .sheet(isPresented: $showsPaywall) {
            HFHighFivePassPaywallSheet(
                movie: catalogMovie,
                isDebugUnlockAvailable: isDebugPaywallUnlockAvailable,
                onDebugUnlock: {
                    #if DEBUG
                    debugUnlockedMovieIDs.insert(catalogMovie.id)
                    showsPaywall = false
                    startPlaybackIfAllowed()
                    #endif
                }
            )
            .environmentObject(streamingStore)
        }
        .sheet(item: $activeTrailerPreview) { preview in
            HFTitleTrailerPreviewSheet(preview: preview)
        }
        .onAppear {
            guard !isDetailWorldAwake else { return }
            withAnimation(reduceMotion ? .easeInOut(duration: 0.01) : HFSpatialMotionTokens.sceneEntranceAnimation) {
                isDetailWorldAwake = true
            }
            if ProcessInfo.processInfo.arguments.contains("--hf-start-paywall"), isHighFivePassLockedTitle {
                showsPaywall = true
            }
        }
    }

    private var movieDetailCinematicBackground: some View {
        ZStack {
            HFColors.screenBackground
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color.black,
                    HFColors.background.opacity(0.96),
                    Color(red: 0.030, green: 0.026, blue: 0.020)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            DepthMotionProvider(
                isEnabled: true,
                clamp: 0.75,
                geometryInfluence: HFCinematicDepthDirector.profile(for: .backgroundAtmosphere).geometryInfluence,
                role: .backgroundAtmosphere
            ) { motion in
                HFLayer4UltraDepthFX(
                    motion: motion,
                    role: .backgroundAtmosphere,
                    tint: catalogMovie.id == "paranormall-s1" ? HFColors.cyanGlow : HFColors.gold,
                    showDust: true,
                    showFocusBreath: false
                )
                .opacity(0.42)
            }
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    (catalogMovie.id == "paranormall-s1" ? HFColors.cyanGlow : HFColors.gold).opacity(0.12),
                    .clear
                ],
                center: .top,
                startRadius: 24,
                endRadius: 620
            )
            .ignoresSafeArea()

            LinearGradient(
                colors: [
                    .black.opacity(0.32),
                    .clear,
                    .black.opacity(0.76)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }

    private var figmaDetailHero: some View {
        ZStack(alignment: .bottomLeading) {
            detailArtwork
                .frame(height: 610)
                .clipped()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.05),
                    Color.black.opacity(0.28),
                    Color.black.opacity(0.90),
                    HFColors.background
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack {
                    Text(catalogMovie.genres.first ?? "Movies")
                    Image(systemName: "chevron.down")
                    Text("All Categories")
                    Image(systemName: "chevron.down")
                    Spacer()
                }
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .padding(.top, HFSpacing.xl)

                Spacer()

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text(catalogMovie.title)
                        .font(.system(size: 44, weight: .black))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.60)

                    Text(catalogMovie.subtitle)
                        .font(HFTypography.body)
                        .foregroundStyle(.white.opacity(0.86))
                        .lineLimit(2)

                    metadataChips

                    HStack(spacing: HFSpacing.sm) {
                        Button {
                            startPlaybackIfAllowed()
                        } label: {
                            Label(isHighFivePassLockedTitle && !isUnlockedForLocalTesting ? "Unlock" : "Play Now", systemImage: "play.fill")
                                .font(HFTypography.smallAction)
                                .foregroundStyle(.black)
                                .frame(width: 150, height: 46)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        .buttonStyle(.plain)

                        Button {
                            streamingStore.toggleSaved(catalogMovie)
                        } label: {
                            Image(systemName: streamingStore.isSaved(catalogMovie) ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 25, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 54, height: 46)
                        }
                        .buttonStyle(.plain)

                        Button {
                            streamingStore.queueOfflineAsset(for: catalogMovie)
                        } label: {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 54, height: 46)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, HFSpacing.xl)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .frame(height: 610)
        .clipped()
        .accessibilityIdentifier("hf.rsf02.movieDetail.hero")
    }

    private var isDebugPaywallUnlockAvailable: Bool {
        HFStreamingAccessPolicy.isDebugPaywallUnlockAvailable
    }

    private func startPlaybackIfAllowed() {
        let canPlay = titleDetailMetadata.isSeries ? hasSelectedEpisodeAccess : isUnlockedForLocalTesting
        guard canPlay else {
            showsPaywall = true
            return
        }

        streamingStore.markStartedWatching(catalogMovie)
        verticalStageMovie = catalogMovie
    }

    private func purchaseSelectedEpisode() {
        guard catalogMovie.id == "paranormall-s1" else {
            showsPaywall = true
            return
        }

        Task {
            _ = await streamingStore.purchaseStoreKitAccess(productID: selectedEpisodeProductID)
            await MainActor.run {
                if streamingStore.hasVerifiedStoreKitAccess(for: catalogMovie, episodeNumber: selectedEpisodeNumber) {
                    startPlaybackIfAllowed()
                }
            }
        }
    }

    private func purchaseParanormallSeasonOne() {
        guard catalogMovie.id == "paranormall-s1" else {
            showsPaywall = true
            return
        }

        Task {
            _ = await streamingStore.purchaseStoreKitAccess(productID: paranormallSeasonProductID)
            await MainActor.run {
                if streamingStore.hasVerifiedStoreKitAccess(for: catalogMovie, episodeNumber: selectedEpisodeNumber) {
                    startPlaybackIfAllowed()
                }
            }
        }
    }

    private func startTrailerPreview() {
        guard let url = titleDetailMetadata.resolvedTrailerPreviewURL else { return }
        logDetailPlaybackSource(intent: "preview", source: "trailerPreview", url: url)
        activeTrailerPreview = HFTitleTrailerPreview(title: titleDetailMetadata.displayTitle, url: url)
    }

    private func logDetailPlaybackSource(intent: String, source: String, url: URL?) {
        #if DEBUG
        let urlDescription = url?.absoluteString ?? "nil"
        print("[PlaybackSource] movie=\(catalogMovie.title) intent=\(intent) source=\(source) url=\(urlDescription)")
        #endif
    }

    private var lockedTitleAccessBand: some View {
        HStack(spacing: HFSpacing.md) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(HFColors.gold)
                .frame(width: 46, height: 46)
                .background(Color.white.opacity(0.08))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text("HighFive Pass")
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                Text("This title opens the HighFive Pass before playback.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: HFSpacing.sm)

            Button {
                showsPaywall = true
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(.black)
                    .frame(width: 38, height: 38)
                    .background(HFColors.gold)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open HighFive Pass")
        }
        .padding(HFSpacing.md)
        .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(HFColors.gold.opacity(0.28), lineWidth: 1))
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.movieDetail.lockedAccessBand")
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
                            startPlaybackIfAllowed()
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
        .accessibilityIdentifier("hf.streaming.premium.movieDetail")
        .hfSpatialFocalHandoff(
            "hf.spatial.handoff.homeToMovie",
            "hf.spatial.handoff.movieToPlayer",
            "hf.spatial.handoff.movieToConnect",
            "hf.spatial.handoff.movieToCreator"
        )
    }

    private var premiumDetailBrandLayer: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: catalogMovie.isOriginal ? "sparkles.tv.fill" : "film.stack.fill")
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(.black)
                        .frame(width: 54, height: 54)
                        .background(HFColors.goldGradient)
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text(catalogMovie.isOriginal ? "HighFive Original" : "Premium Title World")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("A cinematic metadata surface for local preview, creator context, premiere cards, and related collections.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 128), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    premiumDetailSignal(title: "Creator", value: creator.name, color: HFColors.violet)
                    premiumDetailSignal(title: "Premiere", value: catalogMovie.year, color: HFColors.gold)
                    premiumDetailSignal(title: "Collection", value: catalogMovie.genres.first ?? "Cinema", color: HFColors.cyanGlow)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: HFSpacing.sm) {
                        NavigationLink(value: creator) {
                            premiumDetailCard(title: "Creator Profile", detail: creator.role, systemImage: "person.crop.rectangle.stack.fill", color: HFColors.violet)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("hf.route.movieDetailToCreatorProfile")
                        premiumDetailCard(title: "Premiere Preview", detail: "Available in local catalog", systemImage: "sparkles.tv.fill", color: HFColors.gold)
                        premiumDetailCard(title: "Related World", detail: "\(relatedTitles.count) connected titles", systemImage: "rectangle.stack.fill", color: HFColors.cyanGlow)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Premium movie detail brand layer for \(catalogMovie.title)")
    }

    private func premiumDetailSignal(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
            Text(title)
                .font(HFTypography.micro)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.xs)
        .background(Color.black.opacity(0.28))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
    }

    private func premiumDetailCard(title: String, detail: String, systemImage: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(color == HFColors.gold ? .black : color)
                .frame(width: 42, height: 42)
                .background(color == HFColors.gold ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(color.opacity(0.18)))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                Text(detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
            }
        }
        .frame(width: 210, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(color.opacity(0.24), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
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
                        Text("Locked originals require verified StoreKit access before playback.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                HFPlaybackBoundaryRow(
                    title: "StoreKit Access",
                    detail: streamingStore.verifiedStoreKitProductIDs.isEmpty ? "No verified product entitlement is active." : "\(streamingStore.verifiedStoreKitProductIDs.count) verified product entitlement(s) active.",
                    status: entitlementStatus.accessState.statusLabel,
                    identifier: "hf.entitlement.localPreviewAccess"
                )

                HFPlaybackBoundaryRow(
                    title: "Restore Purchases",
                    detail: streamingStore.storeKitRestoreStatusMessage,
                    status: streamingStore.monetizationRuntimeSnapshot.restoreState,
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
                    detail: "Purchase and restore actions are wired to StoreKit 2 and verified entitlements.",
                    status: "StoreKit 2 Ready",
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
            NavigationLink(value: creator) {
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
                            Label("Open Creator Profile", systemImage: "arrow.right.circle.fill")
                                .font(HFTypography.micro.weight(.bold))
                                .foregroundStyle(HFColors.gold)
                        }
                        Spacer()
                    }
                    .padding(HFSpacing.md)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, HFSpacing.screenHorizontal)
            .accessibilityIdentifier("hf.route.movieDetailToCreatorProfile")
        }
    }

    private var relatedSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "More Like This", actionTitle: nil)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: HFSpacing.md) {
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
        .background(
            Color.clear
                .frame(width: 1, height: 1)
                .accessibilityIdentifier("hf.v13.detail.recommendations")
        )
    }

    private var castSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Cast & Creators", actionTitle: nil)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: HFSpacing.sm) {
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
                    LazyHStack(spacing: HFSpacing.md) {
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
        } else {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                HFSectionHeader(title: "Scenes", actionTitle: "Preview")
                HFContentStateCard(
                    kind: .placeholder,
                    title: "Scene gallery placeholder",
                    message: "Gallery stills will appear here when title artwork is available in the local catalog.",
                    isCompact: true
                )
                .padding(.horizontal, HFSpacing.screenHorizontal)
                .accessibilityIdentifier("hf.movieDetail.gallery.placeholder")
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

private struct HFHighFivePassPaywallSheet: View {
    let movie: Movie
    let isDebugUnlockAvailable: Bool
    let onDebugUnlock: () -> Void

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var streamingStore: HFStreamingStore
    @State private var statusMessage = "Purchase or restore with your App Store account."
    @State private var isCheckingRestore = false
    @State private var isPurchasing = false

    private var productID: String {
        HFStoreKitAccessMapping.rule(forCurrentMovieID: movie.id).productReference.productIdentifier.rawValue
    }

    private var fallbackPrice: String {
        switch movie.id {
        case "friendly":
            return HFPurchaseDisplayPrice.friendly
        case "paranormall-s1":
            return HFPurchaseDisplayPrice.paranormallSeasonOne
        default:
            return ""
        }
    }

    private var purchaseButtonTitle: String {
        let price = streamingStore.storeKitDisplayPrice(productID: productID, fallback: fallbackPrice)
        if price.isEmpty {
            return "Unlock with HighFive Pass"
        }
        return movie.id == "paranormall-s1" ? "Unlock Season 1 - \(price)" : "Unlock Full Movie - \(price)"
    }

    var body: some View {
        ZStack {
            HFColors.screenBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("HighFive Pass")
                            .font(.system(size: 34, weight: .black))
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)

                        Text(movie.title)
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.gold)
                            .lineLimit(2)
                    }

                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(HFColors.textPrimary)
                            .frame(width: 42, height: 42)
                            .background(Color.white.opacity(0.10))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close paywall")
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    paywallBenefit("Protected streaming access", "Locked titles require HighFive Pass before playback.")
                    paywallBenefit("Depth + Tilt ready", "Player depth and tilt controls remain available after access.")
                    paywallBenefit("Restore Purchases", streamingStore.storeKitRestoreStatusMessage)
                }
                .padding(HFSpacing.md)
                .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(HFColors.gold.opacity(0.24), lineWidth: 1))

                Text(statusMessage)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.paywall.status")

                VStack(spacing: HFSpacing.sm) {
                    Button {
                        guard !isPurchasing else { return }
                        isPurchasing = true
                        statusMessage = "Opening App Store purchase..."
                        Task {
                            let message = await streamingStore.purchaseStoreKitAccess(for: movie)
                            await MainActor.run {
                                statusMessage = message
                                isPurchasing = false
                                if streamingStore.hasVerifiedStoreKitAccess(for: movie) {
                                    dismiss()
                                }
                            }
                        }
                    } label: {
                        Label(isPurchasing ? "Opening App Store" : purchaseButtonTitle, systemImage: "cart.badge.plus")
                            .font(HFTypography.smallAction)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(HFColors.goldGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(isPurchasing || isCheckingRestore)
                    .accessibilityIdentifier("hf.paywall.purchase")

                    Button {
                        guard !isCheckingRestore else { return }
                        isCheckingRestore = true
                        statusMessage = "Checking App Store purchases..."
                        Task {
                            let message = await streamingStore.restoreStoreKitPurchases()
                            await MainActor.run {
                                statusMessage = message
                                isCheckingRestore = false
                                if streamingStore.hasVerifiedStoreKitAccess(for: movie) {
                                    dismiss()
                                }
                            }
                        }
                    } label: {
                        Label(isCheckingRestore ? "Checking Restore" : "Restore Purchases", systemImage: "arrow.counterclockwise.circle.fill")
                            .font(HFTypography.smallAction)
                            .foregroundStyle(HFColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.white.opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(isPurchasing || isCheckingRestore)
                    .accessibilityIdentifier("hf.paywall.restorePurchases")

                    if isDebugUnlockAvailable {
                        Button {
                            statusMessage = "DEBUG unlock granted for this simulator session."
                            onDebugUnlock()
                        } label: {
                            Label("DEBUG Test Unlock", systemImage: "lock.open.fill")
                                .font(HFTypography.smallAction)
                                .foregroundStyle(HFColors.gold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.white.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("hf.paywall.debugUnlock")
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(HFSpacing.lg)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .accessibilityIdentifier("hf.paywall.highFivePass")
    }

    private func paywallBenefit(_ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(HFColors.gold)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                Text(detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

enum HFPlayerSurfaceFocus: String, CaseIterable, Identifiable {
    case cinema
    case controls
    case metadata
    case watchTogether
    case creatorCommentary
    case polish

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .cinema: return "Cinema"
        case .controls: return "Controls"
        case .metadata: return "Metadata"
        case .watchTogether: return "Watch Together"
        case .creatorCommentary: return "Creator Commentary"
        case .polish: return "Player Polish"
        }
    }

    var systemImage: String {
        switch self {
        case .cinema: return "play.rectangle.fill"
        case .controls: return "slider.horizontal.3"
        case .metadata: return "info.circle.fill"
        case .watchTogether: return "person.2.fill"
        case .creatorCommentary: return "quote.bubble.fill"
        case .polish: return "sparkles.tv.fill"
        }
    }

    var accent: Color {
        switch self {
        case .watchTogether:
            return HFColors.cyanGlow
        case .creatorCommentary:
            return HFColors.violet
        case .polish:
            return HFColors.cyanGlow
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
    let startsInVerticalStage: Bool
    let contentSource: HFPlaybackContentSource
    let importedVideoURL: URL?
    let initialEpisodeNumber: Int
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var streamingStore: HFStreamingStore
    @State private var showsProtectedDepthPreview = false
    @State private var showsPlayerDetails = false
    @State private var isSceneReady = false
    @State private var didRequestPlaybackRuntime = false
    @State private var selectedSurface: HFPlayerSurfaceFocus
    @State private var activePlayer: AVPlayer?
    @State private var activePlaybackURL: URL?
    @State private var activeSourceLabel = "No media source selected."
    @State private var sourceErrorMessage: String?
    @State private var selectedEpisodeNumber = 1
    @State private var showsVideoImporter = false
    @State private var showsFullVerticalPlayer = false
    @State private var didDismissDirectFullVerticalPlayer = false
    @State private var didCloseDirectPlayerRoute = false
    @State private var didAutoOpenFullVerticalPlayer = false
    @State private var pendingImportReference: HFBuild5ReferenceVideo?
    @State private var showsPaywall = false
    #if DEBUG
    @State private var debugUnlockedMovieIDs: Set<String> = []
    #endif

    init(
        movie: Movie,
        initialSurface: HFPlayerSurfaceFocus = .cinema,
        startsInVerticalStage: Bool = false,
        contentSource: HFPlaybackContentSource = .officialCatalog,
        importedVideoURL: URL? = nil,
        initialEpisodeNumber: Int = 1
    ) {
        let safeEpisodeNumber = max(1, min(7, initialEpisodeNumber))
        self.movie = movie
        self.initialSurface = initialSurface
        self.startsInVerticalStage = startsInVerticalStage
        self.contentSource = contentSource
        self.importedVideoURL = importedVideoURL
        self.initialEpisodeNumber = safeEpisodeNumber
        _selectedSurface = State(initialValue: initialSurface)
        _selectedEpisodeNumber = State(initialValue: safeEpisodeNumber)
    }

    private var catalogMovie: Movie {
        streamingStore.movie(id: movie.id) ?? movie
    }

    private var gatedPlaybackDescriptor: HFPlaybackDescriptorAccessResponse {
        streamingStore.entitlementGatedPlaybackDescriptor(for: catalogMovie)
    }

    private var playbackRuntimeSnapshot: HFStreamingPlaybackRuntimeSnapshot {
        streamingStore.streamingPlaybackRuntimeSnapshot
    }

    private var shouldStartFullVerticalPlayer: Bool {
        startsInVerticalStage || CommandLine.arguments.contains("--hf-start-player-fullscreen")
    }

    private var allowsImportControls: Bool {
        contentSource == .userImported
    }

    private var isLockedOfficialTitle: Bool {
        contentSource == .officialCatalog
            && HFStreamingAccessPolicy.isLockedOfficialTitle(catalogMovie)
    }

    private var isPlaybackAllowed: Bool {
        #if DEBUG
        let debugUnlocked = HFStreamingAccessPolicy.isDebugPaywallUnlockAvailable && debugUnlockedMovieIDs.contains(catalogMovie.id)
        #else
        let debugUnlocked = false
        #endif

        return !isLockedOfficialTitle
            || streamingStore.hasVerifiedStoreKitAccess(
                for: catalogMovie,
                episodeNumber: catalogMovie.id == "paranormall-s1" ? selectedEpisodeNumber : nil
            )
            || debugUnlocked
    }

    private var isDirectPlayerRoute: Bool {
        let arguments = CommandLine.arguments
        return arguments.contains("--hf-start-player")
            || arguments.contains("--hf-fpp-player-polish")
            || arguments.contains("--hf-start-streaming-playback-runtime")
            || arguments.contains("--hf-playback-hls")
            || arguments.contains("--hf-playback-session")
            || arguments.contains("--hf-playback-tracks")
            || arguments.contains("--hf-playback-next-episode")
            || arguments.contains("--hf-playback-error")
    }

    private var isShowingDirectFullVerticalPlayer: Bool {
        showsFullVerticalPlayer && !didDismissDirectFullVerticalPlayer
    }

    private var showsInternalPlaybackDiagnostics: Bool {
        let arguments = CommandLine.arguments
        return arguments.contains("--hf-player-diagnostics")
            || arguments.contains("--hf-start-player-metadata")
            || arguments.contains("--hf-start-streaming-playback-runtime")
            || arguments.contains("--hf-playback-hls")
            || arguments.contains("--hf-playback-session")
            || arguments.contains("--hf-playback-tracks")
            || arguments.contains("--hf-playback-next-episode")
            || arguments.contains("--hf-playback-error")
    }

    var body: some View {
        Group {
            if didCloseDirectPlayerRoute {
                MovieDetailView(movie: catalogMovie)
            } else {
                ZStack {
                    if isShowingDirectFullVerticalPlayer {
                        HFFullVerticalDepthPlayer(
                            player: activePlayer,
                            title: catalogMovie.title,
                            sourceLabel: activeSourceLabel,
                            sourceErrorMessage: sourceErrorMessage,
                            contentSource: contentSource,
                            importReferenceTitle: allowsImportControls ? preferredReferenceVideoForImport?.shortTitle : nil,
                            onClose: {
                                closePlayerSurface()
                            },
                            onImportMovie: allowsImportControls ? {
                                pendingImportReference = preferredReferenceVideoForImport
                                showsVideoImporter = true
                            } : nil
                        )
                    } else {
                        HFColors.screenBackground
                            .ignoresSafeArea()

                        atmosphereLayer

                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                                header
                                playerPreview
                                cleanPlaybackState
                                if showsInternalPlaybackDiagnostics {
                                    playerPolishStatusStrip
                                }
                                if showsInternalPlaybackDiagnostics && selectedSurface == .polish {
                                    playerPolishReviewSurface
                                }
                                if showsInternalPlaybackDiagnostics {
                                    playbackRuntimeSurface
                                    routeSpotlight
                                    premiumTimeline
                                }
                                floatingControls
                                if showsInternalPlaybackDiagnostics {
                                    viewerIntelligenceStrip
                                    gatewaySurface
                                    metadataSurface
                                }
                            }
                            .padding(HFSpacing.lg)
                            .padding(.bottom, HFSpacing.xxl)
                        }
                    }
                }
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
        .sheet(isPresented: $showsPaywall) {
            HFHighFivePassPaywallSheet(
                movie: catalogMovie,
                isDebugUnlockAvailable: HFStreamingAccessPolicy.isDebugPaywallUnlockAvailable,
                onDebugUnlock: {
                    #if DEBUG
                    debugUnlockedMovieIDs.insert(catalogMovie.id)
                    showsPaywall = false
                    configureInitialPlaybackSourceIfNeeded(force: true)
                    #endif
                }
            )
            .environmentObject(streamingStore)
        }
        .fileImporter(
            isPresented: $showsVideoImporter,
            allowedContentTypes: [.movie, .video, .mpeg4Movie, .quickTimeMovie],
            allowsMultipleSelection: false
        ) { result in
            let importReference = pendingImportReference
            pendingImportReference = nil
            handleImportedVideo(result, as: importReference)
        }
        .onAppear {
            if isLockedOfficialTitle, !isPlaybackAllowed {
                activePlayer?.pause()
                activePlayer = nil
                activePlaybackURL = nil
                activeSourceLabel = "HighFive Pass required."
                sourceErrorMessage = "Unlock \(catalogMovie.title) with HighFive Pass before playback."
                showsPaywall = true
                return
            }
            configureInitialPlaybackSourceIfNeeded()
            guard !isSceneReady else { return }
            withAnimation(reduceMotion ? .easeInOut(duration: 0.01) : HFSpatialMotionTokens.sceneEntranceAnimation) {
                isSceneReady = true
            }
        }
        .onDisappear {
            activePlayer?.pause()
        }
        .task {
            guard !didRequestPlaybackRuntime else { return }
            didRequestPlaybackRuntime = true
            await streamingStore.runStreamingPlaybackRuntimeFixture(for: catalogMovie)
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
                Text(activePlaybackURL == nil ? "Preparing your preview." : activeSourceLabel)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Button {
                closePlayerSurface()
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

    private func closePlayerSurface() {
        activePlayer?.pause()
        didDismissDirectFullVerticalPlayer = true
        if isDirectPlayerRoute {
            didCloseDirectPlayerRoute = true
        }
        dismiss()
    }

    private var cleanPlaybackState: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text(activePlaybackURL == nil ? missingSourceTitle : "Ready to Watch")
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(.white)
            Text(sourceErrorMessage ?? (activePlaybackURL == nil ? missingSourceMessage : activeSourceLabel))
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if activePlayer == nil, allowsImportControls {
                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    if let importReference = preferredReferenceVideoForImport {
                        Button {
                            pendingImportReference = importReference
                            showsVideoImporter = true
                        } label: {
                            Label("Import \(importReference.shortTitle)", systemImage: "folder.badge.plus")
                                .font(HFTypography.smallAction)
                                .foregroundStyle(.black)
                                .frame(height: 44)
                                .padding(.horizontal, HFSpacing.md)
                                .background(HFColors.gold)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("hf.player.importExpectedMovie")

                        Text("Select \(importReference.filename) from Files. HighFive will save it for future playback on this device.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Button {
                        pendingImportReference = nil
                        showsVideoImporter = true
                    } label: {
                        Label("Choose Any Video", systemImage: "folder")
                            .font(HFTypography.caption.weight(.bold))
                            .foregroundStyle(HFColors.textPrimary)
                            .frame(height: 38)
                            .padding(.horizontal, HFSpacing.sm)
                            .background(Color.white.opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.player.chooseAnyVideo")
                }
                .padding(.top, HFSpacing.xs)
            } else if let activePlayer {
                HStack(spacing: HFSpacing.sm) {
                    Button {
                        activePlayer.pause()
                        showsFullVerticalPlayer = true
                    } label: {
                        Label("Full Vertical", systemImage: "rectangle.portrait.fill")
                            .font(HFTypography.smallAction)
                            .foregroundStyle(.white)
                            .frame(height: 44)
                            .padding(.horizontal, HFSpacing.md)
                            .background(Color.white.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.player.watchFullScreen")
                }
                .padding(.top, HFSpacing.xs)
            }
        }
        .padding(HFSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityIdentifier("hf.rsf02.player.state")
    }

    private var missingSourceTitle: String {
        switch contentSource {
        case .officialCatalog:
            return isLockedOfficialTitle && !isPlaybackAllowed ? "HighFive Pass Required" : "Stream Unavailable"
        case .userImported:
            return "Import Video"
        }
    }

    private var missingSourceMessage: String {
        switch contentSource {
        case .officialCatalog:
            return "This title is not available for playback yet."
        case .userImported:
            return "Choose a video from the Import Videos area on Home."
        }
    }

    private var playerPreview: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            ZStack(alignment: .bottomLeading) {
                if let activePlayer {
                    HFAspectFillAVPlayerView(
                        player: activePlayer,
                        showsPlaybackControls: true,
                        videoGravity: .resizeAspect
                    )
                        .background(Color.black)
                        .onAppear {
                            activePlayer.play()
                        }
                } else if HFPosterAssetHealth.hasImage(named: catalogMovie.backdropAssetName ?? catalogMovie.posterAssetName),
                          let assetName = catalogMovie.backdropAssetName ?? catalogMovie.posterAssetName {
                    Image(assetName)
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(reduceMotion ? 1 : (isSceneReady ? 1.025 : 1.0))
                        .offset(y: reduceMotion ? 0 : (isSceneReady ? -3 : 5))
                    LinearGradient(colors: [.clear, Color.black.opacity(0.86)], startPoint: .top, endPoint: .bottom)
                    fallbackSourceOverlay
                } else {
                    playerArtworkFallback
                    fallbackSourceOverlay
                }
            }
            .frame(height: 390)
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous)
                    .stroke(HFColors.goldStroke, lineWidth: 1)
            )

            referenceEpisodeSelector
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Player frame, \(catalogMovie.title), \(activePlaybackURL == nil ? "source required" : "source connected")")
        .accessibilitySortPriority(9)
        .accessibilityIdentifier("hf.player.cinematicFrame")
    }

    private var fallbackSourceOverlay: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HStack(alignment: .center, spacing: HFSpacing.md) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 58, weight: .black))
                    .foregroundStyle(HFColors.gold)
                    .shadow(color: HFColors.amberGlow.opacity(0.42), radius: 18)

                VStack(alignment: .leading, spacing: 4) {
                    Text(activePlaybackURL == nil ? "Preparing Preview" : "Ready to Watch")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    Text(catalogMovie.metadataLine)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                }
            }

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 112), spacing: HFSpacing.xs)],
                alignment: .leading,
                spacing: HFSpacing.xs
            ) {
                HFPlayerStatusPill(title: "Cinema Mode", color: HFColors.gold)
                HFPlayerStatusPill(title: playbackRuntimeSnapshot.playbackFormat, color: HFColors.cyanGlow)
                HFPlayerStatusPill(title: "Depth Ready", color: HFColors.gold)
                HFPlayerStatusPill(title: "Tilt Ready", color: HFColors.cyanGlow)
            }
        }
        .padding(HFSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var referenceEpisodeSelector: some View {
        let availableVideos = availableReferenceVideos
        if !availableVideos.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HFSpacing.xs) {
                    ForEach(availableVideos) { reference in
                        Button {
                            selectedEpisodeNumber = reference.episodeNumber ?? selectedEpisodeNumber
                            loadPlayer(from: reference)
                        } label: {
                            Text(reference.shortTitle)
                                .font(HFTypography.micro.weight(.bold))
                                .foregroundStyle(reference.isSelected(selectedEpisodeNumber, for: catalogMovie) ? .black : HFColors.textPrimary)
                                .padding(.horizontal, HFSpacing.sm)
                                .frame(height: 34)
                                .background(reference.isSelected(selectedEpisodeNumber, for: catalogMovie) ? HFColors.gold : Color.white.opacity(0.10))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }
            .accessibilityIdentifier("hf.player.referenceVideoSelector")
        }
    }

    private var availableReferenceVideos: [HFBuild5ReferenceVideo] {
        guard contentSource == .officialCatalog else { return [] }
        return referenceVideos.filter(\.isAvailable)
    }

    private var preferredReferenceVideoForImport: HFBuild5ReferenceVideo? {
        guard allowsImportControls else { return nil }
        return referenceVideos.first { $0.isSelected(selectedEpisodeNumber, for: catalogMovie) }
            ?? referenceVideos.first
    }

    private var referenceVideos: [HFBuild5ReferenceVideo] {
        guard contentSource == .officialCatalog else { return [] }
        switch catalogMovie.id {
        case "friendly":
            return [
                HFBuild5ReferenceVideo(
                    id: "friendly",
                    title: "The Friendly",
                    shortTitle: "Friendly",
                    filename: "TheFriendly_ref.mp4",
                    episodeNumber: nil
                )
            ]
        case "paranormall-s1":
            return (1...7).map { (episode: Int) -> HFBuild5ReferenceVideo in
                HFBuild5ReferenceVideo(
                    id: "paranormall-s1-e\(episode)",
                    title: "Paranormall Episode \(episode)",
                    shortTitle: "E\(episode)",
                    filename: "Paranormall_E\(episode)_ref.mp4",
                    episodeNumber: episode
                )
            }
        default:
            return []
        }
    }

    private func configureInitialPlaybackSourceIfNeeded(force: Bool = false) {
        guard force || activePlayer == nil else { return }
        guard isPlaybackAllowed else {
            activePlayer?.pause()
            activePlayer = nil
            activePlaybackURL = nil
            activeSourceLabel = "HighFive Pass required."
            sourceErrorMessage = "Unlock \(catalogMovie.title) with HighFive Pass before playback."
            return
        }

        if contentSource == .userImported {
            activePlayer?.pause()
            sourceErrorMessage = nil

            if let importedVideoURL,
               FileManager.default.fileExists(atPath: importedVideoURL.path) {
                loadPlayer(url: importedVideoURL, sourceLabel: "Imported video: \(catalogMovie.title)")
                scheduleFullVerticalPlayerOpenIfNeeded(force: true)
            } else {
                activePlayer = nil
                activePlaybackURL = nil
                activeSourceLabel = "Imported video missing."
                sourceErrorMessage = "The imported video file is missing. Re-import from the Import Videos card on Home."
                scheduleFullVerticalPlayerOpenIfNeeded(force: true)
            }
            return
        }

        sourceErrorMessage = nil

        let requestedEpisodeNumber = catalogMovie.id == "paranormall-s1" ? selectedEpisodeNumber : nil
        guard let officialURL = HFOfficialStreamResolver.fullStreamURL(for: catalogMovie.id, episodeNumber: requestedEpisodeNumber) else {
            activePlayer?.pause()
            activePlayer = nil
            activePlaybackURL = nil
            activeSourceLabel = "Stream unavailable."
            sourceErrorMessage = "This title is not available for playback yet."
            logPlaybackSource(intent: "full", source: "missingOfficialFullStream", url: nil)
            scheduleFullVerticalPlayerOpenIfNeeded(force: true)
            return
        }

        logPlaybackSource(intent: "full", source: "officialFullStream", url: officialURL)
        #if DEBUG
        print("[PlaybackSource] official full source resolved movie=\(catalogMovie.id) episode=\(requestedEpisodeNumber.map(String.init) ?? "nil") url=\(officialURL)")
        #endif
        let sourceLabel: String
        if let requestedEpisodeNumber {
            sourceLabel = "Now playing: \(catalogMovie.title) Episode \(requestedEpisodeNumber)"
        } else {
            sourceLabel = "Now playing: \(catalogMovie.title)"
        }
        loadPlayer(url: officialURL, sourceLabel: sourceLabel)
        scheduleFullVerticalPlayerOpenIfNeeded(force: true)
    }

    private func loadPlayer(from reference: HFBuild5ReferenceVideo) {
        guard let url = reference.resolvedURL else {
            activePlayer?.pause()
            activePlayer = nil
            activePlaybackURL = nil
            activeSourceLabel = "Stream unavailable."
            sourceErrorMessage = "This title is not available for playback yet."
            logPlaybackSource(intent: "full", source: "missingFullSource", url: nil)
            scheduleFullVerticalPlayerOpenIfNeeded(force: true)
            return
        }

        logPlaybackSource(intent: "full", source: "fullReference", url: url)
        loadPlayer(url: url, sourceLabel: "Now playing: \(reference.title)")
        scheduleFullVerticalPlayerOpenIfNeeded()
    }

    private func loadPlayer(url: URL, sourceLabel: String) {
        activePlayer?.pause()
        activePlaybackURL = url
        activeSourceLabel = sourceLabel
        sourceErrorMessage = nil
        let item = AVPlayerItem(url: url)
        item.preferredPeakBitRate = 0
        item.preferredMaximumResolution = CGSize(width: 1920, height: 1080)
        item.preferredForwardBufferDuration = 5
        let player = AVPlayer(playerItem: item)
        player.automaticallyWaitsToMinimizeStalling = true
        activePlayer = player
    }

    private func logPlaybackSource(intent: String, source: String, url: URL?) {
        #if DEBUG
        let urlDescription = url?.absoluteString ?? "nil"
        print("[PlaybackSource] movie=\(catalogMovie.title) intent=\(intent) source=\(source) url=\(urlDescription)")
        #endif
    }

    private func scheduleFullVerticalPlayerOpenIfNeeded(force: Bool = false) {
        guard (force || shouldStartFullVerticalPlayer), !didAutoOpenFullVerticalPlayer else { return }
        didAutoOpenFullVerticalPlayer = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            showsFullVerticalPlayer = true
        }
    }

    private func handleImportedVideo(_ result: Result<[URL], Error>, as reference: HFBuild5ReferenceVideo?) {
        guard allowsImportControls else { return }
        do {
            guard let sourceURL = try result.get().first else { return }
            let sandboxURL = try copyImportedVideoIntoSandbox(sourceURL, expectedFilename: reference?.filename)
            if let reference {
                selectedEpisodeNumber = reference.episodeNumber ?? selectedEpisodeNumber
                loadPlayer(url: sandboxURL, sourceLabel: "Now playing: \(reference.title)")
            } else {
                loadPlayer(url: sandboxURL, sourceLabel: "Now playing: \(catalogMovie.title)")
            }
            showsFullVerticalPlayer = true
        } catch {
            activePlayer?.pause()
            activePlayer = nil
            activePlaybackURL = nil
            sourceErrorMessage = "Import failed: \(error.localizedDescription)"
        }
    }

    private func bundledPreviewVideoURL() -> URL? {
        let names = ["Timeline1", "timeline1", "HighFive", "highfive", "intro", "Intro"]
        let subdirectories: [String?] = [nil, "App/Resources/Intro", "Resources/Intro"]
        for name in names {
            for extensionName in ["mov", "mp4", "m4v"] {
                for subdirectory in subdirectories {
                    let url: URL?
                    if let subdirectory {
                        url = Bundle.main.url(forResource: name, withExtension: extensionName, subdirectory: subdirectory)
                    } else {
                        url = Bundle.main.url(forResource: name, withExtension: extensionName)
                    }
                    if let url {
                        return url
                    }
                }
            }
        }
        return nil
    }

    private func copyImportedVideoIntoSandbox(_ sourceURL: URL, expectedFilename: String? = nil) throws -> URL {
        let didStartAccess = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if didStartAccess {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }

        let fileManager = FileManager.default
        let supportDirectory = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let importDirectory = supportDirectory.appendingPathComponent("ImportedVideos", isDirectory: true)
        try fileManager.createDirectory(at: importDirectory, withIntermediateDirectories: true)

        let safeName = expectedFilename ?? (sourceURL.lastPathComponent.isEmpty ? "ImportedVideo.mov" : sourceURL.lastPathComponent)
        let destination = importDirectory.appendingPathComponent(safeName)
        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }
        try fileManager.copyItem(at: sourceURL, to: destination)
        return destination
    }

    private func mostRecentImportedVideoURL() -> URL? {
        guard let supportDirectory = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ) else {
            return nil
        }

        let importDirectory = supportDirectory.appendingPathComponent("ImportedVideos", isDirectory: true)
        guard let urls = try? FileManager.default.contentsOfDirectory(
            at: importDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) else {
            return nil
        }

        let playableExtensions: Set<String> = ["mov", "mp4", "m4v", "qt"]
        return urls
            .filter { playableExtensions.contains($0.pathExtension.lowercased()) }
            .sorted { lhs, rhs in
                let lhsDate = (try? lhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
                let rhsDate = (try? rhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
                return lhsDate > rhsDate
            }
            .first
    }

    private struct HFBuild5ReferenceVideo: Identifiable {
        let id: String
        let title: String
        let shortTitle: String
        let filename: String
        let episodeNumber: Int?

        private var candidateFilenames: [String] {
            [filename]
        }

        var isAvailable: Bool {
            resolvedURL != nil
        }

        var resolvedURL: URL? {
            for candidateFilename in candidateFilenames {
                if let bundledURL = bundledResourceURL(filename: candidateFilename) {
                    return bundledURL
                }
            }

            for candidateFilename in candidateFilenames {
                if let sandboxURL = sandboxImportedURL(filename: candidateFilename),
                   FileManager.default.fileExists(atPath: sandboxURL.path) {
                    return sandboxURL
                }
            }

            for directory in Self.externalReferenceDirectories {
                for candidateFilename in candidateFilenames {
                    let url = directory.appendingPathComponent(candidateFilename)
                    if FileManager.default.fileExists(atPath: url.path) {
                        return url
                    }
                }
            }

            return nil
        }

        private func bundledResourceURL(filename: String) -> URL? {
            let filenameURL = URL(fileURLWithPath: filename)
            let resourceName = filenameURL.deletingPathExtension().lastPathComponent
            let resourceExtension = filenameURL.pathExtension
            let subdirectories: [String?] = [
                nil,
                "App/Resources/Movies",
                "Resources/Movies",
                "Movies"
            ]

            for subdirectory in subdirectories {
                let url: URL?
                if let subdirectory {
                    url = Bundle.main.url(forResource: resourceName, withExtension: resourceExtension, subdirectory: subdirectory)
                } else {
                    url = Bundle.main.url(forResource: resourceName, withExtension: resourceExtension)
                }

                if let url {
                    return url
                }
            }

            return nil
        }

        private func sandboxImportedURL(filename: String) -> URL? {
            guard let supportDirectory = try? FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            ) else {
                return nil
            }
            return supportDirectory
                .appendingPathComponent("ImportedVideos", isDirectory: true)
                .appendingPathComponent(filename)
        }

        private static var externalReferenceDirectories: [URL] {
            #if DEBUG
            guard let directory = ProcessInfo.processInfo.environment["HF_LOCAL_FULL_STREAM_DIR"]?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !directory.isEmpty else {
                return []
            }
            return [URL(fileURLWithPath: directory, isDirectory: true)]
            #else
            []
            #endif
        }

        func isSelected(_ selectedEpisodeNumber: Int, for movie: Movie) -> Bool {
            if movie.id == "paranormall-s1" {
                return episodeNumber == selectedEpisodeNumber
            }
            return true
        }
    }

    private var playerArtworkFallback: some View {
        ZStack {
            LinearGradient(
                colors: [
                    HFColors.glassSurfaceRaised,
                    HFColors.background.opacity(0.96),
                    HFColors.warmGlow.opacity(0.46),
                    HFColors.goldDeep.opacity(0.22)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            HFDepthContourOverlay(color: HFColors.cyanGlow)
                .opacity(0.28)
            VStack(spacing: HFSpacing.xs) {
                Image(systemName: "film.stack")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(HFColors.gold.opacity(0.82))
                    .frame(width: 74, height: 74)
                    .background(HFColors.gold.opacity(0.12))
                    .clipShape(Circle())
                Text("Artwork Pending")
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(HFColors.gold.opacity(0.82))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .offset(y: -44)
        }
        .accessibilityHidden(true)
    }

    private var playerPolishStatusStrip: some View {
        HFOpticalGlassSurface(cornerRadius: 24, strokeColor: HFColors.gold.opacity(selectedSurface == .polish ? 0.56 : 0.24)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    Label("Player Polish Pass", systemImage: "sparkles.tv.fill")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    Spacer(minLength: HFSpacing.sm)
                    HFPlayerStatusPill(title: "QA 93/100", color: HFColors.gold)
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.sm) {
                    HFPlayerPolishTile(
                        title: "Controls",
                        value: "Dock Clear",
                        detail: "Primary commands stay above the safe-area rail.",
                        systemImage: "slider.horizontal.3",
                        color: HFColors.gold
                    )
                    HFPlayerPolishTile(
                        title: "Captions",
                        value: "Readable",
                        detail: "Track labels preserve contrast over optical black.",
                        systemImage: "captions.bubble.fill",
                        color: HFColors.cyanGlow
                    )
                    HFPlayerPolishTile(
                        title: "Gestures",
                        value: "Local",
                        detail: "Preview gestures change visible state only.",
                        systemImage: "hand.tap.fill",
                        color: HFColors.violet
                    )
                    HFPlayerPolishTile(
                        title: "Recovery",
                        value: "Friendly",
                        detail: "Unavailable media routes to retry copy instead of blank UI.",
                        systemImage: "arrow.clockwise.circle.fill",
                        color: HFColors.gold
                    )
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.fpp.playerPolish")
    }

    private var playerPolishReviewSurface: some View {
        HFOpticalGlassSurface(cornerRadius: 28, strokeColor: HFColors.cyanGlow.opacity(0.46)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(HFColors.cyanGlow)
                        .frame(width: 44, height: 44)
                        .background(HFColors.cyanGlow.opacity(0.12))
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Player Launch QA")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Controls, captions, buffering copy, and metadata overlays are visible in one deterministic player route.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(spacing: HFSpacing.sm) {
                    HFPlayerPolishRow(title: "Overlay clearance", value: "Controls are outside poster crop and above sheet bottom padding.", color: HFColors.gold)
                    HFPlayerPolishRow(title: "Caption treatment", value: "Caption and audio labels use high-contrast glass chips.", color: HFColors.cyanGlow)
                    HFPlayerPolishRow(title: "Error recovery", value: "Playback errors render an inline retry panel with a clear action.", color: HFColors.violet)
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.player.polish.review")
    }

    private var playbackRuntimeSurface: some View {
        HFOpticalGlassSurface(cornerRadius: 26, strokeColor: HFColors.cyanGlow.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    Image(systemName: playbackRuntimeSnapshot.state == .descriptorReady ? "play.rectangle.on.rectangle.fill" : "play.slash.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(playbackRuntimeSnapshot.state == .descriptorReady ? HFColors.gold : HFColors.cyanGlow)
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Streaming Playback Runtime")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(playbackRuntimeSnapshot.updatedAtLabel)
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.gold)
                    }
                    Spacer()
                    HFPlayerStatusPill(title: playbackRuntimeSnapshot.statusLabel, color: HFColors.gold)
                }

                if let error = playbackRuntimeSnapshot.lastError {
                    HFErrorRecoveryCard(
                        kind: .playback,
                        title: "Playback preview unavailable",
                        message: error,
                        recoveryTitle: "Refresh Playback",
                        recovery: {
                            Task { await streamingStore.runStreamingPlaybackRuntimeFixture(for: catalogMovie) }
                        },
                        isCompact: true
                    )
                    .accessibilityIdentifier("hf.playback.error")
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.sm) {
                    ForEach(streamingStore.streamingPlaybackRuntimeStatusRows) { row in
                        playbackRuntimeMetric(row)
                    }
                }

                if let session = streamingStore.streamingPlaybackSessionRecords.first {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Active Session")
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.textSecondary)
                        Text(session.detail)
                            .font(HFTypography.caption.weight(.semibold))
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(playbackRuntimeSnapshot.lastManifestPreview)
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.textSecondary)
                            .lineLimit(2)
                        Text("\(session.variantCount) variants • \(session.audioTrackCount) audio • \(session.captionTrackCount) captions • \(session.resumePolicy.replacingOccurrences(of: "_", with: " ").capitalized)")
                            .font(HFTypography.micro.weight(.semibold))
                            .foregroundStyle(HFColors.cyanGlow)
                            .lineLimit(2)
                        if let nextEpisodeTitle = session.nextEpisodeTitle {
                            Text("Next Episode: \(nextEpisodeTitle)")
                                .font(HFTypography.micro.weight(.semibold))
                                .foregroundStyle(HFColors.gold)
                                .lineLimit(2)
                        }
                    }
                    .padding(HFSpacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(HFColors.cyanGlow.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .accessibilityIdentifier("hf.playback.session.\(session.id)")
                }

            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.playback.runtime")
    }

    private func playbackRuntimeMetric(_ row: HFStreamingPlaybackStatusRow) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(row.title, systemImage: row.systemImage)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(1)
            Text(row.value)
                .font(HFTypography.caption.weight(.bold))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
            Text(row.detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .padding(HFSpacing.sm)
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .topLeading)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(row.id == "hls" ? "hf.playback.hls" : "hf.playback.runtime.\(row.id)")
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
        case .polish:
            EmptyView()
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
                HFPlayerInsight(title: "Runtime", value: playbackRuntimeSnapshot.statusLabel, systemImage: "antenna.radiowaves.left.and.right", color: HFColors.cyanGlow)
                HFPlayerInsight(title: "Best Scene", value: "Opening", systemImage: "sparkles.tv.fill", color: HFColors.gold)
                HFPlayerInsight(title: "Format", value: playbackRuntimeSnapshot.playbackFormat, systemImage: "play.rectangle.on.rectangle.fill", color: HFColors.cyanGlow)
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Viewer Intelligence, Runtime \(playbackRuntimeSnapshot.statusLabel), Best Scene Opening, Format \(playbackRuntimeSnapshot.playbackFormat)")
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
                    metadataItem(title: "Format", value: playbackRuntimeSnapshot.playbackFormat)
                    metadataItem(title: "Source", value: playbackRuntimeSnapshot.playbackSource)
                    metadataItem(title: "Access", value: gatedPlaybackDescriptor.gateStatus.statusLabel)
                    metadataItem(title: "Session", value: "\(playbackRuntimeSnapshot.sessionCount)")
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
                    playbackRuntimeSurface
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

private struct HFPlayerPolishTile: View {
    let title: String
    let value: String
    let detail: String
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(color)
            Text(title)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(value)
                .font(HFTypography.caption.weight(.bold))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(HFSpacing.sm)
        .frame(maxWidth: .infinity, minHeight: 142, alignment: .topLeading)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.player.polish.\(title.lowercased())")
    }
}

private struct HFPlayerPolishRow: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Circle()
                .fill(color)
                .frame(width: 9, height: 9)
                .padding(.top, 5)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                Text(value)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

struct CreatorProfileView: View {
    let creator: Creator

    @EnvironmentObject private var streamingStore: HFStreamingStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var isAwake = false

    private var profile: HFCreatorProfile {
        streamingStore.creatorProfile(for: creator)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                hero
                discoveryConnection
                filmographySection
                publishedSection
                collectionsSection
                releaseStateSection
            }
            .padding(.bottom, HFResponsiveFit.floatingTabContentClearance(dynamicTypeSize: dynamicTypeSize))
        }
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
                        .background(Color.black.opacity(0.50))
                        .clipShape(Circle())
                }
                .accessibilityLabel("Back")
            }
        }
        .onAppear {
            withAnimation(reduceMotion ? .easeInOut(duration: 0.01) : HFSpatialMotionTokens.sceneEntranceAnimation) {
                isAwake = true
            }
        }
        .accessibilityIdentifier("hf.creator.profile")
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            creatorBannerArtwork
                .frame(height: 520)
                .scaleEffect(reduceMotion ? 1 : (isAwake ? 1.03 : 0.98))
                .offset(y: reduceMotion ? 0 : (isAwake ? -6 : 8))

            LinearGradient(
                colors: [.clear, HFColors.background.opacity(0.70), HFColors.background],
                startPoint: .top,
                endPoint: .bottom
            )

            HFDepthContourOverlay(color: HFColors.violet.opacity(0.70))
                .opacity(0.36)

            VStack(alignment: .leading, spacing: HFSpacing.md) {
                Text("CREATOR SPOTLIGHT")
                    .font(HFTypography.micro)
                    .foregroundStyle(.black)
                    .padding(.horizontal, HFSpacing.sm)
                    .frame(height: 28)
                    .background(HFColors.goldGradient)
                    .clipShape(Capsule())

                Spacer()

                HStack(alignment: .bottom, spacing: HFSpacing.md) {
                    Image(systemName: profile.avatarSymbol)
                        .font(.system(size: 38, weight: .black))
                        .foregroundStyle(HFColors.violet)
                        .frame(width: 84, height: 84)
                        .background(Color.black.opacity(0.72))
                        .overlay(Circle().stroke(HFColors.gold.opacity(0.62), lineWidth: 1))
                        .clipShape(Circle())
                        .shadow(color: HFColors.amberGlow.opacity(0.26), radius: 20, x: 0, y: 12)
                        .accessibilityIdentifier("hf.creator.profile.avatar")

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text(profile.creator.name)
                            .font(HFTypography.heroTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.58)
                        Text(profile.creator.role)
                            .font(HFTypography.body.weight(.semibold))
                            .foregroundStyle(HFColors.violet)
                    }
                }

                Text(profile.bio)
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.creator.profile.bio")

                if let latest = profile.latestRelease {
                    HStack(spacing: HFSpacing.sm) {
                        NavigationLink(value: latest) {
                            Label("Watch Now", systemImage: "play.fill")
                                .font(HFTypography.smallAction)
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(HFColors.goldGradient)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("hf.creator.profile.watchNow")
                        .accessibilityIdentifier("hf.route.creatorProfileToMovieDetail")

                        Text("Latest Release")
                            .font(HFTypography.caption.weight(.bold))
                            .foregroundStyle(HFColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.white.opacity(0.10))
                            .clipShape(Capsule())
                            .accessibilityIdentifier("hf.creator.profile.latestRelease")
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .frame(height: 520)
        .clipped()
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Creator profile for \(profile.creator.name). \(profile.creator.role).")
        .accessibilityIdentifier("hf.creator.profile.banner")
    }

    private var creatorBannerArtwork: some View {
        ZStack {
            if let movie = profile.featuredProject, let asset = movie.backdropAssetName, HFPosterAssetHealth.hasImage(named: asset) {
                Image(asset)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [Color.black, HFColors.violet.opacity(0.30), HFColors.gold.opacity(0.22), Color.black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }

            HStack(spacing: -28) {
                ForEach(Array(profile.filmography.prefix(3).enumerated()), id: \.element.id) { index, movie in
                    HFPosterCard(movie: movie, width: 118, showTitle: false, posterOnly: true)
                        .rotationEffect(.degrees(Double(index - 1) * (reduceMotion ? 0 : 7)))
                        .offset(y: CGFloat(index) * (reduceMotion ? 0 : 12))
                        .opacity(index == 0 ? 0.92 : 0.68)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
            .padding(.trailing, HFSpacing.lg)
            .accessibilityHidden(true)
        }
        .accessibilityIdentifier("hf.creator.profile.featuredProject")
    }

    private var discoveryConnection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.cyanGlow.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                Label("Discovery Connection", systemImage: "sparkle.magnifyingglass")
                    .font(HFTypography.section)
                    .foregroundStyle(HFColors.textPrimary)

                Text("\(profile.creator.name) is connected to Search, Discovery, Movie Detail, and this Creator Profile using local catalog and publishing records.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 112), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    creatorStat(title: "\(profile.publishedTitles.count)", detail: "Published")
                    creatorStat(title: "\(profile.scheduledTitles.count)", detail: "Scheduled")
                    creatorStat(title: "\(profile.archivedTitles.count)", detail: "Archived")
                    creatorStat(title: "\(profile.collections.count)", detail: "Collections")
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.creator.profile.discoveryConnection")
    }

    private var filmographySection: some View {
        creatorMovieRail(
            title: "Creator Filmography",
            identifier: "hf.creator.profile.filmography",
            movies: profile.filmography
        )
    }

    private var publishedSection: some View {
        creatorMovieRail(
            title: "Published Titles",
            identifier: "hf.creator.profile.publishedTitles",
            movies: profile.publishedTitles
        )
    }

    private var collectionsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Creator Collections", actionTitle: nil)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: HFSpacing.md) {
                    ForEach(profile.collections) { collection in
                        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.28)) {
                            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                                Image(systemName: "rectangle.stack.fill")
                                    .font(.system(size: 22, weight: .black))
                                    .foregroundStyle(HFColors.violet)
                                    .frame(width: 46, height: 46)
                                    .background(HFColors.violet.opacity(0.14))
                                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
                                Text(collection.title)
                                    .font(HFTypography.cardTitle)
                                    .foregroundStyle(HFColors.textPrimary)
                                    .lineLimit(2)
                                Text(collection.subtitle ?? "Creator collection")
                                    .font(HFTypography.caption)
                                    .foregroundStyle(HFColors.textSecondary)
                                    .lineLimit(3)
                                Text("\(collection.movies.count) titles")
                                    .font(HFTypography.micro.weight(.bold))
                                    .foregroundStyle(HFColors.gold)
                            }
                            .padding(HFSpacing.md)
                            .frame(width: 210, alignment: .topLeading)
                            .frame(minHeight: 182, alignment: .topLeading)
                        }
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
        .accessibilityIdentifier("hf.creator.profile.collections")
    }

    private var releaseStateSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.26)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                Label("Publishing States", systemImage: "checkmark.seal.fill")
                    .font(HFTypography.section)
                    .foregroundStyle(HFColors.textPrimary)
                creatorStateRow(title: "Published", detail: "Available to Discovery and Creator Profile", count: profile.publishedTitles.count, color: HFColors.gold)
                creatorStateRow(title: "Scheduled", detail: "Shown as upcoming creator work", count: profile.scheduledTitles.count, color: HFColors.cyanGlow)
                creatorStateRow(title: "Archived", detail: "Preserved in creator filmography context", count: profile.archivedTitles.count, color: HFColors.violet)
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    @ViewBuilder
    private func creatorMovieRail(title: String, identifier: String, movies: [Movie]) -> some View {
        if !movies.isEmpty {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                HFSectionHeader(title: title, actionTitle: "\(movies.count)")
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(alignment: .top, spacing: HFSpacing.md) {
                        ForEach(movies) { movie in
                            NavigationLink(value: movie) {
                                HFPosterCard(movie: movie, width: HFSpacing.posterRailWidth, showMetadata: true, showProgress: movie.progress != nil)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("hf.route.creatorProfileToMovieDetail")
                        }
                    }
                    .padding(.horizontal, HFSpacing.screenHorizontal)
                }
            }
            .accessibilityIdentifier(identifier)
        }
    }

    private func creatorStat(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
            Text(detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
    }

    private func creatorStateRow(title: String, detail: String, count: Int, color: Color) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: "circle.fill")
                .font(.system(size: 10, weight: .black))
                .foregroundStyle(color)
                .padding(.top, 5)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                Text(detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
            }
            Spacer()
            Text("\(count)")
                .font(HFTypography.caption.weight(.black))
                .foregroundStyle(color)
        }
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
    }
}

private struct HFDepthControlSettings: Equatable {
    enum LensMode: Int, CaseIterable, Identifiable {
        case natural = 0
        case anamorphic = 1
        case portrait = 2

        var id: Int { rawValue }

        var title: String {
            switch self {
            case .natural: return "Nat"
            case .anamorphic: return "Ana"
            case .portrait: return "Port"
            }
        }

        var playerLensMode: HKV1_PlayerLayerView.LensMode {
            HKV1_PlayerLayerView.LensMode(rawValue: rawValue) ?? .anamorphic
        }

        var motionLensProfile: HKV1_ProMotionCoordinator.LensProfile {
            switch self {
            case .portrait: return .portrait
            case .natural, .anamorphic: return .anamorphic
            }
        }
    }

    enum LUTMode: Int, CaseIterable, Identifiable {
        case off = 0
        case lux = 1
        case highfiveDay = 2
        case highfiveNight = 3
        case highfiveWarm = 4
        case highfiveMono = 5

        var id: Int { rawValue }

        var title: String {
            switch self {
            case .off: return "Off"
            case .lux: return "Lux"
            case .highfiveDay: return "HF Day"
            case .highfiveNight: return "HF Night"
            case .highfiveWarm: return "HF Warm"
            case .highfiveMono: return "HF Mono"
            }
        }

        var playerLUTMode: HKV1_PlayerLayerView.LUTMode {
            HKV1_PlayerLayerView.LUTMode(rawValue: rawValue) ?? .off
        }
    }

    enum Preset: String, CaseIterable, Identifiable {
        case natural = "Natural"
        case cinema = "Cinema"
        case enhanced = "Enhanced"
        case maximum = "Maximum"

        var id: String { rawValue }
    }

    enum MotionMode: String, CaseIterable, Identifiable {
        case off = "Off"
        case close = "Close"
        case wide = "Wide"

        var id: String { rawValue }

        var responseGain: CGFloat {
            switch self {
            case .off: return 0
            case .close: return 0.78
            case .wide: return 1.35
            }
        }
    }

    var isDepthEnabled = true
    var isMotionEnabled = true
    var isAIAssistEnabled = false
    var isTiltEnabled = true
    var isPeekEnabled = true
    var isHighFiveDepthEnabled = true
    var showsRenderOverlay = false
    var depthIntensity: Double = 1.05
    var focusFalloff: Double = 0.28
    var bgPlaneControl: Double = 1.58
    var midPlaneControl: Double = 1.74
    var fgPlaneControl: Double = 2.05
    var depthRendering: Double = 1.0
    var depthScale: Double = 1.07
    var framingScale: Double = 1.24
    var tiltResponse: Double = 0.74
    var peekResponse: Double = 0.76
    var motionRange: Double = 1.0
    var layer4Preset: HKV1_Layer4CreatorIntent.Preset = .drift
    var layer4DepthAmount: Double = 0.45
    var layer4PeekAssistAmount: Double = 0.42
    var layer4CenterSmoothAmount: Double = 0.50
    var layer4RecenterAmount: Double = 0.58
    var layer4EdgeProtectAmount: Double = 0.70
    var layer4HyperAmount: Double = 0.30
    var layer4GoldenSafeMode = true
    var lensMode: LensMode = .portrait
    var lutMode: LUTMode = .off
    var motionMode: MotionMode = .wide
    var preset: Preset = .cinema

    var layer4CreatorIntent: HKV1_Layer4CreatorIntent {
        var edgeProtect = mappedLayer4Slider(layer4EdgeProtectAmount, min: 0.40, max: 1.0)
        var recenter = mappedLayer4Slider(layer4RecenterAmount, min: 0.34, max: 0.94)
        let hyperMax: Double = layer4GoldenSafeMode ? 0.34 : 0.46
        let hyper = mappedLayer4Slider(layer4HyperAmount, min: 0.0, max: hyperMax)

        if layer4GoldenSafeMode {
            edgeProtect = max(edgeProtect, layer4Preset == .hyper ? 0.76 : 0.58)
            recenter = max(recenter, 0.42)
        }

        return HKV1_Layer4CreatorIntent(
            preset: layer4Preset,
            depthAmount: mappedLayer4Slider(layer4DepthAmount, min: 0.58, max: 1.05),
            peekAssistAmount: mappedLayer4Slider(layer4PeekAssistAmount, min: 0.0, max: 0.78),
            centerSmoothAmount: mappedLayer4Slider(layer4CenterSmoothAmount, min: 0.72, max: 1.20),
            recenterAmount: recenter,
            edgeProtectAmount: edgeProtect,
            hyperAmount: hyper,
            goldenSafeMode: layer4GoldenSafeMode
        )
    }

    var layer4DepthDirectorProfile: HKV1_Layer4DepthDirector.Profile {
        switch layer4Preset {
        case .anchor, .lock:
            return .safe119A
        case .drift:
            return .cinematicLift
        case .surge:
            return .volumetricSurge
        case .hyper:
            return .hyperSafe
        }
    }

    mutating func applyPreset(_ preset: Preset) {
        self.preset = preset
        switch preset {
        case .natural:
            isMotionEnabled = true
            motionMode = .wide
            depthIntensity = 0.78
            focusFalloff = 0.24
            bgPlaneControl = 1.34
            midPlaneControl = 1.46
            fgPlaneControl = 1.68
            depthRendering = 0.72
            depthScale = 1.03
            framingScale = 1.24
            tiltResponse = 0.50
            peekResponse = 0.52
            motionRange = 0.62
            applyLayer4Preset(.anchor)
        case .cinema:
            isMotionEnabled = true
            motionMode = .wide
            depthIntensity = 1.05
            focusFalloff = 0.28
            bgPlaneControl = 1.58
            midPlaneControl = 1.74
            fgPlaneControl = 2.05
            depthRendering = 1.0
            depthScale = 1.07
            framingScale = 1.24
            tiltResponse = 0.74
            peekResponse = 0.76
            motionRange = 0.82
            applyLayer4Preset(.drift)
        case .enhanced:
            isMotionEnabled = true
            motionMode = .wide
            depthIntensity = 1.46
            focusFalloff = 0.34
            bgPlaneControl = 1.80
            midPlaneControl = 2.00
            fgPlaneControl = 2.36
            depthRendering = 1.0
            depthScale = 1.34
            framingScale = 1.30
            tiltResponse = 0.92
            peekResponse = 0.94
            motionRange = 0.94
            applyLayer4Preset(.surge)
        case .maximum:
            isMotionEnabled = true
            motionMode = .wide
            depthIntensity = 1.88
            focusFalloff = 0.42
            bgPlaneControl = 2.02
            midPlaneControl = 2.20
            fgPlaneControl = 2.62
            depthRendering = 1.0
            depthScale = 1.54
            framingScale = 1.36
            tiltResponse = 1.0
            peekResponse = 1.0
            motionRange = 1.0
            applyLayer4Preset(.hyper)
        }
    }

    mutating func applyLayer4Preset(_ preset: HKV1_Layer4CreatorIntent.Preset) {
        layer4Preset = preset
        layer4GoldenSafeMode = true
        switch preset {
        case .anchor:
            layer4DepthAmount = 0.30
            layer4PeekAssistAmount = 0.18
            layer4CenterSmoothAmount = 0.58
            layer4RecenterAmount = 0.78
            layer4EdgeProtectAmount = 0.82
            layer4HyperAmount = 0.00
            motionMode = .wide
            motionRange = max(motionRange, 0.62)
            tiltResponse = max(tiltResponse, 0.56)
            peekResponse = max(peekResponse, 0.54)
        case .drift:
            layer4DepthAmount = 0.45
            layer4PeekAssistAmount = 0.42
            layer4CenterSmoothAmount = 0.50
            layer4RecenterAmount = 0.58
            layer4EdgeProtectAmount = 0.70
            layer4HyperAmount = 0.30
            motionRange = max(motionRange, 0.82)
        case .surge:
            layer4DepthAmount = 0.66
            layer4PeekAssistAmount = 0.60
            layer4CenterSmoothAmount = 0.48
            layer4RecenterAmount = 0.52
            layer4EdgeProtectAmount = 0.74
            layer4HyperAmount = 0.52
            motionMode = .wide
            motionRange = max(motionRange, 0.94)
        case .hyper:
            layer4DepthAmount = 0.82
            layer4PeekAssistAmount = 0.72
            layer4CenterSmoothAmount = 0.44
            layer4RecenterAmount = 0.50
            layer4EdgeProtectAmount = 0.86
            layer4HyperAmount = 0.74
            motionMode = .wide
            motionRange = 1.0
            tiltResponse = 1.0
            peekResponse = 1.0
        case .lock:
            layer4DepthAmount = 0.46
            layer4PeekAssistAmount = 0.26
            layer4CenterSmoothAmount = 0.70
            layer4RecenterAmount = 0.84
            layer4EdgeProtectAmount = 0.90
            layer4HyperAmount = 0.08
            motionMode = .wide
            motionRange = max(motionRange, 0.68)
            tiltResponse = max(tiltResponse, 0.62)
            peekResponse = max(peekResponse, 0.58)
        }
    }

    private func mappedLayer4Slider(_ slider: Double, min minValue: Double, max maxValue: Double) -> Double {
        let t = max(0, min(1, slider))
        let s = t * t * t * (t * (t * 6 - 15) + 10)
        return minValue + ((maxValue - minValue) * s)
    }
}

private extension HKV1_Layer4CreatorIntent.Preset {
    var title: String {
        switch self {
        case .anchor: return "Anchor"
        case .drift: return "Drift"
        case .surge: return "Surge"
        case .hyper: return "Hyper"
        case .lock: return "Lock"
        }
    }
}

private final class HFDepthLiveSettings: ObservableObject {
    @Published var values: HFDepthControlSettings {
        didSet { revision &+= 1 }
    }
    @Published private(set) var revision: Int = 0

    init(values: HFDepthControlSettings = HFDepthControlSettings()) {
        self.values = values
    }
}

private enum HFLayer4RuntimeState: String, Equatable {
    case idle
    case loading
    case flatStartup
    case playbackStabilizing
    case depthPreparing
    case spatialActive
    case fallbackFlat
    case recovery
}

private struct HFFullVerticalDepthPlayer: View {
    let player: AVPlayer?
    let title: String
    let sourceLabel: String
    let sourceErrorMessage: String?
    let contentSource: HFPlaybackContentSource
    let importReferenceTitle: String?
    let onClose: () -> Void
    let onImportMovie: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var motionModel = HFPlayerTiltMotionModel()
    @StateObject private var liveSettings = HFDepthLiveSettings()
    @State private var isShowingMasterControls = false
    @State private var isPlaying = true
    @State private var activationPulse = false
    @State private var showsStageControls = true
    @State private var renderProgress: Double?
    @State private var renderProgressTask: Task<Void, Never>?
    @State private var controlsFadeTask: Task<Void, Never>?
    @State private var layer4State: HFLayer4RuntimeState = .idle
    @State private var layer4Task: Task<Void, Never>?
    @State private var playbackProgress: Double = 0
    @State private var playbackDuration: Double = 0
    @State private var playbackTimeObserver: Any?
    @State private var isMasterDrawerExpanded = false

    init(
        player: AVPlayer?,
        title: String,
        sourceLabel: String,
        sourceErrorMessage: String?,
        contentSource: HFPlaybackContentSource,
        importReferenceTitle: String?,
        onClose: @escaping () -> Void,
        onImportMovie: (() -> Void)?
    ) {
        self.player = player
        self.title = title
        self.sourceLabel = sourceLabel
        self.sourceErrorMessage = sourceErrorMessage
        self.contentSource = contentSource
        self.importReferenceTitle = importReferenceTitle
        self.onClose = onClose
        self.onImportMovie = onImportMovie
    }

    private var settings: HFDepthControlSettings {
        liveSettings.values
    }

    private var settingsBinding: Binding<HFDepthControlSettings> {
        Binding(
            get: { liveSettings.values },
            set: { liveSettings.values = $0 }
        )
    }

    private var effectiveTiltX: CGFloat {
        guard settings.isMotionEnabled, settings.motionMode != .off, settings.isTiltEnabled else { return 0 }
        return motionModel.effectiveTiltX * CGFloat(settings.tiltResponse)
    }

    private var effectiveTiltY: CGFloat {
        guard settings.isMotionEnabled, settings.motionMode != .off, settings.isTiltEnabled else { return 0 }
        return motionModel.effectiveTiltY * CGFloat(settings.tiltResponse)
    }

    private var stageScale: CGFloat {
        CGFloat(settings.framingScale * (settings.isDepthEnabled ? settings.depthScale : 1.0))
    }

    private var allowsImportControls: Bool {
        contentSource == .userImported && onImportMovie != nil
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            depthStageContent
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        showsStageControls.toggle()
                    }
                    if showsStageControls, isPlaying, !isShowingMasterControls {
                        scheduleControlsFade()
                    }
                }

            if settings.showsRenderOverlay {
                HFDepthTiltRenderOverlay(
                    compact: false,
                    showsBadges: true,
                    settings: settings,
                    motionModel: motionModel
                )
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            #if DEBUG
            if HFPlayerLayer4DebugGate.isEnabled {
                HFVerticalStageLayer4DebugReadout(
                    layer4State: layer4State,
                    settings: settings,
                    settingsRevision: liveSettings.revision,
                    sourceLabel: sourceLabel,
                    motionModel: motionModel,
                    hasPlayer: player != nil
                )
                .padding(.top, 86)
                .padding(.leading, 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .allowsHitTesting(false)
                .zIndex(29)
            }
            #endif

            VStack {
                HStack(alignment: .top) {
                    Spacer()

                    closeStageButton(size: 58, backgroundOpacity: 0.46)
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .opacity(showsStageControls ? 1 : 0)
                .allowsHitTesting(showsStageControls)
                .animation(.easeInOut(duration: 0.26), value: showsStageControls)
                .zIndex(30)

                Spacer()
            }

            VStack {
                Spacer()
                HFVerticalStageControlDeck(
                    settings: settingsBinding,
                    isPlaying: $isPlaying,
                    playbackProgress: $playbackProgress,
                    renderProgress: renderProgress,
                    hasPlayer: player != nil,
                    onTogglePlayback: togglePlayback,
                    onSkip: skipPlayback,
                    onScrub: seekPlayback,
                    onImportMovie: onImportMovie,
                    showsImportButton: allowsImportControls,
                    onOpenMasterControls: { isShowingMasterControls = true }
                )
                .padding(.horizontal, 14)
                .padding(.bottom, 18)
                .opacity(showsStageControls ? 1 : 0)
                .offset(y: showsStageControls ? 0 : 26)
                .allowsHitTesting(showsStageControls)
                .animation(.easeInOut(duration: 0.26), value: showsStageControls)
            }
            .zIndex(32)

            if isShowingMasterControls {
                GeometryReader { proxy in
                    let panelWidth = max(0, proxy.size.width - 20)
                    let panelHeight = min(
                        proxy.size.height * (isMasterDrawerExpanded ? 0.62 : 0.38),
                        isMasterDrawerExpanded ? 620 : 390
                    )

                    ZStack(alignment: .bottom) {
                        Color.black.opacity(0.10)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
                                    isShowingMasterControls = false
                                }
                            }

                        HFDepthMasterControlSheet(
                            settings: settingsBinding,
                            isPlaying: $isPlaying,
                            playbackProgress: $playbackProgress,
                            hasPlayer: player != nil,
                            onTogglePlayback: togglePlayback,
                            onSkip: skipPlayback,
                            onScrub: seekPlayback,
                            onImportMovie: onImportMovie,
                            showsImportControls: allowsImportControls,
                            onDone: {
                                withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
                                    isShowingMasterControls = false
                                }
                            }
                        )
                        .frame(width: panelWidth)
                        .frame(height: panelHeight)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(HFColors.gold.opacity(0.22), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.42), radius: 30, x: 0, y: -10)
                        .padding(.bottom, 14)
                        .gesture(
                            DragGesture(minimumDistance: 16)
                                .onEnded { value in
                                    withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
                                        if value.translation.height < -34 {
                                            isMasterDrawerExpanded = true
                                        } else if value.translation.height > 34 {
                                            isMasterDrawerExpanded = false
                                        }
                                    }
                                }
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height)
                }
                .zIndex(80)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            motionModel.start()
            player?.play()
            isPlaying = player != nil
            installPlaybackProgressObserver()
            startLayer4Runtime()
            startRenderProgress()
            if isPlaying {
                scheduleControlsFade()
            }
            #if DEBUG
            if CommandLine.arguments.contains("--hf-start-player-fullscreen") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
                        isShowingMasterControls = true
                    }
                }
            }
            #endif
            withAnimation(.easeInOut(duration: 1.45).repeatForever(autoreverses: true)) {
                activationPulse = true
            }
        }
        .onDisappear {
            motionModel.stop()
            player?.pause()
            isPlaying = false
            renderProgressTask?.cancel()
            renderProgressTask = nil
            controlsFadeTask?.cancel()
            controlsFadeTask = nil
            layer4Task?.cancel()
            layer4Task = nil
            removePlaybackProgressObserver()
            layer4State = .idle
            renderProgress = nil
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
            enterLayer4Fallback(reason: "memory warning")
        }
        .onChange(of: isShowingMasterControls) { _, isOpen in
            controlsFadeTask?.cancel()
            withAnimation(.easeInOut(duration: 0.18)) {
                showsStageControls = true
            }
            if isOpen {
                isMasterDrawerExpanded = false
            }
            if !isOpen, isPlaying {
                scheduleControlsFade()
            }
        }
        .animation(.spring(response: 0.34, dampingFraction: 0.88), value: isShowingMasterControls)
        .accessibilityIdentifier("hf.player.fullVerticalDepth")
    }

    private func startLayer4Runtime() {
        layer4Task?.cancel()
        guard let player else {
            setLayer4State(.idle, reason: "no player")
            return
        }

        setLayer4State(.loading, reason: "media selected")
        layer4Task = Task { @MainActor in
            setLayer4State(.flatStartup, reason: "player item created")
            let isStable = await waitForStablePlayback(player)
            guard !Task.isCancelled else { return }
            guard isStable else {
                enterLayer4Fallback(reason: "player did not stabilize")
                return
            }

            setLayer4State(.playbackStabilizing, reason: "ready or playing")
            try? await Task.sleep(nanoseconds: 380_000_000)
            guard !Task.isCancelled else { return }

            setLayer4State(.depthPreparing, reason: "startup delay elapsed")
            try? await Task.sleep(nanoseconds: 90_000_000)
            guard !Task.isCancelled else { return }

            setLayer4State(.spatialActive, reason: "depth and motion runtime active")
        }
    }

    @MainActor
    private func waitForStablePlayback(_ player: AVPlayer) async -> Bool {
        for _ in 0..<70 {
            if Task.isCancelled { return false }
            if player.currentItem?.status == .failed { return false }
            if player.currentItem?.status == .readyToPlay || player.timeControlStatus == .playing || player.rate > 0 {
                return true
            }
            try? await Task.sleep(nanoseconds: 50_000_000)
        }

        return player.currentItem?.status == .readyToPlay || player.timeControlStatus == .playing || player.rate > 0
    }

    private func enterLayer4Fallback(reason: String) {
        layer4Task?.cancel()
        setLayer4State(.fallbackFlat, reason: reason)
        guard player != nil else { return }

        layer4Task = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            guard !Task.isCancelled, let player else { return }
            let isStable = await waitForStablePlayback(player)
            guard !Task.isCancelled, isStable else { return }
            setLayer4State(.recovery, reason: "stable after fallback")
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            setLayer4State(.depthPreparing, reason: "recovery preparing depth")
            try? await Task.sleep(nanoseconds: 90_000_000)
            guard !Task.isCancelled else { return }
            setLayer4State(.spatialActive, reason: "recovered")
        }
    }

    private func setLayer4State(_ state: HFLayer4RuntimeState, reason: String) {
        guard layer4State != state else { return }
        layer4State = state
        #if DEBUG
        if HFPlayerLayer4DebugGate.isEnabled {
            print("[Layer4] state=\(state.rawValue) reason=\(reason)")
        }
        #endif
    }

    private func installPlaybackProgressObserver() {
        removePlaybackProgressObserver()
        guard let player else { return }

        playbackTimeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.25, preferredTimescale: 600),
            queue: .main
        ) { time in
            let seconds = time.seconds
            let duration = player.currentItem?.duration.seconds ?? 0
            guard duration.isFinite, duration > 0, seconds.isFinite else {
                playbackDuration = 0
                playbackProgress = 0
                return
            }
            playbackDuration = duration
            playbackProgress = max(0, min(1, seconds / duration))
        }
    }

    private func removePlaybackProgressObserver() {
        guard let observer = playbackTimeObserver else { return }
        player?.removeTimeObserver(observer)
        playbackTimeObserver = nil
    }

    private func startRenderProgress() {
        renderProgressTask?.cancel()
        guard player != nil else {
            renderProgress = nil
            return
        }

        renderProgress = 0
        renderProgressTask = Task { @MainActor in
            for step in 0...20 {
                guard !Task.isCancelled else { return }
                renderProgress = Double(step) / 20.0
                try? await Task.sleep(nanoseconds: 55_000_000)
            }
            guard !Task.isCancelled else { return }
            try? await Task.sleep(nanoseconds: 260_000_000)
            renderProgress = nil
        }
    }

    private func togglePlayback() {
        guard let player else { return }
        if isPlaying {
            player.pause()
            controlsFadeTask?.cancel()
            withAnimation(.easeInOut(duration: 0.20)) {
                showsStageControls = true
            }
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
            scheduleControlsFade()
        }
    }

    private func scheduleControlsFade() {
        controlsFadeTask?.cancel()
        guard player != nil, isPlaying, !isShowingMasterControls else {
            withAnimation(.easeInOut(duration: 0.18)) {
                showsStageControls = true
            }
            return
        }
        withAnimation(.easeInOut(duration: 0.18)) {
            showsStageControls = true
        }
        controlsFadeTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_600_000_000)
            guard !Task.isCancelled, isPlaying, !isShowingMasterControls else { return }
            withAnimation(.easeInOut(duration: 0.34)) {
                showsStageControls = false
            }
        }
    }

    private func skipPlayback(by seconds: Double) {
        guard let player else { return }
        controlsFadeTask?.cancel()
        showsStageControls = true
        let current = player.currentTime().seconds
        let duration = player.currentItem?.duration.seconds ?? .nan
        let upperBound = duration.isFinite ? duration : Double.greatestFiniteMagnitude
        let target = min(max(current + seconds, 0), upperBound)
        player.seek(to: CMTime(seconds: target, preferredTimescale: 600))
        if isPlaying, !isShowingMasterControls {
            scheduleControlsFade()
        }
    }

    private func seekPlayback(to progress: Double) {
        guard let player else { return }
        controlsFadeTask?.cancel()
        showsStageControls = true
        let duration = player.currentItem?.duration.seconds ?? playbackDuration
        guard duration.isFinite, duration > 0 else { return }
        let target = max(0, min(1, progress)) * duration
        player.seek(to: CMTime(seconds: target, preferredTimescale: 600))
        if isPlaying, !isShowingMasterControls {
            scheduleControlsFade()
        }
    }

    private func closeStageButton(size: CGFloat, backgroundOpacity: Double) -> some View {
        Button {
            player?.pause()
            onClose()
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 17, weight: .black))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .background(.ultraThinMaterial)
                .background(Color.black.opacity(backgroundOpacity))
                .clipShape(Circle())
                .overlay(Circle().stroke(.white.opacity(0.18), lineWidth: 1))
                .shadow(color: .black.opacity(0.38), radius: 14, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
        .accessibilityLabel("Close full screen player")
    }

    @ViewBuilder
    private var depthStageContent: some View {
        if let player {
            HFVerticalStageSpatialPeekLayerView(
                player: player,
                settings: settings,
                layer4State: layer4State,
                settingsRevision: liveSettings.revision
            )
                .background(Color.black)
                .accessibilityIdentifier("hf.player.fullVerticalDepth.video")
        } else {
            verticalImportPrompt
        }
    }

    private var verticalImportPrompt: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                    HFColors.background,
                    HFColors.gold.opacity(0.20),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: HFSpacing.lg) {
                Spacer()

                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 58, weight: .black))
                    .foregroundStyle(HFColors.gold)
                    .scaleEffect(activationPulse ? 1.04 : 0.98)

                VStack(spacing: HFSpacing.xs) {
                    Text(allowsImportControls ? "Import Video" : "Stream Unavailable")
                        .font(.system(size: 34, weight: .black))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text(sourceErrorMessage ?? (allowsImportControls ? "Choose a video to start Vertical Stage playback." : "This title is not available for playback yet."))
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if allowsImportControls, let onImportMovie {
                    Button {
                        onImportMovie()
                    } label: {
                        Label(importReferenceTitle.map { "Import \($0)" } ?? "Import Video", systemImage: "folder.badge.plus")
                            .font(HFTypography.smallAction)
                            .foregroundStyle(.black)
                            .frame(maxWidth: 240)
                            .frame(height: 48)
                            .background(HFColors.goldGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.player.verticalStage.importMovie")
                }

                Spacer()
            }
            .padding(.horizontal, HFSpacing.xl)
        }
        .accessibilityIdentifier("hf.player.fullVerticalDepth.importPrompt")
    }
}

private struct HFVerticalStageActivationOverlay: View {
    let isLiveTilt: Bool
    let pulse: Bool
    let title: String
    let sourceLabel: String

    var body: some View {
        VStack {
            Spacer()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    Text(sourceLabel)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white.opacity(0.72))
                        .lineLimit(2)
                }
                Spacer(minLength: 0)
            }
            .padding(14)
            .background(Color.black.opacity(pulse ? 0.42 : 0.34))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.bottom, 136)
        }
        .accessibilityIdentifier("hf.player.verticalStage.depthTiltActive")
    }
}

#if DEBUG
private struct HFVerticalStageLayer4DebugReadout: View {
    let layer4State: HFLayer4RuntimeState
    let settings: HFDepthControlSettings
    let settingsRevision: Int
    let sourceLabel: String
    @ObservedObject var motionModel: HFPlayerTiltMotionModel
    let hasPlayer: Bool

    private var isSpatialActive: Bool {
        hasPlayer && layer4State == .spatialActive
    }

    private var depthActive: Bool {
        isSpatialActive && settings.isDepthEnabled && settings.isHighFiveDepthEnabled
    }

    private var tiltActive: Bool {
        depthActive && settings.isMotionEnabled && settings.motionMode != .off && settings.isTiltEnabled
    }

    private var peekActive: Bool {
        depthActive && settings.isMotionEnabled && settings.motionMode != .off && settings.isPeekEnabled
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            debugPill(
                layer4State == .fallbackFlat ? "Fallback Flat" : isSpatialActive ? "Layer 4 Active" : "Layer 4 Stabilizing",
                systemImage: layer4State == .fallbackFlat ? "rectangle" : "square.stack.3d.up.fill",
                identifier: layer4State == .fallbackFlat ? "hf.player.layer4.fallbackFlat" : "hf.player.layer4.active"
            )
            debugPill(depthActive ? "Depth Active" : "Depth Waiting", systemImage: "cube.transparent", identifier: "hf.player.depth.active")
            debugPill(tiltActive ? "Tilt Active" : "Tilt Waiting", systemImage: "viewfinder", identifier: "hf.player.tilt.active")
            debugPill(peekActive ? "Peek Active" : "Peek Waiting", systemImage: "scope", identifier: "hf.player.peek.active")
            debugPill(
                motionModel.isLive ? "Motion Live \(tiltText)" : "Motion Sim \(tiltText)",
                systemImage: "gyroscope",
                identifier: "hf.player.motion.liveTilt"
            )
            debugPill(
                "Update rev \(settingsRevision)",
                systemImage: "arrow.triangle.2.circlepath",
                identifier: "hf.player.layer4.updateRevision"
            )
            debugPill(
                String(format: "Depth %.2f BG %.2f MID %.2f FG %.2f", settings.depthIntensity, settings.bgPlaneControl, settings.midPlaneControl, settings.fgPlaneControl),
                systemImage: "cube.transparent",
                identifier: "hf.player.layer4.settings.depth"
            )
            debugPill(
                String(format: "Fill %.2f Tilt %.2f Peek %.2f", settings.framingScale, settings.tiltResponse, settings.peekResponse),
                systemImage: "slider.horizontal.3",
                identifier: "hf.player.layer4.settings.motion"
            )
            debugPill(
                String(format: "L4 %@ D %.2f Peek %.2f Center %.2f", settings.layer4Preset.title, settings.layer4DepthAmount, settings.layer4PeekAssistAmount, settings.layer4CenterSmoothAmount),
                systemImage: "square.stack.3d.up.fill",
                identifier: "hf.player.layer4.settings.intent"
            )
            debugPill(
                String(format: "Recenter %.2f Edge %.2f Hyper %.2f Safe %@", settings.layer4RecenterAmount, settings.layer4EdgeProtectAmount, settings.layer4HyperAmount, settings.layer4GoldenSafeMode ? "on" : "off"),
                systemImage: "checkmark.shield.fill",
                identifier: "hf.player.layer4.settings.safety"
            )
            debugPill(
                "Mode \(rendererMode) \(settings.motionMode.rawValue) Lens \(settings.lensMode.title) LUT \(settings.lutMode.title)",
                systemImage: "camera.filters",
                identifier: "hf.player.layer4.settings.renderMode"
            )

            Text("Source: \(sourceLabel)")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.88))
                .lineLimit(1)
                .minimumScaleFactor(0.62)
                .padding(.horizontal, 9)
                .frame(height: 22)
                .background(.black.opacity(0.42), in: Capsule())
                .overlay(Capsule().stroke(.white.opacity(0.12), lineWidth: 1))
                .accessibilityIdentifier("hf.player.layer4.source")
        }
    }

    private var tiltText: String {
        String(format: "x:%+.2f y:%+.2f", Double(motionModel.effectiveTiltX), Double(motionModel.effectiveTiltY))
    }

    private var rendererMode: String {
        depthActive ? "Layer4" : "flat"
    }

    private func debugPill(_ title: String, systemImage: String, identifier: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.system(size: 10, weight: .black, design: .monospaced))
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.70)
            .padding(.horizontal, 9)
            .frame(height: 22)
            .background(.black.opacity(0.42), in: Capsule())
            .overlay(Capsule().stroke(HFColors.gold.opacity(0.26), lineWidth: 1))
            .accessibilityIdentifier(identifier)
    }
}
#endif

private struct HFVerticalStageRenderProgressOverlay: View {
    let progress: Double

    private var percent: Int {
        Int((max(0, min(progress, 1)) * 100).rounded())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Rendering", systemImage: "gauge.with.dots.needle.67percent")
                    .font(.system(size: 12, weight: .black))
                Spacer(minLength: 8)
                Text("\(percent)%")
                    .font(.system(size: 12, weight: .black))
                    .monospacedDigit()
            }
            .foregroundStyle(.white)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.14))
                    Capsule()
                        .fill(HFColors.goldGradient)
                        .frame(width: max(0, min(proxy.size.width, proxy.size.width * progress)))
                }
            }
            .frame(height: 5)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .background(Color.black.opacity(0.32), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
        .accessibilityLabel("Rendering \(percent) percent")
    }
}

private struct HFVerticalStageControlDeck: View {
    @Binding var settings: HFDepthControlSettings
    @Binding var isPlaying: Bool
    @Binding var playbackProgress: Double
    let renderProgress: Double?
    let hasPlayer: Bool
    let onTogglePlayback: () -> Void
    let onSkip: (Double) -> Void
    let onScrub: (Double) -> Void
    let onImportMovie: (() -> Void)?
    var showsImportButton = false
    let onOpenMasterControls: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            HStack(spacing: 26) {
                transportButton(systemImage: "gobackward.10", title: "Back 10", size: 66, isEnabled: hasPlayer) {
                    onSkip(-10)
                }

                Button {
                    onTogglePlayback()
                } label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 38, weight: .black))
                        .foregroundStyle(.white)
                        .offset(x: isPlaying ? 0 : 3)
                        .frame(width: 96, height: 96)
                        .background(.ultraThinMaterial, in: Circle())
                        .background(Circle().fill(Color.black.opacity(0.28)))
                        .overlay(Circle().stroke(Color.white.opacity(0.30), lineWidth: 1))
                        .overlay(Circle().stroke(HFColors.gold.opacity(0.34), lineWidth: 1.2).padding(2))
                        .shadow(color: Color.black.opacity(0.35), radius: 22, x: 0, y: 14)
                        .shadow(color: HFColors.gold.opacity(0.16), radius: 22, x: 0, y: 8)
                }
                .buttonStyle(.plain)
                .disabled(!hasPlayer)
                .opacity(hasPlayer ? 1 : 0.48)
                .accessibilityLabel(isPlaying ? "Pause movie" : "Play movie")
                .accessibilityIdentifier("hf.player.stage.playPause")

                transportButton(systemImage: "goforward.10", title: "Forward 10", size: 66, isEnabled: hasPlayer) {
                    onSkip(10)
                }
            }

            HStack(spacing: 12) {
                Slider(
                    value: $playbackProgress,
                    in: 0...1,
                    onEditingChanged: { editing in
                        if !editing {
                            onScrub(playbackProgress)
                        }
                    }
                )
                .tint(HFColors.gold)
                .disabled(!hasPlayer)
                .accessibilityLabel("Playback position")

                iconButton(systemImage: "slider.horizontal.3", title: "Master controls", action: onOpenMasterControls)
                if showsImportButton, let onImportMovie {
                    iconButton(systemImage: "folder.badge.plus", title: "Import video", action: onImportMovie)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .modifier(HFStageLiquidGlassModifier(cornerRadius: 34, accent: HFColors.gold.opacity(0.24)))

            HStack(spacing: 10) {
                if let renderProgress {
                    renderProgressIcon(progress: renderProgress)
                }
                stageToggle(title: "Depth", systemImage: "cube.transparent", isOn: $settings.isDepthEnabled)
                stageToggle(title: "Motion", systemImage: "gyroscope", isOn: $settings.isMotionEnabled)
                stageToggle(title: "Tilt", systemImage: "viewfinder", isOn: $settings.isTiltEnabled)
                stageToggle(title: "Peek", systemImage: "scope", isOn: $settings.isPeekEnabled)
            }
        }
        .accessibilityIdentifier("hf.player.stageControlDeck")
    }

    private func stageToggle(title: String, systemImage: String, isOn: Binding<Bool>) -> some View {
        Button {
            isOn.wrappedValue.toggle()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .black))
                Text(title)
                    .font(.system(size: 10, weight: .black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(isOn.wrappedValue ? HFColors.gold : .white.opacity(0.78))
            .frame(width: 62, height: 44)
            .modifier(HFStageLiquidButtonModifier(isActive: isOn.wrappedValue, shape: .circle))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title) \(isOn.wrappedValue ? "on" : "off")")
    }

    private func renderProgressIcon(progress: Double) -> some View {
        let clampedProgress = max(0, min(progress, 1))
        let percent = Int((clampedProgress * 100).rounded())

        return VStack(spacing: 4) {
            Image(systemName: "gauge.with.dots.needle.67percent")
                .font(.system(size: 15, weight: .black))
            Text("Render")
                .font(.system(size: 10, weight: .black))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundStyle(HFColors.gold)
        .frame(width: 62, height: 44)
        .modifier(HFStageLiquidButtonModifier(isActive: true, shape: .circle))
        .overlay(alignment: .bottom) {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.14))
                    Capsule()
                        .fill(HFColors.goldGradient)
                        .frame(width: proxy.size.width * clampedProgress)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 9)
            .padding(.bottom, 4)
        }
        .accessibilityLabel("Rendering \(percent) percent")
        .accessibilityIdentifier("hf.player.stage.renderProgressIcon")
    }

    private func transportButton(
        systemImage: String,
        title: String,
        size: CGFloat,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 31, weight: .black))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .background(.ultraThinMaterial, in: Circle())
                .background(Circle().fill(Color.black.opacity(0.26)))
                .overlay(Circle().stroke(Color.white.opacity(0.24), lineWidth: 1))
                .overlay(Circle().stroke(HFColors.gold.opacity(0.24), lineWidth: 1).padding(1))
                .shadow(color: .black.opacity(0.28), radius: 16, x: 0, y: 9)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.48)
        .accessibilityLabel(title)
    }

    private func iconButton(
        systemImage: String,
        title: String,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .modifier(HFStageLiquidButtonModifier(isActive: false, shape: .circle))
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.48)
        .accessibilityLabel(title)
    }
}

private enum HFStageLiquidButtonShape {
    case circle
    case roundedRect
}

private struct HFStageLiquidGlassModifier: ViewModifier {
    let cornerRadius: CGFloat
    let accent: Color

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .background(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.10),
                        HFColors.gold.opacity(0.030),
                        HFColors.cyanGlow.opacity(0.020),
                        Color.black.opacity(0.045)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
            .overlay(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.30),
                                accent.opacity(0.70),
                                HFColors.cyanGlow.opacity(0.08),
                                Color.white.opacity(0.06)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .overlay(alignment: .top) {
                Capsule()
                    .fill(Color.white.opacity(0.15))
                    .frame(height: 1)
                    .padding(.horizontal, cornerRadius)
                    .padding(.top, 1)
            }
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius - 1, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 0.7)
                    .padding(1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.22), radius: 12, x: 0, y: 7)
            .shadow(color: accent.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

private struct HFStageLiquidButtonModifier: ViewModifier {
    let isActive: Bool
    let shape: HFStageLiquidButtonShape

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: clipShape)
            .background(
                LinearGradient(
                    colors: [
                        Color.white.opacity(isActive ? 0.16 : 0.10),
                        HFColors.gold.opacity(isActive ? 0.12 : 0.025),
                        HFColors.cyanGlow.opacity(isActive ? 0.050 : 0.020),
                        Color.black.opacity(isActive ? 0.040 : 0.060)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: clipShape
            )
            .overlay(
                clipShape
                    .stroke(isActive ? HFColors.gold.opacity(0.38) : Color.white.opacity(0.14), lineWidth: 1)
            )
            .overlay(alignment: .topLeading) {
                Capsule()
                    .fill(Color.white.opacity(isActive ? 0.18 : 0.11))
                    .frame(width: shape == .circle ? 18 : 28, height: 1)
                    .padding(.top, 5)
                    .padding(.leading, shape == .circle ? 11 : 12)
            }
            .shadow(color: isActive ? HFColors.gold.opacity(0.07) : Color.black.opacity(0.08), radius: isActive ? 8 : 5, x: 0, y: 3)
    }

    private var clipShape: some InsettableShape {
        RoundedRectangle(cornerRadius: shape == .circle ? 999 : 19, style: .continuous)
    }
}

private struct HFStageGlassSection<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(HFColors.gold)
                .textCase(.uppercase)

            content
        }
        .padding(14)
        .modifier(HFStageLiquidGlassModifier(cornerRadius: 24, accent: HFColors.gold.opacity(0.30)))
    }
}

private struct HFStageGlassToggle: View {
    let title: String
    let systemImage: String
    @Binding var isOn: Bool

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .black))
                    .frame(width: 24)
                Text(title)
                    .font(.system(size: 13, weight: .black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                Spacer(minLength: 0)
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 15, weight: .black))
            }
            .foregroundStyle(isOn ? .white : .white.opacity(0.72))
            .frame(height: 42)
            .padding(.horizontal, 11)
            .modifier(HFStageLiquidButtonModifier(isActive: isOn, shape: .roundedRect))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title) \(isOn ? "on" : "off")")
    }
}

private struct HFStageGlassSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>

    private var normalizedValue: Double {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return 0 }
        return max(0, min(1, (value - range.lowerBound) / span))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                Text("\(Int((normalizedValue * 100).rounded()))%")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(HFColors.gold)
                    .monospacedDigit()
            }

            Slider(value: $value, in: range)
                .tint(HFColors.gold)
        }
        .padding(11)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .background(Color.white.opacity(0.025), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.13), lineWidth: 1)
        )
    }
}

private final class HFVerticalStageLayerContainerView: UIView {
    let playerView = HKV1_PlayerLayerView()

    var framingScale: CGFloat = 1.0 {
        didSet { setNeedsLayout() }
    }

    private(set) var currentStageOffset: CGPoint = .zero
    private(set) var maxTravelX: CGFloat = 0
    private(set) var maxTravelY: CGFloat = 0

    private let portraitStageOverscanScale: CGFloat = 1.12
    private let landscapeStageOverscanScale: CGFloat = 1.10
    private let stageTravelUsage: CGFloat = 1.0
    private let stageFactor: CGFloat = 0.94

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        clipsToBounds = true
        playerView.clipsToBounds = false
        addSubview(playerView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutStage()
    }

    func setStageOffset(_ offset: CGPoint) {
        currentStageOffset = CGPoint(
            x: softLimitedOffset(offset.x, limit: maxTravelX),
            y: softLimitedOffset(offset.y, limit: maxTravelY)
        )
        applyStageCenter()
    }

    func resetMotion() {
        currentStageOffset = .zero
        applyStageCenter()
        playerView.bgOffset = .zero
        playerView.midOffset = .zero
        playerView.fgOffset = .zero
    }

    private func layoutStage() {
        guard bounds.width > 0, bounds.height > 0 else { return }

        let isPortrait = bounds.height >= bounds.width
        let stageSize = computeStageSize(for: bounds.size, isPortrait: isPortrait)
        maxTravelX = max(0, (stageSize.width - bounds.width) * 0.5) * stageTravelUsage
        maxTravelY = max(0, (stageSize.height - bounds.height) * 0.5) * stageTravelUsage
        currentStageOffset.x = max(-maxTravelX, min(maxTravelX, currentStageOffset.x))
        currentStageOffset.y = max(-maxTravelY, min(maxTravelY, currentStageOffset.y))
        playerView.bounds = CGRect(origin: .zero, size: stageSize)
        applyStageCenter()
    }

    private func computeStageSize(for maskSize: CGSize, isPortrait: Bool) -> CGSize {
        let safeFramingScale = max(0.94, min(framingScale / 1.24, 1.24))

        if isPortrait {
            let stageHeight = maskSize.height * portraitStageOverscanScale * safeFramingScale
            let stageWidth = stageHeight * (16.0 / 9.0)
            return CGSize(width: stageWidth, height: stageHeight)
        }

        let stageWidth = maskSize.width * landscapeStageOverscanScale * safeFramingScale
        let stageHeight = stageWidth * (9.0 / 16.0)
        if stageHeight < maskSize.height {
            let correctedHeight = maskSize.height * landscapeStageOverscanScale * safeFramingScale
            return CGSize(width: correctedHeight * (16.0 / 9.0), height: correctedHeight)
        }
        return CGSize(width: stageWidth, height: stageHeight)
    }

    private func applyStageCenter() {
        playerView.center = CGPoint(
            x: bounds.midX + currentStageOffset.x * stageFactor,
            y: bounds.midY + currentStageOffset.y * stageFactor
        )
    }

    private func softLimitedOffset(_ value: CGFloat, limit: CGFloat) -> CGFloat {
        guard limit > 0 else { return 0 }
        let normalized = value / limit
        return tanh(normalized) * limit
    }
}

private struct HFVerticalStageSpatialPeekLayerView: UIViewRepresentable {
    let player: AVPlayer
    let settings: HFDepthControlSettings
    let layer4State: HFLayer4RuntimeState
    let settingsRevision: Int

    func makeUIView(context: Context) -> HFVerticalStageLayerContainerView {
        let view = HFVerticalStageLayerContainerView()
        configure(view, context: context)
        context.coordinator.start(containerView: view)
        return view
    }

    func updateUIView(_ uiView: HFVerticalStageLayerContainerView, context: Context) {
        configure(uiView, context: context)
    }

    static func dismantleUIView(_ uiView: HFVerticalStageLayerContainerView, coordinator: Coordinator) {
        coordinator.stop()
        uiView.playerView.setPlayer(nil)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    private func configure(_ view: HFVerticalStageLayerContainerView, context: Context) {
        let depthActive = settings.isDepthEnabled && settings.isHighFiveDepthEnabled && layer4State == .spatialActive
        let motionActive = depthActive
            && settings.isMotionEnabled
            && settings.motionMode != .off
            && (settings.isTiltEnabled || settings.isPeekEnabled)
        let depthScaleGain = max(0.65, min(CGFloat(settings.depthScale), 1.70))
        let depthRenderAmount = HKV1_Layer4Math.clamp01(CGFloat(settings.depthRendering))
        let depthRenderGain = HKV1_Layer4Math.mix(0.0, 1.22, depthRenderAmount)
        let layer4Intent = settings.layer4CreatorIntent
        let layer4DepthGain = HKV1_Layer4Math.mix(0.88, 1.20, CGFloat(layer4Intent.depthAmount))
        view.framingScale = CGFloat(settings.framingScale * (settings.isDepthEnabled ? settings.depthScale : 1.0))
        view.playerView.setPlayer(player)
        view.playerView.allowsFallbackFullFrameMasks = depthActive
        view.playerView.setLensMode(settings.lensMode.playerLensMode)
        view.playerView.setLUTMode(settings.lutMode.playerLUTMode)
        view.playerView.setDepthIntensity(depthActive ? CGFloat(settings.depthIntensity) * depthScaleGain * layer4DepthGain * depthRenderGain : 0)
        view.playerView.setFocusFalloff(depthActive ? CGFloat(settings.focusFalloff) : 0)
        view.playerView.setPlaneAuthority(
            bg: depthActive ? CGFloat(settings.bgPlaneControl) * depthScaleGain * layer4DepthGain * max(0.22, depthRenderGain) : 1.0,
            mid: depthActive ? CGFloat(settings.midPlaneControl) * depthScaleGain * layer4DepthGain * max(0.22, depthRenderGain) : 1.0,
            fg: depthActive ? CGFloat(settings.fgPlaneControl) * depthScaleGain * layer4DepthGain * max(0.22, depthRenderGain) : 1.0,
            userDriven: true
        )
        view.playerView.setRenderMode(depthActive ? .depthPrepared : .flat)
        view.playerView.setSpatialMode(depthActive ? .threePlane : .flat)
        context.coordinator.apply(settings: settings, layer4State: layer4State, revision: settingsRevision)
        if !motionActive {
            context.coordinator.resetMotionSmoothing()
        }
        context.coordinator.start(containerView: view)
    }

    final class Coordinator: NSObject {
        private var settings = HFDepthControlSettings()
        private var layer4State: HFLayer4RuntimeState = .idle
        private var settingsRevision = 0

        private let motionService = HKV1_MotionService()
        private let proMotionCoordinator = HKV1_ProMotionCoordinator()
        private let layer4Envelope = HKV1_Layer4StableEnvelope()
        private let layer4DepthDirector = HKV1_Layer4DepthDirector()
        private weak var containerView: HFVerticalStageLayerContainerView?
        private var displayLink: CADisplayLink?
        private var lastTimestamp: CFTimeInterval = 0
        private var neutralTilt: CGPoint?
        private var smoothedDx: CGFloat = 0
        private var smoothedDy: CGFloat = 0
        private var lastLayer4Snapshot: HKV1_Layer4StableSnapshot?
        private var lastPlaneIntent: HKV1_Layer4PlaneResidualIntent = .neutral

        func apply(settings newSettings: HFDepthControlSettings, layer4State newLayer4State: HFLayer4RuntimeState, revision: Int) {
            let oldSettings = settings
            let oldLayer4State = layer4State
            settings = newSettings
            layer4State = newLayer4State
            settingsRevision = revision
            layer4DepthDirector.setProfile(newSettings.layer4DepthDirectorProfile)

            if shouldResetMotion(from: oldSettings, to: newSettings, oldLayer4State: oldLayer4State, newLayer4State: newLayer4State) {
                resetMotionSmoothing()
            }
        }

        func start(containerView: HFVerticalStageLayerContainerView) {
            self.containerView = containerView
            if !motionService.isRunning {
                motionService.simulatorTiltMode = .figureEight
                motionService.simulatorAmplitudeX = 0.22
                motionService.simulatorAmplitudeY = 0.13
                motionService.simulatorSpeed = 0.95
                motionService.start()
            }
            if displayLink == nil {
                let link = CADisplayLink(target: self, selector: #selector(step(_:)))
                link.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 60, preferred: 60)
                link.add(to: .main, forMode: .common)
                displayLink = link
            }
        }

        func stop() {
            displayLink?.invalidate()
            displayLink = nil
            motionService.stop()
            resetMotionSmoothing()
        }

        func resetMotionSmoothing() {
            proMotionCoordinator.reset()
            motionService.reset()
            lastTimestamp = 0
            neutralTilt = nil
            smoothedDx = 0
            smoothedDy = 0
            layer4Envelope.reset()
            lastLayer4Snapshot = nil
            lastPlaneIntent = .neutral
            containerView?.resetMotion()
        }

        @objc private func step(_ link: CADisplayLink) {
            guard let containerView else { return }

            let deltaTime: CGFloat
            let previousTimestamp = lastTimestamp
            if lastTimestamp > 0 {
                deltaTime = CGFloat(max(1.0 / 120.0, min(link.timestamp - lastTimestamp, 1.0 / 20.0)))
            } else {
                deltaTime = 1.0 / 60.0
            }
            lastTimestamp = link.timestamp

            let motionActive = settings.isMotionEnabled && settings.motionMode != .off && (settings.isTiltEnabled || settings.isPeekEnabled)
            guard settings.isDepthEnabled, settings.isHighFiveDepthEnabled, layer4State == .spatialActive, motionActive else {
                containerView.resetMotion()
                layer4Envelope.reset()
                lastLayer4Snapshot = nil
                lastPlaneIntent = .neutral
                return
            }

            let tilt = motionService.readTilt()
            let lens = settings.lensMode.motionLensProfile
            let maxDx = max(70, containerView.maxTravelX)
            let maxDy = max(48, containerView.maxTravelY)
            let creatorIntent = settings.layer4CreatorIntent
            let tiltWeight = settings.isTiltEnabled ? CGFloat(settings.tiltResponse) : 0
            let peekWeight = settings.isPeekEnabled ? CGFloat(settings.peekResponse) : 0
            let aiAssistResponse = settings.isAIAssistEnabled ? 0.72 : 1.0
            let rawTilt = CGPoint(x: CGFloat(tilt.x), y: CGFloat(tilt.y))
            if neutralTilt == nil {
                neutralTilt = rawTilt
            }
            let viewerTilt = calibratedViewerTilt(rawTilt)
            let rangeAmount = HKV1_Layer4Math.clamp01(CGFloat(settings.motionRange))
            let actionAmount = HKV1_Layer4Math.smootherstep(
                HKV1_Layer4Math.clamp01(max(tiltWeight, peekWeight) * rangeAmount)
            )
            let response = max(0.18, max(tiltWeight, peekWeight) * settings.motionMode.responseGain * aiAssistResponse * HKV1_Layer4Math.mix(1.0, 1.34, actionAmount))
            let output = proMotionCoordinator.compute(
                roll: clamp(viewerTilt.x * response, min: -0.72, max: 0.72),
                pitch: clamp(viewerTilt.y * response, min: -0.54, max: 0.54),
                deltaTime: deltaTime * HKV1_Layer4Math.mix(1.54, 2.10, actionAmount),
                lensProfile: lens,
                personality: .cinematic,
                maxDx: maxDx,
                maxDy: maxDy
            )

            let target = currentMotionTarget(
                from: output,
                tiltEnabled: settings.isTiltEnabled,
                peekEnabled: settings.isPeekEnabled,
                peekAssist: CGFloat(creatorIntent.peekAssistAmount)
            )
            let tuning = resolvedMotionResponse(lensProfile: lens, isWide: settings.motionMode == .wide, maxDx: maxDx, maxDy: maxDy)
            let centerSmooth = CGFloat(creatorIntent.centerSmoothAmount)
            let recenter = CGFloat(creatorIntent.recenterAmount)
            let edgeProtect = CGFloat(creatorIntent.edgeProtectAmount)
            let recenterDampX = lerp(tuning.residualDampX, 0.946, recenter)
            let recenterDampY = lerp(tuning.residualDampY, 0.950, recenter)
            let actionTargetGain = settings.motionMode == .wide ? HKV1_Layer4Math.mix(1.0, 1.85, actionAmount) : HKV1_Layer4Math.mix(1.0, 1.22, actionAmount)
            let boostedTarget = CGPoint(x: target.x * actionTargetGain, y: target.y * actionTargetGain)
            smoothedDx = premiumWeightedBlend(current: smoothedDx, target: boostedTarget.x, dt: deltaTime, response: tuning.x * HKV1_Layer4Math.mix(1.0, 1.42, actionAmount), residualDamp: recenterDampX)
            smoothedDy = premiumWeightedBlend(current: smoothedDy, target: boostedTarget.y, dt: deltaTime, response: tuning.y * HKV1_Layer4Math.mix(1.0, 1.36, actionAmount), residualDamp: recenterDampY)
            let safeLimitX: CGFloat
            let safeLimitY: CGFloat
            if settings.motionMode == .wide {
                safeLimitX = maxDx * softLimitInputMultiplier(forFinalTravelRatio: 0.85 * rangeAmount)
                safeLimitY = maxDy * softLimitInputMultiplier(forFinalTravelRatio: 0.85 * rangeAmount)
            } else {
                safeLimitX = maxDx * HKV1_Layer4Math.mix(1.0, 0.86, edgeProtect) * rangeAmount
                safeLimitY = maxDy * HKV1_Layer4Math.mix(1.0, 0.88, edgeProtect) * rangeAmount
            }

            let approvedOffset = CGPoint(
                x: featherEdgeLimit(
                    value: softenedCenterOffset(smoothedDx, centerWidth: tuning.centerWidthX * 0.78 * centerSmooth),
                    limit: safeLimitX * 0.985,
                    shoulderStart: 0.72,
                    softness: 0.42
                ),
                y: featherEdgeLimit(
                    value: softenedCenterOffset(smoothedDy, centerWidth: tuning.centerWidthY * 0.82 * centerSmooth),
                    limit: safeLimitY * 0.985,
                    shoulderStart: 0.74,
                    softness: 0.46
                )
            )
            containerView.setStageOffset(approvedOffset)

            let snapshot = layer4Envelope.observe(
                rawIntentX: viewerTilt.x,
                rawIntentY: viewerTilt.y,
                outputDx: containerView.currentStageOffset.x,
                outputDy: containerView.currentStageOffset.y,
                maxDx: maxDx,
                maxDy: maxDy,
                depthOn: true,
                dt: deltaTime,
                creatorIntent: creatorIntent
            )
            let planeIntent = layer4DepthDirector.resolvePlaneIntent(snapshot: snapshot, depthOn: true)
            lastLayer4Snapshot = snapshot
            lastPlaneIntent = planeIntent

            let residual = CGPoint(
                x: containerView.currentStageOffset.x * (settings.motionMode == .wide ? 0.10 : 0.12),
                y: containerView.currentStageOffset.y * (settings.motionMode == .wide ? 0.10 : 0.12)
            )
            let authorityX = abs(containerView.currentStageOffset.x) / max(1, maxDx)
            let authorityY = abs(containerView.currentStageOffset.y) / max(1, maxDy)
            let authority = HKV1_Layer4Math.clamp01(hypot(authorityX, authorityY))
            let travelAssist = smoothstep(edge0: 0.18, edge1: 0.62, x: authority) * CGFloat(creatorIntent.peekAssistAmount)
            let residualScale = 1.0 + (travelAssist * 0.20)
            let finalEnergy = max(snapshot.depthEnergySafe, settings.layer4Preset == .lock ? 0.14 : 0.08)
            let depthEnergyScale = HKV1_Layer4Math.mix(0.28, 1.0, finalEnergy)
            let depthGain = max(0.35, min(CGFloat(settings.depthIntensity) / 1.25, 2.15))
            let depthScaleGain = max(0.65, min(CGFloat(settings.depthScale), 1.70))
            let depthRenderAmount = HKV1_Layer4Math.clamp01(CGFloat(settings.depthRendering))
            let depthRenderGain = HKV1_Layer4Math.mix(0.0, 1.22, depthRenderAmount)
            let volumetricScalar = snapshot.volumetricIntent.existingDepthScalar *
                HKV1_Layer4Math.mix(1.0, 1.16, snapshot.volumetricIntent.hyperAmountSafe) *
                max(0.0, depthRenderGain)
            let planeGlobal = planeIntent.globalScalar * volumetricScalar
            let bgUser = max(0.05, CGFloat(settings.bgPlaneControl) / 1.58)
            let midUser = max(0.05, CGFloat(settings.midPlaneControl) / 1.74)
            let fgUser = max(0.05, CGFloat(settings.fgPlaneControl) / 2.05)
            let playerView = containerView.playerView
            playerView.setDepthIntensity(CGFloat(settings.depthIntensity) * depthScaleGain * volumetricScalar)
            playerView.setPlaneAuthority(
                bg: CGFloat(settings.bgPlaneControl) * depthScaleGain * max(0.22, depthRenderGain) * planeIntent.backgroundScalar,
                mid: CGFloat(settings.midPlaneControl) * depthScaleGain * max(0.22, depthRenderGain) * planeIntent.midgroundScalar,
                fg: CGFloat(settings.fgPlaneControl) * depthScaleGain * max(0.22, depthRenderGain) * planeIntent.foregroundScalar,
                userDriven: true
            )
            playerView.bgOffset = CGPoint(
                x: residual.x * residualScale * (0.18 + depthGain * 0.04) * depthEnergyScale * planeGlobal * planeIntent.backgroundScalar * bgUser,
                y: residual.y * residualScale * (0.11 + depthGain * 0.03) * depthEnergyScale * planeGlobal * planeIntent.backgroundScalar * bgUser
            )
            playerView.midOffset = CGPoint(
                x: residual.x * residualScale * (0.42 + depthGain * 0.10) * depthEnergyScale * planeGlobal * planeIntent.midgroundScalar * midUser,
                y: residual.y * residualScale * (0.25 + depthGain * 0.07) * depthEnergyScale * planeGlobal * planeIntent.midgroundScalar * midUser
            )
            playerView.fgOffset = CGPoint(
                x: residual.x * residualScale * (0.70 + depthGain * 0.16) * depthEnergyScale * planeGlobal * planeIntent.foregroundScalar * fgUser,
                y: residual.y * residualScale * (0.42 + depthGain * 0.12) * depthEnergyScale * planeGlobal * planeIntent.foregroundScalar * fgUser
            )
            #if DEBUG
            if HFPlayerLayer4DebugGate.isEnabled, Int(link.timestamp * 2) != Int(previousTimestamp * 2) {
                print("[Layer4] rev=\(settingsRevision) preset=\(settings.layer4Preset.rawValue) activeCrossing=\(String(format: "%.2f", snapshot.activeCrossing)) centerBridge=\(String(format: "%.2f", snapshot.depthEnergySafe)) depthLock=\(String(format: "%.2f", snapshot.depthLockAmount)) travelAssist=\(String(format: "%.2f", travelAssist)) recenter=\(String(format: "%.2f", creatorIntent.recenterAmount)) hyper=\(String(format: "%.2f", snapshot.volumetricIntent.hyperAmountSafe)) offset=(\(Int(containerView.currentStageOffset.x)),\(Int(containerView.currentStageOffset.y)))")
            }
            #endif
        }

        private func shouldResetMotion(
            from oldSettings: HFDepthControlSettings,
            to newSettings: HFDepthControlSettings,
            oldLayer4State: HFLayer4RuntimeState,
            newLayer4State: HFLayer4RuntimeState
        ) -> Bool {
            oldLayer4State != newLayer4State
                || oldSettings.isDepthEnabled != newSettings.isDepthEnabled
                || oldSettings.isHighFiveDepthEnabled != newSettings.isHighFiveDepthEnabled
                || oldSettings.isMotionEnabled != newSettings.isMotionEnabled
                || oldSettings.isTiltEnabled != newSettings.isTiltEnabled
                || oldSettings.isPeekEnabled != newSettings.isPeekEnabled
                || oldSettings.motionMode != newSettings.motionMode
                || oldSettings.lensMode != newSettings.lensMode
                || oldSettings.layer4GoldenSafeMode != newSettings.layer4GoldenSafeMode
        }

        private func calibratedViewerTilt(_ tilt: CGPoint) -> CGPoint {
            let neutral = neutralTilt ?? .zero
            return CGPoint(
                x: clamp(tilt.x - neutral.x, min: -0.62, max: 0.62),
                y: clamp(tilt.y - neutral.y, min: -0.46, max: 0.46)
            )
        }

        private func currentMotionTarget(
            from output: HKV1_ProMotionOutput,
            tiltEnabled: Bool,
            peekEnabled: Bool,
            peekAssist: CGFloat
        ) -> CGPoint {
            switch (tiltEnabled, peekEnabled) {
            case (true, true):
                let baseBlend: CGFloat = settings.motionMode == .wide ? 0.62 : 0.54
                let peekBlend = min(0.82, baseBlend + (peekAssist * 0.18))
                return CGPoint(
                    x: lerp(output.tiltDx, output.peekDx, peekBlend),
                    y: lerp(output.tiltDy, output.peekDy, peekBlend)
                )
            case (true, false):
                return CGPoint(x: output.tiltDx, y: output.tiltDy)
            case (false, true):
                let baseGain: CGFloat = settings.motionMode == .wide ? 0.94 : 0.86
                let peekOnlyGain = min(1.12, baseGain + (peekAssist * 0.22))
                return CGPoint(x: output.peekDx * peekOnlyGain, y: output.peekDy * peekOnlyGain)
            case (false, false):
                return .zero
            }
        }

        private func resolvedMotionResponse(
            lensProfile: HKV1_ProMotionCoordinator.LensProfile,
            isWide: Bool,
            maxDx: CGFloat,
            maxDy: CGFloat
        ) -> (x: CGFloat, y: CGFloat, centerWidthX: CGFloat, centerWidthY: CGFloat, residualDampX: CGFloat, residualDampY: CGFloat) {
            switch lensProfile {
            case .natural:
                return isWide
                    ? (x: 8.8, y: 8.0, centerWidthX: max(7.0, maxDx * 0.082), centerWidthY: max(4.8, maxDy * 0.110), residualDampX: 0.985, residualDampY: 0.988)
                    : (x: 10.2, y: 9.4, centerWidthX: max(6.2, maxDx * 0.074), centerWidthY: max(4.4, maxDy * 0.102), residualDampX: 0.982, residualDampY: 0.986)
            case .anamorphic:
                return isWide
                    ? (x: 8.4, y: 7.6, centerWidthX: max(7.4, maxDx * 0.086), centerWidthY: max(4.6, maxDy * 0.104), residualDampX: 0.986, residualDampY: 0.989)
                    : (x: 9.6, y: 8.8, centerWidthX: max(6.6, maxDx * 0.078), centerWidthY: max(4.2, maxDy * 0.096), residualDampX: 0.983, residualDampY: 0.987)
            case .portrait:
                return isWide
                    ? (x: 8.0, y: 7.2, centerWidthX: max(6.6, maxDx * 0.080), centerWidthY: max(4.4, maxDy * 0.108), residualDampX: 0.987, residualDampY: 0.989)
                    : (x: 9.0, y: 8.2, centerWidthX: max(5.8, maxDx * 0.072), centerWidthY: max(4.0, maxDy * 0.100), residualDampX: 0.984, residualDampY: 0.987)
            }
        }

        private func softenedCenterOffset(_ value: CGFloat, centerWidth: CGFloat) -> CGFloat {
            let magnitude = abs(value)
            guard centerWidth > 0, magnitude > 0 else { return value }
            let t = clamp(magnitude / centerWidth, min: 0, max: 1)
            let eased = t * t * (3 - (2 * t))
            let scale = 0.82 + (0.18 * eased)
            return (value >= 0 ? 1 : -1) * magnitude * scale
        }

        private func premiumWeightedBlend(current: CGFloat, target: CGFloat, dt: CGFloat, response: CGFloat, residualDamp: CGFloat) -> CGFloat {
            let alpha = 1.0 - exp(-response * dt)
            var next = current + ((target - current) * alpha)
            if abs(target) < 0.0012 {
                next *= residualDamp
            }
            if abs(next) < 0.0008 {
                next = 0
            }
            return next
        }

        private func featherEdgeLimit(value: CGFloat, limit: CGFloat, shoulderStart: CGFloat, softness: CGFloat) -> CGFloat {
            guard limit > 0 else { return 0 }
            let normalized = clamp(value / limit, min: -1, max: 1)
            let sign: CGFloat = normalized < 0 ? -1 : 1
            let magnitude = abs(normalized)
            if magnitude <= shoulderStart {
                return normalized * limit
            }
            let remaining = max(0.0001, 1 - shoulderStart)
            let u = clamp((magnitude - shoulderStart) / remaining, min: 0, max: 1)
            let eased = shoulderStart + ((1 - shoulderStart) * (1 - exp(-(u / max(0.0001, softness)))))
            return sign * min(1, eased) * limit
        }

        private func softLimitInputMultiplier(forFinalTravelRatio ratio: CGFloat) -> CGFloat {
            let target = clamp(ratio, min: 0, max: 0.85)
            guard target > 0 else { return 0 }
            return 0.5 * log((1 + target) / max(0.0001, 1 - target))
        }

        private func smoothstep(edge0: CGFloat, edge1: CGFloat, x: CGFloat) -> CGFloat {
            guard edge0 != edge1 else { return x < edge0 ? 0 : 1 }
            let t = max(0, min(1, (x - edge0) / (edge1 - edge0)))
            return t * t * (3 - 2 * t)
        }

        private func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
            a + ((b - a) * t)
        }

        private func clamp(_ value: CGFloat, min lowerBound: CGFloat, max upperBound: CGFloat) -> CGFloat {
            Swift.max(lowerBound, Swift.min(upperBound, value))
        }
    }
}

private struct HFAspectFillAVPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer
    let showsPlaybackControls: Bool
    var videoGravity: AVLayerVideoGravity = .resizeAspectFill

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = showsPlaybackControls
        controller.videoGravity = videoGravity
        controller.allowsPictureInPicturePlayback = false
        controller.updatesNowPlayingInfoCenter = false
        return controller
    }

    func updateUIViewController(_ controller: AVPlayerViewController, context: Context) {
        if controller.player !== player {
            controller.player = player
        }
        controller.showsPlaybackControls = showsPlaybackControls
        controller.videoGravity = videoGravity
    }
}

private struct HFDepthMasterControlSheet: View {
    @Binding var settings: HFDepthControlSettings
    @Binding var isPlaying: Bool
    @Binding var playbackProgress: Double
    let hasPlayer: Bool
    let onTogglePlayback: () -> Void
    let onSkip: (Double) -> Void
    let onScrub: (Double) -> Void
    let onImportMovie: (() -> Void)?
    var showsImportControls = false
    var onDone: (() -> Void)?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { proxy in
            let contentWidth = max(0, proxy.size.width - 32)

            VStack(alignment: .leading, spacing: 12) {
                Capsule()
                    .fill(.white.opacity(0.28))
                    .frame(width: 42, height: 4)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 10)

                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Master Controls")
                            .font(.system(size: 24, weight: .black))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                        Text("Live depth, motion, lens, and fill")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                    }

                    Spacer(minLength: 12)

                    Button {
                        if let onDone {
                            onDone()
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .black))
                            .foregroundStyle(.white)
                            .frame(width: 38, height: 38)
                            .modifier(HFStageLiquidButtonModifier(isActive: false, shape: .circle))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close master controls")
                }
                .padding(.horizontal, 16)

                ScrollView(showsIndicators: false) {
                    allMasterControls
                    .frame(width: contentWidth, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .background(Color.clear)
        .preferredColorScheme(.dark)
        .accessibilityIdentifier("hf.player.depthMasterControls")
    }

    private var allMasterControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            quickControls
            layer4Controls
            masterToggleControls
            depthControls
            proControls
            motionControls
            fineTuneControls
            if showsImportControls {
                importControls
            }
        }
    }

    private var quickControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            HFStageGlassSection(title: "Quick", systemImage: "slider.horizontal.3") {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    HFStageGlassToggle(title: "Depth", systemImage: "cube.transparent", isOn: $settings.isDepthEnabled)
                    HFStageGlassToggle(title: "Motion", systemImage: "gyroscope", isOn: $settings.isMotionEnabled)
                    HFStageGlassToggle(title: "Tilt", systemImage: "viewfinder", isOn: $settings.isTiltEnabled)
                    HFStageGlassToggle(title: "Peek", systemImage: "scope", isOn: $settings.isPeekEnabled)
                }
                HFStageGlassSlider(title: "Scale / Phone Fill", value: $settings.framingScale, range: 1.0...1.38)
                HFStageGlassSlider(title: "Depth Intensity", value: $settings.depthIntensity, range: 0...3)
                HFStageGlassSlider(title: "Depth Rendering", value: $settings.depthRendering, range: 0...1)
            }

            presetControls
        }
    }

    private var layer4Controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            HFStageGlassSection(title: "Layer 4", systemImage: "square.stack.3d.up.fill") {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(HKV1_Layer4CreatorIntent.Preset.allCases, id: \.self) { preset in
                        masterPresetButton(
                            title: preset.title,
                            isActive: settings.layer4Preset == preset
                        ) {
                            settings.applyLayer4Preset(preset)
                        }
                    }
                }

                HFStageGlassSlider(title: "Depth", value: $settings.layer4DepthAmount, range: 0...1)
                HFStageGlassSlider(title: "Peek Travel Assist", value: $settings.layer4PeekAssistAmount, range: 0...1)
                HFStageGlassSlider(title: "Safe Center Anchor", value: $settings.layer4CenterSmoothAmount, range: 0...1)
                HFStageGlassSlider(title: "Recenter", value: $settings.layer4RecenterAmount, range: 0...1)
                HFStageGlassSlider(title: "Edge Protection", value: $settings.layer4EdgeProtectAmount, range: 0...1)
                HFStageGlassSlider(title: "Hyper", value: $settings.layer4HyperAmount, range: 0...1)
                HFStageGlassToggle(title: "Golden Safe Mode", systemImage: "checkmark.shield.fill", isOn: $settings.layer4GoldenSafeMode)
            }
        }
    }

    private var legacyControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            masterToggleControls
            presetControls
            depthControls
            proControls
            motionControls
        }
    }

    private var fineTuneControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            HFStageGlassSection(title: "Fine Tune", systemImage: "slider.horizontal.below.rectangle") {
                HFStageGlassSlider(title: "Depth Intensity", value: $settings.depthIntensity, range: 0...3)
                HFStageGlassSlider(title: "Focus", value: $settings.focusFalloff, range: 0...1)
                HFStageGlassSlider(title: "BG", value: $settings.bgPlaneControl, range: 0.2...2.2)
                HFStageGlassSlider(title: "MID", value: $settings.midPlaneControl, range: 0.2...2.4)
                HFStageGlassSlider(title: "FG", value: $settings.fgPlaneControl, range: 0.2...2.8)
                HFStageGlassSlider(title: "Tilt Response", value: $settings.tiltResponse, range: 0...1)
                HFStageGlassSlider(title: "Peek Response", value: $settings.peekResponse, range: 0...1)
                HFStageGlassSlider(title: "Motion Range", value: $settings.motionRange, range: 0...1)
                HFStageGlassSlider(title: "Depth Scale", value: $settings.depthScale, range: 0.70...1.70)
                HFStageGlassSlider(title: "Scale / Phone Fill", value: $settings.framingScale, range: 1.0...1.38)
                HFStageGlassSlider(title: "Safe Center Anchor", value: $settings.layer4CenterSmoothAmount, range: 0...1)
                HFStageGlassSlider(title: "Recenter Settle", value: $settings.layer4RecenterAmount, range: 0...1)
                HFStageGlassSlider(title: "Edge Protection", value: $settings.layer4EdgeProtectAmount, range: 0...1)
            }
        }
    }

    private var importControls: some View {
        HFStageGlassSection(title: "Imported Video", systemImage: "folder.badge.plus") {
            HStack(spacing: 12) {
                if let onImportMovie {
                    masterIconButton(systemImage: "folder.badge.plus", title: "Re-import", isEnabled: true) {
                        onImportMovie()
                    }
                }
            }
        }
    }

    private var masterToggleControls: some View {
        HFStageGlassSection(title: "Master", systemImage: "slider.horizontal.3") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                HFStageGlassToggle(title: "Depth", systemImage: "cube.transparent", isOn: $settings.isDepthEnabled)
                HFStageGlassToggle(title: "Motion", systemImage: "gyroscope", isOn: $settings.isMotionEnabled)
                HFStageGlassToggle(title: "Tilt", systemImage: "viewfinder", isOn: $settings.isTiltEnabled)
                HFStageGlassToggle(title: "Peek", systemImage: "scope", isOn: $settings.isPeekEnabled)
                HFStageGlassToggle(title: "AI", systemImage: "sparkles.tv", isOn: $settings.isAIAssistEnabled)
                HFStageGlassToggle(title: "HighFive", systemImage: "sparkles", isOn: $settings.isHighFiveDepthEnabled)
            }
            HFStageGlassToggle(title: "Render Overlay", systemImage: "square.grid.3x3", isOn: $settings.showsRenderOverlay)
        }
    }

    private var presetControls: some View {
        HFStageGlassSection(title: "Preset", systemImage: "dial.high") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(HFDepthControlSettings.Preset.allCases) { preset in
                    masterPresetButton(
                        title: preset.rawValue,
                        isActive: settings.preset == preset
                    ) {
                        settings.applyPreset(preset)
                    }
                }
            }
        }
    }

    private var depthControls: some View {
        HFStageGlassSection(title: "Depth", systemImage: "cube.transparent") {
            HFStageGlassSlider(title: "Depth Intensity", value: $settings.depthIntensity, range: 0...3)
            HFStageGlassSlider(title: "Depth Rendering", value: $settings.depthRendering, range: 0...1)
            HFStageGlassSlider(title: "Focus", value: $settings.focusFalloff, range: 0...1)
            HFStageGlassSlider(title: "Depth Scale", value: $settings.depthScale, range: 0.70...1.70)
            HFStageGlassSlider(title: "Scale / Phone Fill", value: $settings.framingScale, range: 1.0...1.38)
        }
    }

    private var proControls: some View {
        HFStageGlassSection(title: "Plane Separation", systemImage: "slider.horizontal.below.rectangle") {
            HFStageGlassSlider(title: "BG Plane", value: $settings.bgPlaneControl, range: 0.2...2.2)
            HFStageGlassSlider(title: "MID Plane", value: $settings.midPlaneControl, range: 0.2...2.4)
            HFStageGlassSlider(title: "FG Plane", value: $settings.fgPlaneControl, range: 0.2...2.8)
        }
    }

    private var motionControls: some View {
        HFStageGlassSection(title: "MOTION", systemImage: "gyroscope") {
            Picker("Mode", selection: $settings.motionMode) {
                ForEach(HFDepthControlSettings.MotionMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .tint(HFColors.gold)
            HFStageGlassSlider(title: "Tilt Response", value: $settings.tiltResponse, range: 0...1)
            HFStageGlassSlider(title: "Peek Response", value: $settings.peekResponse, range: 0...1)
            HFStageGlassSlider(title: "Motion Range", value: $settings.motionRange, range: 0...1)
        }
    }

    private func masterPresetButton(title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(isActive ? .black : .white.opacity(0.86))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(isActive ? HFColors.gold : Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(isActive ? Color.clear : Color.white.opacity(0.13), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title) preset")
    }

    private func masterIconButton(
        systemImage: String,
        title: String,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .modifier(HFStageLiquidButtonModifier(isActive: false, shape: .circle))
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.45)
        .accessibilityLabel(title)
    }
}

private struct HFDepthTiltRenderOverlay: View {
    let compact: Bool
    let showsBadges: Bool
    let settings: HFDepthControlSettings
    @ObservedObject var motionModel: HFPlayerTiltMotionModel

    private var tiltX: CGFloat {
        guard settings.isMotionEnabled, settings.motionMode != .off, settings.isTiltEnabled else { return 0 }
        return motionModel.effectiveTiltX * CGFloat(settings.tiltResponse) * settings.motionMode.responseGain
    }

    private var tiltY: CGFloat {
        guard settings.isMotionEnabled, settings.motionMode != .off, settings.isTiltEnabled else { return 0 }
        return motionModel.effectiveTiltY * CGFloat(settings.tiltResponse) * settings.motionMode.responseGain
    }

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let depthGain = settings.isDepthEnabled ? CGFloat(settings.depthIntensity) : 0
            let travelX = tiltX * (compact ? 10 : 28) * depthGain
            let travelY = tiltY * (compact ? 7 : 18) * depthGain

            ZStack {
                ForEach(0..<9, id: \.self) { index in
                    let inset = CGFloat(index) * (compact ? 18 : 34)
                    RoundedRectangle(cornerRadius: compact ? 24 : 42, style: .continuous)
                        .inset(by: inset)
                        .stroke(
                            HFColors.cyanGlow.opacity(compact ? 0.18 : 0.30),
                            lineWidth: index == 0 ? 1.2 : 0.75
                        )
                        .offset(
                            x: travelX * CGFloat(index + 1) / 9,
                            y: travelY * CGFloat(index + 1) / 9
                        )
                }

                Path { path in
                    let lanes = compact ? 5 : 9
                    for lane in 1...lanes {
                        let x = width * CGFloat(lane) / CGFloat(lanes + 1)
                        path.move(to: CGPoint(x: x + travelX, y: 0))
                        path.addLine(to: CGPoint(x: x - travelX, y: height))
                    }
                    for lane in 1...max(3, lanes - 2) {
                        let y = height * CGFloat(lane) / CGFloat(lanes)
                        path.move(to: CGPoint(x: 0, y: y + travelY))
                        path.addLine(to: CGPoint(x: width, y: y - travelY))
                    }
                }
                .stroke(HFColors.gold.opacity(compact ? 0.14 : 0.24), lineWidth: 0.7)

                LinearGradient(
                    colors: [
                        HFColors.cyanGlow.opacity(compact ? 0.05 : 0.12),
                        .clear,
                        HFColors.gold.opacity(compact ? 0.07 : 0.16)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .blendMode(.screen)

                if showsBadges {
                    VStack {
                        HStack(spacing: 8) {
                            HFDepthTiltBadge(title: "Depth Render", systemImage: "cube.transparent")
                            HFDepthTiltBadge(title: motionModel.isLive ? "Tilt Live" : "Tilt Sim", systemImage: "viewfinder")
                            Spacer()
                        }
                        .padding(compact ? 10 : 16)

                        Spacer()
                    }
                }
            }
            .rotation3DEffect(.degrees(Double(tiltX) * (compact ? 3 : 7)), axis: (x: 0, y: 1, z: 0), perspective: 0.72)
            .rotation3DEffect(.degrees(Double(tiltY) * (compact ? 2 : 5)), axis: (x: 1, y: 0, z: 0), perspective: 0.72)
        }
        .opacity(compact ? 0.78 : 0.90)
        .accessibilityLabel("Depth render overlay with tilt motion")
    }
}

private struct HFDepthTiltBadge: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.system(size: 11, weight: .black))
            .foregroundStyle(.black)
            .padding(.horizontal, 10)
            .frame(height: 28)
            .background(HFColors.gold)
            .clipShape(Capsule())
    }
}

private final class HFPlayerTiltMotionModel: ObservableObject {
    @Published var tiltX: CGFloat = 0
    @Published var tiltY: CGFloat = 0
    @Published var isLive = false

    private let motionService = HKV1_MotionService()
    private var displayLink: CADisplayLink?
    private var filteredX: CGFloat = 0
    private var filteredY: CGFloat = 0
    private let smoothing: CGFloat = 0.18
    private let deadZone: CGFloat = 0.018

    var effectiveTiltX: CGFloat {
        tiltX
    }

    var effectiveTiltY: CGFloat {
        tiltY
    }

    func start() {
        stop()

        #if targetEnvironment(simulator)
        motionService.simulatorTiltMode = .figureEight
        motionService.simulatorAmplitudeX = 0.62
        motionService.simulatorAmplitudeY = 0.40
        motionService.simulatorSpeed = 1.0
        #endif

        motionService.start()
        isLive = motionService.isRunning
        let link = CADisplayLink(target: self, selector: #selector(stepMotion))
        link.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 60, preferred: 60)
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
        motionService.stop()
        isLive = false
    }

    @objc private func stepMotion() {
        let tilt = motionService.readTilt()
        filteredX += (CGFloat(tilt.x) - filteredX) * smoothing
        filteredY += (CGFloat(tilt.y) - filteredY) * smoothing
        tiltX = softenCenter(max(-0.85, min(0.85, filteredX)))
        tiltY = softenCenter(max(-0.85, min(0.85, filteredY)))
        isLive = motionService.isRunning
    }

    private func softenCenter(_ value: CGFloat) -> CGFloat {
        let magnitude = abs(value)
        guard magnitude > deadZone else { return 0 }
        let normalized = (magnitude - deadZone) / max(0.0001, 1 - deadZone)
        let eased = normalized * normalized * (3 - 2 * normalized)
        return (value < 0 ? -1 : 1) * eased
    }
}
