import Foundation
import CoreGraphics

final class HKV1_ProMotionCoordinator {

    enum LensProfile {
        case natural
        case anamorphic
        case portrait
    }

    enum CameraPersonality: Int, CaseIterable {
        case cinematic
        case handheld
        case float
        case imax

        var responseScale: CGFloat {
            switch self {
            case .cinematic: return 1.00
            case .handheld: return 1.06
            case .float: return 0.96
            case .imax: return 1.12
            }
        }

        var travelScaleX: CGFloat {
            switch self {
            case .cinematic: return 1.08
            case .handheld: return 1.02
            case .float: return 0.98
            case .imax: return 1.22
            }
        }

        var travelScaleY: CGFloat {
            switch self {
            case .cinematic: return 1.00
            case .handheld: return 0.96
            case .float: return 0.94
            case .imax: return 1.08
            }
        }

        var stabilityBias: CGFloat {
            switch self {
            case .cinematic: return 0.00
            case .handheld: return -0.06
            case .float: return 0.06
            case .imax: return 0.08
            }
        }
    }

    private struct Tuning {
        static let defaultMaxDx: CGFloat = 140.0
        static let defaultMaxDy: CGFloat = 48.0
        static let verticalOutputScale: CGFloat = 0.92
    }

    private struct LaneMix {
        let tiltX: CGFloat
        let tiltY: CGFloat
        let peekX: CGFloat
        let peekY: CGFloat
    }

    private let motionService: HKV1_ProMotionService
    private let peekEngine: HKV1_ProPeekEngine

    var cameraPersonality: CameraPersonality = .cinematic

    private(set) var lastOutput = HKV1_ProMotionOutput(
        tiltDx: 0.0,
        tiltDy: 0.0,
        peekDx: 0.0,
        peekDy: 0.0,
        maxDx: Tuning.defaultMaxDx,
        maxDy: Tuning.defaultMaxDy,
        stability: 1.0
    )

    init(
        motionService: HKV1_ProMotionService = HKV1_ProMotionService(),
        peekEngine: HKV1_ProPeekEngine = HKV1_ProPeekEngine()
    ) {
        self.motionService = motionService
        self.peekEngine = peekEngine
    }

    func reset() {
        motionService.reset()
        peekEngine.reset()
        lastOutput = HKV1_ProMotionOutput(
            tiltDx: 0.0,
            tiltDy: 0.0,
            peekDx: 0.0,
            peekDy: 0.0,
            maxDx: Tuning.defaultMaxDx,
            maxDy: Tuning.defaultMaxDy,
            stability: 1.0
        )
    }

    func compute(
        roll: CGFloat,
        pitch: CGFloat,
        deltaTime: CGFloat,
        lensProfile: LensProfile,
        maxDx: CGFloat? = nil,
        maxDy: CGFloat? = nil
    ) -> HKV1_ProMotionOutput {
        compute(
            roll: roll,
            pitch: pitch,
            deltaTime: deltaTime,
            lensProfile: lensProfile,
            personality: cameraPersonality,
            maxDx: maxDx,
            maxDy: maxDy
        )
    }

    func compute(
        roll: CGFloat,
        pitch: CGFloat,
        deltaTime: CGFloat,
        lensProfile: LensProfile,
        personality: CameraPersonality,
        maxDx: CGFloat? = nil,
        maxDy: CGFloat? = nil
    ) -> HKV1_ProMotionOutput {
        let shaped = motionService.update(
            roll: roll,
            pitch: pitch,
            deltaTime: deltaTime,
            lensProfile: lensProfile
        )

        peekEngine.personality = mapPeekPersonality(from: personality)

        let peek = peekEngine.update(
            targetX: shaped.normalizedX,
            targetY: shaped.normalizedY,
            energy: shaped.energy,
            isActive: shaped.isActive,
            deltaTime: deltaTime,
            lensProfile: lensProfile
        )

        let lensTravel = travelMultipliers(for: lensProfile)
        let laneMix = laneMix(for: lensProfile, personality: personality)

        let resolvedMaxDx = Swift.max(1.0, (maxDx ?? Tuning.defaultMaxDx) * lensTravel.x * personality.travelScaleX)
        let resolvedMaxDy = Swift.max(1.0, (maxDy ?? Tuning.defaultMaxDy) * lensTravel.y * personality.travelScaleY)

        let energyBoost = 1.0 + (shaped.energy * 0.14)

        let tiltDx = shaped.normalizedX * resolvedMaxDx * laneMix.tiltX
        let tiltDy = shaped.normalizedY * resolvedMaxDy * Tuning.verticalOutputScale * laneMix.tiltY

        let peekDx = peek.normalizedDx * resolvedMaxDx * laneMix.peekX * energyBoost
        let peekDy = peek.normalizedDy * resolvedMaxDy * Tuning.verticalOutputScale * laneMix.peekY * Swift.min(1.10, energyBoost)

        let stability = stabilityScore(
            energy: shaped.energy,
            isActive: shaped.isActive,
            totalDx: tiltDx + peekDx,
            totalDy: tiltDy + peekDy,
            maxDx: resolvedMaxDx,
            maxDy: resolvedMaxDy,
            personality: personality
        )

        let output = HKV1_ProMotionOutput(
            tiltDx: tiltDx,
            tiltDy: tiltDy,
            peekDx: peekDx,
            peekDy: peekDy,
            maxDx: resolvedMaxDx,
            maxDy: resolvedMaxDy,
            stability: stability
        )

        lastOutput = output
        return output
    }

    private func laneMix(for lensProfile: LensProfile, personality: CameraPersonality) -> LaneMix {
        let response = personality.responseScale

        switch lensProfile {
        case .natural:
            return LaneMix(
                tiltX: 0.42 * response,
                tiltY: 0.38 * response,
                peekX: 0.54 * response,
                peekY: 0.46 * response
            )
        case .anamorphic:
            return LaneMix(
                tiltX: 0.46 * response,
                tiltY: 0.30 * response,
                peekX: 0.58 * response,
                peekY: 0.40 * response
            )
        case .portrait:
            return LaneMix(
                tiltX: 0.38 * response,
                tiltY: 0.24 * response,
                peekX: 0.50 * response,
                peekY: 0.32 * response
            )
        }
    }

    private func mapPeekPersonality(from personality: CameraPersonality) -> HKV1_ProPeekEngine.CameraPersonality {
        switch personality {
        case .cinematic:
            return .standard
        case .handheld:
            return .handheld
        case .float:
            return .float
        case .imax:
            return .imax
        }
    }

    private func travelMultipliers(for lensProfile: LensProfile) -> (x: CGFloat, y: CGFloat) {
        switch lensProfile {
        case .natural:
            return (x: 1.00, y: 1.00)
        case .anamorphic:
            return (x: 1.12, y: 0.86)
        case .portrait:
            return (x: 0.90, y: 0.78)
        }
    }

    private func stabilityScore(
        energy: CGFloat,
        isActive: Bool,
        totalDx: CGFloat,
        totalDy: CGFloat,
        maxDx: CGFloat,
        maxDy: CGFloat,
        personality: CameraPersonality
    ) -> CGFloat {
        let nx = maxDx > 0 ? abs(totalDx) / maxDx : 0.0
        let ny = maxDy > 0 ? abs(totalDy) / maxDy : 0.0
        let magnitude = Swift.min(1.0, hypot(nx, ny))
        let motionFactor = Swift.min(1.0, Swift.max(energy, magnitude))

        if !isActive && motionFactor < 0.02 {
            return Swift.min(1.0, 1.0 + personality.stabilityBias)
        }

        let score = 1.0 - (motionFactor * 0.55)
        return Swift.max(0.30, Swift.min(1.0, score + personality.stabilityBias))
    }
}
