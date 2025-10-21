import Foundation

enum AnalyticsEvent: String {
    case videoViewed = "video_viewed"
    case videoLoaded = "video_loaded"
    case videoLoadFailed = "video_load_failed"
    case videoCompleted = "video_completed"
    case videoReplayed = "video_replayed"
    case downloadButtonTapped = "download_button_tapped"
    case replayButtonTapped = "replay_button_tapped"
    case appClipLaunched = "app_clip_launched"
}

class AnalyticsManager {
    static let shared = AnalyticsManager()

    private init() {}

    func track(event: AnalyticsEvent, properties: [String: Any]? = nil) {
        var eventData: [String: Any] = [
            "event": event.rawValue,
            "timestamp": Date().ISO8601Format(),
            "platform": "app_clip"
        ]

        if let properties = properties {
            eventData.merge(properties) { _, new in new }
        }

        // In production, send to analytics service (Mixpanel, Amplitude, etc.)
        print("📊 Analytics Event: \(event.rawValue)")
        if let properties = properties {
            print("   Properties: \(properties)")
        }

        // Send to backend
        sendToBackend(eventData)
    }

    private func sendToBackend(_ data: [String: Any]) {
        // API endpoint for analytics
        guard let url = URL(string: "https://api.cameo.com/analytics/events") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data)

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Analytics error: \(error.localizedDescription)")
                }
            }.resume()
        } catch {
            print("Failed to serialize analytics data: \(error)")
        }
    }

    // Conversion rate tracking
    func trackConversionFunnel(step: String) {
        track(event: .appClipLaunched, properties: [
            "funnel_step": step,
            "session_id": getCurrentSessionID()
        ])
    }

    private func getCurrentSessionID() -> String {
        // Generate or retrieve session ID
        return UUID().uuidString
    }
}
