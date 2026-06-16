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

struct HFBackendStatusView: View {
    @EnvironmentObject private var streamingStore: HFStreamingStore

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                runtimeConfigSection
                healthSection
                serviceListSection
                localFallbackSection
                noSecretsSection
            }
            .padding(.top, HFSpacing.xxl)
            .padding(.bottom, HFSpacing.xxl)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Backend Status")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("hf.backendStatus.screen")
        .task {
            await streamingStore.refreshBackendRuntimeStatus()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Label("Backend Status", systemImage: streamingStore.backendStatus.systemImage)
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text(streamingStore.backendStatus.statusLabel)
                .font(HFTypography.section)
                .foregroundStyle(HFColors.gold)

            Text(streamingStore.backendStatus.detail)
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.backend.status")
    }

    private var runtimeConfigSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionTitle("Runtime Config", systemImage: "slider.horizontal.3")

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.backendRuntimeConfigRows) { row in
                        HStack {
                            Text(row.title)
                                .font(HFTypography.micro)
                                .foregroundStyle(HFColors.textSecondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.72)
                            Spacer()
                            Text(row.status)
                                .font(HFTypography.micro)
                                .foregroundStyle(row.status == "Present" ? HFColors.gold : HFColors.textMuted)
                        }
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.backendStatus.runtimeConfig")
    }

    private var healthSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionTitle("Health Check", systemImage: streamingStore.backendHealthSummary.systemImage)
                statusRow(streamingStore.backendHealthSummary)
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.backendStatus.health")
    }

    private var serviceListSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.glassStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionTitle("Services", systemImage: "list.bullet.rectangle")

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.backendServiceStatuses) { service in
                        statusRow(service)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.backendStatus.serviceList")
    }

    private var localFallbackSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.24)) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                sectionTitle("Local fallback active", systemImage: "arrow.triangle.2.circlepath")
                Text(streamingStore.backendLocalFallbackNote)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.backendStatus.localFallback")
    }

    private var noSecretsSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.glassStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                sectionTitle("No secrets stored in app", systemImage: "lock.shield.fill")
                Text("Runtime Config displays presence only. Values, credentials, tokens, and production URLs are not committed or shown.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.backendStatus.noSecrets")
    }

    private func sectionTitle(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(HFTypography.section)
            .foregroundStyle(HFColors.textPrimary)
    }

    private func statusRow(_ status: HFBackendServiceStatus) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: status.systemImage)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(HFColors.gold)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                Text(status.title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                Text(status.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
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
