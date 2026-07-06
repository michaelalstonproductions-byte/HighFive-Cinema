import Foundation
import CoreGraphics

struct HKV1_Layer4StableSnapshot {
    var rawIntentX: CGFloat
    var rawIntentY: CGFloat

    var outputDx: CGFloat
    var outputDy: CGFloat
    var maxDx: CGFloat
    var maxDy: CGFloat

    var velocityX: CGFloat
    var velocityY: CGFloat

    var activeCrossing: CGFloat
    var opposingMotion: Bool
    var opposingStrength: CGFloat
    var bungeeRisk: CGFloat

    var maskHealth: CGFloat
    var depthHealth: CGFloat
    var layerHealth: CGFloat

    var depthLockAmount: CGFloat
    var depthEnergy: CGFloat
    var depthEnergySafe: CGFloat
    var depthLockDragRisk: CGFloat

    var hingeRisk: CGFloat
    var foldbackRiskX: CGFloat
    var signPreservationOK: Bool
    var monotonicityRisk: CGFloat

    var recenterAllowed: Bool
    var recenterBlockedReason: String

    var volumetricIntent: HKV1_Layer4VolumetricIntent
    var creatorIntentApplied: Bool
}
