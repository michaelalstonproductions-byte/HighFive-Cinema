import Foundation
import CoreGraphics
import UIKit

final class HKV1_Layer4PreviewDepthDirector {
    enum Profile: String, Codable, CaseIterable {
        case compact
        case theater
        case cinematic
        case hyperPreview
    }

    private(set) var profile: Profile = .theater

    func setProfile(_ profile: Profile) {
        self.profile = profile
    }

    func resolve(
        tiltX: CGFloat,
        tiltY: CGFloat,
        depthAvailable: Bool,
        layerHealth: CGFloat,
        bungeeRisk: CGFloat,
        hingeRisk: CGFloat,
        foldbackRisk: CGFloat,
        reduceMotion: Bool
    ) -> HKV1_Layer4PreviewEnvelope {
        if reduceMotion {
            return HKV1_Layer4PreviewEnvelope(
                stageOffset: .zero,
                globalPlaneScalar: 1.0,
                backgroundScalar: 1.0,
                midgroundScalar: 1.0,
                foregroundScalar: 1.0,
                uiDepthAmount: 0.28,
                depthEnergy: 0.0,
                health: layerHealth,
                risk: 0.0,
                depthAvailable: depthAvailable,
                reduceMotion: true,
                reason: "reduce motion"
            ).clamped
        }

        let safeTiltX = HKV1_Layer4Math.clamp(tiltX, -1.0, 1.0)
        let safeTiltY = HKV1_Layer4Math.clamp(tiltY, -1.0, 1.0)

        let risk = HKV1_Layer4Math.clamp01(max(bungeeRisk, max(hingeRisk, foldbackRisk)))
        let health = HKV1_Layer4Math.clamp01(layerHealth)

        let profileRiskCeiling = riskCeiling(profile)
        let profileHealthFloor = healthFloor(profile)

        let riskGate = 1.0 - HKV1_Layer4Math.smootherstep(risk / max(profileRiskCeiling, 0.001))
        let healthGate = HKV1_Layer4Math.smootherstep(health)
        let depthGate: CGFloat = depthAvailable ? 1.0 : 0.58

        let tiltEnergy = HKV1_Layer4Math.clamp01(hypot(safeTiltX, safeTiltY))
        let power = HKV1_Layer4Math.clamp01(
            tiltEnergy *
            max(0.0, riskGate) *
            healthGate *
            depthGate
        )

        let travel = stageTravel(profile)
        let stageOffset = CGPoint(
            x: safeTiltX * travel.x * power,
            y: safeTiltY * travel.y * power
        )

        let lift = profileLift(profile)
        let depthEnergy = power * lift

        let reason: String
        if risk > profileRiskCeiling {
            reason = "risk gated"
        } else if health < profileHealthFloor {
            reason = "health gated"
        } else if depthAvailable {
            reason = profile.rawValue
        } else {
            reason = "ui-depth fallback"
        }

        let global = HKV1_Layer4Math.mix(0.995, 1.075, depthEnergy)
        let bg = HKV1_Layer4Math.mix(0.996, 1.026, depthEnergy)
        let mid = HKV1_Layer4Math.mix(1.000, 1.058, depthEnergy)
        let fg = HKV1_Layer4Math.mix(1.012, 1.108, depthEnergy)

        let uiDepth = depthAvailable
            ? HKV1_Layer4Math.mix(0.34, 0.78, depthEnergy)
            : HKV1_Layer4Math.mix(0.22, 0.52, depthEnergy)

        return HKV1_Layer4PreviewEnvelope(
            stageOffset: stageOffset,
            globalPlaneScalar: global,
            backgroundScalar: bg,
            midgroundScalar: mid,
            foregroundScalar: fg,
            uiDepthAmount: uiDepth,
            depthEnergy: depthEnergy,
            health: health,
            risk: risk,
            depthAvailable: depthAvailable,
            reduceMotion: false,
            reason: reason
        ).clamped
    }

    private func stageTravel(_ profile: Profile) -> CGPoint {
        switch profile {
        case .compact:
            return CGPoint(x: 12, y: 7)
        case .theater:
            return CGPoint(x: 18, y: 10)
        case .cinematic:
            return CGPoint(x: 22, y: 12)
        case .hyperPreview:
            return CGPoint(x: 32, y: 18)
        }
    }

    private func profileLift(_ profile: Profile) -> CGFloat {
        switch profile {
        case .compact:
            return 0.62
        case .theater:
            return 0.78
        case .cinematic:
            return 0.92
        case .hyperPreview:
            return 1.00
        }
    }

    private func riskCeiling(_ profile: Profile) -> CGFloat {
        switch profile {
        case .compact:
            return 0.64
        case .theater:
            return 0.56
        case .cinematic:
            return 0.48
        case .hyperPreview:
            return 0.40
        }
    }

    private func healthFloor(_ profile: Profile) -> CGFloat {
        switch profile {
        case .compact:
            return 0.12
        case .theater:
            return 0.20
        case .cinematic:
            return 0.28
        case .hyperPreview:
            return 0.36
        }
    }
}
