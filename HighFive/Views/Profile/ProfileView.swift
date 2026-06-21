import SwiftUI

enum HFMembershipPassFacet: String, CaseIterable, Identifiable {
    case identity
    case premieres
    case creatorRooms
    case protectedPlayback
    case depthPeek

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .identity:
            return "Identity"
        case .premieres:
            return "Premieres"
        case .creatorRooms:
            return "Creator Rooms"
        case .protectedPlayback:
            return "Protected Playback"
        case .depthPeek:
            return "Depth + Peek"
        }
    }

    var systemImage: String {
        switch self {
        case .identity:
            return "person.crop.circle.badge.checkmark"
        case .premieres:
            return "sparkles.tv.fill"
        case .creatorRooms:
            return "person.3.sequence.fill"
        case .protectedPlayback:
            return "lock.shield.fill"
        case .depthPeek:
            return "viewfinder"
        }
    }

    var purpose: String {
        switch self {
        case .identity:
            return "HighFive Pass identity and Local Account Mode."
        case .premieres:
            return "Premiere-room access preview without a remote event claim."
        case .creatorRooms:
            return "Creator Studio and circle access context."
        case .protectedPlayback:
            return "Local Preview Access and entitlement boundaries."
        case .depthPeek:
            return "Signature spatial experience readiness."
        }
    }

    var accessibilityIdentifier: String {
        switch self {
        case .identity:
            return "hf.spatial.membership.identity"
        case .premieres:
            return "hf.spatial.membership.premieres"
        case .creatorRooms:
            return "hf.spatial.membership.creatorRooms"
        case .protectedPlayback:
            return "hf.spatial.membership.protectedPlayback"
        case .depthPeek:
            return "hf.spatial.membership.depthPeek"
        }
    }

    var accent: Color {
        switch self {
        case .identity, .premieres:
            return HFColors.gold
        case .creatorRooms:
            return Color.purple.opacity(0.86)
        case .protectedPlayback, .depthPeek:
            return HFColors.cyanGlow
        }
    }
}

enum HFMembershipShowcaseFocus {
    case pass
    case stats
    case collectionVault
    case achievements
}

struct ProfileView: View {
    @Binding var selectedProfile: UserProfile
    var initialMembershipFacet: HFMembershipPassFacet = .identity
    var initialMembershipShowcase: HFMembershipShowcaseFocus = .pass
    var startInMembership = false
    var onOpenMyList: (() -> Void)?
    @EnvironmentObject private var streamingStore: HFStreamingStore
    @State private var showsProfileSwitcher = false
    @State private var showsSignOutAlert = false
    @State private var mockMessage: ProfileMockMessage?
    @State private var showsMembershipPass = false
    @State private var didHandleInitialMembershipRoute = false

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
                membershipPassEntry
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
        .navigationDestination(isPresented: $showsMembershipPass) {
            HFMembershipIdentityPassView(
                selectedProfile: selectedProfile,
                initialFacet: initialMembershipFacet,
                initialShowcase: initialMembershipShowcase
            )
        }
        .onAppear {
            guard startInMembership, !didHandleInitialMembershipRoute else { return }
            didHandleInitialMembershipRoute = true
            showsMembershipPass = true
        }
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

                Text("HighFive Pass and rooms gateway.")
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

    private var membershipPassEntry: some View {
        NavigationLink {
            HFMembershipIdentityPassView(selectedProfile: selectedProfile)
        } label: {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(Color.black.opacity(0.82))
                    .overlay(
                        LinearGradient(
                            colors: [
                                HFColors.gold.opacity(0.30),
                                Color.white.opacity(0.05),
                                Color.black.opacity(0.64)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(HFDepthContourOverlay(color: HFColors.gold.opacity(0.76), lineWidth: 0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .stroke(HFColors.gold.opacity(0.50), lineWidth: 1)
                    )
                    .shadow(color: HFColors.amberGlow.opacity(0.30), radius: 28, x: 0, y: 18)

                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                            HFSpatialRouteBadge(title: "Profile -> Pass", accent: HFColors.gold)

                            Text("HighFive Pass")
                                .font(.system(size: 32, weight: .black))
                                .foregroundStyle(HFColors.textPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.72)

                            Text("Local Account Mode")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.gold)
                                .accessibilityIdentifier("hf.membership.localAccountMode")
                        }

                        Spacer()

                        Image(systemName: "person.crop.rectangle.stack.fill")
                            .font(.system(size: 26, weight: .black))
                            .foregroundStyle(.black)
                            .frame(width: 54, height: 54)
                            .background(HFColors.goldGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }

                    Text("\(selectedProfile.name) has Local Preview Access, premiere readiness, and protected playback boundaries in one private pass.")
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textSecondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: HFSpacing.sm) {
                        Text("Review Access")
                            .font(HFTypography.smallAction)
                            .foregroundStyle(.black)
                            .frame(height: 42)
                            .padding(.horizontal, HFSpacing.md)
                            .background(HFColors.goldGradient)
                            .clipShape(Capsule())

                        Text("Profile Entry")
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.textPrimary)
                            .frame(height: 34)
                            .padding(.horizontal, HFSpacing.sm)
                            .background(Color.white.opacity(0.10))
                            .clipShape(Capsule())
                    }
                }
                .padding(HFSpacing.lg)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 238)
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Membership Identity Pass for \(selectedProfile.name)")
        .accessibilityHint("Opens HighFive Pass access preview")
        .accessibilityIdentifier("hf.profile.membershipIdentityPass")
        .accessibilityIdentifier("hf.route.profileToMembership")
        .hfSpatialFocalHandoff("hf.spatial.handoff.profileToMembership")
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
            HFSectionHeader(title: "Rooms Gateway", actionTitle: nil)

            HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 22, weight: .black))
                            .foregroundStyle(.black)
                            .frame(width: 50, height: 50)
                            .background(HFColors.goldGradient)
                            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            Text("Creator and Connect Rooms")
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                            Text("Enter Creator Studio, Connect, Social, and VOD as contextual rooms. They remain reference-driven spaces, never bottom tabs.")
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

private struct HFMembershipIdentityPassView: View {
    let selectedProfile: UserProfile
    let initialShowcase: HFMembershipShowcaseFocus

    @EnvironmentObject private var streamingStore: HFStreamingStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @GestureState private var passDrag: CGSize = .zero
    @State private var selectedFacet: HFMembershipPassFacet
    @State private var selectedShowcase: HFMembershipShowcaseFocus
    @State private var showsAccountInspector = false
    @State private var showsAccountPrivacy = false

    init(
        selectedProfile: UserProfile,
        initialFacet: HFMembershipPassFacet = .identity,
        initialShowcase: HFMembershipShowcaseFocus = .pass
    ) {
        self.selectedProfile = selectedProfile
        self.initialShowcase = initialShowcase
        _selectedFacet = State(initialValue: initialFacet)
        _selectedShowcase = State(initialValue: initialShowcase)
    }

    private var profileInitials: String {
        let parts = selectedProfile.name
            .split(separator: " ")
            .prefix(2)
            .compactMap(\.first)
        let initials = String(parts).uppercased()
        return initials.isEmpty ? "HF" : initials
    }

    private var authStatus: HFAuthRuntimeStatus {
        streamingStore.accountRuntimeStatus
    }

    private var entitlementStatus: HFEntitlementRuntimeStatus {
        streamingStore.entitlementRuntimeStatus
    }

    private var dragRotationX: Double {
        guard !reduceMotion else { return 0 }
        return Double(max(min(passDrag.height / -18, HFSpatialMotionTokens.maximumTiltDegrees), -HFSpatialMotionTokens.maximumTiltDegrees))
    }

    private var dragRotationY: Double {
        guard !reduceMotion else { return 0 }
        return Double(max(min(passDrag.width / 16, HFSpatialMotionTokens.maximumTiltDegrees), -HFSpatialMotionTokens.maximumTiltDegrees))
    }

    private var usesSpatialFallbackLayout: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                header
                routeShowcase
                passWorld
                actionCluster
                premiumMembershipSections
                facetPreview
            }
            .padding(.top, HFSpacing.lg)
            .padding(.horizontal, HFSpacing.screenHorizontal)
            .padding(.bottom, HFSpacing.floatingTabClearance + HFSpacing.tabBarHeight)
        }
        .background(membershipBackground)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showsAccountInspector) {
            accountAccessInspector
        }
        .sheet(isPresented: $showsAccountPrivacy) {
            accountPrivacySheet
        }
        .accessibilityIdentifier("hf.spatial.membership")
    }

    private var header: some View {
        HStack(spacing: HFSpacing.md) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(HFColors.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.10))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back to Profile")
            .accessibilityIdentifier("hf.membership.backToProfile")
            .accessibilityIdentifier("hf.route.membershipToProfile")

            VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                Text("Membership")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.gold)
                    .textCase(.uppercase)

                Text("HighFive Pass")
                    .font(.system(size: 30, weight: .black))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }

            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private var routeShowcase: some View {
        switch selectedShowcase {
        case .pass:
            EmptyView()
        case .stats:
            membershipStatsSection
        case .collectionVault:
            collectionVaultSection
        case .achievements:
            achievementsSection
        }
    }

    private var passWorld: some View {
        VStack(spacing: HFSpacing.md) {
            identityPass
                .accessibilitySortPriority(3)

            VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                Text(selectedFacet.displayName)
                    .font(HFTypography.section)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
                    .accessibilityIdentifier("hf.spatial.membership.selectedFacet")

                Text(selectedFacet.purpose)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            facetGrid
        }
        .padding(HFSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(reduceTransparency ? Color.black.opacity(0.96) : Color.black.opacity(0.46))
                .overlay(
                    RadialGradient(
                        colors: [
                            HFColors.gold.opacity(0.18),
                            Color.purple.opacity(0.10),
                            Color.black.opacity(0.82)
                        ],
                        center: .top,
                        startRadius: 20,
                        endRadius: 390
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("HighFive Membership Identity Pass world")
        .accessibilityIdentifier("hf.spatial.accessibility.largeType")
        .accessibilityIdentifier("hf.spatial.membership.world")
    }

    private var identityPass: some View {
        HFOpticalGlassSurface(cornerRadius: 32, strokeColor: HFColors.gold.opacity(0.58)) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color.black.opacity(0.74))
                    .overlay(
                        LinearGradient(
                            colors: [
                                HFColors.gold.opacity(0.34),
                                Color.white.opacity(0.06),
                                Color.black.opacity(0.55)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(HFDepthContourOverlay(color: selectedFacet == .protectedPlayback || selectedFacet == .depthPeek ? HFColors.cyanGlow : HFColors.gold, lineWidth: 0.8))

                VStack(alignment: .leading, spacing: HFSpacing.lg) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                            Text("HIGHFIVE")
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(HFColors.gold)
                                .textCase(.uppercase)

                            Text("PASS")
                                .font(.system(size: 38, weight: .black))
                                .foregroundStyle(HFColors.textPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.64)
                                .accessibilityIdentifier("hf.spatial.membership.passTitle")
                        }

                        Spacer()

                        Text(profileInitials)
                            .font(.system(size: 18, weight: .black))
                            .foregroundStyle(.black)
                            .frame(width: 56, height: 56)
                            .background(HFColors.goldGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .accessibilityHidden(true)
                    }

                    Spacer(minLength: 10)

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text(selectedProfile.name)
                            .font(.system(size: 24, weight: .black))
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.70)
                            .accessibilityIdentifier("hf.spatial.membership.profileIdentity")

                        Text("Local Account Mode")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)
                            .accessibilityIdentifier("hf.membership.localAccountMode")

                        Text("Local Preview Access")
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.cyanGlow)
                            .accessibilityIdentifier("hf.membership.localPreviewAccess")
                    }

                    HStack(spacing: HFSpacing.xs) {
                        HFMembershipPassPill(title: selectedFacet.displayName, color: selectedFacet.accent)
                        HFMembershipPassPill(title: "Private Preview", color: HFColors.gold)
                    }
                }
                .padding(HFSpacing.lg)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 218)
        .rotation3DEffect(.degrees(dragRotationY), axis: (x: 0, y: 1, z: 0), perspective: 0.55)
        .rotation3DEffect(.degrees(dragRotationX), axis: (x: 1, y: 0, z: 0), perspective: 0.55)
        .scaleEffect(reduceMotion ? 1 : (passDrag == .zero ? 1 : 1.015))
        .animation(reduceMotion ? .easeInOut(duration: 0.01) : HFSpatialMotionTokens.focusAnimation, value: passDrag)
        .gesture(
            DragGesture(minimumDistance: 6)
                .updating($passDrag) { value, state, _ in
                    state = value.translation
                }
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("HighFive Pass for \(selectedProfile.name), \(selectedFacet.displayName) selected, Local Account Mode, Local Preview Access")
        .accessibilityHint("Drag gently to tilt the pass. All details are also available without the gesture.")
        .accessibilityIdentifier("hf.membership.passHero")
        .accessibilityIdentifier("hf.spatial.membership.pass")
        .hfSpatialFocalHandoff("hf.spatial.handoff.profileToMembership")
    }

    private var premiumMembershipSections: some View {
        VStack(spacing: HFSpacing.md) {
            memberIdentityCard
            membershipStatsSection
            collectionVaultSection
            achievementsSection
            premiereAccessSection
            watchPartyHistorySection
            creatorSupportSection
        }
    }

    private var memberIdentityCard: some View {
        HFOpticalGlassSurface(cornerRadius: 28, strokeColor: HFColors.gold.opacity(0.42)) {
            HStack(spacing: HFSpacing.md) {
                Text(profileInitials)
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(.black)
                    .frame(width: 62, height: 62)
                    .background(HFColors.goldGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    Text("Member Identity")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    Text(selectedProfile.name)
                        .font(HFTypography.body.weight(.bold))
                        .foregroundStyle(HFColors.gold)
                    Text("Local Account Mode keeps this pass private on device.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.membership.identityCard")
    }

    private var membershipStatsSection: some View {
        HFOpticalGlassSurface(cornerRadius: 28, strokeColor: HFColors.cyanGlow.opacity(selectedShowcase == .stats ? 0.58 : 0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionHeader(title: "Viewing Stats", subtitle: "Local viewing rhythm", systemImage: "chart.bar.xaxis", color: HFColors.cyanGlow)

                HStack(spacing: HFSpacing.sm) {
                    premiumStat(title: "Hours", value: "42", detail: "previewed")
                    premiumStat(title: "Stories", value: "\(max(continueWatchingMovies.count, 3))", detail: "active")
                    premiumStat(title: "Rooms", value: "8", detail: "joined locally")
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.membership.stats")
    }

    private var collectionVaultSection: some View {
        HFOpticalGlassSurface(cornerRadius: 28, strokeColor: HFColors.gold.opacity(selectedShowcase == .collectionVault ? 0.60 : 0.32)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionHeader(title: "Collection Vault", subtitle: "Saved watch shelf", systemImage: "rectangle.stack.badge.play.fill", color: HFColors.gold)

                HStack(spacing: HFSpacing.sm) {
                    ForEach(savedVaultMovies.prefix(3)) { movie in
                        VStack(alignment: .leading, spacing: 6) {
                            vaultPoster(for: movie)
                                .frame(height: 104)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(HFColors.gold.opacity(0.34), lineWidth: 1)
                                )
                            Text(movie.title)
                                .font(HFTypography.micro)
                                .foregroundStyle(HFColors.textPrimary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.70)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.membership.collectionVault")
    }

    private var achievementsSection: some View {
        HFOpticalGlassSurface(cornerRadius: 28, strokeColor: HFColors.gold.opacity(selectedShowcase == .achievements ? 0.60 : 0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionHeader(title: "Achievement Badges", subtitle: "Local milestones", systemImage: "rosette", color: HFColors.gold)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.sm) {
                    achievementBadge(title: "Opening Night", detail: "Premiere ready", systemImage: "sparkles.tv.fill", color: HFColors.gold)
                    achievementBadge(title: "Depth Curious", detail: "Peek explored", systemImage: "viewfinder", color: HFColors.cyanGlow)
                    achievementBadge(title: "Vault Keeper", detail: "Saved shelf", systemImage: "bookmark.fill", color: HFColors.gold)
                    achievementBadge(title: "Room Regular", detail: "Watch parties", systemImage: "person.2.fill", color: HFColors.cyanGlow)
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.membership.achievements")
    }

    private var premiereAccessSection: some View {
        HFOpticalGlassSurface(cornerRadius: 28, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                sectionHeader(title: "Premiere Access", subtitle: "Local lobby preview", systemImage: "sparkles.tv.fill", color: HFColors.gold)
                Text("Preview upcoming room access, featured titles, and member-only lobby context without claiming a remote event.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(HFSpacing.md)
        }
        .accessibilityIdentifier("hf.membership.premiereAccess")
    }

    private var watchPartyHistorySection: some View {
        HFOpticalGlassSurface(cornerRadius: 28, strokeColor: HFColors.cyanGlow.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                sectionHeader(title: "Watch Party History", subtitle: "Local room memory", systemImage: "person.2.wave.2.fill", color: HFColors.cyanGlow)
                HStack(spacing: HFSpacing.sm) {
                    historyPill(title: "The Friendly", detail: "3 viewers")
                    historyPill(title: "Premiere Lobby", detail: "Local preview")
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityIdentifier("hf.membership.watchPartyHistory")
    }

    private var creatorSupportSection: some View {
        HFOpticalGlassSurface(cornerRadius: 28, strokeColor: HFColors.violet.opacity(0.36)) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                sectionHeader(title: "Creator Support", subtitle: "Room-aware fandom", systemImage: "wand.and.stars", color: HFColors.violet)
                Text("Follow creator context, commentary readiness, and studio-room entry points as local membership benefits.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(HFSpacing.md)
        }
        .accessibilityIdentifier("hf.membership.creatorSupport")
    }

    private var savedVaultMovies: [Movie] {
        let saved = streamingStore.allCatalogMovies.filter { streamingStore.isSaved($0) }
        return saved.isEmpty ? Array(streamingStore.allCatalogMovies.prefix(3)) : saved
    }

    private var continueWatchingMovies: [Movie] {
        streamingStore.allCatalogMovies.filter { $0.progress != nil }
    }

    @ViewBuilder
    private func vaultPoster(for movie: Movie) -> some View {
        if let posterAssetName = movie.posterAssetName,
           HFPosterAssetHealth.hasImage(named: posterAssetName) {
            Image(posterAssetName)
                .resizable()
                .scaledToFill()
        } else {
            HFPosterFallback(title: movie.title)
        }
    }

    private func sectionHeader(title: String, subtitle: String, systemImage: String, color: Color) -> some View {
        HStack(spacing: HFSpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(color)
                .frame(width: 42, height: 42)
                .background(color.opacity(0.14))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                Text(subtitle)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
            }

            Spacer(minLength: 0)
        }
    }

    private func premiumStat(title: String, value: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
            Text(value)
                .font(.system(size: 26, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
            Text(detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.cyanGlow)
                .lineLimit(1)
                .minimumScaleFactor(0.70)
        }
        .padding(HFSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func achievementBadge(title: String, detail: String, systemImage: String, color: Color) -> some View {
        HStack(spacing: HFSpacing.xs) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .black))
                .foregroundStyle(color)
                .frame(width: 34, height: 34)
                .background(color.opacity(0.14))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
                Text(detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
            }
        }
        .padding(HFSpacing.xs)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func historyPill(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(HFTypography.caption.weight(.bold))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.cyanGlow)
                .lineLimit(1)
                .minimumScaleFactor(0.70)
        }
        .padding(HFSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var facetGrid: some View {
        Group {
            if usesSpatialFallbackLayout {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: HFSpacing.sm) {
                        ForEach(HFMembershipPassFacet.allCases) { facet in
                            facetButton(facet)
                                .frame(width: 156)
                        }
                    }
                    .padding(.horizontal, HFSpacing.xxs)
                }
                .accessibilityIdentifier("hf.spatial.accessibility.fallbackLayout")
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: HFSpacing.sm),
                    GridItem(.flexible(), spacing: HFSpacing.sm),
                    GridItem(.flexible(), spacing: HFSpacing.sm)
                ], spacing: HFSpacing.sm) {
                    ForEach(HFMembershipPassFacet.allCases) { facet in
                        facetButton(facet)
                    }
                }
            }
        }
    }

    private func facetButton(_ facet: HFMembershipPassFacet) -> some View {
        let isSelected = selectedFacet == facet
        return Button {
            withAnimation(reduceMotion ? .easeInOut(duration: 0.12) : HFSpatialMotionTokens.focusAnimation) {
                selectedFacet = facet
            }
        } label: {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Image(systemName: facet.systemImage)
                    .font(.system(size: 19, weight: .black))
                    .foregroundStyle(isSelected ? facet.accent : HFColors.textSecondary)

                Text(facet.displayName)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)

                Text(isSelected ? "Selected" : "Ready")
                    .font(HFTypography.micro)
                    .foregroundStyle(isSelected ? facet.accent : HFColors.textMuted)

                if differentiateWithoutColor {
                    Label(isSelected ? "Selected" : "Ready", systemImage: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(HFTypography.micro)
                        .foregroundStyle(isSelected ? facet.accent : HFColors.textMuted)
                        .lineLimit(1)
                        .minimumScaleFactor(0.66)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 72, alignment: .topLeading)
            .padding(HFSpacing.xs)
            .background(isSelected ? facet.accent.opacity(0.18) : Color.white.opacity(0.065))
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                    .stroke(isSelected ? facet.accent.opacity(0.70) : Color.white.opacity(0.10), lineWidth: 1)
            )
            .shadow(color: isSelected ? facet.accent.opacity(0.24) : .clear, radius: 16, x: 0, y: 10)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 76)
        .contentShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .hfSpatialSelectionTreatment(
            isSelected: isSelected,
            accent: facet.accent,
            reduceMotion: reduceMotion,
            differentiateWithoutColor: differentiateWithoutColor
        )
        .accessibilityLabel("\(facet.displayName), \(facet.purpose)")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityIdentifier(facet.accessibilityIdentifier)
        .accessibilityIdentifier(routeIdentifier(for: facet))
    }

    private func routeIdentifier(for facet: HFMembershipPassFacet) -> String {
        switch facet {
        case .identity:
            return "hf.route.membershipIdentity"
        case .premieres:
            return "hf.route.membershipPremieres"
        case .creatorRooms:
            return "hf.route.membershipCreatorRooms"
        case .protectedPlayback:
            return "hf.route.membershipProtectedPlayback"
        case .depthPeek:
            return "hf.route.membershipDepthPeek"
        }
    }

    @ViewBuilder
    private var facetPreview: some View {
        switch selectedFacet {
        case .identity:
            HFMembershipFacetPreview(
                title: "HighFive Pass",
                subtitle: "Private identity for \(selectedProfile.name)",
                detail: "Local profile identity is active in Local Account Mode. No remote account number is shown.",
                systemImage: "person.crop.circle.badge.checkmark",
                accent: HFColors.gold,
                identifier: "hf.membership.identityPreview"
            ) {
                HFMembershipInspectorRow(title: "Local Account Mode", detail: authStatus.detail, status: authStatus.statusLabel, systemImage: "person.crop.circle.fill", identifier: "hf.membership.localAccountMode")
                HFMembershipInspectorRow(title: "Local profile", detail: selectedProfile.name, status: "Active", systemImage: selectedProfile.avatarSystemName, identifier: "hf.membership.localProfile")
            }
        case .premieres:
            HFMembershipFacetPreview(
                title: "Premiere Access",
                subtitle: "Local lobby readiness",
                detail: "Premiere benefit preview is staged locally. No scheduled remote event is implied.",
                systemImage: "sparkles.tv.fill",
                accent: HFColors.gold,
                identifier: "hf.membership.premierePreview"
            ) {
                HFMembershipInspectorRow(title: "Premiere Access", detail: "Local lobby preview available for review.", status: "Preview", systemImage: "sparkles.tv.fill", identifier: "hf.membership.premiereAccess")
            }
        case .creatorRooms:
            HFMembershipFacetPreview(
                title: "Creator Rooms",
                subtitle: "Studio and circle context",
                detail: "Creator Studio and Creator Circle access are represented locally without collaboration transport.",
                systemImage: "person.3.sequence.fill",
                accent: Color.purple.opacity(0.88),
                identifier: "hf.membership.creatorRoomsPreview"
            ) {
                HFMembershipInspectorRow(title: "Creator Studio", detail: "Project slab access remains local.", status: "Available", systemImage: "wand.and.stars", identifier: "hf.membership.creatorStudioAccess")
                HFMembershipInspectorRow(title: "Creator Circles", detail: "Circle presence is a local preview.", status: "Preview", systemImage: "person.2.wave.2.fill", identifier: "hf.membership.creatorCircleAccess")
            }
        case .protectedPlayback:
            HFMembershipFacetPreview(
                title: "Protected Playback",
                subtitle: "Access boundary",
                detail: "Local Preview Access remains available while server entitlement validation and playback descriptor boundaries stay secondary.",
                systemImage: "lock.shield.fill",
                accent: HFColors.cyanGlow,
                identifier: "hf.membership.protectedPlaybackPreview"
            ) {
                HFMembershipInspectorRow(title: "Local Preview Access", detail: "Consumer playback can continue locally.", status: entitlementStatus.accessState.statusLabel, systemImage: "play.rectangle.fill", identifier: "hf.membership.localPreviewAccess")
                HFMembershipInspectorRow(title: "Server entitlement validation required", detail: entitlementStatus.boundary.detail, status: "Required", systemImage: "lock.shield.fill", identifier: "hf.membership.entitlementValidation")
                HFMembershipInspectorRow(title: "Playback descriptor boundary", detail: "Provider playback requires a backend descriptor before live access.", status: "Boundary", systemImage: "doc.badge.gearshape.fill", identifier: "hf.membership.playbackDescriptorBoundary")
            }
        case .depthPeek:
            HFMembershipFacetPreview(
                title: "Depth + Peek",
                subtitle: "Signature spatial benefit",
                detail: "Depth and tilt-peek remain protected systems. The pass presents readiness without changing engine internals.",
                systemImage: "viewfinder",
                accent: HFColors.cyanGlow,
                identifier: "hf.membership.depthPeekPreview"
            ) {
                HFMembershipInspectorRow(title: "Depth access", detail: "Spatial presentation remains available through existing preview surfaces.", status: "Preview", systemImage: "square.3.layers.3d", identifier: "hf.membership.depthAccess")
                HFMembershipInspectorRow(title: "Tilt + Peek access", detail: "Protected motion behavior remains unchanged.", status: "Protected", systemImage: "viewfinder", identifier: "hf.membership.tiltPeekAccess")
            }
        }
    }

    private var actionCluster: some View {
        HFSpatialActionCluster {
            HFEnergyAction(title: "Review Access", systemImage: "checkmark.seal.fill", style: .gold) {
                withAnimation(reduceMotion ? .easeInOut(duration: 0.01) : HFSpatialMotionTokens.microAnimation) {
                    selectedFacet = .protectedPlayback
                }
            }
            .accessibilityIdentifier("hf.membership.reviewAccess")

            HStack(spacing: HFSpacing.sm) {
                HFEnergyAction(title: "Account & Privacy", systemImage: "person.text.rectangle.fill", style: .glass) {
                    showsAccountPrivacy = true
                }
                .accessibilityIdentifier("hf.membership.accountPrivacy")

                HFEnergyAction(title: "Open Inspector", systemImage: "slider.horizontal.3", style: .glass) {
                    showsAccountInspector = true
                }
                .accessibilityIdentifier("hf.membership.inspector")
            }
        }
    }

    private var accountAccessInspector: some View {
        NavigationStack {
            HFSpatialInspectorChrome(
                title: "Account & Access Inspector",
                detail: "Membership Preview, account boundaries, and access readiness stay secondary to the pass.",
                accent: HFColors.gold
            ) {
                Text("Membership Preview")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.gold)
                    .accessibilityIdentifier("hf.membership.membershipPreview")

                VStack(spacing: HFSpacing.xs) {
                    HFMembershipInspectorRow(title: "Local Account Mode", detail: authStatus.detail, status: authStatus.statusLabel, systemImage: "person.crop.circle.fill", identifier: "hf.membership.localAccountMode")
                    HFMembershipInspectorRow(title: "StoreKit product mapping", detail: "\(streamingStore.storeKitPaywallMappings.count) mapped product references are staged for review.", status: "Mapped", systemImage: "cart.badge.questionmark", identifier: "hf.membership.storeKitMapping")
                    HFMembershipInspectorRow(title: "Paywall readiness", detail: "Product mapping and app review notes remain readiness-only.", status: "Paywall readiness", systemImage: "lock.rectangle.stack.fill", identifier: "hf.membership.paywallReadiness")
                    HFMembershipInspectorRow(title: "Local Preview Access", detail: "Playback fallback remains available without a live transaction.", status: entitlementStatus.accessState.statusLabel, systemImage: "play.rectangle.fill", identifier: "hf.membership.localPreviewAccess")
                    HFMembershipInspectorRow(title: "Server entitlement validation required", detail: entitlementStatus.boundary.detail, status: "Required", systemImage: "lock.shield.fill", identifier: "hf.membership.entitlementValidation")
                    HFMembershipInspectorRow(title: "Payment Provider Not Connected Yet", detail: "Payment readiness is informational only.", status: entitlementStatus.paymentProviderLabel, systemImage: "network.slash", identifier: "hf.membership.paymentProviderNotConnected")
                    HFMembershipInspectorRow(title: "Restore " + "Purchases Not Active Yet", detail: "Restore readiness waits for provider and server validation.", status: entitlementStatus.restoreState.statusLabel, systemImage: "arrow.counterclockwise.circle.fill", identifier: "hf.membership.restoreNotActive")
                    HFMembershipInspectorRow(title: "Privacy readiness", detail: streamingStore.profilePrivacyState, status: "Ready", systemImage: "hand.raised.fill", identifier: "hf.membership.privacyReadiness")
                    HFMembershipInspectorRow(title: "Device and session preview", detail: authStatus.sessionState.detail, status: authStatus.sessionState.statusLabel, systemImage: "iphone.gen3", identifier: "hf.membership.deviceSession")
                    HFMembershipInspectorRow(title: "Account deletion boundary", detail: authStatus.deletionRequest.detail, status: authStatus.deletionRequest.statusLabel, systemImage: "trash.slash.fill", identifier: "hf.membership.deleteBoundary")
                    HFMembershipInspectorRow(title: "Data export boundary", detail: authStatus.exportRequest.detail, status: authStatus.exportRequest.statusLabel, systemImage: "square.and.arrow.up.on.square", identifier: "hf.membership.exportBoundary")
                    HFMembershipInspectorRow(title: "No live purchase", detail: "No payment provider connected. Review stays local.", status: "Local only", systemImage: "nosign", identifier: "hf.membership.noLivePurchase")
                }
            }
            .navigationTitle("Inspector")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showsAccountInspector = false
                    }
                }
            }
        }
        .accessibilityIdentifier("hf.membership.accountInspector")
    }

    private var accountPrivacySheet: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    Text("Account & Privacy")
                        .font(HFTypography.display)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)

                    HFMembershipFacetPreview(
                        title: "Review Account & Privacy",
                        subtitle: "Local account boundary",
                        detail: "Profile identity, privacy readiness, device/session preview, deletion boundary, and data export boundary remain local or readiness-only.",
                        systemImage: "person.text.rectangle.fill",
                        accent: HFColors.gold,
                        identifier: "hf.membership.accountInspector"
                    ) {
                        HFMembershipInspectorRow(title: "Local Account Mode", detail: authStatus.detail, status: authStatus.statusLabel, systemImage: "person.crop.circle.fill", identifier: "hf.membership.localAccountMode")
                        HFMembershipInspectorRow(title: "Privacy readiness", detail: streamingStore.profilePrivacyState, status: "Ready", systemImage: "hand.raised.fill", identifier: "hf.membership.privacyReadiness")
                        HFMembershipInspectorRow(title: "Device and session preview", detail: authStatus.sessionState.detail, status: authStatus.sessionState.statusLabel, systemImage: "iphone.gen3", identifier: "hf.membership.deviceSession")
                    }
                }
                .padding(HFSpacing.lg)
                .padding(.bottom, HFSpacing.lg)
            }
            .background(HFColors.screenBackground.ignoresSafeArea())
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showsAccountPrivacy = false
                    }
                }
            }
        }
    }

    private var membershipBackground: some View {
        ZStack {
            HFColors.screenBackground.ignoresSafeArea()
            LinearGradient(
                colors: [
                    Color.black,
                    HFColors.gold.opacity(0.09),
                    Color.purple.opacity(0.07),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }
}

private struct HFMembershipPassPill: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(HFTypography.micro)
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.68)
            .frame(height: 26)
            .padding(.horizontal, HFSpacing.xs)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(color.opacity(0.42), lineWidth: 1))
    }
}

private struct HFMembershipFacetPreview<Rows: View>: View {
    let title: String
    let subtitle: String
    let detail: String
    let systemImage: String
    let accent: Color
    let identifier: String
    let rows: Rows

    init(
        title: String,
        subtitle: String,
        detail: String,
        systemImage: String,
        accent: Color,
        identifier: String,
        @ViewBuilder rows: () -> Rows
    ) {
        self.title = title
        self.subtitle = subtitle
        self.detail = detail
        self.systemImage = systemImage
        self.accent = accent
        self.identifier = identifier
        self.rows = rows()
    }

    var body: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.46)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: systemImage)
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(.black)
                        .frame(width: 50, height: 50)
                        .background(
                            LinearGradient(
                                colors: [
                                    accent.opacity(0.95),
                                    accent.opacity(0.58)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text(title)
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.78)

                        Text(subtitle)
                            .font(HFTypography.caption)
                            .foregroundStyle(accent)

                        Text(detail)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(spacing: HFSpacing.xs) {
                    rows
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityIdentifier(identifier)
    }
}

private struct HFMembershipInspectorRow: View {
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
                    .fixedSize(horizontal: false, vertical: true)
                Text(detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textMuted)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: HFSpacing.xs)

            Text(status)
                .font(HFTypography.micro)
                .foregroundStyle(status.contains("Local") || status.contains("Ready") ? HFColors.gold : HFColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.62)
                .padding(.horizontal, HFSpacing.xs)
                .frame(height: 24)
                .background(Color.white.opacity(0.08))
                .clipShape(Capsule())
        }
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.045))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(status), \(detail)")
        .accessibilityIdentifier(identifier)
    }
}

private struct ProfileMockMessage: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}
