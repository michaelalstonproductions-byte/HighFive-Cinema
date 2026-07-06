import Foundation
import CoreGraphics
import AVFoundation

final class HKV1_VibeEngine {

    struct CandidateContext {
        let rect: CGRect
        let isPreviousWinner: Bool
        let isPrimaryCandidate: Bool
        let confidence: CGFloat
        let subjectVelocityX: CGFloat
        let lockConfidence: CGFloat
        let frameBrightness: CGFloat
    }

    struct Output {
        let totalBoost: CGFloat
        let dialogueBoost: CGFloat
        let motionBias: CGFloat
        let compositionBias: CGFloat
        let continuityBias: CGFloat
        let antiCollapseBias: CGFloat
        let dialogueActive: Bool
    }

    private var smoothedAudioEnergy: CGFloat = 0.0
    private var smoothedDialoguePresence: CGFloat = 0.0
    private var smoothedSceneEnergy: CGFloat = 0.0
    private var lastEnergySample: CGFloat = 0.0

    func reset() {
        smoothedAudioEnergy = 0.0
        smoothedDialoguePresence = 0.0
        smoothedSceneEnergy = 0.0
        lastEnergySample = 0.0
    }

    func update(from player: AVPlayer) {
        let isPlaying = player.timeControlStatus == .playing
        let volume = CGFloat(player.volume)
        let currentTimeSeconds = player.currentTime().seconds
        let t: CGFloat = currentTimeSeconds.isFinite ? CGFloat(currentTimeSeconds) : 0.0

        let transportEnergy: CGFloat = isPlaying ? max(0.18, volume) : 0.0
        let phrasePulse: CGFloat = isPlaying ? (0.5 + (0.5 * sin(t * 3.1))) : 0.0
        let rawEnergy = transportEnergy * (0.72 + (0.28 * phrasePulse))

        smoothedAudioEnergy += (rawEnergy - smoothedAudioEnergy) * 0.10

        let dialogueTarget: CGFloat
        if smoothedAudioEnergy > 0.14 {
            dialogueTarget = 1.0
        } else if smoothedAudioEnergy > 0.08 {
            dialogueTarget = 0.55
        } else {
            dialogueTarget = 0.0
        }

        smoothedDialoguePresence += (dialogueTarget - smoothedDialoguePresence) * 0.08
        smoothedSceneEnergy += (abs(smoothedAudioEnergy - lastEnergySample) - smoothedSceneEnergy) * 0.14
        lastEnergySample = smoothedAudioEnergy
    }

    func scoreCandidate(_ candidate: CandidateContext) -> Output {
        let rect = candidate.rect
        let area = rect.width * rect.height

        let horizontalCenterBias = 1.0 - abs(rect.midX - 0.5) / 0.5
        let verticalDialogueZoneBias = 1.0 - abs(rect.midY - 0.56) / 0.56
        let compositionCore = max(0.0, (horizontalCenterBias * 0.46) + (verticalDialogueZoneBias * 0.54))
        let compositionBias = compositionCore * 0.18

        let motionMagnitude = min(abs(candidate.subjectVelocityX) * 3.1, 1.0)
        let dialogueActive = smoothedDialoguePresence > 0.36

        let dialogueBoost: CGFloat = dialogueActive
            ? ((0.42 + (compositionCore * 0.28)) * (0.66 + (motionMagnitude * 0.34)))
            : 0.0

        let motionBias: CGFloat = motionMagnitude * (dialogueActive ? 0.86 : 0.42)
        let continuityBias: CGFloat = candidate.isPreviousWinner ? 0.58 : 0.0

        let antiCollapseBias: CGFloat = {
            let nearEdgeX = min(rect.midX, 1.0 - rect.midX)
            let edgeFactor = 1.0 - min(1.0, nearEdgeX / 0.18)
            let protection =
                edgeFactor *
                motionMagnitude *
                max(candidate.lockConfidence, 0.34) *
                (dialogueActive ? 0.90 : 0.55)

            return protection * 0.72
        }()

        let primaryBias: CGFloat = candidate.isPrimaryCandidate ? 0.24 : 0.0
        let confidenceBias: CGFloat = candidate.confidence * 0.16
        let sizeSoftBias: CGFloat = min(area * 0.38, 0.18)
        let lowLightPenalty: CGFloat = candidate.frameBrightness < 0.34 ? 0.04 : 0.0

        let total =
            dialogueBoost +
            motionBias +
            compositionBias +
            continuityBias +
            antiCollapseBias +
            primaryBias +
            confidenceBias +
            sizeSoftBias -
            lowLightPenalty

        return Output(
            totalBoost: total,
            dialogueBoost: dialogueBoost,
            motionBias: motionBias,
            compositionBias: compositionBias,
            continuityBias: continuityBias,
            antiCollapseBias: antiCollapseBias,
            dialogueActive: dialogueActive
        )
    }
}
