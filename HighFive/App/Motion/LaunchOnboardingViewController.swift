import UIKit

final class LaunchOnboardingViewController: UIViewController {

    private let backgroundView = UIView()
    private let logoContainer = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let primaryButton = UIButton(type: .system)
    private let skipButton = UIButton(type: .system)
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        buildUI()
        styleUI()
        layoutUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIntro()
    }

    private func buildUI() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        logoContainer.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        primaryButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(backgroundView)
        view.addSubview(stackView)

        stackView.addArrangedSubview(logoContainer)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(primaryButton)
        stackView.addArrangedSubview(skipButton)

        primaryButton.addTarget(self, action: #selector(handleContinueTapped), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(handleSkipTapped), for: .touchUpInside)
    }

    private func styleUI() {
        backgroundView.backgroundColor = .black

        logoContainer.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        logoContainer.layer.cornerRadius = 28
        logoContainer.layer.borderWidth = 1
        logoContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor

        titleLabel.text = "Welcome to HighFive"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        subtitleLabel.text = "Spatial cinema, motion depth, and premium playback — all inside your phone."
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.78)
        subtitleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        primaryButton.setTitle("Continue", for: .normal)
        primaryButton.setTitleColor(.black, for: .normal)
        primaryButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        primaryButton.backgroundColor = .white
        primaryButton.layer.cornerRadius = 16
        primaryButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)

        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(UIColor.white.withAlphaComponent(0.78), for: .normal)
        skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        skipButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)

        stackView.axis = .vertical
        stackView.spacing = 18
        stackView.alignment = .fill

        logoContainer.heightAnchor.constraint(equalToConstant: 140).isActive = true
    }

    private func layoutUI() {
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        let mark = UILabel()
        mark.translatesAutoresizingMaskIntoConstraints = false
        mark.text = "H"
        mark.textColor = .white
        mark.font = UIFont.systemFont(ofSize: 56, weight: .heavy)
        mark.textAlignment = .center
        logoContainer.addSubview(mark)

        NSLayoutConstraint.activate([
            mark.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor),
            mark.centerYAnchor.constraint(equalTo: logoContainer.centerYAnchor)
        ])
    }

    private func animateIntro() {
        stackView.alpha = 0
        stackView.transform = CGAffineTransform(translationX: 0, y: 18)

        UIView.animate(
            withDuration: 0.45,
            delay: 0.05,
            options: [.curveEaseOut]
        ) {
            self.stackView.alpha = 1
            self.stackView.transform = .identity
        }
    }

    @objc
    private func handleContinueTapped() {
        dismiss(animated: true)
    }

    @objc
    private func handleSkipTapped() {
        dismiss(animated: true)
    }
}
