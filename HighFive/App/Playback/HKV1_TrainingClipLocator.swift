import Foundation

struct HKV1_TrainingClipPair {
    let videoURL: URL
    let depthURL: URL?
}

enum HKV1_TrainingClipLocator {

    static let videoBaseName = "HKTrainingClip_latest"
    static let videoExtension = "mp4"
    static let depthCandidates: [(String, String)] = [
        ("HKTrainingClip_latest.depth", "mp4"),
        ("HKTrainingClip_latest.depth", "mov"),
        ("HKTrainingClip_latest_depth", "mp4"),
        ("HKTrainingClip_latest_depth", "mov")
    ]

    static func resolvePreferredTrainingClipPair() -> HKV1_TrainingClipPair? {
        if let pair = resolveFromDocuments() {
            print("✅ Training clip pair resolved from Documents:")
            print("   video: \(pair.videoURL.path)")
            if let depth = pair.depthURL {
                print("   depth: \(depth.path)")
            } else {
                print("   depth: none")
            }
            return pair
        }

        if let pair = resolveFromBundle() {
            print("✅ Training clip pair resolved from Bundle:")
            print("   video: \(pair.videoURL.path)")
            if let depth = pair.depthURL {
                print("   depth: \(depth.path)")
            } else {
                print("   depth: none")
            }
            return pair
        }

        print("❌ No preferred training clip pair found for \(videoBaseName).\(videoExtension)")
        return nil
    }

    static func documentsDirectory() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    static func resolveFromDocuments() -> HKV1_TrainingClipPair? {
        guard let docs = documentsDirectory() else { return nil }

        let videoURL = docs.appendingPathComponent("\(videoBaseName).\(videoExtension)")
        guard FileManager.default.fileExists(atPath: videoURL.path) else {
            return nil
        }

        let depthURL = firstExistingDepthURL(in: docs)
        return HKV1_TrainingClipPair(videoURL: videoURL, depthURL: depthURL)
    }

    static func resolveFromBundle() -> HKV1_TrainingClipPair? {
        guard let videoURL = Bundle.main.url(forResource: videoBaseName, withExtension: videoExtension) else {
            return nil
        }

        let depthURL = firstExistingDepthURLInBundle()
        return HKV1_TrainingClipPair(videoURL: videoURL, depthURL: depthURL)
    }

    private static func firstExistingDepthURL(in directory: URL) -> URL? {
        for (name, ext) in depthCandidates {
            let url = directory.appendingPathComponent("\(name).\(ext)")
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
        }
        return nil
    }

    private static func firstExistingDepthURLInBundle() -> URL? {
        for (name, ext) in depthCandidates {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                return url
            }
        }
        return nil
    }
}

