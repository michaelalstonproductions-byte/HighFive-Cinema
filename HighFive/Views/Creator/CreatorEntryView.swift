import SwiftUI

struct CreatorEntryView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                featureGrid
                comingSoonNote
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

            Text("Build, package, and preview your work.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var featureGrid: some View {
        VStack(spacing: HFSpacing.md) {
            NavigationLink {
                CreatorStudioPreviewView()
            } label: {
                CreatorFeatureTile(
                    title: "Creator Studio",
                    subtitle: "Draft, package, and preview releases.",
                    systemImage: "film.stack.fill",
                    isLocked: false
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                CreatorDashboardPreviewView()
            } label: {
                CreatorFeatureTile(
                    title: "Creator Dashboard",
                    subtitle: "Track projects and audience signals.",
                    systemImage: "chart.bar.xaxis",
                    isLocked: false
                )
            }
            .buttonStyle(.plain)

            CreatorFeatureTile(
                title: "Creator Marketplace",
                subtitle: "Future collaboration and services hub.",
                systemImage: "storefront.fill"
            )
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var comingSoonNote: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 28)

                Text("Creator tools are coming next. Streaming foundation remains active.")
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(HFSpacing.md)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}

private struct CreatorFeatureTile: View {
    let title: String
    let subtitle: String
    let systemImage: String
    var isLocked = true

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

                        statusBadge
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

    private var statusBadge: some View {
        HStack(spacing: HFSpacing.xxs) {
            Image(systemName: isLocked ? "lock.fill" : "arrow.right")
                .font(.system(size: 9, weight: .black))
            Text(isLocked ? "Coming Soon" : "Open")
                .font(HFTypography.micro)
        }
        .foregroundStyle(.black)
        .padding(.horizontal, HFSpacing.xs)
        .padding(.vertical, 5)
        .background(HFColors.gold)
        .clipShape(Capsule())
    }
}
