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
        loadVideo()
    }

    func loadVideo() {
        // POC: Using sample video for testing
        // In production: fetch video URL from Branch link data or Cameo API
        // using the videoID from AppState

        // Sample videos for testing (choose based on desired duration):
        // - BigBuckBunny (10 min): Full experience
        // - ForBiggerBlazes (15 sec): Quick testing
        let videoURLString = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"

        print("🎬 POC: Loading sample video")
        print("    Production will load: https://cdn.cameo.com/videos/{videoID}.mp4")

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
                        AnalyticsManager.shared.track(event: .videoLoaded)
                    case .failed:
                        self?.isLoading = false
                        self?.error = playerItem.error
                        AnalyticsManager.shared.track(event: .videoLoadFailed)
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
            AnalyticsManager.shared.track(event: .videoCompleted)
            self?.onVideoComplete?()
        }
    }

    func replayVideo() {
        player?.seek(to: .zero)
        player?.play()
        AnalyticsManager.shared.track(event: .videoReplayed)
    }

    deinit {
        if let observer = videoCompletionObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
