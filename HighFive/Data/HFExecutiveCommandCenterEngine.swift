import Foundation

enum HFExecutiveCommandCenterEngine {
    static func snapshot(
        projects: [HFProject],
        studioIntelligence: HFStudioIntelligenceSnapshot,
        workflowAutomation: HFWorkflowAutomationSnapshot,
        orchestration: HFOrchestrationSnapshot,
        missionPlanner: HFMissionPlannerSnapshot,
        executionTracking: HFExecutionTrackingSnapshot,
        sourceLabel: String = "HFLocalProjectStore + HigherKey OS local engines"
    ) -> HFExecutiveCommandCenterSnapshot {
        let risks = riskMatrix(
            projects: projects,
            workflowAutomation: workflowAutomation,
            orchestration: orchestration,
            missionPlanner: missionPlanner,
            executionTracking: executionTracking
        )
        let summary = executiveSummary(
            projects: projects,
            missionPlanner: missionPlanner,
            executionTracking: executionTracking,
            risks: risks
        )
        let health = healthMetrics(
            projects: projects,
            studioIntelligence: studioIntelligence,
            workflowAutomation: workflowAutomation,
            orchestration: orchestration,
            missionPlanner: missionPlanner,
            executionTracking: executionTracking,
            summary: summary
        )
        let briefing = executiveBriefing(
            projects: projects,
            missionPlanner: missionPlanner,
            executionTracking: executionTracking,
            risks: risks
        )
        let resources = resourceAllocation(
            missionPlanner: missionPlanner,
            executionTracking: executionTracking
        )
        let timeline = executiveTimeline(
            missionPlanner: missionPlanner,
            executionTracking: executionTracking
        )
        let actions = commandActions()

        return HFExecutiveCommandCenterSnapshot(
            sourceLabel: sourceLabel,
            summary: "Executive Command Center reads \(projects.count) projects, \(missionPlanner.activeMissions.count) missions, \(executionTracking.activeExecutionStatuses.count) execution statuses, and \(risks.count) risk records locally.",
            healthMetrics: health,
            executiveSummary: summary,
            briefing: briefing,
            riskMatrix: risks,
            resourceAllocation: resources,
            timeline: timeline,
            commandActions: actions
        )
    }

    private static func healthMetrics(
        projects: [HFProject],
        studioIntelligence: HFStudioIntelligenceSnapshot,
        workflowAutomation: HFWorkflowAutomationSnapshot,
        orchestration: HFOrchestrationSnapshot,
        missionPlanner: HFMissionPlannerSnapshot,
        executionTracking: HFExecutionTrackingSnapshot,
        summary: HFExecutiveSummary
    ) -> [HFExecutiveHealthMetric] {
        let consumerScore = average(projects.map { Int($0.readiness.assets * 100) })
        let creatorScore = average(projects.map { Int($0.readiness.teamReview * 100) })
        let packagingScore = average(projects.map { Int($0.readiness.package * 100) })
        let automationPenalty = min(45, workflowAutomation.blockedDependencies.count * 12 + workflowAutomation.triggeredSuggestions.count * 2)
        let automationScore = max(0, 100 - automationPenalty)
        let executionScore = executionTracking.averageCompletionPercent
        let releaseScore = releaseHealthScore(projects: projects, executionTracking: executionTracking)
        let marketingScore = timelineScore(for: .marketing, executionTracking: executionTracking)
        let overall = average([
            consumerScore,
            creatorScore,
            packagingScore,
            automationScore,
            executionScore,
            releaseScore,
            marketingScore
        ])

        return [
            healthMetric("overall-studio-score", "Overall Studio Score", overall, "\(summary.blockedProjects) blocked projects, \(summary.projectsReadyForReview) ready for review.", "gauge.with.dots.needle.67percent"),
            healthMetric("consumer-health", "Consumer Health", consumerScore, "\(studioIntelligence.events.count) local project events feeding consumer readiness.", "play.tv.fill"),
            healthMetric("creator-health", "Creator Health", creatorScore, "\(missionPlanner.activeMissions.count) active creator and studio missions.", "person.crop.rectangle.stack.fill"),
            healthMetric("packaging-health", "Packaging Health", packagingScore, "\(projects.filter { $0.lifecycleState == .packaging }.count) packaging-stage projects.", "shippingbox.fill"),
            healthMetric("automation-health", "Automation Health", automationScore, "\(workflowAutomation.triggeredSuggestions.count) local suggestions, \(workflowAutomation.blockedDependencies.count) blocked dependencies.", "arrow.triangle.branch"),
            healthMetric("execution-health", "Execution Health", executionScore, "\(executionTracking.taskCompletionStates.count) tracked task states.", "chart.line.uptrend.xyaxis"),
            healthMetric("release-health", "Release Health", releaseScore, "\(summary.projectsReadyForRelease) projects ready for release review.", "flag.checkered"),
            healthMetric("marketing-health", "Marketing Health", marketingScore, "Marketing timeline progress remains local-only.", "megaphone.fill")
        ]
    }

    private static func executiveSummary(
        projects: [HFProject],
        missionPlanner: HFMissionPlannerSnapshot,
        executionTracking: HFExecutionTrackingSnapshot,
        risks: [HFExecutiveRiskRecord]
    ) -> HFExecutiveSummary {
        let blockedProjects = Set(executionTracking.activeExecutionStatuses.filter { $0.status == .blocked }.map(\.projectID)).count
        let readyForReview = Set(missionPlanner.activeMissions.filter { $0.status == .reviewNeeded || $0.status == .ready }.map(\.projectID)).count
        let readyForRelease = projects.filter { project in
            project.readiness.overall >= 0.80 &&
                !executionTracking.activeExecutionStatuses.contains { $0.projectID == project.id && $0.status == .blocked }
        }.count

        return HFExecutiveSummary(
            projectCount: projects.count,
            completedMilestones: missionPlanner.milestones.filter { $0.status == .ready }.count,
            blockedProjects: blockedProjects,
            criticalRisks: risks.filter { $0.level == .critical }.count,
            projectsReadyForReview: readyForReview,
            projectsReadyForRelease: readyForRelease
        )
    }

    private static func executiveBriefing(
        projects: [HFProject],
        missionPlanner: HFMissionPlannerSnapshot,
        executionTracking: HFExecutionTrackingSnapshot,
        risks: [HFExecutiveRiskRecord]
    ) -> HFExecutiveBriefing {
        let topMission = missionPlanner.activeMissions.first
        let topRisk = risks.sorted { riskRank($0.level) > riskRank($1.level) }.first
        let topOpportunity = projects.sorted { $0.readiness.overall > $1.readiness.overall }.first
        let blockedCount = executionTracking.blockedTaskCount

        return HFExecutiveBriefing(
            todaysPriorities: topMission.map { "\($0.projectTitle): \($0.objective)" } ?? "Review local project state.",
            highestRisk: topRisk.map { "\($0.projectTitle): \($0.title)" } ?? "No critical local risk.",
            highestOpportunity: topOpportunity.map { "\($0.shortTitle) is \(Int($0.readiness.overall * 100))% ready." } ?? "No opportunity signal available.",
            recommendedFocus: blockedCount > 0 ? "Clear \(blockedCount) execution blockers before advancing release or marketing work." : "Move ready missions through QA, release, and marketing review."
        )
    }

    private static func riskMatrix(
        projects: [HFProject],
        workflowAutomation: HFWorkflowAutomationSnapshot,
        orchestration: HFOrchestrationSnapshot,
        missionPlanner: HFMissionPlannerSnapshot,
        executionTracking: HFExecutionTrackingSnapshot
    ) -> [HFExecutiveRiskRecord] {
        let projectByID = Dictionary(uniqueKeysWithValues: projects.map { ($0.id, $0) })
        var risks: [HFExecutiveRiskRecord] = []

        for project in projects {
            if project.readiness.blockers >= 3 {
                risks.append(risk(project, .critical, "Blocker count elevated", "\(project.readiness.blockers) blockers are visible in local project state.", "HFLocalProjectStore", "exclamationmark.triangle.fill"))
            } else if project.readiness.blockers > 0 {
                risks.append(risk(project, .high, "Open blockers", "\(project.readiness.blockers) blockers need local review.", "HFLocalProjectStore", "exclamationmark.circle.fill"))
            }

            if project.readiness.overall < 0.70 {
                risks.append(risk(project, .medium, "Readiness below review target", "\(project.shortTitle) is \(project.readinessPercentLabel) ready.", "HFLocalProjectStore", "gauge.with.dots.needle.33percent"))
            }
        }

        risks += workflowAutomation.blockedDependencies.compactMap { dependency in
            guard let project = projectByID[dependency.projectID] else { return nil }
            return risk(project, .critical, dependency.dependencyTitle, dependency.detail, "HFWorkflowAutomationEngine", dependency.systemImage)
        }

        risks += orchestration.blockedHandoffs.compactMap { handoff in
            guard let project = projectByID[handoff.projectID] else { return nil }
            return risk(project, .critical, handoff.title, handoff.detail, "HFOrchestrationEngine", handoff.systemImage)
        }

        risks += executionTracking.taskCompletionStates
            .filter { $0.state == .blocked || $0.priority == .critical }
            .compactMap { task in
                guard let project = projectByID[task.projectID] else { return nil }
                return risk(project, task.state == .blocked ? .critical : .high, task.title, task.ownerPlaceholder, "HFExecutionTrackingEngine", task.systemImage)
            }

        risks += missionPlanner.activeMissions
            .filter { $0.priority == .medium || $0.priority == .normal }
            .prefix(3)
            .compactMap { mission in
                guard let project = projectByID[mission.projectID] else { return nil }
                return risk(project, .low, "Monitor mission", mission.objective, "HFMissionPlannerEngine", mission.systemImage)
            }

        return Array(risks.prefix(18))
    }

    private static func resourceAllocation(
        missionPlanner: HFMissionPlannerSnapshot,
        executionTracking: HFExecutionTrackingSnapshot
    ) -> [HFExecutiveResourceAllocation] {
        HFExecutiveResourceArea.allCases.map { area in
            let workspaces = workspaces(for: area)
            let taskLoad = executionTracking.taskCompletionStates.filter { workspaces.contains($0.workspace) }.count
            let missionLoad = missionPlanner.activeMissions.filter { workspaces.contains($0.targetWorkspace) }.count
            let loadScore = min(100, (taskLoad * 14) + (missionLoad * 18) + 25)

            return HFExecutiveResourceAllocation(
                id: "resource-\(area.rawValue.lowercased())",
                area: area,
                allocationLabel: allocationLabel(for: loadScore),
                detail: "\(taskLoad) tracked tasks and \(missionLoad) mission targets. Placeholder only.",
                loadScore: loadScore,
                isPlaceholder: true,
                systemImage: area.systemImage
            )
        }
    }

    private static func executiveTimeline(
        missionPlanner: HFMissionPlannerSnapshot,
        executionTracking: HFExecutionTrackingSnapshot
    ) -> [HFExecutiveTimelineItem] {
        HFExecutiveTimelineStage.allCases.map { stage in
            let workspace = stage.workspace
            let missionSteps = missionPlanner.executionPlan.filter { $0.workspace == workspace }
            let timelineItems = executionTracking.timelineProgress.filter { $0.workspace == workspace }
            let progress = timelineItems.isEmpty ? fallbackTimelineProgress(for: stage, missionPlanner: missionPlanner) : average(timelineItems.map(\.progressPercent))
            let blocked = timelineItems.reduce(0) { $0 + $1.blockedCount }
            let severity: HFStudioSignalSeverity = blocked > 0 ? .blocked : progress >= 80 ? .ready : progress >= 50 ? .attention : .watch

            return HFExecutiveTimelineItem(
                id: "executive-timeline-\(stage.rawValue.lowercased())",
                stage: stage,
                title: stage.rawValue,
                detail: "\(missionSteps.count) mission execution steps and \(timelineItems.count) tracked timeline records.",
                progressPercent: progress,
                blockedCount: blocked,
                severity: severity,
                systemImage: workspace.systemImage
            )
        }
    }

    private static func commandActions() -> [HFExecutiveCommandAction] {
        [
            HFExecutiveCommandAction(id: "open-brain", title: "Open Brain", detail: "Navigate to HigherKey Brain.", targetWorkspace: .higherKeyBrain, systemImage: "brain.head.profile"),
            HFExecutiveCommandAction(id: "open-mission-planner", title: "Open Mission Planner", detail: "Review active local mission plans.", targetWorkspace: .higherKeyBrain, systemImage: "checklist.checked"),
            HFExecutiveCommandAction(id: "open-workflow-automation", title: "Open Workflow Automation", detail: "Review local workflow rules.", targetWorkspace: .workflowAutomation, systemImage: "arrow.triangle.branch"),
            HFExecutiveCommandAction(id: "open-packaging-studio", title: "Open Packaging Studio", detail: "Navigate to packaging review.", targetWorkspace: .packagingStudio, systemImage: "shippingbox.fill"),
            HFExecutiveCommandAction(id: "open-creator-os", title: "Open Creator OS", detail: "Navigate to creator operations.", targetWorkspace: .creatorOS, systemImage: "command"),
            HFExecutiveCommandAction(id: "open-studio-intelligence", title: "Open Studio Intelligence", detail: "Review derived studio intelligence.", targetWorkspace: .studioIntelligence, systemImage: "lightbulb.max.fill"),
            HFExecutiveCommandAction(id: "open-execution-tracking", title: "Open Execution Tracking", detail: "Review execution tracking status.", targetWorkspace: .higherKeyBrain, systemImage: "chart.line.uptrend.xyaxis")
        ]
    }

    private static func healthMetric(_ id: String, _ title: String, _ score: Int, _ detail: String, _ systemImage: String) -> HFExecutiveHealthMetric {
        HFExecutiveHealthMetric(
            id: id,
            title: title,
            score: min(100, max(0, score)),
            detail: detail,
            severity: severity(forScore: score),
            systemImage: systemImage
        )
    }

    private static func risk(_ project: HFProject, _ level: HFExecutiveRiskLevel, _ title: String, _ detail: String, _ source: String, _ systemImage: String) -> HFExecutiveRiskRecord {
        HFExecutiveRiskRecord(
            id: "\(project.id.rawValue)-\(source)-\(title)".slugID,
            projectID: project.id,
            projectTitle: project.shortTitle,
            level: level,
            title: title,
            detail: detail,
            source: source,
            systemImage: systemImage
        )
    }

    private static func releaseHealthScore(projects: [HFProject], executionTracking: HFExecutionTrackingSnapshot) -> Int {
        let releaseReady = projects.filter { $0.readiness.overall >= 0.80 && $0.readiness.blockers == 0 }.count
        let blockedPenalty = executionTracking.blockedTaskCount * 8
        return min(100, max(0, 55 + (releaseReady * 15) - blockedPenalty))
    }

    private static func timelineScore(for workspace: HFOrchestrationWorkspace, executionTracking: HFExecutionTrackingSnapshot) -> Int {
        let items = executionTracking.timelineProgress.filter { $0.workspace == workspace }
        return items.isEmpty ? 45 : average(items.map(\.progressPercent))
    }

    private static func fallbackTimelineProgress(for stage: HFExecutiveTimelineStage, missionPlanner: HFMissionPlannerSnapshot) -> Int {
        let missionCount = missionPlanner.activeMissions.count
        switch stage {
        case .development:
            return missionCount > 0 ? 58 : 0
        case .packaging:
            return missionPlanner.milestones.contains { $0.workspace == .packagingStudio } ? 52 : 30
        case .qa:
            return missionPlanner.milestones.contains { $0.workspace == .qa } ? 45 : 25
        case .release:
            return missionPlanner.milestones.contains { $0.workspace == .release } ? 42 : 20
        case .marketing:
            return missionPlanner.milestones.contains { $0.workspace == .marketing } ? 36 : 18
        }
    }

    private static func workspaces(for area: HFExecutiveResourceArea) -> Set<HFOrchestrationWorkspace> {
        switch area {
        case .creative:
            return [.creatorOS, .studioIntelligence]
        case .packaging:
            return [.packagingStudio]
        case .qa:
            return [.qa]
        case .marketing:
            return [.marketing]
        case .engineering:
            return [.workflowAutomation, .higherKeyBrain, .unifiedProjectState]
        }
    }

    private static func allocationLabel(for loadScore: Int) -> String {
        if loadScore >= 75 { return "Heavy" }
        if loadScore >= 50 { return "Moderate" }
        return "Light"
    }

    private static func severity(forScore score: Int) -> HFStudioSignalSeverity {
        if score >= 80 { return .ready }
        if score >= 60 { return .attention }
        if score >= 40 { return .watch }
        return .blocked
    }

    private static func riskRank(_ level: HFExecutiveRiskLevel) -> Int {
        switch level {
        case .critical:
            return 4
        case .high:
            return 3
        case .medium:
            return 2
        case .low:
            return 1
        }
    }

    private static func average(_ values: [Int]) -> Int {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / values.count
    }
}

private extension String {
    var slugID: String {
        lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
    }
}
