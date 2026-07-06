import CoreGraphics

enum HKV1_ShotClass: String {
    case close
    case medium
    case wide
}

final class HKV1_ShotClassifier {

    func classify(
        heroRect: CGRect?,
        subjectCount: Int
    ) -> HKV1_ShotClass {
        guard let heroRect else { return .wide }

        let area = heroRect.width * heroRect.height

        if area > 0.14 {
            return .close
        }

        if subjectCount >= 3 {
            return .wide
        }

        if area < 0.055 {
            return .wide
        }

        return .medium
    }

    func speakingWeight(for shotClass: HKV1_ShotClass) -> CGFloat {
        switch shotClass {
        case .close:
            return 0.62
        case .medium:
            return 0.85
        case .wide:
            return 1.05
        }
    }

    func holdBonus(for shotClass: HKV1_ShotClass) -> CGFloat {
        switch shotClass {
        case .close:
            return 0.22
        case .medium:
            return 0.14
        case .wide:
            return 0.06
        }
    }

    func switchMargin(for shotClass: HKV1_ShotClass) -> CGFloat {
        switch shotClass {
        case .close:
            return 0.44
        case .medium:
            return 0.36
        case .wide:
            return 0.28
        }
    }
}
