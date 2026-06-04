import UIKit
import AVFoundation
import CoreImage
import QuartzCore

final class HKV1_PlayerLayerView: UIView {

    enum LensMode: Int {
        case natural = 0
        case anamorphic = 1
        case portrait = 2
    }

    enum SpatialMode {
        case flat
        case threePlane
    }

    enum RenderMode {
        case flat
        case depthPrepared
    }

    enum LUTMode: Int {
        case off = 0
        case lux = 1
        case highfiveDay = 2
        case highfiveNight = 3
        case highfiveWarm = 4
        case highfiveMono = 5
    }

    // MARK: - Public Playback / State

    var player: AVPlayer? {
        didSet {
            flatPlayerLayer.player = player
            bgPlayerLayer.player = player
            midPlayerLayer.player = player
            fgPlayerLayer.player = player
        }
    }

    var spatialMode: SpatialMode = .flat {
        didSet { applyMode() }
    }

    var renderMode: RenderMode = .flat {
        didSet {
            switch renderMode {
            case .flat:
                spatialMode = .flat
            case .depthPrepared:
                spatialMode = .threePlane
            }
        }
    }

    var allowsFallbackFullFrameMasks: Bool = false {
        didSet { rebuildPlaneMasks() }
    }

    var lensMode: LensMode = .natural {
        didSet {
            if !planeAuthorityHasBeenUserCustomized {
                applyLensDefaults(force: true)
            }
            updatePlaneTransforms()
            applyMode()
        }
    }

    var lutMode: LUTMode = .off {
        didSet {
            updateCinematicFinish()
            applyMode()
        }
    }

    var depthIntensity: CGFloat = 1.0 {
        didSet {
            depthIntensity = clamp(depthIntensity, min: 0.0, max: 3.0)
            updatePlaneTransforms()
            updateCinematicFinish()
        }
    }

    var focusFalloff: CGFloat = 0.20 {
        didSet {
            focusFalloff = clamp(focusFalloff, min: 0.0, max: 1.0)
            updatePlaneTransforms()
            updateCinematicFinish()
        }
    }

    var bgPlaneControl: CGFloat = 0.70 {
        didSet {
            planeAuthorityHasBeenUserCustomized = true
            bgPlaneControl = clamp(bgPlaneControl, min: 0.20, max: 2.20)
            updatePlaneTransforms()
            applyMode()
        }
    }

    var midPlaneControl: CGFloat = 1.20 {
        didSet {
            planeAuthorityHasBeenUserCustomized = true
            midPlaneControl = clamp(midPlaneControl, min: 0.20, max: 2.40)
            updatePlaneTransforms()
            applyMode()
        }
    }

    var fgPlaneControl: CGFloat = 1.45 {
        didSet {
            planeAuthorityHasBeenUserCustomized = true
            fgPlaneControl = clamp(fgPlaneControl, min: 0.20, max: 2.80)
            updatePlaneTransforms()
            applyMode()
        }
    }

    private var planeAuthorityHasBeenUserCustomized = false

    private var _bgOffset: CGPoint = .zero
    private var _midOffset: CGPoint = .zero
    private var _fgOffset: CGPoint = .zero

    var bgOffset: CGPoint {
        get { _bgOffset }
        set {
            _bgOffset = newValue
            updatePlaneTransforms()
        }
    }

    var midOffset: CGPoint {
        get { _midOffset }
        set {
            _midOffset = newValue
            updatePlaneTransforms()
        }
    }

    var fgOffset: CGPoint {
        get { _fgOffset }
        set {
            _fgOffset = newValue
            updatePlaneTransforms()
        }
    }

    // MARK: - Lens Profile

    private struct LensProfile {
        let bgPlane: CGFloat
        let midPlane: CGFloat
        let fgPlane: CGFloat

        let lateralBias: CGFloat
        let verticalBias: CGFloat
        let fgProtection: CGFloat

        let bgScaleBias: CGFloat
        let midScaleBias: CGFloat
        let fgScaleBias: CGFloat

        let flatOpacityBase: CGFloat
        let bgOpacityBoost: CGFloat
        let midOpacityBoost: CGFloat
        let fgOpacityBoost: CGFloat

        let topShoulderBase: CGFloat
        let topShoulderDepthGain: CGFloat
        let vignetteBase: CGFloat
        let vignetteFocusGain: CGFloat
        let grainBase: CGFloat
        let grainDepthGain: CGFloat

        let bgTravelGain: CGFloat
        let midTravelGain: CGFloat
        let fgTravelGain: CGFloat
    }

    private enum LensModel {
        static func profile(for mode: LensMode) -> LensProfile {
            let base = HKV1_LensModel.profile(for: mode)
            return LensProfile(
                bgPlane: base.bgPlane,
                midPlane: base.midPlane,
                fgPlane: base.fgPlane,
                lateralBias: base.lateralBias,
                verticalBias: base.verticalBias,
                fgProtection: base.fgProtection,
                bgScaleBias: base.bgScaleBias,
                midScaleBias: base.midScaleBias,
                fgScaleBias: base.fgScaleBias,
                flatOpacityBase: base.flatOpacityBase,
                bgOpacityBoost: base.bgOpacityBoost,
                midOpacityBoost: base.midOpacityBoost,
                fgOpacityBoost: base.fgOpacityBoost,
                topShoulderBase: base.topShoulderBase,
                topShoulderDepthGain: base.topShoulderDepthGain,
                vignetteBase: base.vignetteBase,
                vignetteFocusGain: base.vignetteFocusGain,
                grainBase: base.grainBase,
                grainDepthGain: base.grainDepthGain,
                bgTravelGain: base.bgTravelGain,
                midTravelGain: base.midTravelGain,
                fgTravelGain: base.fgTravelGain
            )
        }
    }

    private struct MaskQuality {
        var bgCoverage: CGFloat = 0
        var midCoverage: CGFloat = 0
        var fgCoverage: CGFloat = 0
        var supportCoverage: CGFloat = 0

        var shellStrength: CGFloat {
            let continuity: CGFloat = midCoverage * 0.68
            let support: CGFloat = supportCoverage * 0.24
            let accents: CGFloat = Swift.min(CGFloat(0.10), (bgCoverage * 0.03) + (fgCoverage * 0.07))
            let value: CGFloat = continuity + support + accents
            return Swift.max(CGFloat(0.0), Swift.min(CGFloat(1.0), value))
        }

        var midDominance: CGFloat {
            let value: CGFloat = (midCoverage * 0.80) + (supportCoverage * 0.20)
            return Swift.max(CGFloat(0.0), Swift.min(CGFloat(1.0), value))
        }

        var weakness: CGFloat {
            1.0 - shellStrength
        }
    }

    private struct ShellTuning {
        static let restBGScale: CGFloat = 1.001
        static let restMIDScale: CGFloat = 1.003
        static let restFGScale: CGFloat = 1.006

        static let moveBGScale: CGFloat = 1.010
        static let moveMIDScale: CGFloat = 1.018
        static let moveFGScale: CGFloat = 1.032

        static let bgXBoost: CGFloat = 0.34
        static let bgYBoost: CGFloat = 0.05

        static let midXBoost: CGFloat = 0.72
        static let midYBoost: CGFloat = 0.10

        static let fgXBoost: CGFloat = 0.96
        static let fgYBoost: CGFloat = 0.12

        static let fgMotionOpacityFloor: CGFloat = 0.010
        static let fgMotionOpacityCeiling: CGFloat = 0.080

        static let bgMotionOpacityFloor: CGFloat = 0.010
        static let bgMotionOpacityCeiling: CGFloat = 0.055

        static let midMotionOpacityFloor: CGFloat = 0.955
        static let midMotionOpacityCeiling: CGFloat = 0.995

        static let motionGhostControlStart: CGFloat = 6.0
        static let motionGhostControlFull: CGFloat = 18.0
    }

    private let ciContext = CIContext(options: [
        .cacheIntermediates: false,
        .useSoftwareRenderer: false
    ])

    // MARK: - Layer Stack

    private let flatPlayerLayer = AVPlayerLayer()

    private let bgContainer = CALayer()
    private let midContainer = CALayer()
    private let fgContainer = CALayer()

    private let bgPlayerLayer = AVPlayerLayer()
    private let midPlayerLayer = AVPlayerLayer()
    private let fgPlayerLayer = AVPlayerLayer()

    private let bgMaskHost = CALayer()
    private let midMaskHost = CALayer()
    private let fgMaskHost = CALayer()

    private let topShoulderLayer = CAGradientLayer()
    private let bottomVignetteLayer = CAGradientLayer()
    private let lutContrastLayer = CALayer()
    private let lutColorWashLayer = CAGradientLayer()
    private let lutBlackFloorLayer = CAGradientLayer()
    private let lutHighlightBloomLayer = CAGradientLayer()
    private let filmGrainLayer = CALayer()

    private var fallbackMaskImage: CGImage?
    private var maskQuality = MaskQuality()
    private var currentMotionMagnitude: CGFloat = 0

    var aiModeActive: Bool = false {
        didSet {
            applyMode()
            updatePlaneTransforms()
        }
    }

    var seamSafeModeEnabled: Bool = true {
        didSet {
            applyMode()
            updatePlaneTransforms()
        }
    }

    private var lastDepthSignature: Int = 0
    private var lastDepthMaskRebuildTime: CFTimeInterval = 0
    private let minDepthMaskRebuildInterval: CFTimeInterval = 1.0 / 12.0
    private var depthMaskRebuildSuspended = false

    override class var layerClass: AnyClass {
        CALayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        flatPlayerLayer.frame = bounds

        bgContainer.frame = bounds
        midContainer.frame = bounds
        fgContainer.frame = bounds

        bgPlayerLayer.frame = bounds
        midPlayerLayer.frame = bounds
        fgPlayerLayer.frame = bounds

        bgMaskHost.frame = bounds
        midMaskHost.frame = bounds
        fgMaskHost.frame = bounds

        topShoulderLayer.frame = bounds
        bottomVignetteLayer.frame = bounds
        lutContrastLayer.frame = bounds
        lutColorWashLayer.frame = bounds
        lutBlackFloorLayer.frame = bounds
        lutHighlightBloomLayer.frame = bounds
        filmGrainLayer.frame = bounds

        rebuildPlaneMasks()
        updatePlaneTransforms()
        updateCinematicFinish()
        applyMode()

        CATransaction.commit()
    }

    // MARK: - Public Helpers

    func resetSpatialOffsets() {
        _bgOffset = .zero
        _midOffset = .zero
        _fgOffset = .zero
        currentMotionMagnitude = 0

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        bgContainer.setAffineTransform(.identity)
        midContainer.setAffineTransform(.identity)
        fgContainer.setAffineTransform(.identity)
        CATransaction.commit()

        setNeedsLayout()
    }

    func clearDepthMasks() {
        fallbackMaskImage = nil
        bgMaskHost.contents = nil
        midMaskHost.contents = nil
        fgMaskHost.contents = nil

        bgContainer.mask = nil
        midContainer.mask = nil
        fgContainer.mask = nil

        maskQuality = MaskQuality()

        lastDepthSignature = 0
        lastDepthMaskRebuildTime = 0

        applyMode()
    }

    func setMetalLiveModeEnabled(_ enabled: Bool) {
        _ = enabled
    }

    func setDepthMaskRebuildSuspended(_ suspended: Bool) {
        depthMaskRebuildSuspended = suspended
    }

    // MARK: - Setup

    private func commonInit() {
        backgroundColor = .black
        isOpaque = true
        clipsToBounds = true

        configure(playerLayer: flatPlayerLayer)
        configure(playerLayer: bgPlayerLayer)
        configure(playerLayer: midPlayerLayer)
        configure(playerLayer: fgPlayerLayer)

        bgContainer.masksToBounds = true
        midContainer.masksToBounds = true
        fgContainer.masksToBounds = true

        bgContainer.addSublayer(bgPlayerLayer)
        midContainer.addSublayer(midPlayerLayer)
        fgContainer.addSublayer(fgPlayerLayer)

        bgContainer.mask = bgMaskHost
        midContainer.mask = midMaskHost
        fgContainer.mask = fgMaskHost

        bgMaskHost.contentsGravity = .resizeAspectFill
        midMaskHost.contentsGravity = .resizeAspectFill
        fgMaskHost.contentsGravity = .resizeAspectFill

        configureGlobalFinish()
        configureLUTFinishLayers()
        configureFilmGrain()

        layer.addSublayer(flatPlayerLayer)
        layer.addSublayer(bgContainer)
        layer.addSublayer(midContainer)
        layer.addSublayer(fgContainer)
        layer.addSublayer(topShoulderLayer)
        layer.addSublayer(lutContrastLayer)
        layer.addSublayer(lutColorWashLayer)
        layer.addSublayer(lutBlackFloorLayer)
        layer.addSublayer(lutHighlightBloomLayer)
        layer.addSublayer(bottomVignetteLayer)
        layer.addSublayer(filmGrainLayer)

        applyLensDefaults(force: true)
        rebuildPlaneMasks()
        updatePlaneTransforms()
        updateCinematicFinish()
        applyMode()
    }

    private func configure(playerLayer: AVPlayerLayer) {
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.contentsScale = UIScreen.main.scale
        playerLayer.masksToBounds = true
    }

    private func configureGlobalFinish() {
        topShoulderLayer.colors = [
            UIColor.black.withAlphaComponent(0.10).cgColor,
            UIColor.black.withAlphaComponent(0.035).cgColor,
            UIColor.clear.cgColor
        ]
        topShoulderLayer.locations = [0.0, 0.20, 0.54]
        topShoulderLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        topShoulderLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        topShoulderLayer.opacity = 0.0

        bottomVignetteLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.05).cgColor,
            UIColor.black.withAlphaComponent(0.12).cgColor
        ]
        bottomVignetteLayer.locations = [0.48, 0.83, 1.0]
        bottomVignetteLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        bottomVignetteLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        bottomVignetteLayer.opacity = 0.0
    }

    private func configureLUTFinishLayers() {
        lutContrastLayer.opacity = 0.0
        lutContrastLayer.compositingFilter = "overlayBlendMode"
        lutContrastLayer.backgroundColor = UIColor(white: 0.50, alpha: 1.0).cgColor

        lutColorWashLayer.opacity = 0.0
        lutColorWashLayer.compositingFilter = "softLightBlendMode"
        lutColorWashLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        lutColorWashLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        lutColorWashLayer.locations = [0.0, 0.45, 1.0]
        lutColorWashLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.clear.cgColor,
            UIColor.clear.cgColor
        ]

        lutBlackFloorLayer.opacity = 0.0
        lutBlackFloorLayer.compositingFilter = "multiplyBlendMode"
        lutBlackFloorLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        lutBlackFloorLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        lutBlackFloorLayer.locations = [0.0, 0.55, 1.0]
        lutBlackFloorLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.08).cgColor,
            UIColor.black.withAlphaComponent(0.28).cgColor
        ]

        lutHighlightBloomLayer.opacity = 0.0
        lutHighlightBloomLayer.compositingFilter = "screenBlendMode"
        lutHighlightBloomLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        lutHighlightBloomLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        lutHighlightBloomLayer.locations = [0.0, 0.22, 0.56, 1.0]
        lutHighlightBloomLayer.colors = [
            UIColor.white.withAlphaComponent(0.28).cgColor,
            UIColor.white.withAlphaComponent(0.10).cgColor,
            UIColor.clear.cgColor,
            UIColor.clear.cgColor
        ]
    }


    private func configureFilmGrain() {
        filmGrainLayer.opacity = 0.026
        filmGrainLayer.compositingFilter = "overlayBlendMode"
        filmGrainLayer.contentsGravity = .resizeAspectFill

        let size = CGSize(width: 128, height: 128)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { ctx in
            for _ in 0..<900 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let alpha = CGFloat.random(in: 0.012...0.050)
                UIColor(white: 1.0, alpha: alpha).setFill()
                ctx.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }

        filmGrainLayer.contents = image.cgImage
    }

    // MARK: - Lens / Mode

    private func applyLensDefaults(force: Bool) {
        let profile = LensModel.profile(for: lensMode)
        if force || !planeAuthorityHasBeenUserCustomized {
            planeAuthorityHasBeenUserCustomized = false
            bgPlaneControl = profile.bgPlane
            midPlaneControl = profile.midPlane
            fgPlaneControl = profile.fgPlane
            planeAuthorityHasBeenUserCustomized = false
        }
    }

    private func applyMode() {
        let showSpatial = spatialMode == .threePlane
        let hasMasks = (
            bgMaskHost.contents != nil ||
            midMaskHost.contents != nil ||
            fgMaskHost.contents != nil ||
            allowsFallbackFullFrameMasks
        )

        let showPlanes = showSpatial && hasMasks
        let weakness = maskQuality.weakness
        let midDominance = maskQuality.midDominance
        let edgeTightening = clamp(midDominance * 1.45, min: 0.0, max: 1.0)
        let motionGhostSuppression = ghostSuppressionFactor()
        let centerContinuity = centerRenderContinuity(currentMotionMagnitude)
        let profile = LensModel.profile(for: lensMode)
        let depthBoost = depthVisualBoost()
        let lutStrength = self.lutStrength()
        let lutFlatBias = lutFlatOpacityBias()
        let seamCollapse = seamCollapseFactor()
        let shellAuthority = 1.0 - seamCollapse

        let flatOpacity: CGFloat
        let bgOpacity: CGFloat
        let midOpacity: CGFloat
        let fgOpacity: CGFloat

        if showPlanes {
            let baseFlatOpacity = clamp(
                profile.flatOpacityBase
                    - 0.05
                    - ((depthBoost - 1.0) * 0.12)
                    + (weakness * 0.10)
                    + (motionGhostSuppression * 0.02)
                    - (centerContinuity * 0.010)
                    + lutFlatBias
                    - (lutStrength * 0.010),
                min: 0.46,
                max: 0.84
            )

            let bgOpacityControl = planeAuthorityBoost(control: bgPlaneControl, base: 0.72, cap: 1.62)
            let midOpacityControl = planeAuthorityBoost(control: midPlaneControl, base: 0.94, cap: 1.30)
            let fgOpacityControl = planeAuthorityBoost(control: fgPlaneControl, base: 0.92, cap: 2.30)

            let bgBase = 0.022 + (maskQuality.bgCoverage * 0.060) + (weakness * 0.020) + profile.bgOpacityBoost + (centerContinuity * 0.004)
            let bgBaseOpacity = clamp(
                bgBase * depthBoost * (1.0 - (motionGhostSuppression * 0.14)) * bgOpacityControl,
                min: 0.016,
                max: 0.135
            )

            let midBase = 0.936 + (midDominance * 0.050) + ((depthBoost - 1.0) * 0.028) + (motionGhostSuppression * 0.006) + profile.midOpacityBoost + (centerContinuity * 0.010)
            let midBaseOpacity = clamp(
                midBase * midOpacityControl,
                min: 0.90,
                max: 1.00
            )

            let fgBase = 0.058 + (maskQuality.fgCoverage * 0.090) + ((depthBoost - 1.0) * 0.060) + profile.fgOpacityBoost + (centerContinuity * 0.014)
            let fgReducedForEdges = fgBase * (1.0 - (edgeTightening * 0.42))
            let fgReducedForMotion = fgReducedForEdges * (1.0 - (motionGhostSuppression * 0.56))
            let fgBaseOpacity = clamp(
                (fgReducedForMotion - (weakness * 0.003)) * fgOpacityControl,
                min: 0.040,
                max: 0.210
            )

            flatOpacity = clamp(
                baseFlatOpacity + (seamCollapse * 0.42),
                min: 0.50,
                max: 1.00
            )

            bgOpacity = clamp(
                bgBaseOpacity * (shellAuthority * shellAuthority),
                min: 0.0,
                max: 0.135
            )

            midOpacity = clamp(
                lerp(1.0, midBaseOpacity, shellAuthority),
                min: 0.0,
                max: 1.0
            )

            fgOpacity = clamp(
                fgBaseOpacity * (shellAuthority * shellAuthority * shellAuthority),
                min: 0.0,
                max: 0.210
            )
        } else {
            flatOpacity = 1.0
            bgOpacity = 0.0
            midOpacity = 0.0
            fgOpacity = 0.0
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        flatPlayerLayer.isHidden = false
        flatPlayerLayer.opacity = Float(flatOpacity)

        bgContainer.isHidden = false
        midContainer.isHidden = false
        fgContainer.isHidden = false

        bgContainer.opacity = Float(bgOpacity)
        midContainer.opacity = Float(midOpacity)
        fgContainer.opacity = Float(fgOpacity)

        CATransaction.commit()

        updateCinematicFinish()
    }

    private func updateCinematicFinish() {
        let showSpatial = (spatialMode == .threePlane)
        let depth = clamp(depthIntensity, min: 0.0, max: 3.0)
        let focus = clamp(focusFalloff, min: 0.0, max: 1.0)
        let weakness = maskQuality.weakness
        let motionGhostSuppression = ghostSuppressionFactor()
        let profile = LensModel.profile(for: lensMode)

        let lutStrength = self.lutStrength()
        let shoulderBias = lutShoulderBias()
        let vignetteBias = lutVignetteBias()
        let grainBias = lutGrainBias()
        let contrastBias = lutContrastBias()
        let blackFloorBias = lutBlackFloorBias()
        let bloomBias = lutBloomBias()

        let warmTop = lutWarmTintTopColor()
        let warmMid = lutWarmTintMidColor()
        let warmBottom = lutWarmTintBottomColor()

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        // Spatial-only cinematic finish
        if showSpatial {
            topShoulderLayer.opacity = Float(
                clamp(
                    profile.topShoulderBase
                        + (depth * profile.topShoulderDepthGain)
                        + (weakness * 0.050)
                        - (motionGhostSuppression * 0.012)
                        + shoulderBias
                        + (lutStrength * 0.030),
                    min: 0.030,
                    max: 0.34
                )
            )

            bottomVignetteLayer.opacity = Float(
                clamp(
                    profile.vignetteBase
                        + (focus * profile.vignetteFocusGain)
                        + (weakness * 0.050)
                        + vignetteBias
                        + (lutStrength * 0.022),
                    min: 0.025,
                    max: 0.34
                )
            )

            filmGrainLayer.opacity = Float(
                clamp(
                    profile.grainBase
                        + (depth * profile.grainDepthGain)
                        + grainBias
                        + (lutStrength * 0.018),
                    min: 0.016,
                    max: 0.13
                )
            )
        } else {
            // Keep subtle finish even in flat mode
            topShoulderLayer.opacity = Float(clamp(0.020 + shoulderBias + (lutStrength * 0.010), min: 0.0, max: 0.12))
            bottomVignetteLayer.opacity = Float(clamp(0.020 + vignetteBias + (lutStrength * 0.010), min: 0.0, max: 0.14))
            filmGrainLayer.opacity = Float(clamp(0.026 + grainBias + (lutStrength * 0.010), min: 0.02, max: 0.10))
        }

        // LUT finish layers should work in BOTH flat and spatial modes
        lutContrastLayer.backgroundColor = lutContrastFillColor().cgColor
        lutContrastLayer.opacity = Float(
            showSpatial
            ? clamp(contrastBias + (lutStrength * 0.18), min: 0.0, max: 0.34)
            : clamp(contrastBias + (lutStrength * 0.18), min: 0.0, max: 0.26)
        )

        lutColorWashLayer.colors = [
            warmTop.cgColor,
            warmMid.cgColor,
            warmBottom.cgColor
        ]
        lutColorWashLayer.opacity = Float(
            showSpatial
            ? clamp(lutColorWashOpacity() + (lutStrength * 0.10), min: 0.0, max: 0.34)
            : clamp(lutColorWashOpacity() + (lutStrength * 0.08), min: 0.0, max: 0.24)
        )

        lutBlackFloorLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.10 + blackFloorBias * 0.45).cgColor,
            UIColor.black.withAlphaComponent(0.22 + blackFloorBias).cgColor
        ]
        lutBlackFloorLayer.opacity = Float(
            showSpatial
            ? clamp(blackFloorBias + (lutStrength * 0.08), min: 0.0, max: 0.38)
            : clamp(blackFloorBias + (lutStrength * 0.06), min: 0.0, max: 0.28)
        )

        lutHighlightBloomLayer.colors = [
            lutBloomTopColor().cgColor,
            lutBloomMidColor().cgColor,
            UIColor.clear.cgColor,
            UIColor.clear.cgColor
        ]
        lutHighlightBloomLayer.opacity = Float(
            showSpatial
            ? clamp(bloomBias + (lutStrength * 0.05), min: 0.0, max: 0.24)
            : clamp(bloomBias + (lutStrength * 0.04), min: 0.0, max: 0.18)
        )

        CATransaction.commit()
    }

    private func updatePlaneTransforms() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let depth = clamp(depthIntensity, min: 0.0, max: 2.5)
        let focus = clamp(focusFalloff, min: 0.0, max: 1.0)
        let profile = LensModel.profile(for: lensMode)

        let motionMagnitude = hypot(_midOffset.x, _midOffset.y)
        currentMotionMagnitude = motionMagnitude

        let centerContinuity = centerRenderContinuity(motionMagnitude)
        let motionT = clamp(motionMagnitude / 26.0, min: 0.0, max: 1.0)
        let motionDrivenBlend = motionT * motionT * (3.0 - (2.0 * motionT))
        let depthDrivenBlend = clamp(depth / 2.5, min: 0.0, max: 1.0)
        let movementBlend = clamp(max(motionDrivenBlend, depthDrivenBlend * 0.62), min: 0.0, max: 1.0)
        let motionGhostSuppression = ghostSuppressionFactor()
        let seamCollapse = seamCollapseFactor()
        let shellAuthority = 1.0 - seamCollapse

        let bgControl = clamp(bgPlaneControl, min: 0.20, max: 2.20)
        let midControl = clamp(midPlaneControl, min: 0.20, max: 2.40)
        let fgControl = clamp(fgPlaneControl, min: 0.20, max: 2.80)

        let bgDepthLift = 0.98 + (depth * 0.14)
        let midDepthLift = 1.06 + (depth * 0.24)
        let fgDepthLift = 1.14 + (depth * 0.34)

        let bgFocusLift = 1.0 + (focus * 0.04)
        let midFocusLift = 1.0 + (focus * 0.07)
        let fgFocusLift = 1.0 + (focus * 0.12)

        let bgMotionTightening = 1.0 - (motionGhostSuppression * 0.06)
        let midMotionTightening = 1.0 - (motionGhostSuppression * 0.09)
        let fgMotionTightening = 1.0 - (motionGhostSuppression * 0.24)

        let baseBG = CGPoint(
            x: _bgOffset.x * profile.bgTravelGain * (ShellTuning.bgXBoost * 1.12) * bgDepthLift * bgFocusLift * bgMotionTightening * profile.lateralBias * bgControl,
            y: _bgOffset.y * (ShellTuning.bgYBoost * 1.10) * (0.96 + depth * 0.08) * bgMotionTightening * profile.verticalBias * bgControl
        )

        let baseMID = CGPoint(
            x: _midOffset.x * profile.midTravelGain * (ShellTuning.midXBoost * 1.18) * midDepthLift * midFocusLift * midMotionTightening * profile.lateralBias * midControl,
            y: _midOffset.y * (ShellTuning.midYBoost * 1.16) * (1.00 + depth * 0.12) * midMotionTightening * profile.verticalBias * midControl
        )

        let baseFG = CGPoint(
            x: _fgOffset.x * profile.fgTravelGain * (ShellTuning.fgXBoost * 1.26) * fgDepthLift * fgFocusLift * fgMotionTightening * profile.lateralBias * profile.fgProtection * fgControl,
            y: _fgOffset.y * (ShellTuning.fgYBoost * 1.22) * (1.06 + depth * 0.18 + focus * 0.07) * fgMotionTightening * profile.verticalBias * profile.fgProtection * fgControl
        )

        let bg = CGPoint(
            x: baseBG.x * (shellAuthority * 0.88),
            y: baseBG.y * (shellAuthority * 0.88)
        )

        let mid = CGPoint(
            x: baseMID.x * lerp(0.12, 1.0, shellAuthority),
            y: baseMID.y * lerp(0.12, 1.0, shellAuthority)
        )

        let fg = CGPoint(
            x: baseFG.x * (shellAuthority * shellAuthority),
            y: baseFG.y * (shellAuthority * shellAuthority)
        )

        let bgScaleTarget =
            ShellTuning.moveBGScale +
            profile.bgScaleBias +
            (depth * 0.006) +
            ((bgControl - 1.0) * 0.018)

        let midScaleTarget =
            ShellTuning.moveMIDScale +
            profile.midScaleBias +
            (depth * 0.010) +
            ((midControl - 1.0) * 0.028)

        let fgScaleTarget =
            ShellTuning.moveFGScale +
            profile.fgScaleBias +
            (depth * 0.018) +
            ((fgControl - 1.0) * 0.046)

        let bgBaseScale = lerp(
            ShellTuning.restBGScale + (depthDrivenBlend * 0.004),
            bgScaleTarget,
            movementBlend * (1.0 - motionGhostSuppression * 0.14) * (1.0 - centerContinuity * 0.08)
        )

        let midBaseScale = lerp(
            ShellTuning.restMIDScale + (depthDrivenBlend * 0.008),
            midScaleTarget,
            movementBlend * (1.0 - motionGhostSuppression * 0.18) * (1.0 - centerContinuity * 0.05)
        )

        let fgBaseScale = lerp(
            ShellTuning.restFGScale + (depthDrivenBlend * 0.012),
            fgScaleTarget,
            movementBlend * (1.0 - motionGhostSuppression * 0.22) * (1.0 - centerContinuity * 0.02)
        )

        let bgScale = lerp(1.0, bgBaseScale, shellAuthority * 0.88)
        let midScale = lerp(1.0, midBaseScale, lerp(0.16, 1.0, shellAuthority))
        let fgScale = lerp(1.0, fgBaseScale, shellAuthority * shellAuthority)

        bgContainer.setAffineTransform(
            CGAffineTransform.identity
                .translatedBy(x: bg.x, y: bg.y)
                .scaledBy(x: bgScale, y: bgScale)
        )

        midContainer.setAffineTransform(
            CGAffineTransform.identity
                .translatedBy(x: mid.x, y: mid.y)
                .scaledBy(x: midScale, y: midScale)
        )

        fgContainer.setAffineTransform(
            CGAffineTransform.identity
                .translatedBy(x: fg.x, y: fg.y)
                .scaledBy(x: fgScale, y: fgScale)
        )

        CATransaction.commit()
        applyMode()
    }

    // MARK: - Depth Masks

    private func rebuildPlaneMasks() {
        let fallback = allowsFallbackFullFrameMasks ? (fallbackMaskImage ?? solidWhiteAlphaMask()) : nil
        fallbackMaskImage = fallback

        if bgMaskHost.contents == nil, let fallback {
            bgMaskHost.contents = fallback
        }
        if midMaskHost.contents == nil, let fallback {
            midMaskHost.contents = fallback
        }
        if fgMaskHost.contents == nil, let fallback {
            fgMaskHost.contents = fallback
        }

        if bgMaskHost.contents != nil { bgContainer.mask = bgMaskHost }
        if midMaskHost.contents != nil { midContainer.mask = midMaskHost }
        if fgMaskHost.contents != nil { fgContainer.mask = fgMaskHost }
    }

    func setDepthBandMasks(
        depthImage: CIImage,
        nearRange: ClosedRange<CGFloat> = 0.72 ... 1.00,
        midRange: ClosedRange<CGFloat> = 0.40 ... 0.78,
        farRange: ClosedRange<CGFloat> = 0.00 ... 0.48,
        invertDepth: Bool = false
    ) {
        let normalized = normalizedDepthImage(from: depthImage, invert: invertDepth)
        let extent = normalized.extent.integral

        guard !extent.isEmpty else {
            clearDepthMasks()
            return
        }

        let supportMask = makeBandMask(
            from: normalized,
            range: 0.16 ... 0.94,
            blurRadius: 4.2,
            contrast: 4.4,
            morphologyRadius: 5
        )

        let bgMask = makeBandMask(
            from: normalized,
            range: farRange,
            blurRadius: 5.2,
            contrast: 4.0,
            morphologyRadius: 4
        )

        var midMask = makeBandMask(
            from: normalized,
            range: midRange,
            blurRadius: 5.4,
            contrast: 4.8,
            morphologyRadius: 6
        )

        var fgMask = makeBandMask(
            from: normalized,
            range: nearRange,
            blurRadius: 2.8,
            contrast: 5.4,
            morphologyRadius: 3
        )

        let supportCoverage = estimateCoverage(of: supportMask)
        let bgCoverage = estimateCoverage(of: bgMask)
        let midCoverage = estimateCoverage(of: midMask)
        let fgCoverage = estimateCoverage(of: fgMask)

        if midCoverage < 0.22 || supportCoverage < 0.18 {
            midMask = supportMask
        }

        if fgCoverage < 0.03 {
            fgMask = makeBandMask(
                from: normalized,
                range: max(nearRange.lowerBound - 0.03, 0.66) ... 1.00,
                blurRadius: 2.4,
                contrast: 4.2,
                morphologyRadius: 2
            ) ?? supportMask
        }

        let fallback = allowsFallbackFullFrameMasks ? (fallbackMaskImage ?? solidWhiteAlphaMask()) : nil
        fallbackMaskImage = fallback

        bgMaskHost.contents = bgMask ?? supportMask ?? fallback
        midMaskHost.contents = midMask ?? supportMask ?? fallback
        fgMaskHost.contents = fgMask ?? supportMask ?? fallback

        bgContainer.mask = (bgMaskHost.contents != nil) ? bgMaskHost : nil
        midContainer.mask = (midMaskHost.contents != nil) ? midMaskHost : nil
        fgContainer.mask = (fgMaskHost.contents != nil) ? fgMaskHost : nil

        maskQuality = MaskQuality(
            bgCoverage: bgCoverage,
            midCoverage: Swift.max(midCoverage, supportCoverage * 0.90),
            fgCoverage: fgCoverage,
            supportCoverage: supportCoverage
        )

        applyMode()
    }

    private func normalizedDepthImage(from image: CIImage, invert: Bool) -> CIImage {
        let extent = image.extent.integral

        var working = image
            .clampedToExtent()
            .applyingFilter("CIColorControls", parameters: [
                kCIInputSaturationKey: 0.0,
                kCIInputContrastKey: 1.18,
                kCIInputBrightnessKey: 0.0
            ])
            .applyingFilter("CIGaussianBlur", parameters: [
                kCIInputRadiusKey: 1.0
            ])
            .cropped(to: extent)

        if invert {
            working = working.applyingFilter("CIColorInvert")
        }

        return working
    }

    private func makeBandMask(
        from image: CIImage,
        range: ClosedRange<CGFloat>,
        blurRadius: CGFloat,
        contrast: CGFloat,
        morphologyRadius: Int
    ) -> CGImage? {
        let extent = image.extent.integral
        let minV = clamp(range.lowerBound, min: 0.0, max: 1.0)
        let maxV = clamp(range.upperBound, min: minV + 0.001, max: 1.0)
        let scale = 1.0 / max(0.001, maxV - minV)

        let clampedImage = image.applyingFilter(
            "CIColorClamp",
            parameters: [
                "inputMinComponents": CIVector(x: minV, y: minV, z: minV, w: 0.0),
                "inputMaxComponents": CIVector(x: maxV, y: maxV, z: maxV, w: 1.0)
            ]
        )

        var working = clampedImage.applyingFilter(
            "CIColorMatrix",
            parameters: [
                "inputRVector": CIVector(x: scale, y: 0, z: 0, w: 0),
                "inputGVector": CIVector(x: 0, y: scale, z: 0, w: 0),
                "inputBVector": CIVector(x: 0, y: 0, z: scale, w: 0),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1),
                "inputBiasVector": CIVector(x: -minV * scale, y: -minV * scale, z: -minV * scale, w: 0)
            ]
        )

        working = working.applyingFilter(
            "CIColorControls",
            parameters: [
                kCIInputSaturationKey: 0.0,
                kCIInputContrastKey: contrast,
                kCIInputBrightnessKey: -0.015
            ]
        )

        if morphologyRadius > 0 {
            working = working.applyingFilter(
                "CIMorphologyMaximum",
                parameters: ["inputRadius": morphologyRadius]
            )
        }

        working = working
            .applyingFilter("CIGaussianBlur", parameters: [kCIInputRadiusKey: blurRadius])
            .cropped(to: extent)

        return ciContext.createCGImage(working, from: extent)
    }

    private func estimateCoverage(of image: CGImage?) -> CGFloat {
        guard let image else { return 0 }
        guard let data = image.dataProvider?.data else { return 0 }
        guard let ptr = CFDataGetBytePtr(data) else { return 0 }

        let width = image.width
        let height = image.height
        let bytesPerRow = image.bytesPerRow
        let bytesPerPixel = max(1, image.bitsPerPixel / 8)

        let stepX = max(1, width / 48)
        let stepY = max(1, height / 48)

        var total: CGFloat = 0
        var count: CGFloat = 0

        for y in stride(from: 0, to: height, by: stepY) {
            for x in stride(from: 0, to: width, by: stepX) {
                let offset = y * bytesPerRow + x * bytesPerPixel
                let v = CGFloat(ptr[offset]) / 255.0
                total += v
                count += 1
            }
        }

        guard count > 0 else { return 0 }
        return clamp(total / count, min: 0, max: 1)
    }

    private func solidWhiteAlphaMask() -> CGImage? {
        let size = CGSize(width: max(bounds.width, 2), height: max(bounds.height, 2))
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }

        return image.cgImage
    }



    private func smoothstep(_ edge0: CGFloat, _ edge1: CGFloat, _ x: CGFloat) -> CGFloat {
        guard edge1 > edge0 else { return x >= edge1 ? 1.0 : 0.0 }
        let t = clamp((x - edge0) / (edge1 - edge0), min: 0.0, max: 1.0)
        return t * t * (3.0 - (2.0 * t))
    }

    private func seamRiskFactor() -> CGFloat {
        guard seamSafeModeEnabled, spatialMode == .threePlane else { return 0.0 }

        let fgWeakness = smoothstep(0.00, 0.08, max(0.0, 0.08 - maskQuality.fgCoverage))
        let supportWeakness = smoothstep(0.10, 0.30, max(0.0, 0.30 - maskQuality.supportCoverage))
        let midWeakness = smoothstep(0.18, 0.34, max(0.0, 0.34 - maskQuality.midCoverage))
        let motionRisk = smoothstep(ShellTuning.motionGhostControlStart * 0.55, ShellTuning.motionGhostControlFull * 0.72, currentMotionMagnitude)
        let aiRisk: CGFloat = aiModeActive ? 0.18 : 0.0

        let risk =
            (fgWeakness * 0.34) +
            (supportWeakness * 0.28) +
            (midWeakness * 0.20) +
            (motionRisk * 0.18) +
            aiRisk

        return clamp(risk, min: 0.0, max: 1.0)
    }

    private func seamCollapseFactor() -> CGFloat {
        guard seamSafeModeEnabled else { return 0.0 }
        let risk = seamRiskFactor()
        return smoothstep(0.18, 0.82, risk)
    }

    private func centerRenderContinuity(_ magnitude: CGFloat) -> CGFloat {
        let threshold: CGFloat = 10.0
        let t = clamp(magnitude / threshold, min: 0.0, max: 1.0)
        let eased = t * t * (3.0 - (2.0 * t))
        return 1.0 - eased
    }

    private func depthVisualBoost() -> CGFloat {
        let depth = clamp(depthIntensity, min: 0.0, max: 3.0)
        let focus = clamp(focusFalloff, min: 0.0, max: 1.0)
        return clamp(1.0 + (depth * 0.26) + (focus * 0.08), min: 1.0, max: 1.95)
    }

    private func planeAuthorityBoost(control: CGFloat, base: CGFloat, cap: CGFloat) -> CGFloat {
        let normalized = clamp((control - 0.20) / max(0.0001, cap - 0.20), min: 0.0, max: 1.0)
        return base + (normalized * (cap - base))
    }

    private func ghostSuppressionFactor() -> CGFloat {
        let start = ShellTuning.motionGhostControlStart
        let full = ShellTuning.motionGhostControlFull
        guard full > start else { return 0 }
        let t = (currentMotionMagnitude - start) / (full - start)
        return clamp(t, min: 0.0, max: 1.0)
    }

    private func lutStrength() -> CGFloat {
        switch lutMode {
        case .off:
            return 0.0
        case .lux:
            return 0.72
        case .highfiveDay:
            return 0.78
        case .highfiveNight:
            return 0.95
        case .highfiveWarm:
            return 0.80
        case .highfiveMono:
            return 1.0
        }
    }

    private func lutShoulderBias() -> CGFloat {
        switch lutMode {
        case .off:
            return 0.0
        case .lux:
            return 0.062
        case .highfiveDay:
            return 0.086
        case .highfiveNight:
            return 0.102
        case .highfiveWarm:
            return 0.092
        case .highfiveMono:
            return 0.118
        }
    }

    private func lutVignetteBias() -> CGFloat {
        switch lutMode {
        case .off:
            return 0.0
        case .lux:
            return 0.034
        case .highfiveDay:
            return 0.040
        case .highfiveNight:
            return 0.094
        case .highfiveWarm:
            return 0.056
        case .highfiveMono:
            return 0.110
        }
    }

    private func lutGrainBias() -> CGFloat {
        switch lutMode {
        case .off:
            return 0.0
        case .lux:
            return 0.012
        case .highfiveDay:
            return 0.018
        case .highfiveNight:
            return 0.050
        case .highfiveWarm:
            return 0.020
        case .highfiveMono:
            return 0.082
        }
    }

    private func lutFlatOpacityBias() -> CGFloat {
        switch lutMode {
        case .off:
            return 0.0
        case .lux:
            return -0.068
        case .highfiveDay:
            return -0.080
        case .highfiveNight:
            return -0.118
        case .highfiveWarm:
            return -0.090
        case .highfiveMono:
            return -0.124
        }
    }

    private func lutContrastBias() -> CGFloat {
        switch lutMode {
        case .off:
            return 0.0
        case .lux:
            return 0.12
        case .highfiveDay:
            return 0.18
        case .highfiveNight:
            return 0.25
        case .highfiveWarm:
            return 0.20
        case .highfiveMono:
            return 0.28
        }
    }

    private func lutBlackFloorBias() -> CGFloat {
        switch lutMode {
        case .off:
            return 0.0
        case .lux:
            return 0.08
        case .highfiveDay:
            return 0.10
        case .highfiveNight:
            return 0.22
        case .highfiveWarm:
            return 0.14
        case .highfiveMono:
            return 0.26
        }
    }

    private func lutBloomBias() -> CGFloat {
        switch lutMode {
        case .off:
            return 0.0
        case .lux:
            return 0.080
        case .highfiveDay:
            return 0.115
        case .highfiveNight:
            return 0.020
        case .highfiveWarm:
            return 0.105
        case .highfiveMono:
            return 0.012
        }
    }

    private func lutColorWashOpacity() -> CGFloat {
        switch lutMode {
        case .off:
            return 0.0
        case .lux:
            return 0.21
        case .highfiveDay:
            return 0.25
        case .highfiveNight:
            return 0.13
        case .highfiveWarm:
            return 0.27
        case .highfiveMono:
            return 0.0
        }
    }

    private func lutContrastFillColor() -> UIColor {
        switch lutMode {
        case .off:
            return UIColor(white: 0.50, alpha: 1.0)
        case .lux:
            return UIColor(red: 0.62, green: 0.50, blue: 0.39, alpha: 1.0)
        case .highfiveDay:
            return UIColor(red: 0.70, green: 0.58, blue: 0.36, alpha: 1.0)
        case .highfiveNight:
            return UIColor(red: 0.42, green: 0.46, blue: 0.48, alpha: 1.0)
        case .highfiveWarm:
            return UIColor(red: 0.74, green: 0.52, blue: 0.34, alpha: 1.0)
        case .highfiveMono:
            return UIColor(white: 0.50, alpha: 1.0)
        }
    }

    private func lutWarmTintTopColor() -> UIColor {
        switch lutMode {
        case .off:
            return UIColor.clear
        case .lux:
            return UIColor(red: 1.00, green: 0.84, blue: 0.68, alpha: 0.56)
        case .highfiveDay:
            return UIColor(red: 1.00, green: 0.88, blue: 0.62, alpha: 0.60)
        case .highfiveNight:
            return UIColor(red: 0.72, green: 0.90, blue: 1.00, alpha: 0.18)
        case .highfiveWarm:
            return UIColor(red: 1.00, green: 0.78, blue: 0.55, alpha: 0.65)
        case .highfiveMono:
            return UIColor(white: 1.0, alpha: 0.18)
        }
    }

    private func lutWarmTintMidColor() -> UIColor {
        switch lutMode {
        case .off:
            return UIColor.clear
        case .lux:
            return UIColor(red: 0.95, green: 0.66, blue: 0.44, alpha: 0.38)
        case .highfiveDay:
            return UIColor(red: 0.92, green: 0.70, blue: 0.36, alpha: 0.45)
        case .highfiveNight:
            return UIColor(red: 0.50, green: 0.68, blue: 0.72, alpha: 0.28)
        case .highfiveWarm:
            return UIColor(red: 0.95, green: 0.62, blue: 0.32, alpha: 0.50)
        case .highfiveMono:
            return UIColor(white: 0.70, alpha: 0.20)
        }
    }

    private func lutWarmTintBottomColor() -> UIColor {
        switch lutMode {
        case .off:
            return UIColor.clear
        case .lux:
            return UIColor(red: 0.38, green: 0.22, blue: 0.14, alpha: 0.34)
        case .highfiveDay:
            return UIColor(red: 0.32, green: 0.26, blue: 0.14, alpha: 0.38)
        case .highfiveNight:
            return UIColor(red: 0.06, green: 0.12, blue: 0.14, alpha: 0.52)
        case .highfiveWarm:
            return UIColor(red: 0.42, green: 0.24, blue: 0.12, alpha: 0.42)
        case .highfiveMono:
            return UIColor(white: 0.0, alpha: 0.50)
        }
    }

    private func lutBloomTopColor() -> UIColor {
        switch lutMode {
        case .off:
            return UIColor.white.withAlphaComponent(0.0)
        case .lux:
            return UIColor(red: 1.00, green: 0.94, blue: 0.86, alpha: 0.40)
        case .highfiveDay:
            return UIColor(red: 1.00, green: 0.93, blue: 0.80, alpha: 0.48)
        case .highfiveNight:
            return UIColor(red: 0.90, green: 0.96, blue: 1.00, alpha: 0.12)
        case .highfiveWarm:
            return UIColor(red: 1.00, green: 0.86, blue: 0.74, alpha: 0.44)
        case .highfiveMono:
            return UIColor(white: 1.0, alpha: 0.16)
        }
    }

    private func lutBloomMidColor() -> UIColor {
        switch lutMode {
        case .off:
            return UIColor.white.withAlphaComponent(0.0)
        case .lux:
            return UIColor(red: 1.00, green: 0.87, blue: 0.74, alpha: 0.20)
        case .highfiveDay:
            return UIColor(red: 1.00, green: 0.86, blue: 0.68, alpha: 0.24)
        case .highfiveNight:
            return UIColor(red: 0.78, green: 0.88, blue: 0.92, alpha: 0.08)
        case .highfiveWarm:
            return UIColor(red: 1.00, green: 0.80, blue: 0.66, alpha: 0.22)
        case .highfiveMono:
            return UIColor(white: 0.92, alpha: 0.10)
        }
    }

    private func depthSignature(for image: UIImage) -> Int {
        guard let cg = image.cgImage else { return 0 }

        var hash = (cg.width & 0xFFFF) ^ ((cg.height & 0xFFFF) << 16)
        hash ^= Int((image.scale * 100.0).rounded()) << 4

        if let data = cg.dataProvider?.data, let ptr = CFDataGetBytePtr(data) {
            let length = CFDataGetLength(data)
            if length > 0 {
                let sampleStep = max(1, length / 24)
                var rolling = 2166136261
                var index = 0
                while index < length {
                    rolling = (rolling &* 16777619) ^ Int(ptr[index])
                    index += sampleStep
                }
                hash ^= rolling
            }
        } else {
            hash ^= Int(bitPattern: Unmanaged.passUnretained(cg).toOpaque())
        }

        return hash
    }

    private func clamp(_ value: CGFloat, min minValue: CGFloat, max maxValue: CGFloat) -> CGFloat {
        Swift.max(minValue, Swift.min(maxValue, value))
    }

    private func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
        a + ((b - a) * t)
    }
}

// MARK: - Compatibility Helpers

extension HKV1_PlayerLayerView {

    func setPlayer(_ player: AVPlayer?) {
        self.player = player
    }

    func setLensMode(_ lensMode: LensMode) {
        self.lensMode = lensMode
    }

    func setSpatialMode(_ mode: SpatialMode) {
        self.spatialMode = mode
    }

    func setRenderMode(_ mode: RenderMode) {
        self.renderMode = mode
    }

    func setDepthIntensity(_ value: CGFloat) {
        self.depthIntensity = value
    }

    func setLUTMode(_ mode: LUTMode) {
        self.lutMode = mode
    }

    func setFocusFalloff(_ value: CGFloat) {
        self.focusFalloff = value
    }

    func setPlaneAuthority(bg: CGFloat, mid: CGFloat, fg: CGFloat, userDriven: Bool = true) {
        planeAuthorityHasBeenUserCustomized = userDriven
        bgPlaneControl = bg
        midPlaneControl = mid
        fgPlaneControl = fg
        planeAuthorityHasBeenUserCustomized = userDriven
    }

    func applyLensPresetDefaults() {
        planeAuthorityHasBeenUserCustomized = false
        applyLensDefaults(force: true)
    }

    func updateDepthComposite(colorImage: UIImage?, depthImage: UIImage?, dx: CGFloat, dy: CGFloat) {
        _ = colorImage

        if let depthImage, let ciDepth = CIImage(image: depthImage) {
            let now = CACurrentMediaTime()
            let signature = depthSignature(for: depthImage)

            let shouldRebuildMasks =
                !depthMaskRebuildSuspended &&
                (
                    renderMode != .depthPrepared ||
                    signature != lastDepthSignature ||
                    (now - lastDepthMaskRebuildTime) >= minDepthMaskRebuildInterval
                )

            renderMode = .depthPrepared

            if shouldRebuildMasks {
                setDepthBandMasks(depthImage: ciDepth)
                lastDepthSignature = signature
                lastDepthMaskRebuildTime = now
            }
        } else {
            renderMode = .flat
            clearDepthMasks()
        }

        _ = dx
        _ = dy
    }
}
