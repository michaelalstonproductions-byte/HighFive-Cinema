import Foundation
import AVFoundation

final class HKV1_PlaybackController {

    let player = AVPlayer()
    private(set) var currentURL: URL?

    private let defaultSeekTolerance = CMTime(seconds: 1.0 / 30.0, preferredTimescale: 600)

    var currentSeconds: Double {
        let s = player.currentTime().seconds
        return s.isFinite ? s : 0.0
    }

    var durationSeconds: Double {
        guard let d = player.currentItem?.duration.seconds, d.isFinite else {
            return 0.0
        }
        return d
    }

    var volume: Float {
        get { player.volume }
        set { player.volume = max(0, min(1, newValue)) }
    }

    var isMuted: Bool {
        get { player.isMuted }
        set { player.isMuted = newValue }
    }

    func load(url: URL) {
        currentURL = url

        let item = AVPlayerItem(url: url)
        item.preferredForwardBufferDuration = 5.0
        item.canUseNetworkResourcesForLiveStreamingWhilePaused = false

        player.automaticallyWaitsToMinimizeStalling = false
        player.actionAtItemEnd = .pause
        player.replaceCurrentItem(with: item)

        player.seek(
            to: .zero,
            toleranceBefore: defaultSeekTolerance,
            toleranceAfter: defaultSeekTolerance
        )
    }

    func play() {
        player.playImmediately(atRate: 1.0)
    }

    func pause() {
        player.pause()
    }

    func togglePlayPause() {
        if isPlaying() {
            pause()
        } else {
            play()
        }
    }

    func isPlaying() -> Bool {
        if #available(iOS 10.0, *) {
            return player.timeControlStatus == .playing || player.rate != 0
        } else {
            return player.rate != 0
        }
    }

    func seek(
        to seconds: Double,
        tolerance: CMTime? = nil,
        completion: ((Bool) -> Void)? = nil
    ) {
        let clamped: Double
        let dur = durationSeconds

        if dur > 0 {
            clamped = max(0.0, min(dur, seconds))
        } else {
            clamped = max(0.0, seconds)
        }

        let t = CMTime(seconds: clamped, preferredTimescale: 600)
        let seekTolerance = tolerance ?? defaultSeekTolerance

        player.seek(
            to: t,
            toleranceBefore: seekTolerance,
            toleranceAfter: seekTolerance
        ) { finished in
            completion?(finished)
        }
    }

    func preciseSeek(
        to seconds: Double,
        completion: ((Bool) -> Void)? = nil
    ) {
        let clamped: Double
        let dur = durationSeconds

        if dur > 0 {
            clamped = max(0.0, min(dur, seconds))
        } else {
            clamped = max(0.0, seconds)
        }

        let t = CMTime(seconds: clamped, preferredTimescale: 600)

        player.seek(
            to: t,
            toleranceBefore: .zero,
            toleranceAfter: .zero
        ) { finished in
            completion?(finished)
        }
    }

    func seekBy(_ delta: Double, completion: ((Bool) -> Void)? = nil) {
        seek(to: currentSeconds + delta, completion: completion)
    }

    func seekToStartAndPlay() {
        seek(to: 0.0) { [weak self] _ in
            self?.play()
        }
    }
}
