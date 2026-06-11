import SwiftUI

struct FinalDemoTourView: View {
    private let storyCopy = "WATCH first. Then CREATE, CONNECT, LAUNCH, EXPORT. Finish with Developer / QA proof. HighFive starts as a premium streaming app, then opens the product suite through Profile while internal validation stays separate."

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: HFSpacing.xl) {
                    Color.clear
                        .frame(height: 0)
                        .id("demoTourTop")

                    hero
                    actsSection
                    ecosystemProofBoardSection
                    runOfShowSection
                    screenshotPlanSection
                    productStorySection
                    figmaSourceSection
                    protectedSystemsSection
                }
                .padding(.top, HFSpacing.lg)
                .padding(.bottom, HFSpacing.floatingTabClearance)
            }
            .accessibilityIdentifier("hf.demoTour.root")
            .onAppear {
                DispatchQueue.main.async {
                    proxy.scrollTo("demoTourTop", anchor: .top)
                }
            }
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Demo Tour")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var hero: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(spacing: HFSpacing.sm) {
                    Image(systemName: "play.rectangle.on.rectangle.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(HFColors.gold)

                    Text("HighFive Cinema Product Story")
                        .font(HFTypography.display)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text("WATCH first. Then CREATE, CONNECT, LAUNCH, EXPORT. Finish with Developer / QA proof.")
                    .font(HFTypography.section)
                    .foregroundStyle(HFColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("A guided internal route through the consumer streaming shell, HighFive Rooms ecosystem, and Developer / QA validation layer.")
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 118), spacing: HFSpacing.xs)], alignment: .leading, spacing: HFSpacing.xs) {
                    ForEach(HFFinalDemoTourData.statusChips, id: \.self) { chip in
                        HFStatusBadge(title: chip, isProminent: chip == "Consumer First")
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("HighFive Cinema Product Story, Watch first, then Create Connect Launch Export, finishing with Developer and QA proof")
        .accessibilityIdentifier("hf.demoTour.presentationHero")
    }

    private var actsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.lg) {
            ForEach(HFFinalDemoTourData.acts) { act in
                demoActSection(act)
            }
        }
    }

    private func demoActSection(_ act: HFDemoAct) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Text(act.title)
                    .font(HFTypography.section)
                    .foregroundStyle(HFColors.textPrimary)

                Text(act.purpose)
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)

            VStack(spacing: HFSpacing.md) {
                ForEach(Array(act.steps.enumerated()), id: \.element.id) { index, step in
                    HFFinalDemoStepCard(step: step, stepNumber: index + 1)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(act.accessibilityLabel)
        .accessibilityIdentifier(actIdentifier(for: act.title))
    }

    private var screenshotPlanSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Screenshot Evidence Plan", actionTitle: nil)

            VStack(spacing: HFSpacing.sm) {
                ForEach(HFFinalDemoTourData.screenshotEvidencePlan) { target in
                    screenshotPlanRow(target)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Screenshot Evidence Plan, consumer evidence rooms evidence creator suite evidence launch connect evidence watch export evidence and internal QA evidence")
        .accessibilityIdentifier("hf.demoTour.screenshotEvidencePlan")
    }

    private var ecosystemProofBoardSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Ecosystem Proof Board", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 148), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                ForEach(HFFinalDemoTourData.ecosystemProofRows) { row in
                    proofRowCard(row)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Ecosystem Proof Board, consumer shell, rooms suite, creator studio, public momentum, professional path, evidence locks, live systems, and protected systems")
        .accessibilityIdentifier("hf.demoTour.ecosystemProofBoard")
    }

    private var runOfShowSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Presentation Run-of-Show", actionTitle: nil)

            VStack(spacing: HFSpacing.sm) {
                ForEach(HFFinalDemoTourData.presentationRunOfShow) { row in
                    proofRowCard(row)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Presentation Run of Show, Home, Movie Detail, Profile, Product Suite, each Room, Developer QA")
        .accessibilityIdentifier("hf.demoTour.runOfShow")
    }

    private func proofRowCard(_ row: HFDemoProofRow) -> some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.glassStroke) {
            HStack(alignment: .top, spacing: HFSpacing.sm) {
                Image(systemName: row.systemImage)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 34, height: 34)
                    .background(HFColors.gold.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    Text(row.title)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(row.detail)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    HFStatusBadge(title: row.status, isProminent: row.status == "Built")
                }

                Spacer(minLength: 0)
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(row.title), \(row.detail), status \(row.status)")
    }

    private func screenshotPlanRow(_ target: HFDemoScreenshotTarget) -> some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.glassStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(HFColors.gold)

                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text(target.filename)
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(target.route)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: HFSpacing.xs)

                    HFStatusBadge(title: target.status, isProminent: false)
                }

                Text(target.reviewFocus)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(target.filename), route \(target.route), focus \(target.reviewFocus), status \(target.status)")
    }

    private var productStorySection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "The HighFive Story", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    Text(storyCopy)
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 145), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                        ForEach(HFFinalDemoTourData.productStory) { item in
                            storyPillarCard(item)
                        }
                    }
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Product Spine, Watch Create Connect Launch Export mapping")
        .accessibilityIdentifier("hf.demoTour.highFiveStory")
    }

    private func storyPillarCard(_ item: HFDemoStoryItem) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: item.systemImage)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(HFColors.gold)

            Text(item.label)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)

            Text(item.value)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(HFColors.glassSurface)
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(HFColors.glassStroke, lineWidth: 1)
        )
    }

    private var figmaSourceSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Figma Source", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.glassStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    metadataRow(label: "File", value: "HighFive Cinema Master Template")
                    metadataRow(label: "File Key", value: "G2QYwgGfR08ZsF1oQpgDuG")
                    metadataRow(label: "Canvas", value: "01_Streaming_System")

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Primary production frames")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)

                        ForEach(HFFinalDemoTourData.figmaFrames, id: \.self) { frame in
                            Text(frame)
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    metadataRow(label: "Secondary style reference", value: "Home_Discovery_Gold - Node 11:9977")
                    metadataRow(label: "Classification", value: "Secondary / Style Support Only")
                    Text("Do not use secondary references to replace production frames.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Figma Source, HighFive Cinema Master Template production frames and secondary style reference")
        .accessibilityIdentifier("hf.demoTour.figmaSource")
    }

    private var protectedSystemsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Protected Systems Summary", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    Text("The demo tour may display these as static text. It must not touch or connect them.")
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: HFSpacing.xs)], alignment: .leading, spacing: HFSpacing.xs) {
                        ForEach(HFFinalDemoTourData.protectedPaths, id: \.self) { path in
                            HFRouteChip(title: path, systemImage: "lock.fill")
                        }
                    }
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Protected systems summary, protected paths and assets remain disconnected")
        .accessibilityIdentifier("hf.demoTour.protectedSystemsSummary")
    }

    private func actIdentifier(for title: String) -> String {
        switch title {
        case "Act 1 - Watch First": "hf.demoTour.actWatch"
        case "Act 2 - HighFive Rooms": "hf.demoTour.actRooms"
        case "Act 3 - Internal Validation": "hf.demoTour.actProof"
        default: "hf.demoTour.act"
        }
    }

    private func metadataRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xxs) {
            Text(label)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)

            Text(value)
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
