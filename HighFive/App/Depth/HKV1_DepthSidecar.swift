import Foundation
import AVFoundation
import CoreGraphics

final class HKV1_DepthSidecar {

    struct Segment: Decodable {
        let index: Int
        let startSeconds: Double
        let durationSeconds: Double
        let depthURLLastPathComponent: String
    }

    struct Manifest: Decodable {
        let segments: [Segment]
    }

    private struct CacheKey: Hashable {
        let source: Int
        let frameTick: Int
    }

    private final class LRUCache {
        private let capacity: Int
        private var storage: [CacheKey: CGImage] = [:]
        private var order: [CacheKey] = []

        init(capacity: Int) {
            self.capacity = max(4, capacity)
        }

        func value(for key: CacheKey) -> CGImage? {
            guard let value = storage[key] else { return nil }
            touch(key)
            return value
        }

        func insert(_ value: CGImage, for key: CacheKey) {
            storage[key] = value
            touch(key)
            trimIfNeeded()
        }

        func removeAll() {
            storage.removeAll()
            order.removeAll()
        }

        private func touch(_ key: CacheKey) {
            order.removeAll { $0 == key }
            order.append(key)
        }

        private func trimIfNeeded() {
            while order.count > capacity, let oldest = order.first {
                order.removeFirst()
                storage.removeValue(forKey: oldest)
            }
        }
    }

    private var isSegmented = false
    private var manifest: Manifest?

    private var segmentGenerators: [Int: AVAssetImageGenerator] = [:]
    private var segmentAssets: [Int: AVAsset] = [:]
    private var singleGenerator: AVAssetImageGenerator?
    private var loadedURL: URL?

    private let imageCache = LRUCache(capacity: 14)
    private let frameQuantum: Double = 1.0 / 24.0
    private let nearReuseThreshold: Double = 1.0 / 48.0

    private var lastImage: CGImage?
    private var lastTime: Double = -.greatestFiniteMagnitude
    private var lastSourceIndex: Int = -1

    func load(url: URL) {
        releaseAssets()
        loadedURL = url

        if url.pathExtension.lowercased() == "json" {
            loadManifest(url: url)
        } else {
            loadSingle(url: url)
        }
    }

    func previewImage(videoSeconds: Double) -> CGImage? {
        guard videoSeconds.isFinite else { return lastImage }
        return isSegmented ? previewSegmented(videoSeconds: videoSeconds) : previewSingle(videoSeconds: videoSeconds)
    }

    func loadPairedDepthVideo(forVideoURL videoURL: URL) -> Bool {
        let base = videoURL.deletingPathExtension().lastPathComponent
        let directory = videoURL.deletingLastPathComponent()

        let manifestURL = directory.appendingPathComponent("\(base).depthmanifest.json")
        if FileManager.default.fileExists(atPath: manifestURL.path) {
            load(url: manifestURL)
            return true
        }

        let depthURL = directory.appendingPathComponent("\(base).depth.mov")
        if FileManager.default.fileExists(atPath: depthURL.path) {
            load(url: depthURL)
            return true
        }

        return false
    }

    func loadedFileName() -> String? {
        loadedURL?.lastPathComponent
    }

    func resetCache() {
        lastImage = nil
        lastTime = -.greatestFiniteMagnitude
        lastSourceIndex = -1
        imageCache.removeAll()
        releaseAssets()
        loadedURL = nil
        manifest = nil
        isSegmented = false
    }

    private func loadManifest(url: URL) {
        isSegmented = true

        do {
            let data = try Data(contentsOf: url)
            manifest = try JSONDecoder().decode(Manifest.self, from: data)
            guard let manifest else { return }

            let directory = url.deletingLastPathComponent()
            for segment in manifest.segments {
                let segURL = directory.appendingPathComponent(segment.depthURLLastPathComponent)
                let asset = AVAsset(url: segURL)
                let generator = configuredGenerator(for: asset)
                segmentAssets[segment.index] = asset
                segmentGenerators[segment.index] = generator
            }
        } catch {
            manifest = nil
        }
    }

    private func loadSingle(url: URL) {
        isSegmented = false
        let asset = AVAsset(url: url)
        singleGenerator = configuredGenerator(for: asset)
    }

    private func configuredGenerator(for asset: AVAsset) -> AVAssetImageGenerator {
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 960, height: 960)
        generator.requestedTimeToleranceBefore = CMTime(seconds: 1.0 / 48.0, preferredTimescale: 600)
        generator.requestedTimeToleranceAfter = CMTime(seconds: 1.0 / 48.0, preferredTimescale: 600)
        return generator
    }

    private func previewSegmented(videoSeconds: Double) -> CGImage? {
        guard let manifest else { return lastImage }
        guard let segment = manifest.segments.first(where: {
            videoSeconds >= $0.startSeconds && videoSeconds < ($0.startSeconds + $0.durationSeconds)
        }) else {
            return lastImage
        }

        let localTime = max(0.0, videoSeconds - segment.startSeconds)
        let frameTick = quantizedFrameTick(for: localTime)
        let key = CacheKey(source: segment.index, frameTick: frameTick)

        if let cached = imageCache.value(for: key) {
            lastImage = cached
            lastTime = videoSeconds
            lastSourceIndex = segment.index
            preloadNextSegment(after: segment.index)
            return cached
        }

        if segment.index == lastSourceIndex, abs(videoSeconds - lastTime) < nearReuseThreshold {
            preloadNextSegment(after: segment.index)
            return lastImage
        }

        guard let generator = segmentGenerators[segment.index] else { return lastImage }
        let time = CMTime(seconds: Double(frameTick) * frameQuantum, preferredTimescale: 600)

        do {
            let image = try generator.copyCGImage(at: time, actualTime: nil)
            imageCache.insert(image, for: key)
            lastImage = image
            lastTime = videoSeconds
            lastSourceIndex = segment.index
            preloadNextSegment(after: segment.index)
            return image
        } catch {
            return lastImage
        }
    }

    private func previewSingle(videoSeconds: Double) -> CGImage? {
        guard let generator = singleGenerator else { return nil }

        let frameTick = quantizedFrameTick(for: videoSeconds)
        let key = CacheKey(source: 0, frameTick: frameTick)

        if let cached = imageCache.value(for: key) {
            lastImage = cached
            lastTime = videoSeconds
            lastSourceIndex = 0
            return cached
        }

        if lastSourceIndex == 0, abs(videoSeconds - lastTime) < nearReuseThreshold {
            return lastImage
        }

        let time = CMTime(seconds: Double(frameTick) * frameQuantum, preferredTimescale: 600)

        do {
            let image = try generator.copyCGImage(at: time, actualTime: nil)
            imageCache.insert(image, for: key)
            lastImage = image
            lastTime = videoSeconds
            lastSourceIndex = 0
            return image
        } catch {
            return lastImage
        }
    }

    private func preloadNextSegment(after currentIndex: Int) {
        guard let manifest else { return }
        let nextIndex = currentIndex + 1
        guard manifest.segments.contains(where: { $0.index == nextIndex }) else { return }
        _ = segmentGenerators[nextIndex]
    }

    private func quantizedFrameTick(for seconds: Double) -> Int {
        Int((seconds / frameQuantum).rounded())
    }

    private func releaseAssets() {
        singleGenerator?.cancelAllCGImageGeneration()
        for generator in segmentGenerators.values {
            generator.cancelAllCGImageGeneration()
        }
        singleGenerator = nil
        segmentGenerators.removeAll()
        segmentAssets.removeAll()
        lastImage = nil
        lastTime = -.greatestFiniteMagnitude
        lastSourceIndex = -1
        imageCache.removeAll()
    }
}
