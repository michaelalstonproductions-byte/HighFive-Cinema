import SwiftUI

private enum HFCreatorOSStage: String, CaseIterable, Identifiable {
    case development = "Development"
    case packaging = "Packaging"
    case qa = "QA"
    case release = "Release"
    case marketing = "Marketing"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .development: return "hammer.fill"
        case .packaging: return "shippingbox.fill"
        case .qa: return "checkmark.seal.fill"
        case .release: return "sparkles.tv.fill"
        case .marketing: return "megaphone.fill"
        }
    }
}

private struct HFCreatorOSProject: Identifiable {
    let id: String
    let title: String
    let status: String
    let packaging: Int
    let release: Int
    let analytics: String
}

struct CreatorOSWorkspaceView: View {
    @State private var selectedStage: HFCreatorOSStage = .packaging
    @State private var completedReleaseItems: Set<String> = ["Poster package", "Social captions", "Synopsis"]
    @State private var completedAssets: Set<String> = ["Posters", "Artwork"]

    private let projects = [
        HFCreatorOSProject(id: "mark-west", title: "The Mark of the West", status: "Packaging", packaging: 72, release: 48, analytics: "Trailer draft pending"),
        HFCreatorOSProject(id: "paranormall", title: "Paranormall", status: "Release QA", packaging: 86, release: 74, analytics: "High interest"),
        HFCreatorOSProject(id: "friendly", title: "The Friendly", status: "Live package", packaging: 94, release: 88, analytics: "Stable")
    ]

    private let releaseItems = [
        "Publishing checklist",
        "Package readiness",
        "Distribution status",
        "Approval workflow",
        "Release notes"
    ]

    private let assetItems = [
        "Posters",
        "Trailers",
        "Artwork",
        "Documents",
        "Version History"
    ]

    private var releaseReadiness: Int {
        readinessScore(selected: completedReleaseItems, total: releaseItems.count)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                hero
                creatorDashboard
                assetManagerShell
                releaseCenterShell
                analyticsShell
                studioTimeline
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
            .padding(.top, 28)
            .padding(.bottom, 44)
        }
        .background(workspaceBackground)
        .navigationTitle("Creator OS")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("hf.creatorOS.workspace")
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black,
                            HFColors.gold.opacity(0.14),
                            HFColors.cyanGlow.opacity(0.08),
                            Color.black.opacity(0.94)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(HFLayer4VolumetricGlow(motion: .still, tint: HFColors.gold, intensity: 0.62))
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(HFColors.gold.opacity(0.30), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.44), radius: 30, x: 0, y: 18)

            VStack(alignment: .leading, spacing: 12) {
                Text("LOCAL CREATOR OPERATING SYSTEM")
                    .font(.system(size: 12, weight: .black))
                    .tracking(1.6)
                    .foregroundStyle(HFColors.gold)

                Text("Creator OS")
                    .font(.system(size: 38, weight: .black))
                    .foregroundStyle(.white)

                Text("Projects, assets, packaging readiness, release status, analytics, and timeline in one local workspace. No backend, upload, publishing, auth, or CRM connection is active.")
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    osPill("Local State")
                    osPill("No Upload")
                    osPill("No CRM")
                }
            }
            .padding(22)
        }
        .frame(minHeight: 250)
    }

    private var creatorDashboard: some View {
        osPanel(title: "Creator Dashboard", subtitle: "Unified local command view", systemImage: "rectangle.3.group.fill", identifier: "hf.creatorOS.dashboard") {
            VStack(alignment: .leading, spacing: 16) {
                dashboardMetricGrid
                activeProjects
                quickActions
            }
        }
    }

    private var assetManagerShell: some View {
        osPanel(title: "Asset Manager", subtitle: "Local/demo asset organization", systemImage: "folder.fill", identifier: "hf.creatorOS.assets") {
            VStack(spacing: 8) {
                ForEach(assetItems, id: \.self) { item in
                    toggleRow(item, selected: $completedAssets)
                }
            }
        }
    }

    private var releaseCenterShell: some View {
        osPanel(title: "Release Center", subtitle: "Publishing readiness without publishing", systemImage: "flag.checkered.2.crossed", identifier: "hf.creatorOS.releaseCenter") {
            VStack(alignment: .leading, spacing: 14) {
                readinessMeter(title: "Release Readiness", score: releaseReadiness)
                VStack(spacing: 8) {
                    ForEach(releaseItems, id: \.self) { item in
                        toggleRow(item, selected: $completedReleaseItems)
                    }
                }
            }
        }
    }

    private var analyticsShell: some View {
        osPanel(title: "Analytics", subtitle: "Local-only metrics preview", systemImage: "chart.xyaxis.line", identifier: "hf.creatorOS.analytics") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                analyticsTile(title: "Trailer Engagement", value: "Local Draft", systemImage: "play.rectangle.fill")
                analyticsTile(title: "Package Completion", value: "\(averagePackaging)%", systemImage: "shippingbox.fill")
                analyticsTile(title: "Readiness Trends", value: "Rising", systemImage: "chart.line.uptrend.xyaxis")
                analyticsTile(title: "Metrics Source", value: "Local Only", systemImage: "lock.shield.fill")
            }
        }
    }

    private var studioTimeline: some View {
        osPanel(title: "Studio Timeline", subtitle: "Development to marketing", systemImage: "timeline.selection", identifier: "hf.creatorOS.timeline") {
            VStack(spacing: 10) {
                ForEach(HFCreatorOSStage.allCases) { stage in
                    Button {
                        selectedStage = stage
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: stage.systemImage)
                                .font(.system(size: 16, weight: .black))
                                .foregroundStyle(selectedStage == stage ? .black : HFColors.gold)
                                .frame(width: 38, height: 38)
                                .background(selectedStage == stage ? HFColors.gold : Color.white.opacity(0.07), in: Circle())

                            VStack(alignment: .leading, spacing: 3) {
                                Text(stage.rawValue)
                                    .font(HFTypography.caption.weight(.black))
                                    .foregroundStyle(HFColors.textPrimary)
                                Text(stageDetail(stage))
                                    .font(HFTypography.micro.weight(.semibold))
                                    .foregroundStyle(HFColors.textSecondary)
                            }

                            Spacer()

                            Text(selectedStage == stage ? "Active" : "Queued")
                                .font(HFTypography.micro.weight(.black))
                                .foregroundStyle(selectedStage == stage ? HFColors.gold : HFColors.textMuted)
                        }
                        .padding(12)
                        .background(Color.white.opacity(selectedStage == stage ? 0.070 : 0.040), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var dashboardMetricGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            dashboardMetric(title: "Active Projects", value: "\(projects.count)", systemImage: "film.stack.fill")
            dashboardMetric(title: "Release Status", value: "\(releaseReadiness)%", systemImage: "checkmark.seal.fill")
            dashboardMetric(title: "Packaging Status", value: "\(averagePackaging)%", systemImage: "shippingbox.fill")
            dashboardMetric(title: "Analytics Summary", value: "Local", systemImage: "chart.bar.fill")
        }
    }

    private var activeProjects: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Active Projects")
                .font(HFTypography.caption.weight(.black))
                .foregroundStyle(HFColors.gold)
                .textCase(.uppercase)

            ForEach(projects) { project in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(project.title)
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                        Spacer()
                        Text(project.status)
                            .font(HFTypography.micro.weight(.black))
                            .foregroundStyle(HFColors.gold)
                    }
                    HStack(spacing: 8) {
                        projectPill("Package \(project.packaging)%")
                        projectPill("Release \(project.release)%")
                        projectPill(project.analytics)
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Actions")
                .font(HFTypography.caption.weight(.black))
                .foregroundStyle(HFColors.gold)
                .textCase(.uppercase)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                quickAction("Review Assets", "folder.fill")
                quickAction("Open Packaging", "shippingbox.fill")
                quickAction("Check Release", "checkmark.seal.fill")
                quickAction("View Timeline", "timeline.selection")
            }
        }
    }

    private var averagePackaging: Int {
        guard !projects.isEmpty else { return 0 }
        return projects.map(\.packaging).reduce(0, +) / projects.count
    }

    private var workspaceBackground: some View {
        ZStack {
            HFColors.background.ignoresSafeArea()
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.030, green: 0.026, blue: 0.020),
                    HFColors.background
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            RadialGradient(
                colors: [HFColors.gold.opacity(0.14), .clear],
                center: .topTrailing,
                startRadius: 18,
                endRadius: 560
            )
            .ignoresSafeArea()
        }
    }

    private func osPanel<Content: View>(
        title: String,
        subtitle: String,
        systemImage: String,
        identifier: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.075), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(HFColors.textPrimary)
                    Text(subtitle)
                        .font(HFTypography.caption.weight(.semibold))
                        .foregroundStyle(HFColors.textSecondary)
                }

                Spacer()
            }

            content()
        }
        .padding(18)
        .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(HFColors.gold.opacity(0.16), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.28), radius: 18, x: 0, y: 10)
        .accessibilityIdentifier(identifier)
    }

    private func dashboardMetric(title: String, value: String, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(HFColors.gold)
            Text(value)
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
            Text(title)
                .font(HFTypography.caption.weight(.bold))
                .foregroundStyle(HFColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func analyticsTile(title: String, value: String, systemImage: String) -> some View {
        dashboardMetric(title: title, value: value, systemImage: systemImage)
    }

    private func quickAction(_ title: String, _ systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(HFTypography.caption.weight(.black))
            .foregroundStyle(HFColors.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.white.opacity(0.055), in: Capsule())
            .overlay(Capsule().stroke(HFColors.gold.opacity(0.14), lineWidth: 1))
    }

    private func toggleRow(_ title: String, selected: Binding<Set<String>>) -> some View {
        Button {
            if selected.wrappedValue.contains(title) {
                selected.wrappedValue.remove(title)
            } else {
                selected.wrappedValue.insert(title)
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: selected.wrappedValue.contains(title) ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(selected.wrappedValue.contains(title) ? HFColors.gold : HFColors.textMuted)
                Text(title)
                    .font(HFTypography.caption.weight(.semibold))
                    .foregroundStyle(HFColors.textPrimary)
                Spacer()
                Text(selected.wrappedValue.contains(title) ? "Ready" : "Draft")
                    .font(HFTypography.micro.weight(.black))
                    .foregroundStyle(selected.wrappedValue.contains(title) ? HFColors.gold : HFColors.textMuted)
            }
            .padding(.horizontal, 12)
            .frame(height: 40)
            .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func readinessMeter(title: String, score: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(HFTypography.caption.weight(.black))
                    .foregroundStyle(HFColors.textPrimary)
                Spacer()
                Text("\(score)%")
                    .font(HFTypography.caption.weight(.black))
                    .foregroundStyle(HFColors.gold)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.08))
                    Capsule()
                        .fill(HFColors.goldGradient)
                        .frame(width: proxy.size.width * CGFloat(score) / 100)
                }
            }
            .frame(height: 7)
        }
    }

    private func readinessScore(selected: Set<String>, total: Int) -> Int {
        guard total > 0 else { return 0 }
        return Int((Double(selected.count) / Double(total) * 100).rounded())
    }

    private func osPill(_ title: String) -> some View {
        Text(title)
            .font(HFTypography.micro.weight(.black))
            .foregroundStyle(HFColors.gold)
            .padding(.horizontal, 10)
            .frame(height: 28)
            .background(Color.white.opacity(0.075), in: Capsule())
    }

    private func projectPill(_ title: String) -> some View {
        Text(title)
            .font(HFTypography.micro.weight(.black))
            .foregroundStyle(HFColors.textSecondary)
            .padding(.horizontal, 8)
            .frame(height: 24)
            .background(Color.white.opacity(0.06), in: Capsule())
    }

    private func stageDetail(_ stage: HFCreatorOSStage) -> String {
        switch stage {
        case .development: return "Project concept, story, and asset planning."
        case .packaging: return "Poster, social, press, and launch materials."
        case .qa: return "Review readiness, copy, and package completeness."
        case .release: return "Distribution checklist and approval state."
        case .marketing: return "Social rollout, press notes, and campaign rhythm."
        }
    }
}
