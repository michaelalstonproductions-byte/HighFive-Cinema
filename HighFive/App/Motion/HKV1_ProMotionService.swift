import Foundation
import CoreGraphics

final class HKV1_ProMotionService {

    struct Sample {
        let normalizedX: CGFloat
        let normalizedY: CGFloat
        let energy: CGFloat
        let isActive: Bool
    }

    private struct AxisTuning {
        let inputLimit: CGFloat
        let centerGate: CGFloat
        let centerSoftness: CGFloat
        let exponentNear: CGFloat
        let exponentFar: CGFloat
        let gain: CGFloat
        let velocityLimitPerSecond: CGFloat
    }

    private struct LensTuning {
        let baseTiltResponse: CGFloat
        let fastTiltResponse: CGFloat
        let settleTiltResponse: CGFloat
        let energySmoothingResponse: CGFloat
        let hardTiltCompressionStart: CGFloat
        let hardTiltCompressionAmount: CGFloat
        let activityEpsilon: CGFloat
        let x: AxisTuning
        let y: AxisTuning
    }

    private var filteredRoll: CGFloat = 0.0
    private var filteredPitch: CGFloat = 0.0
    private var filteredEnergy: CGFloat = 0.0

    private var lastFilteredRoll: CGFloat = 0.0
    private var lastFilteredPitch: CGFloat = 0.0

    private var lastRawRoll: CGFloat = 0.0
    private var lastRawPitch: CGFloat = 0.0

    private var hasPrimed = false

    func reset() {
        filteredRoll = 0.0
        filteredPitch = 0.0
        filteredEnergy = 0.0
        lastFilteredRoll = 0.0
        lastFilteredPitch = 0.0
        lastRawRoll = 0.0
        lastRawPitch = 0.0
        hasPrimed = false
    }

    func update(
        roll: CGFloat,
        pitch: CGFloat,
        deltaTime: CGFloat,
        lensProfile: HKV1_ProMotionCoordinator.LensProfile
    ) -> Sample {
        let tuning = tuning(for: lensProfile)
        let dt = max(1.0 / 240.0, min(deltaTime, 1.0 / 20.0))

        if !hasPrimed {
            filteredRoll = roll
            filteredPitch = pitch
            lastFilteredRoll = roll
            lastFilteredPitch = pitch
            lastRawRoll = roll
            lastRawPitch = pitch
            hasPrimed = true
        }

        let rawDeltaRoll = abs(roll - lastRawRoll)
        let rawDeltaPitch = abs(pitch - lastRawPitch)
        lastRawRoll = roll
        lastRawPitch = pitch

        let inputVelocityX = rawDeltaRoll / max(dt, 0.0001)
        let inputVelocityY = rawDeltaPitch / max(dt, 0.0001)
        let inputVelocity = max(inputVelocityX, inputVelocityY)

        let currentMagnitude = max(abs(filteredRoll), abs(filteredPitch))
        let isSettlingTowardCenter = currentMagnitude < 0.08 && inputVelocity < 0.14
        let fastMotionBlend = clamp(inputVelocity / 2.0, 0.0, 1.0)

        let adaptiveResponse = mix(tuning.baseTiltResponse, tuning.fastTiltResponse, alpha: fastMotionBlend)
        let chosenResponse = isSettlingTowardCenter ? tuning.settleTiltResponse : adaptiveResponse
        let tiltAlpha = smoothingAlpha(response: chosenResponse, dt: dt)

        // Continuous through center: gate is effectively removed by tuning,
        // and this helper now preserves motion continuity.
        let targetRoll = continuousCenterInput(
            roll,
            gate: tuning.x.centerGate,
            softness: tuning.x.centerSoftness
        )
        let targetPitch = continuousCenterInput(
            pitch,
            gate: tuning.y.centerGate,
            softness: tuning.y.centerSoftness
        )

        filteredRoll = mix(filteredRoll, targetRoll, alpha: tiltAlpha)
        filteredPitch = mix(filteredPitch, targetPitch, alpha: tiltAlpha)

        filteredRoll = applyVelocityLimit(
            current: lastFilteredRoll,
            proposed: filteredRoll,
            maxUnitsPerSecond: tuning.x.velocityLimitPerSecond,
            dt: dt
        )

        filteredPitch = applyVelocityLimit(
            current: lastFilteredPitch,
            proposed: filteredPitch,
            maxUnitsPerSecond: tuning.y.velocityLimitPerSecond,
            dt: dt
        )

        let limitedRoll = clamp(filteredRoll, -tuning.x.inputLimit, tuning.x.inputLimit)
        let limitedPitch = clamp(filteredPitch, -tuning.y.inputLimit, tuning.y.inputLimit)

        let shapedX = shapeAxis(limitedRoll, axis: tuning.x)
        let shapedY = shapeAxis(limitedPitch, axis: tuning.y)

        let compressedX = compressHardTilt(
            shapedX,
            start: tuning.hardTiltCompressionStart,
            amount: tuning.hardTiltCompressionAmount
        )
        let compressedY = compressHardTilt(
            shapedY,
            start: tuning.hardTiltCompressionStart,
            amount: tuning.hardTiltCompressionAmount
        )

        let velocityX = abs(filteredRoll - lastFilteredRoll) / max(dt, 0.0001)
        let velocityY = abs(filteredPitch - lastFilteredPitch) / max(dt, 0.0001)

        lastFilteredRoll = filteredRoll
        lastFilteredPitch = filteredPitch

        let positionalEnergy = max(abs(compressedX), abs(compressedY))
        let kineticEnergy = clamp(max(velocityX * 0.20, velocityY * 0.28), 0.0, 1.0)
        let rawEnergy = clamp((positionalEnergy * 0.80) + (kineticEnergy * 0.20), 0.0, 1.0)

        let energyAlpha = smoothingAlpha(response: tuning.energySmoothingResponse, dt: dt)
        filteredEnergy = mix(filteredEnergy, rawEnergy, alpha: energyAlpha)

        var finalX = clamp(compressedX, -1.0, 1.0)
        var finalY = clamp(compressedY, -1.0, 1.0)
        let finalEnergy = clamp(filteredEnergy, 0.0, 1.0)

        // Softer center handling so the signal never feels hinged.
        if abs(finalX) < 0.0018 && finalEnergy < 0.006 { finalX *= 0.5 }
        if abs(finalY) < 0.0016 && finalEnergy < 0.006 { finalY *= 0.5 }

        return Sample(
            normalizedX: finalX,
            normalizedY: finalY,
            energy: finalEnergy,
            isActive: rawEnergy > tuning.activityEpsilon || max(abs(finalX), abs(finalY)) > 0.006
        )
    }

    private func tuning(for lensProfile: HKV1_ProMotionCoordinator.LensProfile) -> LensTuning {
        switch lensProfile {
        case .natural:
            return LensTuning(
                baseTiltResponse: 5.2,
                fastTiltResponse: 7.2,
                settleTiltResponse: 3.8,
                energySmoothingResponse: 4.0,
                hardTiltCompressionStart: 0.46,
                hardTiltCompressionAmount: 0.20,
                activityEpsilon: 0.0018,
                x: AxisTuning(
                    inputLimit: 0.84,
                    centerGate: 0.000,
                    centerSoftness: 0.000,
                    exponentNear: 1.00,
                    exponentFar: 1.05,
                    gain: 0.94,
                    velocityLimitPerSecond: 2.30
                ),
                y: AxisTuning(
                    inputLimit: 0.62,
                    centerGate: 0.000,
                    centerSoftness: 0.000,
                    exponentNear: 1.00,
                    exponentFar: 1.06,
                    gain: 0.28,
                    velocityLimitPerSecond: 1.70
                )
            )

        case .anamorphic:
            return LensTuning(
                baseTiltResponse: 5.4,
                fastTiltResponse: 7.4,
                settleTiltResponse: 4.0,
                energySmoothingResponse: 4.0,
                hardTiltCompressionStart: 0.44,
                hardTiltCompressionAmount: 0.18,
                activityEpsilon: 0.0017,
                x: AxisTuning(
                    inputLimit: 0.82,
                    centerGate: 0.000,
                    centerSoftness: 0.000,
                    exponentNear: 1.00,
                    exponentFar: 1.05,
                    gain: 0.98,
                    velocityLimitPerSecond: 2.45
                ),
                y: AxisTuning(
                    inputLimit: 0.58,
                    centerGate: 0.000,
                    centerSoftness: 0.000,
                    exponentNear: 1.00,
                    exponentFar: 1.06,
                    gain: 0.22,
                    velocityLimitPerSecond: 1.45
                )
            )

        case .portrait:
            return LensTuning(
                baseTiltResponse: 5.0,
                fastTiltResponse: 6.8,
                settleTiltResponse: 3.6,
                energySmoothingResponse: 4.1,
                hardTiltCompressionStart: 0.40,
                hardTiltCompressionAmount: 0.20,
                activityEpsilon: 0.0019,
                x: AxisTuning(
                    inputLimit: 0.78,
                    centerGate: 0.000,
                    centerSoftness: 0.000,
                    exponentNear: 1.00,
                    exponentFar: 1.05,
                    gain: 0.88,
                    velocityLimitPerSecond: 2.10
                ),
                y: AxisTuning(
                    inputLimit: 0.54,
                    centerGate: 0.000,
                    centerSoftness: 0.000,
                    exponentNear: 1.00,
                    exponentFar: 1.06,
                    gain: 0.18,
                    velocityLimitPerSecond: 1.25
                )
            )
        }
    }

    private func shapeAxis(_ value: CGFloat, axis: AxisTuning) -> CGFloat {
        let sign: CGFloat = value < 0 ? -1.0 : 1.0
        let magnitude = abs(value)
        guard magnitude > 0 else { return 0.0 }

        let limited = clamp(magnitude / max(axis.inputLimit, 0.0001), 0.0, 1.0)

        // Keep it nearly linear near center so there is no hinge.
        let exponent = axis.exponentNear + ((axis.exponentFar - axis.exponentNear) * limited)
        let softened = pow(limited, exponent) * axis.gain

        return sign * softened
    }

    private func continuousCenterInput(_ value: CGFloat, gate: CGFloat, softness: CGFloat) -> CGFloat {
        let sign: CGFloat = value < 0 ? -1.0 : 1.0
        let magnitude = abs(value)
        guard magnitude > 0 else { return 0.0 }

        // With gate/softness at zero this becomes continuous/linear through center.
        if gate <= 0.0001 && softness <= 0.0001 {
            return value
        }

        if magnitude <= gate {
            return sign * (magnitude * (1.0 - softness))
        }

        let restored = (magnitude - gate) / max(0.0001, 1.0 - gate)
        let softened = restored * (1.0 - softness + (restored * softness))
        let continuous = gate + (softened * (1.0 - gate))
        return sign * continuous
    }

    private func compressHardTilt(_ value: CGFloat, start: CGFloat, amount: CGFloat) -> CGFloat {
        let sign: CGFloat = value < 0 ? -1.0 : 1.0
        let magnitude = abs(value)
        guard magnitude > start else { return value }

        let extra = magnitude - start
        return sign * (start + (extra * (1.0 - amount)))
    }

    private func applyVelocityLimit(
        current: CGFloat,
        proposed: CGFloat,
        maxUnitsPerSecond: CGFloat,
        dt: CGFloat
    ) -> CGFloat {
        let maxStep = maxUnitsPerSecond * dt
        let delta = proposed - current

        if delta > maxStep { return current + maxStep }
        if delta < -maxStep { return current - maxStep }
        return proposed
    }

    private func smoothingAlpha(response: CGFloat, dt: CGFloat) -> CGFloat {
        1.0 - exp(-response * dt)
    }

    private func mix(_ a: CGFloat, _ b: CGFloat, alpha: CGFloat) -> CGFloat {
        a + ((b - a) * alpha)
    }

    private func clamp(_ value: CGFloat, _ minValue: CGFloat, _ maxValue: CGFloat) -> CGFloat {
        min(max(value, minValue), maxValue)
    }
}
