import Foundation
import AVFoundation
import CoreGraphics

final class HKV1_VideoFrameSidecar {

    private var asset: AVAsset?
    private var generator: AVAssetImageGenerator?
    private var loadedURL: URL?

    private var assetDurationSeconds: Double = 0

    private var lastRequestedSeconds: Double = -999
    private var lastImage: CGImage?

    private var warmupBucketSeconds: Double = -999
    private var warmupImage: CGImage?

    private let nominalFrameStep: Double = 1.0 / 30.0
    private let requestReuseWindow: Double = 0.08

    func load(url: URL) {
        loadedURL = url

        let asset = AVAsset(url: url)
        self.asset = asset
        self.assetDurationSeconds = max(0, asset.duration.seconds.isFinite ? asset.duration.seconds : 0)

        let gen = AVAssetImageGenerator(asset: asset)
        gen.appliesPreferredTrackTransform = true
        gen.maximumSize = .zero

        // Playback-friendly tolerance.
        gen.requestedTimeToleranceBefore = CMTime(seconds: 0.12, preferredTimescale: 600)
        gen.requestedTimeToleranceAfter = CMTime(seconds: 0.12, preferredTimescale: 600)

        self.generator = gen

        lastRequestedSeconds = -999
        lastImage = nil
        warmupBucketSeconds = -999
        warmupImage = nil

        seedInitialFrame()
        primeWarmCache()
    }

    func previewImage(videoSeconds: Double) -> CGImage? {
        guard let generator else { return nil }

        let clampedSeconds = clampedVideoSeconds(videoSeconds)

        if abs(clampedSeconds - lastRequestedSeconds) < requestReuseWindow, let lastImage {
            return lastImage
        }

        let bucketedSeconds = floor(clampedSeconds * 30.0) / 30.0
        if abs(bucketedSeconds - warmupBucketSeconds) < 0.0001, let warmupImage {
            lastRequestedSeconds = clampedSeconds
            lastImage = warmupImage
            return warmupImage
        }

        if let image = copyNearestImage(generator: generator, targetSeconds: clampedSeconds) {
            lastRequestedSeconds = clampedSeconds
            lastImage = image
            warmupBucketSeconds = bucketedSeconds
            warmupImage = image
            return image
        }

        return lastImage ?? warmupImage
    }

    func isLoaded() -> Bool {
        loadedURL != nil
    }

    func loadedFileName() -> String? {
        loadedURL?.lastPathComponent
    }

    func resetCache() {
        lastRequestedSeconds = -999
        lastImage = nil
        warmupBucketSeconds = -999
        warmupImage = nil
    }

    private func seedInitialFrame() {
        guard let generator else { return }

        let seedTargets: [Double] = [
            0.0,
            nominalFrameStep,
            nominalFrameStep * 2.0,
            0.10,
            0.20
        ]

        for seconds in seedTargets {
            let clamped = clampedVideoSeconds(seconds)
            if let image = tryCopyImage(generator: generator, atSeconds: clamped) {
                lastRequestedSeconds = clamped
                lastImage = image

                let bucketed = floor(clamped * 30.0) / 30.0
                warmupBucketSeconds = bucketed
                warmupImage = image
                return
            }
        }
    }

    private func primeWarmCache() {
        guard let generator else { return }

        let primeSeconds: [Double] = [
            0.0,
            nominalFrameStep,
            nominalFrameStep * 2.0,
            0.10,
            0.20
        ]

        let primeTimes = primeSeconds.map {
            NSValue(time: CMTime(seconds: clampedVideoSeconds($0), preferredTimescale: 600))
        }

        generator.generateCGImagesAsynchronously(forTimes: primeTimes) { [weak self] _, image, actualTime, _, _ in
            guard let self else { return }
            guard let image else { return }

            let actualSeconds = self.clampedVideoSeconds(max(0, actualTime.seconds))
            let bucketedSeconds = floor(actualSeconds * 30.0) / 30.0

            if self.warmupImage == nil {
                self.warmupBucketSeconds = bucketedSeconds
                self.warmupImage = image
            }

            if self.lastImage == nil {
                self.lastRequestedSeconds = actualSeconds
                self.lastImage = image
            }
        }
    }

    private func copyNearestImage(
        generator: AVAssetImageGenerator,
        targetSeconds: Double
    ) -> CGImage? {
        let probes = probeTimes(around: targetSeconds)

        for seconds in probes {
            if let image = tryCopyImage(generator: generator, atSeconds: seconds) {
                return image
            }
        }

        return nil
    }

    private func probeTimes(around targetSeconds: Double) -> [Double] {
        let offsets: [Double] = [
            0.0,
            -nominalFrameStep,
            nominalFrameStep,
            -2.0 * nominalFrameStep,
            2.0 * nominalFrameStep,
            -0.10,
            0.10,
            -0.20,
            0.20
        ]

        var ordered: [Double] = []
        var seen = Set<Int>()

        for offset in offsets {
            let candidate = clampedVideoSeconds(targetSeconds + offset)
            let key = Int((candidate * 1000.0).rounded())
            if !seen.contains(key) {
                seen.insert(key)
                ordered.append(candidate)
            }
        }

        return ordered
    }

    private func tryCopyImage(
        generator: AVAssetImageGenerator,
        atSeconds seconds: Double
    ) -> CGImage? {
        let t = CMTime(seconds: clampedVideoSeconds(seconds), preferredTimescale: 600)

        do {
            var actual = CMTime.zero
            let image = try generator.copyCGImage(at: t, actualTime: &actual)
            return image
        } catch {
            return nil
        }
    }

    private func clampedVideoSeconds(_ seconds: Double) -> Double {
        let s = max(0, seconds)
        guard assetDurationSeconds.isFinite, assetDurationSeconds > 0 else { return s }
        return min(s, max(0, assetDurationSeconds - 0.001))
    }
}
