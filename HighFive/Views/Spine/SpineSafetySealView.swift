import SwiftUI

struct SpineSafetySealView: View {
    private let categories = ["Real Services", "Media + Capture", "Design + Protected Paths"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header

                ForEach(categories, id: \.self) { category in
                    safetySection(title: sectionTitle(for: category), category: category)
                }

                safetyRule
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Spine Safety Seal")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFStatusBadge(title: "Internal safety", isProminent: true)

            Text("Spine Safety Seal")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text("Internal safety review confirming real systems, protected paths, assets, and permission files remain untouched.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func safetySection(title: String, category: String) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: title, actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFProductSpineFinalWalkthroughData.safetyItems(for: category)) { item in
                    HFSpineSafetySealCard(item: item)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private func sectionTitle(for category: String) -> String {
        switch category {
        case "Real Services":
            return "Real Services Locked"
        case "Media + Capture":
            return "Media + Capture Locked"
        default:
            return "Design + Protected Paths Locked"
        }
    }

    private var safetyRule: some View {
        HFInsightCard(
            title: "Safety Rule",
            message: "Visual polish cannot introduce real systems, protected media changes, or asset/poster/Figma drift.",
            systemImage: "lock.shield.fill"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}
