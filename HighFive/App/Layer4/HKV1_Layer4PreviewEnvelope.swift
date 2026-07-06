import Foundation
import CoreGraphics

struct HKV1_Layer4PreviewEnvelope: Equatable {
    var stageOffset: CGPoint
    var globalPlaneScalar: CGFloat
    var backgroundScalar: CGFloat
    var midgroundScalar: CGFloat
    var foregroundScalar: CGFloat
    var uiDepthAmount: CGFloat
    var depthEnergy: CGFloat
    var health: CGFloat
    var risk: CGFloat
    var depthAvailable: Bool
    var reduceMotion: Bool
    var reason: String

    static let neutral = HKV1_Layer4PreviewEnvelope(
        stageOffset: .zero,
        globalPlaneScalar: 1.0,
        backgroundScalar: 1.0,
        midgroundScalar: 1.0,
        foregroundScalar: 1.0,
        uiDepthAmount: 0.0,
        depthEnergy: 0.0,
        health: 0.0,
        risk: 0.0,
        depthAvailable: false,
        reduceMotion: false,
        reason: "neutral"
    )

    var clamped: HKV1_Layer4PreviewEnvelope {
        HKV1_Layer4PreviewEnvelope(
            stageOffset: CGPoint(
                x: HKV1_Layer4Math.clamp(stageOffset.x, -32, 32),
                y: HKV1_Layer4Math.clamp(stageOffset.y, -18, 18)
            ),
            globalPlaneScalar: HKV1_Layer4Math.clamp(globalPlaneScalar, 0.94, 1.10),
            backgroundScalar: HKV1_Layer4Math.clamp(backgroundScalar, 0.96, 1.06),
            midgroundScalar: HKV1_Layer4Math.clamp(midgroundScalar, 0.97, 1.08),
            foregroundScalar: HKV1_Layer4Math.clamp(foregroundScalar, 0.98, 1.12),
            uiDepthAmount: HKV1_Layer4Math.clamp01(uiDepthAmount),
            depthEnergy: HKV1_Layer4Math.clamp01(depthEnergy),
            health: HKV1_Layer4Math.clamp01(health),
            risk: HKV1_Layer4Math.clamp01(risk),
            depthAvailable: depthAvailable,
            reduceMotion: reduceMotion,
            reason: reason
        )
    }
}
