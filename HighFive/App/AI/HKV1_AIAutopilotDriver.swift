import Foundation
import CoreGraphics

final class HKV1_AIAutopilotDriver {

    struct Output {
        let target: CGPoint
        let smoothed: CGPoint
        let subjectVelocityX: CGFloat
        let thirdsBiasX: CGFloat
        let cameraMotionBiasX: CGFloat
    }

    private var previousSubjectCenterX: CGFloat?
    private var previousSubjectCenterY: CGFloat?
    private var smoothedSubjectCenterX: CGFloat?
    private var smoothedSubjectCenterY: CGFloat?
    private var smoothedSubjectVelocityX: CGFloat = 0

    private var thirdsBiasX: CGFloat = 0
    private var cameraMotionBiasX: CGFloat = 0

    private var filteredTarget: CGPoint = .zero
    private var smoothedStage: CGPoint = .zero

    private var stableLockFrames: Int = 0
    private var lastResolvedRect: CGRect?

    func reset() {
        previousSubjectCenterX = nil
        previousSubjectCenterY = nil
        smoothedSubjectCenterX = nil
        smoothedSubjectCenterY = nil
        smoothedSubjectVelocityX = 0
        thirdsBiasX = 0
        cameraMotionBiasX = 0
        filteredTarget = .zero
        smoothedStage = .zero
        stableLockFrames = 0
        lastResolvedRect = nil
    }

    func step(
        resolvedRect: CGRect?,
        lockConfidence: CGFloat,
        heroY: CGFloat,
        maxDx: CGFloat,
        maxDy: CGFloat,
        dt: CGFloat,
        lostTrackFrames: Int,
        lowLightBias: Bool
    ) -> Output {
        guard maxDx > 0.001, maxDy > 0.001 else {
            filteredTarget = .zero
            smoothedStage = .zero
            return Output(
                target: .zero,
                smoothed: .zero,
                subjectVelocityX: 0,
                thirdsBiasX: 0,
                cameraMotionBiasX: 0
            )
        }

        let isSameSubject: Bool = {
            guard let prev = lastResolvedRect, let current = resolvedRect else { return false }
            return rectIOU(prev, current) > (lowLightBias ? 0.28 : 0.35)
        }()

        if let current = resolvedRect {
            if isSameSubject {
                stableLockFrames += 1
            } else {
                stableLockFrames = 0
            }
            lastResolvedRect = current
        } else {
            stableLockFrames = 0
            lastResolvedRect = nil
        }

        let stability = clamp(CGFloat(stableLockFrames) / (lowLightBias ? 16.0 : 12.0), min: 0.0, max: 1.0)
        let confidence = max(lockConfidence, lowLightBias ? 0.32 : 0.25)
        let authority = confidence * (lowLightBias ? (0.28 + (stability * 0.60)) : (0.35 + (stability * 0.65)))

        let rawTarget: CGPoint

        if let rect = resolvedRect {
            let rawSubjectCenterX = rect.midX
            let rawVisualCenterY = rect.midY
            let rawSubjectCenterY = 1.0 - rawVisualCenterY
            let subjectArea = rect.width * rect.height

            let centerAlphaX: CGFloat = lowLightBias ? (0.11 + (stability * 0.13)) : (0.16 + (stability * 0.20))
            let centerAlphaY: CGFloat = lowLightBias ? (0.10 + (stability * 0.12)) : (0.14 + (stability * 0.18))

            if let existingX = smoothedSubjectCenterX {
                smoothedSubjectCenterX = existingX + ((rawSubjectCenterX - existingX) * centerAlphaX)
            } else {
                smoothedSubjectCenterX = rawSubjectCenterX
            }

            if let existingY = smoothedSubjectCenterY {
                smoothedSubjectCenterY = existingY + ((rawSubjectCenterY - existingY) * centerAlphaY)
            } else {
                smoothedSubjectCenterY = rawSubjectCenterY
            }

            let subjectCenterX = smoothedSubjectCenterX ?? rawSubjectCenterX
            let subjectCenterY = smoothedSubjectCenterY ?? rawSubjectCenterY

            let closeUpLock = clamp((subjectArea - 0.045) / 0.22, min: 0.0, max: 1.0)
            let wideFactor = 1.0 - closeUpLock

            let rawVelocityX: CGFloat
            if let previousX = previousSubjectCenterX {
                rawVelocityX = subjectCenterX - previousX
            } else {
                rawVelocityX = 0.0
            }
            previousSubjectCenterX = subjectCenterX
            previousSubjectCenterY = subjectCenterY

            let velocityDelta = rawVelocityX - smoothedSubjectVelocityX
            if abs(velocityDelta) < (lowLightBias ? 0.0018 : 0.0012) {
                smoothedSubjectVelocityX *= (lowLightBias ? 0.975 : 0.965)
            } else {
                smoothedSubjectVelocityX += velocityDelta * (lowLightBias ? 0.10 : 0.16)
            }

            let normalizedVelocityX = clamp(
                smoothedSubjectVelocityX * (lowLightBias ? 6.8 : 9.0),
                min: -1.0,
                max: 1.0
            )

            let xTravelBase = maxDx * ((lowLightBias ? 0.72 : 0.82) - (closeUpLock * (lowLightBias ? 0.08 : 0.10)))
            let xTravel = xTravelBase * (lowLightBias ? 0.92 : 1.0)
            let yTravel = maxDy * ((lowLightBias ? 0.44 : 0.48) - (closeUpLock * (lowLightBias ? 0.04 : 0.05)))

            let centerErrorX = 0.5 - subjectCenterX
            let centerErrorY = heroY - subjectCenterY

            let centeredX = centerErrorX * xTravel * (lowLightBias ? (1.84 + (wideFactor * 0.24)) : (2.20 + (wideFactor * 0.38)))

            let desiredThirdsBias =
                -normalizedVelocityX *
                xTravel *
                (lowLightBias ? 0.038 : 0.058) *
                authority

            let thirdsDelta = desiredThirdsBias - thirdsBiasX
            thirdsBiasX += thirdsDelta * (lowLightBias ? 0.045 : 0.07)

            let desiredCameraMotionBias =
                -normalizedVelocityX *
                xTravel *
                (lowLightBias ? 0.014 : 0.024) *
                authority

            let camDelta = desiredCameraMotionBias - cameraMotionBiasX
            cameraMotionBiasX += camDelta * (lowLightBias ? 0.032 : 0.05)

            let leadRoomX =
                normalizedVelocityX *
                xTravel *
                (lowLightBias ? 0.042 : 0.082) *
                authority

            var targetX = centeredX + thirdsBiasX + leadRoomX + cameraMotionBiasX
            var targetY = centerErrorY * yTravel * (lowLightBias ? (0.94 + (closeUpLock * 0.08)) : (1.05 + (closeUpLock * 0.10)))

            let aiStrengthX: CGFloat = lowLightBias ? 0.28 : 0.40
            let aiStrengthY: CGFloat = lowLightBias ? 0.20 : 0.25
            targetX *= aiStrengthX
            targetY *= aiStrengthY

            targetX = softenedCenter(targetX, width: max(0.75, xTravel * (lowLightBias ? 0.09 : 0.07)))
            targetY = softenedCenter(targetY, width: max(0.45, yTravel * 0.08))

            let edgeThresholdX: CGFloat = 0.14
            let edgeThresholdY: CGFloat = 0.14

            if subjectCenterX < edgeThresholdX {
                targetX += (edgeThresholdX - subjectCenterX) * xTravel * (lowLightBias ? 0.82 : 0.98)
            } else if subjectCenterX > (1.0 - edgeThresholdX) {
                targetX -= (subjectCenterX - (1.0 - edgeThresholdX)) * xTravel * (lowLightBias ? 0.82 : 0.98)
            }

            if subjectCenterY < edgeThresholdY {
                targetY += (edgeThresholdY - subjectCenterY) * yTravel * (lowLightBias ? 0.34 : 0.40)
            } else if subjectCenterY > (1.0 - edgeThresholdY) {
                targetY -= (subjectCenterY - (1.0 - edgeThresholdY)) * yTravel * (lowLightBias ? 0.34 : 0.40)
            }

            rawTarget = CGPoint(
                x: clamp(targetX, min: -xTravel, max: xTravel),
                y: clamp(targetY, min: -yTravel, max: yTravel)
            )
        } else {
            previousSubjectCenterX = nil
            previousSubjectCenterY = nil
            smoothedSubjectCenterX = nil
            smoothedSubjectCenterY = nil
            smoothedSubjectVelocityX *= lowLightBias ? 0.94 : 0.90
            thirdsBiasX *= lowLightBias ? 0.985 : 0.97
            cameraMotionBiasX *= lowLightBias ? 0.98 : 0.96

            let decayX: CGFloat = lostTrackFrames < (lowLightBias ? 12 : 8) ? 0.985 : 0.94
            let decayY: CGFloat = lostTrackFrames < (lowLightBias ? 12 : 8) ? 0.985 : 0.93

            rawTarget = CGPoint(
                x: filteredTarget.x * decayX,
                y: filteredTarget.y * decayY
            )
        }

        let unclampedJumpX = rawTarget.x - filteredTarget.x
        let unclampedJumpY = rawTarget.y - filteredTarget.y

        let maxJumpX = maxDx * ((lowLightBias ? 0.018 : 0.028) + (stability * 0.016))
        let maxJumpY = maxDy * ((lowLightBias ? 0.012 : 0.016) + (stability * (lowLightBias ? 0.008 : 0.010)))

        let targetJumpX = clamp(unclampedJumpX, min: -maxJumpX, max: maxJumpX)
        let targetJumpY = clamp(unclampedJumpY, min: -maxJumpY, max: maxJumpY)

        let stabilityAlphaX: CGFloat = (lowLightBias ? 0.052 : 0.07) + (stability * (lowLightBias ? 0.10 : 0.16))
        let stabilityAlphaY: CGFloat = (lowLightBias ? 0.058 : 0.07) + (stability * (lowLightBias ? 0.09 : 0.14))

        filteredTarget.x += targetJumpX * stabilityAlphaX
        filteredTarget.y += targetJumpY * stabilityAlphaY

        let responseX: CGFloat = resolvedRect != nil
            ? (lowLightBias ? (2.9 + (stability * 0.70)) : (4.0 + (stability * 1.05)))
            : (lowLightBias ? 1.8 : 2.0)
        let responseY: CGFloat = resolvedRect != nil
            ? (lowLightBias ? (2.7 + (stability * 0.78)) : (3.1 + (stability * 0.92)))
            : (lowLightBias ? 1.7 : 1.9)

        let alphaX = 1.0 - exp(-responseX * dt)
        let alphaY = 1.0 - exp(-responseY * dt)

        let nextStageX = smoothedStage.x + ((filteredTarget.x - smoothedStage.x) * alphaX)
        let nextStageY = smoothedStage.y + ((filteredTarget.y - smoothedStage.y) * alphaY)

        let maxStageStepX = maxDx * ((lowLightBias ? 0.010 : 0.013) + (stability * (lowLightBias ? 0.007 : 0.010)))
        let maxStageStepY = maxDy * ((lowLightBias ? 0.014 : 0.016) + (stability * (lowLightBias ? 0.008 : 0.010)))

        smoothedStage.x = limitStep(from: smoothedStage.x, to: nextStageX, maxDelta: maxStageStepX)
        smoothedStage.y = limitStep(from: smoothedStage.y, to: nextStageY, maxDelta: maxStageStepY)

        let softCenterX = max(lowLightBias ? 0.08 : 0.05, maxDx * (lowLightBias ? 0.0014 : 0.0010))
        let softCenterY = max(lowLightBias ? 0.09 : 0.08, maxDy * (lowLightBias ? 0.0020 : 0.0018))

        if abs(smoothedStage.x) < softCenterX {
            smoothedStage.x *= 0.55
        }
        if abs(smoothedStage.y) < softCenterY {
            smoothedStage.y *= 0.55
        }

        if abs(smoothedStage.x) < 0.01 { smoothedStage.x = 0 }
        if abs(smoothedStage.y) < 0.01 { smoothedStage.y = 0 }

        return Output(
            target: filteredTarget,
            smoothed: smoothedStage,
            subjectVelocityX: smoothedSubjectVelocityX,
            thirdsBiasX: thirdsBiasX,
            cameraMotionBiasX: cameraMotionBiasX
        )
    }

    private func rectIOU(_ a: CGRect, _ b: CGRect) -> CGFloat {
        let intersection = a.intersection(b)
        guard !intersection.isNull else { return 0.0 }

        let intersectionArea = intersection.width * intersection.height
        let unionArea = (a.width * a.height) + (b.width * b.height) - intersectionArea
        guard unionArea > 0 else { return 0.0 }

        return intersectionArea / unionArea
    }

    private func softenedCenter(_ value: CGFloat, width: CGFloat) -> CGFloat {
        let magnitude = abs(value)
        guard width > 0 else { return value }
        guard magnitude < width else { return value }

        let t = magnitude / width
        let eased = t * t * (3.0 - (2.0 * t))
        let scale = 0.78 + ((1.0 - 0.78) * eased)
        let softened = magnitude * scale
        return value >= 0 ? softened : -softened
    }

    private func limitStep(from current: CGFloat, to target: CGFloat, maxDelta: CGFloat) -> CGFloat {
        let delta = target - current
        if delta > maxDelta { return current + maxDelta }
        if delta < -maxDelta { return current - maxDelta }
        return target
    }

    private func clamp(_ value: CGFloat, min minValue: CGFloat, max maxValue: CGFloat) -> CGFloat {
        Swift.max(minValue, Swift.min(maxValue, value))
    }
}
