import SwiftUI
import AVKit

struct VideoProcessingView: View {
    let videoURL: URL
    let outputURL: URL
    let videoWriter: VideoWriter
    
    init(videoURL: URL) {
        self.videoURL = videoURL
        self.outputURL = URL(fileURLWithPath: NSTemporaryDirectory() + "output.mp4")
        self.videoWriter = VideoWriter(outputURL: outputURL)
    }
    
    var body: some View {
        VideoPlayer(player: AVPlayer(url: videoURL))
            .onAppear {
                Task {
                    await processVideo()
                }
            }
    }
    
    func processVideo() async {
        do {
            let asset = AVURLAsset(url: videoURL)
            let duration = try await asset.load(.duration).seconds
            guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first else {
                    throw VideoWriterError.noVideoTrack
            }
                
                // Calculate the frame rate
            let frameRate = try await videoTrack.load(.nominalFrameRate)
                
                // Calculate total frames
            let totalFrames = Int(duration * Double(frameRate))
            
            
            try await videoWriter.setupWriter(width: Int(videoTrack.load(.naturalSize).width),
                                               height: Int(videoTrack.load(.naturalSize).height),
                                               frameRate: Int32(frameRate)) // Set FPS
            
            for frameNum in 0..<totalFrames {
                let image = try await frameImage(at: frameNum, fps: Int32(frameRate))
                
                // Run your function on the image here
                
                let success = videoWriter.write(image: image, frameNum: frameNum)
                if !success {
                    print("Failed to write frame \(frameNum)")
                }
                if frameNum == 20 {
                    print("we pause in this bitch")
                }
            }
            
            let finishSuccess = await videoWriter.finishWriting()
            if finishSuccess {
                print("Video processing completed successfully.")
            } else {
                print("Video processing failed.")
            }
        } catch {
            print("Error processing video: \(error)")
        }
    }
    
    func frameImage(at frameNum: Int, fps: Int32) async throws -> UIImage {
        let asset = AVURLAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        
        let time = CMTimeMake(value: Int64(frameNum), timescale: fps) // Assuming 30 fps
        
        let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
        return UIImage(cgImage: cgImage)
    }
    
    enum VideoWriterError: Error {
        case setupFailed
        case noVideoTrack
    }
}
