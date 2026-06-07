import SwiftUI

struct FinalDemoTourView: View {
    private var featuredMovie: Movie {
        HFMockData.movie("friendly") ?? HFMockData.movies[0]
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                overviewSection
                guidedStepsSection
                demoModesSection
                provesSection
                doesNotDoSection
                finalRule
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Final Demo Tour")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFStatusBadge(title: "Local walkthrough", isProminent: true)

            Text("Final Demo Tour")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text("Walk through HighFive from Watch to Export with local preview routes.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Demo Overview", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    Text("Watch -> Create -> Connect -> Launch -> Export")
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.gold)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Use this local tour to review the product journey before final QA. Active screens open locally; future export and capture systems are clearly marked locked until scoped.")
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var guidedStepsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Guided Tour Steps", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(Array(HFFinalDemoTourData.steps.enumerated()), id: \.element.id) { index, step in
                    stepRoute(for: step, index: index + 1)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var demoModesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Demo Modes", actionTitle: nil)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    ForEach(HFFinalDemoTourData.audiencePaths) { path in
                        NavigationLink {
                            DemoAudiencePathView()
                        } label: {
                            HFDemoAudiencePathCard(path: path)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
            .scrollClipDisabled()
        }
    }

    private var provesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "What This Tour Proves", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 230), spacing: HFSpacing.md)], spacing: HFSpacing.md) {
                ForEach(HFFinalDemoTourData.highlights) { highlight in
                    HFEcosystemCard(
                        title: highlight.title,
                        subtitle: highlight.subtitle,
                        systemImage: highlight.systemImage,
                        status: highlight.status,
                        minWidth: 230
                    )
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var doesNotDoSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "What This Tour Does Not Do", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach([
                    "Does not submit to App Store",
                    "Does not connect backend, accounts, or payments",
                    "Does not upload files or process creator assets",
                    "Does not capture camera, screen, or protected media",
                    "Does not render, save, or share images",
                    "Does not touch protected playback, depth, motion, or rendering systems"
                ], id: \.self) { item in
                    HFInsightCard(title: item, message: "Locked until a separate protected implementation phase.", systemImage: "lock.shield.fill")
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var finalRule: some View {
        HFInsightCard(
            title: "Final Demo Rule",
            message: "HighFive is demo-ready only when the tree is clean, the latest feature is committed, QA has passed, and every real system remains locked until separately scoped.",
            systemImage: "checkmark.seal.fill"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    @ViewBuilder
    private func stepRoute(for step: HFFinalDemoStep, index: Int) -> some View {
        switch step.title {
        case "Watch The Friendly", "Open Movie Detail":
            NavigationLink(value: featuredMovie) {
                HFFinalDemoStepCard(step: step, stepNumber: index)
            }
            .buttonStyle(.plain)
        case "Explore Unified Discovery":
            NavigationLink {
                UnifiedDiscoveryView()
                    .padding(.top, HFSpacing.lg)
                    .background(HFColors.screenBackground.ignoresSafeArea())
            } label: {
                HFFinalDemoStepCard(step: step, stepNumber: index)
            }
            .buttonStyle(.plain)
        case "Open Personalized Hub":
            NavigationLink {
                PersonalizedHubView()
            } label: {
                HFFinalDemoStepCard(step: step, stepNumber: index)
            }
            .buttonStyle(.plain)
        case "Enter Creator Mode":
            NavigationLink {
                CreatorEntryView()
            } label: {
                HFFinalDemoStepCard(step: step, stepNumber: index)
            }
            .buttonStyle(.plain)
        case "Open Creator Command Center":
            NavigationLink {
                CreatorWorkflowCommandCenterView()
            } label: {
                HFFinalDemoStepCard(step: step, stepNumber: index)
            }
            .buttonStyle(.plain)
        case "Continue Package Builder":
            NavigationLink {
                CreatorPackageBuilderPreviewView()
            } label: {
                HFFinalDemoStepCard(step: step, stepNumber: index)
            }
            .buttonStyle(.plain)
        case "Review Release Readiness":
            NavigationLink {
                CreatorReleaseReadinessPreviewView()
            } label: {
                HFFinalDemoStepCard(step: step, stepNumber: index)
            }
            .buttonStyle(.plain)
        case "Open Connect Hub":
            NavigationLink {
                ConnectHubView()
            } label: {
                HFFinalDemoStepCard(step: step, stepNumber: index)
            }
            .buttonStyle(.plain)
        case "Explore Social Rooms":
            NavigationLink {
                SocialRoomsPreviewView()
            } label: {
                HFFinalDemoStepCard(step: step, stepNumber: index)
            }
            .buttonStyle(.plain)
        case "Open Social Graph":
            NavigationLink {
                SocialGraphPreviewView()
            } label: {
                HFFinalDemoStepCard(step: step, stepNumber: index)
            }
            .buttonStyle(.plain)
        case "Open Launch Center":
            NavigationLink {
                CreatorLaunchCenterPreviewView()
            } label: {
                HFFinalDemoStepCard(step: step, stepNumber: index)
            }
            .buttonStyle(.plain)
        case "Preview Access":
            NavigationLink {
                CreatorAccessPreviewView()
            } label: {
                HFFinalDemoStepCard(step: step, stepNumber: index)
            }
            .buttonStyle(.plain)
        case "Open Product Spine Lockdown":
            NavigationLink {
                ProductSpineLockdownView()
            } label: {
                HFFinalDemoStepCard(step: step, stepNumber: index)
            }
            .buttonStyle(.plain)
        case "Finish at Release Candidate Prep":
            NavigationLink {
                ReleaseCandidatePrepView()
            } label: {
                HFFinalDemoStepCard(step: step, stepNumber: index)
            }
            .buttonStyle(.plain)
        default:
            HFFinalDemoStepCard(step: step, stepNumber: index, showsRouteCue: false)
        }
    }
}
