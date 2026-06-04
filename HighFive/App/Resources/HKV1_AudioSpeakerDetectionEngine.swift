//
//  HKV1_AudioSpeakerDetectionEngine.swift
//  HigherKeySpatialPeek_Rebuild
//
//  Real audio speaker detection engine
//

import Foundation
import CoreGraphics
import AVFoundation
import CoreMedia
import AudioToolbox

final class HKV1_AudioSpeakerDetectionEngine {

    struct SubjectInput {
        let stableID: Int
        let boundingBox: CGRect
    }

    struct SubjectOutput {
        let stableID: Int
        let audioScore: CGFloat
        let fusedSpeakerScore: CGFloat
        let speechConfidence: CGFloat
        let rms: CGFloat
        let peak: CGFloat
        let speakingWindowActive: Bool
    }

    private struct SubjectState {
        var audioScore: CGFloat = 0.0
        var fusedSpeakerScore: CGFloat = 0.0
        var speechConfidence: CGFloat = 0.0
        var lastSeenFrame: Int = 0
        var lastCenteredWeight: CGFloat = 0.0
    }

    private struct SpeechWindow {
        let start: Double
        let end: Double
        let confidence: CGFloat
        let rms: CGFloat
        let peak: CGFloat
    }

    private var states: [Int: SubjectState] = [:]
    private var speechWindows: [SpeechWindow] = []

    private var lastRMS: CGFloat = 0.0
    private var lastPeak: CGFloat = 0.0
    private var lastSpeechConfidence: CGFloat = 0.0
    private var lastSampleTimeSeconds: Double = 0.0

    // Gold tuned audio reactivity
    private let riseAlpha: CGFloat = 0.74
    private let fallAlpha: CGFloat = 0.18
    private let fusedRiseAlpha: CGFloat = 0.62
    private let fusedFallAlpha: CGFloat = 0.16
    private let staleFrameCutoff: Int = 24

    private let rmsSpeechFloor: CGFloat = 0.015
    private let peakSpeechFloor: CGFloat = 0.045
    private let speechWindowDuration: Double = 0.12
    private let speechWindowRetention: Double = 0.85

    private let centerWeightFloor: CGFloat = 0.55
    private let centerWeightCeiling: CGFloat = 1.0

    func reset() {
        states.removeAll()
        speechWindows.removeAll()
        lastRMS = 0.0
        lastPeak = 0.0
        lastSpeechConfidence = 0.0
        lastSampleTimeSeconds = 0.0
    }

    func ingest(sampleBuffer: CMSampleBuffer, at timeSeconds: Double? = nil) {
        let sampleTime: Double = timeSeconds ?? CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
        guard sampleTime.isFinite else { return }
        guard let metrics = extractMetrics(from: sampleBuffer) else { return }
        ingest(rms: metrics.rms, peak: metrics.peak, timeSeconds: sampleTime)
    }

    func ingest(rms: CGFloat, peak: CGFloat, timeSeconds: Double) {
        guard timeSeconds.isFinite else { return }

        lastSampleTimeSeconds = timeSeconds
        lastRMS = rms
        lastPeak = peak

        let speechConfidence: CGFloat = computeSpeechConfidence(rms: rms, peak: peak)
        lastSpeechConfidence = speechConfidence

        if speechConfidence > 0.18 {
            let window = SpeechWindow(
                start: timeSeconds,
                end: timeSeconds + speechWindowDuration,
                confidence: speechConfidence,
                rms: rms,
                peak: peak
            )
            speechWindows.append(window)
        }

        trimSpeechWindows(now: timeSeconds)
    }

    func process(
        subjects: [SubjectInput],
        frameIndex: Int,
        currentTimeSeconds: Double
    ) -> [SubjectOutput] {
        guard !subjects.isEmpty else {
            cleanup(frameIndex: frameIndex, currentTimeSeconds: currentTimeSeconds)
            return []
        }

        trimSpeechWindows(now: currentTimeSeconds)

        let activeWindow: SpeechWindow? = strongestSpeechWindow(at: currentTimeSeconds)
        let currentSpeechConfidence: CGFloat = activeWindow?.confidence ?? lastSpeechConfidence
        let currentRMS: CGFloat = activeWindow?.rms ?? lastRMS
        let currentPeak: CGFloat = activeWindow?.peak ?? lastPeak
        let speakingWindowActive: Bool = (activeWindow != nil)

        let subjectCount = max(1, subjects.count)
        var outputs: [SubjectOutput] = []
        outputs.reserveCapacity(subjects.count)

        for subject in subjects {
            var state = states[subject.stableID] ?? SubjectState()

            let centerWeight: CGFloat = visualCenterWeight(for: subject.boundingBox, subjectCount: subjectCount)
            state.lastCenteredWeight = centerWeight

            let targetAudioScore: CGFloat = currentSpeechConfidence * centerWeight
            let scoreAlpha: CGFloat = targetAudioScore >= state.audioScore ? riseAlpha : fallAlpha
            state.audioScore += (targetAudioScore - state.audioScore) * scoreAlpha

            let instantAudioBias: CGFloat = currentSpeechConfidence * 0.32
            let targetFused: CGFloat = clamp(
                (state.audioScore * 0.56) + (currentSpeechConfidence * 0.44 * centerWeight) + instantAudioBias,
                min: 0.0,
                max: 1.0
            )

            let fusedAlpha: CGFloat = targetFused >= state.fusedSpeakerScore ? fusedRiseAlpha : fusedFallAlpha
            state.fusedSpeakerScore += (targetFused - state.fusedSpeakerScore) * fusedAlpha

            state.speechConfidence = currentSpeechConfidence
            state.lastSeenFrame = frameIndex
            states[subject.stableID] = state

            outputs.append(
                SubjectOutput(
                    stableID: subject.stableID,
                    audioScore: clamp(state.audioScore, min: 0.0, max: 1.0),
                    fusedSpeakerScore: clamp(state.fusedSpeakerScore, min: 0.0, max: 1.0),
                    speechConfidence: clamp(currentSpeechConfidence, min: 0.0, max: 1.0),
                    rms: currentRMS,
                    peak: currentPeak,
                    speakingWindowActive: speakingWindowActive
                )
            )
        }

        cleanup(frameIndex: frameIndex, currentTimeSeconds: currentTimeSeconds)
        return outputs
    }

    private func computeSpeechConfidence(rms: CGFloat, peak: CGFloat) -> CGFloat {
        let rmsNorm: CGFloat = clamp((rms - rmsSpeechFloor) / 0.12, min: 0.0, max: 1.0)
        let peakNorm: CGFloat = clamp((peak - peakSpeechFloor) / 0.28, min: 0.0, max: 1.0)
        let instantBias: CGFloat = peakNorm * 0.12
        return clamp((rmsNorm * 0.52) + (peakNorm * 0.48) + instantBias, min: 0.0, max: 1.0)
    }

    private func strongestSpeechWindow(at timeSeconds: Double) -> SpeechWindow? {
        let active = speechWindows.filter { window in
            timeSeconds >= window.start && timeSeconds <= window.end
        }
        return active.max { lhs, rhs in
            lhs.confidence < rhs.confidence
        }
    }

    private func trimSpeechWindows(now: Double) {
        speechWindows = speechWindows.filter { window in
            (now - window.end) <= speechWindowRetention
        }
    }

    private func cleanup(frameIndex: Int, currentTimeSeconds: Double) {
        states = states.filter { _, state in
            (frameIndex - state.lastSeenFrame) <= staleFrameCutoff
        }
        trimSpeechWindows(now: currentTimeSeconds)
    }

    private func visualCenterWeight(for rect: CGRect, subjectCount: Int) -> CGFloat {
        let centerXBias: CGFloat = 1.0 - abs(rect.midX - 0.5) / 0.5
        let centerYBias: CGFloat = 1.0 - abs(rect.midY - 0.56) / 0.56
        let area: CGFloat = rect.width * rect.height

        let areaBias: CGFloat = clamp(area / 0.12, min: 0.25, max: 1.0)
        let dialogueFavor: CGFloat = subjectCount <= 2 ? 1.0 : 0.92

        let raw: CGFloat = ((centerXBias * 0.48) + (centerYBias * 0.22) + (areaBias * 0.30)) * dialogueFavor
        return clamp(raw, min: centerWeightFloor, max: centerWeightCeiling)
    }

    private func extractMetrics(from sampleBuffer: CMSampleBuffer) -> (rms: CGFloat, peak: CGFloat)? {
        guard let dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else { return nil }
        guard let formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer) else { return nil }
        guard let asbdPtr = CMAudioFormatDescriptionGetStreamBasicDescription(formatDesc) else { return nil }

        let asbd = asbdPtr.pointee
        guard asbd.mFormatID == kAudioFormatLinearPCM else { return nil }

        var totalLength = 0
        var dataPointer: UnsafeMutablePointer<Int8>?
        let status = CMBlockBufferGetDataPointer(
            dataBuffer,
            atOffset: 0,
            lengthAtOffsetOut: nil,
            totalLengthOut: &totalLength,
            dataPointerOut: &dataPointer
        )

        guard status == kCMBlockBufferNoErr, let dataPointer, totalLength > 0 else { return nil }

        let formatFlags = asbd.mFormatFlags
        let isFloat = (formatFlags & kAudioFormatFlagIsFloat) != 0
        let isSignedInteger = (formatFlags & kAudioFormatFlagIsSignedInteger) != 0
        let isBigEndian = (formatFlags & kAudioFormatFlagIsBigEndian) != 0

        let bytesPerFrame = Int(asbd.mBytesPerFrame)
        let channels = max(1, Int(asbd.mChannelsPerFrame))
        guard bytesPerFrame > 0 else { return nil }

        let frameCount = totalLength / bytesPerFrame
        guard frameCount > 0 else { return nil }

        if isFloat && asbd.mBitsPerChannel == 32 {
            let sampleCount = frameCount * channels
            let ptr = UnsafeRawPointer(dataPointer).assumingMemoryBound(to: Float.self)
            var sumSquares: Double = 0.0
            var peak: Float = 0.0

            for i in 0..<sampleCount {
                let s = ptr[i]
                let a = abs(s)
                peak = max(peak, a)
                sumSquares += Double(s * s)
            }

            let rms = sqrt(sumSquares / Double(sampleCount))
            return (CGFloat(rms), CGFloat(peak))
        }

        if isSignedInteger && asbd.mBitsPerChannel == 16 && !isBigEndian {
            let sampleCount = frameCount * channels
            let ptr = UnsafeRawPointer(dataPointer).assumingMemoryBound(to: Int16.self)
            var sumSquares: Double = 0.0
            var peak: Double = 0.0

            for i in 0..<sampleCount {
                let normalized = Double(ptr[i]) / Double(Int16.max)
                let a = abs(normalized)
                peak = max(peak, a)
                sumSquares += normalized * normalized
            }

            let rms = sqrt(sumSquares / Double(sampleCount))
            return (CGFloat(rms), CGFloat(peak))
        }

        if isSignedInteger && asbd.mBitsPerChannel == 32 && !isBigEndian {
            let sampleCount = frameCount * channels
            let ptr = UnsafeRawPointer(dataPointer).assumingMemoryBound(to: Int32.self)
            var sumSquares: Double = 0.0
            var peak: Double = 0.0

            for i in 0..<sampleCount {
                let normalized = Double(ptr[i]) / Double(Int32.max)
                let a = abs(normalized)
                peak = max(peak, a)
                sumSquares += normalized * normalized
            }

            let rms = sqrt(sumSquares / Double(sampleCount))
            return (CGFloat(rms), CGFloat(peak))
        }

        return nil
    }

    private func clamp(_ value: CGFloat, min minValue: CGFloat, max maxValue: CGFloat) -> CGFloat {
        return Swift.max(minValue, Swift.min(maxValue, value))
    }
}
