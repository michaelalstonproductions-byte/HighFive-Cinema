import SwiftUI

struct VisualPassLaunchChecklistView: View {
    private let checkpointTypes = ["Repo Requirements", "Product Requirements", "Visual Scope Requirements"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header

                ForEach(checkpointTypes, id: \.self) { type in
                    checkpointSection(title: type, checkpointType: type)
                }

                checklistRule
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Visual Pass Checklist")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFStatusBadge(title: "Internal checklist", isProminent: true)

            Text("Visual Pass Launch Checklist")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text("Internal checklist for the visual pass. It is not a customer-facing screen and must not change product scope.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func checkpointSection(title: String, checkpointType: String) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: title, actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFProductSpineFinalWalkthroughData.checkpoints(for: checkpointType)) { checkpoint in
                    HFVisualPassChecklistCard(checkpoint: checkpoint)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var checklistRule: some View {
        HFInsightCard(
            title: "Checklist Rule",
            message: "The visual pass is styling/layout only. It must not change product scope.",
            systemImage: "checkmark.seal.fill"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}
