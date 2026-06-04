import SwiftUI

struct HFEmptyState: View {
    let title: String
    let message: String
    var systemImage: String = "film.stack"
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(spacing: HFSpacing.md) {
                Image(systemName: systemImage)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(HFColors.gold)

                VStack(spacing: HFSpacing.xs) {
                    Text(title)
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                        .multilineTextAlignment(.center)
                    Text(message)
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                if let actionTitle, let action {
                    Button(action: action) {
                        Text(actionTitle)
                            .font(HFTypography.smallAction)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(HFColors.goldGradient)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(HFSpacing.xl)
            .frame(maxWidth: .infinity)
        }
    }
}
