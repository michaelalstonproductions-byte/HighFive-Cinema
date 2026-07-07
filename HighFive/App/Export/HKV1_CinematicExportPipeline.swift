//
//  HKV1_CinematicExportPipeline.swift
//  HigherKeySpatialPeek_Rebuild
//
//  Created by Michael Alston on 3/29/26.
//
import UIKit
import CoreImage

final class HKV1_CinematicExportEngine {

    enum Preset: String, CaseIterable {
        case balanced
        case cinema
        case ultra
        case aggressive
        case imax
        case portrait
    }

    struct Parameters {
        let contrast: CGFloat
        let nearExponent: CGFloat
        let farExponent: CGFloat
        let splitThreshold: CGFloat
        let edgeBoost: CGFloat
        let centerPush: CGFloat
        let centerRadius: CGFloat
        let expansion: CGFloat
        let bias: CGFloat
        let blurRadius: CGFloat
        let unsharpIntensity: CGFloat
        let unsharpRadius: CGFloat

        static func forPreset(_ preset: Preset) -> Parameters {
            switch preset {
            case .balanced:
                return Parameters(
                    contrast: 1.9,
                    nearExponent: 1.45,
                    farExponent: 0.92,
                    splitThreshold: 0.58,
                    edgeBoost: 0.14,
                    centerPush: 0.10,
                    centerRadius: 0.60,
                    expansion: 1.18,
                    bias: -0.08,
                    blurRadius: 0.35,
                    unsharpIntensity: 0.30,
                    unsharpRadius: 1.1
                )
            case .cinema:
                return Parameters(
                    contrast: 2.2,
                    nearExponent: 1.75,
                    farExponent: 0.84,
                    splitThreshold: 0.54,
                    edgeBoost: 0.20,
                    centerPush: 0.14,
                    centerRadius: 0.58,
                    expansion: 1.32,
                    bias: -0.14,
                    blurRadius: 0.30,
                    unsharpIntensity: 0.42,
                    unsharpRadius: 1.25
                )
            case .ultra:
                return Parameters(
                    contrast: 2.5,
                    nearExponent: 2.05,
                    farExponent: 0.76,
                    splitThreshold: 0.50,
                    edgeBoost: 0.28,
                    centerPush: 0.18,
                    centerRadius: 0.56,
                    expansion: 1.48,
                    bias: -0.22,
                    blurRadius: 0.24,
                    unsharpIntensity: 0.52,
                    unsharpRadius: 1.4
                )
            case .aggressive:
                return Parameters(
                    contrast: 2.95,
                    nearExponent: 2.38,
                    farExponent: 0.64,
                    splitThreshold: 0.45,
                    edgeBoost: 0.38,
                    centerPush: 0.24,
                    centerRadius: 0.52,
                    expansion: 1.72,
                    bias: -0.30,
                    blurRadius: 0.18,
                    unsharpIntensity: 0.68,
                    unsharpRadius: 1.62
                )
            case .imax:
                return Parameters(
                    contrast: 2.65,
                    nearExponent: 2.18,
                    farExponent: 0.72,
                    splitThreshold: 0.48,
                    edgeBoost: 0.30,
                    centerPush: 0.16,
                    centerRadius: 0.62,
                    expansion: 1.56,
                    bias: -0.24,
                    blurRadius: 0.22,
                    unsharpIntensity: 0.56,
                    unsharpRadius: 1.48
                )
            case .portrait:
                return Parameters(
                    contrast: 2.35,
                    nearExponent: 2.08,
                    farExponent: 0.82,
                    splitThreshold: 0.52,
                    edgeBoost: 0.24,
                    centerPush: 0.22,
                    centerRadius: 0.48,
                    expansion: 1.42,
                    bias: -0.18,
                    blurRadius: 0.26,
                    unsharpIntensity: 0.48,
                    unsharpRadius: 1.30
                )
            }
        }
    }

    private let context = CIContext(options: [
        .cacheIntermediates: false,
        .useSoftwareRenderer: false
    ])

    func renderUltraDepth(from depthImage: UIImage, preset: Preset = .ultra) -> UIImage? {
        guard let input = CIImage(image: depthImage) else { return nil }
        guard let rendered = renderUltraDepthCI(from: input, preset: preset) else { return nil }
        let extent = rendered.extent.integral
        guard let cg = context.createCGImage(rendered, from: extent) else { return nil }
        return UIImage(cgImage: cg)
    }

    func renderUltraDepthCI(from input: CIImage, preset: Preset = .ultra) -> CIImage? {
        let extent = input.extent.integral
        guard extent.width > 0, extent.height > 0 else { return nil }

        let p = Parameters.forPreset(preset)

        var depth = input
            .applyingFilter("CIColorControls", parameters: [
                kCIInputSaturationKey: 0.0,
                kCIInputContrastKey: p.contrast,
                kCIInputBrightnessKey: 0.0
            ])
            .cropped(to: extent)

        let nearBoost = depth
            .applyingFilter("CIColorMatrix", parameters: [
                "inputRVector": CIVector(x: p.nearExponent, y: 0, z: 0, w: p.bias),
                "inputGVector": CIVector(x: 0, y: p.nearExponent, z: 0, w: p.bias),
                "inputBVector": CIVector(x: 0, y: 0, z: p.nearExponent, w: p.bias),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1.0)
            ])
            .cropped(to: extent)

        let farLift = depth
            .applyingFilter("CIColorMatrix", parameters: [
                "inputRVector": CIVector(x: p.farExponent, y: 0, z: 0, w: (1.0 - p.farExponent) * 0.14),
                "inputGVector": CIVector(x: 0, y: p.farExponent, z: 0, w: (1.0 - p.farExponent) * 0.14),
                "inputBVector": CIVector(x: 0, y: 0, z: p.farExponent, w: (1.0 - p.farExponent) * 0.14),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1.0)
            ])
            .cropped(to: extent)

        let splitMask = depth
            .applyingFilter("CIColorClamp", parameters: [
                "inputMinComponents": CIVector(x: p.splitThreshold, y: p.splitThreshold, z: p.splitThreshold, w: 0),
                "inputMaxComponents": CIVector(x: 1, y: 1, z: 1, w: 1)
            ])
            .applyingFilter("CIColorMatrix", parameters: [
                "inputRVector": CIVector(x: 4.0, y: 0, z: 0, w: -4.0 * p.splitThreshold),
                "inputGVector": CIVector(x: 0, y: 4.0, z: 0, w: -4.0 * p.splitThreshold),
                "inputBVector": CIVector(x: 0, y: 0, z: 4.0, w: -4.0 * p.splitThreshold),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1.0)
            ])
            .cropped(to: extent)

        if let blend = CIFilter(
            name: "CIBlendWithMask",
            parameters: [
                kCIInputImageKey: nearBoost,
                kCIInputBackgroundImageKey: farLift,
                kCIInputMaskImageKey: splitMask
            ]
        )?.outputImage?.cropped(to: extent) {
            depth = blend
        }

        let edges = depth
            .applyingFilter("CIEdges", parameters: [kCIInputIntensityKey: 2.8])
            .applyingFilter("CIGaussianBlur", parameters: [kCIInputRadiusKey: 0.65])
            .cropped(to: extent)
            .applyingFilter("CIColorMatrix", parameters: [
                "inputRVector": CIVector(x: p.edgeBoost, y: 0, z: 0, w: 0),
                "inputGVector": CIVector(x: 0, y: p.edgeBoost, z: 0, w: 0),
                "inputBVector": CIVector(x: 0, y: 0, z: p.edgeBoost, w: 0),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1.0)
            ])
            .cropped(to: extent)

        let radius = min(extent.width, extent.height) * p.centerRadius
        let centerBias = (
            CIFilter(
                name: "CIRadialGradient",
                parameters: [
                    "inputCenter": CIVector(x: extent.midX, y: extent.midY * 1.01),
                    "inputRadius0": radius * 0.12,
                    "inputRadius1": radius,
                    "inputColor0": CIColor(red: p.centerPush, green: p.centerPush, blue: p.centerPush, alpha: 1),
                    "inputColor1": CIColor(red: 0, green: 0, blue: 0, alpha: 1)
                ]
            )?.outputImage?.cropped(to: extent)
        ) ?? CIImage(color: .black).cropped(to: extent)

        depth = depth
            .applyingFilter("CIAdditionCompositing", parameters: [
                kCIInputBackgroundImageKey: edges
            ])
            .cropped(to: extent)
            .applyingFilter("CIAdditionCompositing", parameters: [
                kCIInputBackgroundImageKey: centerBias
            ])
            .cropped(to: extent)

        depth = depth
            .applyingFilter("CIColorMatrix", parameters: [
                "inputRVector": CIVector(x: p.expansion, y: 0, z: 0, w: p.bias),
                "inputGVector": CIVector(x: 0, y: p.expansion, z: 0, w: p.bias),
                "inputBVector": CIVector(x: 0, y: 0, z: p.expansion, w: p.bias),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1.0)
            ])
            .cropped(to: extent)
            .applyingFilter("CIUnsharpMask", parameters: [
                kCIInputRadiusKey: p.unsharpRadius,
                kCIInputIntensityKey: p.unsharpIntensity
            ])
            .cropped(to: extent)
            .applyingFilter("CIGaussianBlur", parameters: [
                kCIInputRadiusKey: p.blurRadius
            ])
            .cropped(to: extent)
            .applyingFilter("CIColorClamp", parameters: [
                "inputMinComponents": CIVector(x: 0, y: 0, z: 0, w: 0),
                "inputMaxComponents": CIVector(x: 1, y: 1, z: 1, w: 1)
            ])
            .cropped(to: extent)

        return depth
    }
}
