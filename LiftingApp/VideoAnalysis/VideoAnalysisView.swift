import AVKit
import PhotosUI
import SwiftUI
import AVFoundation
import Vision

struct Movie: Transferable {
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { received in
            
            let copy = URL.documentsDirectory.appending(path: "movie.mp4")
            
            if FileManager.default.fileExists(atPath: copy.path()) {
                try FileManager.default.removeItem(at: copy)
                print("removing already evaluated video")
            }
            print(received.file.absoluteString)
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
//                VideoResultsView(url: movie.url)
                VideoProcessingView(videoURL: movie.url)
                    
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
    let outputURL = URL(fileURLWithPath: NSTemporaryDirectory() + "output.mp4")
    @State var loadVideo: Bool = true
    
    init(url: URL) {
        self.url = url
    }
    
    var body: some View {
        VStack {
            Text("results")
            if analyzingState == AnalyzingState.COMPLETED {
                let player = AVPlayer(url: outputURL)
                Text(url.absoluteString )
                VideoPlayer(player: player)
                    .scaledToFit()
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
                print(url.absoluteString)
                extractFrames(url: url) { completed in
                    if completed {
                        analyzingState = AnalyzingState.COMPLETED
                        loadingState = LoadingState.FINISHED
                    } else {
                        loadingState = LoadingState.ERROR
                        print("error extracting frames")
                    }
                }
            } else {
                print("video already loaded ")
            }
        }
    }
    
    enum LoadingState {
        case LOADING, ERROR, FINISHED
    }
    
    enum AnalyzingState {
        case NOT_ANALYZING, ANALYZING, COMPLETED
    }
    
    func extractFrames(url: URL, completion: @escaping (Bool) -> Void) {
        let asset = AVURLAsset(url: url)
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
                print("Failed to get video track")
                completion(false)
                return
        }
            
            // Get the total number of frames
        let duration = CMTimeGetSeconds(asset.duration)
        let fps = videoTrack.nominalFrameRate
        let totalFrames = Int(duration * Double(fps))
        do {
            //let writer = VideoCreator(url: outputURL)
            let analyzer = VideoAnalyzer(outputURL: outputURL)
            let reader = try AVAssetReader(asset: asset)
//            let videoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
            
            // Define output settings to get raw frames
            let outputSettings: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
            
            let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: outputSettings)
            readerOutput.alwaysCopiesSampleData = false
            reader.add(readerOutput)
            reader.startReading()
            
            var frameCount = 0
            var processedFramesCount = 0
            
            let context = CIContext() // Create CIContext outside the loop
            
            while let sampleBuffer = readerOutput.copyNextSampleBuffer() {
                autoreleasepool { // Use autoreleasepool for efficient memory management
                    if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                        // Create a CIImage from the image buffer
                        let ciImage = CIImage(cvImageBuffer: imageBuffer).oriented(.right)
                        // Convert CIImage to UIImage
                        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                            print("reading frame \(frameCount)")
                            if (frameCount < totalFrames) {
                                analyzer.analyze(frame: cgImage, frameNum: frameCount) { completed in
                                    
                                } numWritten: { framesWritten in
                                    for _ in 1...framesWritten {
                                        processedFramesCount += 1
                                        print("Finished processing \(processedFramesCount) out of \(totalFrames) frames")
                                        if processedFramesCount == totalFrames {
                                            analyzer.closeWriter()
                                            completion(true)
                                        }
                                    }
                                }
                            }
                            frameCount += 1
                            
                            // You can limit the number of frames processed here
                            // For example, if you only want the first 5 frames:
                        } else {
                            print("sample buffer not image buffer")
                        }
                    } else {
                        print("error getting image buffer")
                    }
                    CMSampleBufferInvalidate(sampleBuffer) // Release the sample buffer
                }
            }
            
            // Close writer after processing all frames
//            print("about to close")
            
        } catch {
            print("Error: \(error)")
            completion(false)
        }

    }
    
    
}



#Preview {
    VideoAnalysisView()
}
