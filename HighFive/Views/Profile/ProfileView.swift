import SwiftUI

struct ProfileView: View {
    @Binding var selectedProfile: UserProfile

    private let menuItems: [(title: String, systemImage: String)] = [
        ("Notifications", "bell.fill"),
        ("My List", "bookmark.fill"),
        ("App Settings", "gearshape.fill"),
        ("Account", "person.crop.circle.fill"),
        ("Help", "questionmark.circle.fill")
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                avatarRow

                ProfileSwitcherView(selectedProfile: $selectedProfile)
                    .padding(.horizontal, HFSpacing.screenHorizontal)

                menu
                signOutButton
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.xxl)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Text("Profiles & More")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
            Text("Manage local profiles and streaming preferences.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var avatarRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HFSpacing.md) {
                ForEach(HFMockData.userProfiles) { profile in
                    Button {
                        selectedProfile = profile
                    } label: {
                        VStack(spacing: HFSpacing.xs) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(selectedProfile.id == profile.id ? HFColors.goldGradient : LinearGradient(colors: [HFColors.surfaceElevated, HFColors.charcoal], startPoint: .topLeading, endPoint: .bottomTrailing))
                                Image(systemName: profile.avatarSystemName)
                                    .font(.system(size: 38, weight: .bold))
                                    .foregroundStyle(selectedProfile.id == profile.id ? .black : HFColors.textPrimary)
                            }
                            .frame(width: 100, height: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(selectedProfile.id == profile.id ? HFColors.gold : HFColors.glassStroke, lineWidth: 2)
                            )

                            Text(profile.name)
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textPrimary)
                                .lineLimit(1)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var menu: some View {
        VStack(spacing: HFSpacing.sm) {
            ForEach(menuItems, id: \.title) { item in
                profileMenuRow(title: item.title, systemImage: item.systemImage)
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func profileMenuRow(title: String, systemImage: String) -> some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius) {
            HStack(spacing: HFSpacing.md) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 28)

                Text(title)
                    .font(HFTypography.menu)
                    .foregroundStyle(HFColors.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(HFColors.textMuted)
            }
            .frame(height: 64)
            .padding(.horizontal, HFSpacing.md)
        }
    }

    private var signOutButton: some View {
        Button {} label: {
            Text("Sign Out")
                .font(HFTypography.menu)
                .foregroundStyle(HFColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.white.opacity(0.10))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(HFColors.glassStroke, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}
