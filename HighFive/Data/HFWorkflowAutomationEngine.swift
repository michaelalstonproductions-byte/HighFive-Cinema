import Foundation

enum HFWorkflowAutomationEngine {
    static func snapshot(
        projects: [HFProject],
        intelligence: HFStudioIntelligenceSnapshot,
        sourceLabel: String = "HFLocalProjectStore + HFStudioIntelligenceEngine"
    ) -> HFWorkflowAutomationSnapshot {
        let rules = automationRules()
        let blockedDependencies = intelligence.dependencySignals.filter { $0.severity == .blocked }
        let dependencyThresholds = thresholds(from: intelligence.dependencySignals)
        let triggeredSuggestions = triggeredSuggestions(from: projects, intelligence: intelligence, rules: rules)
        let readinessMovementRecommendations = readinessMovements(from: projects, intelligence: intelligence)

        return HFWorkflowAutomationSnapshot(
            sourceLabel: sourceLabel,
            summary: "\(triggeredSuggestions.count) workflow suggestions, \(blockedDependencies.count) blocked dependencies, and \(readinessMovementRecommendations.count) readiness movement recommendations remain local-only.",
            rules: rules,
            dependencyThresholds: dependencyThresholds,
            triggeredSuggestions: triggeredSuggestions,
            blockedDependencies: blockedDependencies,
            readinessMovementRecommendations: readinessMovementRecommendations
        )
    }

    private static func automationRules() -> [HFWorkflowAutomationRule] {
        [
            HFWorkflowAutomationRule(
                id: "rule-blocker-review",
                title: "Blocker review queue",
                kind: .blockerReview,
                trigger: "Blocking dependency or two or more open blockers",
                localAction: "Create a local review suggestion for the owning workspace",
                targetWorkspace: "Creator OS",
                isEnabled: true,
                severity: .blocked,
                systemImage: "exclamationmark.triangle.fill"
            ),
            HFWorkflowAutomationRule(
                id: "rule-dependency-gate",
                title: "Dependency readiness gate",
                kind: .dependencyGate,
                trigger: "Open dependency count exceeds the local threshold",
                localAction: "Hold readiness movement until the dependency list is reviewed",
                targetWorkspace: "HigherKey Brain",
                isEnabled: true,
                severity: .attention,
                systemImage: "point.3.connected.trianglepath.dotted"
            ),
            HFWorkflowAutomationRule(
                id: "rule-readiness-movement",
                title: "Readiness movement advisor",
                kind: .readinessMovement,
                trigger: "Readiness reaches 70 percent or higher",
                localAction: "Recommend advance, hold, or review movement without changing stored state",
                targetWorkspace: "Brain Dashboard",
                isEnabled: true,
                severity: .watch,
                systemImage: "gauge.with.dots.needle.67percent"
            ),
            HFWorkflowAutomationRule(
                id: "rule-next-action",
                title: "Cross-workspace next action",
                kind: .nextAction,
                trigger: "Review notes, asset review, or team sign-off remain open",
                localAction: "Prepare local next-action notes for the next workspace handoff",
                targetWorkspace: "Packaging Studio",
                isEnabled: true,
                severity: .info,
                systemImage: "sparkles"
            )
        ]
    }

    private static func thresholds(from dependencies: [HFStudioDependencySignal]) -> [HFDependencyThreshold] {
        let blockedCount = dependencies.filter { $0.severity == .blocked }.count
        let attentionCount = dependencies.filter { $0.severity == .attention }.count

        return [
            HFDependencyThreshold(
                id: "threshold-blocked-dependencies",
                title: "Blocked dependency limit",
                dependencyStatus: "Blocked",
                maximumOpenDependencies: 0,
                currentOpenDependencies: blockedCount,
                recommendation: blockedCount > 0 ? "Hold readiness movement and route local review." : "No blocked dependency hold.",
                severity: blockedCount > 0 ? .blocked : .ready,
                systemImage: "lock.trianglebadge.exclamationmark.fill"
            ),
            HFDependencyThreshold(
                id: "threshold-attention-dependencies",
                title: "Attention dependency limit",
                dependencyStatus: "Attention",
                maximumOpenDependencies: 2,
                currentOpenDependencies: attentionCount,
                recommendation: attentionCount > 2 ? "Review dependency list before cross-workspace movement." : "Within local review threshold.",
                severity: attentionCount > 2 ? .attention : .info,
                systemImage: "list.bullet.clipboard.fill"
            )
        ]
    }

    private static func triggeredSuggestions(
        from projects: [HFProject],
        intelligence: HFStudioIntelligenceSnapshot,
        rules: [HFWorkflowAutomationRule]
    ) -> [HFWorkflowTriggeredSuggestion] {
        projects.flatMap { project in
            var suggestions: [HFWorkflowTriggeredSuggestion] = []
            let projectDependencies = intelligence.dependencySignals.filter { $0.projectID == project.id }
            let blockedDependencies = projectDependencies.filter { $0.severity == .blocked }

            if !blockedDependencies.isEmpty, let rule = rules.first(where: { $0.id == "rule-blocker-review" }) {
                suggestions.append(
                    HFWorkflowTriggeredSuggestion(
                        id: "\(project.id.rawValue)-workflow-blocker-review",
                        ruleID: rule.id,
                        projectID: project.id,
                        projectTitle: project.shortTitle,
                        title: "Route blocker review",
                        detail: "\(project.shortTitle) has \(blockedDependencies.count) blocked dependency signals that should be reviewed locally.",
                        actionLabel: "Review Blockers",
                        targetWorkspace: workspaceName(for: project),
                        isLocalOnly: true,
                        severity: .blocked,
                        systemImage: rule.systemImage
                    )
                )
            }

            if project.readiness.overall >= 0.70, let rule = rules.first(where: { $0.id == "rule-readiness-movement" }) {
                suggestions.append(
                    HFWorkflowTriggeredSuggestion(
                        id: "\(project.id.rawValue)-workflow-readiness-movement",
                        ruleID: rule.id,
                        projectID: project.id,
                        projectTitle: project.shortTitle,
                        title: "Evaluate readiness movement",
                        detail: "\(project.shortTitle) is at \(project.readinessPercentLabel); Brain can recommend advance, hold, or review without changing project state.",
                        actionLabel: "Evaluate",
                        targetWorkspace: rule.targetWorkspace,
                        isLocalOnly: true,
                        severity: blockedDependencies.isEmpty ? .watch : .attention,
                        systemImage: rule.systemImage
                    )
                )
            }

            if (project.reviewNotes > 0 || project.readiness.blockers > 0), let rule = rules.first(where: { $0.id == "rule-next-action" }) {
                suggestions.append(
                    HFWorkflowTriggeredSuggestion(
                        id: "\(project.id.rawValue)-workflow-next-action",
                        ruleID: rule.id,
                        projectID: project.id,
                        projectTitle: project.shortTitle,
                        title: "Prepare next action notes",
                        detail: "Summarize \(project.reviewNotes) review notes and \(project.readiness.blockers) blocker counts for \(workspaceName(for: project)).",
                        actionLabel: "Prepare Notes",
                        targetWorkspace: workspaceName(for: project),
                        isLocalOnly: true,
                        severity: .info,
                        systemImage: rule.systemImage
                    )
                )
            }

            return suggestions
        }
    }

    private static func readinessMovements(
        from projects: [HFProject],
        intelligence: HFStudioIntelligenceSnapshot
    ) -> [HFReadinessTransitionSuggestion] {
        projects.map { project in
            let projectDependencies = intelligence.dependencySignals.filter { $0.projectID == project.id }
            let blockedCount = projectDependencies.filter { $0.severity == .blocked }.count
            let attentionCount = projectDependencies.filter { $0.severity == .attention }.count
            let movement = movementState(for: project, blockedCount: blockedCount, attentionCount: attentionCount)

            return HFReadinessTransitionSuggestion(
                id: "\(project.id.rawValue)-readiness-movement",
                projectID: project.id,
                projectTitle: project.shortTitle,
                fromState: project.workflowStage,
                recommendedState: movement.state,
                readinessLabel: project.readinessPercentLabel,
                dependencySummary: "\(blockedCount) blocked, \(attentionCount) attention",
                detail: movement.detail,
                isMovementAllowed: movement.allowed,
                severity: movement.severity,
                systemImage: movement.allowed ? "arrow.up.forward.circle.fill" : "pause.circle.fill"
            )
        }
    }

    private static func movementState(
        for project: HFProject,
        blockedCount: Int,
        attentionCount: Int
    ) -> (state: String, detail: String, allowed: Bool, severity: HFStudioSignalSeverity) {
        if blockedCount > 0 {
            return (
                "Hold in \(project.workflowStage)",
                "Blocked dependencies prevent local readiness movement. Review dependencies before advancing.",
                false,
                .blocked
            )
        }

        if project.readiness.overall >= 0.80 && attentionCount == 0 {
            return (
                "Advance to \(project.releaseState)",
                "Readiness is high and dependency thresholds are clear. Prepare local handoff notes only.",
                true,
                .ready
            )
        }

        if project.readiness.overall >= 0.70 {
            return (
                "Review before \(project.releaseState)",
                "Readiness supports review, but attention dependencies should be cleared before movement.",
                false,
                .attention
            )
        }

        return (
            "Build readiness",
            "Keep this project in local preparation until package, asset, and team review scores improve.",
            false,
            .watch
        )
    }

    private static func workspaceName(for project: HFProject) -> String {
        switch project.lifecycleState {
        case .packaging:
            return "Packaging Studio"
        case .creatorReview:
            return "Creator OS"
        case .streaming:
            return "Streaming"
        case .intelligence:
            return "HigherKey Brain"
        }
    }
}
