import Foundation
import AVFoundation
import CoreImage
import CoreVideo
import UIKit

final class HKV1_DepthGenerator {

    enum GeneratorError: Error {
        case missingVideoTrack
        case cannotCreateReader
        case cannotCreateWriter
        case cannotCreateReaderOutput
        case cannotCreateWriterInput
        case cannotStartReader
        case cannotStartWriter
        case cancelled
    }

    private let workQueue = DispatchQueue(label: "com.higherkey.depthgenerator", qos: .userInitiated)
    private let callbackQueue = DispatchQueue.main

    private let ciContext = CIContext(options: [
        .cacheIntermediates: false,
        .useSoftwareRenderer: false
    ])

    private var cancelToken = UUID()

    private enum Tuning {
        static let importFolder = "HKV1ImportedVideos"
        static let generatedFolder = "HKV1GeneratedDepth"
        static let renderSuffix = ".depth.mov"
        static let minUsableBytes: UInt64 = 12 * 1024
        static let maxWorkingWidthSmall: CGFloat = 384
        static let maxWorkingWidthMedium: CGFloat = 512
        static let maxWorkingWidthLarge: CGFloat = 640
    }

    static func generatedDepthDirectoryURL() -> URL {
        let fm = FileManager.default
        let base = fm.urls(for: .cachesDirectory, in: .userDomainMask).first ?? fm.temporaryDirectory
        return base.appendingPathComponent(Tuning.generatedFolder, isDirectory: true)
    }

    static func cachedDepthURL(for videoURL: URL) -> URL {
        let base = videoURL.deletingPathExtension().lastPathComponent
        return generatedDepthDirectoryURL().appendingPathComponent(base + Tuning.renderSuffix)
    }

    static func hasUsableDepthCache(for videoURL: URL) -> Bool {
        let url = cachedDepthURL(for: videoURL)
        guard FileManager.default.fileExists(atPath: url.path) else { return false }
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
              let size = attrs[.size] as? NSNumber else {
            return false
        }
        return size.uint64Value >= Tuning.minUsableBytes
    }

    func generateDepthSidecarIfNeeded(
        for videoURL: URL,
        progress: @escaping (Double) -> Void,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let outputURL = pairedDepthURL(for: videoURL)
        let token = UUID()
        cancelToken = token

        if Self.hasUsableDepthCache(for: videoURL) {
            callbackQueue.async {
                progress(1.0)
                completion(.success(outputURL))
            }
            return
        }

        workQueue.async {
            do {
                try self.generateDepthSidecar(
                    for: videoURL,
                    outputURL: outputURL,
                    token: token,
                    progress: progress
                )
                self.callbackQueue.async {
                    progress(1.0)
                    completion(.success(outputURL))
                }
            } catch {
                try? FileManager.default.removeItem(at: outputURL)
                self.callbackQueue.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func cancelGeneration() {
        cancelToken = UUID()
    }

    func cleanupGeneratedCache(keepingVideoURL currentVideoURL: URL? = nil) {
        let fm = FileManager.default
        let dir = generatedDepthDirectory()
        guard let urls = try? fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) else { return }

        let keepBase = currentVideoURL?.deletingPathExtension().lastPathComponent
        for url in urls {
            if let keepBase, url.lastPathComponent.contains(keepBase) {
                continue
            }
            try? fm.removeItem(at: url)
        }
    }

    private func generateDepthSidecar(
        for videoURL: URL,
        outputURL: URL,
        token: UUID,
        progress: @escaping (Double) -> Void
    ) throws {
        let fm = FileManager.default
        try? fm.removeItem(at: outputURL)
        try fm.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)

        let asset = AVAsset(url: videoURL)
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            throw GeneratorError.missingVideoTrack
        }

        let reader = try AVAssetReader(asset: asset)
        let readerOutputSettings: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA),
            kCVPixelBufferMetalCompatibilityKey as String: true
        ]
        let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: readerOutputSettings)
        readerOutput.alwaysCopiesSampleData = false
        guard reader.canAdd(readerOutput) else { throw GeneratorError.cannotCreateReaderOutput }
        reader.add(readerOutput)

        let writer = try AVAssetWriter(outputURL: outputURL, fileType: .mov)

        let naturalSize = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
        let sourceWidth = abs(naturalSize.width)
        let sourceHeight = abs(naturalSize.height)
        let workingWidth = self.workingWidth(for: max(sourceWidth, sourceHeight))
        let scale = max(0.1, min(1.0, workingWidth / max(sourceWidth, sourceHeight, 1)))
        let outputSize = CGSize(
            width: max(2, floor(sourceWidth * scale / 2.0) * 2.0),
            height: max(2, floor(sourceHeight * scale / 2.0) * 2.0)
        )

        let compression: [String: Any] = [
            AVVideoAverageBitRateKey: Int(outputSize.width * outputSize.height * 2.6),
            AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
            AVVideoMaxKeyFrameIntervalKey: 24,
            AVVideoExpectedSourceFrameRateKey: 24,
            AVVideoAllowFrameReorderingKey: false
        ]

        let writerInputSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: Int(outputSize.width),
            AVVideoHeightKey: Int(outputSize.height),
            AVVideoCompressionPropertiesKey: compression
        ]

        let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: writerInputSettings)
        writerInput.expectsMediaDataInRealTime = false
        writerInput.transform = videoTrack.preferredTransform
        guard writer.canAdd(writerInput) else { throw GeneratorError.cannotCreateWriterInput }
        writer.add(writerInput)

        let adaptorAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA),
            kCVPixelBufferWidthKey as String: Int(outputSize.width),
            kCVPixelBufferHeightKey as String: Int(outputSize.height),
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
            kCVPixelBufferMetalCompatibilityKey as String: true
        ]

        let adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: writerInput,
            sourcePixelBufferAttributes: adaptorAttributes
        )

        guard reader.startReading() else { throw GeneratorError.cannotStartReader }
        guard writer.startWriting() else { throw GeneratorError.cannotStartWriter }
        writer.startSession(atSourceTime: .zero)

        let durationSeconds = max(0.001, asset.duration.seconds.isFinite ? asset.duration.seconds : 0.001)
        let nominalFPS = max(1.0, min(60.0, videoTrack.nominalFrameRate > 0 ? Double(videoTrack.nominalFrameRate) : 24.0))
        let sampleStride = self.sampleStride(for: outputSize.width, fps: nominalFPS)

        var frameIndex = 0
        var lastRenderedCIImage: CIImage?
        var didAppendAnyFrame = false

        while reader.status == .reading {
            if token != self.cancelToken { throw GeneratorError.cancelled }
            guard let sampleBuffer = readerOutput.copyNextSampleBuffer() else { break }
            autoreleasepool {
                let pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

                let sourceImage = CIImage(cvPixelBuffer: imageBuffer)
                let shouldRecompute = (frameIndex % sampleStride == 0) || lastRenderedCIImage == nil

                if shouldRecompute {
                    lastRenderedCIImage = self.makeProxyDepthImage(from: sourceImage, targetSize: outputSize)
                }

                guard let renderImage = lastRenderedCIImage else {
                    frameIndex += 1
                    return
                }

                while !writerInput.isReadyForMoreMediaData {
                    if token != self.cancelToken { return }
                    Thread.sleep(forTimeInterval: 0.0015)
                }

                if let pixelBufferPool = adaptor.pixelBufferPool,
                   let pixelBuffer = self.makePixelBuffer(from: renderImage, pool: pixelBufferPool, size: outputSize) {
                    adaptor.append(pixelBuffer, withPresentationTime: pts)
                    didAppendAnyFrame = true
                }

                let seconds = pts.seconds.isFinite ? pts.seconds : 0
                let normalized = min(0.999, max(0.0, seconds / durationSeconds))
                self.callbackQueue.async {
                    progress(normalized)
                }
                frameIndex += 1
            }
        }

        writerInput.markAsFinished()

        if token != self.cancelToken { throw GeneratorError.cancelled }
        if !didAppendAnyFrame { throw GeneratorError.cannotStartWriter }

        let group = DispatchGroup()
        group.enter()
        var finishError: Error?
        writer.finishWriting {
            if writer.status == .failed {
                finishError = writer.error
            }
            group.leave()
        }
        group.wait()

        if let finishError { throw finishError }
        if reader.status == .failed, let err = reader.error { throw err }
        if writer.status == .failed, let err = writer.error { throw err }
    }

    private func makeProxyDepthImage(from source: CIImage, targetSize: CGSize) -> CIImage {
        let extent = source.extent
        let scaleX = targetSize.width / max(extent.width, 1)
        let scaleY = targetSize.height / max(extent.height, 1)
        let outputRect = CGRect(origin: .zero, size: targetSize)

        let base = source
            .transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
            .applyingFilter("CIColorControls", parameters: [
                kCIInputSaturationKey: 0.0,
                kCIInputContrastKey: 1.34,
                kCIInputBrightnessKey: 0.0
            ])
            .applyingFilter("CIHighlightShadowAdjust", parameters: [
                "inputShadowAmount": 0.70,
                "inputHighlightAmount": 0.18
            ])
            .cropped(to: outputRect)

        let perspectiveRamp = (
            CIFilter(name: "CILinearGradient", parameters: [
                "inputPoint0": CIVector(x: targetSize.width * 0.5, y: targetSize.height * 0.96),
                "inputPoint1": CIVector(x: targetSize.width * 0.5, y: targetSize.height * 0.12),
                "inputColor0": CIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1),
                "inputColor1": CIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1)
            ])?.outputImage?.cropped(to: outputRect)
        ) ?? CIImage(color: .black).cropped(to: outputRect)

        let centerBias = (
            CIFilter(name: "CIRadialGradient", parameters: [
                "inputCenter": CIVector(x: targetSize.width * 0.5, y: targetSize.height * 0.54),
                "inputRadius0": min(targetSize.width, targetSize.height) * 0.10,
                "inputRadius1": min(targetSize.width, targetSize.height) * 0.64,
                "inputColor0": CIColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 1),
                "inputColor1": CIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1)
            ])?.outputImage?.cropped(to: outputRect)
        ) ?? CIImage(color: .black).cropped(to: outputRect)

        let edges = base
            .applyingFilter("CIEdges", parameters: [kCIInputIntensityKey: 1.55])
            .applyingFilter("CIGaussianBlur", parameters: [kCIInputRadiusKey: 1.0])
            .cropped(to: outputRect)
            .applyingFilter("CIColorMatrix", parameters: [
                "inputRVector": CIVector(x: 0.20, y: 0, z: 0, w: 0),
                "inputGVector": CIVector(x: 0, y: 0.20, z: 0, w: 0),
                "inputBVector": CIVector(x: 0, y: 0, z: 0.20, w: 0),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1.0)
            ])

        let expanded = base
            .applyingFilter("CIColorMatrix", parameters: [
                "inputRVector": CIVector(x: 1.78, y: 0, z: 0, w: -0.22),
                "inputGVector": CIVector(x: 0, y: 1.78, z: 0, w: -0.22),
                "inputBVector": CIVector(x: 0, y: 0, z: 1.78, w: -0.22),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1.0)
            ])
            .cropped(to: outputRect)

        let combined = expanded
            .applyingFilter("CIAdditionCompositing", parameters: [kCIInputBackgroundImageKey: edges])
            .cropped(to: outputRect)
            .applyingFilter("CIAdditionCompositing", parameters: [kCIInputBackgroundImageKey: centerBias])
            .cropped(to: outputRect)
            .applyingFilter("CIAdditionCompositing", parameters: [kCIInputBackgroundImageKey: perspectiveRamp])
            .cropped(to: outputRect)
            .applyingFilter("CIUnsharpMask", parameters: [
                kCIInputRadiusKey: 1.2,
                kCIInputIntensityKey: 0.42
            ])
            .cropped(to: outputRect)
            .applyingFilter("CIColorControls", parameters: [
                kCIInputSaturationKey: 0.0,
                kCIInputContrastKey: 1.72,
                kCIInputBrightnessKey: 0.01
            ])
            .applyingFilter("CIColorClamp", parameters: [
                "inputMinComponents": CIVector(x: 0, y: 0, z: 0, w: 0),
                "inputMaxComponents": CIVector(x: 1, y: 1, z: 1, w: 1)
            ])

        return combined.cropped(to: outputRect)
    }

    private func makePixelBuffer(from image: CIImage, pool: CVPixelBufferPool, size: CGSize) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferPoolCreatePixelBuffer(nil, pool, &pixelBuffer)
        guard status == kCVReturnSuccess, let pixelBuffer else { return nil }

        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        ciContext.render(
            image,
            to: pixelBuffer,
            bounds: CGRect(origin: .zero, size: size),
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )
        CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
        return pixelBuffer
    }

    private func sampleStride(for workingWidth: CGFloat, fps: Double) -> Int {
        if workingWidth >= 560 || fps >= 55 { return 3 }
        if workingWidth >= 430 || fps >= 30 { return 2 }
        return 1
    }

    private func workingWidth(for longestSide: CGFloat) -> CGFloat {
        if longestSide >= 2600 { return Tuning.maxWorkingWidthLarge }
        if longestSide >= 1500 { return Tuning.maxWorkingWidthMedium }
        return Tuning.maxWorkingWidthSmall
    }

    func pairedDepthURL(for videoURL: URL) -> URL {
        Self.cachedDepthURL(for: videoURL)
    }

    func generatedDepthDirectory() -> URL {
        Self.generatedDepthDirectoryURL()
    }
}
