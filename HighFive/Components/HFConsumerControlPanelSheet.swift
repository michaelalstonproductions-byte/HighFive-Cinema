import SwiftUI

enum HFConsumerControlPanelContext {
    case launch
    case training
    case home
    case movieDetail
    case player
}

enum HFDepthBridgeAvailability {
    static var isProtectedBridgeAvailable: Bool {
        let controllerNames = [
            "HighFive.HKV1_SpatialPeekViewController",
            "HighFive_Cinema.HKV1_SpatialPeekViewController"
        ]

        return controllerNames.contains { NSClassFromString($0) != nil }
    }
}

struct HFConsumerControlPanelSheet: View {
    let context: HFConsumerControlPanelContext
    let protectedBridgeAvailable: Bool
    var onOpenDepthPreview: (() -> Void)?
    var onOpenVerticalStage: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    private var subtitle: String {
        switch context {
        case .launch:
            return "Depth, tilt, peek, vertical playback, and access controls are available from the app flow."
        case .training:
            return "Move the phone to see tilt and peek respond in the training stage."
        case .home:
            return "Open depth preview from Home or continue into a movie for full vertical playback."
        case .movieDetail:
            return "Play unlocked titles, open locked titles through HighFive Pass, and use full vertical playback when a source exists."
        case .player:
            return "Use depth preview or full vertical playback with motion controls."
        }
    }

    private var depthStatus: String {
        protectedBridgeAvailable ? "Protected bridge available" : "Live motion layer"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                HFColors.screenBackground
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: HFSpacing.lg) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("HighFive Controls", systemImage: "slider.horizontal.3")
                            .font(.system(size: 28, weight: .black))
                            .foregroundStyle(.white)

                        Text(subtitle)
                            .font(HFTypography.body)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(spacing: 10) {
                        HFConsumerControlRow(
                            title: "Depth",
                            value: depthStatus,
                            systemImage: "cube.transparent"
                        )
                        HFConsumerControlRow(
                            title: "Tilt + Peek",
                            value: "Motion responds in training and vertical playback",
                            systemImage: "viewfinder"
                        )
                        HFConsumerControlRow(
                            title: "Vertical Stage",
                            value: "Portrait playback opens from the player",
                            systemImage: "rectangle.portrait.fill"
                        )
                        HFConsumerControlRow(
                            title: "Source",
                            value: "Official streams stay separate from imports",
                            systemImage: "play.rectangle.fill"
                        )
                        HFConsumerControlRow(
                            title: "Access",
                            value: "Locked titles open HighFive Pass",
                            systemImage: "lock.shield.fill"
                        )
                    }

                    VStack(spacing: 10) {
                        if let onOpenDepthPreview {
                            Button {
                                dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    onOpenDepthPreview()
                                }
                            } label: {
                                Label("Open Depth Preview", systemImage: "cube.transparent")
                                    .font(HFTypography.smallAction)
                                    .foregroundStyle(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(HFColors.goldGradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }

                        if let onOpenVerticalStage {
                            Button {
                                dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    onOpenVerticalStage()
                                }
                            } label: {
                                Label("Open Full Vertical", systemImage: "rectangle.portrait.fill")
                                    .font(HFTypography.smallAction)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }

                        Button {
                            dismiss()
                        } label: {
                            Text("Done")
                                .font(HFTypography.smallAction)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 46)
                                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer(minLength: 0)
                }
                .padding(HFSpacing.lg)
            }
            .navigationTitle("Controls")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .accessibilityIdentifier("hf.consumer.controlPanel")
    }
}

private struct HFConsumerControlRow: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .black))
                .foregroundStyle(HFColors.gold)
                .frame(width: 34, height: 34)
                .background(Color.white.opacity(0.08), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(.white)
                Text(value)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.10), lineWidth: 1))
    }
}
