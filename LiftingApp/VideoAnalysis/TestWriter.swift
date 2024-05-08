import UIKit
import AVFoundation

class VideoWriter {
    private var videoWriter: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    private var outputURL: URL
    private var frameRate: Int32 = 30
    
    
    init(outputURL: URL) {
        self.outputURL = outputURL
    }
    
    func setupWriter(width: Int, height: Int, frameRate: Int32) throws {
        self.frameRate = frameRate
        
        do {
            if FileManager.default.fileExists(atPath: outputURL.path) {
                print("found existing output path")
                try FileManager.default.removeItem(at: outputURL)
                print("removed file")
            }
        } catch {
            print("Error removing file: \(error)")
        }
        
        let videoSettings: [String : Any] = [
            AVVideoCodecKey : AVVideoCodecType.h264,
            AVVideoWidthKey : width,
            AVVideoHeightKey : height
        ]
        
        videoWriter = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
        guard let videoWriter = videoWriter else {
            throw VideoWriterError.setupFailed
        }
        
        videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        guard let videoInput = videoInput else {
            throw VideoWriterError.setupFailed
        }
        
        let pixelBufferAttrs: [String : Any] = [
            kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32ARGB,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height
        ]
        
        pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoInput,
                                                                  sourcePixelBufferAttributes: pixelBufferAttrs)
        
        if videoWriter.canAdd(videoInput) {
            videoWriter.add(videoInput)
        } else {
            throw VideoWriterError.setupFailed
        }
        
        videoWriter.startWriting()
        videoWriter.startSession(atSourceTime: .zero)
    }
    
    func write(image: UIImage, frameNum: Int) -> Bool {
        guard let videoWriter = videoWriter, videoWriter.status == .writing else {
            print("video already writing")
            return false
        }
        
        let presentationTime = CMTimeMake(value: Int64(frameNum), timescale: frameRate)
        
        if let pixelBuffer = self.pixelBuffer(from: image) {
            if pixelBufferAdaptor?.assetWriterInput.isReadyForMoreMediaData ?? false {
                pixelBufferAdaptor?.append(pixelBuffer, withPresentationTime: presentationTime)
                return true
            } else {
                print("buffer not ready for more media")
                return false
            }
        } else {
            print("buffer DNE???")
            return false
        }
    }
    
    private func pixelBuffer(from image: UIImage) -> CVPixelBuffer? {
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          width,
                                          height,
                                          kCVPixelFormatType_32ARGB,
                                          attrs,
                                          &pixelBuffer)
        
        guard let buffer = pixelBuffer, status == kCVReturnSuccess else { return nil }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        
        if let context = CGContext(data: CVPixelBufferGetBaseAddress(buffer),
                                   width: width,
                                   height: height,
                                   bitsPerComponent: 8,
                                   bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                   space: CGColorSpaceCreateDeviceRGB(),
                                   bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) {
            context.translateBy(x: 0, y: CGFloat(height))
            context.scaleBy(x: 1.0, y: -1.0)
            
            UIGraphicsPushContext(context)
            image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            UIGraphicsPopContext()
        }
        
        return buffer
    }
    
    func finishWriting() async -> Bool {
        await videoWriter?.finishWriting()
        if let error = videoWriter?.error {
            print("Error: \(error)")
            return false
        } else {
            return true
        }
    }
}

enum VideoWriterError: Error {
    case setupFailed
}
