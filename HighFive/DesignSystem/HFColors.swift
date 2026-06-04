import SwiftUI

enum HFColors {
    static let background = Color(red: 0.015, green: 0.014, blue: 0.012)
    static let backgroundRaised = Color(red: 0.055, green: 0.054, blue: 0.050)
    static let charcoal = Color(red: 0.090, green: 0.088, blue: 0.082)
    static let charcoalLight = Color(red: 0.145, green: 0.140, blue: 0.130)
    static let gold = Color(red: 0.930, green: 0.705, blue: 0.255)
    static let goldDeep = Color(red: 0.710, green: 0.455, blue: 0.100)
    static let orange = Color(red: 0.950, green: 0.410, blue: 0.115)
    static let cyanGlow = Color(red: 0.270, green: 0.780, blue: 1.000)
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 0.770, green: 0.760, blue: 0.735)
    static let textMuted = Color(red: 0.560, green: 0.550, blue: 0.525)
    static let stroke = Color.white.opacity(0.13)
    static let goldStroke = gold.opacity(0.42)
    static let shadow = Color.black.opacity(0.55)

    static let heroGradient = LinearGradient(
        colors: [
            Color.black.opacity(0.05),
            Color.black.opacity(0.35),
            Color.black.opacity(0.88)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let goldGradient = LinearGradient(
        colors: [gold, Color(red: 0.985, green: 0.820, blue: 0.420), goldDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let screenBackground = LinearGradient(
        colors: [
            Color.black,
            background,
            Color(red: 0.030, green: 0.025, blue: 0.018)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}
