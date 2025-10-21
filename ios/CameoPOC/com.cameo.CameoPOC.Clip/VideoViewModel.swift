import SwiftUI
import AVKit
import Combine

class VideoViewModel: ObservableObject {
    @Published var player: AVPlayer?
    @Published var isLoading = true
    @Published var error: Error?

    var onVideoComplete: (() -> Void)?

    private var cancellables = Set<AnyCancellable>()
    private var videoCompletionObserver: NSObjectProtocol?

    init() {
        // Don't auto-load - wait for ContentView to pass videoID
    }

    func loadVideo(videoID: String? = nil) {
        // Construct video URL from video ID
        let videoURLString: String

        if let videoID = videoID, !videoID.isEmpty {
            // Use video ID from URL to construct CDN path
            videoURLString = "https://cdn.cameo.com/video/\(videoID)-processed.mp4"
            print("🎬 Loading video ID: \(videoID)")
        } else {
            // Fallback to default video
            videoURLString = "https://cdn.cameo.com/video/6536b92a64a84efc4acbce6a-processed.mp4"
            print("🎬 Loading default video (no video ID provided)")
        }

        print("    Video URL: \(videoURLString)")

        guard let videoURL = URL(string: videoURLString) else {
            isLoading = false
            return
        }

        let playerItem = AVPlayerItem(url: videoURL)
        player = AVPlayer(playerItem: playerItem)

        // Observe player status
        playerItem.publisher(for: \.status)
            .sink { [weak self] status in
                DispatchQueue.main.async {
                    switch status {
                    case .readyToPlay:
                        self?.isLoading = false
                    case .failed:
                        self?.isLoading = false
                        self?.error = playerItem.error
                    default:
                        break
                    }
                }
            }
            .store(in: &cancellables)

        // Track video completion
        videoCompletionObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            self?.onVideoComplete?()
        }
    }

    func replayVideo() {
        player?.seek(to: .zero)
        player?.play()
    }

    deinit {
        if let observer = videoCompletionObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
