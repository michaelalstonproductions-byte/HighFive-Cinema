//
//  HKV1_PlayerAudioTap.swift
//  HigherKeySpatialPeek_Rebuild
//

import Foundation
import AVFoundation
import CoreMedia
import AudioToolbox

final class HKV1_PlayerAudioTap {

    fileprivate final class TapContext {
        weak var audioEngine: HKV1_AudioSpeakerDetectionEngine?
        weak var player: AVPlayer?

        init(audioEngine: HKV1_AudioSpeakerDetectionEngine?, player: AVPlayer?) {
            self.audioEngine = audioEngine
            self.player = player
        }
    }

    fileprivate weak var audioEngine: HKV1_AudioSpeakerDetectionEngine?
    fileprivate weak var player: AVPlayer?

    init(audioEngine: HKV1_AudioSpeakerDetectionEngine, player: AVPlayer?) {
        self.audioEngine = audioEngine
        self.player = player
    }

    func attach(to player: AVPlayer) {
        self.player = player
        installTap(on: player.currentItem)
    }

    func refreshAttachmentIfNeeded() {
        installTap(on: player?.currentItem)
    }

    func detach() {
        player?.currentItem?.audioMix = nil
    }

    private func installTap(on item: AVPlayerItem?) {
        guard let item else { return }

        guard let track = item.asset.tracks(withMediaType: .audio).first else {
            return
        }

        let params = AVMutableAudioMixInputParameters(track: track)
        let context = TapContext(audioEngine: audioEngine, player: player)

        let tapInit: MTAudioProcessingTapInitCallback = { _, clientInfo, tapStorageOut in
            tapStorageOut.pointee = clientInfo
        }

        let tapFinalize: MTAudioProcessingTapFinalizeCallback = { tap in
            let storage = MTAudioProcessingTapGetStorage(tap)
            Unmanaged<TapContext>.fromOpaque(storage).release()
        }

        let tapPrepare: MTAudioProcessingTapPrepareCallback = { _, _, _ in
        }

        let tapUnprepare: MTAudioProcessingTapUnprepareCallback = { _ in
        }

        let tapProcess: MTAudioProcessingTapProcessCallback = {
            tap,
            numberFrames,
            flags,
            bufferListInOut,
            numberFramesOut,
            flagsOut in

            let status = MTAudioProcessingTapGetSourceAudio(
                tap,
                numberFrames,
                bufferListInOut,
                flagsOut,
                nil,
                numberFramesOut
            )

            guard status == noErr else { return }

            let storage = MTAudioProcessingTapGetStorage(tap)
            let context = Unmanaged<TapContext>.fromOpaque(storage).takeUnretainedValue()
            guard let engine = context.audioEngine else { return }

            let buffers = UnsafeMutableAudioBufferListPointer(bufferListInOut)

            var totalSquares: Double = 0
            var totalSamples: Int = 0
            var peak: Double = 0

            for buffer in buffers {
                guard let mData = buffer.mData else { continue }

                let sampleCount = Int(buffer.mDataByteSize) / MemoryLayout<Float>.size
                guard sampleCount > 0 else { continue }

                let samples = mData.assumingMemoryBound(to: Float.self)

                for i in 0..<sampleCount {
                    let s = Double(samples[i])
                    let a = abs(s)
                    peak = max(peak, a)
                    totalSquares += s * s
                }

                totalSamples += sampleCount
            }

            guard totalSamples > 0 else { return }

            let rms = sqrt(totalSquares / Double(totalSamples))
            let timeSeconds: Double

            if let player = context.player {
                let t = player.currentTime().seconds
                timeSeconds = t.isFinite ? t : CACurrentMediaTime()
            } else {
                timeSeconds = CACurrentMediaTime()
            }

            engine.ingest(
                rms: CGFloat(rms),
                peak: CGFloat(peak),
                timeSeconds: timeSeconds
            )
        }

        var callbacks = MTAudioProcessingTapCallbacks(
            version: kMTAudioProcessingTapCallbacksVersion_0,
            clientInfo: UnsafeMutableRawPointer(Unmanaged.passRetained(context).toOpaque()),
            init: tapInit,
            finalize: tapFinalize,
            prepare: tapPrepare,
            unprepare: tapUnprepare,
            process: tapProcess
        )

        var tap: MTAudioProcessingTap?
        let status = MTAudioProcessingTapCreate(
            kCFAllocatorDefault,
            &callbacks,
            kMTAudioProcessingTapCreationFlag_PostEffects,
            &tap
        )

        guard status == noErr, let tap else { return }

        params.audioTapProcessor = tap

        let mix = AVMutableAudioMix()
        mix.inputParameters = [params]
        item.audioMix = mix
    }
}
