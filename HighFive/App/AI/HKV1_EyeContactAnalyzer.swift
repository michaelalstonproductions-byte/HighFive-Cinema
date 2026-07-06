import UIKit
import Vision
import CoreGraphics

final class HKV1_EyeContactAnalyzer {

    struct SubjectInput {
        let stableID: Int
        let boundingBox: CGRect
    }

    struct SubjectOutput {
        let stableID: Int
        let eyeContactScore: CGFloat
        let frontalScore: CGFloat
        let centerEngagementScore: CGFloat
    }

    private struct SubjectState {
        var smoothedEyeContactScore: CGFloat = 0
        var lastSeenFrame: Int = 0
    }

    private var states: [Int: SubjectState] = [:]
    private let smoothingAlpha: CGFloat = 0.24
    private let staleFrameCutoff: Int = 18

    func reset() {
        states.removeAll()
    }

    func process(
        faceObservations: [VNFaceObservation],
        resolvedSubjects: [SubjectInput],
        frameIndex: Int
    ) -> [SubjectOutput] {
        guard !resolvedSubjects.isEmpty else {
            cleanup(frameIndex: frameIndex)
            return []
        }

        var outputs: [SubjectOutput] = []

        for subject in resolvedSubjects {
            let matchedFace = bestFaceMatch(
                for: subject.boundingBox,
                from: faceObservations
            )

            let frontalScore: CGFloat
            let centerEngagementScore: CGFloat
            let rawEyeContactScore: CGFloat

            if let matchedFace {
                let faceRect = matchedFace.boundingBox

                let symmetryScore = estimateFaceSymmetry(from: matchedFace)
                let centerXBias = 1.0 - abs(faceRect.midX - 0.5) / 0.5
                let centerYBias = 1.0 - abs(faceRect.midY - 0.56) / 0.56

                frontalScore = symmetryScore
                centerEngagementScore = max(
                    0,
                    (centerXBias * 0.70) + (centerYBias * 0.30)
                )

                rawEyeContactScore = clamp(
                    (frontalScore * 0.68) + (centerEngagementScore * 0.32),
                    min: 0,
                    max: 1
                )
            } else {
                frontalScore = 0
                centerEngagementScore = 0
                rawEyeContactScore = 0
            }

            var state = states[subject.stableID] ?? SubjectState()
            state.smoothedEyeContactScore += (rawEyeContactScore - state.smoothedEyeContactScore) * smoothingAlpha
            state.lastSeenFrame = frameIndex
            states[subject.stableID] = state

            outputs.append(
                SubjectOutput(
                    stableID: subject.stableID,
                    eyeContactScore: clamp(state.smoothedEyeContactScore, min: 0, max: 1),
                    frontalScore: frontalScore,
                    centerEngagementScore: centerEngagementScore
                )
            )
        }

        cleanup(frameIndex: frameIndex)
        return outputs
    }

    private func cleanup(frameIndex: Int) {
        states = states.filter { frameIndex - $0.value.lastSeenFrame <= staleFrameCutoff }
    }

    private func bestFaceMatch(
        for subjectRect: CGRect,
        from faces: [VNFaceObservation]
    ) -> VNFaceObservation? {
        faces.max { lhs, rhs in
            matchScore(subjectRect: subjectRect, faceRect: lhs.boundingBox)
            < matchScore(subjectRect: subjectRect, faceRect: rhs.boundingBox)
        }
    }

    private func matchScore(subjectRect: CGRect, faceRect: CGRect) -> CGFloat {
        let iou = rectIOU(subjectRect, faceRect)
        let dist = 1.0 - normalizedRectCenterDistance(subjectRect, faceRect)
        return (iou * 0.72) + (dist * 0.28)
    }

    private func estimateFaceSymmetry(from face: VNFaceObservation) -> CGFloat {
        guard let landmarks = face.landmarks else {
            return 0.0
        }

        guard
            let leftEye = landmarks.leftEye,
            let rightEye = landmarks.rightEye
        else {
            return 0.0
        }

        let leftBox = boundingBox(for: leftEye)
        let rightBox = boundingBox(for: rightEye)

        let leftArea = leftBox.width * leftBox.height
        let rightArea = rightBox.width * rightBox.height
        let maxArea = max(leftArea, rightArea)

        guard maxArea > 0.0001 else { return 0.0 }

        let areaSimilarity = 1.0 - abs(leftArea - rightArea) / maxArea

        let leftCenter = CGPoint(x: leftBox.midX, y: leftBox.midY)
        let rightCenter = CGPoint(x: rightBox.midX, y: rightBox.midY)

        let verticalAlignment = 1.0 - min(1.0, abs(leftCenter.y - rightCenter.y) * 4.0)

        return clamp(
            (areaSimilarity * 0.58) + (verticalAlignment * 0.42),
            min: 0,
            max: 1
        )
    }

    private func boundingBox(for region: VNFaceLandmarkRegion2D) -> CGRect {
        guard region.pointCount > 0 else { return .zero }

        let points = region.normalizedPoints
        var minX: CGFloat = 1
        var minY: CGFloat = 1
        var maxX: CGFloat = 0
        var maxY: CGFloat = 0

        for point in points {
            minX = Swift.min(minX, point.x)
            minY = Swift.min(minY, point.y)
            maxX = Swift.max(maxX, point.x)
            maxY = Swift.max(maxY, point.y)
        }

        return CGRect(
            x: minX,
            y: minY,
            width: max(0, maxX - minX),
            height: max(0, maxY - minY)
        )
    }

    private func rectIOU(_ a: CGRect, _ b: CGRect) -> CGFloat {
        let intersection = a.intersection(b)
        guard !intersection.isNull else { return 0.0 }

        let intersectionArea = intersection.width * intersection.height
        let unionArea = (a.width * a.height) + (b.width * b.height) - intersectionArea
        guard unionArea > 0 else { return 0.0 }
        return intersectionArea / unionArea
    }

    private func normalizedRectCenterDistance(_ a: CGRect, _ b: CGRect) -> CGFloat {
        let dx = a.midX - b.midX
        let dy = a.midY - b.midY
        let distance = hypot(dx, dy)
        return min(1.0, distance / 1.2)
    }

    private func clamp(_ value: CGFloat, min minValue: CGFloat, max maxValue: CGFloat) -> CGFloat {
        Swift.max(minValue, Swift.min(maxValue, value))
    }
}
