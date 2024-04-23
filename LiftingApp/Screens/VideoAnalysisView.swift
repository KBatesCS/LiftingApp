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
    
    init(url: URL) {
        self.url = url
    }
    
    var body: some View {
        VStack {
            Text("results")
            if analyzingState == AnalyzingState.COMPLETED {
                
                VideoPlayer(player: AVPlayer(url: outputURL))
                    .scaledToFit()
                
                /*
                 ScrollView {
                 ForEach(imageBuffer, id: \.self) { frame in
                 Image(uiImage: frame)
                 .resizable()
                 .aspectRatio(contentMode: .fit)
                 }
                 }*/
                //                    Image(uiImage: image)
                //                                       .resizable()
                //                                        .aspectRatio(contentMode: .fit)
                //                                        .frame(width: 300, height: 200)
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
            if imageBuffer.count == 0 {
                /*
                 extractFrames { completed in
                 if completed {
                 loadingState = LoadingState.FINISHED
                 
                 } else {
                 loadingState = LoadingState.ERROR
                 }
                 }
                 */
                
                extractFrames(url: url) { completed in
                    if completed {
                        loadingState = LoadingState.FINISHED
                    } else {
                        loadingState = LoadingState.ERROR
                    }
                }
            }
        }
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
            
//            var frames: [UIImage] = []
            
            while let sampleBuffer = readerOutput.copyNextSampleBuffer() {
                if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                    // Create a CIImage from the image buffer
                    let ciImage = CIImage(cvImageBuffer: imageBuffer)
                    
                    // Convert CIImage to UIImage
                    let context = CIContext()
                    if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                        let uiImage = UIImage(cgImage: cgImage)
                        let grayScaledImage = OpenCVWrapper.grayscaleImg(uiImage)
                        self.imageBuffer.append(grayScaledImage)
                    }
                }
            }
            
            completion(true)
        } catch {
            print("Error: \(error)")
            completion(false)
        }
    }
    
    
    public func imageFromVideo(url: URL, at time: TimeInterval, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let asset = AVURLAsset(url: url)
            
            let assetIG = AVAssetImageGenerator(asset: asset)
            assetIG.appliesPreferredTrackTransform = true
            assetIG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels
            
            let cmTime = CMTime(seconds: time, preferredTimescale: 60)
            let thumbnailImageRef: CGImage
            do {
                thumbnailImageRef = try assetIG.copyCGImage(at: cmTime, actualTime: nil)
            } catch let error {
                print("Error: \(error)")
                return completion(nil)
            }
            
            DispatchQueue.main.async {
                completion(UIImage(cgImage: thumbnailImageRef))
            }
        }
    }
    
    func extractFrames(completion: @escaping (Bool) -> Void) {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        // Get the duration of the video
        let durationSeconds = CMTimeGetSeconds(asset.duration)
        
        
        // Get the number of frames
        let totalFrames = Int(asset.tracks(withMediaType: .video)
            .map { Float64($0.nominalFrameRate) * durationSeconds }
            .reduce(0, +))
        
        let frameRate: Int32 = Int32(Double(totalFrames) / durationSeconds)
        
        print("Framerate: \(frameRate)")
        //        let frameRate = 24
        
        var times: [NSValue] = []
        var processedFrames = 0
        
        // Prepare array of times for each frame
        let frameDuration = CMTime(value: 1, timescale: frameRate)
        for i in 0..<totalFrames {
            let time = CMTimeMultiply(frameDuration, multiplier: Int32(i))
            times.append(NSValue(time: time))
        }
        
        
        generator.generateCGImagesAsynchronously(forTimes: times) { requestedTime, image, actualTime, result, error in
            if let image = image {
                print("Requested: \(requestedTime.seconds), Received: \(actualTime.seconds), error \(error?.localizedDescription ?? "none")")
                DispatchQueue.main.async {
                    let uiimage = UIImage(cgImage: image)
                    let convertedImage = OpenCVWrapper.grayscaleImg(uiimage)
                    self.imageBuffer.append(convertedImage)
                    self.image = convertedImage
                    processedFrames += 1
                    if processedFrames == totalFrames {
                        completion(true)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
}

class VideoCreator {
    
    func createVideo(from images: [UIImage], outputURL: URL, completion: @escaping (Bool) -> Void) {
        guard !images.isEmpty else {
            completion(false)
            return
        }
        
        // Delete existing file if it exists
        do {
            if FileManager.default.fileExists(atPath: outputURL.path) {
                try FileManager.default.removeItem(at: outputURL)
            }
        } catch {
            completion(false)
            return
        }
        
        do {
            let videoWriter = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
            
            let videoSettings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: images[0].size.width,
                AVVideoHeightKey: images[0].size.height
            ]
            
            let videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
            
            let sourcePixelBufferAttributes: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
                kCVPixelBufferWidthKey as String: images[0].size.width,
                kCVPixelBufferHeightKey as String: images[0].size.height
            ]
            
            let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: sourcePixelBufferAttributes)
            
            if videoWriter.canAdd(videoWriterInput) {
                videoWriter.add(videoWriterInput)
            } else {
                completion(false)
                return
            }
            
            videoWriter.startWriting()
            videoWriter.startSession(atSourceTime: .zero)
            
            let mediaQueue = DispatchQueue(label: "mediaInputQueue")
            let frameDuration = CMTimeMake(value: 1, timescale: 30) // Assuming 30 frames per second
            var presentationTime = CMTime.zero
            
            videoWriterInput.requestMediaDataWhenReady(on: mediaQueue) {
                var frameCount = 0
                
                while frameCount < images.count {
                    if videoWriterInput.isReadyForMoreMediaData {
                        if let buffer = self.pixelBufferFromImage(images[frameCount]) {
                            if !self.appendPixelBuffer(buffer, withPresentationTime: presentationTime, to: pixelBufferAdaptor) {
                                completion(false)
                                return
                            }
                            
                            presentationTime = CMTimeAdd(presentationTime, frameDuration)
                            frameCount += 1
                        }
                    }
                }
                
                videoWriterInput.markAsFinished()
                
                videoWriter.finishWriting {
                    completion(true)
                }
            }
        } catch {
            completion(false)
        }
    }
    
    private func pixelBufferFromImage(_ image: UIImage) -> CVPixelBuffer? {
        let size = image.size
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
             kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(size.width),
                                         Int(size.height),
                                         kCVPixelFormatType_32ARGB,
                                         attrs,
                                         &pixelBuffer)
        
        guard let buffer = pixelBuffer, status == kCVReturnSuccess else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pixelData,
                                      width: Int(size.width),
                                      height: Int(size.height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                      space: rgbColorSpace,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
            return nil
        }
        
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
    }
    
    private func appendPixelBuffer(_ pixelBuffer: CVPixelBuffer, withPresentationTime presentationTime: CMTime, to pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor) -> Bool {
        while !pixelBufferAdaptor.assetWriterInput.isReadyForMoreMediaData {
            usleep(10)
        }
        
        return pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
    }
}


#Preview {
    VideoAnalysisView()
}
