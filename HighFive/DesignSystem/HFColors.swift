import SwiftUI

enum HFColors {
    static let background = Color(red: 0.006, green: 0.006, blue: 0.006)
    static let backgroundRaised = Color(red: 0.044, green: 0.044, blue: 0.044)
    static let charcoal = Color(red: 0.090, green: 0.090, blue: 0.090)
    static let charcoalLight = Color(red: 0.155, green: 0.155, blue: 0.180)
    static let surface = Color(red: 0.092, green: 0.092, blue: 0.095)
    static let surfaceElevated = Color(red: 0.157, green: 0.157, blue: 0.212)
    static let glassSurface = Color(red: 0.064, green: 0.059, blue: 0.052).opacity(0.86)
    static let glassSurfaceRaised = Color(red: 0.112, green: 0.106, blue: 0.096).opacity(0.78)
    static let glassHighlight = Color.white.opacity(0.13)
    static let glassRim = Color.white.opacity(0.095)
    static let gold = Color(red: 1.000, green: 0.914, blue: 0.247)
    static let goldDeep = Color(red: 0.710, green: 0.455, blue: 0.100)
    static let orange = Color(red: 0.950, green: 0.410, blue: 0.115)
    static let redAccent = Color(red: 0.992, green: 0.267, blue: 0.227)
    static let violet = Color(red: 0.565, green: 0.420, blue: 1.000)
    static let amberGlow = Color(red: 1.000, green: 0.530, blue: 0.120)
    static let cyanGlow = Color(red: 0.439, green: 0.812, blue: 0.796)
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 0.835, green: 0.825, blue: 0.795)
    static let textMuted = Color(red: 0.660, green: 0.650, blue: 0.620)
    static let stroke = Color.white.opacity(0.16)
    static let goldStroke = gold.opacity(0.48)
    static let glassStroke = Color.white.opacity(0.20)
    static let shadow = Color.black.opacity(0.55)
    static let warmGlow = Color(red: 0.240, green: 0.130, blue: 0.055)
    static let controlFill = Color.white.opacity(0.105)
    static let controlFillStrong = Color.white.opacity(0.155)
    static let quietFill = Color.white.opacity(0.075)
    static let selectedGoldFill = gold.opacity(0.16)
    static let selectedCyanFill = cyanGlow.opacity(0.16)
    static let selectedVioletFill = violet.opacity(0.18)

    static let heroGradient = LinearGradient(
        colors: [
            Color.black.opacity(0.05),
            Color.black.opacity(0.35),
            Color.black.opacity(0.88)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let cinematicGoldScrim = LinearGradient(
        colors: [
            Color.black.opacity(0.05),
            warmGlow.opacity(0.44),
            Color.black.opacity(0.92)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let opticalGlassGradient = LinearGradient(
        colors: [
            glassHighlight,
            glassSurfaceRaised.opacity(0.68),
            Color.black.opacity(0.80)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let subtleGlassRimGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.22),
            gold.opacity(0.24),
            cyanGlow.opacity(0.15),
            Color.white.opacity(0.055)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
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
            Color(red: 0.030, green: 0.025, blue: 0.018),
            Color(red: 0.065, green: 0.055, blue: 0.035)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}
