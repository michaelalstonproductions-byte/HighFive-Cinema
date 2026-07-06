//
//  HKV1_ReactionDirector.swift
//  HigherKeySpatialPeek_Rebuild
//
//  Director-level reaction chooser.
//

import Foundation
import CoreGraphics

enum HKV1_DirectorSceneType: String {
    case interview
    case dialogue
    case confrontation
    case intimacy
    case action
    case ensemble
    case reveal
    case unknown
}

enum HKV1_DirectorDecisionType: String {
    case holdSpeaker
    case holdReaction
    case switchToSpeaker
    case switchToReaction
    case holdCurrent
}

struct HKV1_ReactionDirectorSubject {
    let stableID: Int
    let boundingBox: CGRect
    let confidence: CGFloat
    let speakingScore: CGFloat
    let eyeContactScore: CGFloat
    let motionScore: CGFloat
    let isPrimaryCandidate: Bool
    let isPreviousWinner: Bool
}

struct HKV1_ReactionDirectorFrameInput {
    let subjects: [HKV1_ReactionDirectorSubject]
    let currentWinnerStableID: Int?
    let sceneType: HKV1_DirectorSceneType
    let shotClassRawValue: String
    let frameIndex: Int
    let frameBrightness: CGFloat
    let currentTimeSeconds: Double
}

struct HKV1_ReactionDirectorDecision {
    let decisionType: HKV1_DirectorDecisionType
    let chosenStableID: Int?
    let speakerStableID: Int?
    let reactionStableID: Int?
    let holdFramesRemaining: Int
    let switchUrgency: CGFloat
    let speakerScore: CGFloat
    let reactionScore: CGFloat
    let reason: String
}

final class HKV1_ReactionDirector {

    struct Config {
        let speakerDominanceThreshold: CGFloat
        let reactionPromotionThreshold: CGFloat
        let minimumHoldFrames: Int
        let reactionHoldFrames: Int
        let confrontationReactionBoost: CGFloat
        let intimacyReactionBoost: CGFloat
        let lowMotionReactionBoost: CGFloat
        let eyeContactReactionBoost: CGFloat
        let continuityBoost: CGFloat
        let previousWinnerStickiness: CGFloat
        let audioLeadBoost: CGFloat

        static let cinematic = Config(
            speakerDominanceThreshold: 0.14,
            reactionPromotionThreshold: 0.10,
            minimumHoldFrames: 7,
            reactionHoldFrames: 10,
            confrontationReactionBoost: 0.22,
            intimacyReactionBoost: 0.18,
            lowMotionReactionBoost: 0.12,
            eyeContactReactionBoost: 0.18,
            continuityBoost: 0.10,
            previousWinnerStickiness: 0.12,
            audioLeadBoost: 0.20
        )
    }

    private struct HoldState {
        var stableID: Int?
        var framesRemaining: Int = 0
        var reason: String = "none"
    }

    private let config: Config
    private var holdState = HoldState()
    private var lastSpeakerStableID: Int?
    private var lastReactionStableID: Int?
    private var lastDecisionType: HKV1_DirectorDecisionType = .holdCurrent

    init(config: Config = .cinematic) {
        self.config = config
    }

    func reset() {
        holdState = HoldState()
        lastSpeakerStableID = nil
        lastReactionStableID = nil
        lastDecisionType = .holdCurrent
    }

    func process(_ input: HKV1_ReactionDirectorFrameInput) -> HKV1_ReactionDirectorDecision {
        guard !input.subjects.isEmpty else {
            holdState.framesRemaining = max(0, holdState.framesRemaining - 1)
            return HKV1_ReactionDirectorDecision(
                decisionType: .holdCurrent,
                chosenStableID: input.currentWinnerStableID,
                speakerStableID: nil,
                reactionStableID: nil,
                holdFramesRemaining: holdState.framesRemaining,
                switchUrgency: 0,
                speakerScore: 0,
                reactionScore: 0,
                reason: "no_subjects"
            )
        }

        let speakerCandidate = bestSpeaker(in: input)
        let reactionCandidate = bestReaction(
            in: input,
            excluding: speakerCandidate?.stableID,
            speaker: speakerCandidate
        )

        let speakerScore = speakerCandidate.map { speakerPriorityScore(for: $0, in: input) } ?? 0
        let reactionScore = reactionCandidate.map { reactionPriorityScore(for: $0, speaker: speakerCandidate, in: input) } ?? 0
        let currentWinner = input.subjects.first(where: { $0.stableID == input.currentWinnerStableID })

        if holdState.framesRemaining > 0, let heldID = holdState.stableID {
            holdState.framesRemaining -= 1

            if let heldSubject = input.subjects.first(where: { $0.stableID == heldID }), heldSubject.confidence > 0.15 {
                let decision: HKV1_DirectorDecisionType = (heldID == speakerCandidate?.stableID) ? .holdSpeaker : .holdReaction
                return HKV1_ReactionDirectorDecision(
                    decisionType: decision,
                    chosenStableID: heldID,
                    speakerStableID: speakerCandidate?.stableID,
                    reactionStableID: reactionCandidate?.stableID,
                    holdFramesRemaining: holdState.framesRemaining,
                    switchUrgency: 0.10,
                    speakerScore: speakerScore,
                    reactionScore: reactionScore,
                    reason: "hold_state_" + holdState.reason
                )
            }
        }

        let currentWinnerScore: CGFloat = {
            guard let currentWinner else { return 0 }
            let currentAsSpeaker = speakerPriorityScore(for: currentWinner, in: input)
            let currentAsReaction = reactionPriorityScore(for: currentWinner, speaker: speakerCandidate, in: input)
            return max(currentAsSpeaker, currentAsReaction)
        }()

        let darkPenalty: CGFloat = input.frameBrightness < 0.32 ? 0.04 : 0.0
        let reactionMargin = config.reactionPromotionThreshold + darkPenalty
        let speakerMargin = config.speakerDominanceThreshold + (input.frameBrightness < 0.30 ? 0.03 : 0.0)

        let reactionBeatsSpeaker = reactionScore > max(
            speakerScore + reactionMargin,
            currentWinnerScore + (reactionMargin * 0.55)
        )

        let speakerDominant = speakerScore > max(
            reactionScore + speakerMargin,
            currentWinnerScore + (speakerMargin * 0.35)
        )

        if let currentWinner, currentWinnerScore > 0, !reactionBeatsSpeaker, !speakerDominant {
            return HKV1_ReactionDirectorDecision(
                decisionType: .holdCurrent,
                chosenStableID: currentWinner.stableID,
                speakerStableID: speakerCandidate?.stableID,
                reactionStableID: reactionCandidate?.stableID,
                holdFramesRemaining: 0,
                switchUrgency: 0,
                speakerScore: speakerScore,
                reactionScore: reactionScore,
                reason: "current_winner_continuity"
            )
        }

        if reactionBeatsSpeaker, let reaction = reactionCandidate {
            let chosenID = reaction.stableID
            lastReactionStableID = chosenID

            let shouldSwitch = input.currentWinnerStableID != chosenID
            let urgency = clamp(reactionScore - max(speakerScore, currentWinnerScore), min: 0, max: 1)

            holdState = HoldState(
                stableID: chosenID,
                framesRemaining: config.reactionHoldFrames,
                reason: "reaction"
            )

            lastDecisionType = shouldSwitch ? .switchToReaction : .holdReaction

            return HKV1_ReactionDirectorDecision(
                decisionType: lastDecisionType,
                chosenStableID: chosenID,
                speakerStableID: speakerCandidate?.stableID,
                reactionStableID: reactionCandidate?.stableID,
                holdFramesRemaining: holdState.framesRemaining,
                switchUrgency: urgency,
                speakerScore: speakerScore,
                reactionScore: reactionScore,
                reason: "reaction_priority"
            )
        }

        if let speaker = speakerCandidate {
            let chosenID = speaker.stableID
            lastSpeakerStableID = chosenID

            let shouldSwitch = input.currentWinnerStableID != chosenID
            let urgency = clamp(speakerScore - max(reactionScore, currentWinnerScore), min: 0, max: 1)

            holdState = HoldState(
                stableID: chosenID,
                framesRemaining: config.minimumHoldFrames,
                reason: "speaker"
            )

            lastDecisionType = shouldSwitch ? .switchToSpeaker : .holdSpeaker

            return HKV1_ReactionDirectorDecision(
                decisionType: lastDecisionType,
                chosenStableID: chosenID,
                speakerStableID: speakerCandidate?.stableID,
                reactionStableID: reactionCandidate?.stableID,
                holdFramesRemaining: holdState.framesRemaining,
                switchUrgency: urgency,
                speakerScore: speakerScore,
                reactionScore: reactionScore,
                reason: speakerDominant ? "speaker_dominant" : "speaker_selected"
            )
        }

        return HKV1_ReactionDirectorDecision(
            decisionType: .holdCurrent,
            chosenStableID: input.currentWinnerStableID,
            speakerStableID: speakerCandidate?.stableID,
            reactionStableID: reactionCandidate?.stableID,
            holdFramesRemaining: 0,
            switchUrgency: 0,
            speakerScore: speakerScore,
            reactionScore: reactionScore,
            reason: "fallback_hold_current"
        )
    }

    private func bestSpeaker(in input: HKV1_ReactionDirectorFrameInput) -> HKV1_ReactionDirectorSubject? {
        input.subjects.max { lhs, rhs in
            speakerPriorityScore(for: lhs, in: input) < speakerPriorityScore(for: rhs, in: input)
        }
    }

    private func bestReaction(
        in input: HKV1_ReactionDirectorFrameInput,
        excluding excludedID: Int?,
        speaker: HKV1_ReactionDirectorSubject?
    ) -> HKV1_ReactionDirectorSubject? {
        input.subjects
            .filter { $0.stableID != excludedID }
            .max { lhs, rhs in
                reactionPriorityScore(for: lhs, speaker: speaker, in: input) < reactionPriorityScore(for: rhs, speaker: speaker, in: input)
            }
    }

    private func speakerPriorityScore(
        for subject: HKV1_ReactionDirectorSubject,
        in input: HKV1_ReactionDirectorFrameInput
    ) -> CGFloat {
        let centerBias = centerWeight(for: subject.boundingBox)
        let sizeBias = areaWeight(for: subject.boundingBox)
        let continuity = subject.isPreviousWinner ? config.previousWinnerStickiness : 0
        let primary = subject.isPrimaryCandidate ? 0.08 : 0
        let speakingLead = subject.speakingScore * (0.68 + config.audioLeadBoost)
        let eyeSupport = subject.eyeContactScore * 0.12

        return speakingLead
            + (subject.confidence * 0.18)
            + (centerBias * 0.08)
            + (sizeBias * 0.06)
            + eyeSupport
            + continuity
            + primary
    }

    private func reactionPriorityScore(
        for subject: HKV1_ReactionDirectorSubject,
        speaker: HKV1_ReactionDirectorSubject?,
        in input: HKV1_ReactionDirectorFrameInput
    ) -> CGFloat {
        let centerBias = centerWeight(for: subject.boundingBox)
        let sizeBias = areaWeight(for: subject.boundingBox)
        let continuity = subject.isPreviousWinner ? config.continuityBoost : 0
        let stillness = 1.0 - clamp(subject.motionScore, min: 0, max: 1)
        let lowMotionBonus = stillness * config.lowMotionReactionBoost
        let eyeBonus = subject.eyeContactScore * config.eyeContactReactionBoost
        let notSpeakingPenalty = subject.speakingScore * 0.18

        var sceneBoost: CGFloat = 0
        switch input.sceneType {
        case .confrontation:
            sceneBoost += config.confrontationReactionBoost
        case .intimacy:
            sceneBoost += config.intimacyReactionBoost
        case .reveal:
            sceneBoost += 0.16
        case .dialogue:
            sceneBoost += 0.08
        default:
            break
        }

        let relationBoost: CGFloat
        if let speaker {
            let horizontalDistance = abs(subject.boundingBox.midX - speaker.boundingBox.midX)
            relationBoost = clamp(1.0 - horizontalDistance, min: 0, max: 1) * 0.10
        } else {
            relationBoost = 0.04
        }

        return (subject.confidence * 0.16)
            + (centerBias * 0.10)
            + (sizeBias * 0.06)
            + lowMotionBonus
            + eyeBonus
            + sceneBoost
            + relationBoost
            + continuity
            - notSpeakingPenalty
    }

    private func centerWeight(for rect: CGRect) -> CGFloat {
        let x = 1.0 - abs(rect.midX - 0.5) / 0.5
        let y = 1.0 - abs(rect.midY - 0.56) / 0.56
        return clamp((x * 0.56) + (y * 0.44), min: 0, max: 1)
    }

    private func areaWeight(for rect: CGRect) -> CGFloat {
        clamp((rect.width * rect.height) / 0.16, min: 0.12, max: 1.0)
    }

    private func clamp(_ value: CGFloat, min minValue: CGFloat, max maxValue: CGFloat) -> CGFloat {
        Swift.max(minValue, Swift.min(maxValue, value))
    }
}
