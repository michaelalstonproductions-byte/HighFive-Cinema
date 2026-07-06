import Foundation
import CoreGraphics

enum HKV1_Layer4Math {
    static func clamp01(_ value: CGFloat) -> CGFloat {
        min(max(value, 0), 1)
    }

    static func clamp(_ value: CGFloat, _ minValue: CGFloat, _ maxValue: CGFloat) -> CGFloat {
        min(max(value, minValue), maxValue)
    }

    static func mix(_ a: CGFloat, _ b: CGFloat, _ alpha: CGFloat) -> CGFloat {
        a + ((b - a) * clamp01(alpha))
    }

    static func smootherstep(_ value: CGFloat) -> CGFloat {
        let t = clamp01(value)
        return t * t * t * (t * (t * 6 - 15) + 10)
    }

    static func signPreservingCap(_ value: CGFloat, limit: CGFloat) -> CGFloat {
        guard limit > 0 else { return 0 }
        let sign: CGFloat = value < 0 ? -1 : 1
        return sign * min(abs(value), limit)
    }

    static func safeNormalize(_ value: CGFloat, by denominator: CGFloat) -> CGFloat {
        guard abs(denominator) > 0.0001 else { return 0 }
        return value / denominator
    }
}
