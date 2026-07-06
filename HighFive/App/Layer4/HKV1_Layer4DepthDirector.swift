import Foundation
import CoreGraphics

final class HKV1_Layer4DepthDirector {
    enum Profile: String, Codable, CaseIterable {
        case safe119A
        case cinematicLift
        case volumetricSurge
        case hyperSafe
    }

    private(set) var profile: Profile = .safe119A

    func setProfile(_ profile: Profile) {
        self.profile = profile
    }

    func resolvePlaneIntent(
        snapshot: HKV1_Layer4StableSnapshot,
        depthOn: Bool
    ) -> HKV1_Layer4PlaneResidualIntent {
        guard depthOn else {
            return .neutral
        }

        let energy = HKV1_Layer4Math.clamp01(snapshot.depthEnergySafe)
        let health = HKV1_Layer4Math.clamp01(snapshot.layerHealth)
        let risk = HKV1_Layer4Math.clamp01(
            max(snapshot.bungeeRisk, max(snapshot.hingeRisk, snapshot.foldbackRiskX))
        )

        let riskGate = 1.0 - HKV1_Layer4Math.smootherstep(risk)
        let healthGate = HKV1_Layer4Math.smootherstep(health)
        let power = HKV1_Layer4Math.clamp01(energy * healthGate * riskGate)

        let lift = profileLift(profile)
        let safeLift = power * lift

        let global = HKV1_Layer4Math.mix(0.98, profileMaxGlobal(profile), safeLift)
        let bg = HKV1_Layer4Math.mix(0.985, profileBackgroundMax(profile), safeLift)
        let mid = HKV1_Layer4Math.mix(1.000, profileMidgroundMax(profile), safeLift)
        let fg = HKV1_Layer4Math.mix(1.015, profileForegroundMax(profile), safeLift)

        let reason: String
        if risk > profileRiskCeiling(profile) {
            reason = "risk gated"
        } else if health < profileHealthFloor(profile) {
            reason = "health gated"
        } else {
            reason = profile.rawValue
        }

        let intent = HKV1_Layer4PlaneResidualIntent(
            globalScalar: global,
            backgroundScalar: bg,
            midgroundScalar: mid,
            foregroundScalar: fg,
            depthEnergy: energy,
            layerHealth: health,
            risk: risk,
            reason: reason
        )

        if risk > profileRiskCeiling(profile) || health < profileHealthFloor(profile) {
            return HKV1_Layer4PlaneResidualIntent(
                globalScalar: min(global, 1.02),
                backgroundScalar: min(bg, 1.01),
                midgroundScalar: min(mid, 1.02),
                foregroundScalar: min(fg, 1.03),
                depthEnergy: energy,
                layerHealth: health,
                risk: risk,
                reason: reason
            ).clamped
        }

        return intent.clamped
    }

    private func profileLift(_ profile: Profile) -> CGFloat {
        switch profile {
        case .safe119A:
            return 0.72
        case .cinematicLift:
            return 0.86
        case .volumetricSurge:
            return 1.00
        case .hyperSafe:
            return 1.08
        }
    }

    private func profileMaxGlobal(_ profile: Profile) -> CGFloat {
        switch profile {
        case .safe119A:
            return 1.06
        case .cinematicLift:
            return 1.07
        case .volumetricSurge, .hyperSafe:
            return 1.08
        }
    }

    private func profileBackgroundMax(_ profile: Profile) -> CGFloat {
        switch profile {
        case .safe119A:
            return 1.025
        case .cinematicLift:
            return 1.035
        case .volumetricSurge:
            return 1.045
        case .hyperSafe:
            return 1.050
        }
    }

    private func profileMidgroundMax(_ profile: Profile) -> CGFloat {
        switch profile {
        case .safe119A:
            return 1.040
        case .cinematicLift:
            return 1.052
        case .volumetricSurge:
            return 1.064
        case .hyperSafe:
            return 1.070
        }
    }

    private func profileForegroundMax(_ profile: Profile) -> CGFloat {
        switch profile {
        case .safe119A:
            return 1.060
        case .cinematicLift:
            return 1.075
        case .volumetricSurge:
            return 1.090
        case .hyperSafe:
            return 1.100
        }
    }

    private func profileRiskCeiling(_ profile: Profile) -> CGFloat {
        switch profile {
        case .safe119A:
            return 0.62
        case .cinematicLift:
            return 0.54
        case .volumetricSurge:
            return 0.48
        case .hyperSafe:
            return 0.42
        }
    }

    private func profileHealthFloor(_ profile: Profile) -> CGFloat {
        switch profile {
        case .safe119A:
            return 0.18
        case .cinematicLift:
            return 0.26
        case .volumetricSurge:
            return 0.32
        case .hyperSafe:
            return 0.38
        }
    }
}
