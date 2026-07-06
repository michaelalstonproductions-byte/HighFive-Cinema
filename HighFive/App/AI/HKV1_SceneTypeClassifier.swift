//
//  HKV1_SceneTypeClassifier.swift
//  HigherKeySpatialPeek_Rebuild
//
//  Final director-brain scene classification layer.
//  Purpose:
//  - classifies the current moment as interview / dialogue / confrontation / intimacy / action / ensemble / reveal
//  - provides timing and shot-policy hints to ReactionDirector / temporal decision layers
//

import Foundation
import CoreGraphics

struct HKV1_SceneTypeFrameInput {
    let subjectCount: Int
    let speakingCount: Int
    let dominantSpeakingScore: CGFloat
    let dominantEyeContactScore: CGFloat
    let averageMotionScore: CGFloat
    let brightestSubjectArea: CGFloat
    let frameBrightness: CGFloat
    let currentShotClassRawValue: String
    let currentWinnerStableID: Int?
    let previousWinnerStableID: Int?
}

struct HKV1_SceneTypeDecision {
    let sceneType: HKV1_DirectorSceneType
    let confidence: CGFloat
    let recommendedHoldFrames: Int
    let recommendedSwitchMargin: CGFloat
    let prefersReactionShots: Bool
    let reason: String
}

final class HKV1_SceneTypeClassifier {

    struct Config {
        let intimacyEyeThreshold: CGFloat
        let dialogueSpeakingThreshold: CGFloat
        let confrontationSpeakingCount: Int
        let actionMotionThreshold: CGFloat
        let revealBrightnessThreshold: CGFloat
        let ensembleCountThreshold: Int

        static let cinematic = Config(
            intimacyEyeThreshold: 0.58,
            dialogueSpeakingThreshold: 0.48,
            confrontationSpeakingCount: 2,
            actionMotionThreshold: 0.34,
            revealBrightnessThreshold: 0.34,
            ensembleCountThreshold: 3
        )
    }

    private let config: Config

    init(config: Config = .cinematic) {
        self.config = config
    }

    func classify(_ input: HKV1_SceneTypeFrameInput) -> HKV1_SceneTypeDecision {
        let shotClass = input.currentShotClassRawValue.lowercased()

        if input.subjectCount >= config.ensembleCountThreshold && input.speakingCount >= 2 {
            return HKV1_SceneTypeDecision(
                sceneType: .ensemble,
                confidence: 0.82,
                recommendedHoldFrames: 6,
                recommendedSwitchMargin: 0.18,
                prefersReactionShots: false,
                reason: "multi_subject_ensemble"
            )
        }

        if input.averageMotionScore >= config.actionMotionThreshold && shotClass == "wide" {
            return HKV1_SceneTypeDecision(
                sceneType: .action,
                confidence: 0.80,
                recommendedHoldFrames: 4,
                recommendedSwitchMargin: 0.10,
                prefersReactionShots: false,
                reason: "high_motion_wide"
            )
        }

        if shotClass == "close" && input.dominantEyeContactScore >= config.intimacyEyeThreshold {
            return HKV1_SceneTypeDecision(
                sceneType: .intimacy,
                confidence: 0.86,
                recommendedHoldFrames: 10,
                recommendedSwitchMargin: 0.22,
                prefersReactionShots: true,
                reason: "close_eye_contact"
            )
        }

        if input.frameBrightness < config.revealBrightnessThreshold && shotClass == "close" {
            return HKV1_SceneTypeDecision(
                sceneType: .reveal,
                confidence: 0.72,
                recommendedHoldFrames: 11,
                recommendedSwitchMargin: 0.24,
                prefersReactionShots: true,
                reason: "dark_close_reveal"
            )
        }

        if input.speakingCount >= config.confrontationSpeakingCount && shotClass != "wide" {
            return HKV1_SceneTypeDecision(
                sceneType: .confrontation,
                confidence: 0.78,
                recommendedHoldFrames: 7,
                recommendedSwitchMargin: 0.16,
                prefersReactionShots: true,
                reason: "multiple_active_speakers"
            )
        }

        if input.dominantSpeakingScore >= config.dialogueSpeakingThreshold {
            return HKV1_SceneTypeDecision(
                sceneType: .dialogue,
                confidence: 0.76,
                recommendedHoldFrames: 8,
                recommendedSwitchMargin: 0.14,
                prefersReactionShots: true,
                reason: "dominant_speaker_detected"
            )
        }

        if input.subjectCount <= 1 {
            return HKV1_SceneTypeDecision(
                sceneType: .interview,
                confidence: 0.68,
                recommendedHoldFrames: 12,
                recommendedSwitchMargin: 0.26,
                prefersReactionShots: false,
                reason: "single_subject_interview"
            )
        }

        return HKV1_SceneTypeDecision(
            sceneType: .unknown,
            confidence: 0.40,
            recommendedHoldFrames: 7,
            recommendedSwitchMargin: 0.16,
            prefersReactionShots: false,
            reason: "fallback_unknown"
        )
    }
}
