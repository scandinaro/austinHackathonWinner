import SwiftUI
import AVKit
import StoreKit

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = VideoViewModel()
    @State private var showPostVideoActions = false
    @State private var hasUnwrapped = false

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

                // Gift unwrapping overlay
                if !hasUnwrapped {
                    GiftUnwrapView(onUnwrap: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            hasUnwrapped = true
                        }
                        // Start playing video after unwrap
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            player.play()
                        }
                    })
                    .transition(.opacity)
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
        .onChange(of: appState.videoID) { oldValue, newValue in
            // React to video ID changes from URL invocation
            print("📱 ContentView: Video ID changed from '\(oldValue ?? "nil")' to '\(newValue ?? "nil")'")
            viewModel.loadVideo(videoID: newValue)
        }
        .onAppear {
            // Load video on initial appear (will use default if no ID yet)
            if appState.videoID != nil {
                viewModel.loadVideo(videoID: appState.videoID)
            }
        }
    }

    private func handleDownloadVideo() {
        // Open Cameo app in App Store
        // Try App Store URL scheme first (works better on device)
        let appStoreID = "1258311581"
        let appStoreURL = "itms-apps://apps.apple.com/app/id\(appStoreID)"

        // Fallback to web URL for simulator
        let webURL = "https://apps.apple.com/us/app/cameo-personal-celeb-videos/id\(appStoreID)"

        if let url = URL(string: appStoreURL) {
            print("🎯 Opening App Store: \(appStoreURL)")
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    print("✅ Successfully opened App Store")
                } else {
                    print("⚠️ App Store URL failed, trying web URL")
                    // Fallback to web URL
                    if let webUrl = URL(string: webURL) {
                        UIApplication.shared.open(webUrl, options: [:])
                    }
                }
            }
        }
    }
}

struct VideoPlayerView: View {
    let player: AVPlayer
    @ObservedObject var viewModel: VideoViewModel
    let onVideoComplete: () -> Void

    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                // Don't auto-play - wait for unwrap gesture
                viewModel.onVideoComplete = onVideoComplete
            }
    }
}

struct PostVideoActionsView: View {
    let onDownload: () -> Void
    let onReplay: () -> Void

    var body: some View {
        VStack(spacing: 24) {
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
                Button(action: onDownload) {
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

                Button(action: onReplay) {
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

struct GiftUnwrapView: View {
    let onUnwrap: () -> Void
    @State private var dragOffset: CGFloat = 0
    @State private var isUnwrapping = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.purple.opacity(0.8), Color.pink.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Gift box icon with shimmer effect
                ZStack {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 120))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .yellow.opacity(0.5), radius: 20)
                        .scaleEffect(isUnwrapping ? 0.1 : 1.0)
                        .opacity(isUnwrapping ? 0 : 1)

                    // Sparkles
                    if !isUnwrapping {
                        ForEach(0..<8) { index in
                            Image(systemName: "sparkle")
                                .font(.system(size: 20))
                                .foregroundColor(.yellow)
                                .offset(
                                    x: cos(Double(index) * .pi / 4) * 80,
                                    y: sin(Double(index) * .pi / 4) * 80
                                )
                                .opacity(0.8)
                        }
                    }
                }
                .offset(y: dragOffset * 0.5)

                VStack(spacing: 12) {
                    Text("You've Received a Cameo!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("Swipe up to reveal your video")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal)

                    // Drag indicator
                    Image(systemName: "chevron.compact.up")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.7))
                        .offset(y: -10 + abs(sin(Date().timeIntervalSince1970 * 2) * 5))
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: Date())
                }
                .offset(y: dragOffset * 0.3)
                .opacity(isUnwrapping ? 0 : 1)

                Spacer()
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Only allow upward drag
                        if value.translation.height < 0 {
                            dragOffset = value.translation.height
                        }
                    }
                    .onEnded { value in
                        if value.translation.height < -100 {
                            // Unwrap threshold reached
                            isUnwrapping = true
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                dragOffset = -UIScreen.main.bounds.height
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                onUnwrap()
                            }
                        } else {
                            // Reset if not dragged far enough
                            withAnimation(.spring()) {
                                dragOffset = 0
                            }
                        }
                    }
            )
        }
        .onAppear {
            // Subtle breathing animation for gift box
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                // Animation handled by sparkles
            }
        }
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
