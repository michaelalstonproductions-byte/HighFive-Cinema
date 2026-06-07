import SwiftUI

struct PreVisualLockView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                structureBeforeStyleSection
                visualParityLaterSection
                doesNotDoSection
                preMockupReadinessSection
                preVisualRule
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Pre-Visual Lock")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFStatusBadge(title: "Before mockups", isProminent: true)

            Text("Pre-Visual Lock")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text("Confirm what must be stable before matching the mockups.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var structureBeforeStyleSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Structure Before Style", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                HFPreVisualLockCard(title: "Product spine stable", subtitle: "Watch, Create, Connect, Launch, and Export are reviewable.", status: "Required", systemImage: "rectangle.connected.to.line.below")
                HFPreVisualLockCard(title: "Route coverage stable", subtitle: "Each pillar has an explicit local review path or locked placeholder.", status: "Required", systemImage: "arrow.triangle.branch")
                HFPreVisualLockCard(title: "Pillar review paths stable", subtitle: "QA can walk repeatable paths without guessing.", status: "Required", systemImage: "map.fill")
                HFPreVisualLockCard(title: "Locked systems documented", subtitle: "Real systems are named and left disconnected.", status: "Required", systemImage: "lock.shield.fill")
                HFPreVisualLockCard(title: "Visual parity backlog documented", subtitle: "Later mockup work is named without starting it here.", status: "Required", systemImage: "rectangle.3.group.fill")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var visualParityLaterSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "What Visual Parity Will Handle Later", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFProductSpineGapData.futureVisualItems) { item in
                    HFPreVisualLockCard(title: item.title, subtitle: item.subtitle, status: item.status, systemImage: item.systemImage)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var doesNotDoSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "What This Phase Does Not Do", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach([
                    "Does not modify Figma",
                    "Does not change assets",
                    "Does not change poster mappings",
                    "Does not do pixel-perfect layout",
                    "Does not connect real systems"
                ], id: \.self) { item in
                    HFPreVisualLockCard(title: item, subtitle: "Locked until a separate scoped phase.", status: "Locked", systemImage: "lock.fill")
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var preMockupReadinessSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Pre-Mockup Readiness", actionTitle: nil)

            NavigationLink {
                PreMockupReadinessReviewView()
            } label: {
                HFActionTile(title: "Pre-Mockup Readiness Review", subtitle: "Confirm route quality and dead-end cleanup before visual parity.", systemImage: "checkmark.seal.fill")
            }
            .buttonStyle(.plain)
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var preVisualRule: some View {
        HFInsightCard(
            title: "Pre-Visual Rule",
            message: "After the spine is QA-passed, the next major effort can focus on making the UI match the mockups.",
            systemImage: "checkmark.seal.fill"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}
