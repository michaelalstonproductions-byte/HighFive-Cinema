import Foundation

struct HKV1_Layer4CreatorIntent: Codable, Equatable {
    var preset: Preset
    var depthAmount: Double
    var peekAssistAmount: Double
    var centerSmoothAmount: Double
    var recenterAmount: Double
    var edgeProtectAmount: Double
    var hyperAmount: Double
    var goldenSafeMode: Bool

    enum Preset: String, Codable, CaseIterable {
        case anchor
        case drift
        case surge
        case hyper
        case lock
    }

    static let safeDefault = HKV1_Layer4CreatorIntent(
        preset: .drift,
        depthAmount: 0.74,
        peekAssistAmount: 0.0,
        centerSmoothAmount: 0.0,
        recenterAmount: 0.55,
        edgeProtectAmount: 0.70,
        hyperAmount: 0.18,
        goldenSafeMode: true
    )
}
