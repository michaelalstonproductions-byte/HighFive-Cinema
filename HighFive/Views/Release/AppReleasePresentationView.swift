import SwiftUI

struct AppReleasePresentationView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                HFBreadcrumbTrail(items: ["Profile", "HighFive Preview"])
                productSnapshotSection
                featureHighlightsSection
                demoChecklistSection
                releaseNotesSection
                comingNextSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("HighFive Preview")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("HighFive Cinema Preview")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .minimumScaleFactor(0.76)

            Text("Streaming, creator tools, marketplace readiness, and cinematic workflow in one app.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Preview only. No app submission, StoreKit, backend, or live services are connected.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var productSnapshotSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Product Snapshot", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                VStack(spacing: HFSpacing.sm) {
                    ForEach(HFReleasePreviewData.productSnapshot) { item in
                        statusRow(item)
                    }
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var featureHighlightsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Feature Highlights", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFReleasePreviewData.featureHighlights) { feature in
                    HFActionTile(title: feature.title, subtitle: feature.detail, systemImage: feature.systemImage, trailingSystemImage: "sparkles")
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var demoChecklistSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Demo Checklist", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.glassStroke) {
                VStack(spacing: HFSpacing.sm) {
                    ForEach(HFReleasePreviewData.demoChecklist) { item in
                        checklistRow(title: item.title, status: "Ready")
                    }
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var releaseNotesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Release Notes Preview", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                VStack(spacing: HFSpacing.sm) {
                    ForEach(HFReleasePreviewData.releaseNotes) { note in
                        HStack(alignment: .top, spacing: HFSpacing.md) {
                            HFStatusBadge(title: note.phase, isProminent: false)
                            Text(note.detail)
                                .font(HFTypography.body)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, HFSpacing.xxs)
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
                    ForEach(HFReleasePreviewData.releaseComingNext, id: \.self) { item in
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

    private func statusRow(_ item: HFReleaseStatusItem) -> some View {
        HStack(spacing: HFSpacing.md) {
            Image(systemName: item.systemImage)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(HFColors.gold)
                .frame(width: 36, height: 36)
                .background(HFColors.gold.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

            Text(item.title)
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: HFSpacing.xs)

            HFStatusBadge(title: item.status, isProminent: item.status == "Ready" || item.status == "Untouched")
        }
        .padding(.vertical, HFSpacing.xxs)
    }

    private func checklistRow(title: String, status: String) -> some View {
        HStack(spacing: HFSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(HFColors.gold)
                .frame(width: 24)
            Text(title)
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textPrimary)
            Spacer()
            HFStatusBadge(title: status, isProminent: false)
        }
        .padding(.vertical, HFSpacing.xxs)
    }
}
