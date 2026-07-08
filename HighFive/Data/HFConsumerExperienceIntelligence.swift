import Foundation

struct HFConsumerExperienceSignal: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let title: String
    let detail: String
    let movieID: String?
    let systemImage: String
}

struct HFConsumerExperienceSnapshot: Codable, Hashable, Sendable {
    let sourceLabel: String
    let heroEyebrow: String
    let heroTitle: String
    let heroDetail: String
    let continueWatchingDetail: String
    let recommendedDetail: String
    let comingSoonDetail: String
    let availableNowDetail: String
    let verticalStageDetail: String
    let suggestedSearches: [HFConsumerExperienceSignal]
    let recentSearches: [HFConsumerExperienceSignal]
    let trendingSignals: [HFConsumerExperienceSignal]
    let featuredCreators: [HFConsumerExperienceSignal]
    let recommendationReasons: [String: String]
}

enum HFConsumerExperienceIntelligence {
    static func snapshot(
        projects: [HFProject],
        studioIntelligence: HFStudioIntelligenceSnapshot,
        workflowAutomation: HFWorkflowAutomationSnapshot,
        orchestration: HFOrchestrationSnapshot,
        missionPlanner: HFMissionPlannerSnapshot,
        executionTracking: HFExecutionTrackingSnapshot,
        executiveCommand: HFExecutiveCommandCenterSnapshot,
        sourceLabel: String = "HFLocalProjectStore + HigherKey OS local signals"
    ) -> HFConsumerExperienceSnapshot {
        let consumerProjects = projects.sorted { lhs, rhs in
            consumerRank(lhs) > consumerRank(rhs)
        }
        let availableProjects = consumerProjects.filter { $0.movieID != nil && !$0.releaseState.localizedCaseInsensitiveContains("package") }
        let comingSoonProjects = consumerProjects.filter { $0.movieID == nil || $0.lifecycleState == .packaging || $0.readiness.overall < 0.65 }
        let topProject = consumerProjects.first
        let topAvailable = availableProjects.first ?? topProject
        let progressCount = executionTracking.activeExecutionStatuses.count
        let reviewCount = missionPlanner.activeMissions.filter { $0.status == .reviewNeeded || $0.status == .ready }.count

        return HFConsumerExperienceSnapshot(
            sourceLabel: sourceLabel,
            heroEyebrow: topProject?.movieID == nil ? "Coming Soon" : "Featured Now",
            heroTitle: topProject?.title ?? "HighFive Cinema",
            heroDetail: heroDetail(for: topProject, executiveScore: executiveCommand.overallStudioScore),
            continueWatchingDetail: progressCount > 0 ? "Resume stories with strong local momentum." : "Pick up your next local preview.",
            recommendedDetail: topAvailable.map { "Selected from local viewer, creator, and catalog signals around \($0.shortTitle)." } ?? "Selected from the local HighFive catalog.",
            comingSoonDetail: comingSoonProjects.first.map { "\($0.shortTitle) is staged as an upcoming HighFive preview." } ?? "Upcoming HighFive titles are staged locally.",
            availableNowDetail: availableProjects.isEmpty ? "Available titles are drawn from the local catalog." : "\(availableProjects.count) HighFive titles are ready to browse locally.",
            verticalStageDetail: "Portrait presentation uses cinematic lighting, glass, and framing while playback systems remain unchanged.",
            suggestedSearches: suggestedSearches(projects: consumerProjects),
            recentSearches: recentSearches(projects: consumerProjects),
            trendingSignals: trendingSignals(projects: consumerProjects, studioIntelligence: studioIntelligence, workflowAutomation: workflowAutomation, orchestration: orchestration),
            featuredCreators: featuredCreators(projects: consumerProjects),
            recommendationReasons: Dictionary(uniqueKeysWithValues: consumerProjects.compactMap { project in
                guard let movieID = project.movieID else { return nil }
                return (movieID, recommendationReason(for: project, reviewCount: reviewCount))
            })
        )
    }

    private static func heroDetail(for project: HFProject?, executiveScore: Int) -> String {
        guard let project else {
            return "Premium local recommendations are ready for this profile."
        }
        let tone = project.movieID == nil ? "upcoming" : "featured"
        return "\(project.shortTitle) is the \(tone) spotlight from local catalog, audience, and creator signals."
    }

    private static func suggestedSearches(projects: [HFProject]) -> [HFConsumerExperienceSignal] {
        let projectSignals = projects.prefix(3).map { project in
            HFConsumerExperienceSignal(
                id: "suggested-\(project.id.rawValue)",
                title: project.shortTitle,
                detail: project.movieID == nil ? "Coming soon" : "Recommended title",
                movieID: project.movieID,
                systemImage: project.movieID == nil ? "calendar.badge.clock" : "sparkles.tv.fill"
            )
        }

        return projectSignals + [
            HFConsumerExperienceSignal(id: "suggested-mystery", title: "Mystery", detail: "Shadow stories", movieID: nil, systemImage: "eye.fill"),
            HFConsumerExperienceSignal(id: "suggested-originals", title: "HighFive Originals", detail: "Creator-led premieres", movieID: nil, systemImage: "sparkles")
        ]
    }

    private static func recentSearches(projects: [HFProject]) -> [HFConsumerExperienceSignal] {
        projects.compactMap { project in
            guard let movieID = project.movieID else { return nil }
            return HFConsumerExperienceSignal(
                id: "recent-\(project.id.rawValue)",
                title: project.shortTitle,
                detail: "Recently explored",
                movieID: movieID,
                systemImage: "clock.arrow.circlepath"
            )
        }
    }

    private static func trendingSignals(
        projects: [HFProject],
        studioIntelligence: HFStudioIntelligenceSnapshot,
        workflowAutomation: HFWorkflowAutomationSnapshot,
        orchestration: HFOrchestrationSnapshot
    ) -> [HFConsumerExperienceSignal] {
        projects.prefix(4).map { project in
            let signalCount = studioIntelligence.events.filter { $0.projectID == project.id }.count
            let queueCount = orchestration.queue.filter { $0.projectID == project.id }.count
            let suggestionCount = workflowAutomation.triggeredSuggestions.filter { $0.projectID == project.id }.count
            let momentum = max(project.marketplaceInterest, signalCount + queueCount + suggestionCount)
            return HFConsumerExperienceSignal(
                id: "trending-\(project.id.rawValue)",
                title: project.shortTitle,
                detail: "\(momentum) local interest signals",
                movieID: project.movieID,
                systemImage: "chart.line.uptrend.xyaxis"
            )
        }
    }

    private static func featuredCreators(projects: [HFProject]) -> [HFConsumerExperienceSignal] {
        var seen = Set<String>()
        return projects.compactMap { project in
            guard seen.insert(project.creator).inserted else { return nil }
            return HFConsumerExperienceSignal(
                id: "creator-\(project.creator.slugID)",
                title: project.creator,
                detail: project.movieID == nil ? "Upcoming world" : "Featured creator",
                movieID: project.movieID,
                systemImage: "person.crop.rectangle.stack.fill"
            )
        }
    }

    private static func recommendationReason(for project: HFProject, reviewCount: Int) -> String {
        if project.readiness.overall >= 0.80 {
            return "Recommended from strong local audience and readiness signals."
        }
        if project.marketplaceInterest >= 40 {
            return "Because viewers are saving creator-led stories like this."
        }
        if reviewCount > 0 {
            return "Because this title is moving through the local preview queue."
        }
        return "Because you watched HighFive originals and related creator worlds."
    }

    private static func consumerRank(_ project: HFProject) -> Int {
        Int(project.readiness.overall * 100)
            + project.marketplaceInterest
            - (project.readiness.blockers * 4)
            + (project.movieID == nil ? 6 : 18)
    }
}

private extension String {
    var slugID: String {
        lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "-")
    }
}
