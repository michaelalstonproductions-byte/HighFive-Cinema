import SwiftUI

struct HFProfileAvatarCard: View {
    let profile: UserProfile
    let isSelected: Bool
    var compact = false

    var body: some View {
        VStack(spacing: HFSpacing.xs) {
            ZStack {
                RoundedRectangle(cornerRadius: compact ? 22 : 24, style: .continuous)
                    .fill(isSelected ? HFColors.goldGradient : LinearGradient(colors: [HFColors.surfaceElevated, HFColors.charcoal], startPoint: .topLeading, endPoint: .bottomTrailing))
                Image(systemName: profile.avatarSystemName)
                    .font(.system(size: compact ? 32 : 38, weight: .bold))
                    .foregroundStyle(isSelected ? .black : HFColors.textPrimary)
            }
            .frame(width: compact ? 84 : 100, height: compact ? 84 : 100)
            .overlay(
                RoundedRectangle(cornerRadius: compact ? 22 : 24, style: .continuous)
                    .stroke(isSelected ? HFColors.gold : HFColors.glassStroke, lineWidth: 2)
            )

            Text(profile.name)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
        }
    }
}
