# Testing Dynamic Video Without URL Invocation

Since we're in POC mode and don't have the App Clip fully registered, here are ways to test:

## Option 1: Hardcode Test Video ID (Quickest)

Temporarily hardcode a test video ID in `CameoAppClipApp.swift`:

**Change this:**
```swift
private func handleIncomingURL(_ url: URL) {
    // Parse Branch link (e.g., v.cameo.com/abc123)
    print("App Clip invoked with Branch URL: \(url)")

    // Extract video ID from v.cameo.com URL
    if url.host == "v.cameo.com" {
        let videoID = url.lastPathComponent
        appState.videoID = videoID
        // ...
    }
}
```

**To this (temporarily):**
```swift
init() {
    // POC: Simulate URL invocation with test video ID
    // Remove this in production!
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        // Test different video IDs here:
        self.appState.videoID = "6536b92a64a84efc4acbce6a"  // Change this to test different videos
        print("🧪 POC: Simulating App Clip invocation with video ID: \(self.appState.videoID ?? "nil")")
    }
}
```

Then rebuild and run - it will load that video ID.

## Option 2: Add Debug Button (Better for Testing)

Add a debug menu to test different videos without rebuilding:

**In ContentView.swift, add this at the bottom:**
```swift
#if DEBUG
struct DebugVideoSelector: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var viewModel: VideoViewModel
    @State private var testVideoID = "6536b92a64a84efc4acbce6a"

    var body: some View {
        VStack {
            TextField("Enter Video ID", text: $testVideoID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Load Video") {
                appState.videoID = testVideoID
                viewModel.loadVideo(videoID: testVideoID)
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .background(Color.white)
    }
}
#endif
```

## Option 3: Use _XCAppClipURL Environment Variable

In Xcode:

1. Click on the scheme dropdown → **Edit Scheme**
2. Select **Run** in left sidebar
3. Go to **Arguments** tab
4. Under **Environment Variables**, add:
   - Name: `_XCAppClipURL`
   - Value: `https://v.cameo.com/6536b92a64a84efc4acbce6a`
5. Click **Close**
6. Run the app

This tells Xcode to simulate an App Clip invocation with that URL.

## Option 4: Create Custom URL Scheme (For Testing)

Add a custom URL scheme just for testing:

1. In Xcode, select **com.cameo.CameoPOC.Clip** target
2. Go to **Info** tab
3. Expand **URL Types**
4. Add new URL Type:
   - Identifier: `com.cameo.appclip.test`
   - URL Schemes: `cameotest`
5. Save

Then you can test with:
```bash
xcrun simctl openurl booted "cameotest://video/6536b92a64a84efc4acbce6a"
```

And update the URL handler in `CameoAppClipApp.swift`:
```swift
.onOpenURL { url in
    if url.scheme == "cameotest" {
        // Parse test URL
        let videoID = url.lastPathComponent
        appState.videoID = videoID
    }
}
```

## Recommended for POC Testing

Use **Option 1** (hardcode test video ID) - it's the simplest for quick testing.

Just change the video ID in the init() method, rebuild, and test!

When you want to test a different video:
1. Change the video ID
2. Cmd+B (build)
3. Cmd+R (run)
4. New video loads!

## For Production Testing

Once you're ready for real testing:
- Register the App Clip in App Store Connect
- Set up the App Clip experience for v.cameo.com domain
- Then real URLs will work on device
