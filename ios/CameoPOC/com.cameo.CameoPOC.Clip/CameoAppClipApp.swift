import SwiftUI
import Combine

@main
struct CameoAppClipApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                    guard let url = userActivity.webpageURL else { return }
                    // Handle Branch v.cameo.com universal links
                    handleIncomingURL(url)
                }
                .onOpenURL { url in
                    // Handle any URL scheme (including test invocations)
                    handleIncomingURL(url)
                }
        }
    }

    private func handleIncomingURL(_ url: URL) {
        // Parse Branch link (e.g., v.cameo.com/abc123)
        print("🔗 App Clip invoked with URL: \(url)")
        print("   Host: \(url.host ?? "nil")")
        print("   Path: \(url.path)")
        print("   Last component: \(url.lastPathComponent)")

        // Extract video ID from v.cameo.com URL
        if url.host == "v.cameo.com" || url.host == "www.v.cameo.com" {
            let videoID = url.lastPathComponent
            print("✅ Extracted video ID: \(videoID)")
            appState.videoID = videoID
        } else {
            print("⚠️ URL host '\(url.host ?? "nil")' doesn't match v.cameo.com")
        }
    }
}

class AppState: ObservableObject {
    @Published var videoID: String?
}
