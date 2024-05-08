//
//  VideoWriter.swift
//  LiftingApp
//
//  Created by Kevin Bates on 5/6/24.
//

import Foundation
import AVFoundation
import UIKit

class VideoCreator {
    
    let outputURL: URL
    var initialized: Bool = false
    var videoWriter: AVAssetWriter? = nil
    var videoWriterInput: AVAssetWriterInput? = nil
    var mediaQueue: DispatchQueue? = nil
    //var totalFrames: Int = 0
    //var presentationTime = CMTime.zero
    let frameDuration = CMTimeMake(value: 1, timescale: 30)
    var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor? = nil
    
    var unwrittenImageQueue: [Frame] = []
    
    init(url: URL) {
        outputURL = url
        do {
            if FileManager.default.fileExists(atPath: outputURL.path) {
                print("found existing output path")
                try FileManager.default.removeItem(at: outputURL)
                print("removed file")
            }
        } catch {
            print("Error removing file: \(error)")
        }
    }
    
    func initializeVideoWriter(height: CGFloat, width: CGFloat) -> Bool {
        print("attempting to initialize")
        do {
            videoWriter = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
            
            let videoSettings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: width,
                AVVideoHeightKey: height
            ]
            
            videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
            
            let sourcePixelBufferAttributes: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
                kCVPixelBufferWidthKey as String: width,
                kCVPixelBufferHeightKey as String: height
            ]
            
            pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput!, sourcePixelBufferAttributes: sourcePixelBufferAttributes)
            
            if videoWriter!.canAdd(videoWriterInput!) {
                videoWriter!.add(videoWriterInput!)
            } else {
                print("could not add videowriter input")
                return false
            }
            
            videoWriter!.startWriting()
            videoWriter!.startSession(atSourceTime: .zero)
            
            mediaQueue = DispatchQueue(label: "mediaInputQueue")
            //presentationTime = CMTime.zero
            initialized = true
            return true
        } catch {
            print("Error initializing video writer: \(error)")
            return false
        }
    }
    
    
    
    func write(image: UIImage, frameNum: Int, completed: @escaping (Bool) -> Void, numWritten: @escaping (Int) -> Void) {
        print("writing frame \(frameNum)")
        unwrittenImageQueue.append(Frame(frameNum: frameNum, frameImg: image))
        var framesWritten = 0
        if initialized || initializeVideoWriter(height: image.size.height, width: image.size.width) {
            if let _ = videoWriter, let videoWriterInput = videoWriterInput, let _ = mediaQueue, let pixelBufferAdaptor = pixelBufferAdaptor {
                // Check if the input is ready for more media data
                if videoWriterInput.isReadyForMoreMediaData {
                    // Create pixel buffer from image
                    while !unwrittenImageQueue.isEmpty {
                        let unwrittenImage = unwrittenImageQueue.removeFirst()
                        if let buffer =
                            self.pixelBufferFromImage(unwrittenImage.frameImg) {
                            let curTime = CMTimeMultiply(self.frameDuration, multiplier: Int32(unwrittenImage.frameNum))
                            // Append pixel buffer to video
                            if !self.appendPixelBuffer(buffer, withPresentationTime: curTime, to: pixelBufferAdaptor) {
                                unwrittenImageQueue.insert(unwrittenImage, at: 0)
                                print("error appending image to pixel buffer from image buffer")
                                completed(false)
                                numWritten(framesWritten)
                                return
                            }
                            framesWritten += 1
                            
                            // Update presentation time
                            //self.presentationTime = CMTimeAdd(presentationTime, self.frameDuration)
                            //self.totalFrames += 1
                        }
                    }
                    completed(true)
                    numWritten(framesWritten)
                } else {
                    print("writer not ready for more input")
                    //unwrittenImageQueue.append(Frame(frameNum: frameNum, frameImg: image))
                }
            } else {
                print("variables not initialized")
            }
        } else {
            print("error, not initialized")
        }
    }

    
    func close() {
        if initialized, let videoWriter = videoWriter, let videoWriterInput = videoWriterInput, let mediaQueue = mediaQueue {
            videoWriterInput.requestMediaDataWhenReady(on: mediaQueue) {
                videoWriter.finishWriting {
                    print("Video writing finished")
                }
                videoWriterInput.markAsFinished()
            }
        } else {
            print("error closing writer")
        }
    }
    
    private func pixelBufferFromImage(_ image: UIImage) -> CVPixelBuffer? {
        guard let cgImage = image.cgImage else {
            print("error getting cgImage from pixel buffer")
            return nil
        }
        
        let options: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        
        var pixelBuffer: CVPixelBuffer? = nil
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(image.size.width),
                                         Int(image.size.height),
                                         kCVPixelFormatType_32ARGB,
                                         options as CFDictionary,
                                         &pixelBuffer)
        guard status == kCVReturnSuccess else {
            print("pixel buffer return status not succesfull")
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let context = CGContext(data: CVPixelBufferGetBaseAddress(pixelBuffer!),
                                width: Int(image.size.width),
                                height: Int(image.size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        guard let ctx = context else {
            print("pixel buffer context error")
            return nil
        }
        
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    private func appendPixelBuffer(_ pixelBuffer: CVPixelBuffer, withPresentationTime presentationTime: CMTime, to pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor) -> Bool {
        while !videoWriterInput!.isReadyForMoreMediaData {}
        
        return pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
    }
}
