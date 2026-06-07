import SwiftUI

struct DemoReviewChecklistView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                HFDemoChecklistCard(title: "Before Demo", items: beforeDemo, systemImage: "checklist.checked", status: "Static")
                HFDemoChecklistCard(title: "Watch Review", items: watchReview, systemImage: "play.rectangle.fill")
                HFDemoChecklistCard(title: "Create Review", items: createReview, systemImage: "shippingbox.fill")
                HFDemoChecklistCard(title: "Connect Review", items: connectReview, systemImage: "person.2.fill")
                HFDemoChecklistCard(title: "Launch Review", items: launchReview, systemImage: "flag.checkered")
                HFDemoChecklistCard(title: "Export Review", items: exportReview, systemImage: "square.and.arrow.up", status: "Future")
                HFDemoChecklistCard(title: "Safety Review", items: safetyReview, systemImage: "lock.shield.fill", status: "Locked")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Demo Checklist")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFStatusBadge(title: "Static checklist", isProminent: true)

            Text("Demo Review Checklist")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text("Use this checklist to review the final product walkthrough. Items are display-only and never persist.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private let beforeDemo = ["Tree is clean", "Latest feature is committed", "QA tag is on HEAD", "App builds", "App installs", "App launches", "Five tabs visible"]
    private let watchReview = ["Home loads", "The Friendly is readable", "Movie Detail safe-area is correct", "Watch Now is primary", "Saved/Add To List remains visible", "Search works", "Unified Discovery works"]
    private let createReview = ["Creator Mode opens", "Creator Command Center opens", "Package Builder opens", "Release Readiness opens", "Team Review opens", "Launch Center opens"]
    private let connectReview = ["Connect Hub opens", "Community Discovery opens", "Social Rooms open", "Creator Circles open", "Social Graph opens", "Follow Suggestions open", "Activity Feed opens"]
    private let launchReview = ["Launch Center opens", "Access Preview opens", "Release Presentation opens", "Demo Checklist opens", "Release Candidate Prep opens"]
    private let exportReview = ["Social Export Hub is future/local only", "Composer is future/local only", "Brand Kit is future/local only", "Template Gallery is future/local only", "Export Preview is future/local only", "Queue is future/local only", "Demo Flow is future/local only", "Platform Guide is future/local only", "Safety Center remains a locked planning surface", "Protected Capture Roadmap remains future"]
    private let safetyReview = ["No backend", "No auth", "No payments", "No uploads", "No capture", "No rendering", "No share APIs", "No Photos", "No ReplayKit", "No protected system changes", "No Figma/assets/poster changes"]
}
