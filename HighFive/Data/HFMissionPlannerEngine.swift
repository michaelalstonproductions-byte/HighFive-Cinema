import Foundation

enum HFMissionPlannerEngine {
    static func snapshot(
        projects: [HFProject],
        intelligence: HFStudioIntelligenceSnapshot,
        workflowAutomation: HFWorkflowAutomationSnapshot,
        orchestration: HFOrchestrationSnapshot,
        sourceLabel: String = "HFLocalProjectStore + HFStudioIntelligenceEngine + HFWorkflowAutomationEngine + HFOrchestrationEngine"
    ) -> HFMissionPlannerSnapshot {
        let missions = activeMissions(from: projects, orchestration: orchestration)
        let milestones = missions.flatMap { mission in
            missionMilestones(for: mission, orchestration: orchestration)
        }
        let taskGroups = missions.map { mission in
            missionTaskGroup(
                for: mission,
                intelligence: intelligence,
                workflowAutomation: workflowAutomation,
                orchestration: orchestration
            )
        }
        let blockerTimeline = missions.flatMap { mission in
            blockerTimelineEvents(for: mission, intelligence: intelligence, orchestration: orchestration)
        }
        let executionPlan = missions.flatMap { mission in
            executionSteps(for: mission, orchestration: orchestration)
        }

        return HFMissionPlannerSnapshot(
            sourceLabel: sourceLabel,
            summary: "\(missions.count) active missions, \(milestones.count) milestones, \(taskGroups.flatMap(\.tasks).count) mission tasks, and \(blockerTimeline.count) blocker timeline events derived locally.",
            activeMissions: missions,
            milestones: milestones,
            taskGroups: taskGroups,
            blockerTimeline: blockerTimeline,
            executionPlan: executionPlan
        )
    }

    private static func activeMissions(
        from projects: [HFProject],
        orchestration: HFOrchestrationSnapshot
    ) -> [HFMissionPlan] {
        projects.map { project in
            let sequenceState = orchestration.projectStates.first { $0.projectID == project.id }
            let status = missionStatus(from: sequenceState?.status)
            let priority = missionPriority(for: project, blockedHandoffCount: sequenceState?.blockedHandoffCount ?? 0)
            let targetWorkspace = sequenceState?.nextWorkspace ?? workspace(for: project)

            return HFMissionPlan(
                id: "\(project.id.rawValue)-mission-plan",
                projectID: project.id,
                projectTitle: project.shortTitle,
                title: "\(project.shortTitle) Mission",
                objective: missionObjective(for: project, targetWorkspace: targetWorkspace),
                currentWorkspace: sequenceState?.currentWorkspace ?? workspace(for: project),
                targetWorkspace: targetWorkspace,
                priority: priority,
                status: status,
                readinessLabel: project.readinessPercentLabel,
                blockerCount: project.readiness.blockers,
                systemImage: targetWorkspace.systemImage
            )
        }
        .sorted { lhs, rhs in
            if lhs.priority.sortRank != rhs.priority.sortRank {
                return lhs.priority.sortRank > rhs.priority.sortRank
            }
            return lhs.projectTitle < rhs.projectTitle
        }
    }

    private static func missionMilestones(
        for mission: HFMissionPlan,
        orchestration: HFOrchestrationSnapshot
    ) -> [HFMissionMilestone] {
        let projectSteps = orchestration.steps
            .filter { $0.projectID == mission.projectID }
            .filter { step in
                step.workspace == .higherKeyBrain ||
                    step.workspace == mission.targetWorkspace ||
                    step.workspace == .qa ||
                    step.workspace == .release ||
                    step.workspace == .marketing
            }
            .prefix(5)

        return projectSteps.enumerated().map { index, step in
            HFMissionMilestone(
                id: "\(mission.id)-milestone-\(index + 1)",
                missionID: mission.id,
                projectID: mission.projectID,
                projectTitle: mission.projectTitle,
                sequenceIndex: index + 1,
                title: step.title,
                detail: step.detail,
                workspace: step.workspace,
                status: missionStatus(from: step.status),
                severity: step.severity,
                systemImage: step.systemImage
            )
        }
    }

    private static func missionTaskGroup(
        for mission: HFMissionPlan,
        intelligence: HFStudioIntelligenceSnapshot,
        workflowAutomation: HFWorkflowAutomationSnapshot,
        orchestration: HFOrchestrationSnapshot
    ) -> HFMissionTaskGroup {
        let queueTasks = orchestration.queue
            .filter { $0.projectID == mission.projectID }
            .map { item in
                HFMissionTask(
                    id: "\(mission.id)-task-queue-\(item.id)",
                    missionID: mission.id,
                    projectID: mission.projectID,
                    projectTitle: mission.projectTitle,
                    title: item.suggestedAction,
                    detail: "\(item.title) for \(item.targetWorkspace.rawValue).",
                    workspace: item.targetWorkspace,
                    priority: missionPriority(from: item.severity),
                    status: missionStatus(from: item.status),
                    sourceSignalID: item.handoffID,
                    systemImage: item.systemImage
                )
            }

        let workflowTasks = workflowAutomation.triggeredSuggestions
            .filter { $0.projectID == mission.projectID }
            .prefix(2)
            .map { suggestion in
                HFMissionTask(
                    id: "\(mission.id)-task-workflow-\(suggestion.id)",
                    missionID: mission.id,
                    projectID: mission.projectID,
                    projectTitle: mission.projectTitle,
                    title: suggestion.actionLabel,
                    detail: suggestion.detail,
                    workspace: mission.targetWorkspace,
                    priority: missionPriority(from: suggestion.severity),
                    status: .reviewNeeded,
                    sourceSignalID: suggestion.id,
                    systemImage: suggestion.systemImage
                )
            }

        let dependencyTasks = intelligence.dependencySignals
            .filter { $0.projectID == mission.projectID }
            .prefix(2)
            .map { dependency in
                HFMissionTask(
                    id: "\(mission.id)-task-dependency-\(dependency.id)",
                    missionID: mission.id,
                    projectID: mission.projectID,
                    projectTitle: mission.projectTitle,
                    title: dependency.status == "Blocking" ? "Inspect Blocker" : "Review Dependency",
                    detail: "\(dependency.dependencyTitle): \(dependency.detail)",
                    workspace: mission.targetWorkspace,
                    priority: missionPriority(from: dependency.severity),
                    status: dependency.severity == .blocked ? .blocked : .reviewNeeded,
                    sourceSignalID: dependency.id,
                    systemImage: dependency.systemImage
                )
            }

        let tasks = Array((queueTasks + workflowTasks + dependencyTasks)
            .sorted { lhs, rhs in
                if lhs.priority.sortRank != rhs.priority.sortRank {
                    return lhs.priority.sortRank > rhs.priority.sortRank
                }
                return lhs.title < rhs.title
            }
            .prefix(5))

        return HFMissionTaskGroup(
            id: "\(mission.id)-task-group",
            missionID: mission.id,
            projectID: mission.projectID,
            projectTitle: mission.projectTitle,
            title: "\(mission.projectTitle) Priority Tasks",
            workspace: mission.targetWorkspace,
            tasks: tasks,
            status: tasks.contains(where: { $0.status == .blocked }) ? .blocked : mission.status,
            priority: tasks.first?.priority ?? mission.priority,
            systemImage: mission.targetWorkspace.systemImage
        )
    }

    private static func blockerTimelineEvents(
        for mission: HFMissionPlan,
        intelligence: HFStudioIntelligenceSnapshot,
        orchestration: HFOrchestrationSnapshot
    ) -> [HFBlockerTimelineEvent] {
        let blockedHandoffs = orchestration.blockedHandoffs
            .filter { $0.projectID == mission.projectID }
            .map { handoff in
                HFBlockerTimelineEvent(
                    id: "\(mission.id)-timeline-handoff-\(handoff.id)",
                    missionID: mission.id,
                    projectID: mission.projectID,
                    projectTitle: mission.projectTitle,
                    sequenceIndex: 0,
                    title: handoff.title,
                    detail: "\(handoff.blockerSummary). \(handoff.detail)",
                    sourceWorkspace: handoff.sourceWorkspace,
                    targetWorkspace: handoff.targetWorkspace,
                    status: missionStatus(from: handoff.status),
                    severity: handoff.severity,
                    systemImage: handoff.systemImage
                )
            }

        let dependencyEvents = intelligence.dependencySignals
            .filter { $0.projectID == mission.projectID && ($0.severity == .blocked || $0.severity == .attention) }
            .prefix(3)
            .map { dependency in
                HFBlockerTimelineEvent(
                    id: "\(mission.id)-timeline-dependency-\(dependency.id)",
                    missionID: mission.id,
                    projectID: mission.projectID,
                    projectTitle: mission.projectTitle,
                    sequenceIndex: 0,
                    title: dependency.dependencyTitle,
                    detail: dependency.detail,
                    sourceWorkspace: workspace(named: dependency.upstreamWorkspace),
                    targetWorkspace: workspace(named: dependency.downstreamWorkspace),
                    status: dependency.severity == .blocked ? .blocked : .reviewNeeded,
                    severity: dependency.severity,
                    systemImage: dependency.systemImage
                )
            }

        return (blockedHandoffs + dependencyEvents).enumerated().map { index, event in
            HFBlockerTimelineEvent(
                id: event.id,
                missionID: event.missionID,
                projectID: event.projectID,
                projectTitle: event.projectTitle,
                sequenceIndex: index + 1,
                title: event.title,
                detail: event.detail,
                sourceWorkspace: event.sourceWorkspace,
                targetWorkspace: event.targetWorkspace,
                status: event.status,
                severity: event.severity,
                systemImage: event.systemImage
            )
        }
    }

    private static func executionSteps(
        for mission: HFMissionPlan,
        orchestration: HFOrchestrationSnapshot
    ) -> [HFMissionExecutionStep] {
        let handoffs = orchestration.handoffs
            .filter { $0.projectID == mission.projectID }
            .prefix(5)

        return handoffs.enumerated().map { index, handoff in
            HFMissionExecutionStep(
                id: "\(mission.id)-execution-\(index + 1)",
                missionID: mission.id,
                projectID: mission.projectID,
                projectTitle: mission.projectTitle,
                sequenceIndex: index + 1,
                title: "\(handoff.sourceWorkspace.rawValue) -> \(handoff.targetWorkspace.rawValue)",
                detail: handoff.detail,
                workspace: handoff.targetWorkspace,
                status: missionStatus(from: handoff.status),
                severity: handoff.severity,
                systemImage: handoff.systemImage
            )
        }
    }

    private static func missionObjective(
        for project: HFProject,
        targetWorkspace: HFOrchestrationWorkspace
    ) -> String {
        "Move \(project.shortTitle) from \(project.workflowStage) into \(targetWorkspace.rawValue) review with blockers visible and no state mutation."
    }

    private static func missionPriority(
        for project: HFProject,
        blockedHandoffCount: Int
    ) -> HFMissionPriority {
        if blockedHandoffCount > 0 || project.readiness.blockers >= 3 { return .critical }
        if project.readiness.blockers > 0 || project.reviewNotes >= 4 { return .high }
        if project.readiness.overall < 0.75 { return .medium }
        return .normal
    }

    private static func missionPriority(from severity: HFStudioSignalSeverity) -> HFMissionPriority {
        switch severity {
        case .blocked:
            return .critical
        case .attention:
            return .high
        case .watch:
            return .medium
        case .info, .ready:
            return .normal
        }
    }

    private static func missionStatus(from status: HFOrchestrationStatus?) -> HFMissionStatus {
        switch status {
        case .blocked:
            return .blocked
        case .reviewNeeded:
            return .reviewNeeded
        case .ready:
            return .ready
        case .queued:
            return .planned
        case .localOnly:
            return .active
        case nil:
            return .planned
        }
    }

    private static func workspace(for project: HFProject) -> HFOrchestrationWorkspace {
        switch project.lifecycleState {
        case .packaging:
            return .packagingStudio
        case .creatorReview:
            return .creatorOS
        case .streaming:
            return .release
        case .intelligence:
            return .higherKeyBrain
        }
    }

    private static func workspace(named name: String) -> HFOrchestrationWorkspace {
        let lowercased = name.lowercased()

        if lowercased.contains("packaging") { return .packagingStudio }
        if lowercased.contains("creator") || lowercased.contains("team") { return .creatorOS }
        if lowercased.contains("qa") || lowercased.contains("asset") || lowercased.contains("metadata") { return .qa }
        if lowercased.contains("release") || lowercased.contains("streaming") { return .release }
        if lowercased.contains("marketing") { return .marketing }
        if lowercased.contains("automation") { return .workflowAutomation }
        if lowercased.contains("intelligence") { return .studioIntelligence }
        return .higherKeyBrain
    }
}
