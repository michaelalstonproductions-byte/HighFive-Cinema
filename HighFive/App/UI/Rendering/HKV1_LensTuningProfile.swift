import Foundation
import CoreGraphics

enum HKV1_LensType {
    case natural
    case anamorphic
    case portrait
}

struct HKV1_LensTuningProfile {
    let name: String

    // Composition / framing
    let lateralBias: CGFloat
    let verticalBias: CGFloat
    let zoomDepthBoost: CGFloat
    let zoomVerticalTuck: CGFloat

    // Motion physics
    let motionResponseX: CGFloat
    let motionResponseY: CGFloat
    let inertia: CGFloat
    let maxDelta: CGFloat
    let restSoftClamp: CGFloat
    let hardZeroClamp: CGFloat
    let jitterThreshold: CGFloat

    // Film-grade v2 motion shaping
    let shoulderStart: CGFloat
    let shoulderSoftness: CGFloat
    let crossAxisCancel: CGFloat
    let recenterResponse: CGFloat

    // Spatial preset influence
    let depthIntensity: CGFloat
    let focusFalloff: CGFloat
    let bgPlane: CGFloat
    let midPlane: CGFloat
    let fgPlane: CGFloat

    // Cinematic multipliers
    let cinematicDepthMultiplier: CGFloat
    let cinematicBgMultiplier: CGFloat
    let cinematicMidMultiplier: CGFloat
    let cinematicFgMultiplier: CGFloat
}

struct HKV1_LensTuning {

    static func profile(for lens: HKV1_LensType) -> HKV1_LensTuningProfile {
        switch lens {
        case .natural:
            return HKV1_LensTuningProfile(
                name: "Natural",

                lateralBias: 1.00,
                verticalBias: 1.00,
                zoomDepthBoost: 0.10,
                zoomVerticalTuck: 0.08,

                motionResponseX: 6.2,
                motionResponseY: 5.8,
                inertia: 0.90,
                maxDelta: 10.0,
                restSoftClamp: 0.20,
                hardZeroClamp: 0.02,
                jitterThreshold: 0.012,

                shoulderStart: 0.72,
                shoulderSoftness: 0.22,
                crossAxisCancel: 0.10,
                recenterResponse: 1.9,

                depthIntensity: 1.00,
                focusFalloff: 1.00,
                bgPlane: 0.92,
                midPlane: 1.00,
                fgPlane: 1.08,

                cinematicDepthMultiplier: 1.10,
                cinematicBgMultiplier: 1.06,
                cinematicMidMultiplier: 1.08,
                cinematicFgMultiplier: 1.12
            )

        case .anamorphic:
            return HKV1_LensTuningProfile(
                name: "Anamorphic",

                lateralBias: 1.18,
                verticalBias: 0.92,
                zoomDepthBoost: 0.14,
                zoomVerticalTuck: 0.06,

                motionResponseX: 5.7,
                motionResponseY: 5.2,
                inertia: 0.92,
                maxDelta: 11.5,
                restSoftClamp: 0.22,
                hardZeroClamp: 0.02,
                jitterThreshold: 0.013,

                shoulderStart: 0.68,
                shoulderSoftness: 0.26,
                crossAxisCancel: 0.08,
                recenterResponse: 1.7,

                depthIntensity: 1.14,
                focusFalloff: 0.92,
                bgPlane: 1.08,
                midPlane: 1.02,
                fgPlane: 1.16,

                cinematicDepthMultiplier: 1.18,
                cinematicBgMultiplier: 1.14,
                cinematicMidMultiplier: 1.10,
                cinematicFgMultiplier: 1.18
            )

        case .portrait:
            return HKV1_LensTuningProfile(
                name: "Portrait",

                lateralBias: 0.88,
                verticalBias: 1.04,
                zoomDepthBoost: 0.08,
                zoomVerticalTuck: 0.11,

                motionResponseX: 6.8,
                motionResponseY: 6.2,
                inertia: 0.88,
                maxDelta: 9.0,
                restSoftClamp: 0.18,
                hardZeroClamp: 0.018,
                jitterThreshold: 0.010,

                shoulderStart: 0.78,
                shoulderSoftness: 0.18,
                crossAxisCancel: 0.14,
                recenterResponse: 2.1,

                depthIntensity: 1.20,
                focusFalloff: 1.14,
                bgPlane: 0.84,
                midPlane: 1.02,
                fgPlane: 1.24,

                cinematicDepthMultiplier: 1.16,
                cinematicBgMultiplier: 1.02,
                cinematicMidMultiplier: 1.08,
                cinematicFgMultiplier: 1.22
            )
        }
    }
}
