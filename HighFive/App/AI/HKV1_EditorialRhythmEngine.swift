import Foundation
import CoreGraphics

struct HKV1_EditorialInput {
    let currentWinnerID: Int?
    let candidateID: Int?
    let switchUrgency: CGFloat
    let sceneHoldFrames: Int
    let frameIndex: Int
    let previousSwitchFrame: Int
}

struct HKV1_EditorialDecision {
    let shouldSwitch: Bool
    let shouldHold: Bool
    let urgency: CGFloat
    let reason: String
}

final class HKV1_EditorialRhythmEngine {

    private var lastSwitchFrame: Int = 0

    func reset() {
        lastSwitchFrame = 0
    }

    func process(_ input: HKV1_EditorialInput) -> HKV1_EditorialDecision {
        let framesSinceLastSwitch = input.frameIndex - lastSwitchFrame

        if framesSinceLastSwitch < input.sceneHoldFrames {
            return HKV1_EditorialDecision(
                shouldSwitch: false,
                shouldHold: true,
                urgency: 0.0,
                reason: "within_hold_window"
            )
        }

        if input.switchUrgency > 0.22 {
            lastSwitchFrame = input.frameIndex
            return HKV1_EditorialDecision(
                shouldSwitch: true,
                shouldHold: false,
                urgency: input.switchUrgency,
                reason: "high_urgency_switch"
            )
        }

        if input.switchUrgency > 0.12 {
            return HKV1_EditorialDecision(
                shouldSwitch: false,
                shouldHold: true,
                urgency: input.switchUrgency,
                reason: "soft_hold"
            )
        }

        return HKV1_EditorialDecision(
            shouldSwitch: false,
            shouldHold: true,
            urgency: input.switchUrgency,
            reason: "low_urgency_hold"
        )
    }
}
