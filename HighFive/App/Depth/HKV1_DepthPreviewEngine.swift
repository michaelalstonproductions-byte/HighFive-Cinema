import UIKit
import AVFoundation
import CoreMedia

final class HKV1_DepthPreviewEngine {

    struct Config {
        let playingInterval: CFTimeInterval
        let pausedInterval: CFTimeInterval
        let settleDelay: CFTimeInterval
        let motionThreshold: CGFloat
        let maxPreviewDimension: CGFloat
        let minSecondsDeltaWhilePlaying: Double
        let minSecondsDeltaWhilePaused: Double

        static let `default` = Config(
            playingInterval: 1.0 / 12.0,
            pausedInterval: 1.0 / 18.0,
            settleDelay: 0.08,
            motionThreshold: 2.0,
            maxPreviewDimension: 256.0,
            minSecondsDeltaWhilePlaying: 1.0 / 24.0,
            minSecondsDeltaWhilePaused: 1.0 / 60.0
        )
    }

    struct Output {
        let image: UIImage?
        let labelText: String
    }

    private let config: Config

    private var lastRenderTime: CFTimeInterval = 0
    private var forceNextRender: Bool = true
    private var lastSeconds: Double = -999
    private var cachedImage: UIImage?

    private var hasMotionSample: Bool = false
    private var lastMotionDx: CGFloat = 0
    private var lastMotionDy: CGFloat = 0
    private var lastMotionTime: CFTimeInterval = 0

    init(config: Config = .default) {
        self.config = config
    }

    func reset() {
        lastRenderTime = 0
        forceNextRender = true
        lastSeconds = -999
        cachedImage = nil
        hasMotionSample = false
        lastMotionDx = 0
        lastMotionDy = 0
        lastMotionTime = 0
    }

    func requestImmediateRefresh() {
        forceNextRender = true
    }

    func noteMotion(dx: CGFloat, dy: CGFloat) {
        let now = CACurrentMediaTime()

        if !hasMotionSample {
            hasMotionSample = true
            lastMotionDx = dx
            lastMotionDy = dy
            if hypot(dx, dy) >= 0.001 {
                lastMotionTime = now
            }
            return
        }

        let delta = hypot(dx - lastMotionDx, dy - lastMotionDy)
        lastMotionDx = dx
        lastMotionDy = dy

        if delta >= config.motionThreshold {
            lastMotionTime = now
        }
    }

    func renderOutput(
        currentSeconds: Double,
        now: CFTimeInterval,
        isPlaying: Bool,
        force: Bool,
        depthImageProvider: () -> CGImage?
    ) -> Output? {
        guard currentSeconds.isFinite else {
            return Output(image: nil, labelText: "DEPTH\nNO TIME")
        }

        guard shouldRender(currentSeconds: currentSeconds, now: now, isPlaying: isPlaying, force: force) else {
            return nil
        }

        let depthImage = depthImageProvider()

        let output: Output
        if let depthImage {
            let preview = makePreviewImage(from: depthImage)
            cachedImage = preview
            output = Output(
                image: preview,
                labelText: String(format: "DEPTH\n%.2fs", currentSeconds)
            )
        } else if let cachedImage {
            output = Output(
                image: cachedImage,
                labelText: String(format: "DEPTH\n%.2fs", currentSeconds)
            )
        } else {
            output = Output(image: nil, labelText: "DEPTH\nNO FRAME")
        }

        lastRenderTime = now
        lastSeconds = currentSeconds
        forceNextRender = false
        return output
    }

    private func shouldRender(
        currentSeconds: Double,
        now: CFTimeInterval,
        isPlaying: Bool,
        force: Bool
    ) -> Bool {
        if force || forceNextRender {
            return true
        }

        let motionRecentlyChanged = (now - lastMotionTime) <= config.settleDelay
        let interval = isPlaying ? config.playingInterval : config.pausedInterval

        if !motionRecentlyChanged && (now - lastRenderTime) < interval {
            return false
        }

        let minDelta = isPlaying ? config.minSecondsDeltaWhilePlaying : config.minSecondsDeltaWhilePaused
        if abs(currentSeconds - lastSeconds) < minDelta && !motionRecentlyChanged {
            return false
        }

        return true
    }

    private func makePreviewImage(from cgImage: CGImage) -> UIImage {
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)

        guard width > 0, height > 0 else {
            return UIImage(cgImage: cgImage)
        }

        let maxDimension = max(width, height)
        let scale = maxDimension <= config.maxPreviewDimension ? 1.0 : (config.maxPreviewDimension / maxDimension)

        let targetWidth = max(1, Int((width * scale).rounded(.down)))
        let targetHeight = max(1, Int((height * scale).rounded(.down)))

        let colorSpace = CGColorSpaceCreateDeviceGray()
        guard let context = CGContext(
            data: nil,
            width: targetWidth,
            height: targetHeight,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else {
            return UIImage(cgImage: cgImage)
        }

        context.interpolationQuality = .none
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight))

        guard let scaled = context.makeImage() else {
            return UIImage(cgImage: cgImage)
        }

        return UIImage(cgImage: scaled)
    }
}
