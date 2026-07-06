import Foundation
import CoreGraphics

final class HKV1_Layer4StableEnvelope {
    private var previousDx: CGFloat = 0
    private var previousDy: CGFloat = 0
    private var previousRawIntentX: CGFloat = 0
    private var previousOutputDx: CGFloat = 0
    private var previousFoldbackRiskX: CGFloat = 0

    func reset() {
        previousDx = 0
        previousDy = 0
        previousRawIntentX = 0
        previousOutputDx = 0
        previousFoldbackRiskX = 0
    }

    func observe(
        rawIntentX: CGFloat,
        rawIntentY: CGFloat,
        outputDx: CGFloat,
        outputDy: CGFloat,
        maxDx: CGFloat,
        maxDy: CGFloat,
        depthOn: Bool,
        dt: CGFloat,
        creatorIntent: HKV1_Layer4CreatorIntent = .safeDefault,
        foregroundPresence: CGFloat? = nil,
        midgroundPresence: CGFloat? = nil,
        backgroundPresence: CGFloat? = nil,
        depthConfidence: CGFloat? = nil
    ) -> HKV1_Layer4StableSnapshot {
        let safeDt = max(dt, 1.0 / 240.0)
        let safeMaxDx = max(abs(maxDx), 1.0)
        let safeMaxDy = max(abs(maxDy), 1.0)

        let velocityX = (outputDx - previousDx) / safeDt
        let velocityY = (outputDy - previousDy) / safeDt

        let stageMagnitude = HKV1_Layer4Math.clamp01(
            hypot(outputDx / safeMaxDx, outputDy / safeMaxDy)
        )
        let stageVelocity = HKV1_Layer4Math.clamp01(
            hypot(velocityX / safeMaxDx, velocityY / safeMaxDy) / 12.0
        )
        let rawIntentMagnitude = HKV1_Layer4Math.clamp01(
            hypot(rawIntentX, rawIntentY)
        )

        let centerProximity = 1.0 - HKV1_Layer4Math.smootherstep(
            HKV1_Layer4Math.clamp01(stageMagnitude / 0.18)
        )
        let crossingVelocity = HKV1_Layer4Math.smootherstep(
            HKV1_Layer4Math.clamp01(stageVelocity / 0.35)
        )
        let activeCrossing =
            centerProximity *
            crossingVelocity *
            HKV1_Layer4Math.smootherstep(rawIntentMagnitude)

        let dotPV = outputDx * velocityX + outputDy * velocityY
        let opposingMotion = dotPV < 0 && rawIntentMagnitude > 0.08
        let opposingStrength = opposingMotion
            ? HKV1_Layer4Math.smootherstep(HKV1_Layer4Math.clamp01(abs(dotPV) / 9000.0))
            : 0

        let fg = HKV1_Layer4Math.clamp01(foregroundPresence ?? 1)
        let mid = HKV1_Layer4Math.clamp01(midgroundPresence ?? 1)
        let bg = HKV1_Layer4Math.clamp01(backgroundPresence ?? 1)
        let confidence = HKV1_Layer4Math.clamp01(depthConfidence ?? (depthOn ? 1 : 0))

        let minCoverage = min(fg, min(mid, bg))
        let maxCoverage = max(fg, max(mid, bg))
        let balance = 1.0 - HKV1_Layer4Math.clamp01(
            (maxCoverage - minCoverage) / max(0.001, maxCoverage)
        )
        let coverageFloor = HKV1_Layer4Math.smootherstep(
            HKV1_Layer4Math.clamp01(minCoverage / 0.08)
        )

        let maskHealth = HKV1_Layer4Math.smootherstep(balance) * coverageFloor
        let depthHealth = HKV1_Layer4Math.smootherstep(confidence)
        let layerHealth = maskHealth * depthHealth

        let inputMagnitudeIncreasing =
            abs(rawIntentX) > abs(previousRawIntentX) + 0.002 &&
            rawIntentX.sign == previousRawIntentX.sign
        let outputMagnitudeShrank =
            abs(outputDx) + 0.20 < abs(previousOutputDx)
        let foldbackPulse: CGFloat = inputMagnitudeIncreasing && outputMagnitudeShrank ? 1.0 : 0.0
        let foldbackRiskX = max(foldbackPulse, previousFoldbackRiskX * 0.86)

        let signPreservationOK =
            abs(rawIntentX) < 0.001 ||
            abs(outputDx) < 0.001 ||
            (rawIntentX < 0 && outputDx <= 0) ||
            (rawIntentX > 0 && outputDx >= 0)

        let monotonicityRisk = foldbackRiskX
        let hingeRisk = max(foldbackRiskX, signPreservationOK ? 0 : 1)

        let edgeRisk = HKV1_Layer4Math.smootherstep(stageMagnitude)
        let healthRisk = 1.0 - layerHealth
        let velocityRisk = HKV1_Layer4Math.smootherstep(stageVelocity)

        let depthRisk =
            edgeRisk * 0.25 +
            healthRisk * 0.30 +
            velocityRisk * 0.15 +
            foldbackRiskX * 0.30

        let depthLockAmount = HKV1_Layer4Math.smootherstep(
            HKV1_Layer4Math.clamp01(depthRisk)
        )
        let depthLockDragRisk = depthLockAmount * opposingStrength

        let baseDepthEnergy = depthOn
            ? HKV1_Layer4Math.smootherstep(stageMagnitude)
            : 0
        let safeDepthScale = HKV1_Layer4Math.mix(1.0, 0.72, depthLockAmount)
        let centerFloor = centerBridgeFloor(for: creatorIntent.preset)
        let centerSmooth = HKV1_Layer4Math.clamp(CGFloat(creatorIntent.centerSmoothAmount), 0.72, 1.20)
        let centerBridgeEnergy: CGFloat = activeCrossing > 0.25
            ? HKV1_Layer4Math.clamp(centerFloor * centerSmooth, 0.06, 0.34)
            : 0
        var depthEnergySafe = max(baseDepthEnergy * safeDepthScale, centerBridgeEnergy)

        if rawIntentMagnitude < 0.02 && stageVelocity < 0.02 {
            depthEnergySafe = 0
        }

        let bungeeRisk = HKV1_Layer4Math.clamp01(
            opposingStrength * 0.35 +
            activeCrossing * 0.25 +
            depthLockDragRisk * 0.20 +
            monotonicityRisk * 0.20
        )

        let safetyRisk = HKV1_Layer4Math.clamp01(
            edgeRisk * 0.25 +
            hingeRisk * 0.30 +
            bungeeRisk * 0.25 +
            healthRisk * 0.20
        )
        let safePower = 1.0 - HKV1_Layer4Math.smootherstep(safetyRisk)
        let effectiveHyperAmount = CGFloat(creatorIntent.hyperAmount) * safePower
        let effectiveDepthAmount = CGFloat(creatorIntent.depthAmount) *
            HKV1_Layer4Math.mix(0.85, 1.0, safePower)

        let existingDepthScalar = HKV1_Layer4Math.clamp(
            HKV1_Layer4Math.mix(
                0.92,
                1.08,
                depthEnergySafe * effectiveDepthAmount * layerHealth
            ),
            0.92,
            1.08
        )

        let volumetricIntent = HKV1_Layer4VolumetricIntent(
            depthEnergySafe: depthEnergySafe,
            layerHealth: layerHealth,
            occlusionConfidence: layerHealth,
            foregroundPresence: fg,
            midgroundPresence: mid,
            backgroundPresence: bg,
            hyperAmountSafe: HKV1_Layer4Math.clamp01(effectiveHyperAmount),
            existingDepthScalar: existingDepthScalar
        )

        let recenterAllowed = activeCrossing <= 0.25
        let recenterBlockedReason = recenterAllowed ? "none" : "active crossing"

        let snapshot = HKV1_Layer4StableSnapshot(
            rawIntentX: rawIntentX,
            rawIntentY: rawIntentY,
            outputDx: outputDx,
            outputDy: outputDy,
            maxDx: maxDx,
            maxDy: maxDy,
            velocityX: velocityX,
            velocityY: velocityY,
            activeCrossing: activeCrossing,
            opposingMotion: opposingMotion,
            opposingStrength: opposingStrength,
            bungeeRisk: bungeeRisk,
            maskHealth: maskHealth,
            depthHealth: depthHealth,
            layerHealth: layerHealth,
            depthLockAmount: depthLockAmount,
            depthEnergy: baseDepthEnergy,
            depthEnergySafe: depthEnergySafe,
            depthLockDragRisk: depthLockDragRisk,
            hingeRisk: hingeRisk,
            foldbackRiskX: foldbackRiskX,
            signPreservationOK: signPreservationOK,
            monotonicityRisk: monotonicityRisk,
            recenterAllowed: recenterAllowed,
            recenterBlockedReason: recenterBlockedReason,
            volumetricIntent: volumetricIntent,
            creatorIntentApplied: true
        )

        previousDx = outputDx
        previousDy = outputDy
        previousRawIntentX = rawIntentX
        previousOutputDx = outputDx
        previousFoldbackRiskX = foldbackRiskX

        return snapshot
    }

    private func centerBridgeFloor(for preset: HKV1_Layer4CreatorIntent.Preset) -> CGFloat {
        switch preset {
        case .anchor:
            return 0.08
        case .drift:
            return 0.14
        case .surge:
            return 0.20
        case .hyper:
            return 0.30
        case .lock:
            return 0.14
        }
    }
}
