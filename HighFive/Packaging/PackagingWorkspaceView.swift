import SwiftUI

struct PackagingWorkspaceView: View {
    private let project = MarkOfTheWestPromoKit.project
    private let package = MarkOfTheWestPromoKit.package
    private let hookGenerator = CaptionHookGenerator()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                ForEach(package.items) { item in
                    previewCard(for: item)
                }
            }
            .padding(20)
        }
        .background(HFColors.background.ignoresSafeArea())
        .accessibilityIdentifier("hf.packaging.workspace.preview")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(package.status.uppercased())
                .font(.system(size: 12, weight: .black))
                .tracking(1.5)
                .foregroundStyle(HFColors.gold)

            Text(package.title)
                .font(.system(size: 28, weight: .black))
                .foregroundStyle(.white)

            Text("Internal packaging workspace. No upload, network, CRM, or contact data is connected.")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.62))

            Text("Project state: \(project.shortTitle) from HFLocalProjectStore")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(HFColors.gold.opacity(0.88))
        }
    }

    private func previewCard(for item: PromoPackageItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(.white)
                    Text(item.subtitle)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.62))
                }

                Spacer()

                Text(item.isInternalOnly ? "INTERNAL" : "DRAFT")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(item.isInternalOnly ? .white.opacity(0.70) : HFColors.gold)
            }

            HStack(spacing: 8) {
                ForEach(item.exportPresets) { preset in
                    Text(preset.aspectRatioLabel)
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(.white.opacity(0.76))
                        .padding(.horizontal, 9)
                        .frame(height: 25)
                        .background(Color.white.opacity(0.07), in: Capsule())
                }
            }

            Text(hookGenerator.hooks(for: item).first ?? "Preview / Draft")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.70))
        }
        .padding(16)
        .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(HFColors.gold.opacity(item.isInternalOnly ? 0.12 : 0.22), lineWidth: 1)
        )
    }
}
