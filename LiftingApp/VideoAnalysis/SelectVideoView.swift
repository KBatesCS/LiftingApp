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
        case unknown, loading, loaded, failed
    }
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var loadState = LoadState.unknown
    @State private var showingSheet = false
    @State private var selectedURL: URL? = nil
    
    var body: some View {
        VStack {
            PhotosPicker("Select movie", selection: $selectedItem, matching: .videos)
            
            switch loadState {
            case .unknown:
                EmptyView()
            case .loading:
                ProgressView()
            case .loaded:
                EmptyView()
//                VideoResultsView(url: movie.url)
//                VideoProcessingView(videoURL: movie.url)
//                showingSheet = true
                    
                //VideoPlayer(player: AVPlayer(url: movie.url))
                //   .scaledToFit()
                //  .frame(width: 300, height: 300)
            case .failed:
                Text("Import failed")
            }
        }
        .sheet(isPresented: $showingSheet) {
            if let url = selectedURL {
                VideoProcessingView(videoURL: url)
            }
        }
        .onChange(of: selectedItem) { _ in
            if selectedItem == nil {
                return
            }
            Task {
                do {
                    loadState = .loading
                    
                    if let movie = try await selectedItem?.loadTransferable(type: Movie.self) {
                        loadState = .loaded
                        selectedURL = movie.url
                        selectedItem = nil
                        showingSheet = true
                    } else {
                        loadState = .failed
                    }
                } catch {
                    print(error)
                    loadState = .failed
                }
            }
        }
    }
}


#Preview {
    VideoAnalysisView()
}
