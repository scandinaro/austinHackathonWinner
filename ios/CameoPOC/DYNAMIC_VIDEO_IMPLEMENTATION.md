# Making Video URL Dynamic - Implementation Guide

## Current State

The app currently:
1. ✅ Parses video ID from URL (`v.cameo.com/abc123`)
2. ✅ Stores it in `AppState.videoID`
3. ❌ BUT doesn't use it - still loads hardcoded video

## Goal

Make the video URL dynamic based on the App Clip invocation URL.

## Implementation Options

### Option A: Simple - Video ID Only (Recommended for POC)

**Flow:**
```
v.cameo.com/6536b92a64a84efc4acbce6a
    ↓ (parse video ID)
6536b92a64a84efc4acbce6a
    ↓ (construct URL)
https://cdn.cameo.com/video/6536b92a64a84efc4acbce6a-processed.mp4
```

**Changes needed:**

1. **Update VideoViewModel to accept video ID**
   ```swift
   class VideoViewModel: ObservableObject {
       // Add video ID parameter
       func loadVideo(videoID: String?) {
           let videoURLString: String

           if let videoID = videoID {
               // Construct URL from video ID
               videoURLString = "https://cdn.cameo.com/video/\(videoID)-processed.mp4"
               print("🎬 Loading video: \(videoID)")
           } else {
               // Fallback to default video
               videoURLString = "https://cdn.cameo.com/video/6536b92a64a84efc4acbce6a-processed.mp4"
               print("🎬 Loading default video")
           }

           // ... rest of loading code
       }
   }
   ```

2. **Update ContentView to pass video ID**
   ```swift
   struct ContentView: View {
       @EnvironmentObject var appState: AppState
       @StateObject private var viewModel = VideoViewModel()

       var body: some View {
           ZStack {
               // ... existing code
           }
           .onAppear {
               // Load video with ID from appState
               if viewModel.player == nil {
                   viewModel.loadVideo(videoID: appState.videoID)
               }
           }
       }
   }
   ```

3. **Remove auto-load from init()**
   ```swift
   init() {
       // Don't auto-load anymore
       // loadVideo() ← Remove this
   }
   ```

**Pros:**
- Simple, clean implementation
- Works for POC/testing
- Easy to understand

**Cons:**
- Assumes video URL pattern (`-processed.mp4` suffix)
- No validation if video exists
- Limited flexibility

---

### Option B: API Fetch (Production Ready)

**Flow:**
```
v.cameo.com/abc123
    ↓ (parse video ID)
abc123
    ↓ (API call)
GET https://api.cameo.com/videos/abc123
    ↓ (response)
{ "video_url": "https://cdn.cameo.com/...", "thumbnail": "...", "celebrity": "..." }
    ↓ (use URL)
Load video from response
```

**Changes needed:**

1. **Add API service**
   ```swift
   class CameoAPIService {
       static func fetchVideoMetadata(videoID: String) async throws -> VideoMetadata {
           let url = URL(string: "https://api.cameo.com/videos/\(videoID)")!
           let (data, _) = try await URLSession.shared.data(from: url)
           return try JSONDecoder().decode(VideoMetadata.self, from: data)
       }
   }

   struct VideoMetadata: Codable {
       let videoURL: String
       let thumbnail: String?
       let celebrity: String?
       let duration: Int?
   }
   ```

2. **Update VideoViewModel**
   ```swift
   func loadVideo(videoID: String?) async {
       guard let videoID = videoID else {
           // Load default
           return
       }

       do {
           let metadata = try await CameoAPIService.fetchVideoMetadata(videoID: videoID)

           DispatchQueue.main.async {
               self.loadVideoFromURL(metadata.videoURL)
           }
       } catch {
           print("❌ Failed to fetch video metadata: \(error)")
           // Fallback or show error
       }
   }
   ```

**Pros:**
- Production-ready
- Validates video exists
- Can get additional metadata (celebrity name, thumbnail, etc.)
- Flexible - supports any video URL format

**Cons:**
- More complex
- Requires API endpoint
- Network dependency (slower initial load)
- Need error handling

---

### Option C: Branch Deep Link Data (Best for Production)

**Flow:**
```
Branch link created with:
{
  "video_id": "abc123",
  "video_url": "https://cdn.cameo.com/video/abc123-processed.mp4",
  "celebrity": "Snoop Dogg",
  "thumbnail": "https://...",
  "$ios_url": "cameo://video/abc123"
}
    ↓ (Branch SDK parses on launch)
Branch.initSession() returns all data
    ↓ (use directly)
Load video from video_url
```

**Changes needed:**

1. **Add Branch SDK** (in Xcode)
   - Add Branch to Package Dependencies
   - Or: `pod 'Branch'` in Podfile

2. **Initialize Branch in App**
   ```swift
   @main
   struct CameoAppClipApp: App {
       @StateObject private var appState = AppState()

       var body: some Scene {
           WindowGroup {
               ContentView()
                   .environmentObject(appState)
                   .onOpenURL { url in
                       Branch.getInstance().handleDeepLink(url)
                   }
           }
       }

       init() {
           Branch.getInstance().initSession(launchOptions: nil) { params, error in
               if let params = params as? [String: Any] {
                   // Extract video data from Branch
                   if let videoURL = params["video_url"] as? String {
                       appState.videoURL = videoURL
                   }
                   if let videoID = params["video_id"] as? String {
                       appState.videoID = videoID
                   }
                   if let celebrity = params["celebrity"] as? String {
                       appState.celebrityName = celebrity
                   }
               }
           }
       }
   }
   ```

3. **Update AppState**
   ```swift
   class AppState: ObservableObject {
       @Published var videoID: String?
       @Published var videoURL: String?
       @Published var celebrityName: String?
       @Published var thumbnail: String?
   }
   ```

4. **Use in VideoViewModel**
   ```swift
   func loadVideo(videoURL: String?, videoID: String?) {
       let urlString: String

       if let videoURL = videoURL {
           // Use full URL from Branch
           urlString = videoURL
       } else if let videoID = videoID {
           // Construct from ID
           urlString = "https://cdn.cameo.com/video/\(videoID)-processed.mp4"
       } else {
           // Fallback
           urlString = "https://cdn.cameo.com/video/6536b92a64a84efc4acbce6a-processed.mp4"
       }

       // Load video...
   }
   ```

**Pros:**
- Best of both worlds
- Rich metadata from Branch
- Works offline (Branch caches)
- Attribution tracking
- Deep linking support
- You already use Branch!

**Cons:**
- Requires Branch SDK integration
- Slightly more setup
- Need to configure Branch dashboard

---

## Recommended Approach for Your Project

### Phase 1: POC (Now) - Option A
- Quick to implement
- Validates the flow
- Good for stakeholder demos

### Phase 2: Integration - Option C
- Add Branch SDK
- You already use `v.cameo.com` with Branch
- Full attribution and deep linking
- Production-ready

### Phase 3: Enhancement (Optional)
- Add API validation (Option B)
- Prefetch video metadata
- Show celebrity name in overlay
- Video thumbnails while loading

---

## Testing Each Approach

### Option A: Test with simulator
```bash
# Test with different video IDs
xcrun simctl openurl booted "https://v.cameo.com/6536b92a64a84efc4acbce6a"
xcrun simctl openurl booted "https://v.cameo.com/another-video-id"
```

### Option C: Test with Branch
```bash
# Create test Branch link in dashboard
# Encode metadata in link
# Test with QR code or simulator URL
```

---

## Code Changes Summary

For **Option A** (quickest for POC):

**3 files to modify:**

1. `VideoViewModel.swift`:
   - Change `loadVideo()` to `loadVideo(videoID: String?)`
   - Construct URL from videoID parameter
   - Remove `loadVideo()` call from `init()`

2. `ContentView.swift`:
   - Add `.onAppear` to call `viewModel.loadVideo(videoID: appState.videoID)`
   - Or use `.onChange(of: appState.videoID)` for reactive updates

3. `CameoAppClipApp.swift`:
   - Already done! URL parsing is working

**Time estimate:** 15 minutes

---

## Want me to implement Option A now?

I can make these changes right now if you want to test dynamic video loading!
