import SwiftUI

struct HFBackendStatusPanel: View {
    let runtimeStatus: HFBackendRuntimeStatus

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: runtimeStatus.status.systemImage)
                        .font(.system(size: 21, weight: .black))
                        .foregroundStyle(.black)
                        .frame(width: 48, height: 48)
                        .background(HFColors.goldGradient)
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text("Backend Services")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(runtimeStatus.status.statusLabel)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)
                        Text(runtimeStatus.status.detail)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(spacing: HFSpacing.xs) {
                    ForEach(runtimeStatus.services) { service in
                        HFBackendServiceRow(status: service)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityIdentifier("hf.backend.statusPanel")
    }
}

private struct HFBackendServiceRow: View {
    let status: HFBackendServiceStatus

    var body: some View {
        HStack(spacing: HFSpacing.sm) {
            Image(systemName: status.systemImage)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(HFColors.gold)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                Text(status.title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                Text(status.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textMuted)
                    .lineLimit(2)
            }

            Spacer(minLength: HFSpacing.xs)

            Text(status.statusLabel)
                .font(HFTypography.micro)
                .foregroundStyle(status.isConfigured ? HFColors.gold : HFColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .padding(.horizontal, HFSpacing.xs)
                .frame(height: 24)
                .background(Color.white.opacity(0.08))
                .clipShape(Capsule())
        }
        .accessibilityIdentifier(status.accessibilityIdentifier)
    }
}
