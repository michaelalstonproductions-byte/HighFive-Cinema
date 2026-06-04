import SwiftUI

struct ProfileView: View {
    @Binding var selectedProfile: UserProfile

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text("Profiles")
                        .font(HFTypography.display)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("Choose a local streaming profile for this session.")
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textSecondary)
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
                .padding(.top, HFSpacing.lg)

                ProfileSwitcherView(selectedProfile: $selectedProfile)
                    .padding(.horizontal, HFSpacing.screenHorizontal)

                HFGlassPanel {
                    VStack(alignment: .leading, spacing: HFSpacing.md) {
                        HStack(spacing: HFSpacing.md) {
                            Image(systemName: selectedProfile.avatarSystemName)
                                .font(.system(size: 42, weight: .bold))
                                .foregroundStyle(HFColors.gold)
                            VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                                Text(selectedProfile.name)
                                    .font(HFTypography.section)
                                    .foregroundStyle(HFColors.textPrimary)
                                Text(selectedProfile.isKidsProfile ? "Kids profile" : "Standard profile")
                                    .font(HFTypography.body)
                                    .foregroundStyle(HFColors.textSecondary)
                            }
                        }

                        Divider()
                            .overlay(HFColors.stroke)

                        profileRow("Playback", value: "Local preview")
                        profileRow("Downloads", value: "Mock data only")
                        profileRow("Privacy", value: "No authentication in Phase 1")
                    }
                    .padding(HFSpacing.lg)
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
    }

    private func profileRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textPrimary)
            Spacer()
            Text(value)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
        }
    }
}
