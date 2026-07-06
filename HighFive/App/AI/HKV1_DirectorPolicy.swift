import Foundation
import CoreGraphics

enum HKV1_DirectorStyle: String {
    case cinematic
    case aggressive
    case conservative
    case documentary
}

struct HKV1_DirectorPolicyConfig {
    let holdMultiplier: CGFloat
    let switchSensitivity: CGFloat
    let reactionBias: CGFloat
    let continuityBias: CGFloat
    let motionTolerance: CGFloat
}

final class HKV1_DirectorPolicy {

    private(set) var style: HKV1_DirectorStyle = .cinematic

    func setStyle(_ style: HKV1_DirectorStyle) {
        self.style = style
    }

    func currentConfig() -> HKV1_DirectorPolicyConfig {
        switch style {
        case .cinematic:
            return HKV1_DirectorPolicyConfig(
                holdMultiplier: 1.0,
                switchSensitivity: 0.0,
                reactionBias: 0.18,
                continuityBias: 0.12,
                motionTolerance: 0.35
            )

        case .aggressive:
            return HKV1_DirectorPolicyConfig(
                holdMultiplier: 0.7,
                switchSensitivity: -0.06,
                reactionBias: 0.10,
                continuityBias: 0.05,
                motionTolerance: 0.55
            )

        case .conservative:
            return HKV1_DirectorPolicyConfig(
                holdMultiplier: 1.3,
                switchSensitivity: 0.08,
                reactionBias: 0.22,
                continuityBias: 0.20,
                motionTolerance: 0.25
            )

        case .documentary:
            return HKV1_DirectorPolicyConfig(
                holdMultiplier: 1.1,
                switchSensitivity: 0.02,
                reactionBias: 0.14,
                continuityBias: 0.16,
                motionTolerance: 0.40
            )
        }
    }
}
