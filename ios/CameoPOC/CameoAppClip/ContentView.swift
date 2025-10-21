import SwiftUI
import AVKit
import StoreKit

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = VideoViewModel()
    @State private var showPostVideoActions = false

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView("Loading your Cameo...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if let player = viewModel.player {
                VideoPlayerView(
                    player: player,
                    viewModel: viewModel,
                    onVideoComplete: {
                        withAnimation {
                            showPostVideoActions = true
                        }
                    }
                )
                .ignoresSafeArea()
                .onAppear {
                    AnalyticsManager.shared.track(event: .videoViewed)
                }
            } else {
                ErrorView()
            }

            // Post-video actions overlay (only shown after video ends)
            if showPostVideoActions {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .transition(.opacity)

                PostVideoActionsView(
                    onDownload: {
                        handleDownloadVideo()
                    },
                    onReplay: {
                        viewModel.replayVideo()
                        withAnimation {
                            showPostVideoActions = false
                        }
                    }
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
    }

    private func handleDownloadVideo() {
        AnalyticsManager.shared.track(event: .downloadButtonTapped)

        // POC: Show App Store overlay (requires parent app in production)
        // In standalone POC, this will log to console only
        #if targetEnvironment(simulator)
        print("🎯 POC: Would show App Store overlay for full Cameo app")
        print("    In production: SKOverlay will prompt user to download full app")
        #else
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }

        let config = SKOverlay.AppClipConfiguration(position: .bottom)
        let overlay = SKOverlay(configuration: config)
        overlay.present(in: scene)
        #endif
    }
}

struct VideoPlayerView: View {
    let player: AVPlayer
    @ObservedObject var viewModel: VideoViewModel
    let onVideoComplete: () -> Void

    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                player.play()
                viewModel.onVideoComplete = onVideoComplete
            }
    }
}

struct PostVideoActionsView: View {
    let onDownload: () -> Void
    let onReplay: () -> Void
    @State private var showPOCBadge = true

    var body: some View {
        VStack(spacing: 24) {
            // POC Badge (remove in production)
            if showPOCBadge {
                HStack {
                    Spacer()
                    Text("POC MODE")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(4)
                }
                .padding(.horizontal)
            }

            Spacer()

            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
                .shadow(radius: 10)

            Text("✨ Want to keep this Cameo forever?")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("Download the Cameo app to save this video and order personalized videos from thousands of celebrities")
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(spacing: 12) {
                Button(action: {
                    print("🎯 [POC] Download button tapped - would show App Store")
                    onDownload()
                }) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.title3)
                        Text("Download & Save Video")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }

                Button(action: {
                    print("🔄 [POC] Replay button tapped - restarting video")
                    onReplay()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Watch Again")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .padding()
    }
}

struct ErrorView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("Unable to Load Video")
                .font(.title2)
                .fontWeight(.bold)

            Text("Please check your connection and try again")
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
