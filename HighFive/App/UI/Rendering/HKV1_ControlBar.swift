import UIKit

final class HKV1_ControlBar: UIView {

    // MARK: - Public Callbacks

    var onToggleDepth: ((Bool) -> Void)?
    var onToggleAI: ((Bool) -> Void)?
    var onToggleTilt: ((Bool) -> Void)?
    var onTogglePeek: ((Bool) -> Void)?
    var onModeChanged: ((Int) -> Void)?
    var isAppUnlocked: Bool = false
    var onLockedLoadTapped: (() -> Void)?
    var onLockedExportTapped: (() -> Void)?

    var onLensModeChanged: ((Int) -> Void)?
    var onDepthIntensityChanged: ((Float) -> Void)?
    var onFocusFalloffChanged: ((Float) -> Void)?
    var onBGPlaneControlChanged: ((Float) -> Void)?
    var onMIDPlaneControlChanged: ((Float) -> Void)?
    var onFGPlaneControlChanged: ((Float) -> Void)?
    var onFramingScaleChanged: ((Float) -> Void)?

    var onLoadVideo: (() -> Void)?
    var onLoadFile: (() -> Void)?
    var onPlayPause: (() -> Void)?
    var onExportTapped: (() -> Void)?
    var onLUTChanged: ((Int) -> Void)?

    var onScrubBegan: (() -> Void)?
    var onScrubChanged: ((Float) -> Void)?
    var onScrubEnded: ((Float) -> Void)?

    var onInteractionBegan: (() -> Void)?
    var onInteractionEnded: (() -> Void)?
    var onExportModeChanged: ((Int) -> Void)?

    // MARK: - Runtime State

    private enum PanelMode {
        case main
        case cin
        case pro
        case motion
    }

    private var depthEnabled = true
    private var autoEnabled = false
    private var tiltEnabled = true
    private var peekEnabled = true
    private var isPlaying = false
    private var runtimeModeIndex = 1
    private var runtimeLensIndex = 1
    private var exportModeIndex = 0

    private var activePanel: PanelMode = .main

    private var statusChipOverrideText: String?
    private var statusChipRenderingProgress: Double?

    // MARK: - Root

    private let rootStack = UIStackView()
    private let glassCard = UIView()
    private let chromeBlur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let chromeTint = UIView()

    // MARK: - Scrubber

    private let scrubberRow = UIView()
    private let scrubber = UISlider()

    // MARK: - Shared Card Areas

    private let cardContentHost = UIView()
    private let mainContentView = UIView()
    private let expandedContentView = UIView()

    // MARK: - Main Surface Controls

    private let centerDeck = UIView()
    private let depthDial = HKV1_RedDialControl(
        title: "DEPTH",
        minValue: 0.0,
        maxValue: 3.0,
        value: 1.0,
        decimals: 2,
        style: .large
    )
    private let focusDial = HKV1_RedDialControl(
        title: "FOCUS",
        minValue: 0.0,
        maxValue: 1.0,
        value: 0.20,
        decimals: 2,
        style: .small
    )

    private let playButton = UIButton(type: .system)
    private let playIconView = UIImageView()

    private let centerInfoStack = UIStackView()
    private let centerKickerLabel = UILabel()
    private let centerStatusChip = HKV1PaddingLabel()

    private let bottomUtilityRow = UIView()
    private let bottomUtilityStack = UIStackView()
    private let loadButton = UIButton(type: .system)
    private let exportButton = UIButton(type: .system)
    private let cinButton = UIButton(type: .system)
    private let proButton = UIButton(type: .system)
    private let motionButton = UIButton(type: .system)

    // MARK: - Expanded Shared Header

    private let expandedHeaderRow = UIStackView()
    private let expandedTitleLabel = UILabel()
    private let expandedSubtitleLabel = UILabel()
    private let expandedHeaderTextStack = UIStackView()
    private let expandedCloseButton = UIButton(type: .system)

    // MARK: - CIN Panel

    private let cinPanel = UIView()
    private let cinPanelStack = UIStackView()
    private let cinTopKnobRow = UIStackView()
    private let lensSegment = UISegmentedControl(items: ["Nat", "Ana", "Port"])
    private let exportSegment = UISegmentedControl(items: ["Off", "Bal", "Ultra", "Agg"])
    private let lutSegment = UISegmentedControl(items: ["Off", "Lux", "HF Day", "HF Night", "HF Warm", "HF Mono"])
    private let cinInfoLabel = UILabel()

    // MARK: - PRO Panel

    private let proPanel = UIView()
    private let proPanelStack = UIStackView()
    private let proKnobRow = UIStackView()
    private let bgDial = HKV1_RedDialControl(
        title: "BG",
        minValue: 0.20,
        maxValue: 2.20,
        value: 0.70,
        decimals: 2,
        style: .compact
    )
    private let midDial = HKV1_RedDialControl(
        title: "MID",
        minValue: 0.20,
        maxValue: 2.40,
        value: 1.20,
        decimals: 2,
        style: .compact
    )
    private let fgDial = HKV1_RedDialControl(
        title: "FG",
        minValue: 0.20,
        maxValue: 2.80,
        value: 1.45,
        decimals: 2,
        style: .compact
    )
    private let framingDial = HKV1_RedDialControl(
        title: "SPACE",
        minValue: 0.86,
        maxValue: 1.18,
        value: 1.00,
        decimals: 2,
        style: .compact,
        sensitivityMultiplier: 1.85
    )
    private let resetButton = UIButton(type: .system)

    // MARK: - Motion Panel

    private let motionPanel = UIView()
    private let motionPanelStack = UIStackView()
    private let aiToggleButton = UIButton(type: .system)
    private let tiltToggleButton = UIButton(type: .system)
    private let peekToggleButton = UIButton(type: .system)
    private let depthToggleButton = UIButton(type: .system)
    private let motionModeSegment = UISegmentedControl(items: ["Off", "Close", "Wide"])

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: 432, height: 360)
    }

    private func setup() {
        backgroundColor = .clear
        clipsToBounds = false
        alpha = 1.0

        setupRootStack()
        setupGlassCard()
        setupScrubber()
        setupMainContent()
        setupExpandedContent()
        setupActions()
        configureLoadMenu()
        configureDefaults()
        refreshAll()
    }

    // MARK: - Setup Root

    private func setupRootStack() {
        rootStack.axis = .vertical
        rootStack.alignment = .fill
        rootStack.distribution = .fill
        rootStack.spacing = 9
        rootStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(rootStack)

        NSLayoutConstraint.activate([
            rootStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            rootStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            rootStack.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            rootStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }

    private func setupGlassCard() {
        glassCard.translatesAutoresizingMaskIntoConstraints = false
        glassCard.clipsToBounds = false

        chromeBlur.translatesAutoresizingMaskIntoConstraints = false
        chromeTint.translatesAutoresizingMaskIntoConstraints = false
        chromeTint.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 0.16)

        chromeBlur.layer.cornerRadius = 30
        chromeBlur.clipsToBounds = true
        chromeBlur.layer.borderWidth = 1.0
        chromeBlur.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        chromeBlur.layer.shadowColor = UIColor.black.cgColor
        chromeBlur.layer.shadowOpacity = 0.22
        chromeBlur.layer.shadowRadius = 28
        chromeBlur.layer.shadowOffset = CGSize(width: 0, height: 14)

        glassCard.addSubview(chromeBlur)
        chromeBlur.contentView.addSubview(chromeTint)
        chromeBlur.contentView.addSubview(cardContentHost)

        cardContentHost.translatesAutoresizingMaskIntoConstraints = false

        rootStack.addArrangedSubview(glassCard)

        NSLayoutConstraint.activate([
            glassCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 286),

            chromeBlur.leadingAnchor.constraint(equalTo: glassCard.leadingAnchor),
            chromeBlur.trailingAnchor.constraint(equalTo: glassCard.trailingAnchor),
            chromeBlur.topAnchor.constraint(equalTo: glassCard.topAnchor),
            chromeBlur.bottomAnchor.constraint(equalTo: glassCard.bottomAnchor),

            chromeTint.leadingAnchor.constraint(equalTo: chromeBlur.contentView.leadingAnchor),
            chromeTint.trailingAnchor.constraint(equalTo: chromeBlur.contentView.trailingAnchor),
            chromeTint.topAnchor.constraint(equalTo: chromeBlur.contentView.topAnchor),
            chromeTint.bottomAnchor.constraint(equalTo: chromeBlur.contentView.bottomAnchor),

            cardContentHost.leadingAnchor.constraint(equalTo: chromeBlur.contentView.leadingAnchor),
            cardContentHost.trailingAnchor.constraint(equalTo: chromeBlur.contentView.trailingAnchor),
            cardContentHost.topAnchor.constraint(equalTo: chromeBlur.contentView.topAnchor),
            cardContentHost.bottomAnchor.constraint(equalTo: chromeBlur.contentView.bottomAnchor)
        ])
    }

    private func setupScrubber() {
        scrubberRow.translatesAutoresizingMaskIntoConstraints = false
        scrubber.translatesAutoresizingMaskIntoConstraints = false
        scrubber.transform = CGAffineTransform(scaleX: 1.0, y: 1.18)

        scrubber.minimumValue = 0
        scrubber.maximumValue = 1
        scrubber.minimumTrackTintColor = .white
        scrubber.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.14)
        scrubber.tintColor = .white
        scrubberRow.alpha = 0.98

        let thumbImage = Self.makeRoundedThumbImage(diameter: 18)
        scrubber.setThumbImage(thumbImage, for: .normal)
        scrubber.setThumbImage(thumbImage, for: .highlighted)

        scrubberRow.addSubview(scrubber)
        rootStack.addArrangedSubview(scrubberRow)

        NSLayoutConstraint.activate([
            scrubberRow.heightAnchor.constraint(equalToConstant: 24),
            scrubber.leadingAnchor.constraint(equalTo: scrubberRow.leadingAnchor),
            scrubber.trailingAnchor.constraint(equalTo: scrubberRow.trailingAnchor),
            scrubber.centerYAnchor.constraint(equalTo: scrubberRow.centerYAnchor)
        ])
    }

    // MARK: - Main Content

    private func setupMainContent() {
        mainContentView.translatesAutoresizingMaskIntoConstraints = false
        mainContentView.alpha = 1.0
        mainContentView.isHidden = false
        cardContentHost.addSubview(mainContentView)

        NSLayoutConstraint.activate([
            mainContentView.leadingAnchor.constraint(equalTo: cardContentHost.leadingAnchor),
            mainContentView.trailingAnchor.constraint(equalTo: cardContentHost.trailingAnchor),
            mainContentView.topAnchor.constraint(equalTo: cardContentHost.topAnchor),
            mainContentView.bottomAnchor.constraint(equalTo: cardContentHost.bottomAnchor)
        ])

        setupCenterDeck()
        setupBottomUtilityRow()

        mainContentView.addSubview(centerDeck)
        mainContentView.addSubview(bottomUtilityRow)

        NSLayoutConstraint.activate([
            centerDeck.leadingAnchor.constraint(equalTo: mainContentView.leadingAnchor, constant: 12),
            centerDeck.trailingAnchor.constraint(equalTo: mainContentView.trailingAnchor, constant: -12),
            centerDeck.topAnchor.constraint(equalTo: mainContentView.topAnchor, constant: 18),
            centerDeck.heightAnchor.constraint(equalToConstant: 188),

            bottomUtilityRow.leadingAnchor.constraint(equalTo: mainContentView.leadingAnchor, constant: 10),
            bottomUtilityRow.trailingAnchor.constraint(equalTo: mainContentView.trailingAnchor, constant: -10),
            bottomUtilityRow.topAnchor.constraint(equalTo: centerDeck.bottomAnchor, constant: 14),
            bottomUtilityRow.heightAnchor.constraint(equalToConstant: 48),
            bottomUtilityRow.bottomAnchor.constraint(equalTo: mainContentView.bottomAnchor, constant: -14)
        ])
    }

    private func setupCenterDeck() {
        centerDeck.translatesAutoresizingMaskIntoConstraints = false

        depthDial.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playIconView.translatesAutoresizingMaskIntoConstraints = false
        focusDial.translatesAutoresizingMaskIntoConstraints = false
        centerInfoStack.translatesAutoresizingMaskIntoConstraints = false

        centerDeck.addSubview(depthDial)
        centerDeck.addSubview(playButton)
        centerDeck.addSubview(focusDial)
        centerDeck.addSubview(centerInfoStack)

        playButton.backgroundColor = UIColor(red: 1.0, green: 0.24, blue: 0.24, alpha: 0.98)
        playButton.layer.cornerRadius = 42
        playButton.layer.shadowColor = UIColor(red: 1.0, green: 0.16, blue: 0.16, alpha: 1.0).cgColor
        playButton.layer.shadowOpacity = 0.36
        playButton.layer.shadowRadius = 22
        playButton.layer.shadowOffset = CGSize(width: 0, height: 10)

        playIconView.tintColor = .white
        playIconView.contentMode = .scaleAspectFit
        playButton.addSubview(playIconView)

        depthDial.layer.shadowColor = UIColor.systemRed.cgColor
        depthDial.layer.shadowOffset = .zero
        depthDial.layer.shadowRadius = 10
        depthDial.layer.shadowOpacity = 0.18

        focusDial.layer.shadowColor = UIColor.systemRed.cgColor
        focusDial.layer.shadowOffset = .zero
        focusDial.layer.shadowRadius = 8
        focusDial.layer.shadowOpacity = 0.14

        centerInfoStack.axis = .vertical
        centerInfoStack.alignment = .center
        centerInfoStack.distribution = .fill
        centerInfoStack.spacing = 6

        centerKickerLabel.text = "SPATIAL CONTROL"
        centerKickerLabel.textColor = UIColor.white.withAlphaComponent(0.52)
        centerKickerLabel.font = .systemFont(ofSize: 9.5, weight: .bold)
        centerKickerLabel.textAlignment = .center

        centerStatusChip.text = "DEPTH ACTIVE"
        centerStatusChip.textColor = UIColor.white.withAlphaComponent(0.98)
        centerStatusChip.backgroundColor = UIColor.systemRed.withAlphaComponent(0.18)
        centerStatusChip.layer.shadowColor = UIColor.systemRed.cgColor
        centerStatusChip.layer.shadowOffset = .zero
        centerStatusChip.layer.shadowRadius = 12
        centerStatusChip.layer.shadowOpacity = 0.34
        centerStatusChip.font = .systemFont(ofSize: 11, weight: .bold)
        centerStatusChip.insets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        centerStatusChip.layer.cornerRadius = 13
        centerStatusChip.layer.masksToBounds = true

        centerInfoStack.addArrangedSubview(centerKickerLabel)
        centerInfoStack.addArrangedSubview(centerStatusChip)

        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: centerDeck.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: centerDeck.centerYAnchor, constant: 8),
            playButton.widthAnchor.constraint(equalToConstant: 84),
            playButton.heightAnchor.constraint(equalToConstant: 84),

            playIconView.centerXAnchor.constraint(equalTo: playButton.centerXAnchor),
            playIconView.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            playIconView.widthAnchor.constraint(equalToConstant: 26),
            playIconView.heightAnchor.constraint(equalToConstant: 26),

            depthDial.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -18),
            depthDial.centerYAnchor.constraint(equalTo: playButton.centerYAnchor, constant: -1),
            depthDial.widthAnchor.constraint(equalToConstant: 108),
            depthDial.heightAnchor.constraint(equalToConstant: 138),

            focusDial.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 18),
            focusDial.centerYAnchor.constraint(equalTo: playButton.centerYAnchor, constant: -1),
            focusDial.widthAnchor.constraint(equalToConstant: 74),
            focusDial.heightAnchor.constraint(equalToConstant: 120),

            depthDial.leadingAnchor.constraint(greaterThanOrEqualTo: centerDeck.leadingAnchor, constant: 8),
            focusDial.trailingAnchor.constraint(lessThanOrEqualTo: centerDeck.trailingAnchor, constant: -8),

            centerInfoStack.centerXAnchor.constraint(equalTo: playButton.centerXAnchor),
            centerInfoStack.bottomAnchor.constraint(equalTo: playButton.topAnchor, constant: -14),
            centerInfoStack.widthAnchor.constraint(lessThanOrEqualToConstant: 230)
        ])
    }

    private func setupBottomUtilityRow() {
        bottomUtilityRow.translatesAutoresizingMaskIntoConstraints = false
        bottomUtilityStack.translatesAutoresizingMaskIntoConstraints = false
        bottomUtilityStack.axis = .horizontal
        bottomUtilityStack.alignment = .center
        bottomUtilityStack.distribution = .fill
        bottomUtilityStack.spacing = 10

        bottomUtilityRow.addSubview(bottomUtilityStack)

        [loadButton, exportButton, cinButton, proButton, motionButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            bottomUtilityStack.addArrangedSubview($0)
        }

        [cinButton, proButton, motionButton].forEach {
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .horizontal)
        }

        NSLayoutConstraint.activate([
            bottomUtilityStack.leadingAnchor.constraint(equalTo: bottomUtilityRow.leadingAnchor, constant: 6),
            bottomUtilityStack.trailingAnchor.constraint(equalTo: bottomUtilityRow.trailingAnchor, constant: -6),
            bottomUtilityStack.topAnchor.constraint(equalTo: bottomUtilityRow.topAnchor),
            bottomUtilityStack.bottomAnchor.constraint(equalTo: bottomUtilityRow.bottomAnchor),

            loadButton.widthAnchor.constraint(equalToConstant: 42),
            loadButton.heightAnchor.constraint(equalToConstant: 42),
            exportButton.widthAnchor.constraint(equalToConstant: 42),
            exportButton.heightAnchor.constraint(equalToConstant: 42),

            cinButton.widthAnchor.constraint(equalToConstant: 78),
            proButton.widthAnchor.constraint(equalToConstant: 88),
            motionButton.widthAnchor.constraint(equalToConstant: 104),

            cinButton.heightAnchor.constraint(equalToConstant: 34),
            proButton.heightAnchor.constraint(equalToConstant: 34),
            motionButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    // MARK: - Expanded Content

    private func setupExpandedContent() {
        expandedContentView.translatesAutoresizingMaskIntoConstraints = false
        expandedContentView.alpha = 0.0
        expandedContentView.isHidden = true

        cardContentHost.addSubview(expandedContentView)

        NSLayoutConstraint.activate([
            expandedContentView.leadingAnchor.constraint(equalTo: cardContentHost.leadingAnchor),
            expandedContentView.trailingAnchor.constraint(equalTo: cardContentHost.trailingAnchor),
            expandedContentView.topAnchor.constraint(equalTo: cardContentHost.topAnchor),
            expandedContentView.bottomAnchor.constraint(equalTo: cardContentHost.bottomAnchor)
        ])

        setupExpandedHeader()
        setupCinPanel()
        setupProPanel()
        setupMotionPanel()
    }

    private func setupExpandedHeader() {
        expandedHeaderRow.axis = .horizontal
        expandedHeaderRow.alignment = .center
        expandedHeaderRow.distribution = .equalSpacing
        expandedHeaderRow.spacing = 10
        expandedHeaderRow.translatesAutoresizingMaskIntoConstraints = false

        expandedHeaderTextStack.axis = .vertical
        expandedHeaderTextStack.alignment = .leading
        expandedHeaderTextStack.distribution = .fill
        expandedHeaderTextStack.spacing = 2
        expandedHeaderTextStack.translatesAutoresizingMaskIntoConstraints = false

        expandedTitleLabel.textColor = UIColor.white.withAlphaComponent(0.98)
        expandedTitleLabel.font = .systemFont(ofSize: 13, weight: .bold)

        expandedSubtitleLabel.textColor = UIColor.white.withAlphaComponent(0.54)
        expandedSubtitleLabel.font = .systemFont(ofSize: 10, weight: .semibold)

        expandedCloseButton.configuration = makeCloseButtonConfig()
        expandedCloseButton.translatesAutoresizingMaskIntoConstraints = false

        expandedHeaderTextStack.addArrangedSubview(expandedTitleLabel)
        expandedHeaderTextStack.addArrangedSubview(expandedSubtitleLabel)

        expandedHeaderRow.addArrangedSubview(expandedHeaderTextStack)
        expandedHeaderRow.addArrangedSubview(expandedCloseButton)

        expandedContentView.addSubview(expandedHeaderRow)

        NSLayoutConstraint.activate([
            expandedHeaderRow.leadingAnchor.constraint(equalTo: expandedContentView.leadingAnchor, constant: 16),
            expandedHeaderRow.trailingAnchor.constraint(equalTo: expandedContentView.trailingAnchor, constant: -16),
            expandedHeaderRow.topAnchor.constraint(equalTo: expandedContentView.topAnchor, constant: 14),
            expandedHeaderRow.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    private func setupCinPanel() {
        cinPanel.translatesAutoresizingMaskIntoConstraints = false
        cinPanel.alpha = 0.0
        cinPanel.isHidden = true

        cinPanelStack.axis = .vertical
        cinPanelStack.alignment = .fill
        cinPanelStack.distribution = .fill
        cinPanelStack.spacing = 14
        cinPanelStack.translatesAutoresizingMaskIntoConstraints = false

        cinTopKnobRow.axis = .horizontal
        cinTopKnobRow.alignment = .center
        cinTopKnobRow.distribution = .fillEqually
        cinTopKnobRow.spacing = 12
        cinTopKnobRow.translatesAutoresizingMaskIntoConstraints = false
        cinTopKnobRow.addArrangedSubview(depthDial.makeReadOnlyClone())
        cinTopKnobRow.addArrangedSubview(focusDial.makeReadOnlyClone())

        configureSegment(lensSegment)
        configureSegment(exportSegment)
        configureSegment(lutSegment)
        exportSegment.selectedSegmentIndex = exportModeIndex
        lutSegment.selectedSegmentIndex = 0

        cinInfoLabel.text = "Lens preset + LUT look + export shaping."
        cinInfoLabel.textColor = UIColor.white.withAlphaComponent(0.62)
        cinInfoLabel.font = .systemFont(ofSize: 11, weight: .medium)
        cinInfoLabel.numberOfLines = 2

        cinPanelStack.addArrangedSubview(makeSectionLabel("Preset"))
        cinPanelStack.addArrangedSubview(lensSegment)
        cinPanelStack.addArrangedSubview(makeSectionLabel("Look"))
        cinPanelStack.addArrangedSubview(lutSegment)
        cinPanelStack.addArrangedSubview(makeSectionLabel("Export"))
        cinPanelStack.addArrangedSubview(exportSegment)
        cinPanelStack.addArrangedSubview(cinInfoLabel)

        cinPanel.addSubview(cinPanelStack)
        expandedContentView.addSubview(cinPanel)

        NSLayoutConstraint.activate([
            cinPanel.leadingAnchor.constraint(equalTo: expandedContentView.leadingAnchor, constant: 16),
            cinPanel.trailingAnchor.constraint(equalTo: expandedContentView.trailingAnchor, constant: -16),
            cinPanel.topAnchor.constraint(equalTo: expandedHeaderRow.bottomAnchor, constant: 16),
            cinPanel.bottomAnchor.constraint(equalTo: expandedContentView.bottomAnchor, constant: -16),

            cinPanelStack.leadingAnchor.constraint(equalTo: cinPanel.leadingAnchor),
            cinPanelStack.trailingAnchor.constraint(equalTo: cinPanel.trailingAnchor),
            cinPanelStack.topAnchor.constraint(equalTo: cinPanel.topAnchor),
            cinPanelStack.bottomAnchor.constraint(lessThanOrEqualTo: cinPanel.bottomAnchor)
        ])
    }

    private func setupProPanel() {
        proPanel.translatesAutoresizingMaskIntoConstraints = false
        proPanel.alpha = 0.0
        proPanel.isHidden = true

        proPanelStack.axis = .vertical
        proPanelStack.alignment = .fill
        proPanelStack.distribution = .fill
        proPanelStack.spacing = 14
        proPanelStack.translatesAutoresizingMaskIntoConstraints = false

        proKnobRow.axis = .horizontal
        proKnobRow.alignment = .top
        proKnobRow.distribution = .fillEqually
        proKnobRow.spacing = 10
        proKnobRow.translatesAutoresizingMaskIntoConstraints = false

        [bgDial, midDial, fgDial, framingDial].forEach { dial in
            dial.translatesAutoresizingMaskIntoConstraints = false
            proKnobRow.addArrangedSubview(dial)
        }

        NSLayoutConstraint.activate([
            bgDial.heightAnchor.constraint(equalToConstant: 122),
            midDial.heightAnchor.constraint(equalToConstant: 122),
            fgDial.heightAnchor.constraint(equalToConstant: 122),
            framingDial.heightAnchor.constraint(equalToConstant: 122)
        ])

        resetButton.configuration = makeResetButtonConfig(title: "Reset Pro")

        proPanelStack.addArrangedSubview(makeSectionLabel("Plane Spread + Framing"))
        proPanelStack.addArrangedSubview(proKnobRow)
        proPanelStack.addArrangedSubview(resetButton)

        proPanel.addSubview(proPanelStack)
        expandedContentView.addSubview(proPanel)

        NSLayoutConstraint.activate([
            proPanel.leadingAnchor.constraint(equalTo: expandedContentView.leadingAnchor, constant: 16),
            proPanel.trailingAnchor.constraint(equalTo: expandedContentView.trailingAnchor, constant: -16),
            proPanel.topAnchor.constraint(equalTo: expandedHeaderRow.bottomAnchor, constant: 16),
            proPanel.bottomAnchor.constraint(equalTo: expandedContentView.bottomAnchor, constant: -16),

            proPanelStack.leadingAnchor.constraint(equalTo: proPanel.leadingAnchor),
            proPanelStack.trailingAnchor.constraint(equalTo: proPanel.trailingAnchor),
            proPanelStack.topAnchor.constraint(equalTo: proPanel.topAnchor),
            proPanelStack.bottomAnchor.constraint(lessThanOrEqualTo: proPanel.bottomAnchor)
        ])
    }

    private func setupMotionPanel() {
        motionPanel.translatesAutoresizingMaskIntoConstraints = false
        motionPanel.alpha = 0.0
        motionPanel.isHidden = true

        motionPanelStack.axis = .vertical
        motionPanelStack.alignment = .fill
        motionPanelStack.distribution = .fill
        motionPanelStack.spacing = 14
        motionPanelStack.translatesAutoresizingMaskIntoConstraints = false

        configureSegment(motionModeSegment)
        motionModeSegment.selectedSegmentIndex = runtimeModeIndex

        motionPanelStack.addArrangedSubview(makeSectionLabel("Lanes"))
        motionPanelStack.addArrangedSubview(makeLaneToggleRow())
        motionPanelStack.addArrangedSubview(makeSectionLabel("Depth"))
        motionPanelStack.addArrangedSubview(depthToggleButton)
        motionPanelStack.addArrangedSubview(makeSectionLabel("Preset"))
        motionPanelStack.addArrangedSubview(motionModeSegment)

        motionPanel.addSubview(motionPanelStack)
        expandedContentView.addSubview(motionPanel)

        NSLayoutConstraint.activate([
            motionPanel.leadingAnchor.constraint(equalTo: expandedContentView.leadingAnchor, constant: 16),
            motionPanel.trailingAnchor.constraint(equalTo: expandedContentView.trailingAnchor, constant: -16),
            motionPanel.topAnchor.constraint(equalTo: expandedHeaderRow.bottomAnchor, constant: 16),
            motionPanel.bottomAnchor.constraint(equalTo: expandedContentView.bottomAnchor, constant: -16),

            motionPanelStack.leadingAnchor.constraint(equalTo: motionPanel.leadingAnchor),
            motionPanelStack.trailingAnchor.constraint(equalTo: motionPanel.trailingAnchor),
            motionPanelStack.topAnchor.constraint(equalTo: motionPanel.topAnchor),
            motionPanelStack.bottomAnchor.constraint(lessThanOrEqualTo: motionPanel.bottomAnchor)
        ])
    }

    private func makeLaneToggleRow() -> UIStackView {
        applyQuickPill(aiToggleButton, title: "AI", active: autoEnabled)
        applyQuickPill(tiltToggleButton, title: "Tilt", active: tiltEnabled && !autoEnabled)
        applyQuickPill(peekToggleButton, title: "Peek", active: peekEnabled)

        let row = UIStackView(arrangedSubviews: [
            aiToggleButton,
            tiltToggleButton,
            peekToggleButton
        ])
        row.axis = .horizontal
        row.alignment = .fill
        row.distribution = .fillEqually
        row.spacing = 8
        return row
    }

    // MARK: - Actions

    private func setupActions() {
        cinButton.addTarget(self, action: #selector(cinTapped), for: .touchUpInside)
        proButton.addTarget(self, action: #selector(proTapped), for: .touchUpInside)
        motionButton.addTarget(self, action: #selector(motionTapped), for: .touchUpInside)
        expandedCloseButton.addTarget(self, action: #selector(closeExpandedPanel), for: .touchUpInside)

        loadButton.addTarget(self, action: #selector(loadTappedFallback), for: .touchUpInside)
        exportButton.addTarget(self, action: #selector(exportTapped), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)

        depthToggleButton.addTarget(self, action: #selector(toggleDepthTapped), for: .touchUpInside)
        aiToggleButton.addTarget(self, action: #selector(toggleAITapped), for: .touchUpInside)
        tiltToggleButton.addTarget(self, action: #selector(toggleTiltTapped), for: .touchUpInside)
        peekToggleButton.addTarget(self, action: #selector(togglePeekTapped), for: .touchUpInside)

        resetButton.addTarget(self, action: #selector(resetStudioTapped), for: .touchUpInside)

        lensSegment.addTarget(self, action: #selector(lensChanged), for: .valueChanged)
        exportSegment.addTarget(self, action: #selector(exportChanged), for: .valueChanged)
        lutSegment.addTarget(self, action: #selector(lutChanged), for: .valueChanged)
        motionModeSegment.addTarget(self, action: #selector(runtimeModeChanged), for: .valueChanged)

        scrubber.addTarget(self, action: #selector(scrubBegan), for: .touchDown)
        scrubber.addTarget(self, action: #selector(scrubChangedAction), for: .valueChanged)
        scrubber.addTarget(self, action: #selector(scrubEnded), for: [.touchUpInside, .touchUpOutside, .touchCancel])

        depthDial.onValueChanged = { [weak self] value in
            self?.onDepthIntensityChanged?(value)
        }
        focusDial.onValueChanged = { [weak self] value in
            self?.onFocusFalloffChanged?(value)
        }
        bgDial.onValueChanged = { [weak self] value in
            self?.onBGPlaneControlChanged?(value)
        }
        midDial.onValueChanged = { [weak self] value in
            self?.onMIDPlaneControlChanged?(value)
        }
        fgDial.onValueChanged = { [weak self] value in
            self?.onFGPlaneControlChanged?(value)
        }
        framingDial.onValueChanged = { [weak self] value in
            self?.onFramingScaleChanged?(value)
        }

        [
            cinButton, proButton, motionButton, expandedCloseButton,
            loadButton, exportButton, playButton, depthToggleButton, aiToggleButton, tiltToggleButton, peekToggleButton,
            lensSegment, exportSegment, lutSegment, motionModeSegment, scrubber
        ].forEach { wireInteractionHold(to: $0) }

        [depthDial, focusDial, bgDial, midDial, fgDial, framingDial].forEach { dial in
            dial.onInteractionBegan = { [weak self] in self?.beginInteractionHold() }
            dial.onInteractionEnded = { [weak self] in self?.endInteractionHold() }
        }
    }

    private func configureLoadMenu() {
        let libraryAction = UIAction(title: "Photo Library", image: UIImage(systemName: "photo.on.rectangle")) { [weak self] _ in
            guard let self = self else { return }

            if !self.isAppUnlocked {
                self.onLockedLoadTapped?()
                return
            }

            self.onLoadVideo?()
        }

        let filesAction = UIAction(title: "Files", image: UIImage(systemName: "folder")) { [weak self] _ in
            guard let self = self else { return }

            if !self.isAppUnlocked {
                self.onLockedLoadTapped?()
                return
            }

            self.onLoadFile?()
        }

        loadButton.menu = UIMenu(title: "", children: [libraryAction, filesAction])
        loadButton.showsMenuAsPrimaryAction = true
    }

    private func configureDefaults() {
        runtimeModeIndex = 1
        runtimeLensIndex = 1
        motionModeSegment.selectedSegmentIndex = runtimeModeIndex
        lensSegment.selectedSegmentIndex = runtimeLensIndex
        exportSegment.selectedSegmentIndex = exportModeIndex
        lutSegment.selectedSegmentIndex = 0
    }

    private func beginInteractionHold() {
        onInteractionBegan?()
    }

    private func endInteractionHold() {
        onInteractionEnded?()
    }

    private func wireInteractionHold(to control: UIControl) {
        control.addTarget(self, action: #selector(handleInteractionTouchDown), for: [.touchDown, .touchDragEnter])
        control.addTarget(self, action: #selector(handleInteractionTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
    }

    @objc private func handleInteractionTouchDown() {
        onInteractionBegan?()
    }

    @objc private func handleInteractionTouchUp() {
        onInteractionEnded?()
    }

    // MARK: - Refresh

    private func refreshAll() {
        refreshStatusChip()
        refreshPlayIcon()
        refreshBottomButtons()
        refreshQuickPills()
        refreshExpandedPanel(animated: false)

        cinPanel.isHidden = activePanel != .cin
        proPanel.isHidden = activePanel != .pro
        motionPanel.isHidden = activePanel != .motion

        cinPanel.alpha = activePanel == .cin ? 1.0 : 0.0
        proPanel.alpha = activePanel == .pro ? 1.0 : 0.0
        motionPanel.alpha = activePanel == .motion ? 1.0 : 0.0
    }

    private func refreshBottomButtons() {
        let locked = !isAppUnlocked

        loadButton.configuration = makeCornerButtonConfig(symbol: "square.and.arrow.down")
        loadButton.alpha = locked ? 0.4 : 1.0
        loadButton.isUserInteractionEnabled = !locked

        exportButton.configuration = makeCornerButtonConfig(symbol: "square.and.arrow.up")
        exportButton.alpha = locked ? 0.4 : 1.0
        exportButton.isUserInteractionEnabled = !locked

        cinButton.configuration = makeSmallTabConfig(
            title: "Cin",
            symbol: activePanel == .cin ? "xmark" : "sparkles",
            active: activePanel == .cin
        )

        proButton.configuration = makeSmallTabConfig(
            title: "Pro",
            symbol: activePanel == .pro ? "xmark" : "dial.medium",
            active: activePanel == .pro
        )

        let motionActiveVisual = activePanel == .motion || autoEnabled || tiltEnabled || peekEnabled
        motionButton.configuration = makeSmallTabConfig(
            title: "Motion",
            symbol: activePanel == .motion ? "xmark" : "move.3d",
            active: motionActiveVisual
        )

        applyTabPolish(cinButton, active: activePanel == .cin)
        applyTabPolish(proButton, active: activePanel == .pro)
        applyTabPolish(motionButton, active: motionActiveVisual)
    }

    private func refreshStatusChip() {
        let presetName: String = {
            switch runtimeLensIndex {
            case 0: return "NAT"
            case 1: return "ANA"
            case 2: return "PORT"
            default: return "ANA"
            }
        }()

        let exportName: String = {
            switch exportModeIndex {
            case 1: return " • EXPORT BAL"
            case 2: return " • EXPORT ULTRA"
            case 3: return " • EXPORT AGGR"
            default: return ""
            }
        }()

        let text: String
        if let overrideText = statusChipOverrideText {
            text = overrideText
        } else if let progress = statusChipRenderingProgress {
            let pct = Int((max(0.0, min(1.0, progress)) * 100.0).rounded())
            text = "\(presetName)\(exportName) • RENDER \(pct)%"
        } else if depthEnabled {
            text = "\(presetName)\(exportName)"
        } else {
            text = "DEPTH OFF"
        }

        centerStatusChip.text = text
        centerStatusChip.backgroundColor = depthEnabled
            ? UIColor.systemRed.withAlphaComponent(0.16)
            : UIColor.white.withAlphaComponent(0.045)
    }

    private func refreshPlayIcon() {
        playIconView.image = UIImage(systemName: isPlaying ? "pause.fill" : "play.fill")
    }

    private func refreshQuickPills() {
        applyQuickPill(depthToggleButton, title: "Depth", active: depthEnabled)
        applyQuickPill(aiToggleButton, title: "AI", active: autoEnabled)
        applyQuickPill(tiltToggleButton, title: "Tilt", active: tiltEnabled && !autoEnabled)
        applyQuickPill(peekToggleButton, title: "Peek", active: peekEnabled)
        motionModeSegment.selectedSegmentIndex = runtimeModeIndex
    }

    private func refreshExpandedPanel(animated: Bool) {
        let isExpanded = activePanel != .main
       
        switch activePanel {
        case .cin:
            expandedTitleLabel.text = "CIN"
            expandedSubtitleLabel.text = "Presets • live depth / focus • export"
        case .pro:
            expandedTitleLabel.text = "PRO"
            expandedSubtitleLabel.text = "Plane spread • framing • reset"
        case .motion:
            expandedTitleLabel.text = "MOTION"
            expandedSubtitleLabel.text = "AI • tilt • peek • mode"
        case .main:
            expandedTitleLabel.text = ""
            expandedSubtitleLabel.text = ""
        }

        cinPanel.isHidden = activePanel != .cin
        proPanel.isHidden = activePanel != .pro
        motionPanel.isHidden = activePanel != .motion

        let updates = {
            self.mainContentView.alpha = isExpanded ? 0.0 : 1.0
            self.expandedContentView.alpha = isExpanded ? 1.0 : 0.0
            self.mainContentView.transform = isExpanded
                ? CGAffineTransform(scaleX: 0.98, y: 0.98)
                : .identity
            self.expandedContentView.transform = isExpanded
                ? .identity
                : CGAffineTransform(scaleX: 0.98, y: 0.98)
        }

        if isExpanded {
            expandedContentView.isHidden = false
        } else {
            mainContentView.isHidden = false
        }

        let finish: (Bool) -> Void = { _ in
            self.mainContentView.isHidden = isExpanded
            self.expandedContentView.isHidden = !isExpanded
        }

        if animated {
            UIView.animate(
                withDuration: 0.24,
                delay: 0,
                options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction],
                animations: updates,
                completion: finish
            )
        } else {
            updates()
            finish(true)
        }
    }

    private func animateTap(_ view: UIView) {
        UIView.animate(withDuration: 0.07, animations: {
            view.transform = CGAffineTransform(scaleX: 0.93, y: 0.93)
        }) { _ in
            UIView.animate(
                withDuration: 0.22,
                delay: 0,
                usingSpringWithDamping: 0.62,
                initialSpringVelocity: 3.2,
                options: [.curveEaseOut],
                animations: {
                    view.transform = .identity
                }
            )
        }
    }

    // MARK: - Styling

    private func makeCornerButtonConfig(symbol: String, active: Bool = false) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: symbol)
        config.title = nil
        config.cornerStyle = .capsule
        config.baseForegroundColor = active ? UIColor.systemRed : UIColor.white.withAlphaComponent(0.86)
        config.baseBackgroundColor = active
            ? UIColor.systemRed.withAlphaComponent(0.28)
            : UIColor.white.withAlphaComponent(0.05)
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        return config
    }

    private func makeSmallTabConfig(title: String, symbol: String, active: Bool) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.image = UIImage(systemName: symbol)
        config.imagePlacement = .leading
        config.imagePadding = 6
        config.cornerStyle = .capsule

        config.baseForegroundColor = active
            ? UIColor.white
            : UIColor.white.withAlphaComponent(0.92)

        config.baseBackgroundColor = active
            ? UIColor.systemRed.withAlphaComponent(0.34)
            : UIColor.white.withAlphaComponent(0.055)

        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)

        var container = AttributeContainer()
        container.font = UIFont.systemFont(ofSize: 11.5, weight: .bold)
        config.attributedTitle = AttributedString(title, attributes: container)

        config.titleLineBreakMode = .byClipping
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 11.5, weight: .bold)
            return outgoing
        }

        return config
    }

    private func applyTabPolish(_ button: UIButton, active: Bool) {
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = false
        button.layer.borderWidth = active ? 1.0 : 0.8
        button.layer.borderColor = active
            ? UIColor.white.withAlphaComponent(0.15).cgColor
            : UIColor.white.withAlphaComponent(0.05).cgColor
        button.layer.shadowColor = UIColor.systemRed.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.layer.shadowRadius = active ? 18 : 8
        button.layer.shadowOpacity = active ? 0.32 : 0.08
    }

    private func makeResetButtonConfig(title: String) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseForegroundColor = .white
        config.baseBackgroundColor = UIColor.white.withAlphaComponent(0.075)
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14)

        var container = AttributeContainer()
        container.font = UIFont.systemFont(ofSize: 13.5, weight: .semibold)
        config.attributedTitle = AttributedString(title, attributes: container)

        return config
    }

    private func makeCloseButtonConfig() -> UIButton.Configuration {
        var closeConfig = UIButton.Configuration.plain()
        closeConfig.image = UIImage(systemName: "xmark")
        closeConfig.baseForegroundColor = UIColor.white.withAlphaComponent(0.84)
        closeConfig.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        return closeConfig
    }

    private func applyQuickPill(_ button: UIButton, title: String, active: Bool) {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseForegroundColor = active ? UIColor.systemRed : UIColor.white.withAlphaComponent(0.86)
        config.baseBackgroundColor = active
            ? UIColor.white.withAlphaComponent(0.10)
            : UIColor.white.withAlphaComponent(0.05)
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 10, bottom: 7, trailing: 10)

        var container = AttributeContainer()
        container.font = UIFont.systemFont(ofSize: 10.5, weight: .semibold)
        config.attributedTitle = AttributedString(title, attributes: container)

        button.configuration = config
    }

    private func configureSegment(_ control: UISegmentedControl) {
        control.selectedSegmentTintColor = UIColor(red: 0.90, green: 0.15, blue: 0.15, alpha: 0.28)
        control.backgroundColor = UIColor.white.withAlphaComponent(0.055)
        control.layer.cornerRadius = 14
        control.clipsToBounds = true

        let normalAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.74),
            .font: UIFont.systemFont(ofSize: 12, weight: .semibold)
        ]

        let selectedAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 12, weight: .bold)
        ]

        control.setTitleTextAttributes(normalAttrs, for: .normal)
        control.setTitleTextAttributes(selectedAttrs, for: .selected)
    }

    private func makeSectionLabel(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title.uppercased()
        label.textColor = UIColor.white.withAlphaComponent(0.50)
        label.font = .systemFont(ofSize: 10, weight: .bold)
        return label
    }

    private static func makeRoundedThumbImage(diameter: CGFloat) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        return renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: CGSize(width: diameter, height: diameter))
            ctx.cgContext.setShadow(offset: CGSize(width: 0, height: 1), blur: 6, color: UIColor.black.withAlphaComponent(0.45).cgColor)
            UIColor.white.setFill()
            UIBezierPath(ovalIn: rect).fill()
        }.withRenderingMode(.alwaysOriginal)
    }

    // MARK: - Button Actions

    @objc private func cinTapped() {
        animateTap(cinButton)
        activePanel = (activePanel == .cin) ? .main : .cin
        refreshAll()
    }

    @objc private func proTapped() {
        animateTap(proButton)
        activePanel = (activePanel == .pro) ? .main : .pro
        refreshAll()
    }

    @objc private func motionTapped() {
        animateTap(motionButton)
        activePanel = (activePanel == .motion) ? .main : .motion
        refreshAll()
    }

    @objc private func closeExpandedPanel() {
        activePanel = .main
        refreshAll()
    }

    @objc private func exportTapped() {
        guard isAppUnlocked else {
            onLockedExportTapped?()
            return
        }
        onExportTapped?()
    }

    @objc private func playTapped() {
        onPlayPause?()
    }

    @objc private func toggleDepthTapped() {
        depthEnabled.toggle()
        refreshAll()
        onToggleDepth?(depthEnabled)
    }

    @objc private func toggleAITapped() {
        autoEnabled.toggle()

        if autoEnabled {
            tiltEnabled = false
        }

        refreshAll()
        onToggleAI?(autoEnabled)
    }

    @objc private func toggleTiltTapped() {
        let newValue = !tiltEnabled
        tiltEnabled = newValue

        if newValue && autoEnabled {
            autoEnabled = false
            onToggleAI?(false)
        }

        refreshAll()
        onToggleTilt?(tiltEnabled)
    }

    @objc private func togglePeekTapped() {
        let newValue = !peekEnabled
        peekEnabled = newValue

        refreshAll()
        onTogglePeek?(peekEnabled)
    }

    @objc private func lensChanged() {
        runtimeLensIndex = lensSegment.selectedSegmentIndex
        onLensModeChanged?(runtimeLensIndex)
        refreshAll()
    }

    @objc private func exportChanged() {
        exportModeIndex = exportSegment.selectedSegmentIndex
        onExportModeChanged?(exportModeIndex)
        refreshAll()
    }

    @objc private func lutChanged() {
        onLUTChanged?(lutSegment.selectedSegmentIndex)
        refreshAll()
    }
   
    @objc private func loadTappedFallback() {
        guard isAppUnlocked else {
            onLockedLoadTapped?()
            return
        }
        onLoadVideo?()
    }
    @objc private func runtimeModeChanged() {
        let selectedIndex = motionModeSegment.selectedSegmentIndex
        runtimeModeIndex = selectedIndex
        motionModeSegment.selectedSegmentIndex = selectedIndex

        if runtimeModeIndex == 0 {
            autoEnabled = false
            tiltEnabled = false
            peekEnabled = false
            onToggleAI?(false)
            onToggleTilt?(false)
            onTogglePeek?(false)
        } else if autoEnabled {
            tiltEnabled = false
        } else if !tiltEnabled && !peekEnabled {
            tiltEnabled = true
            peekEnabled = true
            onToggleTilt?(true)
            onTogglePeek?(true)
        }

        refreshAll()
        onModeChanged?(runtimeModeIndex)
    }

    @objc private func scrubBegan() {
        onScrubBegan?()
    }

    @objc private func scrubChangedAction() {
        onScrubChanged?(scrubber.value)
    }

    @objc private func scrubEnded() {
        onScrubEnded?(scrubber.value)
    }

    @objc private func resetStudioTapped() {
        lensSegment.selectedSegmentIndex = 1
        runtimeLensIndex = 1

        motionModeSegment.selectedSegmentIndex = 1
        runtimeModeIndex = 1
        exportSegment.selectedSegmentIndex = 0
        exportModeIndex = 0
        lutSegment.selectedSegmentIndex = 0

        autoEnabled = false
        tiltEnabled = true
        peekEnabled = true
        depthEnabled = true

        framingDial.setValue(0.86)

        activePanel = .main
        refreshAll()

        onToggleAI?(false)
        onToggleTilt?(true)
        onTogglePeek?(true)
        onToggleDepth?(true)
        onExportModeChanged?(0)
        onLUTChanged?(0)
        onModeChanged?(1)
        onLensModeChanged?(1)
        onFramingScaleChanged?(0.86)
    }

    // MARK: - External API

    func setInitial(depthOn: Bool, aiOn: Bool, tiltOn: Bool, peekOn: Bool, modeIndex: Int) {
        depthEnabled = depthOn
        autoEnabled = aiOn
        tiltEnabled = tiltOn
        peekEnabled = peekOn
        runtimeModeIndex = modeIndex
        motionModeSegment.selectedSegmentIndex = modeIndex
        refreshAll()
    }

    func setLensMode(_ idx: Int) {
        runtimeLensIndex = idx
        lensSegment.selectedSegmentIndex = idx
    }

    func setExportMode(_ idx: Int) {
        exportModeIndex = max(0, min(3, idx))
        exportSegment.selectedSegmentIndex = exportModeIndex
        refreshStatusChip()
    }

    func setLUTPreset(_ idx: Int) {
        let safe = max(0, min(5, idx))
        lutSegment.selectedSegmentIndex = safe
    }

    func setDepthIntensity(_ value: Float) {
        depthDial.setValue(value)
    }

    func setFocusFalloff(_ value: Float) {
        focusDial.setValue(value)
    }

    func setBGPlaneControl(_ value: Float) {
        bgDial.setValue(value)
    }

    func setMIDPlaneControl(_ value: Float) {
        midDial.setValue(value)
    }

    func setFGPlaneControl(_ value: Float) {
        fgDial.setValue(value)
    }

    func setFramingScale(_ value: Float) {
        framingDial.setValue(value)
    }

    func setTime(current: Double, duration: Double) {
        guard duration > 0 else { return }
        scrubber.value = Float(current / duration)
    }

    func setVolume(_ value: Float) {
        _ = value
    }

    func setPlaying(_ playing: Bool) {
        isPlaying = playing
        refreshPlayIcon()
    }

    func setClipName(_ name: String) {
        _ = name
    }

    func setDepthRenderProgress(_ progress: Double?) {
        statusChipRenderingProgress = progress
        if progress != nil {
            statusChipOverrideText = nil
        }
        refreshStatusChip()
    }

    func setStatusChipText(_ text: String?) {
        statusChipOverrideText = text
        refreshStatusChip()
    }

    func setChromeVisible(_ visible: Bool, animated: Bool) {
        let updates = {
            self.alpha = visible ? 1.0 : 0.0
        }

        if animated {
            UIView.animate(
                withDuration: 0.22,
                delay: 0,
                options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction],
                animations: updates
            )
        } else {
            updates()
        }
    }

    func isPinnedOpen() -> Bool {
        activePanel != .main
    }
}

final class HKV1PaddingLabel: UILabel {
    var insets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + insets.left + insets.right,
            height: size.height + insets.top + insets.bottom
        )
    }
}

private final class HKV1_RedDialControl: UIControl {

    enum Style {
        case large
        case small
        case compact
    }

    var onValueChanged: ((Float) -> Void)?
    var onInteractionBegan: (() -> Void)?
    var onInteractionEnded: (() -> Void)?
    var onExportModeChanged: ((Int) -> Void)?

    private let title: String
    private let minValue: Float
    private let maxValue: Float
    private let decimals: Int
    private let style: Style
    private let sensitivityMultiplier: Float

    private(set) var value: Float {
        didSet {
            updateLabels()
            setNeedsDisplay()
        }
    }

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    init(
        title: String,
        minValue: Float,
        maxValue: Float,
        value: Float,
        decimals: Int,
        style: Style,
        sensitivityMultiplier: Float = 1.0
    ) {
        self.title = title
        self.minValue = minValue
        self.maxValue = maxValue
        self.value = value
        self.decimals = decimals
        self.style = style
        self.sensitivityMultiplier = sensitivityMultiplier
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        switch style {
        case .large:
            return CGSize(width: 138, height: 146)
        case .small:
            return CGSize(width: 92, height: 128)
        case .compact:
            return CGSize(width: 92, height: 122)
        }
    }

    private func setup() {
        backgroundColor = .clear

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.82)
        titleLabel.textAlignment = .center

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.textColor = .white
        valueLabel.textAlignment = .center

        switch style {
        case .large:
            titleLabel.font = .systemFont(ofSize: 11.5, weight: .bold)
            valueLabel.font = .monospacedDigitSystemFont(ofSize: 16, weight: .bold)
        case .small:
            titleLabel.font = .systemFont(ofSize: 10.5, weight: .bold)
            valueLabel.font = .monospacedDigitSystemFont(ofSize: 14, weight: .bold)
        case .compact:
            titleLabel.font = .systemFont(ofSize: 10.5, weight: .bold)
            valueLabel.font = .monospacedDigitSystemFont(ofSize: 12.5, weight: .bold)
        }

        addSubview(titleLabel)
        addSubview(valueLabel)

        let titleBottom: CGFloat
        let valueBottom: CGFloat

        switch style {
        case .large:
            titleBottom = -20
            valueBottom = -1
        case .small:
            titleBottom = -18
            valueBottom = -2
        case .compact:
            titleBottom = -18
            valueBottom = -2
        }

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: titleBottom),

            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: valueBottom)
        ])

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)

        updateLabels()
    }

    func setValue(_ newValue: Float) {
        value = clamped(newValue)
    }

    func makeReadOnlyClone() -> HKV1_RedDialControl {
        let clone = HKV1_RedDialControl(
            title: title,
            minValue: minValue,
            maxValue: maxValue,
            value: value,
            decimals: decimals,
            style: .compact,
            sensitivityMultiplier: sensitivityMultiplier
        )
        clone.isUserInteractionEnabled = false
        clone.alpha = 0.92
        return clone
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            onInteractionBegan?()
            alpha = 1.0
            layer.shadowOpacity = 0.35

        case .changed:
            let translation = gesture.translation(in: self)
            let sensitivity: Float

            switch style {
            case .large:
                sensitivity = 0.006
            case .small:
                sensitivity = 0.0045
            case .compact:
                sensitivity = 0.0040
            }

            let delta = Float(translation.x - translation.y) * sensitivity * sensitivityMultiplier

            if delta != 0 {
                value = clamped(value + delta)
                onValueChanged?(value)
                sendActions(for: .valueChanged)
                gesture.setTranslation(.zero, in: self)
            }

        case .ended, .cancelled, .failed:
            layer.shadowOpacity = 0.0
            onInteractionEnded?()

        default:
            break
        }
    }

    private func updateLabels() {
        valueLabel.text = String(format: "% .\(decimals)f", value).replacingOccurrences(of: " ", with: "")
    }

    private func clamped(_ input: Float) -> Float {
        max(minValue, min(maxValue, input))
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        let labelReserve: CGFloat
        switch style {
        case .large:
            labelReserve = 26
        case .small:
            labelReserve = 30
        case .compact:
            labelReserve = 28
        }

        let knobSide = min(rect.width, rect.height - labelReserve)
        let dialRect = CGRect(
            x: (rect.width - knobSide) * 0.5,
            y: style == .large ? 2 : 6,
            width: knobSide,
            height: knobSide
        )

        let center = CGPoint(x: dialRect.midX, y: dialRect.midY)
        let radius = knobSide * 0.5 - (style == .large ? 8 : 7)

        let ringWidth: CGFloat
        switch style {
        case .large:
            ringWidth = 6.5
        case .small:
            ringWidth = 4.2
        case .compact:
            ringWidth = 3.9
        }

        let startAngle = CGFloat(142.0 * .pi / 180.0)
        let endAngle = CGFloat(398.0 * .pi / 180.0)
        let progress = CGFloat((value - minValue) / (maxValue - minValue))
        let activeEnd = startAngle + (endAngle - startAngle) * progress

        ctx.saveGState()
        ctx.setShadow(offset: CGSize(width: 0, height: 12), blur: 18, color: UIColor.black.withAlphaComponent(0.74).cgColor)
        UIColor.black.withAlphaComponent(0.86).setFill()
        UIBezierPath(ovalIn: dialRect).fill()
        ctx.restoreGState()

        let bodyColors = [
            UIColor(white: 0.13, alpha: 1.0).cgColor,
            UIColor(white: 0.05, alpha: 1.0).cgColor,
            UIColor(white: 0.09, alpha: 1.0).cgColor
        ] as CFArray

        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: bodyColors, locations: [0, 0.56, 1]) {
            ctx.saveGState()
            let bodyPath = UIBezierPath(ovalIn: dialRect)
            bodyPath.addClip()
            ctx.drawLinearGradient(
                gradient,
                start: CGPoint(x: dialRect.minX, y: dialRect.minY),
                end: CGPoint(x: dialRect.maxX, y: dialRect.maxY),
                options: []
            )
            ctx.restoreGState()
        }

        UIColor.white.withAlphaComponent(0.05).setStroke()
        let bezelPath = UIBezierPath(ovalIn: dialRect.insetBy(dx: 1, dy: 1))
        bezelPath.lineWidth = 1.0
        bezelPath.stroke()

        ctx.saveGState()
        ctx.setLineWidth(ringWidth)
        ctx.setLineCap(.round)
        UIColor.white.withAlphaComponent(0.09).setStroke()
        ctx.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        ctx.strokePath()
        ctx.restoreGState()

        ctx.saveGState()
        ctx.setLineWidth(ringWidth)
        ctx.setLineCap(.round)
        ctx.setShadow(offset: .zero, blur: style == .large ? 26 : 20, color: UIColor.systemRed.withAlphaComponent(0.96).cgColor)
        UIColor.systemRed.withAlphaComponent(0.98).setStroke()
        ctx.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: activeEnd, clockwise: false)
        ctx.strokePath()
        ctx.restoreGState()

        ctx.saveGState()
        ctx.setLineWidth(style == .large ? 2.0 : 1.6)
        ctx.setLineCap(.round)
        UIColor.white.withAlphaComponent(0.70).setStroke()
        ctx.addArc(center: center, radius: radius + 0.1, startAngle: startAngle, endAngle: activeEnd, clockwise: false)
        ctx.strokePath()
        ctx.restoreGState()

        let innerInset: CGFloat
        switch style {
        case .large:
            innerInset = 18.0
        case .small:
            innerInset = 15.0
        case .compact:
            innerInset = 13.5
        }

        let innerRect = dialRect.insetBy(dx: innerInset, dy: innerInset)

        ctx.saveGState()
        ctx.setShadow(offset: CGSize(width: 0, height: 5), blur: 10, color: UIColor.black.withAlphaComponent(0.55).cgColor)
        UIColor.black.withAlphaComponent(0.94).setFill()
        UIBezierPath(ovalIn: innerRect).fill()
        ctx.restoreGState()

        UIColor.white.withAlphaComponent(0.045).setStroke()
        let innerBezel = UIBezierPath(ovalIn: innerRect.insetBy(dx: 1, dy: 1))
        innerBezel.lineWidth = 1.0
        innerBezel.stroke()

        let highlightRect = dialRect.insetBy(dx: 8, dy: 8)
        let highlightPath = UIBezierPath(
            arcCenter: CGPoint(x: highlightRect.midX, y: highlightRect.midY),
            radius: highlightRect.width * 0.5 - 4,
            startAngle: CGFloat(214.0 * .pi / 180.0),
            endAngle: CGFloat(296.0 * .pi / 180.0),
            clockwise: true
        )
        UIColor.white.withAlphaComponent(0.07).setStroke()
        highlightPath.lineWidth = 1.1
        highlightPath.stroke()
    }
}
