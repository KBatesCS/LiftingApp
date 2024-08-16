import SwiftUI
import AVKit
import ImageIO
import CoreImage
import CoreGraphics

struct VideoProcessingView: View {
    let videoURL: URL
    let outputURL: URL
    let videoWriter: VideoWriter
    
    @State private var alreadyLoaded = false
    @State private var isVideoProcessed = false
    @State private var progress: Double = 0
    
    init(videoURL: URL) {
        self.videoURL = videoURL
        self.outputURL = URL(fileURLWithPath: NSTemporaryDirectory() + "output.mp4")
        self.videoWriter = VideoWriter(outputURL: outputURL)
    }
    
    var body: some View {
        if isVideoProcessed {
            VideoPlayer(player: AVPlayer(url: outputURL))
                .scaledToFit()
        } else {
            ProgressView(value: progress) {
                Text("Analyzing Video...")
            }
            .padding(20)
            .onAppear {
                if !alreadyLoaded {
                    alreadyLoaded = true
                    Task {
                        await extractFrames(url: videoURL)
                        isVideoProcessed = true
                    }
                }
            }
        }
    }
    
    
    func extractFrames(url: URL) async {
        let asset = AVURLAsset(url: url)
        
        print("Orientation: \(getVideoOrientation(from: asset).rawValue)")
        do {
            guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first else {
                throw VideoWriterError.noVideoTrack
            }
            
            
            
            
            let duration = try await asset.load(.duration).seconds
            let fps = try await videoTrack.load(.nominalFrameRate)
            let totalFrames = Int(duration * Double(fps))
            let reader = try AVAssetReader(asset: asset)
            
            
            if (getVideoOrientation(from: asset).rawValue % 2 == 0) {
                try await videoWriter.setupWriter(width: Int(videoTrack.load(.naturalSize).width),
                                                  height: Int(videoTrack.load(.naturalSize).height),
                                                  frameRate: Int32(fps))
            } else {
                try await videoWriter.setupWriter(width: Int(videoTrack.load(.naturalSize).height),
                                                  height: Int(videoTrack.load(.naturalSize).width),
                                                  frameRate: Int32(fps))
            }
            
            
            // Define output settings to get raw frames
            let outputSettings: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
            
            let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: outputSettings)
            readerOutput.alwaysCopiesSampleData = false
            reader.add(readerOutput)
            
            reader.startReading()
            
            var frameNum = 0
            
            let context = CIContext() // Create CIContext outside the loop
            
            while let sampleBuffer = readerOutput.copyNextSampleBuffer() {
                autoreleasepool { // Use autoreleasepool for efficient memory management
                    if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                        // Create a CIImage from the image buffer
                        let ciImage = CIImage(cvImageBuffer: imageBuffer).transformed(by: videoTrack.preferredTransform.inverted())
                        
                        // Convert CIImage to UIImage
                        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                            
                            var image = UIImage(cgImage: cgImage)
                            
                            // variables for counting reps
                            var repCount = 0
                            var lastHighest = image.size.height
                            
                            if let bodyPoints = TestAnalyzer().analyze(frame: image.cgImage!) {
                                for frameBodyPoints in bodyPoints {
                                    //                                    print("Found \(frameBodyPoints.count) points on frame \(frameNum)")
                                    for (point, jointName) in frameBodyPoints {
                                        image = image.drawDot(at: CGPoint(x: point.x, y: image.size.height - point.y), color: .red, radius: 10) ?? image
                                    }
                                }
                            }
                            
                            
                            
                            let success = videoWriter.write(image: image, frameNum: frameNum)
                            if !success {
                                print("Failed to write frame \(frameNum)")
                            } else {
                                //                                print("wrote frame \(frameNum)")
                                frameNum += 1
                                progress = Double(frameNum) / Double(totalFrames)
                                if progress > 1.0 {
                                    progress = 1.0
                                }
                            }
                            
                        } else {
                            print("sample buffer not image buffer")
                        }
                    } else {
                        print("error getting image buffer")
                    }
                    CMSampleBufferInvalidate(sampleBuffer) // Release the sample buffer
                }
            }
            
            await _ = videoWriter.finishWriting()
            
        } catch {
            await _ = videoWriter.finishWriting()
            print("Error: \(error)")
        }
        
    }
    
    func getVideoOrientation(from asset: AVAsset) -> UIImage.Orientation {
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            return .up
        }
        
        let transform = videoTrack.preferredTransform
        
        if transform.a == 0 && transform.b == 1 && transform.c == -1 && transform.d == 0 {
            return .right // 90 degrees
        } else if transform.a == 0 && transform.b == -1 && transform.c == 1 && transform.d == 0 {
            return .left // -90 degrees
        } else if transform.a == 1 && transform.b == 0 && transform.c == 0 && transform.d == 1 {
            return .up // 0 degrees
        } else if transform.a == -1 && transform.b == 0 && transform.c == 0 && transform.d == -1 {
            return .down // 180 degrees
        } else {
            return .up // Default to up if orientation is unknown
        }
    }
    
    
    
    enum VideoWriterError: Error {
        case setupFailed
        case noVideoTrack
    }
}
