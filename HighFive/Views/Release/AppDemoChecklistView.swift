import SwiftUI

struct AppDemoChecklistView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                HFBreadcrumbTrail(items: ["Profile", "Demo Checklist"])
                checklistSection(title: "Streaming", items: HFReleasePreviewData.streamingDemoItems)
                checklistSection(title: "Creator", items: HFReleasePreviewData.creatorDemoItems)
                checklistSection(title: "Safety", items: HFReleasePreviewData.safetyDemoItems)
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Demo Checklist")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Demo Checklist")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .minimumScaleFactor(0.78)

            Text("Walk through the current HighFive preview build.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Local QA guide only. Items do not run automation or connect services.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func checklistSection(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: title, actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: title == "Safety" ? HFColors.goldStroke : HFColors.glassStroke) {
                VStack(spacing: HFSpacing.sm) {
                    ForEach(items, id: \.self) { item in
                        HStack(spacing: HFSpacing.sm) {
                            Image(systemName: title == "Safety" ? "checkmark.shield.fill" : "checkmark.circle.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(HFColors.gold)
                                .frame(width: 24)

                            Text(item)
                                .font(HFTypography.body)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)

                            Spacer(minLength: HFSpacing.xs)

                            HFStatusBadge(title: "Preview", isProminent: false)
                        }
                        .padding(.vertical, HFSpacing.xxs)
                    }
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }
}
