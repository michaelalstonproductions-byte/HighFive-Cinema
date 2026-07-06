import Foundation
import CoreGraphics
import Vision

final class HKV1_SubjectIdentityManager {

    struct Detection {
        let boundingBox: CGRect
        let confidence: CGFloat
    }

    struct ResolvedSubject {
        let stableID: Int
        let boundingBox: CGRect
        let confidence: CGFloat
        let isPrimaryCandidate: Bool
        let previousWinnerPresent: Bool
        let previousWinnerScore: Double?
        let previousWasPrimary: Bool
    }

    private struct Track {
        let stableID: Int
        var boundingBox: CGRect
        var confidence: CGFloat
        var lastSeenFrameIndex: Int
        var hitCount: Int
        var missCount: Int
        var isPrimary: Bool
    }

    private var nextStableID: Int = 1
    private var tracks: [Int: Track] = [:]
    private var frameCounter: Int = 0

    private var previousWinnerStableID: Int?
    private var previousWinnerWasPrimary: Bool = false

    private let maxMissFrames = 10
    private let minIOUForMatch: CGFloat = 0.18
    private let combinedMatchThreshold: CGFloat = 0.78
    private let centerDistanceWeight: CGFloat = 0.65
    private let sizeSimilarityWeight: CGFloat = 0.35

    func reset() {
        nextStableID = 1
        tracks.removeAll()
        frameCounter = 0
        previousWinnerStableID = nil
        previousWinnerWasPrimary = false
    }

    func setPreviousWinner(_ stableID: Int?, wasPrimary: Bool) {
        previousWinnerStableID = stableID
        previousWinnerWasPrimary = wasPrimary
    }

    func process(observations: [VNFaceObservation]) -> [ResolvedSubject] {
        let detections = observations.map {
            Detection(
                boundingBox: $0.boundingBox,
                confidence: CGFloat($0.confidence)
            )
        }
        return process(detections: detections)
    }

    func process(detections: [Detection]) -> [ResolvedSubject] {
        frameCounter += 1

        ageExistingTracks()
        let assignments = assignDetectionsToTracks(detections)
        applyAssignments(assignments, detections: detections)
        pruneExpiredTracks()

        return buildResolvedSubjects()
    }

    func bestSubject(from resolved: [ResolvedSubject]) -> ResolvedSubject? {
        guard !resolved.isEmpty else { return nil }
        return resolved.max { lhs, rhs in
            score(for: lhs) < score(for: rhs)
        }
    }

    private func ageExistingTracks() {
        for key in tracks.keys {
            guard var track = tracks[key] else { continue }
            track.missCount += 1
            track.confidence *= 0.96
            tracks[key] = track
        }
    }

    private func assignDetectionsToTracks(_ detections: [Detection]) -> [(detectionIndex: Int, trackID: Int)] {
        guard !tracks.isEmpty, !detections.isEmpty else { return [] }

        var candidates: [(Int, Int, CGFloat)] = []

        for (detectionIndex, detection) in detections.enumerated() {
            for (trackID, track) in tracks {
                let iouValue = iou(detection.boundingBox, track.boundingBox)
                let centerScore = 1.0 - normalizedCenterDistance(detection.boundingBox, track.boundingBox)
                let sizeScore = sizeSimilarity(detection.boundingBox, track.boundingBox)
                let primaryBonus: CGFloat = trackID == previousWinnerStableID ? 0.10 : 0.0
                let combined = iouValue + (centerScore * centerDistanceWeight) + (sizeScore * sizeSimilarityWeight) + primaryBonus

                if iouValue >= minIOUForMatch || combined >= combinedMatchThreshold {
                    candidates.append((detectionIndex, trackID, combined))
                }
            }
        }

        candidates.sort { $0.2 > $1.2 }

        var usedDetections = Set<Int>()
        var usedTracks = Set<Int>()
        var assignments: [(Int, Int)] = []

        for (detectionIndex, trackID, _) in candidates {
            guard !usedDetections.contains(detectionIndex) else { continue }
            guard !usedTracks.contains(trackID) else { continue }

            usedDetections.insert(detectionIndex)
            usedTracks.insert(trackID)
            assignments.append((detectionIndex, trackID))
        }

        return assignments
    }

    private func applyAssignments(
        _ assignments: [(detectionIndex: Int, trackID: Int)],
        detections: [Detection]
    ) {
        var assignedDetections = Set<Int>()

        for (detectionIndex, trackID) in assignments {
            assignedDetections.insert(detectionIndex)

            guard var track = tracks[trackID] else { continue }
            let detection = detections[detectionIndex]

            track.boundingBox = smoothRect(from: track.boundingBox, to: detection.boundingBox, alpha: 0.42)
            track.confidence = max(detection.confidence, track.confidence * 0.75)
            track.lastSeenFrameIndex = frameCounter
            track.hitCount += 1
            track.missCount = 0
            track.isPrimary = (trackID == previousWinnerStableID)

            tracks[trackID] = track
        }

        for (index, detection) in detections.enumerated() where !assignedDetections.contains(index) {
            let stableID = nextStableID
            nextStableID += 1

            let track = Track(
                stableID: stableID,
                boundingBox: detection.boundingBox,
                confidence: detection.confidence,
                lastSeenFrameIndex: frameCounter,
                hitCount: 1,
                missCount: 0,
                isPrimary: false
            )

            tracks[stableID] = track
        }
    }

    private func pruneExpiredTracks() {
        tracks = tracks.filter { _, track in
            track.missCount <= maxMissFrames
        }
    }

    private func buildResolvedSubjects() -> [ResolvedSubject] {
        let previousWinnerID = previousWinnerStableID

        return tracks.values
            .filter { $0.missCount == 0 }
            .sorted { lhs, rhs in
                score(for: lhs) > score(for: rhs)
            }
            .map { track in
                let previousPresent = (track.stableID == previousWinnerID)

                return ResolvedSubject(
                    stableID: track.stableID,
                    boundingBox: track.boundingBox,
                    confidence: track.confidence,
                    isPrimaryCandidate: track.hitCount >= 2 || previousPresent,
                    previousWinnerPresent: previousPresent,
                    previousWinnerScore: previousPresent ? Double(track.confidence) : nil,
                    previousWasPrimary: previousWinnerWasPrimary
                )
            }
    }

    private func score(for subject: ResolvedSubject) -> CGFloat {
        let box = subject.boundingBox
        let area = box.width * box.height
        let centerX = box.midX
        let centerY = box.midY

        let horizontalCenterBias = 1.0 - abs(centerX - 0.5) / 0.5
        let verticalCenterBias = 1.0 - abs(centerY - 0.55) / 0.55
        let centerBias = max(0.0, (horizontalCenterBias * 0.55) + (verticalCenterBias * 0.45))

        var total = subject.confidence * 1.20
        total += area * 1.10
        total += centerBias * 0.90

        if subject.previousWinnerPresent {
            total += 0.55
        }

        if subject.isPrimaryCandidate {
            total += 0.18
        }

        return total
    }

    private func score(for track: Track) -> CGFloat {
        let area = track.boundingBox.width * track.boundingBox.height
        let centerX = track.boundingBox.midX
        let centerY = track.boundingBox.midY

        let horizontalCenterBias = 1.0 - abs(centerX - 0.5) / 0.5
        let verticalCenterBias = 1.0 - abs(centerY - 0.55) / 0.55
        let centerBias = max(0.0, (horizontalCenterBias * 0.55) + (verticalCenterBias * 0.45))

        var total = track.confidence * 1.10
        total += area * 1.00
        total += centerBias * 0.80
        total += min(CGFloat(track.hitCount) * 0.04, 0.20)
        if track.isPrimary { total += 0.30 }
        return total
    }

    private func iou(_ a: CGRect, _ b: CGRect) -> CGFloat {
        let intersection = a.intersection(b)
        guard !intersection.isNull else { return 0.0 }

        let intersectionArea = intersection.width * intersection.height
        let unionArea = (a.width * a.height) + (b.width * b.height) - intersectionArea

        guard unionArea > 0 else { return 0.0 }
        return intersectionArea / unionArea
    }

    private func normalizedCenterDistance(_ a: CGRect, _ b: CGRect) -> CGFloat {
        let dx = a.midX - b.midX
        let dy = a.midY - b.midY
        let distance = hypot(dx, dy)
        return min(1.0, distance / 1.5)
    }

    private func sizeSimilarity(_ a: CGRect, _ b: CGRect) -> CGFloat {
        let areaA = max(0.0001, a.width * a.height)
        let areaB = max(0.0001, b.width * b.height)
        return min(areaA, areaB) / max(areaA, areaB)
    }

    private func smoothRect(from old: CGRect, to new: CGRect, alpha: CGFloat) -> CGRect {
        CGRect(
            x: old.origin.x + ((new.origin.x - old.origin.x) * alpha),
            y: old.origin.y + ((new.origin.y - old.origin.y) * alpha),
            width: old.size.width + ((new.size.width - old.size.width) * alpha),
            height: old.size.height + ((new.size.height - old.size.height) * alpha)
        )
    }
}
