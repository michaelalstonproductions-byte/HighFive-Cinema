import SwiftUI

struct CreatorDashboardPreviewView: View {
    private var snapshotMetrics: [CreatorMetric] {
        let snapshot = HFLocalProjectStore.studioIntelligenceSnapshot
        return [
            CreatorMetric(title: "Slate readiness", value: snapshot.readinessLabel, systemImage: "gauge.with.dots.needle.67percent"),
            CreatorMetric(title: "Shared projects", value: "\(snapshot.projectCount)", systemImage: "square.stack.3d.up.fill"),
            CreatorMetric(title: "Review notes", value: "\(snapshot.reviewNotes)", systemImage: "text.bubble.fill"),
            CreatorMetric(title: "Marketplace interest", value: "\(snapshot.marketplaceInterest)", systemImage: "person.2.fill")
        ]
    }

    private let performanceMetrics = [
        CreatorMetric(title: "Views", value: "24.8K", systemImage: "play.rectangle.fill"),
        CreatorMetric(title: "Saves", value: "1.2K", systemImage: "bookmark.fill"),
        CreatorMetric(title: "Completion", value: "74%", systemImage: "chart.line.uptrend.xyaxis"),
        CreatorMetric(title: "Shares", value: "318", systemImage: "square.and.arrow.up.fill")
    ]

    private var topProjects: [String] {
        HFLocalProjectStore.studioIntelligenceProjects.map(\.creatorPackageTitle)
    }

    private let comingNext = [
        "Real analytics",
        "Audience cohorts",
        "Creator earnings",
        "Campaign insights"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                HFBreadcrumbTrail(items: ["Creator Mode", "Dashboard"])
                commandLinksSection
                snapshotSection
                performanceSection
                topProjectsSection
                comingNextSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Creator Dashboard")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Creator Dashboard")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .minimumScaleFactor(0.82)

            Text("Track your slate, audience signals, and creator momentum.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var commandLinksSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Creator Intelligence", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                NavigationLink {
                    CreatorWorkflowCommandCenterView()
                } label: {
                    HFActionTile(title: "Open Command Center", subtitle: "Track workflow, blockers, and recent updates.", systemImage: "command")
                }
                .buttonStyle(.plain)

                NavigationLink {
                    CreatorReleaseReadinessPreviewView()
                } label: {
                    HFActionTile(title: "Release Readiness", subtitle: "Preview blockers and launch path progress.", systemImage: "gauge.with.dots.needle.67percent")
                }
                .buttonStyle(.plain)

                NavigationLink {
                    CreatorLaunchCenterPreviewView()
                } label: {
                    HFActionTile(title: "Creator Launch Center", subtitle: "Preview launch planning, access setup, and audience signals.", systemImage: "flag.checkered")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var snapshotSection: some View {
        metricSection(title: "Snapshot", metrics: snapshotMetrics)
    }

    private var performanceSection: some View {
        metricSection(title: "Performance Preview", metrics: performanceMetrics)
    }

    private func metricSection(title: String, metrics: [CreatorMetric]) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: title, actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                ForEach(metrics) { metric in
                    CreatorMetricCard(metric: metric)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var topProjectsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Top Projects", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                VStack(spacing: HFSpacing.sm) {
                    ForEach(Array(topProjects.enumerated()), id: \.element) { index, project in
                        projectRow(index: index + 1, title: project)
                    }
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var comingNextSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Coming Next", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius) {
                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(comingNext, id: \.self) { item in
                        HStack(spacing: HFSpacing.sm) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(HFColors.gold)
                                .frame(width: 22)
                            Text(item)
                                .font(HFTypography.body)
                                .foregroundStyle(HFColors.textSecondary)
                            Spacer()
                        }
                    }
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private func projectRow(index: Int, title: String) -> some View {
        HStack(spacing: HFSpacing.md) {
            Text("\(index)")
                .font(HFTypography.caption)
                .foregroundStyle(.black)
                .frame(width: 30, height: 30)
                .background(HFColors.gold)
                .clipShape(Circle())

            Text(title)
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(.vertical, HFSpacing.xxs)
    }
}

private struct CreatorMetric: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let systemImage: String
}

private struct CreatorMetricCard: View {
    let metric: CreatorMetric

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                Image(systemName: metric.systemImage)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 40, height: 40)
                    .background(HFColors.gold.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    Text(metric.value)
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    Text(metric.title)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(HFSpacing.md)
        }
    }
}
