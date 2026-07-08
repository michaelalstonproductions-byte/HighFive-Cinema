import Foundation

enum HFStudioIntelligenceEngine {
    static func snapshot(projects: [HFProject], sourceLabel: String = "HFLocalProjectStore") -> HFStudioIntelligenceSnapshot {
        let events = projectEvents(from: projects)
        let readinessChanges = readinessChanges(from: projects)
        let dependencySignals = dependencySignals(from: projects)
        let automationSuggestions = automationSuggestions(from: projects)

        return HFStudioIntelligenceSnapshot(
            sourceLabel: sourceLabel,
            summary: "\(events.count) events, \(dependencySignals.count) dependency signals, \(readinessChanges.count) readiness changes, and \(automationSuggestions.count) local suggestions derived from shared project state.",
            events: events,
            readinessChanges: readinessChanges,
            dependencySignals: dependencySignals,
            automationSuggestions: automationSuggestions
        )
    }

    private static func projectEvents(from projects: [HFProject]) -> [HFStudioProjectEvent] {
        projects.flatMap { project in
            var events = project.activitySignals.prefix(2).map { signal in
                HFStudioProjectEvent(
                    id: "\(project.id.rawValue)-event-\(signal.id)",
                    projectID: project.id,
                    projectTitle: project.shortTitle,
                    kind: .activity,
                    title: signal.title,
                    detail: signal.detail,
                    severity: eventSeverity(for: project),
                    workspace: workspaceName(for: project),
                    systemImage: signal.systemImage
                )
            }

            if project.readiness.blockers > 0 {
                events.append(
                    HFStudioProjectEvent(
                        id: "\(project.id.rawValue)-event-blockers",
                        projectID: project.id,
                        projectTitle: project.shortTitle,
                        kind: .dependency,
                        title: "\(project.readiness.blockers) blocker signals",
                        detail: "\(project.workflowStage) has dependencies that should be reviewed before the next workspace handoff.",
                        severity: project.readiness.blockers >= 3 ? .blocked : .attention,
                        workspace: workspaceName(for: project),
                        systemImage: "exclamationmark.triangle.fill"
                    )
                )
            }

            return events
        }
    }

    private static func readinessChanges(from projects: [HFProject]) -> [HFStudioReadinessChange] {
        projects.map { project in
            let status = project.readiness.status
            let severity = readinessSeverity(for: project)
            let deltaLabel: String

            if project.readiness.blockers == 0 {
                deltaLabel = "Ready"
            } else if project.readiness.overall >= 0.75 {
                deltaLabel = "Hold"
            } else {
                deltaLabel = "Needs Review"
            }

            return HFStudioReadinessChange(
                id: "\(project.id.rawValue)-readiness",
                projectID: project.id,
                projectTitle: project.shortTitle,
                readinessLabel: project.readinessPercentLabel,
                packageLabel: project.packagePercentLabel,
                status: status,
                deltaLabel: deltaLabel,
                detail: "\(project.releaseState) is \(project.readinessPercentLabel) ready with \(project.readiness.blockers) blockers and \(project.reviewNotes) review notes.",
                severity: severity,
                systemImage: severity == .ready ? "checkmark.seal.fill" : "gauge.with.dots.needle.67percent"
            )
        }
    }

    private static func dependencySignals(from projects: [HFProject]) -> [HFStudioDependencySignal] {
        projects.flatMap { project in
            var signals = project.blockers.prefix(2).map { blocker in
                HFStudioDependencySignal(
                    id: "\(project.id.rawValue)-dependency-\(blocker.id)",
                    projectID: project.id,
                    projectTitle: project.shortTitle,
                    dependencyTitle: blocker.title,
                    upstreamWorkspace: workspaceName(for: project),
                    downstreamWorkspace: downstreamWorkspace(for: blocker),
                    status: blocker.status,
                    detail: "Resolve locally before \(project.shortTitle) moves from \(project.workflowStage) to \(project.releaseState).",
                    severity: blocker.status == "Blocking" ? .blocked : .attention,
                    systemImage: blocker.systemImage
                )
            }

            if project.assetState.trailer == "Needs Review" || project.assetState.trailer == "Not Started" {
                signals.append(
                    HFStudioDependencySignal(
                        id: "\(project.id.rawValue)-dependency-trailer-state",
                        projectID: project.id,
                        projectTitle: project.shortTitle,
                        dependencyTitle: "Trailer state: \(project.assetState.trailer)",
                        upstreamWorkspace: "Asset Review",
                        downstreamWorkspace: "Streaming Package",
                        status: project.assetState.trailer,
                        detail: "Keep this as a local review signal; no upload or publishing action is enabled.",
                        severity: project.assetState.trailer == "Not Started" ? .blocked : .attention,
                        systemImage: "film.fill"
                    )
                )
            }

            return signals
        }
    }

    private static func automationSuggestions(from projects: [HFProject]) -> [HFStudioAutomationSuggestion] {
        projects.flatMap { project in
            [
                blockerSuggestion(for: project),
                readinessSuggestion(for: project)
            ].compactMap { $0 }
        }
    }

    private static func blockerSuggestion(for project: HFProject) -> HFStudioAutomationSuggestion? {
        guard let blocker = project.blockers.first else { return nil }

        return HFStudioAutomationSuggestion(
            id: "\(project.id.rawValue)-suggestion-blocker",
            projectID: project.id,
            projectTitle: project.shortTitle,
            title: "Queue local blocker review",
            detail: "Open \(blocker.title) in \(workspaceName(for: project)) and attach it to the next team review pass.",
            actionLabel: "Local Review",
            destinationWorkspace: workspaceName(for: project),
            isLocalOnly: true,
            severity: blocker.status == "Blocking" ? .blocked : .attention,
            systemImage: "checklist.checked"
        )
    }

    private static func readinessSuggestion(for project: HFProject) -> HFStudioAutomationSuggestion? {
        guard project.readiness.overall >= 0.70 else {
            return HFStudioAutomationSuggestion(
                id: "\(project.id.rawValue)-suggestion-readiness-build",
                projectID: project.id,
                projectTitle: project.shortTitle,
                title: "Build readiness checklist",
                detail: "Group package, asset, and owner-review tasks into a local next-action list.",
                actionLabel: "Draft Checklist",
                destinationWorkspace: workspaceName(for: project),
                isLocalOnly: true,
                severity: .watch,
                systemImage: "list.bullet.clipboard.fill"
            )
        }

        return HFStudioAutomationSuggestion(
            id: "\(project.id.rawValue)-suggestion-next-actions",
            projectID: project.id,
            projectTitle: project.shortTitle,
            title: "Generate cross-workspace next actions",
            detail: "Prepare local handoff notes for \(project.shortTitle) across assets, review, and launch readiness.",
            actionLabel: "Prepare Notes",
            destinationWorkspace: "Brain Dashboard",
            isLocalOnly: true,
            severity: project.readiness.blockers > 0 ? .attention : .ready,
            systemImage: "sparkles"
        )
    }

    private static func eventSeverity(for project: HFProject) -> HFStudioSignalSeverity {
        if project.readiness.blockers >= 3 { return .attention }
        if project.readiness.overall >= 0.80 { return .ready }
        return .info
    }

    private static func readinessSeverity(for project: HFProject) -> HFStudioSignalSeverity {
        if project.readiness.blockers >= 3 { return .blocked }
        if project.readiness.blockers > 0 { return .attention }
        if project.readiness.overall >= 0.80 { return .ready }
        return .watch
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

    private static func downstreamWorkspace(for blocker: HFProjectBlocker) -> String {
        let title = blocker.title.lowercased()

        if title.contains("trailer") { return "Asset Review" }
        if title.contains("cast") || title.contains("credits") { return "Metadata Review" }
        if title.contains("team") || title.contains("owner") { return "Team Review" }
        if title.contains("budget") { return "Internal Review" }
        return "Brain Dashboard"
    }
}
