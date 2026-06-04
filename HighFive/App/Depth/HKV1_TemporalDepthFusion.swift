import UIKit
import CoreImage

final class HKV1_TemporalDepthFusion {

    private let ciContext = CIContext(options: [
        .cacheIntermediates: false,
        .useSoftwareRenderer: false
    ])

    private var lastDepth: CIImage?
    private var lastConfidence: CGFloat = 1.0
    private var velocity: CGFloat = 0.0
    private var weakFrameStreak: Int = 0

    private let maxWeakFrameStreak = 8

    func fuse(current: CIImage) -> CIImage {
        let currentPrepared = prepareDepth(current)
        let currentConfidence = estimateConfidence(for: currentPrepared)

        guard let lastDepth else {
            self.lastDepth = currentPrepared
            self.lastConfidence = currentConfidence
            return currentPrepared
        }

        let motionFactor = clamp(velocity, min: 0.0, max: 1.0)
        let confidenceDelta = abs(currentConfidence - lastConfidence)
        let confidenceFloor = min(currentConfidence, lastConfidence)

        let weakFrame = currentConfidence < 0.26
        weakFrameStreak = weakFrame ? min(maxWeakFrameStreak, weakFrameStreak + 1) : max(0, weakFrameStreak - 1)
        let weakFramePenalty = CGFloat(weakFrameStreak) / CGFloat(maxWeakFrameStreak)

        var alpha: CGFloat = 0.58
        alpha -= motionFactor * 0.22
        alpha -= confidenceDelta * 0.18
        alpha -= (1.0 - confidenceFloor) * 0.18
        alpha -= weakFramePenalty * 0.10
        alpha = clamp(alpha, min: 0.10, max: 0.68)

        let fused = blend(current: currentPrepared, previous: lastDepth, alpha: alpha)
        let stabilized = stabilizeIfNeeded(fused, previous: lastDepth, confidence: currentConfidence)

        self.lastDepth = stabilized
        self.lastConfidence = currentConfidence
        return stabilized
    }

    func setMotion(dx: CGFloat, dy: CGFloat) {
        velocity = min(1.0, hypot(dx, dy) / 20.0)
    }

    func reset() {
        lastDepth = nil
        lastConfidence = 1.0
        velocity = 0.0
        weakFrameStreak = 0
    }

    private func prepareDepth(_ image: CIImage) -> CIImage {
        let extent = image.extent.integral
        return image
            .clampedToExtent()
            .applyingFilter("CIColorControls", parameters: [
                kCIInputSaturationKey: 0.0,
                kCIInputContrastKey: 1.18,
                kCIInputBrightnessKey: 0.0
            ])
            .applyingFilter("CIGaussianBlur", parameters: [
                kCIInputRadiusKey: 0.55
            ])
            .cropped(to: extent)
    }

    private func blend(current: CIImage, previous: CIImage, alpha: CGFloat) -> CIImage {
        let extent = current.extent.integral

        let currentWeighted = current.applyingFilter("CIColorMatrix", parameters: [
            "inputRVector": CIVector(x: alpha, y: 0, z: 0, w: 0),
            "inputGVector": CIVector(x: 0, y: alpha, z: 0, w: 0),
            "inputBVector": CIVector(x: 0, y: 0, z: alpha, w: 0),
            "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1)
        ])

        let previousWeighted = previous.applyingFilter("CIColorMatrix", parameters: [
            "inputRVector": CIVector(x: 1.0 - alpha, y: 0, z: 0, w: 0),
            "inputGVector": CIVector(x: 0, y: 1.0 - alpha, z: 0, w: 0),
            "inputBVector": CIVector(x: 0, y: 0, z: 1.0 - alpha, w: 0),
            "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1)
        ])

        return currentWeighted
            .applyingFilter("CIAdditionCompositing", parameters: [
                kCIInputBackgroundImageKey: previousWeighted
            ])
            .cropped(to: extent)
            .applyingFilter("CIColorClamp", parameters: [
                "inputMinComponents": CIVector(x: 0, y: 0, z: 0, w: 0),
                "inputMaxComponents": CIVector(x: 1, y: 1, z: 1, w: 1)
            ])
            .cropped(to: extent)
    }

    private func stabilizeIfNeeded(_ current: CIImage, previous: CIImage, confidence: CGFloat) -> CIImage {
        let extent = current.extent.integral

        guard confidence < 0.34 || velocity < 0.08 else {
            return current
        }

        let hold = clamp((0.38 - confidence) * 1.8, min: 0.0, max: 0.28)
        guard hold > 0.001 else { return current }

        let previousWeighted = previous.applyingFilter("CIColorMatrix", parameters: [
            "inputRVector": CIVector(x: hold, y: 0, z: 0, w: 0),
            "inputGVector": CIVector(x: 0, y: hold, z: 0, w: 0),
            "inputBVector": CIVector(x: 0, y: 0, z: hold, w: 0),
            "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1)
        ])

        return current
            .applyingFilter("CIAdditionCompositing", parameters: [
                kCIInputBackgroundImageKey: previousWeighted
            ])
            .cropped(to: extent)
            .applyingFilter("CIColorClamp", parameters: [
                "inputMinComponents": CIVector(x: 0, y: 0, z: 0, w: 0),
                "inputMaxComponents": CIVector(x: 1, y: 1, z: 1, w: 1)
            ])
            .cropped(to: extent)
    }

    private func estimateConfidence(for image: CIImage) -> CGFloat {
        let extent = image.extent.integral
        let target = CGRect(origin: .zero, size: CGSize(width: 28, height: 28))

        let scaleX = target.width / max(extent.width, 1.0)
        let scaleY = target.height / max(extent.height, 1.0)

        let reduced = image
            .transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
            .cropped(to: target)

        guard let cg = ciContext.createCGImage(reduced, from: target),
              let data = cg.dataProvider?.data,
              let ptr = CFDataGetBytePtr(data)
        else {
            return 0.5
        }

        let width = cg.width
        let height = cg.height
        let bytesPerRow = cg.bytesPerRow
        let bytesPerPixel = max(1, cg.bitsPerPixel / 8)

        var total: CGFloat = 0
        var count: CGFloat = 0
        var minV: CGFloat = 1.0
        var maxV: CGFloat = 0.0

        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * bytesPerRow) + (x * bytesPerPixel)
                let value = CGFloat(ptr[offset]) / 255.0
                total += value
                count += 1.0
                minV = min(minV, value)
                maxV = max(maxV, value)
            }
        }

        guard count > 0 else { return 0.5 }

        let average = total / count
        let contrast = maxV - minV
        let spreadScore = clamp(contrast / 0.40, min: 0.0, max: 1.0)
        let midPresence = 1.0 - abs(average - 0.52) / 0.52
        let confidence = (spreadScore * 0.76) + (midPresence * 0.24)
        return clamp(confidence, min: 0.0, max: 1.0)
    }

    private func clamp(_ value: CGFloat, min minValue: CGFloat, max maxValue: CGFloat) -> CGFloat {
        Swift.max(minValue, Swift.min(maxValue, value))
    }
}
