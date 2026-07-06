import Foundation

struct HFOfficialStreamsManifest: Decodable {
    let version: String
    let titles: [HFOfficialStreamEntry]
}

struct HFOfficialStreamEntry: Decodable, Identifiable {
    let id: String
    let seriesID: String?
    let title: String
    let type: String
    let episodeNumber: Int?
    let storeKitProductID: String
    let fullStreamURL: String
    let trailerPreviewResource: String?
}

enum HFOfficialStreamResolver {
    static func fullStreamURL(for movieID: String, episodeNumber: Int? = nil) -> URL? {
        guard let manifest = loadManifest() else {
            debugLog("Manifest missing")
            return debugFallbackURL(for: movieID, episodeNumber: episodeNumber)
        }

        let entry = manifest.titles.first { entry in
            if let episodeNumber {
                return entry.seriesID == movieID && entry.episodeNumber == episodeNumber
            }
            return entry.id == movieID
        }

        guard let entry else {
            debugLog("No entry for movieID=\(movieID) episode=\(episodeNumber.map(String.init) ?? "nil")")
            return debugFallbackURL(for: movieID, episodeNumber: episodeNumber)
        }

        guard let url = validatedProductionURL(entry.fullStreamURL) else {
            debugLog("No production URL for \(entry.id)")
            return debugFallbackURL(for: movieID, episodeNumber: episodeNumber)
        }

        debugLog("Resolved production stream \(entry.id): \(url.absoluteString)")
        return url
    }

    private static func loadManifest() -> HFOfficialStreamsManifest? {
        let manifestURL = Bundle.main.url(
            forResource: "HFOfficialStreams",
            withExtension: "json",
            subdirectory: "App/Resources/Streaming"
        )
        ?? Bundle.main.url(
            forResource: "HFOfficialStreams",
            withExtension: "json",
            subdirectory: "Resources/Streaming"
        )
        ?? Bundle.main.url(forResource: "HFOfficialStreams", withExtension: "json")

        guard let manifestURL else {
            return nil
        }

        do {
            let data = try Data(contentsOf: manifestURL)
            return try JSONDecoder().decode(HFOfficialStreamsManifest.self, from: data)
        } catch {
            debugLog("Manifest decode failed: \(error)")
            return nil
        }
    }

    private static func validatedProductionURL(_ rawValue: String) -> URL? {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let url = URL(string: trimmed) else { return nil }
        guard url.scheme?.lowercased() == "https" else { return nil }
        return url
    }

    private static func debugLog(_ message: String) {
        #if DEBUG
        print("[OfficialStreamResolver] \(message)")
        #endif
    }

    private static func debugFallbackURL(for movieID: String, episodeNumber: Int?) -> URL? {
        #if DEBUG
        if let bundledURL = debugBundledFallbackURL(for: movieID, episodeNumber: episodeNumber) {
            return bundledURL
        }

        return debugLocalFallbackURL(for: movieID, episodeNumber: episodeNumber)
        #else
        return nil
        #endif
    }

    #if DEBUG
    private static func debugBundledFallbackURL(for movieID: String, episodeNumber: Int?) -> URL? {
        let baseName: String

        if movieID == "friendly" {
            baseName = "TheFriendly_ref"
        } else if movieID == "paranormall-s1", let episodeNumber {
            baseName = "Paranormall_E\(episodeNumber)_ref"
        } else {
            return nil
        }

        let subdirectories: [String?] = [
            "DebugFullStreams",
            nil
        ]

        for ext in ["mp4", "mov", "m4v"] {
            for subdirectory in subdirectories {
                let url: URL?
                if let subdirectory {
                    url = Bundle.main.url(forResource: baseName, withExtension: ext, subdirectory: subdirectory)
                } else {
                    url = Bundle.main.url(forResource: baseName, withExtension: ext)
                }

                if let url {
                    debugLog("Using DEBUG bundled fallback \(url.lastPathComponent)")
                    return url
                }
            }
        }

        return nil
    }
    #endif

    private static func debugLocalFallbackURL(for movieID: String, episodeNumber: Int?) -> URL? {
        #if DEBUG
        guard let directory = ProcessInfo.processInfo.environment["HF_LOCAL_FULL_STREAM_DIR"],
              !directory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        let fileName: String
        if movieID == "friendly" {
            fileName = "TheFriendly_ref.mp4"
        } else if movieID == "paranormall-s1", let episodeNumber {
            fileName = "Paranormall_E\(episodeNumber)_ref.mp4"
        } else {
            return nil
        }

        let url = URL(fileURLWithPath: directory, isDirectory: true).appendingPathComponent(fileName)
        guard FileManager.default.fileExists(atPath: url.path) else {
            debugLog("DEBUG fallback missing file \(url.path)")
            return nil
        }

        debugLog("Using DEBUG local fallback \(url.path)")
        return url
        #else
        return nil
        #endif
    }
}
