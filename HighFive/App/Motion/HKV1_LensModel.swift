import UIKit

struct HKV1_LensModel {

    struct Profile {
        let bgPlane: CGFloat
        let midPlane: CGFloat
        let fgPlane: CGFloat

        let lateralBias: CGFloat
        let verticalBias: CGFloat
        let fgProtection: CGFloat

        let bgScaleBias: CGFloat
        let midScaleBias: CGFloat
        let fgScaleBias: CGFloat

        let flatOpacityBase: CGFloat
        let bgOpacityBoost: CGFloat
        let midOpacityBoost: CGFloat
        let fgOpacityBoost: CGFloat

        let topShoulderBase: CGFloat
        let topShoulderDepthGain: CGFloat
        let vignetteBase: CGFloat
        let vignetteFocusGain: CGFloat
        let grainBase: CGFloat
        let grainDepthGain: CGFloat

        let bgTravelGain: CGFloat
        let midTravelGain: CGFloat
        let fgTravelGain: CGFloat
    }

    static func profile(for lensMode: HKV1_PlayerLayerView.LensMode) -> Profile {
        switch lensMode {
        case .natural:
            return Profile(
                bgPlane: 0.70,
                midPlane: 1.20,
                fgPlane: 1.45,

                lateralBias: 1.22,
                verticalBias: 1.00,
                fgProtection: 0.96,

                bgScaleBias: 0.002,
                midScaleBias: 0.010,
                fgScaleBias: 0.006,

                flatOpacityBase: 0.74,
                bgOpacityBoost: 0.003,
                midOpacityBoost: 0.006,
                fgOpacityBoost: 0.001,

                topShoulderBase: 0.052,
                topShoulderDepthGain: 0.024,
                vignetteBase: 0.048,
                vignetteFocusGain: 0.068,
                grainBase: 0.022,
                grainDepthGain: 0.007,

                bgTravelGain: 0.96,
                midTravelGain: 1.22,
                fgTravelGain: 1.12
            )

        case .anamorphic:
            return Profile(
                bgPlane: 0.42,
                midPlane: 1.55,
                fgPlane: 2.05,

                lateralBias: 1.58,
                verticalBias: 0.78,
                fgProtection: 0.86,

                bgScaleBias: 0.010,
                midScaleBias: 0.028,
                fgScaleBias: 0.016,

                flatOpacityBase: 0.75,
                bgOpacityBoost: 0.010,
                midOpacityBoost: 0.008,
                fgOpacityBoost: 0.010,

                topShoulderBase: 0.066,
                topShoulderDepthGain: 0.030,
                vignetteBase: 0.055,
                vignetteFocusGain: 0.076,
                grainBase: 0.022,
                grainDepthGain: 0.008,

                bgTravelGain: 1.10,
                midTravelGain: 1.44,
                fgTravelGain: 1.28
            )

        case .portrait:
            return Profile(
                bgPlane: 0.30,
                midPlane: 1.30,
                fgPlane: 2.20,

                lateralBias: 1.12,
                verticalBias: 0.92,
                fgProtection: 0.98,

                bgScaleBias: -0.001,
                midScaleBias: 0.012,
                fgScaleBias: 0.010,

                flatOpacityBase: 0.77,
                bgOpacityBoost: -0.002,
                midOpacityBoost: 0.010,
                fgOpacityBoost: 0.006,

                topShoulderBase: 0.046,
                topShoulderDepthGain: 0.021,
                vignetteBase: 0.060,
                vignetteFocusGain: 0.088,
                grainBase: 0.021,
                grainDepthGain: 0.006,

                bgTravelGain: 0.90,
                midTravelGain: 1.28,
                fgTravelGain: 1.30
            )
        }
    }
}
