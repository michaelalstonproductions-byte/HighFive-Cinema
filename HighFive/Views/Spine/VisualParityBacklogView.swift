import SwiftUI

struct VisualParityBacklogView: View {
    private let groups = [
        "Home + Core Tabs",
        "Watch + Movie Detail",
        "Creator",
        "Connect",
        "Launch",
        "Export",
        "Global Design System"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                backlogNotice
                preVisualNotice
                ForEach(groups, id: \.self) { group in
                    backlogSection(title: group, group: group)
                }
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Visual Backlog")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFStatusBadge(title: "After Spine Lock", isProminent: true)

            Text("Visual Parity Backlog")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text("What we will make match the mockups after the spine is complete.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var backlogNotice: some View {
        HFInsightCard(
            title: "Planning surface only",
            message: "This screen does not modify Figma, sync mockups, change assets, or attempt pixel-perfect work in this phase.",
            systemImage: "rectangle.3.group.fill"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var preVisualNotice: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFInsightCard(
                title: "Visual parity waits",
                message: "Visual parity starts after Product Spine Gap Review and Pre-Visual Lock pass QA.",
                systemImage: "checkmark.seal.fill"
            )

            HFInsightCard(
                title: "Run readiness first",
                message: "Before visual parity starts, run Pre-Mockup Readiness Review.",
                systemImage: "checkmark.circle.fill"
            )

            NavigationLink {
                PreVisualLockView()
            } label: {
                HFActionTile(title: "Pre-Visual Lock", subtitle: "Confirm structure is stable before mockup matching.", systemImage: "checkmark.seal.fill")
            }
            .buttonStyle(.plain)

            NavigationLink {
                PreMockupReadinessReviewView()
            } label: {
                HFActionTile(title: "Pre-Mockup Readiness Review", subtitle: "Check route quality, dead-end cleanup, and local-only safety before visual matching.", systemImage: "checkmark.circle.fill")
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func backlogSection(title: String, group: String) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: title, actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFProductSpineCompletionData.backlog(for: group)) { item in
                    HFVisualParityBacklogCard(item: item)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }
}
