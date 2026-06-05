import SwiftUI

struct CreatorEntryView: View {
    @StateObject private var workflowStore = HFCreatorWorkflowStore()

    private let comingNext = [
        "Uploads",
        "Asset manager",
        "Team review",
        "Secure marketplace"
    ]

    private var quickStats: [CreatorHubMetric] {
        [
            CreatorHubMetric(title: "Draft packages", value: "3", caption: "In progress", systemImage: "shippingbox.fill"),
            CreatorHubMetric(title: "Ready for review", value: "1", caption: "Package", systemImage: "checkmark.seal.fill"),
            CreatorHubMetric(title: "Review notes", value: "\(workflowStore.openReviewNotes)", caption: "Open", systemImage: "text.bubble.fill"),
            CreatorHubMetric(title: "Marketplace interest", value: "\(workflowStore.marketplaceInterest)", caption: "Preview signal", systemImage: "person.2.fill")
        ]
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                HFBreadcrumbTrail(items: ["Creator Mode"])
                activePackageHero
                commandCenterCard
                launchCenterCard
                featureGrid
                quickStatsSection
                comingNextStrip
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Creator Mode")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Creator Mode")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .minimumScaleFactor(0.82)

            Text("Build, package, preview, and grow your HighFive slate.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Preview mode. All creator tools are local SwiftUI shells.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var activePackageHero: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: HFSpacing.md, style: .continuous)
                            .fill(HFColors.gold.opacity(0.16))
                        Image(systemName: "film.stack.fill")
                            .font(.system(size: 30, weight: .black))
                            .foregroundStyle(HFColors.gold)
                    }
                    .frame(width: 68, height: 68)

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text(workflowStore.currentProjectTitle)
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: HFSpacing.xs) {
                            CreatorStatusBadge(title: "Draft", systemImage: "pencil")
                            Text("\(Int(workflowStore.completionPercent * 100))% complete")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.gold)
                        }
                    }

                    Spacer(minLength: HFSpacing.xs)
                }

                ProgressView(value: workflowStore.completionPercent)
                    .tint(HFColors.gold)
                    .background(HFColors.glassStroke)
                    .clipShape(Capsule())

                NavigationLink {
                    CreatorPackageBuilderPreviewView()
                } label: {
                    HStack(spacing: HFSpacing.xs) {
                        Text("Continue Studio")
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .black))
                    }
                    .font(HFTypography.smallAction)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(HFColors.goldGradient)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Continue Studio")
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var commandCenterCard: some View {
        NavigationLink {
            CreatorWorkflowCommandCenterView()
        } label: {
            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
                HStack(spacing: HFSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: HFSpacing.md, style: .continuous)
                            .fill(HFColors.gold.opacity(0.16))
                        Image(systemName: "command")
                            .font(.system(size: 28, weight: .black))
                            .foregroundStyle(HFColors.gold)
                    }
                    .frame(width: 64, height: 64)

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HStack(spacing: HFSpacing.xs) {
                            Text("Workflow Command Center")
                                .font(HFTypography.menu)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)

                            Spacer(minLength: HFSpacing.xs)

                            CreatorStatusBadge(title: workflowStore.selectedWorkflowStage, systemImage: "arrow.right")
                        }

                        Text("Track package, assets, review, versions, and permissions.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(HFSpacing.md)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Workflow Command Center")
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var launchCenterCard: some View {
        NavigationLink {
            CreatorLaunchCenterPreviewView()
        } label: {
            HFActionTile(
                title: "Creator Launch Center",
                subtitle: "Prepare audience, marketplace, access, and release readiness previews.",
                systemImage: "flag.checkered"
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Creator Launch Center")
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var featureGrid: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Creator Hub", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                NavigationLink {
                    CreatorStudioPreviewView()
                } label: {
                    CreatorFeatureTile(
                        title: "Creator Studio",
                        subtitle: "Package your work",
                        status: "Active",
                        systemImage: "film.stack.fill"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open Creator Studio")

                NavigationLink {
                    CreatorPackageBuilderPreviewView()
                } label: {
                    CreatorFeatureTile(
                        title: "Package Builder",
                        subtitle: "Continue The Friendly package",
                        status: "In Progress",
                        systemImage: "shippingbox.fill"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open Package Builder")

                NavigationLink {
                    CreatorDashboardPreviewView()
                } label: {
                    CreatorFeatureTile(
                        title: "Creator Dashboard",
                        subtitle: "Track audience signals",
                        status: "Preview",
                        systemImage: "chart.bar.xaxis"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open Creator Dashboard")

                NavigationLink {
                    CreatorMarketplacePreviewView()
                } label: {
                    CreatorFeatureTile(
                        title: "Creator Marketplace",
                        subtitle: "Discover collaborators",
                        status: "Preview / Coming Soon",
                        systemImage: "storefront.fill"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open Creator Marketplace Preview")
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Quick Stats", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                ForEach(quickStats) { metric in
                    CreatorMetricCard(metric: metric)
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var comingNextStrip: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Coming Next", actionTitle: nil)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HFSpacing.sm) {
                    ForEach(comingNext, id: \.self) { item in
                        HStack(spacing: HFSpacing.xs) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 11, weight: .bold))
                            Text(item)
                                .font(HFTypography.caption)
                                .lineLimit(1)
                        }
                        .foregroundStyle(HFColors.gold)
                        .padding(.horizontal, HFSpacing.md)
                        .padding(.vertical, HFSpacing.sm)
                        .background(HFColors.gold.opacity(0.12))
                        .overlay(
                            Capsule()
                                .stroke(HFColors.goldStroke, lineWidth: 1)
                        )
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
            .scrollClipDisabled()
        }
    }
}

private struct CreatorHubMetric: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let caption: String
    let systemImage: String
}

private struct CreatorMetricCard: View {
    let metric: CreatorHubMetric

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                Image(systemName: metric.systemImage)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 36, height: 36)
                    .background(HFColors.gold.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    Text(metric.value)
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(1)

                    Text(metric.title)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(metric.caption)
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textMuted)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(HFSpacing.md)
        }
    }
}

private struct CreatorFeatureTile: View {
    let title: String
    let subtitle: String
    let status: String
    let systemImage: String

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            HStack(spacing: HFSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: HFSpacing.sm, style: .continuous)
                        .fill(HFColors.gold.opacity(0.16))
                    Image(systemName: systemImage)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                }
                .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    HStack(spacing: HFSpacing.xs) {
                        Text(title)
                            .font(HFTypography.menu)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)

                        Spacer(minLength: HFSpacing.xs)

                        CreatorStatusBadge(title: status, systemImage: "arrow.right")
                    }

                    Text(subtitle)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(HFSpacing.md)
        }
    }
}

private struct CreatorStatusBadge: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: HFSpacing.xxs) {
            Image(systemName: systemImage)
                .font(.system(size: 9, weight: .black))
            Text(title)
                .font(HFTypography.micro)
                .lineLimit(1)
                .minimumScaleFactor(0.74)
        }
        .foregroundStyle(.black)
        .padding(.horizontal, HFSpacing.xs)
        .padding(.vertical, 5)
        .background(HFColors.gold)
        .clipShape(Capsule())
    }
}
