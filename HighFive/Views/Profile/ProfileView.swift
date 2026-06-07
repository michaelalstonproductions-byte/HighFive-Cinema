import SwiftUI

struct ProfileView: View {
    @Binding var selectedProfile: UserProfile
    var onOpenMyList: (() -> Void)?
    @State private var showsProfileSwitcher = false
    @State private var showsSignOutAlert = false
    @State private var showsNotifications = false
    @State private var activeMockSheet: ProfileMockSheet?
    @StateObject private var notificationStore = HFNotificationCenterStore()

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

                creatorModeCard
                ecosystemCommandShortcut
                productSpineShortcut
                preVisualLockShortcut
                preMockupReadinessShortcut
                mockupReadinessLockShortcut
                creatorWorkflowShortcut
                creatorLaunchShortcut
                connectPreviewShortcut
                personalizedHubShortcut
                previewReleaseSection
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
        .sheet(item: $activeMockSheet) { sheet in
            ProfileMockSheetView(sheet: sheet)
        }
        .sheet(isPresented: $showsNotifications) {
            HFNotificationSheet(store: notificationStore)
        }
        .alert("Sign Out?", isPresented: $showsSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {}
        } message: {
            Text("This is a mock confirmation. No account state will change.")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Text("Profiles & More")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
            Text("Your local product hub for watching, creator packages, Connect previews, launch readiness, and future export planning.")
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

    private var creatorModeCard: some View {
        NavigationLink {
            CreatorEntryView()
        } label: {
            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                HStack(spacing: HFSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(HFColors.gold.opacity(0.16))
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(HFColors.gold)
                    }
                    .frame(width: 52, height: 52)

                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text("Creator Mode")
                            .font(HFTypography.menu)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Build creator packages with studio, dashboard, and workflow previews")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                }
                .padding(HFSpacing.md)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Creator Mode")
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var ecosystemCommandShortcut: some View {
        NavigationLink {
            EcosystemCommandCenterView()
        } label: {
            HFActionTile(
                title: "HighFive Command Center",
                subtitle: "Navigate Watch, Create, Connect, Launch, and future export readiness.",
                systemImage: "command"
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open HighFive Command Center")
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var productSpineShortcut: some View {
        NavigationLink {
            ProductSpineCompletionView()
        } label: {
            HFActionTile(
                title: "Product Spine Completion",
                subtitle: "Review the full local product structure.",
                systemImage: "rectangle.connected.to.line.below"
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Product Spine Completion")
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var preVisualLockShortcut: some View {
        NavigationLink {
            PreVisualLockView()
        } label: {
            HFActionTile(
                title: "Pre-Visual Lock",
                subtitle: "Confirm the spine is ready before mockup matching.",
                systemImage: "checkmark.seal.fill"
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Pre-Visual Lock")
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var preMockupReadinessShortcut: some View {
        NavigationLink {
            PreMockupReadinessReviewView()
        } label: {
            HFActionTile(
                title: "Pre-Mockup Readiness Review",
                subtitle: "Confirm the spine is stable before visual matching.",
                systemImage: "checkmark.circle.fill"
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Pre-Mockup Readiness Review")
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var mockupReadinessLockShortcut: some View {
        NavigationLink {
            MockupReadinessLockView()
        } label: {
            HFActionTile(
                title: "Mockup Readiness Lock",
                subtitle: "Confirm the product is ready for visual parity.",
                systemImage: "checkmark.seal.fill"
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Mockup Readiness Lock")
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var creatorWorkflowShortcut: some View {
        NavigationLink {
            CreatorWorkflowCommandCenterView()
        } label: {
            HFActionTile(
                title: "Creator Command Center",
                subtitle: "Build package, review, readiness, and release signals.",
                systemImage: "command"
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Creator Command Center")
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var creatorLaunchShortcut: some View {
        NavigationLink {
            CreatorLaunchCenterPreviewView()
        } label: {
            HFActionTile(
                title: "Creator Launch Center",
                subtitle: "Prepare launch plan, audience interest, and mock access setup.",
                systemImage: "flag.checkered"
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Creator Launch Center")
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var connectPreviewShortcut: some View {
        NavigationLink {
            ConnectHubView()
        } label: {
            HFActionTile(
                title: "Connect Preview",
                subtitle: "Follow creator communities, project updates, and mock signals.",
                systemImage: "person.2.fill"
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Connect Preview")
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var personalizedHubShortcut: some View {
        NavigationLink {
            PersonalizedHubView()
        } label: {
            HFActionTile(
                title: "For You",
                subtitle: "Local paths across Watch, Create, Connect, Launch, and Access.",
                systemImage: "sparkles"
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Personalized Hub")
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var previewReleaseSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Preview & Release", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                NavigationLink {
                    AppReleasePresentationView()
                } label: {
                    HFActionTile(
                        title: "HighFive Preview",
                        subtitle: "Review the local product story for partners and testers.",
                        systemImage: "sparkles"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open HighFive Preview")

                NavigationLink {
                    AppOnboardingPreviewView()
                } label: {
                    HFActionTile(
                        title: "Onboarding Preview",
                        subtitle: "Preview the first-run story without changing app launch.",
                        systemImage: "rectangle.stack.badge.play.fill"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open Onboarding Preview")

                NavigationLink {
                    AppDemoChecklistView()
                } label: {
                    HFActionTile(
                        title: "Demo Checklist",
                        subtitle: "Walk Watch, Create, Connect, Launch, and safety checks.",
                        systemImage: "checklist"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open Demo Checklist")

                NavigationLink {
                    FinalDemoTourView()
                } label: {
                    HFActionTile(
                        title: "Final Demo Tour",
                        subtitle: "Walk through the full HighFive product spine.",
                        systemImage: "map.fill"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open Final Demo Tour")
            }
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
        .accessibilityLabel("Manage Profiles")
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var menu: some View {
        VStack(spacing: HFSpacing.sm) {
            ForEach(menuItems, id: \.title) { item in
                HFMenuRow(
                    title: item.title,
                    systemImage: item.systemImage,
                    badgeCount: item.title == "Notifications" ? notificationStore.unreadCount : 0
                ) {
                    handleMenuItem(item.title)
                }
                .accessibilityLabel(item.title == "Notifications" ? "Notifications, \(notificationStore.unreadCount) unread" : item.title)
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func handleMenuItem(_ title: String) {
        switch title {
        case "My List":
            onOpenMyList?()
        case "Notifications":
            showsNotifications = true
        case "App Settings":
            activeMockSheet = ProfileMockSheet(
                title: "App Settings",
                message: "Streaming display, download, and playback preferences will live here later.",
                systemImage: "gearshape.fill"
            )
        case "Account":
            activeMockSheet = ProfileMockSheet(
                title: "Account",
                message: "Account management is a local placeholder. No sign-in or billing is connected.",
                systemImage: "person.crop.circle.fill"
            )
        case "Help":
            activeMockSheet = ProfileMockSheet(
                title: "Help",
                message: "Help content is mocked for now. No live support service is connected.",
                systemImage: "questionmark.circle.fill"
            )
        default:
            break
        }
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

private struct ProfileMockSheet: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let systemImage: String
}

private struct ProfileMockSheetView: View {
    let sheet: ProfileMockSheet
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            HFColors.screenBackground
                .ignoresSafeArea()

            VStack(spacing: HFSpacing.xl) {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(HFColors.textPrimary)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
                    VStack(spacing: HFSpacing.lg) {
                        ZStack {
                            Circle()
                                .fill(HFColors.gold.opacity(0.16))
                            Image(systemName: sheet.systemImage)
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(HFColors.gold)
                        }
                        .frame(width: 78, height: 78)

                        VStack(spacing: HFSpacing.sm) {
                            Text(sheet.title)
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                                .multilineTextAlignment(.center)
                            Text(sheet.message)
                                .font(HFTypography.body)
                                .foregroundStyle(HFColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(HFSpacing.xl)
                }

                Spacer()
            }
            .padding(HFSpacing.lg)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
