import Foundation
import CoreGraphics

struct HKV1_Layer4VolumetricIntent {
    var depthEnergySafe: CGFloat
    var layerHealth: CGFloat
    var occlusionConfidence: CGFloat
    var foregroundPresence: CGFloat
    var midgroundPresence: CGFloat
    var backgroundPresence: CGFloat
    var hyperAmountSafe: CGFloat

    /// Existing-depth scalar only. Safe for plane residuals; never alters dx/dy.
    var existingDepthScalar: CGFloat

    static let neutral = HKV1_Layer4VolumetricIntent(
        depthEnergySafe: 0,
        layerHealth: 0,
        occlusionConfidence: 0,
        foregroundPresence: 1,
        midgroundPresence: 1,
        backgroundPresence: 1,
        hyperAmountSafe: 0,
        existingDepthScalar: 1
    )
}
