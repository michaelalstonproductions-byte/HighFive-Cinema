import SwiftUI

struct HFEmptyState: View {
    let title: String
    let message: String
    var systemImage: String = "film.stack"
    var actionTitle: String?
    var action: (() -> Void)?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAwake = false

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(spacing: HFSpacing.md) {
                Image(systemName: systemImage)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .scaleEffect(reduceMotion ? 1 : (isAwake ? 1 : 0.94))
                    .opacity(isAwake ? 1 : 0.72)
                    .animation(reduceMotion ? nil : HFSpatialMotionTokens.cinematicFocusAnimation.delay(0.04), value: isAwake)

                VStack(spacing: HFSpacing.xs) {
                    Text(title)
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                        .multilineTextAlignment(.center)
                    Text(message)
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                if let actionTitle, let action {
                    Button(action: action) {
                        Text(actionTitle)
                            .font(HFTypography.smallAction)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(HFColors.goldGradient)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(actionTitle)
                    .accessibilityHint("Attempts to recover this empty state")
                }
            }
            .padding(HFSpacing.xl)
            .frame(maxWidth: .infinity)
        }
        .hfCinematicSectionReveal(isActive: isAwake, reduceMotion: reduceMotion)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(title). \(message)")
        .onAppear {
            guard !isAwake else { return }
            if reduceMotion {
                isAwake = true
            } else {
                withAnimation(HFSpatialMotionTokens.sectionRevealAnimation) {
                    isAwake = true
                }
            }
        }
    }
}

enum HFContentStateKind {
    case loading
    case empty
    case retry
    case offline
    case progress(Double)
    case placeholder

    var systemImage: String {
        switch self {
        case .loading: return "hourglass"
        case .empty: return "rectangle.stack.badge.minus"
        case .retry: return "arrow.clockwise.circle.fill"
        case .offline: return "wifi.slash"
        case .progress: return "chart.line.uptrend.xyaxis.circle.fill"
        case .placeholder: return "sparkles.rectangle.stack.fill"
        }
    }

    var accent: Color {
        switch self {
        case .loading, .progress: return HFColors.cyanGlow
        case .retry: return HFColors.orange
        case .offline: return HFColors.violet
        case .empty, .placeholder: return HFColors.gold
        }
    }

    var label: String {
        switch self {
        case .loading: return "Loading"
        case .empty: return "Empty"
        case .retry: return "Retry"
        case .offline: return "Offline"
        case .progress: return "Progress"
        case .placeholder: return "Placeholder"
        }
    }

    var progressValue: Double? {
        guard case .progress(let value) = self else { return nil }
        return min(max(value, 0), 1)
    }
}

struct HFContentStateCard: View {
    let kind: HFContentStateKind
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?
    var isCompact = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAwake = false

    var body: some View {
        HFOpticalGlassSurface(cornerRadius: isCompact ? HFSpacing.cardRadius : HFSpacing.panelRadius, strokeColor: kind.accent.opacity(0.38)) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                stateIcon

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HStack(spacing: HFSpacing.xs) {
                        Text(kind.label)
                            .font(HFTypography.micro)
                            .foregroundStyle(kind.accent)
                            .textCase(.uppercase)
                        Spacer(minLength: 0)
                    }

                    Text(title)
                        .font(isCompact ? HFTypography.cardTitle : HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(message)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    if let progress = kind.progressValue {
                        ProgressView(value: progress)
                            .tint(kind.accent)
                            .background(HFColors.controlFill)
                            .clipShape(Capsule())
                            .accessibilityLabel("State progress")
                            .accessibilityValue("\(Int(progress * 100)) percent")
                    }

                    if let actionTitle, let action {
                        Button(action: action) {
                            Text(actionTitle)
                                .font(HFTypography.smallAction)
                                .foregroundStyle(kind.accent == HFColors.gold ? .black : HFColors.textPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 42)
                                .background(kind.accent == HFColors.gold ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(kind.accent.opacity(0.18)))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(actionTitle)
                        .accessibilityHint("Attempts to recover the \(kind.label.lowercased()) state")
                    }
                }
            }
            .padding(isCompact ? HFSpacing.md : HFSpacing.lg)
        }
        .hfCinematicSectionReveal(isActive: isAwake, reduceMotion: reduceMotion)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(kind.label): \(title). \(message)")
        .accessibilityIdentifier("hf.state.\(kind.label.lowercased())")
        .onAppear {
            guard !isAwake else { return }
            if reduceMotion {
                isAwake = true
            } else {
                withAnimation(HFSpatialMotionTokens.sectionRevealAnimation.delay(0.03)) {
                    isAwake = true
                }
            }
        }
    }

    private var stateIcon: some View {
        Image(systemName: kind.systemImage)
            .font(HFIconography.symbolFont(size: isCompact ? HFIconography.controlIconSize : HFIconography.featureIconSize, weight: .black))
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(kind.accent)
            .frame(width: isCompact ? 44 : 54, height: isCompact ? 44 : 54)
            .background(kind.accent.opacity(0.16))
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
            .accessibilityHidden(true)
    }
}

enum HFErrorRecoveryKind {
    case playback
    case upload
    case search
    case network
    case auth
    case download
    case generic

    var systemImage: String {
        switch self {
        case .playback: return "play.slash.fill"
        case .upload: return "arrow.up.doc.fill"
        case .search: return "magnifyingglass.circle.fill"
        case .network: return "network.slash"
        case .auth: return "person.crop.circle.badge.exclamationmark"
        case .download: return "arrow.down.circle.dotted"
        case .generic: return "exclamationmark.triangle.fill"
        }
    }

    var title: String {
        switch self {
        case .playback: return "Playback"
        case .upload: return "Upload"
        case .search: return "Search"
        case .network: return "Network"
        case .auth: return "Account"
        case .download: return "Download"
        case .generic: return "Recovery"
        }
    }

    var accent: Color {
        switch self {
        case .playback, .search: return HFColors.orange
        case .upload, .download: return HFColors.violet
        case .network: return HFColors.cyanGlow
        case .auth: return HFColors.gold
        case .generic: return HFColors.redAccent
        }
    }
}

struct HFErrorRecoveryCard: View {
    let kind: HFErrorRecoveryKind
    let title: String
    let message: String
    var recoveryTitle: String = "Try Again"
    var recovery: (() -> Void)?
    var secondaryTitle: String?
    var secondary: (() -> Void)?
    var isCompact = false

    var body: some View {
        HFOpticalGlassSurface(cornerRadius: isCompact ? HFSpacing.cardRadius : HFSpacing.panelRadius, strokeColor: kind.accent.opacity(0.42)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: kind.systemImage)
                        .font(HFIconography.symbolFont(size: isCompact ? HFIconography.controlIconSize : HFIconography.featureIconSize, weight: .black))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(kind.accent)
                        .frame(width: isCompact ? 44 : 54, height: isCompact ? 44 : 54)
                        .background(kind.accent.opacity(0.16))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("\(kind.title) Error")
                            .font(HFTypography.micro)
                            .foregroundStyle(kind.accent)
                            .textCase(.uppercase)
                        Text(title)
                            .font(isCompact ? HFTypography.cardTitle : HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(message)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                HStack(spacing: HFSpacing.sm) {
                    if let recovery {
                        Button(action: recovery) {
                            Text(recoveryTitle)
                                .font(HFTypography.smallAction)
                                .foregroundStyle(kind.accent == HFColors.gold ? .black : HFColors.textPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 42)
                                .background(kind.accent == HFColors.gold ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(kind.accent.opacity(0.20)))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(recoveryTitle)
                        .accessibilityHint("Attempts to recover this \(kind.title.lowercased()) error")
                    }

                    if let secondaryTitle, let secondary {
                        Button(action: secondary) {
                            Text(secondaryTitle)
                                .font(HFTypography.smallAction)
                                .foregroundStyle(HFColors.textPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 42)
                                .background(HFColors.controlFill)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(secondaryTitle)
                        .accessibilityHint("Shows an alternate recovery option")
                    }
                }
            }
            .padding(isCompact ? HFSpacing.md : HFSpacing.lg)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(kind.title) error. \(title). \(message)")
        .accessibilityIdentifier("hf.error.\(kind.title.lowercased())")
    }
}
