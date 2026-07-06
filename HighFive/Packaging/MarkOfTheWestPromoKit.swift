import Foundation

enum MarkOfTheWestPromoKit {
    static let package = PromoPackage(
        id: "mark-west-promo-kit",
        title: "The Mark of the West Promo Kit",
        status: "Preview / Draft",
        items: [
            PromoPackageItem(
                id: "mark-west-title-card",
                title: "The Mark of the West",
                subtitle: "Limited Series Coming Soon",
                layout: .titleCard,
                exportPresets: [.tikTokVertical, .instagramReelStory, .linkedInLandscape, .pressKitSlide],
                assetName: "mark_west_hero_keyart",
                isInternalOnly: false
            ),
            PromoPackageItem(
                id: "mark-west-quote",
                title: "The West is not the story they told.",
                subtitle: "It is the truth they buried.",
                layout: .quoteCard,
                exportPresets: [.instagramSquare, .tikTokVertical, .posterExport],
                assetName: "mark_west_dark_quote",
                isInternalOnly: false
            ),
            PromoPackageItem(
                id: "mark-west-queho",
                title: "Queho",
                subtitle: "Character card",
                layout: .characterCard,
                exportPresets: [.tikTokVertical, .instagramReelStory, .posterExport],
                assetName: "mark_west_character_queho",
                isInternalOnly: false
            ),
            PromoPackageItem(
                id: "mark-west-world",
                title: "World / Locations",
                subtitle: "Desert, mountain, and frontier atmosphere",
                layout: .worldLocations,
                exportPresets: [.linkedInLandscape, .pressKitSlide],
                assetName: "mark_west_world_locations",
                isInternalOnly: false
            ),
            PromoPackageItem(
                id: "mark-west-pitch",
                title: "Pitch at a Glance",
                subtitle: "Internal preview card",
                layout: .pitchAtGlance,
                exportPresets: [.pressKitSlide, .linkedInLandscape],
                assetName: "mark_west_pitch_at_glance",
                isInternalOnly: true
            ),
            PromoPackageItem(
                id: "mark-west-budget",
                title: "Budget / Investment",
                subtitle: "Internal packaging only",
                layout: .budgetInternal,
                exportPresets: [.pressKitSlide],
                assetName: nil,
                isInternalOnly: true
            )
        ]
    )
}
