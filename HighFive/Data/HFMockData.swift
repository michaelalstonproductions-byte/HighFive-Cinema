import Foundation

enum HFMockData {
    static let movies: [Movie] = [
        Movie(
            id: "friendly",
            title: "The Friendly",
            subtitle: "Loyalty. Love. Revenge.",
            synopsis: "In a city that never forgets, one man learns the cost of choosing peace while old wounds return to collect.",
            year: "2026",
            rating: "TV-MA",
            duration: "1h 48m",
            genres: ["Crime", "Drama", "Original"],
            posterAssetName: "the_friendly",
            backdropAssetName: "the_friendly",
            creatorName: "HigherKey Inc.",
            isOriginal: true,
            isComingSoon: false,
            isDownloaded: true,
            progress: 0.42
        ),
        Movie(
            id: "paranormall-s1",
            title: "Paranormall Season 1",
            subtitle: "Episodes 1-7",
            synopsis: "A grounded paranormal investigation series follows the people who step into the places everyone else avoids.",
            year: "2026",
            rating: "TV-14",
            duration: "7 episodes",
            genres: ["Horror", "Mystery", "Series"],
            posterAssetName: "paranormall",
            backdropAssetName: "paranormall",
            creatorName: "HighFive Cinema",
            isOriginal: true,
            isComingSoon: false,
            isDownloaded: false,
            progress: 0.28
        ),
        Movie(id: "big-loss", title: "Big Loss", subtitle: "Coming soon", synopsis: "A hard reset turns into a story about consequence, family, and rebuilding under pressure.", year: "2026", rating: "TV-MA", duration: "Feature", genres: ["Drama"], posterAssetName: "poster_big_loss_coming_soon", backdropAssetName: "poster_big_loss_coming_soon", creatorName: "HighFive Cinema", isOriginal: true, isComingSoon: true, isDownloaded: false, progress: 0.18),
        Movie(id: "artist-development", title: "Artist Development", subtitle: "A documentary film", synopsis: "A documentary about discipline, legacy, and the pressure behind the art.", year: "2026", rating: "TV-14", duration: "1h 22m", genres: ["Documentary", "Music"], posterAssetName: "poster_artist_development_coming_soon", backdropAssetName: "poster_artist_development_coming_soon", creatorName: "HigherKey Studios", isOriginal: true, isComingSoon: true, isDownloaded: false, progress: nil),
        Movie(id: "maple-street", title: "Maple Street", subtitle: "Some secrets are buried in plain sight.", synopsis: "A quiet street hides a case that never stopped waiting for answers.", year: "2026", rating: "TV-14", duration: "Limited Series", genres: ["Mystery", "Drama"], posterAssetName: "poster_maple_street_coming_soon", backdropAssetName: "poster_maple_street_coming_soon", creatorName: "In The Light Productions", isOriginal: true, isComingSoon: true, isDownloaded: false, progress: nil),
        Movie(id: "sunshine", title: "Sunshine", subtitle: "Sun Valley, 1989", synopsis: "Old money, new love, and a winter escape that changes everyone involved.", year: "2026", rating: "TV-PG", duration: "Feature", genres: ["Romance", "Drama"], posterAssetName: "poster_sunshine_coming_soon", backdropAssetName: "poster_sunshine_coming_soon", creatorName: "HigherKey Inc.", isOriginal: true, isComingSoon: true, isDownloaded: false, progress: nil),
        Movie(id: "old-satan", title: "Old Satan", subtitle: "The devil never left town.", synopsis: "A preacher returns to a town where faith, fear, and power are impossible to separate.", year: "2026", rating: "TV-MA", duration: "Original Series", genres: ["Thriller", "Drama"], posterAssetName: "poster_old_satan_coming_soon", backdropAssetName: "poster_old_satan_coming_soon", creatorName: "In The Light Productions", isOriginal: true, isComingSoon: true, isDownloaded: false, progress: nil),
        Movie(id: "arrival-time", title: "Arrival Time", subtitle: "You can leave home. You can't leave time.", synopsis: "A traveler faces the choice he has been running from since the day he left.", year: "2026", rating: "TV-14", duration: "Original Series", genres: ["Drama", "Mystery"], posterAssetName: "poster_arrival_time_coming_soon", backdropAssetName: "poster_arrival_time_coming_soon", creatorName: "HigherKey Inc.", isOriginal: true, isComingSoon: true, isDownloaded: false, progress: nil),
        Movie(id: "black-turnip", title: "Black Turnip", subtitle: "Legacy isn't given. It's remembered.", synopsis: "A six-part limited series about power, memory, and the people who refuse to be erased.", year: "2026", rating: "TV-MA", duration: "6 episodes", genres: ["Drama", "Limited Series"], posterAssetName: "poster_black_turnip_coming_soon", backdropAssetName: "poster_black_turnip_coming_soon", creatorName: "HighFive Cinema", isOriginal: true, isComingSoon: true, isDownloaded: false, progress: nil),
        Movie(id: "bleu-velvet", title: "Bleu Velvet", subtitle: "Lust. Lies. Loyalty.", synopsis: "A private lounge becomes the center of a choice between business and truth.", year: "2026", rating: "TV-MA", duration: "Feature", genres: ["Crime", "Drama"], posterAssetName: "poster_blue_velvet_coming_soon", backdropAssetName: "poster_blue_velvet_coming_soon", creatorName: "HighFive Cinema", isOriginal: true, isComingSoon: true, isDownloaded: false, progress: nil),
        Movie(id: "lost-ones", title: "Lost Ones", subtitle: "Some borders separate more than countries.", synopsis: "A mother searches across systems built to keep the missing invisible.", year: "2026", rating: "TV-14", duration: "Feature", genres: ["Drama", "Thriller"], posterAssetName: "poster_lost_ones_coming_soon", backdropAssetName: "poster_lost_ones_coming_soon", creatorName: "HighFive Cinema", isOriginal: true, isComingSoon: true, isDownloaded: false, progress: nil),
        Movie(id: "breaking-chain", title: "Breaking the Chain", subtitle: "Every secret has a price.", synopsis: "A remote county, a hidden ledger, and a debt that refuses to stay buried.", year: "2026", rating: "TV-MA", duration: "Feature", genres: ["Western", "Thriller"], posterAssetName: "poster_breaking_the_chain_coming_soon", backdropAssetName: "poster_breaking_the_chain_coming_soon", creatorName: "In The Light Productions", isOriginal: true, isComingSoon: true, isDownloaded: false, progress: nil),
        Movie(id: "blackmailed", title: "Blackmailed", subtitle: "Every secret can be used against you.", synopsis: "Power has a price, and secrets have a cost.", year: "2026", rating: "TV-MA", duration: "Feature", genres: ["Crime", "Drama"], posterAssetName: "poster_blackmailed_coming_soon", backdropAssetName: "poster_blackmailed_coming_soon", creatorName: "HighFive Cinema", isOriginal: true, isComingSoon: true, isDownloaded: false, progress: nil),
        Movie(id: "halfway-there", title: "Half Way There", subtitle: "One day at a time.", synopsis: "A public accountant loses everything and learns what forward really means.", year: "2026", rating: "TV-14", duration: "Feature", genres: ["Drama"], posterAssetName: "poster_halfway_there_coming_soon", backdropAssetName: "poster_halfway_there_coming_soon", creatorName: "HighFive Cinema", isOriginal: true, isComingSoon: true, isDownloaded: false, progress: nil),
        Movie(id: "toxic", title: "Toxic", subtitle: "Obsession. Art. Love. Destruction.", synopsis: "A painter and muse cross the line between devotion and damage.", year: "2026", rating: "TV-MA", duration: "Feature", genres: ["Thriller", "Drama"], posterAssetName: "poster_toxic_package_background", backdropAssetName: "poster_toxic_package_background", creatorName: "In The Light Productions", isOriginal: true, isComingSoon: true, isDownloaded: false, progress: nil),
        Movie(id: "behind-vision", title: "Behind the Vision", subtitle: "HighFive original short", synopsis: "A short-form look at the creative decisions shaping the HighFive Cinema slate.", year: "2026", rating: "TV-PG", duration: "18m", genres: ["Documentary"], posterAssetName: "poster_artist_development_coming_soon", backdropAssetName: "poster_artist_development_coming_soon", creatorName: "HighFive Cinema", isOriginal: true, isComingSoon: false, isDownloaded: true, progress: 0.64),
        Movie(id: "night-file", title: "The Night File", subtitle: "Local case archive", synopsis: "A compact thriller built around a recovered drive and a missing witness.", year: "2026", rating: "TV-14", duration: "42m", genres: ["Thriller"], posterAssetName: nil, backdropAssetName: nil, creatorName: "HighFive Cinema", isOriginal: false, isComingSoon: false, isDownloaded: false, progress: nil)
    ]

    static let creators: [Creator] = [
        Creator(id: "higherkey", name: "HigherKey Inc.", role: "Studio", avatarAssetName: nil, featuredMovieIDs: ["friendly", "arrival-time", "sunshine"]),
        Creator(id: "highfive", name: "HighFive Cinema", role: "Originals", avatarAssetName: nil, featuredMovieIDs: ["paranormall-s1", "black-turnip", "bleu-velvet"]),
        Creator(id: "in-light", name: "In The Light Productions", role: "Production Partner", avatarAssetName: nil, featuredMovieIDs: ["old-satan", "breaking-chain", "toxic"])
    ]

    static let userProfiles: [UserProfile] = [
        UserProfile(id: "profile-kumbali", name: "Kumbali", avatarSystemName: "person.crop.circle.fill", accentName: "Gold", isKidsProfile: false),
        UserProfile(id: "profile-studio", name: "Studio", avatarSystemName: "video.circle.fill", accentName: "Cyan", isKidsProfile: false),
        UserProfile(id: "profile-family", name: "Family", avatarSystemName: "person.2.circle.fill", accentName: "Orange", isKidsProfile: false),
        UserProfile(id: "profile-kids", name: "Kids", avatarSystemName: "star.circle.fill", accentName: "Gold", isKidsProfile: true)
    ]

    static let searchSuggestions: [SearchResult] = [
        SearchResult(id: "suggest-friendly", title: "The Friendly", subtitle: "Feature film", movie: movie("friendly")),
        SearchResult(id: "suggest-paranormall", title: "Paranormall", subtitle: "Series", movie: movie("paranormall-s1")),
        SearchResult(id: "suggest-coming-soon", title: "Coming Soon", subtitle: "Upcoming HighFive originals", movie: nil),
        SearchResult(id: "suggest-crime", title: "Crime Drama", subtitle: "Dark cinematic stories", movie: nil),
        SearchResult(id: "suggest-documentary", title: "Documentaries", subtitle: "Creator and music stories", movie: nil),
        SearchResult(id: "suggest-downloaded", title: "Downloaded", subtitle: "Available offline", movie: nil),
        SearchResult(id: "suggest-originals", title: "HighFive Originals", subtitle: "Studio slate", movie: nil),
        SearchResult(id: "suggest-thrillers", title: "Thrillers", subtitle: "Suspense and mystery", movie: nil)
    ]

    static var categories: [Category] {
        [
            newThisWeek,
            continueWatching,
            recommended,
            onlyOnHighFive,
            Category(id: "continue", title: "Continue Watching", subtitle: nil, movies: movies.filter { $0.progress != nil }),
            Category(id: "originals", title: "HighFive Originals", subtitle: "Premium original films and series", movies: movies.filter { $0.isOriginal && !$0.isComingSoon }),
            Category(id: "trending", title: "Trending Now", subtitle: nil, movies: ["friendly", "paranormall-s1", "black-turnip", "big-loss", "artist-development", "bleu-velvet"].compactMap(movie)),
            Category(id: "coming-soon", title: "Coming Soon", subtitle: "Scripted originals in development", movies: movies.filter { $0.isComingSoon }),
            Category(id: "my-movies", title: "My Movies", subtitle: "Saved and local titles", movies: movies.filter { $0.isDownloaded || $0.progress != nil }),
            Category(id: "fresh-finds", title: "Fresh Finds", subtitle: "New from the HighFive slate", movies: movies.suffix(10).map { $0 })
        ]
    }

    static var premiumHomeRails: [Category] {
        [
            newThisWeek,
            continueWatching,
            recommended,
            onlyOnHighFive
        ]
    }

    static var newThisWeek: Category {
        Category(
            id: "new-this-week",
            title: "New This Week",
            subtitle: "Fresh HighFive picks",
            movies: ["friendly", "paranormall-s1", "behind-vision", "artist-development", "big-loss"].compactMap(movie)
        )
    }

    static var continueWatching: Category {
        Category(
            id: "continue-watching",
            title: "Continue Watching",
            subtitle: "Pick up where you left off",
            movies: movies.filter { $0.progress != nil }
        )
    }

    static var recommended: Category {
        Category(
            id: "recommended",
            title: "Recommended",
            subtitle: "Selected from your local viewing profile",
            movies: ["black-turnip", "sunshine", "arrival-time", "maple-street", "night-file"].compactMap(movie)
        )
    }

    static var onlyOnHighFive: Category {
        Category(
            id: "only-on-highfive",
            title: "Only On HighFive",
            subtitle: "Originals and local showcase titles",
            movies: movies.filter(\.isOriginal)
        )
    }

    static var discoveryGenres: [String] {
        ["All", "Originals", "Creator Published", "Award Winners", "Premieres", "Horror", "Documentary", "Western", "Crime", "Drama", "Thriller", "Mystery", "Coming Soon"]
    }

    static func creator(for movie: Movie) -> Creator {
        creators.first { $0.name == movie.creatorName }
            ?? Creator(
                id: movie.creatorName.lowercased().replacingOccurrences(of: " ", with: "-"),
                name: movie.creatorName,
                role: movie.isOriginal ? "HighFive Original Partner" : "Creator",
                avatarAssetName: nil,
                featuredMovieIDs: [movie.id]
            )
    }

    static func cast(for movie: Movie) -> [String] {
        switch movie.id {
        case "friendly":
            return ["Kumbali Satori", "Mara Voss", "Darius King", "Elena Cross"]
        case "paranormall-s1":
            return ["Jalen Brooks", "Mina Hart", "Rafael Stone", "Avery Cole"]
        case "artist-development":
            return ["Kumbali Satori", "The Studio Team", "HigherKey Artists"]
        default:
            return ["Kumbali Satori", "HighFive Ensemble", "Studio Players"]
        }
    }

    static func galleryAssets(for movie: Movie) -> [String] {
        let assets = [
            movie.backdropAssetName,
            movie.posterAssetName
        ]
        var seen = Set<String>()
        return assets.compactMap { $0 }.filter { seen.insert($0).inserted }
    }

    static func relatedTitles(for movie: Movie) -> [Movie] {
        let genreMatches = movies.filter { candidate in
            candidate.id != movie.id &&
            !Set(candidate.genres).isDisjoint(with: Set(movie.genres))
        }
        let creatorMatches = movies.filter { $0.id != movie.id && $0.creatorName == movie.creatorName }
        let merged = genreMatches + creatorMatches + recommended.movies
        var seen = Set<String>()
        return merged.filter { seen.insert($0.id).inserted }.prefix(8).map { $0 }
    }

    static func movie(_ id: String) -> Movie? {
        movies.first { $0.id == id }
    }
}
