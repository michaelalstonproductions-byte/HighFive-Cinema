import Foundation

enum HKCContentType: Equatable {
    case movie
    case series
}

struct HKCEpisode: Identifiable, Equatable {
    let id: String
    let title: String
    let episodeNumber: Int
    let runtimeText: String?
    let bundledVideoName: String?
    let priceText: String?

    init(
        id: String,
        title: String,
        episodeNumber: Int,
        runtimeText: String? = nil,
        bundledVideoName: String? = nil,
        priceText: String? = "$1.99"
    ) {
        self.id = id
        self.title = title
        self.episodeNumber = episodeNumber
        self.runtimeText = runtimeText
        self.bundledVideoName = bundledVideoName
        self.priceText = priceText
    }
}

struct HKCMovie: Identifiable, Equatable {
    static let theFriendlyReleaseDate: Date? = DateComponents(
        calendar: .current,
        year: 2026,
        month: 6,
        day: 1
    ).date

    let id: String
    let title: String
    let posterName: String
    let runtimeText: String?
    let synopsis: String?
    let previewVideoName: String?
    let bundledVideoName: String?
    let contentType: HKCContentType
    let seasonPriceText: String?
    let episodes: [HKCEpisode]
    let isComingSoon: Bool
    let releaseDate: Date?
    let preOrderPriceText: String?

    var isSeries: Bool {
        contentType == .series
    }

    var isPreOrderAvailable: Bool {
        isComingSoon && !isReleased()
    }

    func isReleased(now: Date = Date()) -> Bool {
        guard isComingSoon else { return true }
        guard let releaseDate else { return false }
        return now >= releaseDate
    }

    static func isReleased(movieID: String, now: Date = Date()) -> Bool {
        true
    }

    init(
        id: String,
        title: String,
        posterName: String,
        runtimeText: String? = nil,
        synopsis: String? = nil,
        previewVideoName: String? = nil,
        bundledVideoName: String? = nil,
        contentType: HKCContentType = .movie,
        seasonPriceText: String? = nil,
        episodes: [HKCEpisode] = [],
        isComingSoon: Bool = false,
        releaseDate: Date? = nil,
        preOrderPriceText: String? = nil
    ) {
        self.id = id
        self.title = title
        self.posterName = posterName
        self.runtimeText = runtimeText
        self.synopsis = synopsis
        self.previewVideoName = previewVideoName
        self.bundledVideoName = bundledVideoName
        self.contentType = contentType
        self.seasonPriceText = seasonPriceText
        self.episodes = episodes
        self.isComingSoon = isComingSoon
        self.releaseDate = releaseDate
        self.preOrderPriceText = preOrderPriceText
    }
}
