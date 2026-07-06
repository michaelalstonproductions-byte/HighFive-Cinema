import Foundation
import CoreGraphics

struct HKV1_Layer4PracticeMotionState: Equatable {
    var isVisible: Bool
    var reduceMotion: Bool
    var activeDisplayLinkCount: Int
    var rawTiltX: CGFloat
    var rawTiltY: CGFloat
    var demoOffsetX: CGFloat
    var demoOffsetY: CGFloat
    var maxTranslationX: CGFloat
    var maxTranslationY: CGFloat
    var hasUserPressedNext: Bool
}

struct HKV1_Layer4PracticeMotionDecision: Equatable {
    var allowMotion: Bool
    var useStaticDepthCard: Bool
    var maxTranslationX: CGFloat
    var maxTranslationY: CGFloat
    var clampDemoOffset: Bool
    var shouldStopMotionOnNext: Bool
    var duplicateDisplayLinkRisk: CGFloat
    var overtravelRisk: CGFloat
    var reason: String

    static let staticMode = HKV1_Layer4PracticeMotionDecision(
        allowMotion: false,
        useStaticDepthCard: true,
        maxTranslationX: 0,
        maxTranslationY: 0,
        clampDemoOffset: true,
        shouldStopMotionOnNext: true,
        duplicateDisplayLinkRisk: 0,
        overtravelRisk: 0,
        reason: "static"
    )

    var clamped: HKV1_Layer4PracticeMotionDecision {
        HKV1_Layer4PracticeMotionDecision(
            allowMotion: allowMotion,
            useStaticDepthCard: useStaticDepthCard,
            maxTranslationX: HKV1_Layer4Math.clamp(maxTranslationX, 0, 24),
            maxTranslationY: HKV1_Layer4Math.clamp(maxTranslationY, 0, 14),
            clampDemoOffset: clampDemoOffset,
            shouldStopMotionOnNext: shouldStopMotionOnNext,
            duplicateDisplayLinkRisk: HKV1_Layer4Math.clamp01(duplicateDisplayLinkRisk),
            overtravelRisk: HKV1_Layer4Math.clamp01(overtravelRisk),
            reason: reason
        )
    }
}

final class HKV1_Layer4PracticeMotionSafetyGuard {
    func decide(_ state: HKV1_Layer4PracticeMotionState) -> HKV1_Layer4PracticeMotionDecision {
        guard state.isVisible else {
            return .staticMode
        }

        if state.reduceMotion {
            return HKV1_Layer4PracticeMotionDecision(
                allowMotion: false,
                useStaticDepthCard: true,
                maxTranslationX: 0,
                maxTranslationY: 0,
                clampDemoOffset: true,
                shouldStopMotionOnNext: true,
                duplicateDisplayLinkRisk: 0,
                overtravelRisk: 0,
                reason: "reduce motion"
            ).clamped
        }

        let duplicateRisk: CGFloat = state.activeDisplayLinkCount > 1 ? 1.0 : 0.0
        let overtravelX = abs(state.demoOffsetX) > max(state.maxTranslationX, 0.001)
        let overtravelY = abs(state.demoOffsetY) > max(state.maxTranslationY, 0.001)
        let overtravelRisk: CGFloat = overtravelX || overtravelY ? 1.0 : 0.0

        return HKV1_Layer4PracticeMotionDecision(
            allowMotion: duplicateRisk < 0.5,
            useStaticDepthCard: duplicateRisk >= 0.5,
            maxTranslationX: min(max(state.maxTranslationX, 8), 24),
            maxTranslationY: min(max(state.maxTranslationY, 5), 14),
            clampDemoOffset: true,
            shouldStopMotionOnNext: true,
            duplicateDisplayLinkRisk: duplicateRisk,
            overtravelRisk: overtravelRisk,
            reason: duplicateRisk > 0.5 ? "duplicate display link guarded" : "practice motion safe"
        ).clamped
    }
}
