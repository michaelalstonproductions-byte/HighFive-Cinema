import Foundation

// MARK: - Public Types

public struct VerticalTemporalFrameInput: Sendable {
    public let clipID: String
    public let frameID: String

    // Current raw winner from your ranker / face tracker / subject scorer.
    public let rawWinnerID: Int?
    public let rawWinnerScore: Double

    // Whether the previous chosen winner is still in the current frame candidates.
    public let previousWinnerPresent: Bool

    // Score of the previous chosen winner if present in this frame.
    public let previousWinnerScore: Double?

    // Whether the previous chosen winner was the primary subject before.
    public let previousWasPrimary: Bool

    // Gap in frames from the last processed frame.
    public let frameJump: Int

    // Optional confidence-grace probabilities from your existing confidence model.
    // Expected class order:
    // [bad, edge, gold]
    public let confidenceGraceProbs: [Double]?

    public init(
        clipID: String,
        frameID: String,
        rawWinnerID: Int?,
        rawWinnerScore: Double,
        previousWinnerPresent: Bool,
        previousWinnerScore: Double?,
        previousWasPrimary: Bool,
        frameJump: Int,
        confidenceGraceProbs: [Double]? = nil
    ) {
        self.clipID = clipID
        self.frameID = frameID
        self.rawWinnerID = rawWinnerID
        self.rawWinnerScore = rawWinnerScore
        self.previousWinnerPresent = previousWinnerPresent
        self.previousWinnerScore = previousWinnerScore
        self.previousWasPrimary = previousWasPrimary
        self.frameJump = frameJump
        self.confidenceGraceProbs = confidenceGraceProbs
    }
}

public struct VerticalTemporalDecision: Sendable {
    public let chosenWinnerID: Int?
    public let previousWinnerID: Int?
    public let rawWinnerID: Int?

    public let temporalAction: String
    public let decisionType: String

    public let switchProbability: Double
    public let scoreGapOverPrevious: Double

    public let missingStreak: Int
    public let graceFramesUsed: Int
    public let graceActive: Bool
    public let graceRemaining: Int
    public let graceMode: String

    public let usedBaselineEngine: Bool
}

public struct VerticalTemporalConfig: Sendable {
    public let baseMissingGraceFrames: Int
    public let graceOverrideSwitchProbability: Double

    // Baseline lane thresholds
    public let hardSwitchThreshold: Double
    public let previousSubjectProtectionBias: Double
    public let previousPrimaryBonus: Double
    public let frameJumpPenaltyPerFrame: Double
    public let missingSwitchBoost: Double
    public let rawScoreScale: Double
    public let scoreGapScale: Double

    public init(
        baseMissingGraceFrames: Int = 2,
        graceOverrideSwitchProbability: Double = 0.75,
        hardSwitchThreshold: Double = 0.50,
        previousSubjectProtectionBias: Double = 0.16,
        previousPrimaryBonus: Double = 0.05,
        frameJumpPenaltyPerFrame: Double = 0.015,
        missingSwitchBoost: Double = 0.18,
        rawScoreScale: Double = 0.35,
        scoreGapScale: Double = 1.15
    ) {
        self.baseMissingGraceFrames = baseMissingGraceFrames
        self.graceOverrideSwitchProbability = graceOverrideSwitchProbability
        self.hardSwitchThreshold = hardSwitchThreshold
        self.previousSubjectProtectionBias = previousSubjectProtectionBias
        self.previousPrimaryBonus = previousPrimaryBonus
        self.frameJumpPenaltyPerFrame = frameJumpPenaltyPerFrame
        self.missingSwitchBoost = missingSwitchBoost
        self.rawScoreScale = rawScoreScale
        self.scoreGapScale = scoreGapScale
    }

    public static let baseline = VerticalTemporalConfig()
}

// MARK: - Engine

public final class VerticalTemporalDecisionEngine {
    private struct ClipState {
        var previousWinnerID: Int?
        var previousFrameID: String?
        var missingStreak: Int = 0
    }

    private var clipStates: [String: ClipState] = [:]
    private let config: VerticalTemporalConfig

    public init(config: VerticalTemporalConfig = .baseline) {
        self.config = config
    }

    public func resetAll() {
        clipStates.removeAll()
    }

    public func reset(clipID: String) {
        clipStates.removeValue(forKey: clipID)
    }

    @discardableResult
    public func process(_ input: VerticalTemporalFrameInput) -> VerticalTemporalDecision {
        var state = clipStates[input.clipID] ?? ClipState()

        let previousWinnerID = state.previousWinnerID
        let rawWinnerID = input.rawWinnerID

        let scoreGapOverPrevious: Double
        if input.previousWinnerPresent, let prevScore = input.previousWinnerScore {
            scoreGapOverPrevious = input.rawWinnerScore - prevScore
        } else {
            scoreGapOverPrevious = input.rawWinnerScore
        }

        let graceResult = confidenceToGraceFrames(input.confidenceGraceProbs)
        let graceFrames = graceResult.frames
        let graceMode = graceResult.mode

        let switchProbability = computeBaselineSwitchProbability(
            rawWinnerScore: input.rawWinnerScore,
            scoreGapOverPrevious: scoreGapOverPrevious,
            previousWinnerPresent: input.previousWinnerPresent,
            previousWasPrimary: input.previousWasPrimary,
            rawWinnerID: rawWinnerID,
            previousWinnerID: previousWinnerID,
            frameJump: input.frameJump
        )

        let chosenWinnerID: Int?
        let temporalAction: String
        let decisionType: String
        let graceActive: Bool
        let graceRemaining: Int

        if previousWinnerID == nil {
            chosenWinnerID = rawWinnerID
            temporalAction = "raw_winner"
            decisionType = "initial"
            state.missingStreak = 0
            graceActive = false
            graceRemaining = 0
        } else if !input.previousWinnerPresent {
            state.missingStreak += 1

            if switchProbability >= config.graceOverrideSwitchProbability {
                chosenWinnerID = rawWinnerID
                temporalAction = "switch_missing_subject_override"
                decisionType = "switch"
                graceActive = false
                graceRemaining = 0
            } else if state.missingStreak <= graceFrames {
                chosenWinnerID = previousWinnerID
                temporalAction = "hold_missing_subject_grace"
                decisionType = "hold"
                graceActive = true
                graceRemaining = max(0, graceFrames - state.missingStreak)
            } else {
                chosenWinnerID = rawWinnerID
                temporalAction = "switch_previous_missing"
                decisionType = "switch"
                graceActive = false
                graceRemaining = 0
            }
        } else if rawWinnerID == previousWinnerID {
            chosenWinnerID = previousWinnerID
            temporalAction = "same_subject_continues"
            decisionType = "hold"
            state.missingStreak = 0
            graceActive = false
            graceRemaining = 0
        } else {
            state.missingStreak = 0

            if switchProbability >= config.hardSwitchThreshold {
                chosenWinnerID = rawWinnerID
                temporalAction = "hard_switch_confidence"
                decisionType = "switch"
            } else {
                chosenWinnerID = previousWinnerID
                temporalAction = "hold_previous_subject"
                decisionType = "hold"
            }

            graceActive = false
            graceRemaining = 0
        }

        state.previousWinnerID = chosenWinnerID
        state.previousFrameID = input.frameID
        clipStates[input.clipID] = state

        return VerticalTemporalDecision(
            chosenWinnerID: chosenWinnerID,
            previousWinnerID: previousWinnerID,
            rawWinnerID: rawWinnerID,
            temporalAction: temporalAction,
            decisionType: decisionType,
            switchProbability: switchProbability,
            scoreGapOverPrevious: scoreGapOverPrevious,
            missingStreak: state.missingStreak,
            graceFramesUsed: graceFrames,
            graceActive: graceActive,
            graceRemaining: graceRemaining,
            graceMode: graceMode,
            usedBaselineEngine: true
        )
    }

    // MARK: - Internal Scoring

    private func computeBaselineSwitchProbability(
        rawWinnerScore: Double,
        scoreGapOverPrevious: Double,
        previousWinnerPresent: Bool,
        previousWasPrimary: Bool,
        rawWinnerID: Int?,
        previousWinnerID: Int?,
        frameJump: Int
    ) -> Double {
        let candidateIsPrevious = (rawWinnerID != nil && previousWinnerID != nil && rawWinnerID == previousWinnerID)

        var logit = 0.0

        // Core runtime-compatible temporal features
        logit += scoreGapOverPrevious * config.scoreGapScale
        logit += rawWinnerScore * config.rawScoreScale

        if previousWinnerPresent {
            logit -= config.previousSubjectProtectionBias
        } else {
            logit += config.missingSwitchBoost
        }

        if previousWasPrimary {
            logit -= config.previousPrimaryBonus
        }

        if candidateIsPrevious {
            logit -= 0.45
        } else {
            logit += 0.08
        }

        let jumpPenalty = max(0, frameJump - 1)
        logit -= Double(jumpPenalty) * config.frameJumpPenaltyPerFrame

        return sigmoid(logit)
    }

    private func confidenceToGraceFrames(_ probs: [Double]?) -> (frames: Int, mode: String) {
        guard let probs, !probs.isEmpty else {
            return (config.baseMissingGraceFrames, "no_confidence_model")
        }

        let bad = probs.indices.contains(0) ? clamp01(probs[0]) : 0.0
        let edge = probs.indices.contains(1) ? clamp01(probs[1]) : 0.0
        let gold = probs.indices.contains(2) ? clamp01(probs[2]) : 0.0

        _ = bad
        let qualityScore = gold + 0.5 * edge

        if qualityScore >= 0.80 { return (4, "gold_heavy") }
        if qualityScore >= 0.60 { return (3, "edge_gold") }
        if qualityScore >= 0.35 { return (2, "mixed") }
        return (1, "bad_heavy")
    }

    private func sigmoid(_ x: Double) -> Double {
        let clamped = max(-50.0, min(50.0, x))
        return 1.0 / (1.0 + Foundation.exp(-clamped))
    }

    private func clamp01(_ x: Double) -> Double {
        max(0.0, min(1.0, x))
    }
}
