import SwiftUI

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
        }
    }

    private func handleIncomingURL(_ url: URL) {
        // Parse Branch link (e.g., v.cameo.com/abc123)
        print("App Clip invoked with Branch URL: \(url)")

        // Extract video ID from v.cameo.com URL
        if url.host == "v.cameo.com" {
            let videoID = url.lastPathComponent
            appState.videoID = videoID
            AnalyticsManager.shared.track(event: .appClipLaunched, properties: [
                "video_id": videoID,
                "url": url.absoluteString
            ])
        }
    }
}

class AppState: ObservableObject {
    @Published var videoID: String?
}
