import SwiftUI

struct ProfileSwitcherView: View {
    @Binding var selectedProfile: UserProfile
    var showsHeader = false

    private let columns = [
        GridItem(.flexible(), spacing: HFSpacing.md),
        GridItem(.flexible(), spacing: HFSpacing.md)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.lg) {
            if showsHeader {
                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text("Who is watching?")
                        .font(HFTypography.display)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("Choose a local profile for this session.")
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textSecondary)
                }
            }

            LazyVGrid(columns: columns, spacing: HFSpacing.md) {
                ForEach(HFMockData.userProfiles) { profile in
                    profileCard(profile)
                }

                addProfileCard
            }

            Button {} label: {
                Text("Manage Profiles")
                    .font(HFTypography.smallAction)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(HFColors.goldGradient)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private func profileCard(_ profile: UserProfile) -> some View {
        Button {
            selectedProfile = profile
        } label: {
            VStack(spacing: HFSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(selectedProfile.id == profile.id ? HFColors.goldGradient : LinearGradient(colors: [HFColors.surfaceElevated, HFColors.charcoal], startPoint: .topLeading, endPoint: .bottomTrailing))
                    Image(systemName: profile.avatarSystemName)
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(selectedProfile.id == profile.id ? .black : HFColors.textPrimary)
                }
                .frame(width: 82, height: 82)
                .overlay(
                    Circle()
                        .stroke(selectedProfile.id == profile.id ? HFColors.gold : HFColors.glassStroke, lineWidth: 2)
                )

                Text(profile.name)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: HFSpacing.profileCardHeight)
            .background(HFColors.surface.opacity(0.78))
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                    .stroke(selectedProfile.id == profile.id ? HFColors.goldStroke : HFColors.glassStroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var addProfileCard: some View {
        Button {} label: {
            VStack(spacing: HFSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(HFColors.gold.opacity(0.16))
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                }
                .frame(width: 58, height: 58)

                Text("Add Profile")
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 136)
            .background(HFColors.surface.opacity(0.58))
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                    .stroke(HFColors.glassStroke, style: StrokeStyle(lineWidth: 1, dash: [6, 6]))
            )
        }
        .buttonStyle(.plain)
    }
}
