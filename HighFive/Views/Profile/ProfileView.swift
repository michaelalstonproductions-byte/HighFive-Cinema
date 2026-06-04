import SwiftUI

struct ProfileView: View {
    @Binding var selectedProfile: UserProfile
    @State private var showsProfileSwitcher = false
    @State private var showsSignOutAlert = false
    @State private var showsMockAction = false
    @State private var mockActionTitle = ""

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
                selectedProfilePanel
                avatarRow
                manageProfilesButton

                menu
                signOutButton
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .sheet(isPresented: $showsProfileSwitcher) {
            ProfileSwitcherView(selectedProfile: $selectedProfile, showsHeader: true)
                .padding(HFSpacing.lg)
                .background(HFColors.screenBackground.ignoresSafeArea())
        }
        .alert("Mock Action", isPresented: $showsMockAction) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("\(mockActionTitle) is a local placeholder for this streaming phase.")
        }
        .alert("Sign Out?", isPresented: $showsSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {}
        } message: {
            Text("This is a mock confirmation. No account or auth state will change.")
        }
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

    private var selectedProfilePanel: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            HStack(spacing: HFSpacing.md) {
                HFProfileAvatarCard(profile: selectedProfile, isSelected: true, compact: true)
                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    Text("Watching as")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.gold)
                    Text(selectedProfile.name)
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                    Text(selectedProfile.isKidsProfile ? "Kids profile" : "Standard profile")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                }
                Spacer()
            }
            .padding(HFSpacing.md)
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
                        HFProfileAvatarCard(profile: profile, isSelected: selectedProfile.id == profile.id)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var manageProfilesButton: some View {
        Button {
            showsProfileSwitcher = true
        } label: {
            HStack(spacing: HFSpacing.xs) {
                Image(systemName: "person.2.fill")
                Text("Manage Profiles")
            }
            .font(HFTypography.smallAction)
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(HFColors.goldGradient)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var menu: some View {
        VStack(spacing: HFSpacing.sm) {
            ForEach(menuItems, id: \.title) { item in
                HFMenuRow(title: item.title, systemImage: item.systemImage) {
                    mockActionTitle = item.title
                    showsMockAction = true
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var signOutButton: some View {
        Button {
            showsSignOutAlert = true
        } label: {
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
