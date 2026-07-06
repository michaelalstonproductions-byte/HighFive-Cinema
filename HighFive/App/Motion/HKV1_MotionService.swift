import Foundation
import CoreMotion
import UIKit

final class HKV1_MotionService {

    enum SimulatorTiltMode {
        case off
        case orbit
        case figureEight
        case sweep
    }

    private let manager = CMMotionManager()
    private let queue = OperationQueue()

    private var lastX: Double = 0
    private var lastY: Double = 0

    private var filteredX: Double = 0
    private var filteredY: Double = 0
    private var hasPrimedFilter = false

    private var simulatorTimer: DispatchSourceTimer?
    private var simulatorStartTime: TimeInterval = 0
    private var lastProcessTimestamp: CFTimeInterval = 0

    var maxTiltX: Double = 1.0
    var maxTiltY: Double = 1.0

    var simulatorTiltMode: SimulatorTiltMode = .orbit
    var simulatorSpeed: Double = 0.82
    var simulatorAmplitudeX: Double = 0.16
    var simulatorAmplitudeY: Double = 0.10
    var simulatorDriftX: Double = 0.030
    var simulatorDriftY: Double = 0.015
    var simulatorFPS: Double = 60.0

    private let outputScale: Double = 1.00
    private let quietDeadbandX: Double = 0.0022
    private let quietDeadbandY: Double = 0.0020
    private let settleResponse: Double = 5.2
    private let movingResponse: Double = 10.8
    private let motionThreshold: Double = 0.018

    // Orientation-aware tuning
    private let gravitySmoothingAlpha: Double = 0.16
    private let flatEnterZ: Double = 0.82
    private let flatExitZ: Double = 0.68
    private let flatBlendResponse: Double = 7.2

    private var smoothedGravityX: Double = 0.0
    private var smoothedGravityY: Double = 0.0
    private var smoothedGravityZ: Double = -1.0
    private var flatBlend: Double = 0.0

    var isRunning: Bool {
        #if targetEnvironment(simulator)
        return simulatorTimer != nil || manager.isDeviceMotionActive
        #else
        return manager.isDeviceMotionActive
        #endif
    }

    func start() {
        #if targetEnvironment(simulator)
        if Self.isSimulatorMotionPreviewEnabled {
            startSimulatorMotion()
        }
        #else
        startDeviceMotion()
        #endif
    }

    func stop() {
        #if targetEnvironment(simulator)
        stopSimulatorMotion()
        #endif
        manager.stopDeviceMotionUpdates()
    }

    func readTilt() -> (x: Double, y: Double) {
        (lastX, lastY)
    }

    func reset() {
        lastX = 0
        lastY = 0
        filteredX = 0
        filteredY = 0
        hasPrimedFilter = false
        simulatorStartTime = 0
        lastProcessTimestamp = 0

        smoothedGravityX = 0.0
        smoothedGravityY = 0.0
        smoothedGravityZ = -1.0
        flatBlend = 0.0
    }

    private func startDeviceMotion() {
        guard manager.isDeviceMotionAvailable else { return }
        if manager.isDeviceMotionActive { return }

        queue.qualityOfService = .userInteractive
        queue.maxConcurrentOperationCount = 1
        manager.deviceMotionUpdateInterval = 1.0 / 120.0

        reset()

        manager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: queue) { [weak self] motion, _ in
            guard let self, let motion else { return }

            let rawX = Double(motion.gravity.x)
            let rawY = Double(-motion.gravity.y)
            self.processIncomingTilt(rawX: rawX, rawY: rawY)
        }
    }

    private func startSimulatorMotion() {
        if simulatorTimer != nil { return }

        reset()
        simulatorStartTime = Date().timeIntervalSinceReferenceDate
        #if DEBUG
        print("[SimulatorQA] synthetic motion preview active")
        #endif

        let timer = DispatchSource.makeTimerSource(
            queue: queue.underlyingQueue ?? DispatchQueue(label: "com.higherkey.motion.sim")
        )

        let intervalNs = UInt64((1.0 / max(1.0, simulatorFPS)) * 1_000_000_000.0)
        timer.schedule(deadline: .now(), repeating: .nanoseconds(Int(intervalNs)))

        timer.setEventHandler { [weak self] in
            guard let self else { return }

            let now = Date().timeIntervalSinceReferenceDate
            let t = now - self.simulatorStartTime
            let synthetic = self.syntheticTilt(at: t)
            self.processIncomingTilt(rawX: synthetic.x, rawY: synthetic.y)
        }

        simulatorTimer = timer
        timer.resume()
    }

    private func stopSimulatorMotion() {
        simulatorTimer?.cancel()
        simulatorTimer = nil
    }

    private static var isSimulatorMotionPreviewEnabled: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.environment["HF_SIMULATOR_MOTION_PREVIEW"] == "1"
        #else
        return false
        #endif
    }

    private func syntheticTilt(at t: TimeInterval) -> (x: Double, y: Double) {
        switch simulatorTiltMode {
        case .off:
            return (0.0, 0.0)

        case .orbit:
            let x =
                sin(t * simulatorSpeed) * simulatorAmplitudeX +
                sin(t * simulatorSpeed * 0.21) * simulatorDriftX

            let y =
                cos(t * simulatorSpeed * 0.78) * simulatorAmplitudeY +
                cos(t * simulatorSpeed * 0.17) * simulatorDriftY

            return (x, y)

        case .figureEight:
            let x =
                sin(t * simulatorSpeed) * simulatorAmplitudeX +
                sin(t * simulatorSpeed * 0.33) * simulatorDriftX

            let y =
                sin(t * simulatorSpeed * 0.50) * simulatorAmplitudeY +
                cos(t * simulatorSpeed * 0.19) * simulatorDriftY

            return (x, y)

        case .sweep:
            let x =
                sin(t * simulatorSpeed * 0.55) * (simulatorAmplitudeX * 1.10) +
                sin(t * simulatorSpeed * 0.11) * simulatorDriftX

            let y =
                sin(t * simulatorSpeed * 0.24) * (simulatorAmplitudeY * 0.70) +
                cos(t * simulatorSpeed * 0.09) * simulatorDriftY

            return (x, y)
        }
    }

    private func normalizedViewerTilt(from motion: CMDeviceMotion) -> (x: Double, y: Double) {
        let now = CFAbsoluteTimeGetCurrent()

        let dt: Double
        if lastProcessTimestamp > 0 {
            dt = max(1.0 / 240.0, min(now - lastProcessTimestamp, 1.0 / 20.0))
        } else {
            dt = 1.0 / 60.0
        }

        // Smooth gravity so orientation/flatness transitions never snap
        smoothedGravityX += (motion.gravity.x - smoothedGravityX) * gravitySmoothingAlpha
        smoothedGravityY += (motion.gravity.y - smoothedGravityY) * gravitySmoothingAlpha
        smoothedGravityZ += (motion.gravity.z - smoothedGravityZ) * gravitySmoothingAlpha

        let orientation = currentInterfaceOrientation()

        // Upright mapping:
        // keep the existing feel, but align it to what the screen is doing.
        let upright = screenAlignedGravityXY(
            gx: smoothedGravityX,
            gy: smoothedGravityY,
            orientation: orientation
        )

        // Flat mapping:
        // when the device is flat / near-flat, derive motion from the screen plane.
        // This is the bed / sideways rescue.
        let flat = screenPlaneFlatXY(
            gx: smoothedGravityX,
            gy: smoothedGravityY,
            orientation: orientation
        )

        let flatness = abs(smoothedGravityZ)
        let targetFlatBlend: Double
        if flatness >= flatEnterZ {
            targetFlatBlend = 1.0
        } else if flatness <= flatExitZ {
            targetFlatBlend = 0.0
        } else {
            let t = (flatness - flatExitZ) / max(0.0001, (flatEnterZ - flatExitZ))
            targetFlatBlend = t
        }

        let flatAlpha = smoothingAlpha(response: flatBlendResponse, dt: dt)
        flatBlend += (targetFlatBlend - flatBlend) * flatAlpha

        let mixedX = mix(upright.x, flat.x, alpha: flatBlend)
        let mixedY = mix(upright.y, flat.y, alpha: flatBlend)

        return (mixedX, mixedY)
    }

    private func screenAlignedGravityXY(
        gx: Double,
        gy: Double,
        orientation: UIInterfaceOrientation
    ) -> (x: Double, y: Double) {
        switch orientation {
        case .portrait:
            return (gx, -gy)

        case .portraitUpsideDown:
            return (-gx, gy)

        case .landscapeLeft:
            return (-gy, -gx)

        case .landscapeRight:
            return (gy, gx)

        default:
            return (gx, -gy)
        }
    }

    private func screenPlaneFlatXY(
        gx: Double,
        gy: Double,
        orientation: UIInterfaceOrientation
    ) -> (x: Double, y: Double) {
        // Flat mode should feel like the visible screen is the reference plane,
        // not the world gravity frame.
        switch orientation {
        case .portrait:
            return (-gy, -gx)

        case .portraitUpsideDown:
            return (gy, gx)

        case .landscapeLeft:
            return (-gx, gy)

        case .landscapeRight:
            return (gx, -gy)

        default:
            return (-gy, -gx)
        }
    }

    private func currentInterfaceOrientation() -> UIInterfaceOrientation {
        if Thread.isMainThread {
            return readInterfaceOrientation()
        }

        var orientation: UIInterfaceOrientation = .portrait
        DispatchQueue.main.sync {
            orientation = readInterfaceOrientation()
        }
        return orientation
    }

    private func readInterfaceOrientation() -> UIInterfaceOrientation {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }

        if let active = scenes.first(where: { $0.activationState == .foregroundActive }) {
            return active.interfaceOrientation
        }

        if let first = scenes.first {
            return first.interfaceOrientation
        }

        return .portrait
    }

    private func processIncomingTilt(rawX: Double, rawY: Double) {
        let clampedX = clamp(rawX, min: -maxTiltX, max: maxTiltX)
        let clampedY = clamp(rawY, min: -maxTiltY, max: maxTiltY)

        let now = CFAbsoluteTimeGetCurrent()
        let dt: Double
        if lastProcessTimestamp > 0 {
            dt = max(1.0 / 240.0, min(now - lastProcessTimestamp, 1.0 / 20.0))
        } else {
            dt = 1.0 / 60.0
        }
        lastProcessTimestamp = now

        if !hasPrimedFilter {
            filteredX = clampedX
            filteredY = clampedY
            hasPrimedFilter = true
        }

        let delta = max(abs(clampedX - filteredX), abs(clampedY - filteredY))
        let response = delta < motionThreshold ? settleResponse : movingResponse
        let alpha = smoothingAlpha(response: response, dt: dt)

        filteredX += (clampedX - filteredX) * alpha
        filteredY += (clampedY - filteredY) * alpha

        var tx = filteredX * outputScale
        var ty = filteredY * outputScale

        tx = softenCenter(tx, threshold: quietDeadbandX)
        ty = softenCenter(ty, threshold: quietDeadbandY)

        lastX = clamp(tx, min: -maxTiltX, max: maxTiltX)
        lastY = clamp(ty, min: -maxTiltY, max: maxTiltY)
    }

    private func softenCenter(_ value: Double, threshold: Double) -> Double {
        let magnitude = abs(value)
        guard magnitude < threshold, threshold > 0 else { return value }
        let t = magnitude / threshold
        let eased = t * t * (3.0 - (2.0 * t))
        let scale = 0.38 + (0.62 * eased)
        return value * scale
    }

    private func smoothingAlpha(response: Double, dt: Double) -> Double {
        1.0 - Foundation.exp(-response * dt)
    }

    private func mix(_ a: Double, _ b: Double, alpha: Double) -> Double {
        a + ((b - a) * alpha)
    }

    private func clamp(_ value: Double, min minValue: Double, max maxValue: Double) -> Double {
        Swift.max(minValue, Swift.min(maxValue, value))
    }
}
