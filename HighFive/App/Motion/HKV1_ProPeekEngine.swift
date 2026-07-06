import Foundation
import CoreGraphics

final class HKV1_ProPeekEngine {

    enum CameraPersonality: Int {
        case standard = 0
        case imax = 1
        case handheld = 2
        case float = 3
    }

    struct Output {
        let normalizedDx: CGFloat
        let normalizedDy: CGFloat
        let isAtRest: Bool
    }

    private struct AxisTuning {
        let followStrength: CGFloat
        let damping: CGFloat
        let energyBoost: CGFloat
        let maxNormalized: CGFloat
        let maxVelocityPerSecond: CGFloat
        let restPositionThreshold: CGFloat
        let restTargetThreshold: CGFloat
        let restVelocityThreshold: CGFloat
    }

    private struct LensTuning {
        let x: AxisTuning
        let y: AxisTuning
        let verticalWeight: CGFloat
    }

    private var positionX: CGFloat = 0.0
    private var positionY: CGFloat = 0.0
    private var velocityX: CGFloat = 0.0
    private var velocityY: CGFloat = 0.0

    var personality: CameraPersonality = .standard

    func reset() {
        positionX = 0.0
        positionY = 0.0
        velocityX = 0.0
        velocityY = 0.0
    }

    func update(
        targetX: CGFloat,
        targetY: CGFloat,
        energy: CGFloat,
        isActive: Bool,
        deltaTime: CGFloat,
        lensProfile: HKV1_ProMotionCoordinator.LensProfile
    ) -> Output {

        let base = tuning(for: lensProfile)
        let tuned = applyPersonality(base)

        let dt = max(1.0 / 240.0, min(deltaTime, 1.0 / 20.0))
        let clampedEnergy = clamp(energy, 0.0, 1.0)

        let desiredX = clamp(targetX, -tuned.x.maxNormalized, tuned.x.maxNormalized)
        let desiredY = clamp(targetY * tuned.verticalWeight, -tuned.y.maxNormalized, tuned.y.maxNormalized)

        let xState = updateAxis(
            current: positionX,
            velocity: velocityX,
            desired: desiredX,
            axis: tuned.x,
            energy: clampedEnergy,
            dt: dt
        )

        let yState = updateAxis(
            current: positionY,
            velocity: velocityY,
            desired: desiredY,
            axis: tuned.y,
            energy: clampedEnergy,
            dt: dt
        )

        positionX = xState.position
        velocityX = xState.velocity
        positionY = yState.position
        velocityY = yState.velocity

        let resting =
            !isActive &&
            abs(positionX) < tuned.x.restPositionThreshold &&
            abs(positionY) < tuned.y.restPositionThreshold &&
            abs(desiredX) < tuned.x.restTargetThreshold &&
            abs(desiredY) < tuned.y.restTargetThreshold &&
            abs(velocityX) < tuned.x.restVelocityThreshold &&
            abs(velocityY) < tuned.y.restVelocityThreshold

        if resting {
            positionX *= 0.96
            positionY *= 0.96
            velocityX *= 0.78
            velocityY *= 0.78

            if abs(positionX) < 0.0004 { positionX = 0.0 }
            if abs(positionY) < 0.0004 { positionY = 0.0 }
            if abs(velocityX) < 0.0003 { velocityX = 0.0 }
            if abs(velocityY) < 0.0003 { velocityY = 0.0 }
        }

        return Output(normalizedDx: positionX, normalizedDy: positionY, isAtRest: resting)
    }

    private func updateAxis(
        current: CGFloat,
        velocity: CGFloat,
        desired: CGFloat,
        axis: AxisTuning,
        energy: CGFloat,
        dt: CGFloat
    ) -> (position: CGFloat, velocity: CGFloat) {
        let boostedFollow = axis.followStrength + (energy * axis.energyBoost)
        let error = desired - current
        let acceleration = (error * boostedFollow) - (velocity * axis.damping)

        var nextVelocity = velocity + (acceleration * dt)
        nextVelocity = clamp(nextVelocity, -axis.maxVelocityPerSecond, axis.maxVelocityPerSecond)

        var nextPosition = current + (nextVelocity * dt)
        nextPosition = clamp(nextPosition, -axis.maxNormalized, axis.maxNormalized)

        if abs(nextPosition) >= axis.maxNormalized {
            nextVelocity = 0.0
        }

        return (nextPosition, nextVelocity)
    }

    private func tuning(for lensProfile: HKV1_ProMotionCoordinator.LensProfile) -> LensTuning {
        switch lensProfile {
        case .natural:
            return LensTuning(
                x: AxisTuning(
                    followStrength: 22.0,
                    damping: 20.0,
                    energyBoost: 2.8,
                    maxNormalized: 0.82,
                    maxVelocityPerSecond: 2.2,
                    restPositionThreshold: 0.0022,
                    restTargetThreshold: 0.0022,
                    restVelocityThreshold: 0.0032
                ),
                y: AxisTuning(
                    followStrength: 18.0,
                    damping: 18.5,
                    energyBoost: 2.3,
                    maxNormalized: 0.46,
                    maxVelocityPerSecond: 1.35,
                    restPositionThreshold: 0.0022,
                    restTargetThreshold: 0.0022,
                    restVelocityThreshold: 0.0032
                ),
                verticalWeight: 0.42
            )
        case .anamorphic:
            return LensTuning(
                x: AxisTuning(
                    followStrength: 23.0,
                    damping: 20.5,
                    energyBoost: 2.9,
                    maxNormalized: 0.82,
                    maxVelocityPerSecond: 2.3,
                    restPositionThreshold: 0.0022,
                    restTargetThreshold: 0.0022,
                    restVelocityThreshold: 0.0032
                ),
                y: AxisTuning(
                    followStrength: 17.0,
                    damping: 18.8,
                    energyBoost: 2.1,
                    maxNormalized: 0.36,
                    maxVelocityPerSecond: 1.10,
                    restPositionThreshold: 0.0022,
                    restTargetThreshold: 0.0022,
                    restVelocityThreshold: 0.0032
                ),
                verticalWeight: 0.30
            )
        case .portrait:
            return LensTuning(
                x: AxisTuning(
                    followStrength: 21.0,
                    damping: 19.6,
                    energyBoost: 2.6,
                    maxNormalized: 0.78,
                    maxVelocityPerSecond: 2.0,
                    restPositionThreshold: 0.0022,
                    restTargetThreshold: 0.0022,
                    restVelocityThreshold: 0.0032
                ),
                y: AxisTuning(
                    followStrength: 15.5,
                    damping: 18.5,
                    energyBoost: 2.0,
                    maxNormalized: 0.28,
                    maxVelocityPerSecond: 0.95,
                    restPositionThreshold: 0.0022,
                    restTargetThreshold: 0.0022,
                    restVelocityThreshold: 0.0032
                ),
                verticalWeight: 0.24
            )
        }
    }

    private func applyPersonality(_ base: LensTuning) -> LensTuning {
        switch personality {
        case .standard:
            return base
        case .imax:
            return LensTuning(
                x: scale(base.x, follow: 1.04, damping: 1.03),
                y: scale(base.y, follow: 1.02, damping: 1.03),
                verticalWeight: base.verticalWeight
            )
        case .handheld:
            return LensTuning(
                x: scale(base.x, follow: 1.03, damping: 0.98),
                y: scale(base.y, follow: 1.02, damping: 0.98),
                verticalWeight: base.verticalWeight * 0.96
            )
        case .float:
            return LensTuning(
                x: scale(base.x, follow: 0.94, damping: 1.08),
                y: scale(base.y, follow: 0.92, damping: 1.10),
                verticalWeight: base.verticalWeight * 1.02
            )
        }
    }

    private func scale(_ axis: AxisTuning, follow: CGFloat, damping: CGFloat) -> AxisTuning {
        AxisTuning(
            followStrength: axis.followStrength * follow,
            damping: axis.damping * damping,
            energyBoost: axis.energyBoost,
            maxNormalized: axis.maxNormalized,
            maxVelocityPerSecond: axis.maxVelocityPerSecond,
            restPositionThreshold: axis.restPositionThreshold,
            restTargetThreshold: axis.restTargetThreshold,
            restVelocityThreshold: axis.restVelocityThreshold
        )
    }

    private func clamp(_ value: CGFloat, _ minValue: CGFloat, _ maxValue: CGFloat) -> CGFloat {
        min(max(value, minValue), maxValue)
    }
}
