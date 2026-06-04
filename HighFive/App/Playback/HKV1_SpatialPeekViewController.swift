//
//  Untitled.swift
//  HigherKeySpatialPeek_Rebuild
//
//  Created by Michael Alston on 3/29/26.
//
import UIKit
import AVFoundation
import CoreGraphics
import CoreImage
import PhotosUI
import UniformTypeIdentifiers
import Vision

final class HKV1_SpatialPeekViewController: UIViewController,
    PHPickerViewControllerDelegate,
    UIDocumentPickerDelegate
{
    private struct HKAutoPreset {
        var depth: CGFloat
        var focus: CGFloat
        var bg: CGFloat
        var mid: CGFloat
        var fg: CGFloat
    }

    private enum HKContentProfile: String {
        case general
        case people
        case landscape
        case interior
    }

    private struct HKSceneAnalysis {
        let profile: HKContentProfile
        let faceCount: Int
        let brightness: CGFloat
        let saturation: CGFloat
        let edgeDensity: CGFloat
        let skyBias: CGFloat
        let centralSubjectWeight: CGFloat
        let wideAspectBias: CGFloat
    }

    private enum HKExportPreset: String {
        case off = "OFF"
        case balanced = "BAL"
        case ultra = "ULTRA"
        case aggressive = "AGGR"

        var next: HKExportPreset {
            switch self {
            case .off: return .balanced
            case .balanced: return .ultra
            case .ultra: return .aggressive
            case .aggressive: return .off
            }
        }
    }

    // MARK: - Core

    private let playbackController = HKV1_PlaybackController()
    private let livePlaybackEngine = HKV1_LivePlaybackEngine()

    // MARK: - UI

    private let controlBar = HKV1_ControlBar()
    private let debugLabel = UILabel()
    private let libraryButton = UIButton(type: .system)
    private let defaultIntroVideoName = "Timeline 1"
    private var hasExitedToLibrary = false
    private let loadingOverlay = UIView()
    private let loadingCard = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let loadingTitleLabel = UILabel()
    private let loadingSubtitleLabel = UILabel()
    private let loadingProgressView = UIProgressView(progressViewStyle: .default)
    private let loadingPercentLabel = UILabel()
    private var exportProgressTimer: Timer?


    // MARK: - Visible Window / Stage

    private let maskContainerView = UIView()
    private let maskWindowView = UIView()
    private let stageView = UIView()
    private let playerView = HKV1_PlayerLayerView()

    // MARK: - Motion

    private let motionService = HKV1_MotionService()
    private let proMotionCoordinator = HKV1_ProMotionCoordinator()

    private var displayLink: CADisplayLink?
    private var lastDisplayTimestamp: CFTimeInterval = 0
    private var pendingUIUpdate: DispatchWorkItem?

    private var isAIEnabled: Bool = false
    private var isTiltEnabled: Bool = true
    private var isPeekEnabled: Bool = true
    private var manualTiltPreference: Bool = true
    private var manualPeekPreference: Bool = true
    private var aiTiltAssistEnabled: Bool = false
    private var aiPeekAssistEnabled: Bool = false

    private var smoothedManualDx: CGFloat = 0
    private var smoothedManualDy: CGFloat = 0
    private var smoothedAIDx: CGFloat = 0
    private var smoothedAIDy: CGFloat = 0

    private var lastMotionUIRefreshTime: CFTimeInterval = 0
    private let motionUIRefreshFPS: CFTimeInterval = 12.0

    // MARK: - Depth

    private let depthSidecar = HKV1_DepthSidecar()
    private let depthGenerator = HKV1_DepthGenerator()
    private let temporalDepth = HKV1_TemporalDepthFusion()
    private let exportEngine = HKV1_CinematicExportEngine()

    private var isDepthPreviewEnabled: Bool = true
    private var hasLoadedDepthSidecar: Bool = false
    private var loadedDepthFileName: String = "NONE"
    private var currentVideoURL: URL?

    private var cachedDepthImage: UIImage?
    private var lastResolvedDepthImage: UIImage?
    private var isPreparingDepth: Bool = false
    private var depthGenerationProgress: Double = 0.0
    private var activeDepthGenerationID = UUID()

    private var lastDepthRefreshTime: CFTimeInterval = 0
    private var lastDepthVideoSeconds: Double = -999.0

    private let playbackDepthRefreshFPS: CFTimeInterval = 8.0
    private let pausedDepthRefreshFPS: CFTimeInterval = 12.0
    private let minSecondsDeltaForDepthWhilePlaying: Double = 1.0 / 12.0
    private let minSecondsDeltaForDepthWhilePaused: Double = 1.0 / 30.0

    // MARK: - Playback

    private var playbackEndedObserver: NSObjectProtocol?
    private var isScrubbing = false

    // MARK: - AI Subject Framing
   
    private struct HKAISubjectCandidate {
        let boundingBox: CGRect
        let confidence: CGFloat
        let source: String
        let variant: String
    }

    private let subjectIdentityManager = HKV1_SubjectIdentityManager()
    private let temporalDecisionEngine = VerticalTemporalDecisionEngine(config: .baseline)
    private let aiAutopilotDriver = HKV1_AIAutopilotDriver()
    private var aiDriverResolvedRect: CGRect?
    private let vibeEngine = HKV1_VibeEngine()
    private var aiCurrentCameraID: String = "CAM_A"
    private var aiDirectorDebugReason: String = "boot"

    private let speakerDetectionEngine = HKV1_SpeakerDetectionEngine()
    private let shotClassifier = HKV1_ShotClassifier()
    private let eyeContactAnalyzer = HKV1_EyeContactAnalyzer()
    private let reactionDirector = HKV1_ReactionDirector()
    private let sceneTypeClassifier = HKV1_SceneTypeClassifier()
    private let directorPolicy = HKV1_DirectorPolicy()
    private let editorialRhythmEngine = HKV1_EditorialRhythmEngine()
    private let audioSpeakerDetectionEngine = HKV1_AudioSpeakerDetectionEngine()
    private lazy var playerAudioTap = HKV1_PlayerAudioTap(
        audioEngine: audioSpeakerDetectionEngine,
        player: playbackController.player
    )

    private var aiSpeakingScoreByStableID: [Int: CGFloat] = [:]
    private var aiAudioScoreByStableID: [Int: CGFloat] = [:]
    private var aiEyeContactScoreByStableID: [Int: CGFloat] = [:]
    private var aiCurrentShotClass: HKV1_ShotClass = .medium

    private let aiSpeakingWeight: CGFloat = 0.85
    private let aiEyeContactWeight: CGFloat = 0.35
    private var aiLastCenterXByStableID: [Int: CGFloat] = [:]
    private var aiVelocityXByStableID: [Int: CGFloat] = [:]
    private var aiLastSeenFrameByStableID: [Int: Int] = [:]

    private var aiTemporalFrameIndex: Int = 0
    private var aiChosenWinnerStableID: Int?
    private var thirdsBiasX: CGFloat = 0
    private var previousAISubjectCenterX: CGFloat?
    private var smoothedAISubjectVelocityX: CGFloat = 0
    private var aiPreviousWinnerWasPrimary: Bool = false
    private var aiPendingSwitchStableID: Int?
    private var aiPendingSwitchFrames: Int = 0
    private var aiPendingSwitchScore: CGFloat = 0
    private var aiLastCommittedSwitchFrame: Int = -1000
    private var aiReactionWindowUntilFrame: Int = 0
    private var aiLastSpeakerStableID: Int?

    private var trackedFaceObservation: VNDetectedObjectObservation?
    private var aiSubjectOffset: CGPoint = .zero
    private var aiSmoothedSubjectOffset: CGPoint = .zero
    private var aiLockConfidence: CGFloat = 0.0
    private var aiFrameBrightness: CGFloat = 0.5
    private var lastAIAnalysisTime: CFTimeInterval = 0
    private let aiAnalysisFPS: CFTimeInterval = 12.0
    private let aiWorkingCIContext = CIContext(options: [.useSoftwareRenderer: false])
    private var aiFrameGenerator: AVAssetImageGenerator?
    private let aiVerboseLogging = false
   
    private let aiMotionBoostDialogue: CGFloat = 4.4
    private let aiMotionBoostBase: CGFloat = 2.6
    private let aiVibeWeight: CGFloat = 3.6
    private let aiAreaWeight: CGFloat = 0.24
    private let aiCenterWeight: CGFloat = 0.18
    private let aiSwitchFramesRequired: Int = 1

    // MARK: - Cinematic Baseline V4 (Locked)
    // Top-10 median lock from converged W&B cluster, with AI lane isolated from Peek.

    private let aiTargetHeroY: CGFloat = 0.474665

    private let aiXStrength: CGFloat = 1.198143
    private let aiYStrength: CGFloat = 1.018004

    private let aiResponseXBaseline: CGFloat = 4.467930
    private let aiResponseYBaseline: CGFloat = 3.158101
    private let aiRecenterResponse: CGFloat = 1.666260
    // 🔥 FINAL GOLD LOCK (W&B CONVERGED VALUES)
    private let aiStrengthFinal: CGFloat = 0.215
    private let aiXResponseFinal: CGFloat = 3.7
    private let aiSwitchThresholdFinal: CGFloat = 0.52

    // AI Peek assist is now enabled in AI mode.
    // Keep it intentionally softer than manual Peek so AI remains framing owner.
    private let aiPeekAssistX: CGFloat = 0.18
    private let aiPeekAssistY: CGFloat = 0.12

    private let aiDeadZoneX: CGFloat = 0.199806
    private let aiDeadZoneY: CGFloat = 0.139759

    private let edgeProtectionX: CGFloat = 0.135393
    private let edgeProtectionY: CGFloat = 0.087305

    private let faceAreaWeight: CGFloat = 1.094014
    private let faceCenterWeight: CGFloat = 0.757319
    private let faceConfidenceThreshold: CGFloat = 0.294856

    private let faceContinuityIOUWeight: CGFloat = 1.861688
    private let faceContinuityDistWeight: CGFloat = 1.186624

    private let alphaXBase: CGFloat = 0.088823
    private let alphaXGain: CGFloat = 0.065174
    private let alphaYBase: CGFloat = 0.074472
    private let alphaYGain: CGFloat = 0.045899

    // Compatibility aliases used by the working ROBUST_V2 AI lane.
    private var aiAssistMaxTravelUsage: CGFloat { 0.413875 }
    private var aiResponseXRate: CGFloat { aiXResponseFinal }
    private var aiResponseYRate: CGFloat { aiXResponseFinal * 0.72 }
    private var aiRecenterResponseRate: CGFloat { aiRecenterResponse }
    private var aiPeekAssistXStrength: CGFloat { aiPeekAssistX }
    private var aiPeekAssistYStrength: CGFloat { aiPeekAssistY }

    private var aiLastStableRect: CGRect?
    private var aiLostTrackFrames: Int = 0
    private let aiLostTrackGraceFrames: Int = 22

    private final class HKAITraceLogger {
        private let queue = DispatchQueue(label: "com.higherkey.spatialpeek.ai-trace")
        private var fileURL: URL?

        func beginSession(clipName: String) {
            queue.async {
                let formatter = ISO8601DateFormatter()
                let stamp = formatter.string(from: Date()).replacingOccurrences(of: ":", with: "-")
                let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                self.fileURL = docs.appendingPathComponent("hk_ai_trace_\(stamp).jsonl")
                self.append([
                    "type": "session_start",
                    "clip_name": clipName,
                    "started_at": formatter.string(from: Date())
                ])
            }
        }

        func logFrame(
            now: CFTimeInterval,
            detectedRect: CGRect?,
            resolvedRect: CGRect?,
            targetOffset: CGPoint,
            smoothedOffset: CGPoint,
            stageOffset: CGPoint,
            lostTrackFrames: Int,
            detectorInfo: [String: Any] = [:]
        ) {
            queue.async {
                var payload: [String: Any] = [
                    "type": "frame",
                    "t": now,
                    "lost_track_frames": lostTrackFrames,
                    "target_offset": ["x": targetOffset.x, "y": targetOffset.y],
                    "smoothed_offset": ["x": smoothedOffset.x, "y": smoothedOffset.y],
                    "stage_offset": ["x": stageOffset.x, "y": stageOffset.y]
                ]
                if let detectedRect {
                    payload["detected_rect"] = [
                        "x": detectedRect.origin.x,
                        "y": detectedRect.origin.y,
                        "w": detectedRect.width,
                        "h": detectedRect.height
                    ]
                }
                if let resolvedRect {
                    payload["resolved_rect"] = [
                        "x": resolvedRect.origin.x,
                        "y": resolvedRect.origin.y,
                        "w": resolvedRect.width,
                        "h": resolvedRect.height
                    ]
                }
                for (key, value) in detectorInfo {
                    payload[key] = value
                }
                self.append(payload)
            }
        }

        func endSession() {
            queue.async {
                let formatter = ISO8601DateFormatter()
                self.append([
                    "type": "session_end",
                    "ended_at": formatter.string(from: Date())
                ])
            }
        }

        private func append(_ payload: [String: Any]) {
            guard let fileURL else { return }

            do {
                let data = try JSONSerialization.data(withJSONObject: payload)
                let line = data + Data([0x0A])

                if !FileManager.default.fileExists(atPath: fileURL.path) {
                    FileManager.default.createFile(atPath: fileURL.path, contents: nil)
                }

                let handle = try FileHandle(forWritingTo: fileURL)
                try handle.seekToEnd()
                try handle.write(contentsOf: line)
                try handle.close()
            } catch {
                print("TRACE ERROR:", error)
            }
        }
    }

    private let aiTraceLogger = HKAITraceLogger()
    private var aiDetectorTelemetry: [String: Any] = [:]

    // MARK: - Chrome Auto Hide

    private var controlBarHideWorkItem: DispatchWorkItem?
    private var isControlBarVisible = true
    private var chromeInteractionLocks = 0
    private let controlBarAutoHideDelay: TimeInterval = 2.2
    var selectedMovie: HKCMovie?

    // MARK: - Geometry

    private var currentStageOffset: CGPoint = .zero
    private var maxTravelX: CGFloat = 0
    private var maxTravelY: CGFloat = 0

    // MARK: - Debug Motion State

    private var lastRawTiltX: CGFloat = 0
    private var lastRawTiltY: CGFloat = 0
    private var lastAppliedDx: CGFloat = 0
    private var lastAppliedDy: CGFloat = 0

    // MARK: - Tuning

    private let portraitStageOverscanScale: CGFloat = 1.18
    private let landscapeStageOverscanScale: CGFloat = 1.12

    private let stageTravelUsageX: CGFloat = 0.94
    private let stageTravelUsageY: CGFloat = 0.94

    private let modeOffGain: CGFloat = 0.0
    private let modeCloseGain: CGFloat = 1.05
    private let modeWideGain: CGFloat = 2.45

    private let depthMotionAmplificationClose: CGFloat = 0.78
    private let depthMotionAmplificationWide: CGFloat = 2.65

    private var currentModeIndex: Int = 1
    private var framingScale: CGFloat = 0.86

    private var isManualMotionLaneActive: Bool {
        !isAIEnabled && (isTiltEnabled || isPeekEnabled)
    }

    private let presetAnalysisQueue = DispatchQueue(label: "com.higherkey.spatialpeek.preset-analysis", qos: .userInitiated)
    private var currentContentProfile: HKContentProfile = .general
    private var currentSceneAnalysis: HKSceneAnalysis?
    private var cinematicMode: Bool = false
    private var exportPreset: HKExportPreset = .off

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        buildViewHierarchy()
        styleViews()
        setupLoadingOverlay()
        wirePlayback()
        wireGestures()
        wireControlBar()

        playerView.lensMode = .anamorphic
        currentModeIndex = 1
        framingScale = 0.86
        cinematicMode = false
        applyResolvedLensPresetStack(forceDepthRefresh: false)
       
        syncControlBarState()
        loadInitialPlaybackRoute()
        showControlBar(animated: false, scheduleHide: false)
        scheduleControlBarAutoHideIfAllowed()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startMotionPipeline()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopMotionPipeline()
    }

    deinit {
        if let observer = playbackEndedObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        aiTraceLogger.endSession()
        livePlaybackEngine.detach()
        playerAudioTap.detach()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutStageAndMask()
    }

    // MARK: - Presets

    private func resolvedAutoPreset(
        lens: HKV1_PlayerLayerView.LensMode,
        modeIndex: Int,
        content: HKContentProfile
    ) -> HKAutoPreset {
        let base: HKAutoPreset

        switch (lens, modeIndex) {
        case (.natural, 1):
            base = HKAutoPreset(depth: 1.34, focus: 0.66, bg: 0.57, mid: 1.48, fg: 0.70)
        case (.natural, 2):
            base = HKAutoPreset(depth: 1.48, focus: 0.64, bg: 0.68, mid: 1.66, fg: 0.82)
        case (.anamorphic, 1):
            base = HKAutoPreset(depth: 2.50, focus: 0.52, bg: 0.35, mid: 1.14, fg: 0.55)
        case (.anamorphic, 2):
            base = HKAutoPreset(depth: 1.98, focus: 0.54, bg: 0.30, mid: 2.02, fg: 1.44)
        case (.portrait, 1):
            base = HKAutoPreset(depth: 1.24, focus: 0.80, bg: 0.76, mid: 1.26, fg: 0.88)
        case (.portrait, 2):
            base = HKAutoPreset(depth: 1.36, focus: 0.84, bg: 0.88, mid: 1.44, fg: 1.00)
        default:
            switch lens {
            case .natural:
                base = HKAutoPreset(depth: 1.34, focus: 0.66, bg: 0.57, mid: 1.48, fg: 0.70)
            case .anamorphic:
                base = HKAutoPreset(depth: 1.68, focus: 0.58, bg: 0.40, mid: 1.76, fg: 1.20)
            case .portrait:
                base = HKAutoPreset(depth: 1.24, focus: 0.80, bg: 0.76, mid: 1.26, fg: 0.88)
            }
        }

        return tunedPreset(base: base, lens: lens, modeIndex: modeIndex, content: content)
    }

    private func tunedPreset(
        base: HKAutoPreset,
        lens: HKV1_PlayerLayerView.LensMode,
        modeIndex: Int,
        content: HKContentProfile
    ) -> HKAutoPreset {
        var preset = base

        switch content {
        case .people:
            switch lens {
            case .natural:
                preset.focus += 0.08
                preset.bg -= 0.06
                preset.mid += 0.10
                preset.fg += 0.12
            case .anamorphic:
                preset.depth -= 0.04
                preset.focus += 0.10
                preset.bg -= 0.06
                preset.mid += 0.06
                preset.fg -= 0.08
            case .portrait:
                preset.depth += 0.08
                preset.focus += 0.08
                preset.bg -= 0.08
                preset.mid += 0.04
                preset.fg += 0.10
            }
        case .landscape:
            switch lens {
            case .natural:
                preset.depth -= 0.06
                preset.focus -= 0.08
                preset.bg += 0.10
                preset.mid -= 0.06
                preset.fg -= 0.10
            case .anamorphic:
                preset.depth += 0.06
                preset.focus -= 0.06
                preset.bg += 0.12
                preset.mid += 0.02
                preset.fg -= 0.08
            case .portrait:
                preset.depth -= 0.10
                preset.focus -= 0.10
                preset.bg += 0.08
                preset.mid -= 0.04
                preset.fg -= 0.14
            }
        case .interior:
            switch lens {
            case .natural:
                preset.depth += 0.08
                preset.focus += 0.02
                preset.bg -= 0.02
                preset.mid += 0.12
                preset.fg += 0.08
            case .anamorphic:
                preset.depth += 0.10
                preset.focus += 0.02
                preset.bg -= 0.02
                preset.mid += 0.14
                preset.fg += 0.10
            case .portrait:
                preset.depth += 0.04
                preset.focus += 0.06
                preset.bg -= 0.04
                preset.mid += 0.10
                preset.fg += 0.06
            }
        case .general:
            break
        }

        if modeIndex == 2 {
            switch content {
            case .people:
                preset.fg += 0.04
            case .landscape:
                preset.bg += 0.04
                preset.focus -= 0.02
            case .interior:
                preset.mid += 0.04
                preset.depth += 0.02
            case .general:
                break
            }
        }

        return clampPreset(preset)
    }

    private func clampPreset(_ preset: HKAutoPreset) -> HKAutoPreset {
        HKAutoPreset(
            depth: clamp(preset.depth, min: 0.90, max: 2.30),
            focus: clamp(preset.focus, min: 0.40, max: 0.92),
            bg: clamp(preset.bg, min: 0.20, max: 1.40),
            mid: clamp(preset.mid, min: 0.80, max: 2.20),
            fg: clamp(preset.fg, min: 0.55, max: 1.90)
        )
    }

    private func mapLens(_ mode: HKV1_PlayerLayerView.LensMode) -> HKV1_LensType {
        switch mode {
        case .natural:
            return .natural
        case .anamorphic:
            return .anamorphic
        case .portrait:
            return .portrait
        }
    }
   
    // MARK: - Manual Tilt / Peek Tuning

    private struct HKManualTiltPeekTuning {
        struct AxisPair {
            let responseX: CGFloat
            let responseY: CGFloat
            let gainXClose: CGFloat
            let gainYClose: CGFloat
            let gainXWide: CGFloat
            let gainYWide: CGFloat
            let maxDelta: CGFloat
            let jitterThreshold: CGFloat
            let inertia: CGFloat
            let centerSoftness: CGFloat
            let zeroClamp: CGFloat
        }

        struct LensBias {
            let tiltLateralBias: CGFloat
            let tiltVerticalBias: CGFloat
            let peekLateralBias: CGFloat
            let peekVerticalBias: CGFloat
        }

        let tilt: AxisPair
        let peek: AxisPair
        let lens: LensBias
    }

    private func currentManualTiltPeekTuning() -> HKManualTiltPeekTuning {
        let tilt = HKManualTiltPeekTuning.AxisPair(
            responseX: 6.8,
            responseY: 6.2,
            gainXClose: 0.92,
            gainYClose: 0.82,
            gainXWide: 1.42,
            gainYWide: 1.12,
            maxDelta: 12.0,
            jitterThreshold: 0.015,
            inertia: 0.92,
            centerSoftness: 0.82,
            zeroClamp: 0.02
        )

        let peek = HKManualTiltPeekTuning.AxisPair(
            responseX: 5.4,
            responseY: 5.0,
            gainXClose: 0.72,
            gainYClose: 0.62,
            gainXWide: 1.02,
            gainYWide: 0.86,
            maxDelta: 8.0,
            jitterThreshold: 0.012,
            inertia: 0.94,
            centerSoftness: 0.86,
            zeroClamp: 0.015
        )

        let lens: HKManualTiltPeekTuning.LensBias
        switch playerView.lensMode {
        case .natural:
            lens = .init(
                tiltLateralBias: 1.22,
                tiltVerticalBias: 1.00,
                peekLateralBias: 1.08,
                peekVerticalBias: 0.96
            )
        case .anamorphic:
            lens = .init(
                tiltLateralBias: 1.58,
                tiltVerticalBias: 0.78,
                peekLateralBias: 1.22,
                peekVerticalBias: 0.72
            )
        case .portrait:
            lens = .init(
                tiltLateralBias: 1.12,
                tiltVerticalBias: 0.92,
                peekLateralBias: 0.96,
                peekVerticalBias: 0.88
            )
        }

        return HKManualTiltPeekTuning(
            tilt: tilt,
            peek: peek,
            lens: lens
        )
    }

    private func softCenter(_ value: CGFloat, softness: CGFloat) -> CGFloat {
        let magnitude = abs(value)
        let sign: CGFloat = value < 0 ? -1.0 : 1.0
        let shaped = magnitude * softness
        return sign * shaped
    }
    private func expSmoothingAlpha(response: CGFloat, dt: CGFloat) -> CGFloat {
        1.0 - exp(-response * dt)
    }

    private func applyARRIShoulder(_ value: CGFloat, limit: CGFloat, shoulderStart: CGFloat, softness: CGFloat) -> CGFloat {
        guard limit > 0 else { return 0.0 }

        let normalized = clamp(value / limit, min: -1.0, max: 1.0)
        let sign: CGFloat = normalized < 0 ? -1.0 : 1.0
        let magnitude = abs(normalized)

        if magnitude <= shoulderStart {
            return normalized * limit
        }

        let remaining = max(0.0001, 1.0 - shoulderStart)
        let u = (magnitude - shoulderStart) / remaining
        let eased = shoulderStart + ((1.0 - shoulderStart) * (1.0 - exp(-(u / max(0.0001, softness)))))
        return sign * min(1.0, eased) * limit
    }

    private func cinematicCenterDamp(_ value: CGFloat, deadZone: CGFloat, softness: CGFloat) -> CGFloat {
        let magnitude = abs(value)
        guard deadZone > 0 else { return value }
        guard magnitude < deadZone else { return value }

        let t = magnitude / deadZone
        let eased = t * t * (3.0 - (2.0 * t))
        let scale = softness + ((1.0 - softness) * eased)
        return value * scale
    }
    private func currentLensTuningProfile() -> HKV1_LensTuningProfile {
        HKV1_LensTuning.profile(for: mapLens(playerView.lensMode))
    }

    private func applyShoulderEasing(_ value: CGFloat, limit: CGFloat, start: CGFloat, softness: CGFloat) -> CGFloat {
        guard limit > 0 else { return 0.0 }

        let normalized = max(-1.0, min(1.0, value / limit))
        let sign: CGFloat = normalized < 0 ? -1.0 : 1.0
        let magnitude = abs(normalized)

        if magnitude <= start {
            return normalized * limit
        }

        let denom = max(0.0001, 1.0 - start)
        let u = min(1.0, max(0.0, (magnitude - start) / denom))
        let eased = start + ((1.0 - start) * (1.0 - exp(-(u / max(0.0001, softness)))))
        return sign * min(1.0, eased) * limit
    }

    private func applyResolvedLensPresetStack(forceDepthRefresh: Bool = true) {
        playerView.applyLensPresetDefaults()
        applyAutoPresetForCurrentSelection()
        applyMotionPersonality()
        if forceDepthRefresh {
            refreshDepthCompositeIfNeeded(force: true)
        }
        syncControlBarState()
    }

    private func applyMotionPersonality() {
        let coordinatorPersonality: HKV1_ProMotionCoordinator.CameraPersonality

        if currentModeIndex == 2 {
            coordinatorPersonality = .imax
        } else {
            switch playerView.lensMode {
            case .anamorphic:
                coordinatorPersonality = .cinematic
            case .portrait:
                coordinatorPersonality = (currentContentProfile == .landscape) ? .float : .cinematic
            case .natural:
                coordinatorPersonality = (currentContentProfile == .landscape) ? .float : .cinematic
            }
        }

        proMotionCoordinator.cameraPersonality = coordinatorPersonality
    }
    
    private func applyAutoPresetForCurrentSelection() {
        let resolved = resolvedAutoPreset(
            lens: playerView.lensMode,
            modeIndex: currentModeIndex,
            content: currentContentProfile
        )

        let lens = currentLensTuningProfile()

        var depth = resolved.depth * lens.depthIntensity
        var focus = resolved.focus * lens.focusFalloff
        var bg = resolved.bg * lens.bgPlane
        var mid = resolved.mid * lens.midPlane
        var fg = resolved.fg * lens.fgPlane

        if cinematicMode {
            depth *= lens.cinematicDepthMultiplier
            bg *= lens.cinematicBgMultiplier
            mid *= lens.cinematicMidMultiplier
            fg *= lens.cinematicFgMultiplier
        }

        playerView.depthIntensity = clamp(depth, min: 0.90, max: 2.50)
        playerView.focusFalloff = clamp(focus, min: 0.40, max: 1.05)
        playerView.bgPlaneControl = clamp(bg, min: 0.20, max: 2.20)
        playerView.midPlaneControl = clamp(mid, min: 0.60, max: 2.60)
        playerView.fgPlaneControl = clamp(fg, min: 0.55, max: 3.10)

        controlBar.setLensMode(playerView.lensMode.rawValue)
        controlBar.setLUTPreset(playerView.lutMode.rawValue)
        controlBar.setDepthIntensity(Float(playerView.depthIntensity))
        controlBar.setFocusFalloff(Float(playerView.focusFalloff))
        controlBar.setBGPlaneControl(Float(playerView.bgPlaneControl))
        controlBar.setMIDPlaneControl(Float(playerView.midPlaneControl))
        controlBar.setFGPlaneControl(Float(playerView.fgPlaneControl))
        controlBar.setFramingScale(Float(framingScale))
    }
    private func analyzeContentAndApplyPreset(for videoURL: URL) {
        let generationID = activeDepthGenerationID

        presetAnalysisQueue.async { [weak self] in
            guard let self = self else { return }
            let analysis = self.analyzeRepresentativeFrame(for: videoURL)

            DispatchQueue.main.async {
                guard self.activeDepthGenerationID == generationID else { return }
                self.currentSceneAnalysis = analysis
                self.currentContentProfile = analysis?.profile ?? .general
                self.applyAutoPresetForCurrentSelection()
                self.refreshDepthCompositeIfNeeded(force: true)
                self.syncControlBarState()
            }
        }
    }

    private func analyzeRepresentativeFrame(for videoURL: URL) -> HKSceneAnalysis? {
        let asset = AVAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 640, height: 640)
        generator.requestedTimeToleranceBefore = CMTime(seconds: 0.10, preferredTimescale: 600)
        generator.requestedTimeToleranceAfter = CMTime(seconds: 0.10, preferredTimescale: 600)

        let duration = asset.duration.seconds.isFinite ? asset.duration.seconds : 0.0
        let probeSeconds = max(0.0, min(duration > 0.6 ? 0.35 : 0.0, max(0.0, duration - 0.05)))
        let probeTime = CMTime(seconds: probeSeconds, preferredTimescale: 600)

        guard let cgImage = try? generator.copyCGImage(at: probeTime, actualTime: nil) else {
            return nil
        }

        return sceneAnalysis(from: cgImage)
    }

    private func sceneAnalysis(from cgImage: CGImage) -> HKSceneAnalysis? {
        let width = cgImage.width
        let height = cgImage.height
        guard width > 8, height > 8 else { return nil }

        let targetMax = 160.0
        let scale = min(1.0, targetMax / Double(max(width, height)))
        let targetWidth = max(16, Int((Double(width) * scale).rounded()))
        let targetHeight = max(16, Int((Double(height) * scale).rounded()))

        let bytesPerRow = targetWidth * 4
        var pixels = [UInt8](repeating: 0, count: bytesPerRow * targetHeight)

        guard let ctx = CGContext(
            data: &pixels,
            width: targetWidth,
            height: targetHeight,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }

        ctx.interpolationQuality = .low
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight))

        var totalBrightness: CGFloat = 0
        var totalSaturation: CGFloat = 0
        var totalEdge: CGFloat = 0
        var skyAccumulator: CGFloat = 0
        var centerAccumulator: CGFloat = 0

        func brightnessAt(_ x: Int, _ y: Int) -> CGFloat {
            let idx = (y * bytesPerRow) + (x * 4)
            let r = CGFloat(pixels[idx]) / 255.0
            let g = CGFloat(pixels[idx + 1]) / 255.0
            let b = CGFloat(pixels[idx + 2]) / 255.0
            return (0.299 * r) + (0.587 * g) + (0.114 * b)
        }

        for y in 0..<targetHeight {
            let vertical = CGFloat(y) / CGFloat(max(targetHeight - 1, 1))
            for x in 0..<targetWidth {
                let idx = (y * bytesPerRow) + (x * 4)
                let r = CGFloat(pixels[idx]) / 255.0
                let g = CGFloat(pixels[idx + 1]) / 255.0
                let b = CGFloat(pixels[idx + 2]) / 255.0

                let maxC = max(r, max(g, b))
                let minC = min(r, min(g, b))
                let brightness = (0.299 * r) + (0.587 * g) + (0.114 * b)
                let saturation = maxC > 0.0001 ? (maxC - minC) / maxC : 0.0

                totalBrightness += brightness
                totalSaturation += saturation

                if x + 1 < targetWidth, y + 1 < targetHeight {
                    let gx = abs(brightnessAt(x + 1, y) - brightness)
                    let gy = abs(brightnessAt(x, y + 1) - brightness)
                    totalEdge += min(1.0, gx + gy)
                }

                let horizontal = CGFloat(x) / CGFloat(max(targetWidth - 1, 1))
                let centerDistance = hypot(horizontal - 0.5, vertical - 0.56)
                let centerWeight = max(0.0, 1.0 - (centerDistance / 0.52))
                centerAccumulator += brightness * centerWeight

                let looksLikeSky = (vertical < 0.42) && (brightness > 0.54) && (saturation < 0.28)
                if looksLikeSky {
                    skyAccumulator += 1.0
                }
            }
        }

        let sampleCount = CGFloat(targetWidth * targetHeight)
        guard sampleCount > 0 else { return nil }

        let brightness = totalBrightness / sampleCount
        let saturation = totalSaturation / sampleCount
        let edgeDensity = totalEdge / sampleCount
        let skyBias = skyAccumulator / sampleCount
        let centralSubjectWeight = clamp((centerAccumulator / sampleCount) / max(brightness, 0.001), min: 0.0, max: 1.0)
        let wideAspectBias = clamp(CGFloat(width) / CGFloat(max(height, 1)), min: 0.6, max: 2.4)
        let faceCount = detectFaceCount(in: cgImage)

        let profile: HKContentProfile
        if faceCount > 0 || (centralSubjectWeight > 0.72 && skyBias < 0.18 && edgeDensity > 0.015) {
            profile = .people
        } else if skyBias > 0.16 || (wideAspectBias > 1.40 && brightness > 0.46 && edgeDensity < 0.040) {
            profile = .landscape
        } else if edgeDensity > 0.030 && skyBias < 0.08 {
            profile = .interior
        } else {
            profile = .general
        }

        return HKSceneAnalysis(
            profile: profile,
            faceCount: faceCount,
            brightness: brightness,
            saturation: saturation,
            edgeDensity: edgeDensity,
            skyBias: skyBias,
            centralSubjectWeight: centralSubjectWeight,
            wideAspectBias: wideAspectBias
        )
    }

    private func detectFaceCount(in cgImage: CGImage) -> Int {
        let request = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
            return request.results?.count ?? 0
        } catch {
            return 0
        }
    }

    // MARK: - Build

    private func buildViewHierarchy() {
        maskContainerView.translatesAutoresizingMaskIntoConstraints = false
        maskWindowView.translatesAutoresizingMaskIntoConstraints = true
        stageView.translatesAutoresizingMaskIntoConstraints = true
        playerView.translatesAutoresizingMaskIntoConstraints = true
        debugLabel.translatesAutoresizingMaskIntoConstraints = false
        controlBar.translatesAutoresizingMaskIntoConstraints = false
        libraryButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(maskContainerView)
        maskContainerView.addSubview(maskWindowView)
        maskWindowView.addSubview(stageView)
        stageView.addSubview(playerView)

        view.addSubview(debugLabel)
        view.addSubview(controlBar)
        view.addSubview(libraryButton)

        NSLayoutConstraint.activate([
            maskContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            maskContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            maskContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            maskContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            debugLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            debugLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
            debugLabel.bottomAnchor.constraint(equalTo: controlBar.topAnchor, constant: -10),

            libraryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            libraryButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            libraryButton.widthAnchor.constraint(equalToConstant: 46),
            libraryButton.heightAnchor.constraint(equalToConstant: 46),

            controlBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controlBar.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            controlBar.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
            controlBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }

    private func styleViews() {
        maskContainerView.backgroundColor = .black

        maskWindowView.backgroundColor = .black
        maskWindowView.layer.cornerRadius = 0.0
        maskWindowView.layer.borderWidth = 0.0
        maskWindowView.clipsToBounds = true

        stageView.backgroundColor = .black
        stageView.clipsToBounds = false

        playerView.backgroundColor = .black
        playerView.clipsToBounds = true
        playerView.allowsFallbackFullFrameMasks = true

        debugLabel.numberOfLines = 0
        debugLabel.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .medium)
        debugLabel.textColor = UIColor(white: 1.0, alpha: 0.78)
        debugLabel.textAlignment = .left
        debugLabel.isHidden = true
        debugLabel.alpha = 0.0

        libraryButton.setImage(UIImage(systemName: "rectangle.stack.fill"), for: .normal)
        libraryButton.tintColor = .white
        libraryButton.backgroundColor = UIColor(white: 0.08, alpha: 0.72)
        libraryButton.layer.cornerRadius = 23
        libraryButton.layer.cornerCurve = .continuous
        libraryButton.layer.borderWidth = 1.0
        libraryButton.layer.borderColor = UIColor.white.withAlphaComponent(0.10).cgColor
        libraryButton.layer.shadowColor = UIColor.black.cgColor
        libraryButton.layer.shadowOpacity = 0.22
        libraryButton.layer.shadowRadius = 14
        libraryButton.layer.shadowOffset = CGSize(width: 0, height: 8)
        libraryButton.addTarget(self, action: #selector(handleOpenLibraryButton), for: .touchUpInside)

        controlBar.setChromeVisible(true, animated: false)
    }

    // MARK: - Control Bar

    private func wireControlBar() {
        controlBar.onInteractionBegan = { [weak self] in
            self?.beginChromeInteraction()
        }

        controlBar.onInteractionEnded = { [weak self] in
            self?.endChromeInteraction()
        }

        controlBar.onPlayPause = { [weak self] in
            self?.togglePlayPause()
        }

        controlBar.onToggleDepth = { [weak self] enabled in
            guard let self = self else { return }
            self.isDepthPreviewEnabled = enabled
            self.refreshDepthCompositeIfNeeded(force: true)
            self.syncControlBarState()
        }

        controlBar.onToggleAI = { [weak self] enabled in
            guard let self = self else { return }

            if enabled {
                self.activateAIMode()
            } else if self.manualTiltPreference || self.manualPeekPreference {
                self.activateManualMode(
                    tilt: self.manualTiltPreference,
                    peek: self.manualPeekPreference
                )
            } else {
                self.activateIdleMode()
            }

            self.syncControlBarState()
            // 🔥 SEAM SAFE + AI STATE SYNC
            self.playerView.aiModeActive = enabled
            self.playerView.seamSafeModeEnabled = true
        }

        controlBar.onToggleTilt = { [weak self] enabled in
            guard let self = self else { return }

            self.manualTiltPreference = enabled

            if self.isAIEnabled {
                // AI mode never gets Tilt authority.
                // Store the preference only, do not activate Tilt.
                self.syncControlBarState()
                return
            }

            if enabled {
                self.activateManualMode(tilt: true, peek: self.manualPeekPreference)
            } else if self.manualPeekPreference {
                self.activateManualMode(tilt: false, peek: true)
            } else {
                self.activateIdleMode()
            }

            self.syncControlBarState()
        }
     
        controlBar.onExportTapped = { [weak self] in
            self?.exportCurrentVideo()
        }

        controlBar.onTogglePeek = { [weak self] enabled in
            guard let self = self else { return }

            self.manualPeekPreference = enabled

            if self.isAIEnabled {
                // Peek remains manual/user-driven during AI mode.
                self.isPeekEnabled = enabled
                self.syncControlBarState()
                return
            }

            if enabled {
                self.activateManualMode(tilt: self.manualTiltPreference, peek: true)
            } else if self.manualTiltPreference {
                self.activateManualMode(tilt: true, peek: false)
            } else {
                self.activateIdleMode()
            }

            self.syncControlBarState()
        }

        controlBar.onModeChanged = { [weak self] index in
            guard let self = self else { return }

            self.currentModeIndex = index
            self.cinematicMode = (index == 2)

            self.hardResetMotionState(resetAI: true, resetManual: true, recenterStage: true)
            self.applyResolvedLensPresetStack()

            self.smoothedManualDx = 0
            self.smoothedManualDy = 0
            self.smoothedAIDx = 0
            self.smoothedAIDy = 0
            self.currentStageOffset = .zero
            self.lastAppliedDx = 0
            self.lastAppliedDy = 0

            // HINGE FIX
            self.motionService.reset()
            self.proMotionCoordinator.reset()

            self.setStageOffset(x: 0, y: 0, updateDebugNow: false)
        }

        controlBar.onLensModeChanged = { [weak self] index in
            guard let self = self else { return }
            guard let lens = HKV1_PlayerLayerView.LensMode(rawValue: index) else { return }

            self.playerView.lensMode = lens
            self.hardResetMotionState(resetAI: true, resetManual: true, recenterStage: true)
            self.applyResolvedLensPresetStack()
        }

        controlBar.onExportModeChanged = { [weak self] index in
            guard let self = self else { return }
            switch index {
            case 1: self.exportPreset = .balanced
            case 2: self.exportPreset = .ultra
            case 3: self.exportPreset = .aggressive
            default: self.exportPreset = .off
            }
            self.updateDepthStatusChip()
            self.refreshDepthCompositeIfNeeded(force: true)
            self.syncControlBarState()
        }
       
        controlBar.onLUTChanged = { [weak self] index in
            guard let self = self else { return }
            guard let mode = HKV1_PlayerLayerView.LUTMode(rawValue: index) else { return }

            self.playerView.setLUTMode(mode)
            self.refreshDepthCompositeIfNeeded(force: true)
            self.syncControlBarState()
        }

        controlBar.onDepthIntensityChanged = { [weak self] value in
            guard let self = self else { return }
            self.playerView.depthIntensity = CGFloat(value)
            self.pendingUIUpdate?.cancel()
            let work = DispatchWorkItem { [weak self] in
                self?.refreshDepthCompositeIfNeeded(force: true)
            }
            self.pendingUIUpdate = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: work)
        }

        controlBar.onFocusFalloffChanged = { [weak self] value in
            guard let self = self else { return }
            self.playerView.focusFalloff = CGFloat(value)
            self.pendingUIUpdate?.cancel()
            let work = DispatchWorkItem { [weak self] in
                self?.refreshDepthCompositeIfNeeded(force: true)
            }
            self.pendingUIUpdate = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: work)
        }

        controlBar.onBGPlaneControlChanged = { [weak self] value in
            guard let self = self else { return }
            self.playerView.bgPlaneControl = CGFloat(value)
            self.pendingUIUpdate?.cancel()
            let work = DispatchWorkItem { [weak self] in
                self?.refreshDepthCompositeIfNeeded(force: true)
            }
            self.pendingUIUpdate = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: work)
        }

        controlBar.onMIDPlaneControlChanged = { [weak self] value in
            guard let self = self else { return }
            self.playerView.midPlaneControl = CGFloat(value)
            self.pendingUIUpdate?.cancel()
            let work = DispatchWorkItem { [weak self] in
                self?.refreshDepthCompositeIfNeeded(force: true)
            }
            self.pendingUIUpdate = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: work)
        }

        controlBar.onFGPlaneControlChanged = { [weak self] value in
            guard let self = self else { return }
            self.playerView.fgPlaneControl = CGFloat(value)
            self.pendingUIUpdate?.cancel()
            let work = DispatchWorkItem { [weak self] in
                self?.refreshDepthCompositeIfNeeded(force: true)
            }
            self.pendingUIUpdate = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: work)
        }

        controlBar.onFramingScaleChanged = { [weak self] value in
            guard let self = self else { return }
            self.framingScale = self.clamp(CGFloat(value), min: 0.86, max: 1.18)

            // Fast path: geometry first so SPACE feels immediate.
            self.layoutStageAndMask()

            // Unified render-loop assist: defer expensive depth/UI work until drag settles.
            self.pendingUIUpdate?.cancel()
            let work = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                self.refreshDepthCompositeIfNeeded(force: true)
                self.syncControlBarState()
            }
            self.pendingUIUpdate = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08, execute: work)
        }

        controlBar.onLoadVideo = { [weak self] in
            self?.presentPhotoPicker()
        }

        controlBar.onLoadFile = { [weak self] in
            self?.presentDocumentPicker()
        }

        controlBar.onScrubBegan = { [weak self] in
            guard let self = self else { return }
            self.beginChromeInteraction()
            self.isScrubbing = true
            self.cancelControlBarAutoHide()
            self.updatePlaybackDepthPolicy()
            self.refreshDepthCompositeIfNeeded(force: true)
        }

        controlBar.onScrubChanged = { [weak self] progress in
            guard let self = self else { return }
            let duration = self.playbackController.durationSeconds
            guard duration > 0 else { return }

            let targetSeconds = Double(progress) * duration
            self.playbackController.seek(to: targetSeconds)
            self.refreshDepthCompositeIfNeeded(force: true)
        }
        
        controlBar.onScrubEnded = { [weak self] progress in
            guard let self = self else { return }
            self.isScrubbing = false
            let duration = self.playbackController.durationSeconds

            guard duration > 0 else {
                self.updatePlaybackDepthPolicy()
                self.endChromeInteraction()
                return
            }

            let targetSeconds = Double(progress) * duration
            self.playbackController.preciseSeek(to: targetSeconds) { [weak self] _ in
                guard let self = self else { return }
                self.refreshDepthCompositeIfNeeded(force: true)
                self.updatePlaybackDepthPolicy()
                self.endChromeInteraction()
            }
        }

        controlBar.setDepthIntensity(Float(playerView.depthIntensity))
        controlBar.setFocusFalloff(Float(playerView.focusFalloff))
        controlBar.setBGPlaneControl(Float(playerView.bgPlaneControl))
        controlBar.setMIDPlaneControl(Float(playerView.midPlaneControl))
        controlBar.setFGPlaneControl(Float(playerView.fgPlaneControl))
        controlBar.setFramingScale(Float(framingScale))
        controlBar.setLensMode(playerView.lensMode.rawValue)
        controlBar.setLUTPreset(playerView.lutMode.rawValue)
        controlBar.setVolume(playbackController.player.volume)
    }
    
    private func exportCurrentVideo() {
        guard currentVideoURL != nil else { return }

        showClipLoadStatus("PREPARING EXPORT…")
        showLoadingOverlay(
            title: "Preparing Export",
            subtitle: "Building your cinematic file…"
        )

        prepareExportableVideoFile { [weak self] preparedURL in
            guard let self = self else { return }

            self.hideLoadingOverlay()

            guard let preparedURL else {
                self.showClipLoadStatus("EXPORT FAILED")
                return
            }

            self.showClipLoadStatus("EXPORT READY")

            let activity = UIActivityViewController(
                activityItems: [preparedURL],
                applicationActivities: nil
            )

            activity.excludedActivityTypes = [
                .assignToContact,
                .addToReadingList
            ]

            DispatchQueue.main.async {
                self.present(activity, animated: true)
            }
        }
    }

    private func prepareExportableVideoFile(completion: @escaping (URL?) -> Void) {
        guard let sourceURL = currentVideoURL else {
            completion(nil)
            return
        }

        let asset = AVAsset(url: sourceURL)

        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("HK_export_\(UUID().uuidString).mov")

        try? FileManager.default.removeItem(at: outputURL)

        guard let session = AVAssetExportSession(
            asset: asset,
            presetName: AVAssetExportPresetPassthrough
        ) else {
            completion(nil)
            return
        }

        session.outputURL = outputURL
        session.outputFileType = .mov
        session.shouldOptimizeForNetworkUse = true
        session.timeRange = CMTimeRange(start: .zero, duration: asset.duration)

        exportProgressTimer?.invalidate()
        exportProgressTimer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { [weak self, weak session] timer in
            guard let self = self, let session = session else {
                timer.invalidate()
                return
            }

            self.updateLoadingProgress(
                session.progress,
                subtitle: "Exporting your cinematic file…"
            )

            if session.status != .exporting && session.status != .waiting {
                timer.invalidate()
            }
        }

        DispatchQueue.global(qos: .userInitiated).async {
            session.exportAsynchronously {
                DispatchQueue.main.async {
                    self.exportProgressTimer?.invalidate()
                    self.exportProgressTimer = nil

                    if session.status == .completed {
                        self.updateLoadingProgress(1.0, subtitle: "Export complete.")
                        completion(outputURL)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
    private func resetAIEliteState() {
        aiChosenWinnerStableID = nil
        aiPendingSwitchStableID = nil
        aiPendingSwitchFrames = 0
        aiPendingSwitchScore = 0
        thirdsBiasX = 0
        previousAISubjectCenterX = nil
        smoothedAISubjectVelocityX = 0
        aiDriverResolvedRect = nil
        aiAutopilotDriver.reset()
        aiPreviousWinnerWasPrimary = false
        aiTemporalFrameIndex = 0
        aiLastCommittedSwitchFrame = -1000
        aiReactionWindowUntilFrame = 0
        aiLastSpeakerStableID = nil

        aiCurrentCameraID = "CAM_A"
        aiDirectorDebugReason = "reset"

        aiSubjectOffset = .zero
        aiSmoothedSubjectOffset = .zero
        aiLockConfidence = 0.0

        subjectIdentityManager.reset()
        temporalDecisionEngine.resetAll()

        aiLastCenterXByStableID.removeAll()
        aiVelocityXByStableID.removeAll()
        aiLastSeenFrameByStableID.removeAll()

        aiSpeakingScoreByStableID.removeAll()
        aiAudioScoreByStableID.removeAll()
        aiEyeContactScoreByStableID.removeAll()
        aiCurrentShotClass = .medium

        speakerDetectionEngine.reset()
        audioSpeakerDetectionEngine.reset()
        eyeContactAnalyzer.reset()
        reactionDirector.reset()
        editorialRhythmEngine.reset()
        directorPolicy.setStyle(.cinematic)
        vibeEngine.reset()
    }
    
    private func hardResetMotionState(
        resetAI: Bool = true,
        resetManual: Bool = true,
        recenterStage: Bool = true
    ) {
        if resetManual {
            smoothedManualDx = 0
            smoothedManualDy = 0
        }

        if resetAI {
            smoothedAIDx = 0
            smoothedAIDy = 0
            resetAIEliteState()
        }

        if recenterStage {
            currentStageOffset = .zero
            setStageOffset(x: 0, y: 0, updateDebugNow: false)
        }

        lastAppliedDx = 0
        lastAppliedDy = 0

        motionService.reset()
        proMotionCoordinator.reset()
        temporalDepth.reset()
    }
    private func activateAIMode() {
        isAIEnabled = true

        // Tilt is fully disabled in AI mode.
        isTiltEnabled = false

        // Peek remains user-available in AI mode if the user had it enabled.
        isPeekEnabled = manualPeekPreference

        // AI has no motion-lane authority.
        aiTiltAssistEnabled = false
        aiPeekAssistEnabled = false

        smoothedManualDx = 0
        smoothedManualDy = 0
        smoothedAIDx = 0
        smoothedAIDy = 0

        resetAIEliteState()
        hardResetMotionState(resetAI: true, resetManual: true, recenterStage: true)
        refreshDepthCompositeIfNeeded(force: true)
    }
    
    private func activateManualMode(tilt: Bool, peek: Bool) {
        manualTiltPreference = tilt
        manualPeekPreference = peek
        isAIEnabled = false
        isTiltEnabled = tilt
        isPeekEnabled = peek
        aiTiltAssistEnabled = false
        aiPeekAssistEnabled = false
        cinematicMode = (currentModeIndex == 2)

        smoothedManualDx = 0
        smoothedManualDy = 0
        smoothedAIDx = 0
        smoothedAIDy = 0

        hardResetMotionState(resetAI: true, resetManual: true, recenterStage: true)
        applyResolvedLensPresetStack(forceDepthRefresh: true)
    }

    private func activateIdleMode() {
        manualTiltPreference = false
        manualPeekPreference = false
        isAIEnabled = false
        isTiltEnabled = false
        isPeekEnabled = false
        aiTiltAssistEnabled = false
        aiPeekAssistEnabled = false

        smoothedManualDx = 0
        smoothedManualDy = 0
        smoothedAIDx = 0
        smoothedAIDy = 0

        hardResetMotionState(resetAI: true, resetManual: true, recenterStage: true)
        refreshDepthCompositeIfNeeded(force: true)
    }

    private func dynamicAILostTrackGraceFrames() -> Int {
        if aiFrameBrightness < 0.32 { return aiLostTrackGraceFrames + 10 }
        if aiFrameBrightness < 0.42 { return aiLostTrackGraceFrames + 6 }
        if aiFrameBrightness < 0.52 { return aiLostTrackGraceFrames + 3 }
        return aiLostTrackGraceFrames
    }

    private func makeAIFrameGenerator(for url: URL) -> AVAssetImageGenerator {
        let generator = AVAssetImageGenerator(asset: AVAsset(url: url))
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 960, height: 960)
        generator.requestedTimeToleranceBefore = CMTime(seconds: 0.04, preferredTimescale: 600)
        generator.requestedTimeToleranceAfter = CMTime(seconds: 0.04, preferredTimescale: 600)
        return generator
    }

    // MARK: - Chrome Behavior

    private func beginChromeInteraction() {
        chromeInteractionLocks += 1
        cancelControlBarAutoHide()
        showControlBar(animated: true, scheduleHide: false)
    }

    private func endChromeInteraction() {
        chromeInteractionLocks = max(0, chromeInteractionLocks - 1)
        scheduleControlBarAutoHideIfAllowed()
    }

    private var canAutoHideChrome: Bool {
        playbackController.isPlaying() &&
        !isScrubbing &&
        chromeInteractionLocks == 0 &&
        !controlBar.isPinnedOpen()
    }

    private func showControlBar(animated: Bool = true, scheduleHide: Bool = true) {
        cancelControlBarAutoHide()
        isControlBarVisible = true

        let debugUpdates = {
            self.debugLabel.alpha = 1.0
        }

        if animated {
            UIView.animate(
                withDuration: 0.22,
                delay: 0,
                options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction],
                animations: {
                    self.controlBar.setChromeVisible(true, animated: false)
                    debugUpdates()
                }
            )
        } else {
            controlBar.setChromeVisible(true, animated: false)
            debugUpdates()
        }

        if scheduleHide {
            scheduleControlBarAutoHideIfAllowed()
        }
    }

    private func hideControlBar(animated: Bool = true) {
        guard canAutoHideChrome else { return }

        cancelControlBarAutoHide()
        isControlBarVisible = false

        let debugUpdates = {
            self.debugLabel.alpha = 0.0
        }

        if animated {
            UIView.animate(
                withDuration: 0.28,
                delay: 0,
                options: [.beginFromCurrentState, .curveEaseInOut, .allowUserInteraction],
                animations: {
                    self.controlBar.setChromeVisible(false, animated: false)
                    debugUpdates()
                }
            )
        } else {
            controlBar.setChromeVisible(false, animated: false)
            debugUpdates()
        }
    }

    private func updatePerSubjectMotion(for subjects: [HKV1_SubjectIdentityManager.ResolvedSubject]) {
        for subject in subjects {
            let id = subject.stableID
            let centerX = subject.boundingBox.midX

            let rawVelocity: CGFloat
            if let previousX = aiLastCenterXByStableID[id] {
                rawVelocity = centerX - previousX
            } else {
                rawVelocity = 0
            }

            let previousSmoothed = aiVelocityXByStableID[id] ?? 0
            let smoothed = previousSmoothed + ((rawVelocity - previousSmoothed) * 0.34)

            aiLastCenterXByStableID[id] = centerX
            aiVelocityXByStableID[id] = smoothed
            aiLastSeenFrameByStableID[id] = aiTemporalFrameIndex
        }

        let cutoff = aiTemporalFrameIndex - 18
        aiLastSeenFrameByStableID = aiLastSeenFrameByStableID.filter { $0.value >= cutoff }
        aiLastCenterXByStableID = aiLastCenterXByStableID.filter { aiLastSeenFrameByStableID[$0.key] != nil }
        aiVelocityXByStableID = aiVelocityXByStableID.filter { aiLastSeenFrameByStableID[$0.key] != nil }
    }

    private func cancelControlBarAutoHide() {
        controlBarHideWorkItem?.cancel()
        controlBarHideWorkItem = nil
    }

    private func scheduleControlBarAutoHideIfAllowed() {
        cancelControlBarAutoHide()

        guard canAutoHideChrome else {
            if controlBar.isPinnedOpen() || chromeInteractionLocks > 0 || !playbackController.isPlaying() {
                showControlBar(animated: true, scheduleHide: false)
            }
            return
        }

        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.hideControlBar(animated: true)
        }

        controlBarHideWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + controlBarAutoHideDelay, execute: workItem)
    }

    private func updateDepthStatusChip() {
        let exportIndex: Int
        switch exportPreset {
        case .off: exportIndex = 0
        case .balanced: exportIndex = 1
        case .ultra: exportIndex = 2
        case .aggressive: exportIndex = 3
        }

        controlBar.setExportMode(exportIndex)

        if isPreparingDepth {
            controlBar.setDepthRenderProgress(depthGenerationProgress)
            controlBar.setStatusChipText(nil)
        } else {
            controlBar.setDepthRenderProgress(nil)
            controlBar.setStatusChipText(nil)
        }
    }

    private func syncControlBarState() {
        // In AI mode, Tilt / Peek act as assist toggles and should reflect live assist state.
        let liveTiltOn = isAIEnabled ? false : isTiltEnabled
        let livePeekOn = isPeekEnabled

        controlBar.setInitial(
            depthOn: isDepthPreviewEnabled,
            aiOn: isAIEnabled,
            tiltOn: liveTiltOn,
            peekOn: livePeekOn,
            modeIndex: currentModeIndex
        )

        controlBar.setDepthIntensity(Float(playerView.depthIntensity))
        controlBar.setFocusFalloff(Float(playerView.focusFalloff))
        controlBar.setBGPlaneControl(Float(playerView.bgPlaneControl))
        controlBar.setMIDPlaneControl(Float(playerView.midPlaneControl))
        controlBar.setFGPlaneControl(Float(playerView.fgPlaneControl))
        controlBar.setFramingScale(Float(framingScale))
        controlBar.setLensMode(playerView.lensMode.rawValue)
        controlBar.setLUTPreset(playerView.lutMode.rawValue)
        controlBar.setPlaying(playbackController.isPlaying())
        controlBar.setVolume(playbackController.player.volume)
        updateDepthStatusChip()

        if controlBar.isPinnedOpen() || chromeInteractionLocks > 0 {
            showControlBar(animated: true, scheduleHide: false)
        } else if playbackController.isPlaying() {
            scheduleControlBarAutoHideIfAllowed()
        } else {
            showControlBar(animated: true, scheduleHide: false)
        }
    }

    // MARK: - Playback
   
    private func setupLoadingOverlay() {
        loadingOverlay.translatesAutoresizingMaskIntoConstraints = false
        loadingCard.translatesAutoresizingMaskIntoConstraints = false
        loadingTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingProgressView.translatesAutoresizingMaskIntoConstraints = false
        loadingPercentLabel.translatesAutoresizingMaskIntoConstraints = false

        loadingOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.48)
        loadingOverlay.alpha = 0.0
        loadingOverlay.isHidden = true

        loadingCard.layer.cornerRadius = 24
        loadingCard.clipsToBounds = true
        loadingCard.layer.borderWidth = 1
        loadingCard.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor

        loadingTitleLabel.textColor = .white
        loadingTitleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        loadingTitleLabel.textAlignment = .center
        loadingTitleLabel.text = "Preparing Export"

        loadingSubtitleLabel.textColor = UIColor.white.withAlphaComponent(0.72)
        loadingSubtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        loadingSubtitleLabel.textAlignment = .center
        loadingSubtitleLabel.numberOfLines = 0
        loadingSubtitleLabel.text = "Building your cinematic file…"

        loadingProgressView.progressTintColor = UIColor.systemRed
        loadingProgressView.trackTintColor = UIColor.white.withAlphaComponent(0.10)
        loadingProgressView.progress = 0.0
        loadingProgressView.transform = CGAffineTransform(scaleX: 1, y: 1.6)

        loadingPercentLabel.textColor = UIColor.white
        loadingPercentLabel.font = .monospacedDigitSystemFont(ofSize: 14, weight: .bold)
        loadingPercentLabel.textAlignment = .center
        loadingPercentLabel.text = "0%"

        view.addSubview(loadingOverlay)
        loadingOverlay.addSubview(loadingCard)
        loadingCard.contentView.addSubview(loadingTitleLabel)
        loadingCard.contentView.addSubview(loadingSubtitleLabel)
        loadingCard.contentView.addSubview(loadingProgressView)
        loadingCard.contentView.addSubview(loadingPercentLabel)

        NSLayoutConstraint.activate([
            loadingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingCard.centerXAnchor.constraint(equalTo: loadingOverlay.centerXAnchor),
            loadingCard.centerYAnchor.constraint(equalTo: loadingOverlay.centerYAnchor),
            loadingCard.leadingAnchor.constraint(equalTo: loadingOverlay.leadingAnchor, constant: 28),
            loadingCard.trailingAnchor.constraint(equalTo: loadingOverlay.trailingAnchor, constant: -28),

            loadingTitleLabel.topAnchor.constraint(equalTo: loadingCard.contentView.topAnchor, constant: 26),
            loadingTitleLabel.leadingAnchor.constraint(equalTo: loadingCard.contentView.leadingAnchor, constant: 20),
            loadingTitleLabel.trailingAnchor.constraint(equalTo: loadingCard.contentView.trailingAnchor, constant: -20),

            loadingSubtitleLabel.topAnchor.constraint(equalTo: loadingTitleLabel.bottomAnchor, constant: 10),
            loadingSubtitleLabel.leadingAnchor.constraint(equalTo: loadingCard.contentView.leadingAnchor, constant: 20),
            loadingSubtitleLabel.trailingAnchor.constraint(equalTo: loadingCard.contentView.trailingAnchor, constant: -20),

            loadingProgressView.topAnchor.constraint(equalTo: loadingSubtitleLabel.bottomAnchor, constant: 22),
            loadingProgressView.leadingAnchor.constraint(equalTo: loadingCard.contentView.leadingAnchor, constant: 20),
            loadingProgressView.trailingAnchor.constraint(equalTo: loadingCard.contentView.trailingAnchor, constant: -20),

            loadingPercentLabel.topAnchor.constraint(equalTo: loadingProgressView.bottomAnchor, constant: 14),
            loadingPercentLabel.leadingAnchor.constraint(equalTo: loadingCard.contentView.leadingAnchor, constant: 20),
            loadingPercentLabel.trailingAnchor.constraint(equalTo: loadingCard.contentView.trailingAnchor, constant: -20),
            loadingPercentLabel.bottomAnchor.constraint(equalTo: loadingCard.contentView.bottomAnchor, constant: -24)
        ])
    }
  
    private func showLoadingOverlay(title: String, subtitle: String) {
        loadingTitleLabel.text = title
        loadingSubtitleLabel.text = subtitle
        loadingProgressView.progress = 0.0
        loadingPercentLabel.text = "0%"

        loadingOverlay.isHidden = false
        UIView.animate(withDuration: 0.22) {
            self.loadingOverlay.alpha = 1.0
        }
    }

    private func hideLoadingOverlay() {
        exportProgressTimer?.invalidate()
        exportProgressTimer = nil

        UIView.animate(withDuration: 0.22, animations: {
            self.loadingOverlay.alpha = 0.0
        }) { _ in
            self.loadingOverlay.isHidden = true
        }
    }

    private func updateLoadingProgress(_ progress: Float, subtitle: String? = nil) {
        let clamped = max(0.0, min(1.0, progress))
        loadingProgressView.setProgress(clamped, animated: true)
        loadingPercentLabel.text = "\(Int((clamped * 100).rounded()))%"

        if let subtitle {
            loadingSubtitleLabel.text = subtitle
        }
    }

    private func wirePlayback() {
        playerView.setPlayer(playbackController.player)
        playerView.setRenderMode(.flat)
        playerView.setSpatialMode(.flat)
        // 🔥 SEAM SAFE DEFAULT (ALWAYS ON)
        playerView.seamSafeModeEnabled = true
        playerView.aiModeActive = false
        livePlaybackEngine.attach(to: playbackController.player)
        playerAudioTap.attach(to: playbackController.player)
        updatePlaybackDepthPolicy()
    }

    private func wireGestures() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleTapToggle))
        singleTap.cancelsTouchesInView = false
        view.addGestureRecognizer(singleTap)

    }

    @objc
    private func handleOpenLibraryButton() {
        goToLibrary()
    }

    @objc
    private func handleTapToggle() {
        if isControlBarVisible {
            hideControlBar(animated: true)
        } else {
            showControlBar(animated: true, scheduleHide: true)
        }
    }

    private func togglePlayPause() {
        let wasPlaying = playbackController.isPlaying()
        playbackController.togglePlayPause()

        if wasPlaying {
            updatePlaybackDepthPolicy()
            refreshDepthCompositeIfNeeded(force: true)
            showControlBar(animated: true, scheduleHide: false)
        } else {
            refreshDepthCompositeIfNeeded(force: true)
            updatePlaybackDepthPolicy()
            scheduleControlBarAutoHideIfAllowed()
        }

        controlBar.setPlaying(playbackController.isPlaying())
    }


    private func loadInitialPlaybackRoute() {
        if let movie = selectedMovie, let url = bundledURL(for: movie) {
            loadVideo(url: url)
            return
        }

        if let introURL = bundledIntroURL() {
            loadVideo(url: introURL)
            return
        }

        loadBundledVideoAndPlay()
    }

    private func bundledIntroURL() -> URL? {
        if let exact = Bundle.main.url(forResource: defaultIntroVideoName, withExtension: "mp4")
            ?? Bundle.main.url(forResource: defaultIntroVideoName, withExtension: "mov")
            ?? Bundle.main.url(forResource: defaultIntroVideoName, withExtension: "m4v") {
            return exact
        }

        let fm = FileManager.default
        let validExtensions = Set(["mov", "mp4", "m4v"])

        func matchesIntroName(_ url: URL) -> Bool {
            let ext = url.pathExtension.lowercased()
            guard validExtensions.contains(ext) else { return false }
            let stem = url.deletingPathExtension().lastPathComponent
            return stem.caseInsensitiveCompare(defaultIntroVideoName) == .orderedSame
        }

        if let resourceURL = Bundle.main.resourceURL,
           let urls = try? fm.contentsOfDirectory(
                at: resourceURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
           ),
           let match = urls.first(where: matchesIntroName) {
            return match
        }

        if let trainingClipsURL = Bundle.main.resourceURL?.appendingPathComponent("HKTrainingClips"),
           let urls = try? fm.contentsOfDirectory(
                at: trainingClipsURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
           ),
           let match = urls.first(where: matchesIntroName) {
            return match
        }

        return nil
    }

    private func bundledURL(for movie: HKCMovie) -> URL? {
        guard let videoName = movie.bundledVideoName, !videoName.isEmpty else {
            return nil
        }

        if let exact = Bundle.main.url(forResource: videoName, withExtension: "mp4")
            ?? Bundle.main.url(forResource: videoName, withExtension: "mov")
            ?? Bundle.main.url(forResource: videoName, withExtension: "m4v") {
            return exact
        }

        let fm = FileManager.default
        let validExtensions = Set(["mov", "mp4", "m4v"])

        func matchesVideoName(_ url: URL) -> Bool {
            let ext = url.pathExtension.lowercased()
            guard validExtensions.contains(ext) else { return false }

            let stem = url.deletingPathExtension().lastPathComponent
            return stem.caseInsensitiveCompare(videoName) == .orderedSame
        }

        if let trainingClipsURL = Bundle.main.resourceURL?.appendingPathComponent("HKTrainingClips"),
           let urls = try? fm.contentsOfDirectory(
                at: trainingClipsURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
           ),
           let match = urls.first(where: matchesVideoName) {
            return match
        }

        if let resourceURL = Bundle.main.resourceURL,
           let urls = try? fm.contentsOfDirectory(
                at: resourceURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
           ),
           let match = urls.first(where: matchesVideoName) {
            return match
        }

        return nil
    }

    private func loadBundledVideoAndPlay() {
        if let preferredPair = HKV1_TrainingClipLocator.resolvePreferredTrainingClipPair() {
            loadVideo(url: preferredPair.videoURL)
            return
        }

        guard let url = firstBundledVideoURL() else {
            debugLabel.text = "No bundled video found.\nAdd HKTrainingClip_latest.mp4 and HKTrainingClip_latest.depth.mp4 to Documents or include a bundled .mov, .mp4, or .m4v."
            debugLabel.isHidden = false
            syncControlBarState()
            return
        }

        loadVideo(url: url)
    }

    private func loadVideo(url: URL) {
        showClipLoadStatus("OPENING CLIP…")
        currentVideoURL = url
        hasExitedToLibrary = false
        aiFrameGenerator = makeAIFrameGenerator(for: url)
        aiTraceLogger.endSession()
        aiTraceLogger.beginSession(clipName: url.lastPathComponent)
        activeDepthGenerationID = UUID()
        currentContentProfile = .general
        playerView.lensMode = .anamorphic
        playerView.setLUTMode(.off)
        currentModeIndex = 1
        framingScale = 0.86
        cinematicMode = false
        applyResolvedLensPresetStack(forceDepthRefresh: false)
        currentSceneAnalysis = nil
        hasLoadedDepthSidecar = false
        loadedDepthFileName = "NONE"

        hardResetMotionState(resetAI: true, resetManual: true, recenterStage: true)

        playbackController.load(url: url)
        livePlaybackEngine.refreshAttachmentIfNeeded()
        playerAudioTap.refreshAttachmentIfNeeded()
        playerView.clearDepthMasks()
        playerView.setRenderMode(.flat)
        playerView.setSpatialMode(.flat)
        controlBar.setPlaying(true)
        playbackController.play()
        updatePlaybackDepthPolicy()
        analyzeContentAndApplyPreset(for: url)
        installLoopObserver(for: playbackController.player.currentItem)

        cachedDepthImage = nil
        lastResolvedDepthImage = nil
        lastDepthRefreshTime = 0
        lastDepthVideoSeconds = -999.0
        isPreparingDepth = false
        depthGenerationProgress = 0.0
        updateDepthStatusChip()

        let hasDepthSidecar = loadDepthSidecarIfAvailable(for: url)
        refreshDepthCompositeIfNeeded(force: true)

        if hasDepthSidecar {
            playbackController.play()
            updatePlaybackDepthPolicy()
            controlBar.setPlaying(true)
            scheduleControlBarAutoHideIfAllowed()
            return
        }

        prepareDepthForVideoIfNeeded(url)
    }
    
    private func installLoopObserver(for item: AVPlayerItem?) {
        if let observer = playbackEndedObserver {
            NotificationCenter.default.removeObserver(observer)
            playbackEndedObserver = nil
        }

        guard let item else { return }

        playbackEndedObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            self?.goToLibrary()
        }
    }
    
    private func goToLibrary() {
        guard !hasExitedToLibrary else { return }
        hasExitedToLibrary = true

        playbackController.pause()
        controlBar.setPlaying(false)

        guard let windowScene = view.window?.windowScene else {
            let libraryVC = HKC_LIBRARYViewController()
            let nav = UINavigationController(rootViewController: libraryVC)
            nav.setNavigationBarHidden(true, animated: false)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
            return
        }

        let window = UIWindow(windowScene: windowScene)
        let libraryVC = HKC_LIBRARYViewController()
        let nav = UINavigationController(rootViewController: libraryVC)
        nav.setNavigationBarHidden(true, animated: false)

        window.rootViewController = nav
        window.makeKeyAndVisible()

        if let sceneDelegate = windowScene.delegate as? HKV1_SceneDelegate {
            sceneDelegate.window = window
        }
    }

    private func firstBundledVideoURL() -> URL? {
        if let introURL = bundledIntroURL() {
            return introURL
        }

        if let preferredPair = HKV1_TrainingClipLocator.resolvePreferredTrainingClipPair() {
            return preferredPair.videoURL
        }

        let fm = FileManager.default
        let validExtensions = Set(["mov", "mp4", "m4v"])

        func isPlayableMainVideo(_ url: URL) -> Bool {
            let ext = url.pathExtension.lowercased()
            guard validExtensions.contains(ext) else { return false }

            let name = url.deletingPathExtension().lastPathComponent.lowercased()
            return !name.contains(".depth")
                && !name.contains("_depth")
                && name != "paranormal_e1"
                && name != "paranormal_e2"
                && name != "paranormal_e3"
                && name != "paranormal_e4"
                && name != "paranormal_e5"
                && name != "paranormal_e6"
                && name != "paranormal_e7"
                && name != "paranormall_e1"
                && name != "paranormall_e2"
                && name != "paranormall_e3"
                && name != "paranormall_e4"
                && name != "paranormall_e5"
                && name != "paranormall_e6"
                && name != "paranormall_e7"
        }

        if let trainingClipsURL = Bundle.main.resourceURL?.appendingPathComponent("HKTrainingClips"),
           let urls = try? fm.contentsOfDirectory(
                at: trainingClipsURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
           ),
           let match = urls.first(where: { isPlayableMainVideo($0) }) {
            return match
        }

        if let resourceURL = Bundle.main.resourceURL,
           let urls = try? fm.contentsOfDirectory(
                at: resourceURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
           ),
           let match = urls.first(where: { isPlayableMainVideo($0) }) {
            return match
        }

        return nil
    }

    @discardableResult
    private func loadDepthSidecarIfAvailable(for videoURL: URL) -> Bool {
        depthSidecar.resetCache()

        cachedDepthImage = nil
        lastResolvedDepthImage = nil
        lastDepthRefreshTime = 0
        lastDepthVideoSeconds = -999.0

        if let preferredPair = HKV1_TrainingClipLocator.resolvePreferredTrainingClipPair(),
           preferredPair.videoURL.lastPathComponent == videoURL.lastPathComponent,
           let preferredDepthURL = preferredPair.depthURL {
            depthSidecar.load(url: preferredDepthURL)
            hasLoadedDepthSidecar = true
            loadedDepthFileName = preferredDepthURL.lastPathComponent
        } else {
            hasLoadedDepthSidecar = depthSidecar.loadPairedDepthVideo(forVideoURL: videoURL)
            loadedDepthFileName = depthSidecar.loadedFileName() ?? "NONE"
        }

        if !hasLoadedDepthSidecar {
            playerView.clearDepthMasks()
            playerView.setRenderMode(.flat)
            playerView.setSpatialMode(.flat)
        }

        updatePlaybackDepthPolicy()
        syncControlBarState()
        return hasLoadedDepthSidecar
    }

    private func prepareDepthForVideoIfNeeded(_ videoURL: URL) {
        let generationID = activeDepthGenerationID
        isPreparingDepth = true
        depthGenerationProgress = 0.0
        updateDepthStatusChip()

        // Show the clip immediately. Depth generation continues in the background.
        playerView.clearDepthMasks()
        playerView.setRenderMode(.flat)
        playerView.setSpatialMode(.flat)
        playbackController.play()
        updatePlaybackDepthPolicy()
        controlBar.setPlaying(true)
        showControlBar(animated: true, scheduleHide: false)
        refreshDebugUI(force: true)

        depthGenerator.generateDepthSidecarIfNeeded(
            for: videoURL,
            progress: { [weak self] progress in
                guard let self = self, self.activeDepthGenerationID == generationID else { return }
                self.isPreparingDepth = true
                self.depthGenerationProgress = progress
                self.updateDepthStatusChip()
                self.showControlBar(animated: true, scheduleHide: false)
                self.refreshDebugUI(force: true)
            },
            completion: { [weak self] result in
                guard let self = self, self.activeDepthGenerationID == generationID else { return }

                self.isPreparingDepth = false
                self.updateDepthStatusChip()

                switch result {
                case .success(let depthURL):
                    self.depthGenerationProgress = 1.0
                    self.depthSidecar.load(url: depthURL)
                    self.hasLoadedDepthSidecar = true
                    self.loadedDepthFileName = depthURL.lastPathComponent
                    self.refreshDepthCompositeIfNeeded(force: true)
                    self.updatePlaybackDepthPolicy()
                    self.controlBar.setPlaying(true)
                    self.showControlBar(animated: true, scheduleHide: false)
                    self.scheduleControlBarAutoHideIfAllowed()

                case .failure:
                    self.depthGenerationProgress = 0.0
                    self.hasLoadedDepthSidecar = false
                    self.loadedDepthFileName = "NONE"
                    self.playerView.clearDepthMasks()
                    self.playerView.setRenderMode(.flat)
                    self.playerView.setSpatialMode(.flat)
                    self.updatePlaybackDepthPolicy()
                    self.controlBar.setPlaying(true)
                    self.showControlBar(animated: true, scheduleHide: false)
                }

                self.syncControlBarState()
                self.refreshDebugUI(force: true)
            }
        )
    }

    private func updatePlaybackDepthPolicy() {
        let suspend = playbackController.isPlaying() && !isScrubbing
        playerView.setDepthMaskRebuildSuspended(suspend)
    }

    // MARK: - Layout

    private func layoutStageAndMask() {
        let bounds = view.bounds
        guard bounds.width > 0, bounds.height > 0 else { return }

        let isPortrait = bounds.height >= bounds.width
        let maskFrame = bounds.integral

        maskWindowView.frame = maskFrame

        let stageSize = computeStageSize(for: maskFrame.size, isPortrait: isPortrait)
        stageView.bounds = CGRect(origin: .zero, size: stageSize)

        maxTravelX = max(0, (stageSize.width - maskFrame.width) * 0.5)
        maxTravelY = max(0, (stageSize.height - maskFrame.height) * 0.5)

        currentStageOffset.x = clamp(currentStageOffset.x, min: -maxTravelX, max: maxTravelX)
        currentStageOffset.y = clamp(currentStageOffset.y, min: -maxTravelY, max: maxTravelY)

        stageView.center = CGPoint(
            x: maskWindowView.bounds.midX + currentStageOffset.x,
            y: maskWindowView.bounds.midY + currentStageOffset.y
        )

        playerView.frame = stageView.bounds
        updatePlaneOffsetsOnly()
        refreshDebugUI(force: true)
    }

    private func computeStageSize(for maskSize: CGSize, isPortrait: Bool) -> CGSize {
        let safeFramingScale = clamp(framingScale, min: 0.86, max: 1.18)

        if isPortrait {
            let stageHeight = maskSize.height * max(1.02, portraitStageOverscanScale * safeFramingScale)
            let stageWidth = stageHeight * (16.0 / 9.0)
            return CGSize(width: stageWidth, height: stageHeight)
        } else {
            let stageWidth = maskSize.width * max(1.02, landscapeStageOverscanScale * safeFramingScale)
            let stageHeight = stageWidth * (9.0 / 16.0)

            if stageHeight < maskSize.height {
                let correctedHeight = maskSize.height * max(1.02, landscapeStageOverscanScale * safeFramingScale)
                let correctedWidth = correctedHeight * (16.0 / 9.0)
                return CGSize(width: correctedWidth, height: correctedHeight)
            }

            return CGSize(width: stageWidth, height: stageHeight)
        }
    }

    // MARK: - Motion
    
    private func amplifiedDepthOffset(rawX: CGFloat, rawY: CGFloat) -> CGPoint {
        guard isDepthPreviewEnabled else {
            return CGPoint(x: rawX, y: rawY)
        }

        let multiplier = currentDepthAmplificationMultiplier()

        return CGPoint(
            x: rawX * multiplier,
            y: rawY * multiplier
        )
    }
    
    private func startMotionPipeline() {
        stopMotionPipeline()

        currentStageOffset = .zero
        lastDisplayTimestamp = 0
        lastMotionUIRefreshTime = 0
        lastRawTiltX = 0
        lastRawTiltY = 0
        lastAppliedDx = 0
        lastAppliedDy = 0
        smoothedManualDx = 0
        smoothedManualDy = 0
        smoothedAIDx = 0
        smoothedAIDy = 0
        aiLockConfidence = 0.0

        motionService.reset()
        proMotionCoordinator.reset()
        motionService.start()

        let link = CADisplayLink(target: self, selector: #selector(handleDisplayLink(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    private func stopMotionPipeline() {
        displayLink?.invalidate()
        displayLink = nil
        lastDisplayTimestamp = 0
        motionService.stop()
    }
    @objc
    private func handleDisplayLink(_ link: CADisplayLink) {
        let dt: CGFloat
        vibeEngine.update(from: playbackController.player)

        if lastDisplayTimestamp > 0 {
            dt = CGFloat(max(1.0 / 240.0, min(link.timestamp - lastDisplayTimestamp, 1.0 / 30.0)))
        } else {
            dt = CGFloat(1.0 / 60.0)
        }
        lastDisplayTimestamp = link.timestamp

        let rawTilt = motionService.readTilt()
        let rawX = CGFloat(rawTilt.x)
        let rawY = CGFloat(rawTilt.y)

        lastRawTiltX = rawX
        lastRawTiltY = rawY

        if isAIEnabled {
            updateAISubjectTrackingIfNeeded(link.timestamp)
            applyAIOffset(rawX: rawX, rawY: rawY, dt: dt)
        } else if isManualMotionLaneActive {
            applyManualMotion(rawX: rawX, rawY: rawY, dt: dt)
        } else {
            smoothedManualDx = 0
            smoothedManualDy = 0
            smoothedAIDx = 0
            smoothedAIDy = 0
            settleToCenter(dt: dt)
        }

        updatePlaneOffsetsOnly()

        if shouldRunDepthWorkOnDisplayTick() {
            refreshDepthCompositeIfNeeded(force: false)
        }

        refreshMotionUIIfNeeded(link.timestamp)
    }
    
    private func settleToCenter(dt: CGFloat) {
        let damping: CGFloat = 1.0 - pow(0.001, dt * 2.1)

        var newX = currentStageOffset.x + ((0 - currentStageOffset.x) * damping)
        var newY = currentStageOffset.y + ((0 - currentStageOffset.y) * damping)

        if abs(newX) < 0.16 { newX = 0.0 }
        if abs(newY) < 0.14 { newY = 0.0 }

        let amplified = amplifiedDepthOffset(rawX: newX, rawY: newY)

        lastAppliedDx = amplified.x
        lastAppliedDy = amplified.y

        setStageOffset(x: amplified.x, y: amplified.y, updateDebugNow: false)
    }

    private func shouldRunDepthWorkOnDisplayTick() -> Bool {
        guard isDepthPreviewEnabled, hasLoadedDepthSidecar else { return false }
        if isScrubbing { return true }
        if !playbackController.isPlaying() { return true }
        return cachedDepthImage == nil
    }

    private func manualLensProfile() -> HKV1_ProMotionCoordinator.LensProfile {
        switch playerView.lensMode {
        case .natural:
            return isPortraitOrientation ? .portrait : .natural
        case .anamorphic:
            return .anamorphic
        case .portrait:
            return .portrait
        }
    }

    private func softenedCenterOffset(_ value: CGFloat, centerWidth: CGFloat) -> CGFloat {
        let magnitude = abs(value)
        guard centerWidth > 0 else { return value }
        guard magnitude > 0 else { return 0.0 }

        let t = clamp(magnitude / centerWidth, min: 0.0, max: 1.0)
        let eased = t * t * (3.0 - (2.0 * t))

        // Much softer center treatment:
        // keep continuity through center, but remove the feeling of a brake/grab.
        let scale = 0.82 + (0.18 * eased)
        let softenedMagnitude = magnitude * scale

        return value >= 0 ? softenedMagnitude : -softenedMagnitude
    }

    private func centerContinuityBlend(for value: CGFloat, width: CGFloat) -> CGFloat {
        let magnitude = abs(value)
        guard width > 0 else { return 0.0 }
        return 1.0 - clamp(magnitude / width, min: 0.0, max: 1.0)
    }

    private func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
        a + ((b - a) * t)
    }

    private func currentManualMotionTarget(from output: HKV1_ProMotionOutput, gain: CGFloat) -> CGPoint {
        switch (isTiltEnabled, isPeekEnabled) {
        case (true, true):
            let peekBlend: CGFloat = currentModeIndex == 2 ? 0.62 : 0.54
            return CGPoint(
                x: lerp(output.tiltDx, output.peekDx, peekBlend) * gain,
                y: lerp(output.tiltDy, output.peekDy, peekBlend) * gain
            )

        case (true, false):
            return CGPoint(
                x: output.tiltDx * gain,
                y: output.tiltDy * gain
            )

        case (false, true):
            let peekOnlyGain: CGFloat = currentModeIndex == 2 ? 0.94 : 0.86
            return CGPoint(
                x: output.peekDx * gain * peekOnlyGain,
                y: output.peekDy * gain * peekOnlyGain
            )

        case (false, false):
            return .zero
        }
    }
   
    private func cinematicAIMotionOffset(
        base: CGPoint,
        subjectVelocityX: CGFloat,
        confidence: CGFloat,
        dt: CGFloat
    ) -> CGPoint {

        let driftStrength: CGFloat = 0.18
        let velocityInfluence: CGFloat = 0.42
        let breathingSpeed: CGFloat = 0.6

        let time = CACurrentMediaTime()

        // Cinematic drift (slow floating camera)
        let driftX = sin(time * breathingSpeed) * maxTravelX * driftStrength * 0.08
        let driftY = cos(time * (breathingSpeed * 0.7)) * maxTravelY * driftStrength * 0.04

        // Predictive lead (this is what real cameras do)
        let leadX = subjectVelocityX * maxTravelX * velocityInfluence * confidence

        return CGPoint(
            x: base.x + driftX + leadX,
            y: base.y + driftY
        )
    }

    private func aiMotionAssistOffset(rawX: CGFloat, rawY: CGFloat, dt: CGFloat) -> CGPoint {
        guard isAIEnabled, aiTiltAssistEnabled else { return .zero }

        let lensProfile = manualLensProfile()

        let motionOutput = proMotionCoordinator.compute(
            roll: rawX,
            pitch: rawY,
            deltaTime: dt,
            lensProfile: lensProfile,
            maxDx: maxTravelX * stageTravelUsageX,
            maxDy: maxTravelY * stageTravelUsageY
        )

        let tiltScaleX: CGFloat = currentModeIndex == 2 ? 0.34 : 0.26
        let tiltScaleY: CGFloat = currentModeIndex == 2 ? 0.24 : 0.18

        var assistX = motionOutput.tiltDx * tiltScaleX
        var assistY = motionOutput.tiltDy * tiltScaleY
       
        assistX = clamp(assistX, min: -(maxTravelX * 0.32), max: maxTravelX * 0.32)
        assistY = clamp(assistY, min: -(maxTravelY * 0.22), max: maxTravelY * 0.22)

        return CGPoint(x: assistX, y: assistY)
    }

    private func aiPeekAssistOffset(rawX: CGFloat, rawY: CGFloat, dt: CGFloat) -> CGPoint {
        guard isAIEnabled, aiPeekAssistEnabled else { return .zero }

        let lensProfile = manualLensProfile()

        let motionOutput = proMotionCoordinator.compute(
            roll: rawX,
            pitch: rawY,
            deltaTime: dt,
            lensProfile: lensProfile,
            maxDx: maxTravelX * stageTravelUsageX,
            maxDy: maxTravelY * stageTravelUsageY
        )

        let peekScaleX: CGFloat = currentModeIndex == 2 ? 0.28 : 0.20
        let peekScaleY: CGFloat = currentModeIndex == 2 ? 0.18 : 0.12

        var assistX = motionOutput.peekDx * peekScaleX
        var assistY = motionOutput.peekDy * peekScaleY

        assistX *= aiPeekAssistXStrength > 0 ? aiPeekAssistXStrength / 0.18 : 0.0
        assistY *= aiPeekAssistYStrength > 0 ? aiPeekAssistYStrength / 0.12 : 0.0

        assistX = clamp(assistX, min: -(maxTravelX * 0.22), max: maxTravelX * 0.22)
        assistY = clamp(assistY, min: -(maxTravelY * 0.16), max: maxTravelY * 0.16)

        return CGPoint(x: assistX, y: assistY)
    }

    private func updateAIAutoLookControls() {
        guard isAIEnabled else { return }

        let profile = currentContentProfile
        let shot = aiCurrentShotClass
        let brightness = aiFrameBrightness

        var preset = resolvedAutoPreset(
            lens: playerView.lensMode,
            modeIndex: currentModeIndex,
            content: profile
        )

        switch shot {
        case .close:
            preset.depth += 0.22
            preset.focus += 0.10
            preset.bg -= 0.06
            preset.mid += 0.12
            preset.fg += 0.20

        case .medium:
            preset.depth += 0.10
            preset.focus += 0.04
            preset.mid += 0.08
            preset.fg += 0.10

        case .wide:
            preset.depth -= 0.08
            preset.focus -= 0.04
            preset.bg += 0.12
            preset.mid -= 0.04
            preset.fg -= 0.06
        }

        if brightness < 0.38 {
            preset.depth += 0.12
            preset.focus += 0.05
            preset.mid += 0.06
        }

        preset = clampPreset(preset)

        let rampSpeed: CGFloat = 3.56
        let maxDelta: CGFloat = 0.22

        func step(current: CGFloat, target: CGFloat) -> CGFloat {
            let error = target - current
            let delta = error * (1.0 - exp(-rampSpeed * 0.016))
            let clamped = clamp(delta, min: -maxDelta, max: maxDelta)
            return current + clamped
        }

        playerView.depthIntensity  = step(current: playerView.depthIntensity, target: preset.depth)
        playerView.focusFalloff    = step(current: playerView.focusFalloff, target: preset.focus)
        playerView.bgPlaneControl  = step(current: playerView.bgPlaneControl, target: preset.bg)
        playerView.midPlaneControl = step(current: playerView.midPlaneControl, target: preset.mid)
        playerView.fgPlaneControl  = step(current: playerView.fgPlaneControl, target: preset.fg)

        controlBar.setDepthIntensity(Float(playerView.depthIntensity))
        controlBar.setFocusFalloff(Float(playerView.focusFalloff))
        controlBar.setBGPlaneControl(Float(playerView.bgPlaneControl))
        controlBar.setMIDPlaneControl(Float(playerView.midPlaneControl))
        controlBar.setFGPlaneControl(Float(playerView.fgPlaneControl))
    }

    private func computeAISmoothedBaseOffset(dt: CGFloat) -> CGPoint {
        let output = aiAutopilotDriver.step(
            resolvedRect: aiLastStableRect,
            lockConfidence: aiLockConfidence,
            heroY: aiTargetHeroY,
            maxDx: maxTravelX,
            maxDy: maxTravelY,
            dt: dt,
            lostTrackFrames: aiLostTrackFrames,
            lowLightBias: aiFrameBrightness < 0.42
        )

        aiSubjectOffset = CGPoint(
            x: output.target.x * aiStrengthFinal,
            y: output.target.y * aiStrengthFinal
        )

        aiSmoothedSubjectOffset = CGPoint(
            x: output.smoothed.x * aiStrengthFinal,
            y: output.smoothed.y * aiStrengthFinal
        )

        thirdsBiasX = output.thirdsBiasX
        smoothedAISubjectVelocityX = output.subjectVelocityX

        return aiSmoothedSubjectOffset
    }

    private func applyManualMotion(rawX: CGFloat, rawY: CGFloat, dt: CGFloat) {
        let lensProfile = manualLensProfile()

        let output = proMotionCoordinator.compute(
            roll: rawX,
            pitch: rawY,
            deltaTime: dt,
            lensProfile: lensProfile,
            maxDx: maxTravelX * stageTravelUsageX,
            maxDy: maxTravelY * stageTravelUsageY
        )

        let gain = currentModeGain()
        let manualTarget = currentManualMotionTarget(from: output, gain: gain)
        let targetX = manualTarget.x
        let targetY = manualTarget.y

        let tuning = resolvedManualResponse(lensProfile: lensProfile)

        smoothedManualDx = premiumWeightedBlend(
            current: smoothedManualDx,
            target: targetX,
            dt: dt,
            response: tuning.x,
            residualDamp: tuning.residualDampX
        )

        smoothedManualDy = premiumWeightedBlend(
            current: smoothedManualDy,
            target: targetY,
            dt: dt,
            response: tuning.y,
            residualDamp: tuning.residualDampY
        )

        // HINGE FIX: soft center deadzone, no snap-to-zero
        let deadZoneX: CGFloat = 0.002
        let deadZoneY: CGFloat = 0.002

        if abs(smoothedManualDx) < deadZoneX {
            smoothedManualDx *= 0.5
        }

        if abs(smoothedManualDy) < deadZoneY {
            smoothedManualDy *= 0.5
        }

        let centeredX = softenedCenterOffset(
            smoothedManualDx,
            centerWidth: tuning.centerWidthX * 0.78
        )

        let centeredY = softenedCenterOffset(
            smoothedManualDy,
            centerWidth: tuning.centerWidthY * 0.82
        )

        // FEATHER EDGE: start easing earlier and soften more
        let shoulderedX = featherEdgeLimit(
            value: centeredX,
            limit: maxTravelX * 0.985,
            shoulderStart: 0.72,
            softness: 0.42
        )

        let shoulderedY = featherEdgeLimit(
            value: centeredY,
            limit: maxTravelY * 0.985,
            shoulderStart: 0.74,
            softness: 0.46
        )

        let amplified = amplifiedDepthOffset(rawX: shoulderedX, rawY: shoulderedY)

        lastAppliedDx = amplified.x
        lastAppliedDy = amplified.y

        setStageOffset(x: amplified.x, y: amplified.y, updateDebugNow: false)
    }
    
    private func applyAIOffset(rawX: CGFloat, rawY: CGFloat, dt: CGFloat) {
        let output = aiAutopilotDriver.step(
            resolvedRect: aiLastStableRect,
            lockConfidence: aiLockConfidence,
            heroY: aiTargetHeroY,
            maxDx: maxTravelX,
            maxDy: maxTravelY,
            dt: dt,
            lostTrackFrames: aiLostTrackFrames,
            lowLightBias: aiFrameBrightness < 0.42
        )

        aiSubjectOffset = CGPoint(
            x: output.target.x * aiStrengthFinal,
            y: output.target.y * aiStrengthFinal
        )

        aiSmoothedSubjectOffset = CGPoint(
            x: output.smoothed.x * aiStrengthFinal,
            y: output.smoothed.y * aiStrengthFinal
        )

        // AI owns framing only.
        // Manual Peek may still add user motion while AI is active.
        let manualPeekOffset: CGPoint
        if isPeekEnabled {
            let lensProfile = manualLensProfile()
            let motionOutput = proMotionCoordinator.compute(
                roll: rawX,
                pitch: rawY,
                deltaTime: dt,
                lensProfile: lensProfile,
                maxDx: maxTravelX * stageTravelUsageX,
                maxDy: maxTravelY * stageTravelUsageY
            )

            let peekScaleX: CGFloat = currentModeIndex == 2 ? 0.28 : 0.20
            let peekScaleY: CGFloat = currentModeIndex == 2 ? 0.18 : 0.12

            manualPeekOffset = CGPoint(
                x: motionOutput.peekDx * peekScaleX,
                y: motionOutput.peekDy * peekScaleY
            )
        } else {
            manualPeekOffset = .zero
        }

        let finalDx = aiSmoothedSubjectOffset.x + manualPeekOffset.x
        let finalDy = aiSmoothedSubjectOffset.y + manualPeekOffset.y

        let aiAlphaX = 1.0 - exp(-4.2 * dt)
        let aiAlphaY = 1.0 - exp(-3.6 * dt)

        smoothedAIDx += (finalDx - smoothedAIDx) * aiAlphaX
        smoothedAIDy += (finalDy - smoothedAIDy) * aiAlphaY

        thirdsBiasX = output.thirdsBiasX
        smoothedAISubjectVelocityX = output.subjectVelocityX

        lastAppliedDx = smoothedAIDx
        lastAppliedDy = smoothedAIDy

        updateAIAutoLookControls()
        setStageOffset(x: smoothedAIDx, y: smoothedAIDy, updateDebugNow: false)
    }

    private func currentModeGain() -> CGFloat {
        switch currentModeIndex {
        case 0:
            return modeOffGain
        case 2:
            return 2.22
        default:
            return 1.02
        }
    }
    
    private func resolvedManualResponse(
        lensProfile: HKV1_ProMotionCoordinator.LensProfile
    ) -> (x: CGFloat, y: CGFloat, centerWidthX: CGFloat, centerWidthY: CGFloat, residualDampX: CGFloat, residualDampY: CGFloat) {
        let wide = currentModeIndex == 2

        switch lensProfile {
        case .natural:
            return wide
            ? (x: 8.8, y: 8.0, centerWidthX: max(7.0, maxTravelX * 0.082), centerWidthY: max(4.8, maxTravelY * 0.110), residualDampX: 0.985, residualDampY: 0.988)
            : (x: 10.2, y: 9.4, centerWidthX: max(6.2, maxTravelX * 0.074), centerWidthY: max(4.4, maxTravelY * 0.102), residualDampX: 0.982, residualDampY: 0.986)

        case .anamorphic:
            return wide
            ? (x: 8.4, y: 7.6, centerWidthX: max(7.4, maxTravelX * 0.086), centerWidthY: max(4.6, maxTravelY * 0.104), residualDampX: 0.986, residualDampY: 0.989)
            : (x: 9.6, y: 8.8, centerWidthX: max(6.6, maxTravelX * 0.078), centerWidthY: max(4.2, maxTravelY * 0.096), residualDampX: 0.983, residualDampY: 0.987)

        case .portrait:
            return wide
            ? (x: 8.0, y: 7.2, centerWidthX: max(6.6, maxTravelX * 0.080), centerWidthY: max(4.4, maxTravelY * 0.108), residualDampX: 0.987, residualDampY: 0.989)
            : (x: 9.0, y: 8.2, centerWidthX: max(5.8, maxTravelX * 0.072), centerWidthY: max(4.0, maxTravelY * 0.100), residualDampX: 0.984, residualDampY: 0.987)
        }
    }

    private func premiumWeightedBlend(
        current: CGFloat,
        target: CGFloat,
        dt: CGFloat,
        response: CGFloat,
        residualDamp: CGFloat
    ) -> CGFloat {
        let alpha = 1.0 - exp(-response * dt)
        var next = current + ((target - current) * alpha)

        if abs(target) < 0.0012 {
            next *= residualDamp
        }

        if abs(next) < 0.0008 {
            next = 0.0
        }

        return next
    }
    private var isPortraitOrientation: Bool {
        view.bounds.height >= view.bounds.width
    }

    // MARK: - Stage Offset

    private func setStageOffset(x: CGFloat, y: CGFloat, updateDebugNow: Bool) {
        let softenedX = featherEdgeLimit(
            value: x,
            limit: maxTravelX,
            shoulderStart: 0.74,
            softness: 0.44
        )

        let softenedY = featherEdgeLimit(
            value: y,
            limit: maxTravelY,
            shoulderStart: 0.76,
            softness: 0.48
        )

        currentStageOffset = CGPoint(
            x: softenedX,
            y: softenedY
        )

        let stageFactorX: CGFloat = currentModeIndex == 2 ? 0.88 : 0.84
        let stageFactorY: CGFloat = currentModeIndex == 2 ? 0.88 : 0.84

        let stageX = currentStageOffset.x * stageFactorX
        let stageY = currentStageOffset.y * stageFactorY

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        stageView.center = CGPoint(
            x: maskWindowView.bounds.midX + stageX,
            y: maskWindowView.bounds.midY + stageY
        )
        CATransaction.commit()

        if updateDebugNow {
            refreshDebugUI(force: true)
        }
    }
   
    private func featherEdgeLimit(value: CGFloat, limit: CGFloat, shoulderStart: CGFloat, softness: CGFloat) -> CGFloat {
        guard limit > 0 else { return 0.0 }

        let normalized = max(-1.0, min(1.0, value / limit))
        let sign: CGFloat = normalized < 0 ? -1.0 : 1.0
        let magnitude = abs(normalized)

        if magnitude <= shoulderStart {
            return normalized * limit
        }

        let remaining = max(0.0001, 1.0 - shoulderStart)
        let u = min(1.0, max(0.0, (magnitude - shoulderStart) / remaining))

        // feather-style shoulder
        let eased = shoulderStart + ((1.0 - shoulderStart) * (1.0 - exp(-(u / max(0.0001, softness)))))
        let blended = min(1.0, eased)

        return sign * blended * limit
    }

    // MARK: - Plane Offsets

    private func updatePlaneOffsetsOnly() {
        let residualFactor: CGFloat = currentModeIndex == 2 ? 0.12 : 0.16
        let residualX = currentStageOffset.x * residualFactor
        let residualY = currentStageOffset.y * residualFactor

        let dx = residualX
        let dy = residualY

        let bgX: CGFloat = currentModeIndex == 2 ? 0.18 : 0.22
        let bgY: CGFloat = currentModeIndex == 2 ? 0.11 : 0.14

        let midX: CGFloat = currentModeIndex == 2 ? 0.42 : 0.52
        let midY: CGFloat = currentModeIndex == 2 ? 0.25 : 0.32

        let fgX: CGFloat = currentModeIndex == 2 ? 0.70 : 0.86
        let fgY: CGFloat = currentModeIndex == 2 ? 0.42 : 0.54

        playerView.bgOffset = CGPoint(x: dx * bgX, y: dy * bgY)
        playerView.midOffset = CGPoint(x: dx * midX, y: dy * midY)
        playerView.fgOffset = CGPoint(x: dx * fgX, y: dy * fgY)
    }

    // MARK: - Motion UI

    private func refreshMotionUIIfNeeded(_ now: CFTimeInterval) {
        if !isScrubbing {
            let duration = playbackController.durationSeconds
            let current = playbackController.player.currentTime().seconds
            if duration > 0, current.isFinite,
               (now - lastMotionUIRefreshTime) >= (1.0 / motionUIRefreshFPS) {
                controlBar.setTime(current: current, duration: duration)
            }
        }

        if (now - lastMotionUIRefreshTime) >= (1.0 / motionUIRefreshFPS) {
            refreshDebugUI(force: false)
            lastMotionUIRefreshTime = now
        }
    }

    private func refreshDebugUI(force: Bool) {
        let maskFrame = maskWindowView.frame
        let stageSize = stageView.bounds.size
        let isPortrait = isPortraitOrientation

        if force || !debugLabel.isHidden {
            updateDebugLabel(maskFrame: maskFrame, stageSize: stageSize, isPortrait: isPortrait)
        }
    }

    // MARK: - Depth Refresh

    private func shouldRefreshDepth(now: CFTimeInterval, isPlaying: Bool, force: Bool) -> Bool {
        if force { return true }
        if cachedDepthImage == nil { return true }

        let interval = isPlaying ? (1.0 / playbackDepthRefreshFPS) : (1.0 / pausedDepthRefreshFPS)
        return (now - lastDepthRefreshTime) >= interval
    }

    private func shouldAcceptDepthTime(currentSeconds: Double, isPlaying: Bool, force: Bool) -> Bool {
        if force { return true }
        if lastDepthVideoSeconds < 0 { return true }

        let minDelta = isPlaying ? minSecondsDeltaForDepthWhilePlaying : minSecondsDeltaForDepthWhilePaused
        return abs(currentSeconds - lastDepthVideoSeconds) >= minDelta
    }

    private func mappedExportPreset() -> HKV1_CinematicExportEngine.Preset {
        switch exportPreset {
        case .balanced:
            return .balanced
        case .ultra:
            return .ultra
        case .aggressive:
            return .aggressive
        case .off:
            return cinematicMode ? .cinema : .balanced
        }
    }

    
    private func refreshDepthCompositeIfNeeded(force: Bool) {
        guard isDepthPreviewEnabled, hasLoadedDepthSidecar else {
            playerView.setRenderMode(.flat)
            playerView.setSpatialMode(.flat)
            return
        }

        let player = playbackController.player
        let currentSeconds = player.currentTime().seconds
        let now = CACurrentMediaTime()
        let isPlaying = player.timeControlStatus == .playing

        guard currentSeconds.isFinite else {
            playerView.setRenderMode(.flat)
            playerView.setSpatialMode(.flat)
            return
        }

        let allowDepthRefresh =
            shouldRefreshDepth(now: now, isPlaying: isPlaying, force: force) &&
            shouldAcceptDepthTime(currentSeconds: currentSeconds, isPlaying: isPlaying, force: force)

        if allowDepthRefresh {
            if let depthCG = depthSidecar.previewImage(videoSeconds: currentSeconds) {
                let rawDepth = UIImage(cgImage: depthCG)

                if let ci = CIImage(image: rawDepth) {
                    temporalDepth.setMotion(
                        dx: currentStageOffset.x,
                        dy: currentStageOffset.y
                    )

                    let fused = temporalDepth.fuse(current: ci)

                    // 10/10 manual depth authority:
                    // AI stays on the safer fused masks.
                    // Manual lane gets the stronger cinematic-shaped depth for visible masks.
                    var workingDepth = UIImage(ciImage: fused)

                    let shouldUseManualDepthAuthority = isManualMotionLaneActive
                    let shouldShapeDepthForManual =
                        shouldUseManualDepthAuthority || exportPreset != .off || isScrubbing || force

                    if shouldShapeDepthForManual {
                        workingDepth = exportEngine.renderUltraDepth(
                            from: workingDepth,
                            preset: mappedExportPreset()
                        ) ?? workingDepth
                    }

                    if shouldUseManualDepthAuthority, let workingCI = CIImage(image: workingDepth) {
                        playerView.setDepthBandMasks(depthImage: workingCI)
                    } else {
                        playerView.setDepthBandMasks(depthImage: fused)
                    }

                    cachedDepthImage = workingDepth
                    lastResolvedDepthImage = workingDepth
                    lastDepthVideoSeconds = currentSeconds
                }
            } else if let lastResolvedDepthImage {
                cachedDepthImage = lastResolvedDepthImage
            }

            lastDepthRefreshTime = now
        }

        guard cachedDepthImage != nil else {
            playerView.setRenderMode(.flat)
            playerView.setSpatialMode(.flat)
            return
        }

        playerView.setRenderMode(.depthPrepared)
        playerView.setSpatialMode(.threePlane)
    }


    private func updateAISubjectTrackingIfNeeded(_ now: CFTimeInterval) {
        guard (now - lastAIAnalysisTime) >= (1.0 / aiAnalysisFPS) else { return }
        lastAIAnalysisTime = now

        var aiState = "unknown"
        var hadFrame = false
        aiDetectorTelemetry = [
            "detector_mode": "ROBUST_V2",
            "detector_state": "idle"
        ]

        let graceFrames = dynamicAILostTrackGraceFrames()
        var resolvedRect: CGRect?
        resolvedRect = aiLastStableRect

        guard let frame = livePlaybackEngine.currentFrame() else {
            aiDriverResolvedRect = nil
            aiLostTrackFrames = min(graceFrames, aiLostTrackFrames + 1)
            aiLockConfidence = max(0.0, aiLockConfidence - 0.04)
            aiDetectorTelemetry["detector_state"] = "no_frame_hold"
            return
        }

        hadFrame = true
        let detectedRect = detectSubjectRect(in: frame.pixelBuffer)

        if let detectedRect {

            if let currentHero = aiLastStableRect {
                let iou = rectIOU(currentHero, detectedRect)

                if iou > 0.42 {
                    aiLastStableRect = detectedRect
                    aiLockConfidence = min(1.0, aiLockConfidence + 0.20)
                    aiLostTrackFrames = 0
                    aiState = "hero_reinforced"
                } else {
                    if aiLockConfidence < 0.28 {
                        aiLastStableRect = detectedRect
                        aiLockConfidence = 0.35
                        aiLostTrackFrames = 0
                        aiState = "hero_switched_low_confidence"
                    } else {
                        aiLockConfidence *= 0.94
                        aiState = "holding_current_hero"
                    }
                }
            } else {
                aiLastStableRect = detectedRect
                aiLockConfidence = 0.30
                aiLostTrackFrames = 0
                aiState = "hero_acquired"
            }

            resolvedRect = aiLastStableRect

        } else if let heldRect = aiLastStableRect, aiLostTrackFrames < graceFrames {

            aiLostTrackFrames += 1
            aiLockConfidence *= 0.96
            resolvedRect = heldRect
            aiState = "holding_previous"

        } else {

            aiLastStableRect = nil
            aiLockConfidence *= 0.85
            resolvedRect = nil
            aiState = "lost_lock"
        }
        
        aiDriverResolvedRect = resolvedRect
        print("🔥 HERO LOCK ACTIVE")
        print("TRACE RECT:", resolvedRect ?? .zero)
        
        let targetOffset = aiSubjectOffset
        let smoothedOffset = CGPoint(x: smoothedAIDx, y: smoothedAIDy)

        var detectorInfo = aiDetectorTelemetry
        detectorInfo["ai_state"] = aiState
        detectorInfo["had_frame"] = hadFrame
        detectorInfo["ai_lock_confidence"] = aiLockConfidence
        detectorInfo["ai_grace_frames"] = graceFrames
        detectorInfo["ai_frame_brightness"] = aiFrameBrightness

        for (key, value) in currentLookControlTracePayload() {
            detectorInfo[key] = value
        }

        aiTraceLogger.logFrame(
            now: now,
            detectedRect: resolvedRect,
            resolvedRect: resolvedRect,
            targetOffset: targetOffset,
            smoothedOffset: smoothedOffset,
            stageOffset: currentStageOffset,
            lostTrackFrames: aiLostTrackFrames,
            detectorInfo: detectorInfo
        )

        if aiVerboseLogging {
            print("AI DEBUG → state:", aiState, "| detector:", detectorInfo)
        }
    }

    private func detectSubjectRect(in pixelBuffer: CVPixelBuffer) -> CGRect? {
        _ = pixelBuffer

        let currentSeconds = playbackController.player.currentTime().seconds
        guard currentSeconds.isFinite else {
            aiDetectorTelemetry = [
                "detector_mode": "ELITE_TEMPORAL_V1",
                "detector_state": "bad_time"
            ]
            aiDriverResolvedRect = nil
            return nil
        }

        guard let cgImage = uprightFrameCGImageForAI(at: currentSeconds) else {
            aiDetectorTelemetry = [
                "detector_mode": "ELITE_TEMPORAL_V1",
                "detector_state": "no_upright_frame"
            ]
            aiDriverResolvedRect = nil
            return nil
        }

        let result = robustDetectSubjects(in: cgImage)
        let candidates = result.candidates
        var telemetry = result.telemetry

        aiTemporalFrameIndex += 1

        let detections = candidates.map {
            HKV1_SubjectIdentityManager.Detection(
                boundingBox: $0.boundingBox,
                confidence: $0.confidence
            )
        }

        let resolvedSubjects = subjectIdentityManager.process(detections: detections)
        updatePerSubjectMotion(for: resolvedSubjects)

        let speakerInputs: [HKV1_SpeakerDetectionEngine.SubjectInput] = resolvedSubjects.map {
            HKV1_SpeakerDetectionEngine.SubjectInput(
                stableID: $0.stableID,
                boundingBox: $0.boundingBox
            )
        }

        // ---------- SPEAKER DETECTION ----------

        let speakerOutputs = speakerDetectionEngine.process(
            frameImage: cgImage,
            subjects: speakerInputs,
            frameIndex: aiTemporalFrameIndex
        )

        for output in speakerOutputs {
            aiSpeakingScoreByStableID[output.stableID] = output.speakingScore
        }

        let audioInputs: [HKV1_AudioSpeakerDetectionEngine.SubjectInput] = resolvedSubjects.map {
            HKV1_AudioSpeakerDetectionEngine.SubjectInput(
                stableID: $0.stableID,
                boundingBox: $0.boundingBox
            )
        }

        let audioOutputs = audioSpeakerDetectionEngine.process(
            subjects: audioInputs,
            frameIndex: aiTemporalFrameIndex,
            currentTimeSeconds: currentSeconds
        )

        for output in audioOutputs {
            aiAudioScoreByStableID[output.stableID] = output.fusedSpeakerScore
        }

        // ---------- FACE LANDMARKS ----------

        let faceRequest = VNDetectFaceLandmarksRequest()
        let faceHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        var landmarkFaces: [VNFaceObservation] = []

        do {
            try faceHandler.perform([faceRequest])
            landmarkFaces = (faceRequest.results as? [VNFaceObservation]) ?? []
        } catch {
            landmarkFaces = []
        }

        // ---------- EYE CONTACT ----------

        let eyeInputs: [HKV1_EyeContactAnalyzer.SubjectInput] = resolvedSubjects.map {
            HKV1_EyeContactAnalyzer.SubjectInput(
                stableID: $0.stableID,
                boundingBox: $0.boundingBox
            )
        }

        let eyeOutputs = eyeContactAnalyzer.process(
            faceObservations: landmarkFaces,
            resolvedSubjects: eyeInputs,
            frameIndex: aiTemporalFrameIndex
        )

        for output in eyeOutputs {
            aiEyeContactScoreByStableID[output.stableID] = output.eyeContactScore
        }

        let directorSubjects: [HKV1_ReactionDirectorSubject] = resolvedSubjects.map {
            let motionMagnitude = abs(aiVelocityXByStableID[$0.stableID] ?? 0)
            return HKV1_ReactionDirectorSubject(
                stableID: $0.stableID,
                boundingBox: $0.boundingBox,
                confidence: $0.confidence,
                speakingScore: speakingScore(for: $0.stableID),
                eyeContactScore: eyeContactScore(for: $0.stableID),
                motionScore: clamp(motionMagnitude * 10.0, min: 0.0, max: 1.0),
                isPrimaryCandidate: $0.isPrimaryCandidate,
                isPreviousWinner: $0.previousWinnerPresent
            )
        }

        let bestResolved = resolvedSubjects.max { lhs, rhs in
            scoreResolvedSubject(lhs) < scoreResolvedSubject(rhs)
        }

        let previousWinnerPresent = resolvedSubjects.contains { $0.stableID == aiChosenWinnerStableID }
        let previousWinnerScore = resolvedSubjects.first(where: { $0.stableID == aiChosenWinnerStableID })?.confidence

        let graceProbs = temporalConfidenceGraceProbs(
            candidateCount: resolvedSubjects.count,
            brightness: aiFrameBrightness,
            bestConfidence: bestResolved?.confidence ?? 0.0
        )

        let decision = temporalDecisionEngine.process(
            VerticalTemporalFrameInput(
                clipID: currentVideoURL?.lastPathComponent ?? "default_clip",
                frameID: "ai_frame_\(aiTemporalFrameIndex)",
                rawWinnerID: bestResolved?.stableID,
                rawWinnerScore: Double(bestResolved?.confidence ?? 0.0),
                previousWinnerPresent: previousWinnerPresent,
                previousWinnerScore: previousWinnerScore.map(Double.init),
                previousWasPrimary: aiPreviousWinnerWasPrimary,
                frameJump: 1,
                confidenceGraceProbs: graceProbs
            )
        )

        let temporalChosen = resolvedSubjects.first(where: { $0.stableID == decision.chosenWinnerID }) ?? bestResolved

        let brightestSubjectArea = resolvedSubjects.map { $0.boundingBox.width * $0.boundingBox.height }.max() ?? 0.0
        let sceneDecision = currentSceneTypeDecision(
            subjectCount: resolvedSubjects.count,
            brightestSubjectArea: brightestSubjectArea
        )

        let directorInput = HKV1_ReactionDirectorFrameInput(
            subjects: directorSubjects,
            currentWinnerStableID: aiChosenWinnerStableID,
            sceneType: sceneDecision.sceneType,
            shotClassRawValue: aiCurrentShotClass.rawValue,
            frameIndex: aiTemporalFrameIndex,
            frameBrightness: aiFrameBrightness,
            currentTimeSeconds: currentSeconds
        )

        let directorDecision: HKV1_ReactionDirectorDecision = reactionDirector.process(directorInput)

        let editorialPolicy = directorPolicy.currentConfig()
        let editorialDecision = editorialRhythmEngine.process(
            HKV1_EditorialInput(
                currentWinnerID: aiChosenWinnerStableID,
                candidateID: directorDecision.chosenStableID,
                switchUrgency: clamp(directorDecision.switchUrgency + editorialPolicy.switchSensitivity, min: 0.0, max: 1.0),
                sceneHoldFrames: max(2, Int(round(CGFloat(sceneDecision.recommendedHoldFrames) * editorialPolicy.holdMultiplier))),
                frameIndex: aiTemporalFrameIndex,
                previousSwitchFrame: 0
            )
        )

        let rawChosen = editorialDecision.shouldSwitch
            ? (resolvedSubjects.first(where: { $0.stableID == directorDecision.chosenStableID }) ?? temporalChosen)
            : (resolvedSubjects.first(where: { $0.stableID == aiChosenWinnerStableID }) ?? temporalChosen)

        let chosenSubject: HKV1_SubjectIdentityManager.ResolvedSubject?

        if let raw = rawChosen {
            if let currentHeroID = aiChosenWinnerStableID {
                if raw.stableID == currentHeroID {
                    aiPendingSwitchStableID = nil
                    aiPendingSwitchFrames = 0
                    aiPendingSwitchScore = 0
                    chosenSubject = raw
                } else {
                    let currentHero = resolvedSubjects.first(where: { $0.stableID == currentHeroID })
                    let policy = directorPolicy.currentConfig()

                    let holdBias = directorHoldBias(
                        sceneDecision: sceneDecision,
                        directorDecision: directorDecision,
                        currentHero: currentHero,
                        challenger: raw
                    )

                    let heroStickiness = directorHeroStickiness(
                        currentHero: currentHero,
                        challenger: raw,
                        sceneDecision: sceneDecision
                    )

                    let reactionBoost = hollywoodReactionBoost(
                        currentHero: currentHero,
                        challenger: raw,
                        directorDecision: directorDecision,
                        sceneDecision: sceneDecision
                    )

                    let heroPenalty = hollywoodHoldPenaltyForCurrentHero(
                        currentHero: currentHero,
                        challenger: raw
                    )

                    let challengerScoreRaw = scoreResolvedSubject(raw)
                        + (directorDecision.switchUrgency * 0.18)
                        + (sceneDecision.prefersReactionShots ? policy.reactionBias : 0.0)
                        + reactionBoost

                    let challengerScore = challengerScoreRaw - holdBias

                    let currentHeroScoreBase = currentHero.map(scoreResolvedSubject)
                        ?? ((aiLockConfidence * 1.35) + 0.35)

                    let currentHeroScore = currentHeroScoreBase + heroStickiness - heroPenalty

                    let currentSpeaking = currentHero.map { speakingScore(for: $0.stableID) } ?? 0.0
                    let challengerSpeaking = speakingScore(for: raw.stableID)

                    let heroWeak =
                        (currentHero == nil) ||
                        (aiLockConfidence < 0.38) ||
                        (abs(smoothedAISubjectVelocityX) > 0.010) ||
                        (challengerSpeaking > currentSpeaking + 0.22)

                    let dynamicSwitchMargin = directorSwitchMargin(
                        sceneDecision: sceneDecision,
                        editorialDecision: editorialDecision
                    )

                    let challengerClearlyBetter =
                        challengerScore > (currentHeroScore + dynamicSwitchMargin)

                    let editorialWarmup = editorialDecision.shouldHold ? 1 : 0
                    let confidenceWarmup = aiLockConfidence > 0.72 ? 1 : 0
                    let extraWarmupFrames = editorialWarmup + confidenceWarmup

                    if heroWeak && challengerClearlyBetter {
                        if aiPendingSwitchStableID == raw.stableID {
                            aiPendingSwitchFrames += 1
                        } else {
                            aiPendingSwitchStableID = raw.stableID
                            aiPendingSwitchFrames = 1
                        }

                        aiPendingSwitchScore = challengerScore

                        let requiredFrames = directorSwitchDelayFrames(
                            sceneDecision: sceneDecision,
                            directorDecision: directorDecision,
                            currentHero: currentHero,
                            challenger: raw
                        ) + extraWarmupFrames

                        if aiPendingSwitchFrames >= requiredFrames {
                            let adaptiveConfidenceGate: CGFloat =
                                aiFrameBrightness < 0.40 ? 0.55 : 0.48

                            if aiLockConfidence < adaptiveConfidenceGate {
                                chosenSubject = currentHero ?? raw
                            } else {
                                chosenSubject = raw
                                aiLastCommittedSwitchFrame = aiTemporalFrameIndex
                                aiReactionWindowUntilFrame = aiTemporalFrameIndex + 10
                                aiLastSpeakerStableID = raw.stableID
                            }
                        } else {
                            chosenSubject = currentHero ?? raw
                        }
                    } else {
                        aiPendingSwitchStableID = nil
                        aiPendingSwitchFrames = 0
                        aiPendingSwitchScore = 0
                        chosenSubject = currentHero ?? raw
                    }
                }
            } else {
                aiPendingSwitchStableID = nil
                aiPendingSwitchFrames = 0
                aiPendingSwitchScore = 0
                chosenSubject = raw
                aiLastCommittedSwitchFrame = aiTemporalFrameIndex
                aiReactionWindowUntilFrame = aiTemporalFrameIndex + 8
                aiLastSpeakerStableID = raw.stableID
            }
        } else {
            aiPendingSwitchStableID = nil
            aiPendingSwitchFrames = 0
            aiPendingSwitchScore = 0
            chosenSubject = nil
        }
        if let chosen = chosenSubject {
            smoothedAISubjectVelocityX = aiVelocityXByStableID[chosen.stableID] ?? 0
        } else {
            smoothedAISubjectVelocityX = 0
        }

        aiChosenWinnerStableID = chosenSubject?.stableID
        aiPreviousWinnerWasPrimary = chosenSubject?.isPrimaryCandidate ?? false
        aiCurrentShotClass = shotClassifier.classify(
            heroRect: chosenSubject?.boundingBox,
            subjectCount: resolvedSubjects.count
        )

        if let chosenRect = chosenSubject?.boundingBox {
            aiLastStableRect = chosenRect
            aiDriverResolvedRect = chosenRect
            trackedFaceObservation = VNDetectedObjectObservation(boundingBox: chosenRect)
            telemetry["detector_state"] = "temporal_winner_locked"
            telemetry["resolved_subject_count"] = resolvedSubjects.count
            telemetry["chosen_stable_id"] = chosenSubject?.stableID ?? -1
            telemetry["raw_winner_id"] = bestResolved?.stableID ?? -1
            telemetry["temporal_action"] = decision.temporalAction
            telemetry["decision_type"] = decision.decisionType
            telemetry["switch_probability"] = decision.switchProbability
            telemetry["grace_active"] = decision.graceActive
            telemetry["grace_remaining"] = decision.graceRemaining
            telemetry["grace_mode"] = decision.graceMode
            telemetry["pending_switch_id"] = aiPendingSwitchStableID ?? -1
            telemetry["pending_switch_frames"] = aiPendingSwitchFrames
            telemetry["pending_switch_score"] = aiPendingSwitchScore
            telemetry["hero_confidence_floor"] = currentAIHeroConfidenceFloor()
            telemetry["switch_margin_required"] = currentAISwitchMargin()
            telemetry["shot_class"] = aiCurrentShotClass.rawValue
            telemetry["director_decision"] = directorDecision.decisionType.rawValue
            telemetry["director_reason"] = directorDecision.reason
            telemetry["director_speaker_id"] = directorDecision.speakerStableID ?? -1
            telemetry["director_reaction_id"] = directorDecision.reactionStableID ?? -1
            telemetry["director_switch_urgency"] = directorDecision.switchUrgency
            telemetry["scene_type"] = sceneDecision.sceneType.rawValue
            telemetry["scene_confidence"] = sceneDecision.confidence
            telemetry["scene_reason"] = sceneDecision.reason
            telemetry["editorial_should_switch"] = editorialDecision.shouldSwitch
            telemetry["editorial_should_hold"] = editorialDecision.shouldHold
            telemetry["editorial_reason"] = editorialDecision.reason
            aiDetectorTelemetry = telemetry
            return chosenRect
        }

        aiDriverResolvedRect = nil
        trackedFaceObservation = nil
        telemetry["detector_state"] = "no_temporal_winner"
        telemetry["resolved_subject_count"] = resolvedSubjects.count
        telemetry["temporal_action"] = decision.temporalAction
        telemetry["decision_type"] = decision.decisionType
        telemetry["switch_probability"] = decision.switchProbability
        telemetry["grace_active"] = decision.graceActive
        telemetry["grace_remaining"] = decision.graceRemaining
        telemetry["grace_mode"] = decision.graceMode
        telemetry["pending_switch_id"] = aiPendingSwitchStableID ?? -1
        telemetry["pending_switch_frames"] = aiPendingSwitchFrames
        telemetry["pending_switch_score"] = aiPendingSwitchScore
        telemetry["hero_confidence_floor"] = currentAIHeroConfidenceFloor()
        telemetry["switch_margin_required"] = currentAISwitchMargin()
        telemetry["shot_class"] = aiCurrentShotClass.rawValue
        telemetry["director_decision"] = directorDecision.decisionType.rawValue
        telemetry["director_reason"] = directorDecision.reason
        telemetry["director_speaker_id"] = directorDecision.speakerStableID ?? -1
        telemetry["director_reaction_id"] = directorDecision.reactionStableID ?? -1
        telemetry["director_switch_urgency"] = directorDecision.switchUrgency
        telemetry["scene_type"] = sceneDecision.sceneType.rawValue
        telemetry["scene_confidence"] = sceneDecision.confidence
        telemetry["scene_reason"] = sceneDecision.reason
        telemetry["editorial_should_switch"] = editorialDecision.shouldSwitch
        telemetry["editorial_should_hold"] = editorialDecision.shouldHold
        telemetry["editorial_reason"] = editorialDecision.reason
        aiDetectorTelemetry = telemetry
        return nil
    }

    
    private func speakingScore(for stableID: Int) -> CGFloat {
        let visual = aiSpeakingScoreByStableID[stableID] ?? 0
        let audio = aiAudioScoreByStableID[stableID] ?? 0
        return clamp(
            max(
                visual * 0.72,
                (visual * 0.40) + (audio * 0.85)
            ),
            min: 0.0,
            max: 1.0
        )
    }

    private func eyeContactScore(for stableID: Int) -> CGFloat {
        aiEyeContactScoreByStableID[stableID] ?? 0
    }

private func scoreResolvedSubject(_ subject: HKV1_SubjectIdentityManager.ResolvedSubject) -> CGFloat {
        let rect = subject.boundingBox
        let area = rect.width * rect.height

        let horizontalCenterBias = 1.0 - abs(rect.midX - 0.5) / 0.5
        let verticalCenterBias = 1.0 - abs(rect.midY - 0.55) / 0.55
        let centerBias = max(0.0, (horizontalCenterBias * 0.42) + (verticalCenterBias * 0.58))

        let subjectVelocity = aiVelocityXByStableID[subject.stableID] ?? 0
        let rawMotion = abs(subjectVelocity)
        let motionNormalized = min(rawMotion * 10.0, 1.0)

        let motionBoost: CGFloat = motionNormalized * aiMotionBoostDialogue

        let speaking = speakingScore(for: subject.stableID)
        let eye = eyeContactScore(for: subject.stableID)
        let speakingWeight = shotClassifier.speakingWeight(for: aiCurrentShotClass)

        let vibe = vibeEngine.scoreCandidate(
            .init(
                rect: rect,
                isPreviousWinner: subject.previousWinnerPresent,
                isPrimaryCandidate: subject.isPrimaryCandidate,
                confidence: subject.confidence,
                subjectVelocityX: subjectVelocity,
                lockConfidence: aiLockConfidence,
                frameBrightness: aiFrameBrightness
            )
        )

        let heroDominance =
            (motionBoost * 2.2) +
            (vibe.totalBoost * aiVibeWeight * 1.4)

        var score = subject.confidence * 0.45
        score += heroDominance
        score += area * aiAreaWeight
        score += centerBias * aiCenterWeight
        score += speaking * aiSpeakingWeight * speakingWeight
        score += eye * aiEyeContactWeight

        if subject.previousWinnerPresent {
            score += 0.25
            score += shotClassifier.holdBonus(for: aiCurrentShotClass)

            if speaking > 0.55 {
                score += 0.18
            }

            if eye > 0.58 {
                score += 0.08
            }
        }

        if subject.isPrimaryCandidate {
            score += 0.15
        }

        return score
    }
  
    private func applyCinematicComposition(
        subjectCenterX: CGFloat,
        subjectVelocityX: CGFloat,
        confidence: CGFloat,
        closeUpLock: CGFloat,
        maxDx: CGFloat
    ) -> CGFloat {
        let centerError = 0.5 - subjectCenterX

        // Much stronger base composition in 9:16
        let centeredX = centerError * maxDx * 2.35

        // Wider shots get stronger thirds authority.
        let compositionStrength = 0.26 + ((1.0 - closeUpLock) * 0.26)

        let desiredThirdsBias =
            -subjectVelocityX *
            maxDx *
            compositionStrength *
            max(confidence, 0.42)

        thirdsBiasX += (desiredThirdsBias - thirdsBiasX) * 0.38

        let leadRoom =
            subjectVelocityX *
            maxDx *
            (0.22 + ((1.0 - closeUpLock) * 0.10)) *
            max(confidence, 0.42)

        let composedX = centeredX + thirdsBiasX + leadRoom

        return clamp(composedX, min: -maxDx * 0.96, max: maxDx * 0.96)
    }
    
    private func currentAISwitchConfirmationFrames() -> Int {
        if aiFrameBrightness < 0.36 { return 6 }
        if aiFrameBrightness < 0.42 { return 5 }
        return 4
    }

    private func currentAISwitchMargin() -> CGFloat {
        if aiFrameBrightness < 0.36 { return 0.26 }
        if aiFrameBrightness < 0.42 { return 0.22 }
        return 0.14
    }

    private func currentAIHeroConfidenceFloor() -> CGFloat {
        if aiFrameBrightness < 0.36 { return 0.55 }
        if aiFrameBrightness < 0.42 { return 0.50 }
        return 0.38
    }
   
    private func directorHoldBias(
        sceneDecision: HKV1_SceneTypeDecision,
        directorDecision: HKV1_ReactionDirectorDecision,
        currentHero: HKV1_SubjectIdentityManager.ResolvedSubject?,
        challenger: HKV1_SubjectIdentityManager.ResolvedSubject?
    ) -> CGFloat {
        var bias = aiLockConfidence * 0.18

        if let currentHero {
            bias += currentHero.previousWinnerPresent ? 0.08 : 0.0
            bias += currentHero.isPrimaryCandidate ? 0.05 : 0.0

            let currentSpeaking = speakingScore(for: currentHero.stableID)
            let currentEye = eyeContactScore(for: currentHero.stableID)

            bias += currentSpeaking * 0.12
            bias += currentEye * 0.06
        }

        // Scene influence (SAFE — uses rawValue fallback)
        let sceneTypeString = sceneDecision.sceneType.rawValue.lowercased()

        if sceneTypeString.contains("dialog") {
            bias += 0.14
        } else if sceneTypeString.contains("interview") {
            bias += 0.18
        } else if sceneTypeString.contains("reaction") {
            bias += 0.08
        } else if sceneTypeString.contains("action") {
            bias -= 0.04
        }

        // Director influence (SAFE — uses rawValue)
        let decisionTypeString = directorDecision.decisionType.rawValue.lowercased()

        if decisionTypeString.contains("hold") {
            bias += 0.10
        } else if decisionTypeString.contains("speaker") {
            bias += 0.06
        } else if decisionTypeString.contains("reaction") {
            bias -= 0.04
        } else if decisionTypeString.contains("switch") {
            bias -= 0.02
        }

        if let challenger, let currentHero {
            let currentArea = currentHero.boundingBox.width * currentHero.boundingBox.height
            let challengerArea = challenger.boundingBox.width * challenger.boundingBox.height

            if challengerArea > currentArea * 1.35 {
                bias -= 0.05
            }
        }

        return clamp(bias, min: 0.04, max: 0.42)
    }

    private func directorSwitchDelayFrames(
        sceneDecision: HKV1_SceneTypeDecision,
        directorDecision: HKV1_ReactionDirectorDecision,
        currentHero: HKV1_SubjectIdentityManager.ResolvedSubject?,
        challenger: HKV1_SubjectIdentityManager.ResolvedSubject?
    ) -> Int {

        var delaySeconds: CGFloat = 0.08 + ((1.0 - aiLockConfidence) * 0.06)

        // Scene influence
        switch sceneDecision.sceneType {
        case .dialogue:
            delaySeconds += 0.08
        case .interview:
            delaySeconds += 0.12
        case .action:
            delaySeconds -= 0.03
        default:
            break
        }

        // Director intent (SAFE using rawValue)
        let decisionTypeString = directorDecision.decisionType.rawValue.lowercased()

        if decisionTypeString.contains("speaker") {
            delaySeconds -= 0.02
        } else if decisionTypeString.contains("reaction") {
            delaySeconds -= 0.03
        } else if decisionTypeString.contains("hold") {
            delaySeconds += 0.03
        }

        // Speaker dominance influence
        if let currentHero, let challenger {
            let currentSpeaking = speakingScore(for: currentHero.stableID)
            let challengerSpeaking = speakingScore(for: challenger.stableID)

            if challengerSpeaking > currentSpeaking + 0.20 {
                delaySeconds -= 0.03
            }
        }

        delaySeconds = clamp(delaySeconds, min: 0.04, max: 0.22)

        return max(
            aiSwitchFramesRequired,
            Int(ceil(delaySeconds * 60.0))
        )
    }
    
    private func directorHeroStickiness(
        currentHero: HKV1_SubjectIdentityManager.ResolvedSubject?,
        challenger: HKV1_SubjectIdentityManager.ResolvedSubject?,
        sceneDecision: HKV1_SceneTypeDecision
    ) -> CGFloat {

        guard let currentHero else { return 0.0 }

        var stickiness: CGFloat = 0.0

        stickiness += aiLockConfidence * 0.16
        stickiness += currentHero.previousWinnerPresent ? 0.10 : 0.0
        stickiness += currentHero.isPrimaryCandidate ? 0.05 : 0.0

        let currentSpeaking = speakingScore(for: currentHero.stableID)
        let currentEye = eyeContactScore(for: currentHero.stableID)

        stickiness += currentSpeaking * 0.14
        stickiness += currentEye * 0.06

        switch sceneDecision.sceneType {
        case .dialogue:
            stickiness += 0.10
        case .interview:
            stickiness += 0.14
        case .action:
            stickiness -= 0.04
        default:
            break
        }

        if let challenger {
            let currentArea = currentHero.boundingBox.width * currentHero.boundingBox.height
            let challengerArea = challenger.boundingBox.width * challenger.boundingBox.height

            if challengerArea > currentArea * 1.45 {
                stickiness -= 0.06
            }

            let challengerSpeaking = speakingScore(for: challenger.stableID)
            if challengerSpeaking > currentSpeaking + 0.22 {
                stickiness -= 0.08
            }
        }

        return clamp(stickiness, min: 0.0, max: 0.34)
    }

    private func directorSwitchMargin(
        sceneDecision: HKV1_SceneTypeDecision,
        editorialDecision: HKV1_EditorialDecision
    ) -> CGFloat {

        var margin = max(
            0.06,
            sceneDecision.recommendedSwitchMargin
                + shotClassifier.switchMargin(for: aiCurrentShotClass)
                - (editorialDecision.urgency * 0.05)
        )

        switch sceneDecision.sceneType {
        case .dialogue:
            margin += 0.06
        case .interview:
            margin += 0.08
        case .action:
            margin -= 0.03
        default:
            break
        }

        return clamp(margin, min: 0.05, max: 0.30)
    }
    
    private func hollywoodReactionBoost(
        currentHero: HKV1_SubjectIdentityManager.ResolvedSubject?,
        challenger: HKV1_SubjectIdentityManager.ResolvedSubject?,
        directorDecision: HKV1_ReactionDirectorDecision,
        sceneDecision: HKV1_SceneTypeDecision
    ) -> CGFloat {
        guard let challenger else { return 0.0 }

        var boost: CGFloat = 0.0

        let challengerSpeaking = speakingScore(for: challenger.stableID)
        let challengerEye = eyeContactScore(for: challenger.stableID)

        boost += challengerSpeaking * 0.16
        boost += challengerEye * 0.05

        if directorDecision.reactionStableID == challenger.stableID {
            boost += 0.08
        }

        if directorDecision.speakerStableID == challenger.stableID {
            boost += 0.10
        }

        if aiTemporalFrameIndex <= aiReactionWindowUntilFrame {
            boost += 0.06
        }

        switch sceneDecision.sceneType {
        case .dialogue:
            boost += 0.04
        case .interview:
            boost -= 0.02
        case .action:
            boost += 0.02
        default:
            break
        }

        if let currentHero {
            let currentSpeaking = speakingScore(for: currentHero.stableID)
            if challengerSpeaking > currentSpeaking + 0.24 {
                boost += 0.10
            }
        }

        return clamp(boost, min: 0.0, max: 0.24)
    }

    private func hollywoodHoldPenaltyForCurrentHero(
        currentHero: HKV1_SubjectIdentityManager.ResolvedSubject?,
        challenger: HKV1_SubjectIdentityManager.ResolvedSubject?
    ) -> CGFloat {
        guard let currentHero, let challenger else { return 0.0 }

        let currentSpeaking = speakingScore(for: currentHero.stableID)
        let challengerSpeaking = speakingScore(for: challenger.stableID)

        var penalty: CGFloat = 0.0

        if challengerSpeaking > currentSpeaking + 0.20 {
            penalty += 0.08
        }

        if aiLastSpeakerStableID == challenger.stableID {
            penalty += 0.04
        }

        return clamp(penalty, min: 0.0, max: 0.14)
    }
    
    private func currentSceneTypeDecision(subjectCount: Int, brightestSubjectArea: CGFloat) -> HKV1_SceneTypeDecision {
        let speakingValues = Array(aiSpeakingScoreByStableID.values)
        let eyeValues = Array(aiEyeContactScoreByStableID.values)

        let speakingCount = speakingValues.filter { $0 > 0.45 }.count
        let dominantSpeakingScore = speakingValues.max() ?? 0.0
        let dominantEyeContactScore = eyeValues.max() ?? 0.0

        let motionValues = Array(aiVelocityXByStableID.values).map { abs($0) * 10.0 }
        let averageMotionScore: CGFloat = motionValues.isEmpty ? 0.0 : motionValues.reduce(0.0, +) / CGFloat(motionValues.count)

        return sceneTypeClassifier.classify(
            HKV1_SceneTypeFrameInput(
                subjectCount: subjectCount,
                speakingCount: speakingCount,
                dominantSpeakingScore: dominantSpeakingScore,
                dominantEyeContactScore: dominantEyeContactScore,
                averageMotionScore: clamp(averageMotionScore, min: 0.0, max: 1.0),
                brightestSubjectArea: brightestSubjectArea,
                frameBrightness: aiFrameBrightness,
                currentShotClassRawValue: aiCurrentShotClass.rawValue,
                currentWinnerStableID: aiChosenWinnerStableID,
                previousWinnerStableID: aiChosenWinnerStableID
            )
        )
    }

    private func temporalConfidenceGraceProbs(
        candidateCount: Int,
        brightness: CGFloat,
        bestConfidence: CGFloat
    ) -> [Double] {
        let clampedBrightness = clamp(brightness, min: 0.0, max: 1.0)
        let clampedConfidence = clamp(bestConfidence, min: 0.0, max: 1.0)

        let gold = clamp((clampedConfidence * 0.68) + (clampedBrightness * 0.32), min: 0.0, max: 1.0)
        let edge = clamp((1.0 - gold) * 0.62 + (candidateCount > 1 ? 0.12 : 0.0), min: 0.0, max: 1.0)
        let bad = clamp(1.0 - max(gold, edge * 0.72), min: 0.0, max: 1.0)

        let total = max(0.0001, bad + edge + gold)
        return [bad / total, edge / total, gold / total]
    }

    private func robustDetectSubjects(in cgImage: CGImage) -> (candidates: [HKAISubjectCandidate], telemetry: [String: Any]) {
        let base = CIImage(cgImage: cgImage)
        let extent = base.extent.integral
        let estimatedBrightness = estimateImageBrightness(from: base, extent: extent)
        aiFrameBrightness = estimatedBrightness
        let lowLight = estimatedBrightness < 0.42

        var variants: [(name: String, image: CIImage)] = [
            ("ROBUST_BASE", base),
            ("ROBUST_LIFTED", base
                .applyingFilter("CIHighlightShadowAdjust", parameters: [
                    "inputShadowAmount": 0.90,
                    "inputHighlightAmount": 0.10
                ])
                .applyingFilter("CIColorControls", parameters: [
                    kCIInputBrightnessKey: 0.06,
                    kCIInputContrastKey: 1.18,
                    kCIInputSaturationKey: 1.0
                ])),
            ("ROBUST_GRAY_CONTRAST", base
                .applyingFilter("CIColorControls", parameters: [
                    kCIInputSaturationKey: 0.0,
                    kCIInputBrightnessKey: 0.14,
                    kCIInputContrastKey: 1.65
                ])),
            ("ROBUST_GRAY_AGGRESSIVE", base
                .applyingFilter("CIColorControls", parameters: [
                    kCIInputSaturationKey: 0.0,
                    kCIInputBrightnessKey: 0.22,
                    kCIInputContrastKey: 2.10
                ])
                .applyingFilter("CIHighlightShadowAdjust", parameters: [
                    "inputShadowAmount": 1.0,
                    "inputHighlightAmount": 0.0
                ])),
            ("ROBUST_EXPOSURE_GRAY", base
                .applyingFilter("CIExposureAdjust", parameters: [
                    kCIInputEVKey: 0.45
                ])
                .applyingFilter("CIColorControls", parameters: [
                    kCIInputSaturationKey: 0.0,
                    kCIInputContrastKey: 1.45
                ]))
        ]

        if true {
            variants.append(("ROBUST_LOWLIGHT_PUSH", base
                .applyingFilter("CIHighlightShadowAdjust", parameters: [
                    "inputShadowAmount": 1.0,
                    "inputHighlightAmount": 0.0
                ])
                .applyingFilter("CIExposureAdjust", parameters: [
                    kCIInputEVKey: 0.72
                ])
                .applyingFilter("CIColorControls", parameters: [
                    kCIInputSaturationKey: 0.0,
                    kCIInputBrightnessKey: 0.28,
                    kCIInputContrastKey: 2.28
                ])))
            variants.append(("ROBUST_LOWLIGHT_SOFT", base
                .applyingFilter("CIHighlightShadowAdjust", parameters: [
                    "inputShadowAmount": 0.96,
                    "inputHighlightAmount": 0.02
                ])
                .applyingFilter("CIExposureAdjust", parameters: [
                    kCIInputEVKey: 0.56
                ])
                .applyingFilter("CIColorControls", parameters: [
                    kCIInputBrightnessKey: 0.18,
                    kCIInputContrastKey: 1.82,
                    kCIInputSaturationKey: 0.0
                ])))
        }

        variants = variants.map { ($0.0, $0.1.cropped(to: extent)) }

        var ciCount = 0
        var visionCount = 0
        var bodyCount = 0
        var candidates: [HKAISubjectCandidate] = []

        let ciDetector = CIDetector(
            ofType: CIDetectorTypeFace,
            context: nil,
            options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        )

        for (variantName, variant) in variants {
            if let features = ciDetector?.features(in: variant), !features.isEmpty {
                for case let face as CIFaceFeature in features {
                    let normalized = normalizedRect(fromCIDetectorRect: face.bounds, imageExtent: extent)
                    let area = normalized.width * normalized.height
                    if area >= 0.004 {
                        ciCount += 1
                        candidates.append(
                            HKAISubjectCandidate(
                                boundingBox: normalized,
                                confidence: 0.65,
                                source: "ROBUST_CI",
                                variant: variantName
                            )
                        )
                    }
                }
            }

            guard let variantCG = aiWorkingCIContext.createCGImage(variant, from: extent) else { continue }

            let request = VNDetectFaceRectanglesRequest()
            if #available(iOS 17.0, *) {
                request.revision = VNDetectFaceRectanglesRequestRevision3
            }

            let handler = VNImageRequestHandler(cgImage: variantCG, options: [:])

            do {
                try handler.perform([request])
                if let results = request.results, !results.isEmpty {
                    for face in results {
                        let area = face.boundingBox.width * face.boundingBox.height
                        if area >= 0.004 {
                            visionCount += 1
                            candidates.append(
                                HKAISubjectCandidate(
                                    boundingBox: face.boundingBox,
                                    confidence: CGFloat(face.confidence),
                                    source: "ROBUST_VISION",
                                    variant: variantName
                                )
                            )
                        }
                    }
                }
            } catch {
                continue
            }
        }

        if lowLight {
            let bodyRequest = VNDetectHumanRectanglesRequest()
            bodyRequest.upperBodyOnly = false

            do {
                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                try handler.perform([bodyRequest])
                if let results = bodyRequest.results, !results.isEmpty {
                    for body in results {
                        let pseudo = pseudoFaceRect(fromBodyRect: body.boundingBox)
                        let area = pseudo.width * pseudo.height
                        if area >= 0.004 {
                            bodyCount += 1
                            candidates.append(
                                HKAISubjectCandidate(
                                    boundingBox: pseudo,
                                    confidence: 0.65,
                                    source: "ROBUST_BODY",
                                    variant: "ROBUST_BODY_BASE"
                                )
                            )
                        }
                    }
                }
            } catch {
                // ignore
            }
        }

        let deduped = dedupeAISubjectCandidates(candidates)

        let telemetry: [String: Any] = [
            "detector_mode": "ELITE_TEMPORAL_V1",
            "ci_face_count": ciCount,
            "vision_face_count": visionCount,
            "body_count": bodyCount,
            "candidate_count": candidates.count,
            "deduped_candidate_count": deduped.count,
            "ai_frame_brightness": estimatedBrightness,
            "low_light_bias": lowLight
        ]

        return (deduped, telemetry)
    }

    private func dedupeAISubjectCandidates(_ input: [HKAISubjectCandidate]) -> [HKAISubjectCandidate] {
        let sorted = input.sorted { lhs, rhs in
            if lhs.confidence == rhs.confidence {
                return (lhs.boundingBox.width * lhs.boundingBox.height) > (rhs.boundingBox.width * rhs.boundingBox.height)
            }
            return lhs.confidence > rhs.confidence
        }

        var deduped: [HKAISubjectCandidate] = []

        for candidate in sorted {
            let overlapsExisting = deduped.contains { existing in
                rectIOU(candidate.boundingBox, existing.boundingBox) > 0.58 ||
                normalizedRectCenterDistance(candidate.boundingBox, existing.boundingBox) < 0.06
            }

            if !overlapsExisting {
                deduped.append(candidate)
            }
        }

        return deduped
    }
    private func detectFreshFace(at seconds: Double) -> CGRect? {
        guard let cgImage = uprightFrameCGImageForAI(at: seconds) else {
            aiDetectorTelemetry = [
                "detector_mode": "ROBUST_V2",
                "detector_state": "no_upright_frame"
            ]
            return nil
        }

        let result = robustDetectSubject(in: cgImage)
        aiDetectorTelemetry = result.telemetry

        if let rect = result.rect {
            trackedFaceObservation = VNDetectedObjectObservation(boundingBox: rect)
            return rect
        }

        return nil
    }

    private func uprightFrameCGImageForAI(at seconds: Double) -> CGImage? {

        // 🔥 FIRST: try live playback frame via pixelBuffer
        if let frame = livePlaybackEngine.currentFrame() {
            let liveCI = CIImage(cvPixelBuffer: frame.pixelBuffer)
                .applyingFilter("CIHighlightShadowAdjust", parameters: [
                    "inputShadowAmount": 1.0,
                    "inputHighlightAmount": 0.0
                ])
                .applyingFilter("CIExposureAdjust", parameters: [
                    kCIInputEVKey: 1.6
                ])
                .applyingFilter("CIColorControls", parameters: [
                    kCIInputBrightnessKey: 0.45,
                    kCIInputContrastKey: 2.8,
                    kCIInputSaturationKey: 0.0
                ])

            if let liveCG = aiWorkingCIContext.createCGImage(liveCI, from: liveCI.extent) {
                return liveCG
            }
        }

        // 🔥 FALLBACK: AVAssetImageGenerator
        guard currentVideoURL != nil else { return nil }
        guard let generator = aiFrameGenerator else { return nil }

        let safeSeconds = max(0.0, seconds)
        let time = CMTime(seconds: safeSeconds, preferredTimescale: 600)

        guard let rawCG = try? generator.copyCGImage(at: time, actualTime: nil) else {
            return nil
        }

        let ci = CIImage(cgImage: rawCG)
            .applyingFilter("CIHighlightShadowAdjust", parameters: [
                "inputShadowAmount": 1.0,
                "inputHighlightAmount": 0.0
            ])
            .applyingFilter("CIExposureAdjust", parameters: [
                kCIInputEVKey: 1.6
            ])
            .applyingFilter("CIColorControls", parameters: [
                kCIInputBrightnessKey: 0.45,
                kCIInputContrastKey: 2.8,
                kCIInputSaturationKey: 0.0
            ])

        return aiWorkingCIContext.createCGImage(ci, from: ci.extent)
    }

    private func robustDetectSubject(in cgImage: CGImage) -> (rect: CGRect?, telemetry: [String: Any]) {
        let base = CIImage(cgImage: cgImage)
        let extent = base.extent.integral
        let estimatedBrightness = estimateImageBrightness(from: base, extent: extent)
        aiFrameBrightness = estimatedBrightness
        let lowLight = estimatedBrightness < 0.42

        var variants: [(name: String, image: CIImage)] = [
            ("ROBUST_BASE", base),
            ("ROBUST_LIFTED", base
                .applyingFilter("CIHighlightShadowAdjust", parameters: [
                    "inputShadowAmount": 0.90,
                    "inputHighlightAmount": 0.10
                ])
                .applyingFilter("CIColorControls", parameters: [
                    kCIInputBrightnessKey: 0.06,
                    kCIInputContrastKey: 1.18,
                    kCIInputSaturationKey: 1.0
                ])),
            ("ROBUST_GRAY_CONTRAST", base
                .applyingFilter("CIColorControls", parameters: [
                    kCIInputSaturationKey: 0.0,
                    kCIInputBrightnessKey: 0.14,
                    kCIInputContrastKey: 1.65
                ])),
            ("ROBUST_GRAY_AGGRESSIVE", base
                .applyingFilter("CIColorControls", parameters: [
                    kCIInputSaturationKey: 0.0,
                    kCIInputBrightnessKey: 0.22,
                    kCIInputContrastKey: 2.10
                ])
                .applyingFilter("CIHighlightShadowAdjust", parameters: [
                    "inputShadowAmount": 1.0,
                    "inputHighlightAmount": 0.0
                ])),
            ("ROBUST_EXPOSURE_GRAY", base
                .applyingFilter("CIExposureAdjust", parameters: [
                    kCIInputEVKey: 0.45
                ])
                .applyingFilter("CIColorControls", parameters: [
                    kCIInputSaturationKey: 0.0,
                    kCIInputContrastKey: 1.45
                ]))
        ]

        if lowLight {
            variants.append(("ROBUST_LOWLIGHT_PUSH", base
                .applyingFilter("CIHighlightShadowAdjust", parameters: [
                    "inputShadowAmount": 1.0,
                    "inputHighlightAmount": 0.0
                ])
                .applyingFilter("CIExposureAdjust", parameters: [
                    kCIInputEVKey: 0.72
                ])
                .applyingFilter("CIColorControls", parameters: [
                    kCIInputSaturationKey: 0.0,
                    kCIInputBrightnessKey: 0.28,
                    kCIInputContrastKey: 2.28
                ])))
            variants.append(("ROBUST_LOWLIGHT_SOFT", base
                .applyingFilter("CIHighlightShadowAdjust", parameters: [
                    "inputShadowAmount": 0.96,
                    "inputHighlightAmount": 0.02
                ])
                .applyingFilter("CIExposureAdjust", parameters: [
                    kCIInputEVKey: 0.56
                ])
                .applyingFilter("CIColorControls", parameters: [
                    kCIInputBrightnessKey: 0.18,
                    kCIInputContrastKey: 1.82,
                    kCIInputSaturationKey: 0.0
                ])))
        }

        variants = variants.map { ($0.0, $0.1.cropped(to: extent)) }

        var ciCount = 0
        var visionCount = 0
        var bodyCount = 0
        var allCandidates: [(rect: CGRect, source: String, variant: String, confidence: CGFloat)] = []

        let detector = CIDetector(
            ofType: CIDetectorTypeFace,
            context: nil,
            options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        )

        for (variantName, variant) in variants {
            if let features = detector?.features(in: variant), !features.isEmpty {
                for case let face as CIFaceFeature in features {
                    let normalized = normalizedRect(fromCIDetectorRect: face.bounds, imageExtent: extent)
                    let area = normalized.width * normalized.height
                    if area >= 0.004 {
                        ciCount += 1
                        allCandidates.append((normalized, "ROBUST_CI", variantName, 0.68))
                    }
                }
            }

            guard let variantCG = aiWorkingCIContext.createCGImage(variant, from: extent) else { continue }

            let request = VNDetectFaceRectanglesRequest()
            if #available(iOS 17.0, *) {
                request.revision = VNDetectFaceRectanglesRequestRevision3
            }

            let handler = VNImageRequestHandler(cgImage: variantCG, options: [:])

            do {
                try handler.perform([request])
                if let results = request.results, !results.isEmpty {
                    for face in results {
                        let area = face.boundingBox.width * face.boundingBox.height
                        if area >= 0.004 {
                            visionCount += 1
                            allCandidates.append((face.boundingBox, "ROBUST_VISION", variantName, CGFloat(face.confidence)))
                        }
                    }
                }
            } catch {
                continue
            }
        }

        if lowLight || allCandidates.isEmpty {
            let bodyRequest = VNDetectHumanRectanglesRequest()
            bodyRequest.upperBodyOnly = false

            do {
                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                try handler.perform([bodyRequest])
                if let results = bodyRequest.results, !results.isEmpty {
                    for body in results {
                        let pseudo = pseudoFaceRect(fromBodyRect: body.boundingBox)
                        let area = pseudo.width * pseudo.height
                        if area >= 0.004 {
                            bodyCount += 1
                            allCandidates.append((pseudo, "ROBUST_BODY", "ROBUST_BODY_BASE", 0.65))
                        }
                    }
                }
            } catch {
                // ignore
            }
        }

        var telemetry: [String: Any] = [
            "detector_mode": "ROBUST_V2",
            "ci_face_count": ciCount,
            "vision_face_count": visionCount,
            "body_count": bodyCount,
            "candidate_count": allCandidates.count,
            "ai_frame_brightness": estimatedBrightness,
            "low_light_bias": lowLight
        ]

        if allCandidates.isEmpty {
            let fallback = CGRect(x: 0.35, y: 0.30, width: 0.30, height: 0.40)

            telemetry["detector_state"] = "fallback_subject"
            telemetry["acquired_via"] = "FALLBACK"
            telemetry["detector_variant"] = "CENTER_FALLBACK"
            telemetry["candidate_count"] = 1

            return (fallback, telemetry)
        }

        let previousRect = aiLastStableRect
        let best = allCandidates.max { lhs, rhs in
            scoreFaceRect(lhs.rect, previousRect: previousRect) < scoreFaceRect(rhs.rect, previousRect: previousRect)
        }

        guard let best else {
            telemetry["detector_state"] = "no_best_candidate"
            telemetry["acquired_via"] = "ROBUST_NONE"
            telemetry["detector_variant"] = "ROBUST_NONE"
            return (nil, telemetry)
        }

        telemetry["detector_state"] = "acquired_subject"
        telemetry["acquired_via"] = best.source
        telemetry["detector_variant"] = best.variant

        if aiVerboseLogging {
            print("AI DEBUG → ROBUST V2 SUBJECT:", best.source, best.variant, "ci:", ciCount, "vision:", visionCount, "body:", bodyCount)
        }

        return (best.rect, telemetry)
    }

    private func pseudoFaceRect(fromBodyRect body: CGRect) -> CGRect {
        let pseudoWidth = clamp(body.width * 0.52, min: 0.10, max: 0.55)
        let pseudoHeight = clamp(body.height * 0.34, min: 0.12, max: 0.42)
        let pseudoX = clamp(body.midX - (pseudoWidth * 0.5), min: 0.0, max: 1.0 - pseudoWidth)
        let pseudoY = clamp(body.origin.y + (body.height * 0.56), min: 0.0, max: 1.0 - pseudoHeight)

        return CGRect(x: pseudoX, y: pseudoY, width: pseudoWidth, height: pseudoHeight)
    }

    private func normalizedRect(fromCIDetectorRect rect: CGRect, imageExtent: CGRect) -> CGRect {
        guard imageExtent.width > 0, imageExtent.height > 0 else { return .zero }

        return CGRect(
            x: (rect.origin.x - imageExtent.origin.x) / imageExtent.width,
            y: (rect.origin.y - imageExtent.origin.y) / imageExtent.height,
            width: rect.width / imageExtent.width,
            height: rect.height / imageExtent.height
        )
    }

    private func scoreFaceRect(_ rect: CGRect, previousRect: CGRect?) -> CGFloat {
        let area = rect.width * rect.height
        let centerX = rect.midX
        let centerY = rect.midY
        let closeUpBoost = clamp((area - 0.040) / 0.16, min: 0.0, max: 1.0)

        let horizontalCenterBias = 1.0 - abs(centerX - 0.5) / 0.5
        let verticalCenterBias = 1.0 - abs(centerY - aiTargetHeroY) / max(aiTargetHeroY, 0.001)
        let centerBias = max(0.0, (horizontalCenterBias * 0.62) + (verticalCenterBias * 0.38))

        var continuityBonus: CGFloat = 0.0
        if let previousRect {
            let lowLightContinuityBoost: CGFloat = aiFrameBrightness < 0.40 ? 1.22 : 1.0
            continuityBonus += rectIOU(rect, previousRect) * faceContinuityIOUWeight * lowLightContinuityBoost
            continuityBonus += (1.0 - normalizedRectCenterDistance(rect, previousRect)) * faceContinuityDistWeight * lowLightContinuityBoost
        }

        let areaWeight = faceAreaWeight * (1.0 + (closeUpBoost * 0.18))
        let centerWeight = faceCenterWeight * (1.0 + (closeUpBoost * 0.10))
        return (area * areaWeight) + (centerBias * centerWeight) + continuityBonus
    }

    private func scoreFaceObservation(_ observation: VNFaceObservation, previousRect: CGRect?) -> CGFloat {
        let rect = observation.boundingBox
        let area = rect.width * rect.height
        let centerX = rect.midX
        let centerY = rect.midY

        let horizontalCenterBias = 1.0 - abs(centerX - 0.5) / 0.5
        let verticalCenterBias = 1.0 - abs(centerY - aiTargetHeroY) / max(aiTargetHeroY, 0.001)
        let centerBias = max(0.0, (horizontalCenterBias * 0.60) + (verticalCenterBias * 0.40))

        var continuityBonus: CGFloat = 0.0
        if let previousRect {
            continuityBonus += rectIOU(rect, previousRect) * (faceContinuityIOUWeight * 0.92)
            continuityBonus += (1.0 - normalizedRectCenterDistance(rect, previousRect)) * (faceContinuityDistWeight * 0.92)
        }

        return (area * (faceAreaWeight * 0.92))
            + (centerBias * (faceCenterWeight * 0.92))
            + continuityBonus
            + (CGFloat(observation.confidence) * 0.42)
    }

    private func aiOffsetForSubjectRect(_ rect: CGRect?) -> CGPoint {
        guard let rect else {
            previousAISubjectCenterX = nil
            smoothedAISubjectVelocityX = 0
            return .zero
        }

        let visualCenterX = rect.origin.x + (rect.size.width * 0.5)
        let visualCenterY = rect.origin.y + (rect.size.height * 0.5)
        let subjectCenterY = 1.0 - visualCenterY

        let subjectArea = rect.width * rect.height
        let closeUpLock = clamp((subjectArea - 0.045) / 0.22, min: 0.0, max: 1.0)

        let centerYError = aiTargetHeroY - subjectCenterY

        let rawSubjectVelocityX: CGFloat
        if let previousX = previousAISubjectCenterX {
            rawSubjectVelocityX = visualCenterX - previousX
        } else {
            rawSubjectVelocityX = 0
        }
        previousAISubjectCenterX = visualCenterX

        smoothedAISubjectVelocityX += (rawSubjectVelocityX - smoothedAISubjectVelocityX) * 0.34
        let subjectVelocityX = clamp(smoothedAISubjectVelocityX * 8.0, min: -1.0, max: 1.0)

        // Give AI more real horizontal room.
        // Close-ups stay calmer. Wider shots get much more authority.
        let maxX = maxTravelX * (0.72 - (closeUpLock * 0.16))
        let maxY = maxTravelY * ((aiAssistMaxTravelUsage * 0.84) + (closeUpLock * 0.03))

        // Work directly in stage space for X so we do not crush composition twice.
        var targetX = applyCinematicComposition(
            subjectCenterX: visualCenterX,
            subjectVelocityX: subjectVelocityX,
            confidence: aiLockConfidence,
            closeUpLock: closeUpLock,
            maxDx: maxX
        )

        var targetYNorm =
            centerYError * (aiYStrength + (closeUpLock * 0.10))

        targetYNorm += centerYError * (0.10 + (closeUpLock * 0.06))

        if abs(targetX) < max(0.50, maxX * 0.010) { targetX *= 0.82 }
        if abs(targetYNorm) < 0.008 { targetYNorm *= 0.70 }

        let edgeThresholdX: CGFloat = 0.14
        let edgeThresholdY: CGFloat = 0.14

        if visualCenterX < edgeThresholdX {
            targetX += (edgeThresholdX - visualCenterX) * maxX * 0.95
        } else if visualCenterX > (1.0 - edgeThresholdX) {
            targetX -= (visualCenterX - (1.0 - edgeThresholdX)) * maxX * 0.95
        }

        if subjectCenterY < edgeThresholdY {
            targetYNorm += (edgeThresholdY - subjectCenterY) * edgeProtectionY
        } else if subjectCenterY > (1.0 - edgeThresholdY) {
            targetYNorm -= (subjectCenterY - (1.0 - edgeThresholdY)) * edgeProtectionY
        }

        targetX = clamp(targetX, min: -maxX, max: maxX)
        targetYNorm = clamp(targetYNorm, min: -0.36, max: 0.36)

        return CGPoint(
            x: targetX,
            y: targetYNorm * maxY
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



    private func currentLookControlTracePayload() -> [String: Any] {
        [
            "depth_intensity": Double(playerView.depthIntensity),
            "focus_falloff": Double(playerView.focusFalloff),
            "bg_plane": Double(playerView.bgPlaneControl),
            "mid_plane": Double(playerView.midPlaneControl),
            "fg_plane": Double(playerView.fgPlaneControl),
            "framing_scale": Double(framingScale),
            "mode_index": currentModeIndex,
            "lens_mode": playerView.lensMode.rawValue,
            "lut_mode": playerView.lutMode.rawValue,
            "is_ai_enabled": isAIEnabled,
            "is_tilt_enabled": isTiltEnabled,
            "is_peek_enabled": isPeekEnabled,
            "ai_tilt_assist_enabled": aiTiltAssistEnabled,
            "ai_peek_assist_enabled": aiPeekAssistEnabled,
            "is_depth_preview_enabled": isDepthPreviewEnabled,
            "is_scrubbing": isScrubbing,
            "is_preparing_depth": isPreparingDepth,
            "depth_generation_progress": depthGenerationProgress,
            "current_content_profile": currentContentProfile.rawValue,
            "current_shot_class": aiCurrentShotClass.rawValue,
            "frame_brightness": Double(aiFrameBrightness),
            "stage_travel_x": Double(maxTravelX),
            "stage_travel_y": Double(maxTravelY),
            "current_stage_offset_x": Double(currentStageOffset.x),
            "current_stage_offset_y": Double(currentStageOffset.y)
        ]
    }

    // MARK: - Loaders


    private func showClipLoadStatus(_ text: String) {
        controlBar.setStatusChipText(text)
        showControlBar(animated: true, scheduleHide: false)
    }

    private func presentPhotoPicker() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = .videos

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func presentDocumentPicker() {
        let types: [UTType] = [.movie, .mpeg4Movie, .video]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.delegate = self
        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        showClipLoadStatus("IMPORTING CLIP…")

        guard let provider = results.first?.itemProvider else { return }
        guard provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) else { return }

        provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, _ in
            guard let self = self, let url else { return }

            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
            try? FileManager.default.removeItem(at: tempURL)

            do {
                do {
                    try FileManager.default.moveItem(at: url, to: tempURL)
                } catch {
                    // fallback if move fails (iCloud, etc)
                    try? FileManager.default.copyItem(at: url, to: tempURL)
                }
                DispatchQueue.main.async {
                    self.loadVideo(url: tempURL)
                }
            } catch {
                DispatchQueue.main.async {
                    self.debugLabel.text = "Failed to import video from Photos."
                    self.debugLabel.isHidden = true
                    self.showClipLoadStatus("IMPORT FAILED")
                }
            }
        }
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let pickedURL = urls.first else { return }
        showClipLoadStatus("OPENING CLIP…")
        loadVideo(url: pickedURL)
    }
    
    private func cleanupImportedVideoCache() {
        let fm = FileManager.default
        let cacheDir = fm.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? fm.temporaryDirectory

        let importedDir = cacheDir.appendingPathComponent("HKV1ImportedVideos", isDirectory: true)

        guard let files = try? fm.contentsOfDirectory(at: importedDir, includingPropertiesForKeys: nil) else {
            return
        }

        for file in files {
            try? fm.removeItem(at: file)
        }
    }

    private func currentDepthAmplificationMultiplier() -> CGFloat {
        switch currentModeIndex {
        case 2: return 2.35
        case 1: return 1.35
        default: return 1.0
        }
    }

    // MARK: - Debug

    private func updateDebugLabel(maskFrame: CGRect, stageSize: CGSize, isPortrait: Bool) {
        let mode = isPortrait ? "PORTRAIT" : "LANDSCAPE"
        let depthState = isDepthPreviewEnabled ? "ON" : "OFF"
        let depthLoaded = hasLoadedDepthSidecar ? "YES" : "NO"
        let lane = isAIEnabled ? "AI" : ((isTiltEnabled || isPeekEnabled) ? "MANUAL" : "OFF")
        let depthLock = hasLoadedDepthSidecar ? "LIVE" : "NONE"
        let depthPrepState: String = {
            if isPreparingDepth {
                return String(format: "GENERATING %.0f%%", depthGenerationProgress * 100.0)
            }
            return hasLoadedDepthSidecar ? "READY" : "NONE"
        }()

        debugLabel.text =
            """
            Phase 21A • Upload Depth Fast Pass
            mode: \(mode)
            lane: \(lane)\n            depthAmp: \(String(format: "%.2f", currentModeIndex == 2 ? depthMotionAmplificationWide : (currentModeIndex == 1 ? depthMotionAmplificationClose : 1.0)))
            lens: \(playerView.lensMode.rawValue)
            mask: \(Int(maskFrame.width)) x \(Int(maskFrame.height))
            stage: \(Int(stageSize.width)) x \(Int(stageSize.height))
            travelX: ±\(String(format: "%.1f", maxTravelX))
            travelY: ±\(String(format: "%.1f", maxTravelY))
            rawTilt: \(String(format: "%.3f", lastRawTiltX)), \(String(format: "%.3f", lastRawTiltY))
            applied: \(String(format: "%.1f", lastAppliedDx)), \(String(format: "%.1f", lastAppliedDy))
            offset: \(String(format: "%.1f", currentStageOffset.x)), \(String(format: "%.1f", currentStageOffset.y))
            depth: \(String(format: "%.2f", playerView.depthIntensity))
            focus: \(String(format: "%.2f", playerView.focusFalloff))
            bg/mid/fg: \(String(format: "%.2f", playerView.bgPlaneControl)) / \(String(format: "%.2f", playerView.midPlaneControl)) / \(String(format: "%.2f", playerView.fgPlaneControl))
            depthPreview: \(depthState)
            depthLoaded: \(depthLoaded)
            depthPrep: \(depthPrepState)
            depthFile: \(loadedDepthFileName)
            depthLock: \(depthLock)
            chromeVisible: \(isControlBarVisible ? "YES" : "NO")
            chromeLocks: \(chromeInteractionLocks)
            """
    }


    private func estimateImageBrightness(from image: CIImage, extent: CGRect) -> CGFloat {
        guard !extent.isEmpty else { return 0.5 }

        let average = image
            .applyingFilter("CIAreaAverage", parameters: [kCIInputExtentKey: CIVector(cgRect: extent)])
            .cropped(to: CGRect(x: 0, y: 0, width: 1, height: 1))

        var bitmap = [UInt8](repeating: 0, count: 4)
        aiWorkingCIContext.render(
            average,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )

        let r = CGFloat(bitmap[0]) / 255.0
        let g = CGFloat(bitmap[1]) / 255.0
        let b = CGFloat(bitmap[2]) / 255.0
        return clamp((0.299 * r) + (0.587 * g) + (0.114 * b), min: 0.0, max: 1.0)
    }

    // MARK: - Utils

    private func clamp(_ value: CGFloat, min minValue: CGFloat, max maxValue: CGFloat) -> CGFloat {
        Swift.max(minValue, Swift.min(maxValue, value))
    }
}
