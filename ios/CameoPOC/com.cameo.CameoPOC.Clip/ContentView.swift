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
                    GiftUnwrapView(
                        onUnwrap: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                hasUnwrapped = true
                            }
                            // Start playing video after unwrap
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                player.play()
                            }
                        },
                        player: player
                    )
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
        VStack(spacing: 0) {
            // Header at top
            VStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
                    .shadow(radius: 10)

                Text("Keep this Cameo forever")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 60)

            Spacer()

            // CTAs at bottom
            VStack(spacing: 12) {
                Button(action: onDownload) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.title3)
                        Text("Save Video")
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
            .padding(.bottom, 40)
        }
    }
}

struct GiftUnwrapView: View {
    let onUnwrap: () -> Void
    let player: AVPlayer

    @State private var revealedPoints: [CGPoint] = []
    @State private var revealPercentage: Double = 0
    @State private var thumbnail: UIImage?
    @State private var hasStartedRevealing = false
    @State private var revealedCells: Set<String> = [] // Track unique grid cells for accurate percentage

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Video thumbnail (blurred initially, revealed by touch)
                if let thumbnail = thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } else {
                    // Fallback gradient while thumbnail loads
                    Color.black
                }

                // Invisible ink overlay
                Canvas { context, size in
                    // Fill entire canvas with sparkle pattern
                    context.fill(
                        Path(CGRect(origin: .zero, size: size)),
                        with: .color(.white.opacity(0.65))
                    )

                    // "Erase" revealed areas
                    for point in revealedPoints {
                        let circlePath = Circle()
                            .path(in: CGRect(
                                x: point.x - 40,
                                y: point.y - 40,
                                width: 80,
                                height: 80
                            ))

                        context.blendMode = .destinationOut
                        context.fill(circlePath, with: .color(.white))
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if !hasStartedRevealing {
                                hasStartedRevealing = true
                            }

                            // Add revealed point and interpolate between last point for smooth lines
                            if let lastPoint = revealedPoints.last {
                                let distance = sqrt(pow(value.location.x - lastPoint.x, 2) + pow(value.location.y - lastPoint.y, 2))

                                // Interpolate points between last and current for smooth connection
                                if distance > 5 {
                                    let steps = Int(distance / 5)
                                    for i in 1...steps {
                                        let t = CGFloat(i) / CGFloat(steps)
                                        let interpolatedPoint = CGPoint(
                                            x: lastPoint.x + (value.location.x - lastPoint.x) * t,
                                            y: lastPoint.y + (value.location.y - lastPoint.y) * t
                                        )
                                        revealedPoints.append(interpolatedPoint)

                                        // Track unique 50x50 grid cells for accurate percentage calculation
                                        let cellX = Int(interpolatedPoint.x / 50)
                                        let cellY = Int(interpolatedPoint.y / 50)
                                        revealedCells.insert("\(cellX),\(cellY)")
                                    }
                                }
                            } else {
                                revealedPoints.append(value.location)
                                let cellX = Int(value.location.x / 50)
                                let cellY = Int(value.location.y / 50)
                                revealedCells.insert("\(cellX),\(cellY)")
                            }

                            // Calculate reveal percentage based on unique grid cells covered
                            let totalCellsX = Int(ceil(geometry.size.width / 50))
                            let totalCellsY = Int(ceil(geometry.size.height / 50))
                            let totalCells = totalCellsX * totalCellsY
                            revealPercentage = Double(revealedCells.count) / Double(totalCells)

                            // Auto-reveal when threshold reached
                            if revealPercentage > 0.40 {
                                withAnimation(.easeOut(duration: 0.8)) {
                                    revealPercentage = 1.0
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onUnwrap()
                                }
                            }
                        }
                )

                // Sparkle overlay effect
                if !hasStartedRevealing {
                    ZStack {
                        // Shimmer effect
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0),
                                Color.white.opacity(0.3),
                                Color.white.opacity(0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )

                        // Sparkles scattered around
                        ForEach(0..<20, id: \.self) { index in
                            Image(systemName: "sparkle")
                                .foregroundColor(.yellow.opacity(0.6))
                                .font(.system(size: CGFloat.random(in: 12...24)))
                                .position(
                                    x: CGFloat.random(in: 0...geometry.size.width),
                                    y: CGFloat.random(in: 0...geometry.size.height)
                                )
                        }
                    }
                    .allowsHitTesting(false)
                }

                // Instruction text
                if !hasStartedRevealing {
                    VStack {
                        Spacer()

                        VStack(spacing: 12) {
                            Image(systemName: "hand.draw")
                                .font(.system(size: 40))
                                .foregroundColor(.white)

                            Text("Swipe to reveal your Cameo")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(20)
                        }
                        .padding(.bottom, 60)
                    }
                    .allowsHitTesting(false)
                }

                // Progress indicator
                if hasStartedRevealing && revealPercentage < 0.40 {
                    VStack {
                        HStack {
                            Spacer()
                            Text("\(Int(revealPercentage * 100))%")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(8)
                                .padding()
                        }
                        Spacer()
                    }
                    .allowsHitTesting(false)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            generateThumbnail()
        }
    }

    private func generateThumbnail() {
        guard let currentItem = player.currentItem else { return }

        let asset = currentItem.asset
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSize(width: 1920, height: 1080)

        let time = CMTime(seconds: 1, preferredTimescale: 600)

        imageGenerator.generateCGImageAsynchronously(for: time) { cgImage, actualTime, error in
            if let error = error {
                print("⚠️ Failed to generate thumbnail: \(error)")
                return
            }

            guard let cgImage = cgImage else { return }

            let uiImage = UIImage(cgImage: cgImage)

            DispatchQueue.main.async {
                self.thumbnail = uiImage
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
