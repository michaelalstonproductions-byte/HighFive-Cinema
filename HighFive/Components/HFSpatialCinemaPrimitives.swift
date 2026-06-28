import SwiftUI

enum HFIconography {
    static let chipIconSize: CGFloat = 9
    static let smallIconSize: CGFloat = 12
    static let actionIconSize: CGFloat = 16
    static let controlIconSize: CGFloat = 18
    static let featureIconSize: CGFloat = 22
    static let heroIconSize: CGFloat = 30
    static let actionIconFrame: CGFloat = 20
    static let chipIconFrame: CGFloat = 13
    static let menuIconFrame: CGFloat = 30
    static let circularIconFrame: CGFloat = 48

    static func symbolFont(size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
}

enum HFSpatialMotionTokens {
    static let microResponse: Double = 0.14
    static let standardTransition: Double = 0.24
    static let sceneEntrance: Double = 0.42
    static let focusSpringResponse: Double = 0.34
    static let focusSpringDamping: Double = 0.88
    static let selectedScale: CGFloat = 1.035
    static let recededScale: CGFloat = 0.965
    static let selectedLift: CGFloat = -5
    static let recededOffset: CGFloat = 3
    static let maximumTiltDegrees: Double = 7
    static let maximumDecorativeBlur: CGFloat = 2

    static var microAnimation: Animation {
        .easeInOut(duration: microResponse)
    }

    static var standardAnimation: Animation {
        .easeInOut(duration: standardTransition)
    }

    static var sceneEntranceAnimation: Animation {
        .easeOut(duration: sceneEntrance)
    }

    static var focusAnimation: Animation {
        .spring(response: focusSpringResponse, dampingFraction: focusSpringDamping)
    }

    static var tabSelectionAnimation: Animation {
        .spring(response: 0.30, dampingFraction: 0.86)
    }

    static var pressAnimation: Animation {
        .spring(response: 0.22, dampingFraction: 0.82)
    }
}

enum HFSpatialRouteTransition {
    static var animation: Animation {
        HFSpatialMotionTokens.standardAnimation
    }

    static func entranceScale(reduceMotion: Bool) -> CGFloat {
        reduceMotion ? 1 : 0.992
    }

    static func tabTransition(reduceMotion: Bool) -> AnyTransition {
        reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.992, anchor: .center))
    }
}

enum HFSpatialFocalHandoff {
    static let edgeOpacity: Double = 0.34
    static let titleLift: CGFloat = -4
}

private struct HFSpatialNavigationSpineModifier: ViewModifier {
    let isActive: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive ? 1 : HFSpatialRouteTransition.entranceScale(reduceMotion: reduceMotion))
            .animation(reduceMotion ? .easeInOut(duration: 0.01) : HFSpatialRouteTransition.animation, value: isActive)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                HFColors.gold.opacity(reduceTransparency ? 0.16 : 0.22),
                                HFColors.cyanGlow.opacity(reduceTransparency ? 0.10 : 0.16),
                                HFColors.violet.opacity(reduceTransparency ? 0.035 : 0.08),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: differentiateWithoutColor ? 2 : 1)
                    .opacity(isActive ? 1 : 0)
                    .accessibilityHidden(true)
                    .accessibilityIdentifier("hf.spatial.nav.transition")
            }
            .overlay(alignment: .bottomTrailing) {
                Color.clear
                    .frame(width: 1, height: 1)
                    .accessibilityHidden(true)
                    .accessibilityIdentifier("hf.spatial.nav.spine")
            }
    }
}

private struct HFSpatialFocalHandoffModifier: ViewModifier {
    let identifiers: [String]

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topLeading) {
                VStack {
                    ForEach(identifiers, id: \.self) { identifier in
                        Color.clear
                            .frame(width: 1, height: 1)
                            .accessibilityHidden(true)
                            .accessibilityIdentifier(identifier)
                    }
                }
                .accessibilityIdentifier("hf.spatial.nav.focalHandoff")
            }
    }
}

enum HFSpatialDepthState {
    case selected
    case receded
}

enum HFSpatialSelectionTreatment {
    static func scale(for state: HFSpatialDepthState, reduceMotion: Bool) -> CGFloat {
        guard !reduceMotion else { return state == .selected ? 1.02 : 1 }
        switch state {
        case .selected:
            return HFSpatialMotionTokens.selectedScale
        case .receded:
            return HFSpatialMotionTokens.recededScale
        }
    }

    static func opacity(for state: HFSpatialDepthState) -> Double {
        state == .selected ? 1 : 0.74
    }

    static func offset(for state: HFSpatialDepthState, reduceMotion: Bool) -> CGFloat {
        guard !reduceMotion else { return 0 }
        return state == .selected ? HFSpatialMotionTokens.selectedLift : HFSpatialMotionTokens.recededOffset
    }
}

typealias HFSpatialFocusTransform = HFSpatialSelectionTreatment

enum HFSpatialSceneEntrance {
    static var animation: Animation {
        HFSpatialMotionTokens.sceneEntranceAnimation
    }
}

private struct HFSpatialSelectionModifier: ViewModifier {
    let isSelected: Bool
    let accent: Color
    let reduceMotion: Bool
    let differentiateWithoutColor: Bool

    private var state: HFSpatialDepthState {
        isSelected ? .selected : .receded
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(HFSpatialSelectionTreatment.scale(for: state, reduceMotion: reduceMotion))
            .opacity(HFSpatialSelectionTreatment.opacity(for: state))
            .offset(y: HFSpatialSelectionTreatment.offset(for: state, reduceMotion: reduceMotion))
            .zIndex(isSelected ? 2 : 0)
            .overlay(alignment: .topTrailing) {
                if isSelected && differentiateWithoutColor {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(.black)
                        .frame(width: 24, height: 24)
                        .background(accent)
                        .clipShape(Circle())
                        .padding(5)
                        .accessibilityHidden(true)
                        .accessibilityIdentifier("hf.spatial.accessibility.differentiateWithoutColor")
                }
            }
            .overlay(alignment: .bottomLeading) {
                Color.clear
                    .frame(width: 1, height: 1)
                    .accessibilityHidden(true)
                    .accessibilityIdentifier("hf.spatial.motion.selection")
            }
            .accessibilityAddTraits(isSelected ? .isSelected : [])
            .accessibilityValue(isSelected ? "Selected" : "Not selected")
            .accessibilityIdentifier(isSelected ? "hf.spatial.motion.selected" : "hf.spatial.motion.receded")
    }
}

private struct HFSpatialSceneEntranceModifier: ViewModifier {
    let isActive: Bool
    let reduceMotion: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(reduceMotion ? 1 : (isActive ? 1 : 0.985))
            .opacity(isActive ? 1 : 0.94)
            .offset(y: reduceMotion ? 0 : (isActive ? 0 : 8))
            .animation(reduceMotion ? .easeInOut(duration: 0.01) : HFSpatialSceneEntrance.animation, value: isActive)
            .accessibilityIdentifier(reduceMotion ? "hf.spatial.motion.reduceMotionFallback" : "hf.spatial.motion.sceneEntrance")
    }
}

private struct HFSpatialPressButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.982 : 1))
            .opacity(configuration.isPressed ? 0.88 : 1)
            .animation(reduceMotion ? .easeOut(duration: 0.01) : HFSpatialMotionTokens.pressAnimation, value: configuration.isPressed)
    }
}

extension View {
    func hfSpatialNavigationSpine(isActive: Bool = true) -> some View {
        modifier(HFSpatialNavigationSpineModifier(isActive: isActive))
    }

    func hfSpatialFocalHandoff(_ identifiers: String...) -> some View {
        modifier(HFSpatialFocalHandoffModifier(identifiers: identifiers))
    }

    func hfSpatialSelectionTreatment(
        isSelected: Bool,
        accent: Color,
        reduceMotion: Bool,
        differentiateWithoutColor: Bool
    ) -> some View {
        modifier(
            HFSpatialSelectionModifier(
                isSelected: isSelected,
                accent: accent,
                reduceMotion: reduceMotion,
                differentiateWithoutColor: differentiateWithoutColor
            )
        )
    }

    func hfSpatialSceneEntrance(isActive: Bool, reduceMotion: Bool) -> some View {
        modifier(HFSpatialSceneEntranceModifier(isActive: isActive, reduceMotion: reduceMotion))
    }
}

struct HFOpticalGlassSurface<Content: View>: View {
    let cornerRadius: CGFloat
    let strokeColor: Color
    let content: Content
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    init(
        cornerRadius: CGFloat = HFSpacing.panelRadius,
        strokeColor: Color = HFColors.glassStroke,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.strokeColor = strokeColor
        self.content = content()
    }

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(reduceTransparency ? Color.black.opacity(0.97) : Color.black.opacity(0.76))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(HFColors.glassSurface.opacity(reduceTransparency ? 0.36 : 0.72))
                    )
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(reduceTransparency ? 0.055 : 0.15),
                                HFColors.gold.opacity(reduceTransparency ? 0.025 : 0.08),
                                HFColors.cyanGlow.opacity(reduceTransparency ? 0.015 : 0.045),
                                HFColors.violet.opacity(reduceTransparency ? 0.008 : 0.026),
                                Color.black.opacity(reduceTransparency ? 0.58 : 0.42)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    )
                    .overlay(alignment: .top) {
                        Capsule()
                            .fill(Color.white.opacity(reduceTransparency ? 0.035 : 0.16))
                            .frame(height: 1)
                            .padding(.horizontal, cornerRadius)
                            .padding(.top, 1)
                    }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(strokeColor, lineWidth: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(HFColors.glassRim, lineWidth: 0.7)
                    .padding(1)
            )
            .shadow(color: Color.black.opacity(0.64), radius: 22, x: 0, y: 14)
            .shadow(color: strokeColor.opacity(reduceTransparency ? 0 : 0.10), radius: 20, x: 0, y: 8)
            .accessibilityIdentifier(reduceTransparency ? "hf.spatial.material.reduceTransparency" : "hf.spatial.material.opticalBlack")
    }
}

struct HFDepthContourOverlay: View {
    var color: Color = HFColors.cyanGlow
    var lineWidth: CGFloat = 1

    var body: some View {
        GeometryReader { proxy in
            let inset = max(12, min(proxy.size.width, proxy.size.height) * 0.06)
            ZStack {
                RoundedRectangle(cornerRadius: HFSpacing.heroRadius + 4, style: .continuous)
                    .stroke(color.opacity(0.36), lineWidth: lineWidth)
                    .padding(inset)

                RoundedRectangle(cornerRadius: HFSpacing.heroRadius + 12, style: .continuous)
                    .stroke(color.opacity(0.18), lineWidth: lineWidth)
                    .padding(inset * 1.9)

                HStack {
                    contourMark
                    Spacer()
                    contourMark
                }
                .padding(.horizontal, inset * 0.9)
                .padding(.top, inset * 1.2)
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var contourMark: some View {
        Capsule()
            .fill(color.opacity(0.62))
            .frame(width: 34, height: 2)
            .shadow(color: color.opacity(0.55), radius: 8)
    }
}

struct HFEnergyAction: View {
    enum Style {
        case gold
        case cyan
        case glass
    }

    let title: String
    let systemImage: String
    let style: Style
    let action: () -> Void
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    var body: some View {
        Button(action: action) {
            HStack(spacing: HFSpacing.xs) {
                Image(systemName: systemImage)
                    .font(HFIconography.symbolFont(size: HFIconography.actionIconSize, weight: .black))
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: HFIconography.actionIconFrame)
                Text(title)
                if style == .gold && differentiateWithoutColor {
                    Image(systemName: "checkmark.seal.fill")
                        .font(HFIconography.symbolFont(size: HFIconography.smallIconSize, weight: .black))
                        .frame(width: HFIconography.chipIconFrame)
                        .accessibilityHidden(true)
                }
            }
            .font(HFTypography.smallAction)
            .foregroundStyle(foregroundStyle)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 48)
            .background(backgroundStyle)
            .overlay(border)
            .clipShape(Capsule())
            .shadow(color: glowColor, radius: glowRadius, x: 0, y: 8)
        }
        .buttonStyle(HFSpatialPressButtonStyle())
        .accessibilityIdentifier(style == .gold ? "hf.spatial.command.primary" : "hf.spatial.command.secondary")
    }

    private var foregroundStyle: Color {
        switch style {
        case .gold:
            return .black
        case .cyan, .glass:
            return HFColors.textPrimary
        }
    }

    private var backgroundStyle: AnyShapeStyle {
        switch style {
        case .gold:
            return AnyShapeStyle(HFColors.goldGradient)
        case .cyan:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        HFColors.cyanGlow.opacity(0.22),
                        Color.black.opacity(0.72),
                        HFColors.glassSurface
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .glass:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.12),
                        HFColors.glassSurfaceRaised.opacity(0.56),
                        Color.black.opacity(0.64)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }

    @ViewBuilder
    private var border: some View {
        switch style {
        case .gold:
            Capsule().stroke(HFColors.gold.opacity(0.72), lineWidth: 1)
        case .cyan:
            Capsule().stroke(HFColors.cyanGlow.opacity(0.68), lineWidth: 1)
        case .glass:
            Capsule().stroke(HFColors.glassStroke, lineWidth: 1)
        }
    }

    private var glowColor: Color {
        switch style {
        case .gold:
            return HFColors.amberGlow.opacity(0.32)
        case .cyan:
            return HFColors.cyanGlow.opacity(0.24)
        case .glass:
            return Color.clear
        }
    }

    private var glowRadius: CGFloat {
        style == .glass ? 0 : 16
    }
}

struct HFSpatialActionCluster<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: HFSpacing.xs) {
            content
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.spatial.motion.system")
        .accessibilityIdentifier("hf.spatial.actionCluster")
        .accessibilityIdentifier("hf.spatial.nav.commandBar")
    }
}

struct HFSpatialCommandBar<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        HFSpatialActionCluster {
            content
        }
        .accessibilityIdentifier("hf.spatial.nav.commandBar")
    }
}

struct HFSpatialRouteBadge: View {
    let title: String
    var accent: Color = HFColors.gold

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(accent)
                .frame(width: 6, height: 6)
            Text(title)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(.horizontal, HFSpacing.xs)
        .frame(height: 24)
        .background(Color.black.opacity(0.48))
        .overlay(Capsule().stroke(accent.opacity(0.28), lineWidth: 1))
        .clipShape(Capsule())
        .accessibilityIdentifier("hf.spatial.nav.routeBadge")
    }
}

struct HFSpatialInspectorChrome<Content: View>: View {
    let title: String
    let detail: String
    let systemImage: String
    let accent: Color
    let content: Content
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    init(
        title: String,
        detail: String,
        systemImage: String = "slider.horizontal.3",
        accent: Color = HFColors.gold,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.detail = detail
        self.systemImage = systemImage
        self.accent = accent
        self.content = content()
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: systemImage)
                        .font(HFIconography.symbolFont(size: HFIconography.featureIconSize, weight: .black))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.black)
                        .frame(width: HFIconography.circularIconFrame + 2, height: HFIconography.circularIconFrame + 2)
                        .background(
                            LinearGradient(
                                colors: [accent.opacity(0.98), accent.opacity(0.64)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text(title)
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.72)
                        Text(detail)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                content
            }
            .padding(HFSpacing.lg)
            .padding(.bottom, HFSpacing.lg)
        }
        .background(inspectorBackground)
        .accessibilityIdentifier("hf.spatial.inspector.chrome")
    }

    @ViewBuilder
    private var inspectorBackground: some View {
        if reduceTransparency {
            HFColors.background.ignoresSafeArea()
        } else {
            HFColors.screenBackground.ignoresSafeArea()
        }
    }
}
