import SwiftUI

struct HFAppSettingsView: View {
    @AppStorage("hf.settings.autoplayPreviews") private var autoplayPreviews = true
    @AppStorage("hf.settings.motionEffectsEnabled") private var motionEffectsEnabled = true
    @AppStorage("hf.settings.hapticsEnabled") private var hapticsEnabled = true
    @AppStorage("hf.settings.allowCellularStreaming") private var allowCellularStreaming = true
    @AppStorage("hf.settings.downloadsWifiOnly") private var downloadsWifiOnly = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                settingsCard(title: "Playback", systemImage: "play.circle.fill") {
                    Toggle("Autoplay Previews", isOn: $autoplayPreviews)
                        .accessibilityIdentifier("hf.settings.autoplayPreviews")

                    Toggle("Stream Over Cellular", isOn: $allowCellularStreaming)
                        .accessibilityIdentifier("hf.settings.allowCellularStreaming")
                }

                settingsCard(title: "Motion", systemImage: "gyroscope") {
                    Toggle("Motion Effects", isOn: $motionEffectsEnabled)
                        .accessibilityIdentifier("hf.settings.motionEffects")

                    Text("Depth, Tilt, and Peek may also follow device accessibility settings such as Reduce Motion.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                settingsCard(title: "Downloads", systemImage: "arrow.down.circle.fill") {
                    Toggle("Download on Wi-Fi Only", isOn: $downloadsWifiOnly)
                        .accessibilityIdentifier("hf.settings.downloadsWifiOnly")
                }

                settingsCard(title: "Feel", systemImage: "waveform.path") {
                    Toggle("Haptics", isOn: $hapticsEnabled)
                        .accessibilityIdentifier("hf.settings.haptics")
                }

                settingsCard(title: "App", systemImage: "info.circle.fill") {
                    HStack {
                        Text("Version")
                            .font(HFTypography.body)
                            .foregroundStyle(HFColors.textPrimary)
                        Spacer()
                        Text(HFSupportConfig.appVersionDisplay)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(HFColors.textSecondary)
                    }
                    .accessibilityIdentifier("hf.settings.appVersion")

                    #if DEBUG
                    Button(role: .destructive) {
                        HFLegalDocuments.resetLocalAcceptanceForDebug()
                    } label: {
                        Text("Reset Legal Agreement")
                            .font(.system(size: 14, weight: .black))
                    }
                    .accessibilityIdentifier("hf.settings.resetLegalDebug")
                    #endif
                }
            }
            .padding(20)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("App Settings")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("hf.settings.screen")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("App Settings")
                .font(.system(size: 34, weight: .black))
                .foregroundStyle(HFColors.textPrimary)

            Text("Control playback preferences, motion comfort, downloads, and app information.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func settingsCard<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .foregroundStyle(HFColors.gold)
                Text(title)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(HFColors.textPrimary)
            }

            VStack(spacing: 12) {
                content()
            }
            .tint(HFColors.gold)
        }
        .padding(16)
        .background(Color.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }
}
