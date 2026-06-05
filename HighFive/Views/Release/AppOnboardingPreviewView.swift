import SwiftUI

struct AppOnboardingPreviewView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                HFBreadcrumbTrail(items: ["Profile", "Onboarding Preview"])
                stepperVisual
                onboardingStepsSection
                previewNoteSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Onboarding Preview")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Onboarding Preview")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .minimumScaleFactor(0.78)

            Text("Introduce viewers and creators to HighFive Cinema.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Mock only. This screen is not wired into the app launch flow.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var stepperVisual: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            HStack(spacing: HFSpacing.sm) {
                ForEach(Array(HFReleasePreviewData.onboardingSteps.enumerated()), id: \.element.id) { index, step in
                    VStack(spacing: HFSpacing.xs) {
                        Text("\(index + 1)")
                            .font(HFTypography.micro)
                            .foregroundStyle(index == 0 ? .black : HFColors.gold)
                            .frame(width: 30, height: 30)
                            .background(index == 0 ? AnyShapeStyle(HFColors.gold) : AnyShapeStyle(HFColors.gold.opacity(0.14)))
                            .clipShape(Circle())

                        Text(step.title)
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(HFSpacing.md)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var onboardingStepsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Preview Pages", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFReleasePreviewData.onboardingSteps) { step in
                    HFActionTile(title: step.title, subtitle: step.detail, systemImage: step.systemImage, trailingSystemImage: "circle.fill")
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var previewNoteSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.glassStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                Text("Launch behavior is unchanged.")
                    .font(HFTypography.section)
                    .foregroundStyle(HFColors.textPrimary)
                Text("This preview documents the intended first-run story for testers and partners without replacing the real app entry point.")
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(HFSpacing.md)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}
