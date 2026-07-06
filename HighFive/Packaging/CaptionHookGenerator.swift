import Foundation

struct CaptionHookGenerator {
    func hooks(for packageItem: PromoPackageItem) -> [String] {
        switch packageItem.layout {
        case .titleCard:
            return [
                "A new western myth is taking shape.",
                "The West is not finished telling the truth."
            ]

        case .quoteCard:
            return [
                "The West is not the story they told. It is the truth they buried.",
                "Some legends were built to hide the evidence."
            ]

        case .characterCard:
            return [
                "Queho enters the frame.",
                "A character shaped by survival, myth, and consequence."
            ]

        case .worldLocations:
            return [
                "A world of dust, distance, and buried history.",
                "Every location carries a secret."
            ]

        case .pitchAtGlance:
            return [
                "A limited series built for cinematic scale.",
                "Original stories in motion."
            ]

        case .budgetInternal:
            return [
                "Internal packaging draft.",
                "Investment materials are not consumer-facing."
            ]
        }
    }
}
