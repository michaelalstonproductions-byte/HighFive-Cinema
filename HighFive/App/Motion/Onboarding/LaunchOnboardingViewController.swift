import UIKit

final class LaunchOnboardingViewController: UIViewController {

    private enum Screen {
        case instructions
        case motion
    }

    private let backgroundImageView = UIImageView()
    private let backgroundOverlayView = UIView()
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let pageControl = UIPageControl()
    private let primaryButton = UIButton(type: .system)
    private let secondaryButton = UIButton(type: .system)
    private let motionPromptContainer = UIView()
    private let motionPhoneView = UIView()
    private let motionPhoneScreenView = UIView()
    private let motionPhoneBackgroundView = UIView()
    private let motionPhoneForegroundView = UIView()
    private let motionPhoneEdgeRevealView = UIView()
    private let motionPhoneSpeakerView = UIView()
    private let motionPhoneCameraView = UIView()
    private let motionTiltLabel = UILabel()
    private let motionPeekLabel = UILabel()
    private let motionCompatibilityLabel = UILabel()

    private var currentScreen: Screen = .instructions
    private var hasPositionedMotionPhonePivot = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        renderCurrentScreen(animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !hasPositionedMotionPhonePivot else { return }

        let originalPosition = motionPhoneView.layer.position
        motionPhoneView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.86)
        motionPhoneView.layer.position = originalPosition
        hasPositionedMotionPhonePivot = true
    }

    private func setupUI() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true

        backgroundOverlayView.translatesAutoresizingMaskIntoConstraints = false
        backgroundOverlayView.backgroundColor = UIColor.black.withAlphaComponent(0.54)

        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        bodyLabel.textColor = UIColor(white: 1.0, alpha: 0.84)
        bodyLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        bodyLabel.textAlignment = .center
        bodyLabel.numberOfLines = 0
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false

        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = 2
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.30)
        pageControl.isUserInteractionEnabled = false

        primaryButton.setTitle("Next", for: .normal)
        primaryButton.setTitleColor(.black, for: .normal)
        primaryButton.backgroundColor = .white
        primaryButton.layer.cornerRadius = 16
        primaryButton.layer.cornerCurve = .continuous
        primaryButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        primaryButton.translatesAutoresizingMaskIntoConstraints = false
        primaryButton.accessibilityIdentifier = "onboardingNextButton"
        primaryButton.addTarget(self, action: #selector(handleNext), for: .touchUpInside)

        secondaryButton.setTitle("Skip", for: .normal)
        secondaryButton.setTitleColor(UIColor(white: 1.0, alpha: 0.8), for: .normal)
        secondaryButton.backgroundColor = UIColor(white: 1.0, alpha: 0.08)
        secondaryButton.layer.cornerRadius = 16
        secondaryButton.layer.cornerCurve = .continuous
        secondaryButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        secondaryButton.translatesAutoresizingMaskIntoConstraints = false
        secondaryButton.accessibilityIdentifier = "onboardingSkipButton"
        secondaryButton.addTarget(self, action: #selector(handleSkip), for: .touchUpInside)

        motionPromptContainer.translatesAutoresizingMaskIntoConstraints = false
        motionPromptContainer.alpha = 0.0

        motionPhoneView.translatesAutoresizingMaskIntoConstraints = false
        motionPhoneView.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        motionPhoneView.layer.cornerRadius = 30
        motionPhoneView.layer.cornerCurve = .continuous
        motionPhoneView.layer.borderWidth = 1
        motionPhoneView.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        motionPhoneView.layer.shadowColor = UIColor.black.cgColor
        motionPhoneView.layer.shadowOpacity = 0.22
        motionPhoneView.layer.shadowRadius = 18
        motionPhoneView.layer.shadowOffset = CGSize(width: 0, height: 14)

        motionPhoneScreenView.translatesAutoresizingMaskIntoConstraints = false
        motionPhoneScreenView.backgroundColor = UIColor(white: 0.04, alpha: 1.0)
        motionPhoneScreenView.layer.cornerRadius = 24
        motionPhoneScreenView.layer.cornerCurve = .continuous
        motionPhoneScreenView.clipsToBounds = true

        motionPhoneBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        motionPhoneBackgroundView.backgroundColor = UIColor(red: 0.11, green: 0.14, blue: 0.20, alpha: 1.0)
        motionPhoneBackgroundView.layer.cornerRadius = 24
        motionPhoneBackgroundView.layer.cornerCurve = .continuous

        motionPhoneForegroundView.translatesAutoresizingMaskIntoConstraints = false
        motionPhoneForegroundView.backgroundColor = UIColor(red: 0.84, green: 0.88, blue: 0.93, alpha: 0.18)
        motionPhoneForegroundView.layer.cornerRadius = 18
        motionPhoneForegroundView.layer.cornerCurve = .continuous

        motionPhoneEdgeRevealView.translatesAutoresizingMaskIntoConstraints = false
        motionPhoneEdgeRevealView.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        motionPhoneEdgeRevealView.layer.cornerRadius = 24
        motionPhoneEdgeRevealView.layer.cornerCurve = .continuous

        motionPhoneSpeakerView.translatesAutoresizingMaskIntoConstraints = false
        motionPhoneSpeakerView.backgroundColor = UIColor(white: 0.82, alpha: 1.0)
        motionPhoneSpeakerView.layer.cornerRadius = 2
        motionPhoneSpeakerView.layer.cornerCurve = .continuous

        motionPhoneCameraView.translatesAutoresizingMaskIntoConstraints = false
        motionPhoneCameraView.backgroundColor = UIColor(white: 0.70, alpha: 1.0)
        motionPhoneCameraView.layer.cornerRadius = 4
        motionPhoneCameraView.layer.cornerCurve = .continuous

        motionTiltLabel.translatesAutoresizingMaskIntoConstraints = false
        motionTiltLabel.text = "Tilt to move"
        motionTiltLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        motionTiltLabel.textColor = .white
        motionTiltLabel.textAlignment = .center

        motionPeekLabel.translatesAutoresizingMaskIntoConstraints = false
        motionPeekLabel.text = "Peek to explore"
        motionPeekLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        motionPeekLabel.textColor = UIColor(white: 1.0, alpha: 0.72)
        motionPeekLabel.textAlignment = .center

        motionCompatibilityLabel.translatesAutoresizingMaskIntoConstraints = false
        motionCompatibilityLabel.text = "Best experienced on iOS 26.2 or later. System updates may be required."
        motionCompatibilityLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        motionCompatibilityLabel.textColor = UIColor(white: 1.0, alpha: 0.62)
        motionCompatibilityLabel.textAlignment = .center
        motionCompatibilityLabel.numberOfLines = 2

        view.addSubview(backgroundImageView)
        view.addSubview(backgroundOverlayView)
        view.addSubview(titleLabel)
        view.addSubview(bodyLabel)
        view.addSubview(pageControl)
        view.addSubview(primaryButton)
        view.addSubview(secondaryButton)
        view.addSubview(motionPromptContainer)

        motionPromptContainer.addSubview(motionPhoneView)
        motionPromptContainer.addSubview(motionTiltLabel)
        motionPromptContainer.addSubview(motionPeekLabel)
        motionPromptContainer.addSubview(motionCompatibilityLabel)
        motionPhoneView.addSubview(motionPhoneScreenView)
        motionPhoneScreenView.addSubview(motionPhoneBackgroundView)
        motionPhoneScreenView.addSubview(motionPhoneEdgeRevealView)
        motionPhoneScreenView.addSubview(motionPhoneForegroundView)
        motionPhoneView.addSubview(motionPhoneSpeakerView)
        motionPhoneView.addSubview(motionPhoneCameraView)

        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            backgroundOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -122),

            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            bodyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 34),
            bodyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -34),

            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: primaryButton.topAnchor, constant: -18),

            primaryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            primaryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            primaryButton.heightAnchor.constraint(equalToConstant: 56),
            primaryButton.bottomAnchor.constraint(equalTo: secondaryButton.topAnchor, constant: -14),

            secondaryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            secondaryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            secondaryButton.heightAnchor.constraint(equalToConstant: 56),
            secondaryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -22),

            motionPromptContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            motionPromptContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            motionPromptContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -24),

            motionPhoneView.centerXAnchor.constraint(equalTo: motionPromptContainer.centerXAnchor),
            motionPhoneView.topAnchor.constraint(equalTo: motionPromptContainer.topAnchor),
            motionPhoneView.widthAnchor.constraint(equalToConstant: 156),
            motionPhoneView.heightAnchor.constraint(equalToConstant: 308),

            motionPhoneScreenView.leadingAnchor.constraint(equalTo: motionPhoneView.leadingAnchor, constant: 8),
            motionPhoneScreenView.trailingAnchor.constraint(equalTo: motionPhoneView.trailingAnchor, constant: -8),
            motionPhoneScreenView.topAnchor.constraint(equalTo: motionPhoneView.topAnchor, constant: 8),
            motionPhoneScreenView.bottomAnchor.constraint(equalTo: motionPhoneView.bottomAnchor, constant: -8),

            motionPhoneBackgroundView.widthAnchor.constraint(equalTo: motionPhoneScreenView.widthAnchor, multiplier: 1.40),
            motionPhoneBackgroundView.heightAnchor.constraint(equalTo: motionPhoneScreenView.heightAnchor),
            motionPhoneBackgroundView.centerXAnchor.constraint(equalTo: motionPhoneScreenView.centerXAnchor),
            motionPhoneBackgroundView.centerYAnchor.constraint(equalTo: motionPhoneScreenView.centerYAnchor),

            motionPhoneEdgeRevealView.widthAnchor.constraint(equalTo: motionPhoneScreenView.widthAnchor, multiplier: 0.52),
            motionPhoneEdgeRevealView.heightAnchor.constraint(equalTo: motionPhoneScreenView.heightAnchor, multiplier: 0.82),
            motionPhoneEdgeRevealView.centerXAnchor.constraint(equalTo: motionPhoneScreenView.centerXAnchor),
            motionPhoneEdgeRevealView.centerYAnchor.constraint(equalTo: motionPhoneScreenView.centerYAnchor, constant: -12),

            motionPhoneForegroundView.widthAnchor.constraint(equalTo: motionPhoneScreenView.widthAnchor, multiplier: 0.72),
            motionPhoneForegroundView.heightAnchor.constraint(equalTo: motionPhoneScreenView.heightAnchor, multiplier: 0.30),
            motionPhoneForegroundView.centerXAnchor.constraint(equalTo: motionPhoneScreenView.centerXAnchor),
            motionPhoneForegroundView.bottomAnchor.constraint(equalTo: motionPhoneScreenView.bottomAnchor, constant: -34),

            motionPhoneSpeakerView.centerXAnchor.constraint(equalTo: motionPhoneView.centerXAnchor),
            motionPhoneSpeakerView.topAnchor.constraint(equalTo: motionPhoneView.topAnchor, constant: 16),
            motionPhoneSpeakerView.widthAnchor.constraint(equalToConstant: 38),
            motionPhoneSpeakerView.heightAnchor.constraint(equalToConstant: 4),

            motionPhoneCameraView.leadingAnchor.constraint(equalTo: motionPhoneSpeakerView.trailingAnchor, constant: 8),
            motionPhoneCameraView.centerYAnchor.constraint(equalTo: motionPhoneSpeakerView.centerYAnchor),
            motionPhoneCameraView.widthAnchor.constraint(equalToConstant: 8),
            motionPhoneCameraView.heightAnchor.constraint(equalToConstant: 8),

            motionTiltLabel.topAnchor.constraint(equalTo: motionPhoneView.bottomAnchor, constant: 28),
            motionTiltLabel.leadingAnchor.constraint(equalTo: motionPromptContainer.leadingAnchor),
            motionTiltLabel.trailingAnchor.constraint(equalTo: motionPromptContainer.trailingAnchor),

            motionPeekLabel.topAnchor.constraint(equalTo: motionTiltLabel.bottomAnchor, constant: 8),
            motionPeekLabel.leadingAnchor.constraint(equalTo: motionPromptContainer.leadingAnchor),
            motionPeekLabel.trailingAnchor.constraint(equalTo: motionPromptContainer.trailingAnchor),
            motionCompatibilityLabel.topAnchor.constraint(equalTo: motionPeekLabel.bottomAnchor, constant: 10),
            motionCompatibilityLabel.leadingAnchor.constraint(equalTo: motionPromptContainer.leadingAnchor, constant: 8),
            motionCompatibilityLabel.trailingAnchor.constraint(equalTo: motionPromptContainer.trailingAnchor, constant: -8),
            motionCompatibilityLabel.bottomAnchor.constraint(equalTo: motionPromptContainer.bottomAnchor)
        ])
    }

    private func renderCurrentScreen(animated: Bool) {
        switch currentScreen {
        case .instructions:
            backgroundImageView.image = UIImage(named: "UI_Feature_ColorSystem")
            backgroundOverlayView.alpha = 1.0
            titleLabel.text = "Tilt your phone to move"
            bodyLabel.text = "Peek left and right to explore"
            pageControl.currentPage = 0
            primaryButton.setTitle("Next", for: .normal)
            secondaryButton.setTitle("Skip", for: .normal)
            secondaryButton.isHidden = false
            titleLabel.isHidden = false
            bodyLabel.isHidden = false
            motionPromptContainer.isHidden = true
            motionPromptContainer.alpha = 0.0

        case .motion:
            backgroundImageView.image = nil
            backgroundOverlayView.alpha = 0.0
            pageControl.currentPage = 1
            primaryButton.setTitle("Next", for: .normal)
            secondaryButton.isHidden = true
            titleLabel.isHidden = true
            bodyLabel.isHidden = true
            motionPromptContainer.isHidden = false
            startMotionPromptAnimation()
        }

        guard animated else {
            motionPromptContainer.alpha = currentScreen == .motion ? 1.0 : 0.0
            return
        }

        UIView.transition(with: backgroundImageView, duration: 0.30, options: [.transitionCrossDissolve]) {
            self.view.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.30, delay: 0.0, options: [.curveEaseOut]) {
            self.backgroundOverlayView.alpha = self.currentScreen == .instructions ? 1.0 : 0.0
            self.motionPromptContainer.alpha = self.currentScreen == .motion ? 1.0 : 0.0
            self.titleLabel.alpha = self.currentScreen == .instructions ? 1.0 : 0.0
            self.bodyLabel.alpha = self.currentScreen == .instructions ? 1.0 : 0.0
        } completion: { _ in
            if self.currentScreen == .instructions {
                self.titleLabel.alpha = 1.0
                self.bodyLabel.alpha = 1.0
            }
        }
    }

    @objc
    private func handleNext() {
        switch currentScreen {
        case .instructions:
            currentScreen = .motion
            renderCurrentScreen(animated: true)
        case .motion:
            enterIntroVideo()
        }
    }

    @objc
    private func handleSkip() {
        currentScreen = .motion
        renderCurrentScreen(animated: true)
    }

    private func startMotionPromptAnimation() {
        motionPhoneView.layer.removeAllAnimations()
        motionPhoneBackgroundView.layer.removeAllAnimations()
        motionPhoneForegroundView.layer.removeAllAnimations()
        motionPhoneEdgeRevealView.layer.removeAllAnimations()

        var perspective = CATransform3DIdentity
        perspective.m34 = -1.0 / 700.0
        motionPromptContainer.layer.sublayerTransform = perspective

        let tiltRoll = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        tiltRoll.values = [0.0, -0.12, 0.10, 0.0, 0.0, 0.0, 0.0]
        tiltRoll.keyTimes = [0.0, 0.12, 0.28, 0.42, 0.58, 0.80, 1.0]
        tiltRoll.duration = 5.2
        tiltRoll.timingFunctions = Array(repeating: CAMediaTimingFunction(name: .easeInEaseOut), count: 6)
        tiltRoll.repeatCount = .infinity
        tiltRoll.isAdditive = true

        let peekYaw = CAKeyframeAnimation(keyPath: "transform.rotation.y")
        peekYaw.values = [0.0, 0.0, 0.0, -0.24, 0.0, 0.24, 0.0]
        peekYaw.keyTimes = [0.0, 0.12, 0.28, 0.42, 0.58, 0.80, 1.0]
        peekYaw.duration = 5.2
        peekYaw.timingFunctions = Array(repeating: CAMediaTimingFunction(name: .easeInEaseOut), count: 6)
        peekYaw.repeatCount = .infinity
        peekYaw.isAdditive = true

        let phoneShift = CAKeyframeAnimation(keyPath: "transform.translation.x")
        phoneShift.values = [0.0, 0.0, 0.0, -4.0, 0.0, 4.0, 0.0]
        phoneShift.keyTimes = [0.0, 0.12, 0.28, 0.42, 0.58, 0.80, 1.0]
        phoneShift.duration = 5.2
        phoneShift.timingFunctions = Array(repeating: CAMediaTimingFunction(name: .easeInEaseOut), count: 6)
        phoneShift.repeatCount = .infinity
        phoneShift.isAdditive = true

        let backgroundParallax = CAKeyframeAnimation(keyPath: "transform.translation.x")
        backgroundParallax.values = [0.0, 0.0, 0.0, 24.0, 0.0, -24.0, 0.0]
        backgroundParallax.keyTimes = [0.0, 0.18, 0.42, 0.56, 0.68, 0.88, 1.0]
        backgroundParallax.duration = 5.2
        backgroundParallax.timingFunctions = Array(repeating: CAMediaTimingFunction(name: .easeInEaseOut), count: 6)
        backgroundParallax.repeatCount = .infinity
        backgroundParallax.isAdditive = true

        let foregroundParallax = CAKeyframeAnimation(keyPath: "transform.translation.x")
        foregroundParallax.values = [0.0, 0.0, 0.0, 12.0, 0.0, -12.0, 0.0]
        foregroundParallax.keyTimes = [0.0, 0.18, 0.42, 0.56, 0.68, 0.88, 1.0]
        foregroundParallax.duration = 5.2
        foregroundParallax.timingFunctions = Array(repeating: CAMediaTimingFunction(name: .easeInEaseOut), count: 6)
        foregroundParallax.repeatCount = .infinity
        foregroundParallax.isAdditive = true

        let edgeReveal = CAKeyframeAnimation(keyPath: "transform.translation.x")
        edgeReveal.values = [0.0, 0.0, 0.0, 16.0, 0.0, -16.0, 0.0]
        edgeReveal.keyTimes = [0.0, 0.18, 0.42, 0.56, 0.68, 0.88, 1.0]
        edgeReveal.duration = 5.2
        edgeReveal.timingFunctions = Array(repeating: CAMediaTimingFunction(name: .easeInEaseOut), count: 6)
        edgeReveal.repeatCount = .infinity
        edgeReveal.isAdditive = true

        motionPhoneView.layer.add(tiltRoll, forKey: "hf.motionPrompt.tiltRoll")
        motionPhoneView.layer.add(peekYaw, forKey: "hf.motionPrompt.peekYaw")
        motionPhoneView.layer.add(phoneShift, forKey: "hf.motionPrompt.phoneShift")
        motionPhoneBackgroundView.layer.add(backgroundParallax, forKey: "hf.motionPrompt.backgroundParallax")
        motionPhoneForegroundView.layer.add(foregroundParallax, forKey: "hf.motionPrompt.foregroundParallax")
        motionPhoneEdgeRevealView.layer.add(edgeReveal, forKey: "hf.motionPrompt.edgeReveal")
    }

    private func enterIntroVideo() {
        let vc = HKV1_SpatialPeekViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
}
