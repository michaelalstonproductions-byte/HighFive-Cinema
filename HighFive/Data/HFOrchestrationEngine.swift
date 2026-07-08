import Foundation

enum HFOrchestrationEngine {
    static func snapshot(
        projects: [HFProject],
        intelligence: HFStudioIntelligenceSnapshot,
        workflowAutomation: HFWorkflowAutomationSnapshot,
        sourceLabel: String = "HFLocalProjectStore + HFStudioIntelligenceEngine + HFWorkflowAutomationEngine"
    ) -> HFOrchestrationSnapshot {
        let steps = projects.flatMap { project in
            orchestrationSteps(for: project, intelligence: intelligence)
        }
        let handoffs = projects.flatMap { project in
            crossWorkspaceHandoffs(for: project, intelligence: intelligence, workflowAutomation: workflowAutomation)
        }
        let queue = orchestrationQueue(from: steps, handoffs: handoffs, workflowAutomation: workflowAutomation)
        let projectStates = projects.map { project in
            projectSequenceState(for: project, handoffs: handoffs, intelligence: intelligence)
        }

        return HFOrchestrationSnapshot(
            sourceLabel: sourceLabel,
            summary: "\(queue.count) queued orchestration items, \(handoffs.filter { $0.status == .blocked }.count) blocked handoffs, and \(projectStates.count) project pipeline states derived locally.",
            steps: steps,
            handoffs: handoffs,
            queue: queue,
            projectStates: projectStates,
            localActions: localActions()
        )
    }

    private static func orchestrationSteps(
        for project: HFProject,
        intelligence: HFStudioIntelligenceSnapshot
    ) -> [HFOrchestrationStep] {
        let blockedCount = blockedDependencyCount(for: project, intelligence: intelligence)
        let attentionCount = attentionDependencyCount(for: project, intelligence: intelligence)
        let projectWorkspace = owningWorkspace(for: project)
        let readinessGateStatus = readinessGateStatus(for: project, blockedCount: blockedCount, attentionCount: attentionCount)
        let releaseStatus = releaseGateStatus(for: project, blockedCount: blockedCount, attentionCount: attentionCount)

        let workspacePlan: [(HFOrchestrationWorkspace, String, String, String, String, HFOrchestrationStatus, HFStudioSignalSeverity)] = [
            (
                .unifiedProjectState,
                "Read shared project state",
                "\(project.shortTitle) starts from HFLocalProjectStore without mutation.",
                "HFLocalProjectStore",
                "Studio Intelligence",
                .localOnly,
                .info
            ),
            (
                .studioIntelligence,
                "Derive studio signals",
                "Events, readiness, dependencies, and suggestions are derived from local project data.",
                "Unified Project State",
                "Workflow Automation",
                .ready,
                attentionCount > 0 ? .attention : .info
            ),
            (
                .workflowAutomation,
                "Evaluate workflow rules",
                "Automation rules create local recommendations only; they do not change project state.",
                "Studio Intelligence",
                "HigherKey Brain",
                blockedCount > 0 ? .blocked : .ready,
                blockedCount > 0 ? .blocked : .watch
            ),
            (
                .higherKeyBrain,
                "Coordinate next handoff",
                "Brain sequences the next local workspace handoff and blocker review.",
                "Workflow Automation",
                projectWorkspace.rawValue,
                readinessGateStatus,
                severity(for: readinessGateStatus)
            ),
            (
                projectWorkspace,
                "Prepare workspace handoff",
                "Owning workspace reviews notes, assets, and package readiness before QA.",
                "HigherKey Brain",
                "QA",
                readinessGateStatus,
                severity(for: readinessGateStatus)
            ),
            (
                .qa,
                "Check local QA gate",
                "QA receives a review-only package; no media rendering, upload, or publishing path is enabled.",
                projectWorkspace.rawValue,
                "Release",
                releaseStatus,
                severity(for: releaseStatus)
            ),
            (
                .release,
                "Stage release review",
                "Release remains a local review stage with blocked items held before movement.",
                "QA",
                "Marketing",
                releaseStatus,
                severity(for: releaseStatus)
            ),
            (
                .marketing,
                "Prepare marketing notes",
                "Marketing receives only local sequence guidance and package notes.",
                "Release",
                "Local Review",
                releaseStatus == .ready ? .reviewNeeded : releaseStatus,
                releaseStatus == .ready ? .attention : severity(for: releaseStatus)
            )
        ]

        return workspacePlan.enumerated().map { index, item in
            HFOrchestrationStep(
                id: "\(project.id.rawValue)-orchestration-step-\(index + 1)",
                projectID: project.id,
                projectTitle: project.shortTitle,
                sequenceIndex: index + 1,
                workspace: item.0,
                title: item.1,
                detail: item.2,
                inputSource: item.3,
                outputTarget: item.4,
                status: item.5,
                severity: item.6,
                systemImage: item.0.systemImage
            )
        }
    }

    private static func crossWorkspaceHandoffs(
        for project: HFProject,
        intelligence: HFStudioIntelligenceSnapshot,
        workflowAutomation: HFWorkflowAutomationSnapshot
    ) -> [HFCrossWorkspaceHandoff] {
        let blockedCount = blockedDependencyCount(for: project, intelligence: intelligence)
        let attentionCount = attentionDependencyCount(for: project, intelligence: intelligence)
        let projectWorkspace = owningWorkspace(for: project)
        let movement = workflowAutomation.readinessMovementRecommendations.first { $0.projectID == project.id }
        let blockerSummary = "\(blockedCount) blocked, \(attentionCount) attention"
        let workspaceGate = readinessGateStatus(for: project, blockedCount: blockedCount, attentionCount: attentionCount)
        let releaseGate = releaseGateStatus(for: project, blockedCount: blockedCount, attentionCount: attentionCount)

        let handoffPlan: [(HFOrchestrationWorkspace, HFOrchestrationWorkspace, String, String, HFOrchestrationStatus)] = [
            (
                .unifiedProjectState,
                .studioIntelligence,
                "State to intelligence",
                "Project data becomes event, readiness, dependency, and suggestion signals.",
                .ready
            ),
            (
                .studioIntelligence,
                .workflowAutomation,
                "Signals to workflow rules",
                "Studio signals feed local automation rules and dependency thresholds.",
                attentionCount > 0 ? .reviewNeeded : .ready
            ),
            (
                .workflowAutomation,
                .higherKeyBrain,
                "Automation to Brain queue",
                movement?.detail ?? "Brain receives local readiness and dependency recommendations.",
                blockedCount > 0 ? .blocked : .ready
            ),
            (
                .higherKeyBrain,
                projectWorkspace,
                "Brain to target workspace",
                "Next handoff routes review context to \(projectWorkspace.rawValue).",
                workspaceGate
            ),
            (
                projectWorkspace,
                .qa,
                "Workspace to QA",
                "QA receives review notes, blockers, and readiness context only.",
                workspaceGate
            ),
            (
                .qa,
                .release,
                "QA to release review",
                "Release review waits for local QA and blocker inspection.",
                releaseGate
            ),
            (
                .release,
                .marketing,
                "Release to marketing",
                "Marketing notes remain local until release review is clear.",
                releaseGate == .ready ? .reviewNeeded : releaseGate
            )
        ]

        return handoffPlan.enumerated().map { index, item in
            let status = item.4
            return HFCrossWorkspaceHandoff(
                id: "\(project.id.rawValue)-handoff-\(index + 1)",
                projectID: project.id,
                projectTitle: project.shortTitle,
                sourceWorkspace: item.0,
                targetWorkspace: item.1,
                title: item.2,
                detail: item.3,
                blockerSummary: blockerSummary,
                status: status,
                severity: severity(for: status),
                systemImage: item.1.systemImage
            )
        }
    }

    private static func orchestrationQueue(
        from steps: [HFOrchestrationStep],
        handoffs: [HFCrossWorkspaceHandoff],
        workflowAutomation: HFWorkflowAutomationSnapshot
    ) -> [HFOrchestrationQueueItem] {
        let workflowByProject = Dictionary(grouping: workflowAutomation.triggeredSuggestions, by: \.projectID)

        let queued = handoffs.compactMap { handoff -> HFOrchestrationQueueItem? in
            guard handoff.status == .blocked || handoff.status == .reviewNeeded else { return nil }
            let step = steps.first { $0.projectID == handoff.projectID && $0.workspace == handoff.targetWorkspace }
            let workflowSuggestion = workflowByProject[handoff.projectID]?.first
            let action = actionLabel(for: handoff.status, targetWorkspace: handoff.targetWorkspace, fallback: workflowSuggestion?.actionLabel)

            return HFOrchestrationQueueItem(
                id: "\(handoff.id)-queue",
                projectID: handoff.projectID,
                projectTitle: handoff.projectTitle,
                position: 0,
                stepID: step?.id ?? "\(handoff.projectID.rawValue)-orchestration-step-unmatched",
                handoffID: handoff.id,
                title: handoff.title,
                targetWorkspace: handoff.targetWorkspace,
                suggestedAction: action,
                status: handoff.status,
                severity: handoff.severity,
                systemImage: handoff.systemImage
            )
        }

        return queued
            .sorted { lhs, rhs in
                if severityRank(lhs.severity) != severityRank(rhs.severity) {
                    return severityRank(lhs.severity) > severityRank(rhs.severity)
                }
                if lhs.projectTitle != rhs.projectTitle {
                    return lhs.projectTitle < rhs.projectTitle
                }
                return lhs.title < rhs.title
            }
            .enumerated()
            .map { index, item in
                HFOrchestrationQueueItem(
                    id: item.id,
                    projectID: item.projectID,
                    projectTitle: item.projectTitle,
                    position: index + 1,
                    stepID: item.stepID,
                    handoffID: item.handoffID,
                    title: item.title,
                    targetWorkspace: item.targetWorkspace,
                    suggestedAction: item.suggestedAction,
                    status: item.status,
                    severity: item.severity,
                    systemImage: item.systemImage
                )
            }
    }

    private static func projectSequenceState(
        for project: HFProject,
        handoffs: [HFCrossWorkspaceHandoff],
        intelligence: HFStudioIntelligenceSnapshot
    ) -> HFProjectSequenceState {
        let projectHandoffs = handoffs.filter { $0.projectID == project.id }
        let blockedCount = projectHandoffs.filter { $0.status == .blocked }.count
        let attentionCount = attentionDependencyCount(for: project, intelligence: intelligence)
        let currentWorkspace = owningWorkspace(for: project)
        let nextHandoff = projectHandoffs.first { $0.status == .blocked || $0.status == .reviewNeeded } ?? projectHandoffs.first
        let nextWorkspace = nextHandoff?.targetWorkspace ?? currentWorkspace
        let status: HFOrchestrationStatus
        let pipelineState: String

        if blockedCount > 0 {
            status = .blocked
            pipelineState = "Blocked before \(nextWorkspace.rawValue)"
        } else if attentionCount > 0 || project.reviewNotes > 0 {
            status = .reviewNeeded
            pipelineState = "Review needed before \(nextWorkspace.rawValue)"
        } else {
            status = .ready
            pipelineState = "Ready for \(nextWorkspace.rawValue)"
        }

        return HFProjectSequenceState(
            id: "\(project.id.rawValue)-project-sequence-state",
            projectID: project.id,
            projectTitle: project.shortTitle,
            currentWorkspace: currentWorkspace,
            nextWorkspace: nextWorkspace,
            pipelineState: pipelineState,
            suggestedSequence: suggestedSequence(for: project, nextWorkspace: nextWorkspace, blockedCount: blockedCount),
            readinessLabel: project.readinessPercentLabel,
            blockedHandoffCount: blockedCount,
            status: status,
            severity: severity(for: status),
            systemImage: nextWorkspace.systemImage
        )
    }

    private static func localActions() -> [HFOrchestrationLocalAction] {
        [
            HFOrchestrationLocalAction(
                id: "review-handoff",
                title: "Review Handoff",
                detail: "Open the selected handoff context for local review.",
                targetWorkspace: .higherKeyBrain,
                isPlaceholder: false,
                systemImage: "checklist.checked"
            ),
            HFOrchestrationLocalAction(
                id: "inspect-blocker",
                title: "Inspect Blocker",
                detail: "Inspect blocked dependency context without changing project state.",
                targetWorkspace: .qa,
                isPlaceholder: false,
                systemImage: "exclamationmark.triangle.fill"
            ),
            HFOrchestrationLocalAction(
                id: "open-target-workspace",
                title: "Open Target Workspace",
                detail: "Navigate to the local workspace surface for review.",
                targetWorkspace: .creatorOS,
                isPlaceholder: false,
                systemImage: "arrow.up.forward.app.fill"
            ),
            HFOrchestrationLocalAction(
                id: "mark-review-needed",
                title: "Mark as Review Needed",
                detail: "Placeholder action only; no persistence or backend update is enabled.",
                targetWorkspace: .higherKeyBrain,
                isPlaceholder: true,
                systemImage: "flag.fill"
            )
        ]
    }

    private static func owningWorkspace(for project: HFProject) -> HFOrchestrationWorkspace {
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

    private static func blockedDependencyCount(
        for project: HFProject,
        intelligence: HFStudioIntelligenceSnapshot
    ) -> Int {
        intelligence.dependencySignals.filter { $0.projectID == project.id && $0.severity == .blocked }.count
    }

    private static func attentionDependencyCount(
        for project: HFProject,
        intelligence: HFStudioIntelligenceSnapshot
    ) -> Int {
        intelligence.dependencySignals.filter { $0.projectID == project.id && $0.severity == .attention }.count
    }

    private static func readinessGateStatus(
        for project: HFProject,
        blockedCount: Int,
        attentionCount: Int
    ) -> HFOrchestrationStatus {
        if blockedCount > 0 { return .blocked }
        if attentionCount > 0 || project.reviewNotes > 0 { return .reviewNeeded }
        return .ready
    }

    private static func releaseGateStatus(
        for project: HFProject,
        blockedCount: Int,
        attentionCount: Int
    ) -> HFOrchestrationStatus {
        if blockedCount > 0 { return .blocked }
        if attentionCount > 0 || project.readiness.overall < 0.80 { return .reviewNeeded }
        return .ready
    }

    private static func actionLabel(
        for status: HFOrchestrationStatus,
        targetWorkspace: HFOrchestrationWorkspace,
        fallback: String?
    ) -> String {
        if status == .blocked { return "Inspect Blocker" }
        if targetWorkspace == .higherKeyBrain { return "Review Handoff" }
        if let fallback { return fallback }
        return "Mark as Review Needed"
    }

    private static func suggestedSequence(
        for project: HFProject,
        nextWorkspace: HFOrchestrationWorkspace,
        blockedCount: Int
    ) -> String {
        if blockedCount > 0 {
            return "Inspect blockers -> Review handoff -> \(nextWorkspace.rawValue)"
        }

        if project.readiness.overall >= 0.80 {
            return "Review handoff -> QA -> Release -> Marketing"
        }

        return "Review handoff -> \(nextWorkspace.rawValue) -> QA"
    }

    private static func severity(for status: HFOrchestrationStatus) -> HFStudioSignalSeverity {
        switch status {
        case .queued:
            return .watch
        case .ready:
            return .ready
        case .blocked:
            return .blocked
        case .reviewNeeded:
            return .attention
        case .localOnly:
            return .info
        }
    }

    private static func severityRank(_ severity: HFStudioSignalSeverity) -> Int {
        switch severity {
        case .blocked:
            return 5
        case .attention:
            return 4
        case .watch:
            return 3
        case .info:
            return 2
        case .ready:
            return 1
        }
    }
}
