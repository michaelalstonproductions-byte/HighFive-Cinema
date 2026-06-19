import SwiftUI

struct ProfileView: View {
    @Binding var selectedProfile: UserProfile
    var onOpenMyList: (() -> Void)?
    @EnvironmentObject private var streamingStore: HFStreamingStore
    @State private var showsProfileSwitcher = false
    @State private var showsSignOutAlert = false
    @State private var mockMessage: ProfileMockMessage?

    private var savedMovies: [Movie] {
        streamingStore.allCatalogMovies.filter { streamingStore.isSaved($0) }
    }

    private var downloadedMovies: [Movie] {
        streamingStore.allCatalogMovies.filter { streamingStore.isDownloaded($0) || $0.isDownloaded }
    }

    private var continueWatchingMovies: [Movie] {
        streamingStore.allCatalogMovies.filter { $0.progress != nil }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                activeProfileCard
                accountPanel
                librarySyncReadinessPanel
                paymentReadinessPanel
                playbackDescriptorReadinessPanel
                downloadReadinessPanel
                backendServicesPanel
                profileSwitcherRail
                viewingStats
                highfiveHub
                preferencesPanel
                menu
                signOutButton
            }
            .padding(.top, HFSpacing.xxl)
            .padding(.bottom, HFSpacing.floatingTabClearance + HFSpacing.tabBarHeight)
        }
        .accessibilityIdentifier("hf.profile.root")
        .accessibilityIdentifier("hf.profile.screen")
        .background(HFColors.screenBackground.ignoresSafeArea())
        .sheet(isPresented: $showsProfileSwitcher) {
            ProfileSwitcherView(selectedProfile: $selectedProfile, showsHeader: true)
                .padding(HFSpacing.lg)
                .background(HFColors.screenBackground.ignoresSafeArea())
        }
        .alert("Sign Out?", isPresented: $showsSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {}
        } message: {
            Text("This signs out of this device session.")
        }
        .alert(item: $mockMessage) { message in
            Alert(
                title: Text(message.title),
                message: Text(message.body),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: HFSpacing.md) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Text("Profile")
                    .font(HFTypography.display)
                    .foregroundStyle(HFColors.textPrimary)

                Text("Manage your viewing profile.")
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textSecondary)
            }

            Spacer()

            Button {
                showsProfileSwitcher = true
            } label: {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(.black)
                    .frame(width: 46, height: 46)
                    .background(HFColors.goldGradient)
                    .clipShape(Circle())
                    .shadow(color: HFColors.amberGlow.opacity(0.35), radius: 18, x: 0, y: 10)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Switch profile")
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var activeProfileCard: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                HStack(alignment: .center, spacing: HFSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(HFColors.goldGradient)
                        Image(systemName: selectedProfile.avatarSystemName)
                            .font(.system(size: 40, weight: .black))
                            .foregroundStyle(.black)
                    }
                    .frame(width: 88, height: 88)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.22), lineWidth: 1)
                    )

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text(selectedProfile.name)
                            .font(.system(size: 30, weight: .black, design: .default))
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)

                        Text(selectedProfile.isKidsProfile ? "Kids profile" : "Premium viewer")
                            .font(HFTypography.body)
                            .foregroundStyle(HFColors.textSecondary)

                        HStack(spacing: HFSpacing.xs) {
                            HFProfileBadge(title: selectedProfile.accentName, systemImage: "sparkles")
                            HFProfileBadge(title: streamingStore.accountMode, systemImage: "checkmark.seal.fill")
                        }
                    }

                    Spacer(minLength: 0)
                }

                HStack(spacing: HFSpacing.sm) {
                    HFButton("Switch", systemImage: "person.2.fill", style: .primary) {
                        showsProfileSwitcher = true
                    }

                    HFButton("My List", systemImage: "bookmark.fill", style: .secondary) {
                        onOpenMyList?()
                    }
                }

                NavigationLink {
                    ConnectHubView()
                } label: {
                    Label("Connect", systemImage: "person.2.wave.2.fill")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.80)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.white.opacity(0.10))
                        .overlay(Capsule().stroke(HFColors.cyanGlow.opacity(0.34), lineWidth: 1))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.route.profileToConnect")
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var backendServicesPanel: some View {
        HFBackendStatusPanel(runtimeStatus: streamingStore.backendRuntimeStatus)
            .padding(.horizontal, HFSpacing.screenHorizontal)
            .accessibilityIdentifier("hf.profile.backendServices")
    }

    private var accountPanel: some View {
        let authStatus = streamingStore.accountRuntimeStatus
        return HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "person.badge.key.fill")
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(.black)
                        .frame(width: 48, height: 48)
                        .background(HFColors.goldGradient)
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text("Account")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(authStatus.statusLabel)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)
                            .accessibilityIdentifier("hf.account.status")
                        Text(authStatus.detail)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .accessibilityIdentifier(authStatus.providerStatus.accessibilityIdentifier)

                VStack(spacing: HFSpacing.xs) {
                    HFAccountReadinessRow(
                        title: "Current local profile",
                        detail: selectedProfile.name,
                        status: authStatus.providerStatus == .localAccountMode ? "Local Account Mode" : authStatus.statusLabel,
                        systemImage: selectedProfile.avatarSystemName,
                        identifier: "hf.account.localMode"
                    )

                    HFAccountReadinessRow(
                        title: "Session",
                        detail: authStatus.sessionState.detail,
                        status: authStatus.sessionState.statusLabel,
                        systemImage: "person.crop.circle.badge.checkmark",
                        identifier: "hf.account.sessionState"
                    )

                    HFAccountReadinessRow(
                        title: "Sign-in readiness",
                        detail: authStatus.signInRequirement.detail,
                        status: authStatus.signInRequirement.statusLabel,
                        systemImage: "person.crop.circle.badge.questionmark",
                        identifier: "hf.account.signInReadiness"
                    )

                    HFAccountReadinessRow(
                        title: "Sign-out readiness",
                        detail: "Local profile can return to the profile hub without ending a live provider session.",
                        status: authStatus.sessionState.statusLabel,
                        systemImage: "rectangle.portrait.and.arrow.right",
                        identifier: "hf.account.signOutReadiness"
                    )

                    HFAccountReadinessRow(
                        title: authStatus.appleRequirementNote.title,
                        detail: authStatus.appleRequirementNote.detail,
                        status: authStatus.appleRequirementNote.statusLabel,
                        systemImage: "apple.logo",
                        identifier: "hf.account.appleRequirement"
                    )

                    HFAccountReadinessRow(
                        title: "Delete Account",
                        detail: authStatus.deletionRequest.detail,
                        status: authStatus.deletionRequest.statusLabel,
                        systemImage: "trash.slash.fill",
                        identifier: "hf.account.deleteRequest"
                    )

                    HFAccountReadinessRow(
                        title: "Export Account",
                        detail: authStatus.exportRequest.detail,
                        status: authStatus.exportRequest.statusLabel,
                        systemImage: "square.and.arrow.up.on.square",
                        identifier: "hf.account.exportRequest"
                    )
                }

                HStack(spacing: HFSpacing.sm) {
                    Button {
                        mockMessage = ProfileMockMessage(
                            title: "Account Readiness",
                            body: "Account staging is local-first. Runtime auth config is required before provider validation."
                        )
                    } label: {
                        Text("Review Account Readiness")
                            .font(HFTypography.smallAction)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(HFColors.goldGradient)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    Button {
                        mockMessage = ProfileMockMessage(
                            title: "Local Profile",
                            body: "\(selectedProfile.name) remains the active local viewing profile."
                        )
                    } label: {
                        Text("Use Local Profile")
                            .font(HFTypography.smallAction)
                            .foregroundStyle(HFColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(HFColors.surfaceElevated.opacity(0.72))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.account.panel")
    }

    private var librarySyncReadinessPanel: some View {
        let syncStatus = streamingStore.librarySyncRuntimeStatus
        return HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "bookmark.rectangle.stack.fill")
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(.black)
                        .frame(width: 48, height: 48)
                        .background(HFColors.goldGradient)
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text("Library Sync")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(syncStatus.statusLabel)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)
                            .accessibilityIdentifier("hf.profile.librarySyncStatus")
                            .accessibilityIdentifier("hf.library.syncStatus")
                        Text(syncStatus.detail)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(spacing: HFSpacing.xs) {
                    HFAccountReadinessRow(
                        title: "Local Library Mode",
                        detail: "Saved titles, progress, and offline preview state stay local.",
                        status: syncStatus.state.statusLabel,
                        systemImage: "bookmark.fill",
                        identifier: "hf.library.localLibraryMode"
                    )

                    HFAccountReadinessRow(
                        title: "Cloud Library Not Connected Yet",
                        detail: "Cloud sync requires account",
                        status: syncStatus.providerStatus.statusLabel,
                        systemImage: "person.crop.circle.badge.questionmark",
                        identifier: "hf.library.cloudNotConnected"
                    )

                    HFAccountReadinessRow(
                        title: syncStatus.boundary.title,
                        detail: syncStatus.boundary.detail,
                        status: "Boundary",
                        systemImage: "lock.shield.fill",
                        identifier: "hf.profile.librarySyncStatus"
                    )
                }

                Button {
                    mockMessage = ProfileMockMessage(
                        title: "Library Sync Readiness",
                        body: "Library sync is staged behind account, backend, and library runtime config. Local library state remains available."
                    )
                } label: {
                    Text("Review Library Sync Readiness")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(HFColors.goldGradient)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.profile.librarySyncReadiness")
    }

    private var paymentReadinessPanel: some View {
        let entitlementStatus = streamingStore.entitlementRuntimeStatus
        let paywallMappings = streamingStore.storeKitPaywallMappings
        let mappedRules = streamingStore.storeKitAccessRules
        return HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "creditcard.and.123")
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(.black)
                        .frame(width: 48, height: 48)
                        .background(HFColors.goldGradient)
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text("Membership")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(entitlementStatus.statusLabel)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)
                            .accessibilityIdentifier("hf.profile.membershipStatus")
                            .accessibilityIdentifier("hf.entitlement.status")
                        Text(entitlementStatus.detail)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(spacing: HFSpacing.xs) {
                    HFAccountReadinessRow(
                        title: "Local Preview Access",
                        detail: "Profile playback can continue locally without a payment provider.",
                        status: entitlementStatus.accessState.statusLabel,
                        systemImage: "play.rectangle.fill",
                        identifier: "hf.entitlement.localPreviewAccess"
                    )

                    HFAccountReadinessRow(
                        title: "Payment Provider Not Connected Yet",
                        detail: "Payment readiness is staged only. No live payment flow is active.",
                        status: entitlementStatus.paymentProviderLabel,
                        systemImage: "network.slash",
                        identifier: "hf.entitlement.paymentProviderNotConnected"
                    )

                    HFAccountReadinessRow(
                        title: "StoreKit product mapping",
                        detail: "\(paywallMappings.count) product IDs mapped from the older paywall project. \(mappedRules.count) current movie access rules are staged.",
                        status: "Mapped",
                        systemImage: "cart.badge.questionmark",
                        identifier: "hf.profile.storeKitReadiness"
                    )
                    .accessibilityIdentifier("hf.entitlement.storeKitMapping")

                    HFAccountReadinessRow(
                        title: "Paywall readiness",
                        detail: "Product mapping is ready for staging review. Entitlement validation required before live purchase.",
                        status: "Paywall readiness",
                        systemImage: "lock.rectangle.stack.fill",
                        identifier: "hf.movieDetail.paywallReadiness"
                    )

                    HFAccountReadinessRow(
                        title: "Restore Purchases Not Active Yet",
                        detail: "Restore purchase behavior waits for provider and server validation.",
                        status: entitlementStatus.restoreState.statusLabel,
                        systemImage: "arrow.counterclockwise.circle.fill",
                        identifier: "hf.profile.restoreReadiness"
                    )
                    .accessibilityIdentifier("hf.entitlement.restoreNotActive")

                    HFAccountReadinessRow(
                        title: "Entitlement Configured",
                        detail: "Complete runtime config may prepare entitlement validation without activating live purchase.",
                        status: "Staging only",
                        systemImage: "checkmark.seal.fill",
                        identifier: "hf.entitlement.status"
                    )

                    HFAccountReadinessRow(
                        title: "Server Entitlement Validation Required",
                        detail: entitlementStatus.boundary.detail,
                        status: "Required",
                        systemImage: "lock.shield.fill",
                        identifier: "hf.profile.entitlementBoundary"
                    )
                    .accessibilityIdentifier("hf.entitlement.serverValidationRequired")
                }

                HStack(spacing: HFSpacing.sm) {
                    Button {
                        mockMessage = ProfileMockMessage(
                            title: "Payment Readiness",
                            body: "Payment and entitlement staging is local-first. Runtime config and server validation are required before production access."
                        )
                    } label: {
                        Text("Review Payment Readiness")
                            .font(HFTypography.smallAction)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(HFColors.goldGradient)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    Button {
                        mockMessage = ProfileMockMessage(
                            title: "Access Rules",
                            body: "Local preview access stays available. Paid access requires provider configuration and server entitlement validation."
                        )
                    } label: {
                        Text("Review Access Rules")
                            .font(HFTypography.smallAction)
                            .foregroundStyle(HFColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(HFColors.surfaceElevated.opacity(0.72))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.profile.paymentReadiness")
    }

    private var playbackDescriptorReadinessPanel: some View {
        let rows = streamingStore.playbackDescriptorReadinessRows
        return HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "lock.rectangle.stack.fill")
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(.black)
                        .frame(width: 48, height: 48)
                        .background(HFColors.goldGradient)
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text("Playback Descriptor")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Backend descriptor required")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)
                        Text("Cloudflare descriptor not connected. Backend-mediated playback only.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(spacing: HFSpacing.xs) {
                    ForEach(rows) { row in
                        HFAccountReadinessRow(
                            title: row.title,
                            detail: row.detail,
                            status: row.status,
                            systemImage: row.systemImage,
                            identifier: playbackDescriptorIdentifier(for: row.id)
                        )
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.profile.playbackDescriptorReadiness")
    }

    private func playbackDescriptorIdentifier(for rowID: String) -> String {
        switch rowID {
        case "cloudflare-descriptor":
            return "hf.streaming.cloudflarePlaybackReference"
        case "backend-entitlement-validation":
            return "hf.backendStatus.entitlementValidation"
        case "backend-playback-contract":
            return "hf.profile.backendPlaybackContract"
        case "staging-playback-adapter":
            return "hf.profile.stagingPlaybackAdapter"
        default:
            return "hf.playback.descriptorBoundary"
        }
    }

    private var downloadReadinessPanel: some View {
        let downloadStatus = streamingStore.downloadPolicyRuntimeStatus
        return HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(.black)
                        .frame(width: 48, height: 48)
                        .background(HFColors.goldGradient)
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text("Downloads")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(downloadStatus.statusLabel)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)
                            .accessibilityIdentifier("hf.profile.downloadPolicyStatus")
                            .accessibilityIdentifier("hf.downloads.policyStatus")
                        Text(downloadStatus.detail)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(spacing: HFSpacing.xs) {
                    HFAccountReadinessRow(
                        title: "Offline Preview",
                        detail: "Local offline preview only",
                        status: downloadStatus.queueState.statusLabel,
                        systemImage: "tray.full.fill",
                        identifier: "hf.downloads.localOfflinePreviewOnly"
                    )

                    HFAccountReadinessRow(
                        title: "Download Provider Not Connected Yet",
                        detail: downloadStatus.policy.boundary.title,
                        status: downloadStatus.providerStatus.statusLabel,
                        systemImage: "network.slash",
                        identifier: "hf.downloads.downloadProviderNotConnected"
                    )

                    HFAccountReadinessRow(
                        title: "Backend-mediated downloads only",
                        detail: downloadStatus.policy.boundary.detail,
                        status: "Boundary",
                        systemImage: "lock.shield.fill",
                        identifier: "hf.downloads.policyStatus"
                    )

                    HFAccountReadinessRow(
                        title: "Real downloads disabled",
                        detail: downloadStatus.policy.expirationPolicy.statusLabel,
                        status: downloadStatus.policy.actionReadiness.statusLabel,
                        systemImage: "nosign",
                        identifier: "hf.downloads.realDownloadsDisabled"
                    )
                }

                Button {
                    mockMessage = ProfileMockMessage(
                        title: "Offline Policy",
                        body: "Downloads are staged as policy readiness only. Local offline preview remains available while real downloads stay disabled."
                    )
                } label: {
                    Text("Review Offline Policy")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(HFColors.goldGradient)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.profile.downloadReadiness")
    }

    private var profileSwitcherRail: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Who's Watching", actionTitle: "Switch") {
                showsProfileSwitcher = true
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HFSpacing.md) {
                    ForEach(HFMockData.userProfiles) { profile in
                        profileAvatarButton(profile)
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
    }

    private func profileAvatarButton(_ profile: UserProfile) -> some View {
        Button {
            selectedProfile = profile
        } label: {
            VStack(spacing: HFSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(selectedProfile.id == profile.id ? HFColors.goldGradient : LinearGradient(colors: [HFColors.surfaceElevated, HFColors.charcoal], startPoint: .topLeading, endPoint: .bottomTrailing))
                    Image(systemName: profile.avatarSystemName)
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(selectedProfile.id == profile.id ? .black : HFColors.textPrimary)
                }
                .frame(width: 74, height: 74)
                .overlay(
                    Circle()
                        .stroke(selectedProfile.id == profile.id ? HFColors.gold : HFColors.glassStroke, lineWidth: 2)
                )

                Text(profile.name)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(1)
                    .frame(width: 82)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Use \(profile.name) profile")
    }

    private var viewingStats: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Viewing Snapshot", actionTitle: nil)

            HStack(spacing: HFSpacing.sm) {
                HFProfileStatCard(title: "Saved", value: "\(savedMovies.count)", systemImage: "bookmark.fill")
                HFProfileStatCard(title: "Offline", value: "\(downloadedMovies.count)", systemImage: "arrow.down.circle.fill")
                HFProfileStatCard(title: "Watching", value: "\(continueWatchingMovies.count)", systemImage: "play.circle.fill")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)

            if let movie = continueWatchingMovies.first {
                NavigationLink(value: movie) {
                    HFProfileContinueCard(movie: movie)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
    }

    private var highfiveHub: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "HighFive Hub", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 22, weight: .black))
                            .foregroundStyle(.black)
                            .frame(width: 50, height: 50)
                            .background(HFColors.goldGradient)
                            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            Text("Creator Studio")
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                            Text("Build local drafts, prepare the Social Kit, and package VOD for private review without provider connections.")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    VStack(spacing: HFSpacing.sm) {
                        NavigationLink {
                            CreatorStudioView()
                        } label: {
                            HFProfileHubRouteRow(title: "Creator Studio", subtitle: "Local Draft", systemImage: "wand.and.stars")
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            ConnectHubView()
                        } label: {
                            HFProfileHubRouteRow(title: "Connect", subtitle: "Local Preview Room", systemImage: "person.2.wave.2.fill")
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("hf.route.profileToConnect")

                        NavigationLink {
                            CreatorStudioView(initialFocus: .socialMediaKit)
                        } label: {
                            HFProfileHubRouteRow(title: "Social Media Kit", subtitle: "Provider-ready", systemImage: "bubble.left.and.bubble.right.fill")
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            CreatorStudioView(initialFocus: .vodPackage)
                        } label: {
                            HFProfileHubRouteRow(title: "VOD Package", subtitle: "Not Connected Yet", systemImage: "shippingbox.fill")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityIdentifier("hf.profile.highfiveHub")
    }

    private var preferencesPanel: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.glassStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(spacing: HFSpacing.md) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 46, height: 46)
                        .background(HFColors.gold.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text("Viewing Preferences")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Dark cinematic playback, smart recommendations, and profile-specific saves.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(spacing: HFSpacing.sm) {
                    HFPreferenceRow(title: "Autoplay previews", detail: "On", systemImage: "play.rectangle.fill")
                    HFPreferenceRow(title: "Offline quality", detail: "High", systemImage: "arrow.down.circle.fill")
                    HFPreferenceRow(title: "Kids mode", detail: selectedProfile.isKidsProfile ? "On" : "Off", systemImage: "star.circle.fill")
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var menu: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Profile & More", actionTitle: nil)

            VStack(spacing: HFSpacing.sm) {
                HFProfileMenuButton(title: "My List", subtitle: "\(savedMovies.count) saved titles", systemImage: "bookmark.fill") {
                    onOpenMyList?()
                }
                HFProfileMenuButton(title: "Downloads", subtitle: "\(downloadedMovies.count) available offline", systemImage: "arrow.down.circle.fill") {
                    mockMessage = ProfileMockMessage(
                        title: "Downloads",
                        body: "Use the Downloads tab to manage your offline titles."
                    )
                }
                HFProfileMenuButton(title: "Manage Profiles", subtitle: "Switch profiles or add a new viewer", systemImage: "person.2.fill") {
                    showsProfileSwitcher = true
                }
                HFProfileMenuButton(title: "Help", subtitle: "Streaming preview support", systemImage: "questionmark.circle.fill") {
                    mockMessage = ProfileMockMessage(
                        title: "Help",
                        body: "Help is ready for streaming support, profile questions, and download guidance."
                    )
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var signOutButton: some View {
        Button {
            showsSignOutAlert = true
        } label: {
            Text("Sign Out")
                .font(HFTypography.smallAction)
                .foregroundStyle(HFColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(HFColors.surfaceElevated.opacity(0.72))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(HFColors.glassStroke, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}

private struct HFProfileBadge: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: systemImage)
                .font(.system(size: 9, weight: .black))
            Text(title)
                .font(HFTypography.micro)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .foregroundStyle(HFColors.gold)
        .padding(.horizontal, HFSpacing.xs)
        .frame(height: 24)
        .background(HFColors.gold.opacity(0.12))
        .clipShape(Capsule())
    }
}

private struct HFProfileStatCard: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(HFColors.gold)

            Text(value)
                .font(.system(size: 26, weight: .black, design: .default))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(title)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.md)
        .background(HFColors.surfaceElevated.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(HFColors.glassStroke, lineWidth: 1)
        )
    }
}

private struct HFProfileContinueCard: View {
    let movie: Movie

    var body: some View {
        HStack(spacing: HFSpacing.md) {
            HFPosterCard(movie: movie, width: 92, showTitle: false, showMetadata: false, showProgress: true)

            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Text("Continue Watching")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.gold)
                    .textCase(.uppercase)

                Text(movie.title)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)

                Text(movie.metadataLine)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(1)

                if let progress = movie.progress {
                    ProgressView(value: progress)
                        .tint(HFColors.gold)
                        .accessibilityLabel("Playback progress")
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(HFColors.textMuted)
        }
        .padding(HFSpacing.md)
        .background(HFColors.surface.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous)
                .stroke(HFColors.gold.opacity(0.18), lineWidth: 1)
        )
    }
}

private struct HFPreferenceRow: View {
    let title: String
    let detail: String
    let systemImage: String

    var body: some View {
        HStack(spacing: HFSpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(HFColors.gold)
                .frame(width: 28)

            Text(title)
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textPrimary)

            Spacer()

            Text(detail)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .padding(.horizontal, HFSpacing.xs)
                .frame(height: 26)
                .background(HFColors.surface.opacity(0.72))
                .clipShape(Capsule())
        }
    }
}

private struct HFAccountReadinessRow: View {
    let title: String
    let detail: String
    let status: String
    let systemImage: String
    let identifier: String

    var body: some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(HFColors.gold)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                Text(title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                Text(detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textMuted)
                    .lineLimit(2)
            }

            Spacer(minLength: HFSpacing.xs)

            Text(status)
                .font(HFTypography.micro)
                .foregroundStyle(status.contains("Configured") ? HFColors.gold : HFColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.66)
                .padding(.horizontal, HFSpacing.xs)
                .frame(height: 24)
                .background(Color.white.opacity(0.08))
                .clipShape(Capsule())
        }
        .accessibilityIdentifier(identifier)
    }
}

private struct HFProfileMenuButton: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: HFSpacing.md) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 42, height: 42)
                    .background(HFColors.gold.opacity(0.12))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    Text(title)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    Text(subtitle)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textMuted)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(HFColors.textMuted)
            }
            .padding(HFSpacing.md)
            .background(HFColors.surfaceElevated.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                    .stroke(HFColors.glassStroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct HFProfileHubRouteRow: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: HFSpacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(HFColors.gold)
                .frame(width: 42, height: 42)
                .background(HFColors.gold.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                Text(title)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                Text(subtitle)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textMuted)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(HFColors.textMuted)
        }
        .padding(HFSpacing.md)
        .background(HFColors.surfaceElevated.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(HFColors.glassStroke, lineWidth: 1)
        )
    }
}

private struct ProfileMockMessage: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}
