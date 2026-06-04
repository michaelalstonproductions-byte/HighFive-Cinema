import SwiftUI

struct ProfileSwitcherView: View {
    @Binding var selectedProfile: UserProfile

    private let columns = [
        GridItem(.adaptive(minimum: 132), spacing: HFSpacing.md)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: HFSpacing.md) {
            ForEach(HFMockData.userProfiles) { profile in
                Button {
                    selectedProfile = profile
                } label: {
                    VStack(spacing: HFSpacing.sm) {
                        ZStack {
                            Circle()
                                .fill(selectedProfile.id == profile.id ? HFColors.goldGradient : LinearGradient(colors: [HFColors.charcoalLight, HFColors.charcoal], startPoint: .topLeading, endPoint: .bottomTrailing))
                            Image(systemName: profile.avatarSystemName)
                                .font(.system(size: 44, weight: .bold))
                                .foregroundStyle(selectedProfile.id == profile.id ? .black : HFColors.textPrimary)
                        }
                        .frame(width: 92, height: 92)
                        .overlay(
                            Circle()
                                .stroke(selectedProfile.id == profile.id ? HFColors.gold : HFColors.stroke, lineWidth: 2)
                        )

                        Text(profile.name)
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(1)
                    }
                    .padding(HFSpacing.md)
                    .frame(maxWidth: .infinity)
                    .background(HFColors.charcoal.opacity(0.75))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                            .stroke(selectedProfile.id == profile.id ? HFColors.goldStroke : HFColors.stroke, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
