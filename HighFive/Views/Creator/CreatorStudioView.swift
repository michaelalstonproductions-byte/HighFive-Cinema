import SwiftUI

enum HFCreatorStudioFocus: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case socialMediaKit = "Social Kit"
    case vodPackage = "VOD Package"

    var id: String { rawValue }
}

struct CreatorStudioView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var streamingStore: HFStreamingStore
    @State private var selectedFocus: HFCreatorStudioFocus
    @State private var didSaveLocalDraft = false

    init(initialFocus: HFCreatorStudioFocus = .dashboard) {
        _selectedFocus = State(initialValue: initialFocus)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                focusTabs
                dashboardSection
                localDraftActions

                switch selectedFocus {
                case .dashboard:
                    socialMediaKitSection
                    vodPackageSection
                case .socialMediaKit:
                    socialMediaKitSection
                    vodPackageSection
                case .vodPackage:
                    vodPackageSection
                    socialMediaKitSection
                }

                backendReadinessSection
            }
            .padding(.top, HFSpacing.xxl)
            .padding(.bottom, HFSpacing.floatingTabClearance + HFSpacing.tabBarHeight)
        }
        .safeAreaInset(edge: .top) {
            Color.clear
                .frame(height: 4)
                .accessibilityIdentifier("hf.safeArea.topProtected")
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear
                .frame(height: 4)
                .accessibilityIdentifier("hf.safeArea.bottomProtected")
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Creator Studio")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("hf.creatorStudio.screen")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(.black)
                    .frame(width: 54, height: 54)
                    .background(HFColors.goldGradient)
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text("Creator Studio")
                        .font(HFTypography.display)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)

                    Text("Build the Release, Prepare the Social Kit, and Package the VOD for local review.")
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textSecondary)
                        .lineLimit(3)
                        .minimumScaleFactor(0.86)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: HFSpacing.xs) {
                        HFCreatorStudioPill(title: "Local Draft", isActive: true)
                        HFCreatorStudioPill(title: "Provider-ready")
                        HFCreatorStudioPill(title: "Not Connected Yet")
                    }
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var focusTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HFSpacing.xs) {
                ForEach(HFCreatorStudioFocus.allCases) { focus in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFocus = focus
                        }
                    } label: {
                        Text(focus.rawValue)
                            .font(HFTypography.smallAction)
                            .foregroundStyle(selectedFocus == focus ? .black : HFColors.textPrimary)
                            .padding(.horizontal, HFSpacing.md)
                            .frame(height: 36)
                            .background(selectedFocus == focus ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(Color.white.opacity(0.10)))
                            .overlay(Capsule().stroke(selectedFocus == focus ? Color.clear : HFColors.glassStroke, lineWidth: 1))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var backendReadinessSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Backend Readiness",
                    detail: "Local Draft actions stay available while Creator, Social, and VOD providers remain Not Connected Yet.",
                    systemImage: "server.rack",
                    accent: HFColors.gold
                )

                VStack(spacing: HFSpacing.xs) {
                    HFCreatorStudioReadinessRow(
                        title: "Creator Studio Backend",
                        detail: streamingStore.creatorStudioBackendStatus.statusLabel,
                        status: streamingStore.creatorStudioBackendStatus.isConfigured ? "Configured" : "Not Connected Yet",
                        systemImage: streamingStore.creatorStudioBackendStatus.systemImage,
                        accent: HFColors.gold
                    )
                    .accessibilityIdentifier("hf.creatorStudio.backendStatus")

                    HFCreatorStudioReadinessRow(
                        title: "Social Media Backend",
                        detail: streamingStore.socialKitBackendStatus.statusLabel,
                        status: streamingStore.socialKitBackendStatus.isConfigured ? "Configured" : "Not Connected Yet",
                        systemImage: streamingStore.socialKitBackendStatus.systemImage,
                        accent: Color.orange
                    )
                    .accessibilityIdentifier("hf.creatorStudio.socialBackendStatus")

                    HFCreatorStudioReadinessRow(
                        title: "VOD Backend",
                        detail: streamingStore.vodBackendStatus.statusLabel,
                        status: streamingStore.vodBackendStatus.isConfigured ? "Configured" : "Not Connected Yet",
                        systemImage: streamingStore.vodBackendStatus.systemImage,
                        accent: HFColors.gold
                    )
                    .accessibilityIdentifier("hf.creatorStudio.vodBackendStatus")
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Creator Studio backend readiness \(streamingStore.backendStatus.statusLabel)")
    }

    private var dashboardSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Current Project", actionTitle: "Tonight on HighFive")

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.36)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        Image(systemName: "film.stack.fill")
                            .font(.system(size: 22, weight: .black))
                            .foregroundStyle(HFColors.gold)
                            .frame(width: 48, height: 48)
                            .background(HFColors.gold.opacity(0.13))
                            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            Text("\(streamingStore.featuredMovie.title) Creator Slate")
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                            Text("Current project, local project status, and creator profile context stay inside this app.")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 138), spacing: HFSpacing.xs)], alignment: .leading, spacing: HFSpacing.xs) {
                        HFCreatorStudioMetric(title: "Current project", detail: streamingStore.featuredMovie.title, systemImage: "sparkles.tv.fill", isActive: true)
                        HFCreatorStudioMetric(title: "Local project status", detail: "Local Draft", systemImage: "pencil")
                        HFCreatorStudioMetric(title: "Creator profile", detail: streamingStore.activeViewingProfile.displayName, systemImage: streamingStore.activeViewingProfile.avatarSymbol)
                        HFCreatorStudioMetric(title: "Provider boundary", detail: "Not Connected Yet", systemImage: "network.slash")
                    }
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Studio Dashboard, local project status, creator profile context")
        .accessibilityIdentifier("hf.creatorStudio.dashboard")
        .accessibilityIdentifier("hf.creatorStudio.currentProject")
        .accessibilityIdentifier("hf.creatorStudio.workspaceModules")
    }

    private var socialMediaKitSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Social Media Kit", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: Color.orange.opacity(0.36)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    sectionLead(
                        title: "Social Media Kit",
                        detail: "Build local captions, poster notes, and platform readiness before any account is connected.",
                        systemImage: "bubble.left.and.bubble.right.fill",
                        accent: Color.orange
                    )

                    HStack(spacing: HFSpacing.xs) {
                        HFCreatorStudioPill(title: "Local Draft", isActive: true)
                        HFCreatorStudioPill(title: "Provider-ready")
                        HFCreatorStudioPill(title: "Not Connected Yet")
                    }

                    Button {
                        selectedFocus = .socialMediaKit
                    } label: {
                        HFCreatorStudioAction(title: "Prepare the Social Kit", systemImage: "bubble.left.and.bubble.right.fill", isPrimary: selectedFocus == .socialMediaKit)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.creatorStudio.prepareSocialKit")

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Caption Drafts")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .accessibilityIdentifier("hf.creatorStudio.socialCaptionDrafts")

                        ForEach(captionDraftCards) { draft in
                            HFCreatorStudioReadinessRow(title: draft.title, detail: draft.detail, status: "Local Draft", systemImage: "text.quote", accent: Color.orange)
                        }
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: HFSpacing.xs)], alignment: .leading, spacing: HFSpacing.xs) {
                        HFCreatorStudioMetric(title: "Poster", detail: "Placeholder", systemImage: "photo.fill")
                        HFCreatorStudioMetric(title: "Clip", detail: "Placeholder", systemImage: "play.rectangle.fill")
                        HFCreatorStudioMetric(title: "Trailer pull", detail: "Local Draft", systemImage: "film.fill")
                        HFCreatorStudioMetric(title: "Caption set", detail: "Local Draft", systemImage: "text.bubble.fill")
                    }

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Platform readiness")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .accessibilityIdentifier("hf.creatorStudio.socialPlatformReadiness")

                        ForEach(socialPlatformRows) { platform in
                            HFCreatorStudioReadinessRow(title: platform.title, detail: platform.detail, status: "Not Connected Yet", systemImage: "network.slash", accent: Color.orange)
                        }
                    }

                    HFCreatorStudioReadinessRow(
                        title: "No live publishing",
                        detail: "Local planning only. No account connection, posting, sharing, or provider SDK is active.",
                        status: "Safe Boundary",
                        systemImage: "lock.shield.fill",
                        accent: Color.orange
                    )
                    .accessibilityIdentifier("hf.creatorStudio.noLivePublishing")
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Social Media Kit, Local Draft, Provider-ready, Not Connected Yet, local-only release boundary")
        .accessibilityIdentifier("hf.creatorStudio.socialMediaKit")
        .accessibilityIdentifier("hf.creatorStudio.prepareSocialKit")
    }

    private var vodPackageSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "VOD Package", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.38)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    sectionLead(
                        title: "VOD Package",
                        detail: "Prepare trailer, poster, synopsis, and provider-readiness before distribution is connected.",
                        systemImage: "shippingbox.fill",
                        accent: HFColors.gold
                    )

                    HStack(spacing: HFSpacing.xs) {
                        HFCreatorStudioPill(title: "Local Draft", isActive: true)
                        HFCreatorStudioPill(title: "Provider-ready")
                        HFCreatorStudioPill(title: "Not Connected Yet")
                    }

                    Button {
                        selectedFocus = .vodPackage
                    } label: {
                        HFCreatorStudioAction(title: "Package the VOD", systemImage: "play.rectangle.on.rectangle.fill", isPrimary: selectedFocus == .vodPackage)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.creatorStudio.packageVOD")

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("VOD release checklist")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .accessibilityIdentifier("hf.creatorStudio.vodChecklist")

                        ForEach(vodChecklistRows) { item in
                            HFCreatorStudioReadinessRow(title: item.title, detail: item.detail, status: item.status, systemImage: item.systemImage, accent: HFColors.gold)
                        }
                    }

                    packagePreviewCard

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Provider status")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .accessibilityIdentifier("hf.creatorStudio.vodProviderStatus")

                        HFCreatorStudioReadinessRow(title: "Distribution provider", detail: "Not Connected Yet", status: "Provider-ready", systemImage: "network.slash", accent: HFColors.gold)
                        HFCreatorStudioReadinessRow(title: "Storefront provider", detail: "Not Connected Yet", status: "Provider-ready", systemImage: "cart.badge.questionmark", accent: HFColors.gold)
                        HFCreatorStudioReadinessRow(title: "Payment / entitlement provider", detail: "Not Connected Yet", status: "Boundary", systemImage: "checkmark.shield.fill", accent: HFColors.gold)
                    }

                    HFCreatorStudioReadinessRow(
                        title: "No live VOD provider",
                        detail: "No live VOD release, payments, media delivery, or file export is active.",
                        status: "Safe Boundary",
                        systemImage: "lock.shield.fill",
                        accent: HFColors.gold
                    )
                    .accessibilityIdentifier("hf.creatorStudio.noLiveVODProvider")
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("VOD Package, VOD release checklist, provider status Not Connected Yet")
        .accessibilityIdentifier("hf.creatorStudio.vodPackage")
        .accessibilityIdentifier("hf.creatorStudio.releasePrep")
        .accessibilityIdentifier("hf.creatorStudio.packageVOD")
    }

    private var localDraftActions: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Local Draft", actionTitle: nil)

            VStack(spacing: HFSpacing.sm) {
                Button {
                    selectedFocus = .socialMediaKit
                } label: {
                    HFCreatorStudioAction(title: "Prepare the Social Kit", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .buttonStyle(.plain)

                Button {
                    selectedFocus = .vodPackage
                } label: {
                    HFCreatorStudioAction(title: "Package the VOD", systemImage: "play.rectangle.on.rectangle.fill")
                }
                .buttonStyle(.plain)

                Button {
                    didSaveLocalDraft = true
                } label: {
                    HFCreatorStudioAction(title: didSaveLocalDraft ? "Local Draft Saved" : "Build the Release", systemImage: "checkmark.circle.fill", isPrimary: true)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.creatorStudio.localDraft")
                .accessibilityIdentifier("hf.creatorStudio.primaryAction")
                .accessibilityIdentifier("hf.creatorStudio.buildTheRelease")

                Button {
                    dismiss()
                } label: {
                    HFCreatorStudioAction(title: "Back to Profile", systemImage: "person.crop.circle.fill")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var packagePreviewCard: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Package preview")
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)

            HStack(alignment: .top, spacing: HFSpacing.sm) {
                Image(systemName: "play.rectangle.on.rectangle.fill")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
                    .background(HFColors.goldGradient)
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text(streamingStore.featuredMovie.title)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("Synopsis, poster placeholder, trailer placeholder, release mood, and Local Draft status are grouped for review.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(HFSpacing.md)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(HFColors.gold.opacity(0.18), lineWidth: 1)
        )
    }

    private var captionDraftCards: [HFCreatorStudioDraftCard] {
        [
            HFCreatorStudioDraftCard(title: "Premiere", detail: "Tonight on HighFive: choose the scene you would replay first."),
            HFCreatorStudioDraftCard(title: "Behind the Shot", detail: "Move the frame and peek into the moment."),
            HFCreatorStudioDraftCard(title: "Creator Note", detail: "Poster, mood, and trailer direction are ready for review.")
        ]
    }

    private var socialPlatformRows: [HFCreatorStudioDraftCard] {
        [
            HFCreatorStudioDraftCard(title: "Instagram", detail: "Poster drop - Provider-ready"),
            HFCreatorStudioDraftCard(title: "TikTok", detail: "Trailer clip - Provider-ready"),
            HFCreatorStudioDraftCard(title: "YouTube Shorts", detail: "Short caption - Provider-ready"),
            HFCreatorStudioDraftCard(title: "X / Threads", detail: "Creator prompt - Provider-ready")
        ]
    }

    private var vodChecklistRows: [HFCreatorStudioChecklistRow] {
        [
            HFCreatorStudioChecklistRow(title: "Trailer readiness", detail: "Trailer placeholder is staged for review.", status: "Local Draft", systemImage: "film.fill"),
            HFCreatorStudioChecklistRow(title: "Poster readiness", detail: "Poster placeholder is ready for notes.", status: "Placeholder", systemImage: "photo.fill"),
            HFCreatorStudioChecklistRow(title: "Synopsis readiness", detail: "Synopsis copy stays editable locally.", status: "Local Draft", systemImage: "text.alignleft"),
            HFCreatorStudioChecklistRow(title: "Metadata readiness", detail: "Title, genre, and release mood are grouped.", status: "Local Draft", systemImage: "tag.fill"),
            HFCreatorStudioChecklistRow(title: "Pricing / entitlement boundary", detail: "No payment flow is active.", status: "Boundary", systemImage: "checkmark.shield.fill"),
            HFCreatorStudioChecklistRow(title: "Distribution provider", detail: "Not Connected Yet", status: "Provider-ready", systemImage: "network.slash"),
            HFCreatorStudioChecklistRow(title: "Storefront provider", detail: "Not Connected Yet", status: "Provider-ready", systemImage: "cart.badge.questionmark")
        ]
    }

    private func sectionLead(title: String, detail: String, systemImage: String, accent: Color) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(accent)
                .frame(width: 48, height: 48)
                .background(accent.opacity(0.13))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Text(title)
                    .font(HFTypography.section)
                    .foregroundStyle(HFColors.textPrimary)
                Text(detail)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct HFCreatorStudioPill: View {
    let title: String
    var isActive = false

    var body: some View {
        Text(title)
            .font(HFTypography.micro)
            .foregroundStyle(isActive ? .black : HFColors.gold)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, HFSpacing.xs)
            .frame(height: 24)
            .background(isActive ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(HFColors.gold.opacity(0.10)))
            .overlay(Capsule().stroke(isActive ? Color.clear : HFColors.gold.opacity(0.24), lineWidth: 1))
            .clipShape(Capsule())
    }
}

private struct HFCreatorStudioDraftCard: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
}

private struct HFCreatorStudioChecklistRow: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let status: String
    let systemImage: String
}

private struct HFCreatorStudioMetric: View {
    let title: String
    let detail: String
    let systemImage: String
    var isActive = false

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(isActive ? .black : HFColors.gold)
                .frame(width: 30, height: 30)
                .background(isActive ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(HFColors.gold.opacity(0.12)))
                .clipShape(Circle())

            Text(title)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.74)

            Text(detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 102, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(isActive ? HFColors.gold.opacity(0.14) : Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous)
                .stroke(isActive ? HFColors.gold.opacity(0.38) : HFColors.glassStroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
    }
}

private struct HFCreatorStudioReadinessRow: View {
    let title: String
    let detail: String
    let status: String
    let systemImage: String
    let accent: Color

    var body: some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(accent)
                .frame(width: 32, height: 32)
                .background(accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

            VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                Text(title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: HFSpacing.xs)

            Text(status)
                .font(HFTypography.micro)
                .foregroundStyle(accent)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .padding(.horizontal, HFSpacing.xs)
                .frame(height: 24)
                .background(accent.opacity(0.10))
                .overlay(Capsule().stroke(accent.opacity(0.26), lineWidth: 1))
                .clipShape(Capsule())
        }
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }
}

private struct HFCreatorStudioAction: View {
    let title: String
    let systemImage: String
    var isPrimary = false

    var body: some View {
        HStack(spacing: HFSpacing.xs) {
            Image(systemName: systemImage)
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .black))
        }
        .font(HFTypography.smallAction)
        .foregroundStyle(isPrimary ? .black : HFColors.textPrimary)
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .padding(.horizontal, HFSpacing.md)
        .background(isPrimary ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(Color.white.opacity(0.08)))
        .overlay(Capsule().stroke(isPrimary ? Color.clear : HFColors.glassStroke, lineWidth: 1))
        .clipShape(Capsule())
    }
}
