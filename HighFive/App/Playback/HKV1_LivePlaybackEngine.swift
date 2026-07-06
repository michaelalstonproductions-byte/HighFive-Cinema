import Foundation
import AVFoundation
import CoreMedia
import CoreVideo
import QuartzCore

final class HKV1_LivePlaybackEngine {

    struct Frame {
        let pixelBuffer: CVPixelBuffer
        let itemTime: CMTime
        let seconds: Double
    }

    private weak var player: AVPlayer?
    private var videoOutput: AVPlayerItemVideoOutput?
    private weak var attachedItem: AVPlayerItem?

    private var lastPixelBuffer: CVPixelBuffer?
    private var lastTime: CMTime = .zero

    // MARK: - Public

    func attach(to player: AVPlayer) {
        self.player = player
        rebuildOutputIfNeeded()
    }

    func detach() {
        if let item = attachedItem, let output = videoOutput {
            item.remove(output)
        }

        attachedItem = nil
        videoOutput = nil
        player = nil

        lastPixelBuffer = nil
        lastTime = .zero
    }

    func refreshAttachmentIfNeeded() {
        rebuildOutputIfNeeded()
    }

    func currentFrame() -> Frame? {
        guard let player,
              let output = videoOutput else {
            return nil
        }

        let hostTime = CACurrentMediaTime()
        let itemTime = output.itemTime(forHostTime: hostTime)

        if output.hasNewPixelBuffer(forItemTime: itemTime) {
            var displayTime = CMTime.zero

            if let pixelBuffer = output.copyPixelBuffer(
                forItemTime: itemTime,
                itemTimeForDisplay: &displayTime
            ) {
                lastPixelBuffer = pixelBuffer
                lastTime = displayTime

                let seconds = safeSeconds(from: displayTime, fallback: itemTime)
                return Frame(
                    pixelBuffer: pixelBuffer,
                    itemTime: displayTime,
                    seconds: seconds
                )
            }
        }

        // fallback: reuse last frame (critical for smooth playback)
        if let lastPixelBuffer {
            let seconds = safeSeconds(from: lastTime, fallback: player.currentTime())
            return Frame(
                pixelBuffer: lastPixelBuffer,
                itemTime: lastTime,
                seconds: seconds
            )
        }

        return fallbackFrame(at: player.currentTime())
    }

    func currentTimeSeconds() -> Double {
        guard let player else { return 0 }
        return safeSeconds(from: player.currentTime(), fallback: .zero)
    }

    // MARK: - Internal

    private func rebuildOutputIfNeeded() {
        guard let player,
              let item = player.currentItem else {
            return
        }

        if attachedItem === item, videoOutput != nil {
            return
        }

        if let oldItem = attachedItem,
           let oldOutput = videoOutput {
            oldItem.remove(oldOutput)
        }

        let attrs: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA),
            kCVPixelBufferMetalCompatibilityKey as String: true
        ]

        let output = AVPlayerItemVideoOutput(pixelBufferAttributes: attrs)
        output.suppressesPlayerRendering = false

        item.add(output)

        attachedItem = item
        videoOutput = output

        lastPixelBuffer = nil
        lastTime = .zero
    }

    private func fallbackFrame(at time: CMTime) -> Frame? {
        guard let output = videoOutput else { return nil }

        var displayTime = CMTime.zero
        guard let pixelBuffer = output.copyPixelBuffer(
            forItemTime: time,
            itemTimeForDisplay: &displayTime
        ) else {
            return nil
        }

        let seconds = safeSeconds(from: displayTime, fallback: time)

        lastPixelBuffer = pixelBuffer
        lastTime = displayTime

        return Frame(
            pixelBuffer: pixelBuffer,
            itemTime: displayTime,
            seconds: seconds
        )
    }

    private func safeSeconds(from time: CMTime, fallback: CMTime) -> Double {
        if time.seconds.isFinite {
            return time.seconds
        }
        if fallback.seconds.isFinite {
            return fallback.seconds
        }
        return 0
    }
}
