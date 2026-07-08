import Foundation

enum HFExecutionTrackingEngine {
    static func snapshot(
        projects: [HFProject],
        missionPlanner: HFMissionPlannerSnapshot,
        orchestration: HFOrchestrationSnapshot,
        workflowAutomation: HFWorkflowAutomationSnapshot,
        sourceLabel: String = "HFLocalProjectStore + HFMissionPlannerEngine + HFOrchestrationEngine + HFWorkflowAutomationEngine"
    ) -> HFExecutionTrackingSnapshot {
        let taskCompletionStates = missionPlanner.taskGroups.flatMap { group in
            buildTaskCompletionStates(for: group)
        }
        let activeStatuses = missionPlanner.activeMissions.map { mission in
            activeExecutionStatus(
                for: mission,
                tasks: taskCompletionStates.filter { $0.missionID == mission.id },
                projects: projects
            )
        }
        let progressHistory = missionPlanner.activeMissions.flatMap { mission in
            progressHistoryEvents(
                for: mission,
                missionPlanner: missionPlanner,
                workflowAutomation: workflowAutomation
            )
        }
        let ownerPlaceholders = missionPlanner.activeMissions.flatMap { mission in
            ownershipPlaceholders(
                for: mission,
                tasks: taskCompletionStates.filter { $0.missionID == mission.id }
            )
        }
        let timelineProgress = missionPlanner.activeMissions.flatMap { mission in
            buildTimelineProgress(
                for: mission,
                missionPlanner: missionPlanner,
                orchestration: orchestration
            )
        }
        let completionForecasts = missionPlanner.activeMissions.map { mission in
            completionForecast(
                for: mission,
                status: activeStatuses.first { $0.missionID == mission.id },
                tasks: taskCompletionStates.filter { $0.missionID == mission.id },
                timeline: timelineProgress.filter { $0.missionID == mission.id }
            )
        }

        return HFExecutionTrackingSnapshot(
            sourceLabel: sourceLabel,
            summary: "\(activeStatuses.count) active execution statuses, \(taskCompletionStates.count) task states, \(ownerPlaceholders.count) owner placeholders, and \(completionForecasts.count) completion forecasts derived locally.",
            activeExecutionStatuses: activeStatuses,
            taskCompletionStates: taskCompletionStates,
            progressHistory: progressHistory,
            ownerPlaceholders: ownerPlaceholders,
            timelineProgress: timelineProgress,
            completionForecasts: completionForecasts
        )
    }

    private static func buildTaskCompletionStates(for group: HFMissionTaskGroup) -> [HFTaskCompletionState] {
        group.tasks.enumerated().map { index, task in
            let state = executionState(from: task.status)
            let completionPercent = taskCompletionPercent(for: task, index: index)
            let owner = ownerPlaceholder(for: task.workspace, projectTitle: task.projectTitle)

            return HFTaskCompletionState(
                id: "\(task.id)-completion",
                missionID: task.missionID,
                taskID: task.id,
                projectID: task.projectID,
                projectTitle: task.projectTitle,
                title: task.title,
                workspace: task.workspace,
                state: state,
                completionPercent: completionPercent,
                ownerPlaceholder: owner,
                priority: task.priority,
                systemImage: task.systemImage
            )
        }
    }

    private static func activeExecutionStatus(
        for mission: HFMissionPlan,
        tasks: [HFTaskCompletionState],
        projects: [HFProject]
    ) -> HFMissionExecutionStatus {
        let project = projects.first { $0.id == mission.projectID }
        let blockedCount = tasks.filter { $0.state == .blocked }.count
        let activeTaskCount = tasks.filter { $0.state != .complete }.count
        let averageTaskProgress = averageProgress(tasks)
        let readinessPercent = project.map { Int($0.readiness.overall * 100) } ?? mission.readinessLabel.asPercent
        let completionPercent = min(96, max(0, (averageTaskProgress + readinessPercent) / 2))
        let state: HFExecutionTaskState

        if blockedCount > 0 {
            state = .blocked
        } else if activeTaskCount == 0 {
            state = .complete
        } else if completionPercent >= 80 {
            state = .reviewNeeded
        } else {
            state = .inProgress
        }

        return HFMissionExecutionStatus(
            id: "\(mission.id)-execution-status",
            missionID: mission.id,
            projectID: mission.projectID,
            projectTitle: mission.projectTitle,
            title: "\(mission.projectTitle) Execution",
            status: state,
            completionPercent: completionPercent,
            activeTaskCount: activeTaskCount,
            blockedTaskCount: blockedCount,
            ownerPlaceholder: ownerPlaceholder(for: mission.targetWorkspace, projectTitle: mission.projectTitle),
            systemImage: mission.systemImage
        )
    }

    private static func progressHistoryEvents(
        for mission: HFMissionPlan,
        missionPlanner: HFMissionPlannerSnapshot,
        workflowAutomation: HFWorkflowAutomationSnapshot
    ) -> [HFProgressHistoryEvent] {
        let milestones = missionPlanner.milestones
            .filter { $0.missionID == mission.id }
            .prefix(3)
            .map { milestone in
                HFProgressHistoryEvent(
                    id: "\(milestone.id)-history",
                    missionID: mission.id,
                    projectID: mission.projectID,
                    projectTitle: mission.projectTitle,
                    sequenceIndex: milestone.sequenceIndex,
                    title: milestone.title,
                    detail: milestone.detail,
                    progressLabel: milestone.status.rawValue,
                    state: executionState(from: milestone.status),
                    systemImage: milestone.systemImage
                )
            }

        let movement = workflowAutomation.readinessMovementRecommendations
            .first { $0.projectID == mission.projectID }

        let movementEvent = movement.map { suggestion in
            HFProgressHistoryEvent(
                id: "\(mission.id)-history-readiness",
                missionID: mission.id,
                projectID: mission.projectID,
                projectTitle: mission.projectTitle,
                sequenceIndex: milestones.count + 1,
                title: suggestion.recommendedState,
                detail: suggestion.detail,
                progressLabel: suggestion.readinessLabel,
                state: suggestion.isMovementAllowed ? .reviewNeeded : executionState(from: suggestion.severity),
                systemImage: suggestion.systemImage
            )
        }

        return milestones + Array([movementEvent].compactMap { $0 }.prefix(1))
    }

    private static func ownershipPlaceholders(
        for mission: HFMissionPlan,
        tasks: [HFTaskCompletionState]
    ) -> [HFTeamOwnershipPlaceholder] {
        let workspaces = Array(Set(tasks.map(\.workspace) + [mission.currentWorkspace, mission.targetWorkspace]))

        return workspaces.sorted { $0.rawValue < $1.rawValue }.map { workspace in
            let task = tasks.first { $0.workspace == workspace }
            let state = task?.state ?? executionState(from: mission.status)

            return HFTeamOwnershipPlaceholder(
                id: "\(mission.id)-owner-\(workspace.rawValue.slugID)",
                missionID: mission.id,
                projectID: mission.projectID,
                projectTitle: mission.projectTitle,
                ownerName: ownerPlaceholder(for: workspace, projectTitle: mission.projectTitle),
                role: ownerRole(for: workspace),
                workspace: workspace,
                responsibility: task?.title ?? "Track \(workspace.rawValue) handoff readiness.",
                state: state,
                systemImage: workspace.systemImage
            )
        }
    }

    private static func buildTimelineProgress(
        for mission: HFMissionPlan,
        missionPlanner: HFMissionPlannerSnapshot,
        orchestration: HFOrchestrationSnapshot
    ) -> [HFTimelineProgress] {
        let executionSteps = missionPlanner.executionPlan
            .filter { $0.missionID == mission.id }
            .prefix(6)
        let blockedHandoffs = orchestration.blockedHandoffs.filter { $0.projectID == mission.projectID }

        return executionSteps.enumerated().map { index, step in
            let blockedCount = blockedHandoffs.filter { $0.targetWorkspace == step.workspace }.count
            let state = blockedCount > 0 ? HFExecutionTaskState.blocked : executionState(from: step.status)
            let progressPercent = timelinePercent(for: step, index: index, blockedCount: blockedCount)

            return HFTimelineProgress(
                id: "\(step.id)-timeline-progress",
                missionID: mission.id,
                projectID: mission.projectID,
                projectTitle: mission.projectTitle,
                sequenceIndex: step.sequenceIndex,
                title: step.title,
                workspace: step.workspace,
                progressPercent: progressPercent,
                blockedCount: blockedCount,
                state: state,
                systemImage: step.systemImage
            )
        }
    }

    private static func completionForecast(
        for mission: HFMissionPlan,
        status: HFMissionExecutionStatus?,
        tasks: [HFTaskCompletionState],
        timeline: [HFTimelineProgress]
    ) -> HFCompletionForecast {
        let blockedCount = tasks.filter { $0.state == .blocked }.count + timeline.reduce(0) { $0 + $1.blockedCount }
        let completionPercent = status?.completionPercent ?? averageProgress(tasks)
        let forecastLabel: String
        let confidence: HFExecutionForecastConfidence
        let blockerRisk: String
        let nextBestAction: String

        if blockedCount > 0 {
            forecastLabel = "Blocked before completion"
            confidence = .low
            blockerRisk = "\(blockedCount) blocker signals remain open"
            nextBestAction = "Inspect Blocker"
        } else if completionPercent >= 80 {
            forecastLabel = "Ready for final review"
            confidence = .high
            blockerRisk = "Low blocker risk"
            nextBestAction = "Review Handoff"
        } else if tasks.contains(where: { $0.state == .reviewNeeded }) {
            forecastLabel = "Review needed before completion"
            confidence = .medium
            blockerRisk = "Review notes may slow execution"
            nextBestAction = "Mark as Review Needed"
        } else {
            forecastLabel = "On track locally"
            confidence = .medium
            blockerRisk = "No blocked execution tasks"
            nextBestAction = "Open Target Workspace"
        }

        return HFCompletionForecast(
            id: "\(mission.id)-completion-forecast",
            missionID: mission.id,
            projectID: mission.projectID,
            projectTitle: mission.projectTitle,
            forecastLabel: forecastLabel,
            confidence: confidence,
            blockerRisk: blockerRisk,
            nextBestAction: nextBestAction,
            projectedCompletionPercent: min(100, max(0, completionPercent)),
            systemImage: blockedCount > 0 ? "exclamationmark.triangle.fill" : "chart.line.uptrend.xyaxis"
        )
    }

    private static func executionState(from status: HFMissionStatus) -> HFExecutionTaskState {
        switch status {
        case .active:
            return .inProgress
        case .blocked:
            return .blocked
        case .reviewNeeded:
            return .reviewNeeded
        case .ready:
            return .complete
        case .planned:
            return .notStarted
        }
    }

    private static func executionState(from severity: HFStudioSignalSeverity) -> HFExecutionTaskState {
        switch severity {
        case .blocked:
            return .blocked
        case .attention:
            return .reviewNeeded
        case .watch:
            return .inProgress
        case .info:
            return .notStarted
        case .ready:
            return .complete
        }
    }

    private static func taskCompletionPercent(for task: HFMissionTask, index: Int) -> Int {
        switch task.status {
        case .blocked:
            return 15
        case .reviewNeeded:
            return 65
        case .ready:
            return 100
        case .active:
            return 55
        case .planned:
            return max(10, 35 - (index * 5))
        }
    }

    private static func timelinePercent(for step: HFMissionExecutionStep, index: Int, blockedCount: Int) -> Int {
        if blockedCount > 0 { return max(10, 25 - (index * 3)) }

        switch step.status {
        case .blocked:
            return 20
        case .reviewNeeded:
            return 70
        case .ready:
            return 100
        case .active:
            return 55
        case .planned:
            return max(15, 40 - (index * 4))
        }
    }

    private static func averageProgress(_ tasks: [HFTaskCompletionState]) -> Int {
        guard !tasks.isEmpty else { return 0 }
        return tasks.reduce(0) { $0 + $1.completionPercent } / tasks.count
    }

    private static func ownerPlaceholder(for workspace: HFOrchestrationWorkspace, projectTitle: String) -> String {
        switch workspace {
        case .unifiedProjectState:
            return "\(projectTitle) State Owner"
        case .studioIntelligence:
            return "\(projectTitle) Intelligence Owner"
        case .workflowAutomation:
            return "\(projectTitle) Workflow Owner"
        case .higherKeyBrain:
            return "\(projectTitle) Brain Lead"
        case .packagingStudio:
            return "\(projectTitle) Packaging Owner"
        case .creatorOS:
            return "\(projectTitle) Creator Owner"
        case .qa:
            return "\(projectTitle) QA Owner"
        case .release:
            return "\(projectTitle) Release Owner"
        case .marketing:
            return "\(projectTitle) Marketing Owner"
        }
    }

    private static func ownerRole(for workspace: HFOrchestrationWorkspace) -> String {
        switch workspace {
        case .unifiedProjectState:
            return "Project State"
        case .studioIntelligence:
            return "Studio Intelligence"
        case .workflowAutomation:
            return "Workflow Automation"
        case .higherKeyBrain:
            return "Brain Review"
        case .packagingStudio:
            return "Packaging"
        case .creatorOS:
            return "Creator OS"
        case .qa:
            return "QA"
        case .release:
            return "Release"
        case .marketing:
            return "Marketing"
        }
    }
}

private extension String {
    var asPercent: Int {
        Int(replacingOccurrences(of: "%", with: "")) ?? 0
    }

    var slugID: String {
        lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "/", with: "-")
    }
}
