import UIKit
import CoreGraphics

final class HKV1_SpeakerDetectionEngine {

    struct SubjectInput {
        let stableID: Int
        let boundingBox: CGRect
    }

    struct SubjectOutput {
        let stableID: Int
        let speakingScore: CGFloat
        let mouthMotion: CGFloat
    }

    private struct SubjectState {
        var previousSampleValue: CGFloat = 0
        var speakingScore: CGFloat = 0
        var lastMouthMotion: CGFloat = 0
        var lastSeenFrame: Int = 0
        var hasHistory: Bool = false
    }

    private var states: [Int: SubjectState] = [:]

    private let speakingRiseAlpha: CGFloat = 0.34
    private let speakingFallAlpha: CGFloat = 0.16
    private let staleFrameCutoff: Int = 18

    func reset() {
        states.removeAll()
    }

    func process(
        frameImage: CGImage,
        subjects: [SubjectInput],
        frameIndex: Int
    ) -> [SubjectOutput] {
        guard !subjects.isEmpty else {
            cleanup(frameIndex: frameIndex)
            return []
        }

        let width = frameImage.width
        let height = frameImage.height

        guard width > 8, height > 8 else {
            cleanup(frameIndex: frameIndex)
            return subjects.map {
                SubjectOutput(stableID: $0.stableID, speakingScore: 0, mouthMotion: 0)
            }
        }

        guard let pixelData = makePixelBuffer(from: frameImage) else {
            cleanup(frameIndex: frameIndex)
            return subjects.map {
                SubjectOutput(stableID: $0.stableID, speakingScore: 0, mouthMotion: 0)
            }
        }

        var outputs: [SubjectOutput] = []

        for subject in subjects {
            var state = states[subject.stableID] ?? SubjectState()

            let mouthRect = mouthRegion(for: subject.boundingBox)
            let mouthSample = averageLuma(
                in: mouthRect,
                pixels: pixelData,
                imageWidth: width,
                imageHeight: height
            )

            let mouthMotion: CGFloat
            if state.hasHistory {
                mouthMotion = min(1.0, abs(mouthSample - state.previousSampleValue) * 4.2)
            } else {
                mouthMotion = 0
            }

            let targetSpeakingScore = clamp(
                (mouthMotion * 0.72) + (state.speakingScore * 0.28),
                min: 0,
                max: 1
            )

            let alpha = targetSpeakingScore >= state.speakingScore ? speakingRiseAlpha : speakingFallAlpha
            state.speakingScore += (targetSpeakingScore - state.speakingScore) * alpha
            state.lastMouthMotion = mouthMotion
            state.previousSampleValue = mouthSample
            state.lastSeenFrame = frameIndex
            state.hasHistory = true

            states[subject.stableID] = state

            outputs.append(
                SubjectOutput(
                    stableID: subject.stableID,
                    speakingScore: clamp(state.speakingScore, min: 0, max: 1),
                    mouthMotion: mouthMotion
                )
            )
        }

        cleanup(frameIndex: frameIndex)
        return outputs
    }

    private func cleanup(frameIndex: Int) {
        states = states.filter { frameIndex - $0.value.lastSeenFrame <= staleFrameCutoff }
    }

    private func mouthRegion(for rect: CGRect) -> CGRect {
        let mouthWidth = rect.width * 0.46
        let mouthHeight = rect.height * 0.18
        let mouthX = rect.midX - (mouthWidth * 0.5)
        let mouthY = rect.minY + (rect.height * 0.18)

        return CGRect(
            x: clamp(mouthX, min: 0, max: 1 - mouthWidth),
            y: clamp(mouthY, min: 0, max: 1 - mouthHeight),
            width: clamp(mouthWidth, min: 0.04, max: 0.40),
            height: clamp(mouthHeight, min: 0.03, max: 0.20)
        )
    }

    private func makePixelBuffer(from image: CGImage) -> [UInt8]? {
        let width = image.width
        let height = image.height
        let bytesPerRow = width * 4
        var pixels = [UInt8](repeating: 0, count: bytesPerRow * height)

        guard let ctx = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }

        ctx.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return pixels
    }

    private func averageLuma(
        in normalizedRect: CGRect,
        pixels: [UInt8],
        imageWidth: Int,
        imageHeight: Int
    ) -> CGFloat {
        let x0 = max(0, min(imageWidth - 1, Int(normalizedRect.minX * CGFloat(imageWidth))))
        let x1 = max(0, min(imageWidth, Int(normalizedRect.maxX * CGFloat(imageWidth))))
        let y0 = max(0, min(imageHeight - 1, Int((1.0 - normalizedRect.maxY) * CGFloat(imageHeight))))
        let y1 = max(0, min(imageHeight, Int((1.0 - normalizedRect.minY) * CGFloat(imageHeight))))

        guard x1 > x0, y1 > y0 else { return 0 }

        let bytesPerRow = imageWidth * 4
        var total: CGFloat = 0
        var count: CGFloat = 0

        for y in y0..<y1 {
            for x in x0..<x1 {
                let idx = (y * bytesPerRow) + (x * 4)
                let r = CGFloat(pixels[idx]) / 255.0
                let g = CGFloat(pixels[idx + 1]) / 255.0
                let b = CGFloat(pixels[idx + 2]) / 255.0
                total += (0.299 * r) + (0.587 * g) + (0.114 * b)
                count += 1
            }
        }

        guard count > 0 else { return 0 }
        return total / count
    }

    private func clamp(_ value: CGFloat, min minValue: CGFloat, max maxValue: CGFloat) -> CGFloat {
        Swift.max(minValue, Swift.min(maxValue, value))
    }
}
