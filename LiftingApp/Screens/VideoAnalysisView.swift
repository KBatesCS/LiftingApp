import AVKit
import PhotosUI
import SwiftUI
import AVFoundation

struct Movie: Transferable {
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { received in
            let copy = URL.documentsDirectory.appending(path: "movie.mp4")
            
            if FileManager.default.fileExists(atPath: copy.path()) {
                try FileManager.default.removeItem(at: copy)
            }
            
            try FileManager.default.copyItem(at: received.file, to: copy)
            return Self.init(url: copy)
        }
    }
}

struct VideoAnalysisView: View {
    enum LoadState {
        case unknown, loading, loaded(Movie), failed
    }
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var loadState = LoadState.unknown
    
    var body: some View {
        VStack {
            PhotosPicker("Select movie", selection: $selectedItem, matching: .videos)
            
            switch loadState {
            case .unknown:
                EmptyView()
            case .loading:
                ProgressView()
            case .loaded(let movie):
                VideoResultsView(url: movie.url)
                    
                //VideoPlayer(player: AVPlayer(url: movie.url))
                //   .scaledToFit()
                //  .frame(width: 300, height: 300)
            case .failed:
                Text("Import failed")
            }
        }
        .onChange(of: selectedItem) { _ in
            Task {
                do {
                    loadState = .loading
                    
                    if let movie = try await selectedItem?.loadTransferable(type: Movie.self) {
                        loadState = .loaded(movie)
                    } else {
                        loadState = .failed
                    }
                } catch {
                    loadState = .failed
                }
            }
        }
    }
}

struct VideoResultsView: View {
    @State var url: URL
    @State private var image: UIImage?
    @State private var loadingState: LoadingState = LoadingState.LOADING
    @State private var analyzingState: AnalyzingState = AnalyzingState.NOT_ANALYZING
    @State private var imageBuffer: [UIImage] = []
    let outputURL = URL(fileURLWithPath: NSTemporaryDirectory() + "output.mp4")
    @State var loadVideo: Bool = true
    
    init(url: URL) {
        self.url = url
    }
    
    var body: some View {
        VStack {
            Text("results")
            if analyzingState == AnalyzingState.COMPLETED {
                VideoPlayer(player: AVPlayer(url: outputURL))
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            } else if loadingState == LoadingState.LOADING {
                Text("Loading Video...")
            } else if loadingState == LoadingState.ERROR {
                Text("Error...")
            } else if analyzingState == AnalyzingState.ANALYZING {
                Text("Analyzing Video...")
            }
            else {
                Text("HI :), you shouldn't see me")
            }
            
        }
        .onAppear {
            if loadVideo {
                loadVideo = false
                extractFrames(url: url) { completed in
                    if completed {
                        analyzingState = AnalyzingState.COMPLETED
                        loadingState = LoadingState.FINISHED
                    } else {
                        loadingState = LoadingState.ERROR
                    }
                }
            }
        }
        /*
        .onChange(of: loadingState) { _ in
            if loadingState == LoadingState.FINISHED && imageBuffer.count > 10 {
                analyzingState = AnalyzingState.ANALYZING
                VideoCreator().createVideo(from: imageBuffer, outputURL: outputURL) { success in
                    if success {
                        analyzingState = AnalyzingState.COMPLETED
                    }
                    else {
                        loadingState = LoadingState.ERROR
                    }
                }
            }
        }
         */
        
    }
    
    enum LoadingState {
        case LOADING, ERROR, FINISHED
    }
    
    enum AnalyzingState {
        case NOT_ANALYZING, ANALYZING, COMPLETED
    }
    
    func extractFrames(url: URL, completion: @escaping (Bool) -> Void) {
        let asset = AVURLAsset(url: url)
        
        do {
            let writer = VideoCreator(url: outputURL)
            let reader = try AVAssetReader(asset: asset)
            let videoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
            
            // Define output settings to get raw frames
            let outputSettings: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
            
            let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: outputSettings)
            readerOutput.alwaysCopiesSampleData = false
            reader.add(readerOutput)
            reader.startReading()
            
            var frameCount = 0
            
            let context = CIContext() // Create CIContext outside the loop
            
            while let sampleBuffer = readerOutput.copyNextSampleBuffer() {
                autoreleasepool { // Use autoreleasepool for efficient memory management
                    if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                        // Create a CIImage from the image buffer
                        let ciImage = CIImage(cvImageBuffer: imageBuffer)
                        
                        // Convert CIImage to UIImage
                        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                            let uiImage = UIImage(cgImage: cgImage)
                            let grayScaledImage = OpenCVWrapper.grayscaleImg(uiImage)
                            
                            // Write frame to video
                            writer.write(image: grayScaledImage) { success in
                                if !success {
                                    completion(false)
                                    writer.close()
                                    return
                                }
                            }
                                
                            print("reading frame \(frameCount)")
                            frameCount += 1
                            
                            // You can limit the number of frames processed here
                            // For example, if you only want the first 5 frames:
                        }
                    }
                    CMSampleBufferInvalidate(sampleBuffer) // Release the sample buffer
                }
            }
            
            // Close writer after processing all frames
            writer.close()
            completion(true)
        } catch {
            print("Error: \(error)")
            completion(false)
        }

    }
    
}

import AVFoundation
import UIKit

class VideoCreator {
    
    let outputURL: URL
    var initialized: Bool = false
    var videoWriter: AVAssetWriter? = nil
    var videoWriterInput: AVAssetWriterInput? = nil
    var mediaQueue: DispatchQueue? = nil
    var totalFrames: Int = 0
    var presentationTime = CMTime.zero
    let frameDuration = CMTimeMake(value: 1, timescale: 30)
    var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor? = nil
    
    init(url: URL) {
        outputURL = url
        do {
            if FileManager.default.fileExists(atPath: outputURL.path) {
                try FileManager.default.removeItem(at: outputURL)
            }
        } catch {
            print("Error removing file: \(error)")
        }
    }
    
    func initializeVideoWriter(height: CGFloat, width: CGFloat) -> Bool {
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
                return false
            }
            
            videoWriter!.startWriting()
            videoWriter!.startSession(atSourceTime: .zero)
            
            mediaQueue = DispatchQueue(label: "mediaInputQueue")
            presentationTime = CMTime.zero
            initialized = true
            return true
        } catch {
            print("Error initializing video writer: \(error)")
            return false
        }
    }
    
    func write(image: UIImage, completed: @escaping (Bool) -> Void) {
        if initialized || initializeVideoWriter(height: image.size.height, width: image.size.width) {
            if let videoWriter = videoWriter, let videoWriterInput = videoWriterInput, let mediaQueue = mediaQueue, let pixelBufferAdaptor = pixelBufferAdaptor {
                // Check if the input is ready for more media data
                if videoWriterInput.isReadyForMoreMediaData {
                    // Create pixel buffer from image
                    if let buffer = self.pixelBufferFromImage(image) {
                        // Append pixel buffer to video
                        if !self.appendPixelBuffer(buffer, withPresentationTime: self.presentationTime, to: pixelBufferAdaptor) {
                            completed(false)
                            return
                        }
                        
                        // Update presentation time
                        self.presentationTime = CMTimeAdd(self.presentationTime, self.frameDuration)
                        self.totalFrames += 1
                        completed(true)
                    }
                }
            }
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
        }
    }
    
    private func pixelBufferFromImage(_ image: UIImage) -> CVPixelBuffer? {
        guard let cgImage = image.cgImage else {
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

#Preview {
    VideoAnalysisView()
}
