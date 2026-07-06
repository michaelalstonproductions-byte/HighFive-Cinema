import Foundation
import CoreGraphics

struct HKV1_Layer4PlaneResidualIntent: Equatable {
    var globalScalar: CGFloat
    var backgroundScalar: CGFloat
    var midgroundScalar: CGFloat
    var foregroundScalar: CGFloat
    var depthEnergy: CGFloat
    var layerHealth: CGFloat
    var risk: CGFloat
    var reason: String

    static let neutral = HKV1_Layer4PlaneResidualIntent(
        globalScalar: 1.0,
        backgroundScalar: 1.0,
        midgroundScalar: 1.0,
        foregroundScalar: 1.0,
        depthEnergy: 0.0,
        layerHealth: 0.0,
        risk: 0.0,
        reason: "neutral"
    )

    var clamped: HKV1_Layer4PlaneResidualIntent {
        HKV1_Layer4PlaneResidualIntent(
            globalScalar: HKV1_Layer4Math.clamp(globalScalar, 0.92, 1.08),
            backgroundScalar: HKV1_Layer4Math.clamp(backgroundScalar, 0.94, 1.05),
            midgroundScalar: HKV1_Layer4Math.clamp(midgroundScalar, 0.95, 1.07),
            foregroundScalar: HKV1_Layer4Math.clamp(foregroundScalar, 0.96, 1.10),
            depthEnergy: HKV1_Layer4Math.clamp01(depthEnergy),
            layerHealth: HKV1_Layer4Math.clamp01(layerHealth),
            risk: HKV1_Layer4Math.clamp01(risk),
            reason: reason
        )
    }
}
