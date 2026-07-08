import SwiftUI

private struct HFStudioIntelligenceProject: Identifiable {
    let id: String
    let title: String
    let packaging: Int
    let release: Int
    let marketing: Int
    let qaStatus: String
    let nextBestAction: String
}

private struct HFStudioIntelligenceCategory: Identifiable {
    let id: String
    let title: String
    let score: Int
    let systemImage: String
}

struct StudioIntelligenceDashboardView: View {
    private let projects = [
        HFStudioIntelligenceProject(
            id: "mark-west",
            title: "The Mark of the West",
            packaging: 74,
            release: 52,
            marketing: 68,
            qaStatus: "Visual QA",
            nextBestAction: "Finish LinkedIn package before launch."
        ),
        HFStudioIntelligenceProject(
            id: "paranormall",
            title: "Paranormall",
            packaging: 88,
            release: 78,
            marketing: 72,
            qaStatus: "Release QA",
            nextBestAction: "Trailer package is below readiness threshold."
        ),
        HFStudioIntelligenceProject(
            id: "friendly",
            title: "The Friendly",
            packaging: 94,
            release: 86,
            marketing: 80,
            qaStatus: "Ready",
            nextBestAction: "Movie Detail and consumer experience are ready for visual QA."
        )
    ]

    private var categories: [HFStudioIntelligenceCategory] {
        [
            HFStudioIntelligenceCategory(id: "consumer", title: "Consumer Experience", score: 86, systemImage: "play.tv.fill"),
            HFStudioIntelligenceCategory(id: "packaging", title: "Packaging", score: average(\.packaging), systemImage: "shippingbox.fill"),
            HFStudioIntelligenceCategory(id: "creator", title: "Creator Workflow", score: 81, systemImage: "rectangle.3.group.fill"),
            HFStudioIntelligenceCategory(id: "release", title: "Release Readiness", score: average(\.release), systemImage: "checkmark.seal.fill"),
            HFStudioIntelligenceCategory(id: "qa", title: "QA", score: 76, systemImage: "checklist.checked"),
            HFStudioIntelligenceCategory(id: "marketing", title: "Marketing", score: average(\.marketing), systemImage: "megaphone.fill")
        ]
    }

    private var recommendations: [String] {
        [
            "Finish LinkedIn package before launch.",
            "Trailer package is below readiness threshold.",
            "Press kit needs director bio.",
            "Launch readiness is improving.",
            "Movie Detail and consumer experience are ready for visual QA."
        ]
    }

    private var studioHealthScore: Int {
        average(categories.map(\.score))
    }

    private var strongestCategory: HFStudioIntelligenceCategory {
        categories.max { $0.score < $1.score } ?? categories[0]
    }

    private var weakestCategory: HFStudioIntelligenceCategory {
        categories.min { $0.score < $1.score } ?? categories[0]
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                hero
                categoryGrid
                projectIntelligence
                recommendationsPanel
                commandCenterActions
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
            .padding(.top, 28)
            .padding(.bottom, 44)
        }
        .background(intelligenceBackground)
        .navigationTitle("Studio Intelligence")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("hf.studioIntelligence.dashboard")
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black,
                            HFColors.gold.opacity(0.16),
                            HFColors.cyanGlow.opacity(0.08),
                            Color.black.opacity(0.94)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(HFLayer4VolumetricGlow(motion: .still, tint: HFColors.gold, intensity: 0.68))
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(HFColors.gold.opacity(0.30), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.44), radius: 30, x: 0, y: 18)

            VStack(alignment: .leading, spacing: 12) {
                Text("LOCAL STUDIO COMMAND CENTER")
                    .font(.system(size: 12, weight: .black))
                    .tracking(1.6)
                    .foregroundStyle(HFColors.gold)

                Text("Studio Intelligence")
                    .font(.system(size: 36, weight: .black))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)

                Text("Consumer, packaging, creator workflow, release, QA, marketing, and local recommendations in one private dashboard. No AI API, backend, network, upload, publishing, auth, or CRM connection is active.")
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                studioHealthSummary
            }
            .padding(22)
        }
        .frame(minHeight: 285)
    }

    private var studioHealthSummary: some View {
        VStack(alignment: .leading, spacing: 10) {
            readinessMeter(title: "Overall Studio Health", score: studioHealthScore)
            HStack(spacing: 8) {
                intelligencePill("Strongest: \(strongestCategory.title)")
                intelligencePill("Focus: \(weakestCategory.title)")
            }
        }
    }

    private var categoryGrid: some View {
        intelligencePanel(title: "Dashboard", subtitle: "Operational categories", systemImage: "rectangle.grid.2x2.fill") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(categories) { category in
                    categoryCard(category)
                }
            }
        }
    }

    private var projectIntelligence: some View {
        intelligencePanel(title: "Project Intelligence", subtitle: "Local/demo project readiness", systemImage: "film.stack.fill") {
            VStack(spacing: 12) {
                ForEach(projects) { project in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(project.title)
                                .font(HFTypography.cardTitle)
                                .foregroundStyle(HFColors.textPrimary)
                            Spacer()
                            Text(project.qaStatus)
                                .font(HFTypography.micro.weight(.black))
                                .foregroundStyle(HFColors.gold)
                        }

                        HStack(spacing: 8) {
                            projectMetric("Package", project.packaging)
                            projectMetric("Release", project.release)
                            projectMetric("Marketing", project.marketing)
                        }

                        Text(project.nextBestAction)
                            .font(HFTypography.caption.weight(.semibold))
                            .foregroundStyle(HFColors.textSecondary)
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
        }
    }

    private var recommendationsPanel: some View {
        intelligencePanel(title: "Recommendations", subtitle: "Local computed guidance", systemImage: "sparkles") {
            VStack(spacing: 10) {
                ForEach(recommendations, id: \.self) { recommendation in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 14, weight: .black))
                            .foregroundStyle(HFColors.gold)
                            .frame(width: 24)
                        Text(recommendation)
                            .font(HFTypography.caption.weight(.semibold))
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }
    }

    private var commandCenterActions: some View {
        intelligencePanel(title: "Command Center", subtitle: "Local actions only", systemImage: "command") {
            VStack(spacing: 10) {
                NavigationLink {
                    CreatorOSWorkspaceView()
                } label: {
                    commandAction("Open Creator OS", "rectangle.3.group.fill", isPrimary: true)
                }
                .buttonStyle(.plain)

                NavigationLink {
                    PackagingWorkspaceView()
                } label: {
                    commandAction("Open Packaging Studio", "shippingbox.fill", isPrimary: true)
                }
                .buttonStyle(.plain)

                commandAction("Review Release Readiness", "checkmark.seal.fill")
                commandAction("Review Marketing Plan", "megaphone.fill")
                commandAction("Run QA Checklist", "checklist.checked")
            }
        }
    }

    private var intelligenceBackground: some View {
        ZStack {
            HFColors.background.ignoresSafeArea()
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.034, green: 0.027, blue: 0.020),
                    HFColors.background
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            RadialGradient(
                colors: [HFColors.gold.opacity(0.14), .clear],
                center: .topTrailing,
                startRadius: 18,
                endRadius: 580
            )
            .ignoresSafeArea()
        }
    }

    private func intelligencePanel<Content: View>(
        title: String,
        subtitle: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.075), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(HFColors.textPrimary)
                    Text(subtitle)
                        .font(HFTypography.caption.weight(.semibold))
                        .foregroundStyle(HFColors.textSecondary)
                }
                Spacer()
            }
            content()
        }
        .padding(18)
        .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(HFColors.gold.opacity(0.16), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.28), radius: 18, x: 0, y: 10)
    }

    private func categoryCard(_ category: HFStudioIntelligenceCategory) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: category.systemImage)
                .font(.system(size: 17, weight: .black))
                .foregroundStyle(HFColors.gold)
            Text("\(category.score)%")
                .font(.system(size: 25, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
            Text(category.title)
                .font(HFTypography.caption.weight(.bold))
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func projectMetric(_ title: String, _ score: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(score)%")
                .font(HFTypography.caption.weight(.black))
                .foregroundStyle(HFColors.gold)
            Text(title)
                .font(HFTypography.micro.weight(.bold))
                .foregroundStyle(HFColors.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func commandAction(_ title: String, _ systemImage: String, isPrimary: Bool = false) -> some View {
        Label(title, systemImage: systemImage)
            .font(HFTypography.caption.weight(.black))
            .foregroundStyle(isPrimary ? .black : HFColors.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(isPrimary ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(Color.white.opacity(0.055)), in: Capsule())
            .overlay(Capsule().stroke(HFColors.gold.opacity(isPrimary ? 0.0 : 0.16), lineWidth: 1))
    }

    private func readinessMeter(title: String, score: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(HFTypography.caption.weight(.black))
                    .foregroundStyle(HFColors.textPrimary)
                Spacer()
                Text("\(score)%")
                    .font(HFTypography.caption.weight(.black))
                    .foregroundStyle(HFColors.gold)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.08))
                    Capsule()
                        .fill(HFColors.goldGradient)
                        .frame(width: proxy.size.width * CGFloat(score) / 100)
                }
            }
            .frame(height: 7)
        }
    }

    private func intelligencePill(_ title: String) -> some View {
        Text(title)
            .font(HFTypography.micro.weight(.black))
            .foregroundStyle(HFColors.gold)
            .padding(.horizontal, 10)
            .frame(height: 28)
            .background(Color.white.opacity(0.075), in: Capsule())
    }

    private func average(_ keyPath: KeyPath<HFStudioIntelligenceProject, Int>) -> Int {
        average(projects.map { $0[keyPath: keyPath] })
    }

    private func average(_ values: [Int]) -> Int {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / values.count
    }
}
