import SwiftUI

struct CreatorAccessPreviewView: View {
    @StateObject private var workflowStore = HFCreatorWorkflowStore()

    private let accessModels = [
        CreatorAccessModel(title: "Free Preview", detail: "Includes trailer, poster, synopsis", systemImage: "play.rectangle.fill"),
        CreatorAccessModel(title: "Premium Package", detail: "Includes full feature, extras, creator notes", systemImage: "sparkles"),
        CreatorAccessModel(title: "Studio Access", detail: "Includes review package, submission notes, team review", systemImage: "person.badge.shield.checkmark.fill")
    ]

    private let unlockNotes = [
        "This is a mock access screen.",
        "No purchases are processed.",
        "No payments are connected.",
        "No subscriptions are active."
    ]

    private let comingNext = [
        "Real StoreKit integration",
        "Secure access rules",
        "Entitlements",
        "Creator payouts",
        "Marketplace purchases"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                HFBreadcrumbTrail(items: ["Creator Mode", "Access Preview"])
                accessModelSection
                mockPlansSection
                unlockPreviewSection
                comingNextSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Access Preview")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Access Preview")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .minimumScaleFactor(0.78)

            Text("Preview how audiences may unlock premium creator packages.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Mock only. No payment, StoreKit, subscription, or entitlement logic is connected.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var accessModelSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Access Model", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(accessModels) { model in
                    HFActionTile(title: model.title, subtitle: model.detail, systemImage: model.systemImage, trailingSystemImage: "lock.fill")
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var mockPlansSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Mock Plans", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(workflowStore.mockAccessPlans) { plan in
                    accessPlanCard(plan)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var unlockPreviewSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Unlock Preview", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(unlockNotes, id: \.self) { note in
                        HStack(alignment: .top, spacing: HFSpacing.sm) {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(HFColors.gold)
                                .frame(width: 22)

                            Text(note)
                                .font(HFTypography.body)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
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

    private func accessPlanCard(_ plan: HFCreatorAccessPlan) -> some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            HStack(spacing: HFSpacing.md) {
                Image(systemName: plan.systemImage)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 42, height: 42)
                    .background(HFColors.gold.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    Text(plan.title)
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textPrimary)
                    Text(plan.detail)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                }

                Spacer(minLength: HFSpacing.xs)

                HFStatusBadge(title: plan.status, isProminent: false)
            }
            .padding(HFSpacing.md)
        }
    }
}

private struct CreatorAccessModel: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let systemImage: String
}
